#!/bin/bash
# Update an existing MMOD installation without changing repeater settings.
set -euo pipefail
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
if [[ "${1:-}" == --help ]]; then
  echo 'sudo bash mmodupdate.sh [--verify-only]'
  echo 'Updates MMOD only. Preserves station settings, passwords, history and radio configuration.'
  exit 0
fi
verify=0
[[ "${1:-}" != --verify-only ]] || verify=1
[[ $# == 0 || ( $# == 1 && $verify == 1 ) ]] || { echo 'Unknown option'; exit 1; }
if [[ $verify == 0 ]]; then
  [[ $(id -u) == 0 ]] || { echo 'Run with sudo.'; exit 1; }
  [[ -x /opt/mmod/venv/bin/python && -f /etc/mmod/config.json ]] || { echo 'MMOD is not installed. Run mmodinstall.sh first.'; exit 1; }
  exec 9>/run/lock/mmod-update.lock
  flock -n 9 || { echo 'Another MMOD update is running.'; exit 1; }
fi
for utility in curl python3 tar; do command -v "$utility" >/dev/null || { echo "Missing: $utility"; exit 1; }; done
stage=$(mktemp -d /tmp/mmod-update.XXXXXXXX)
backup=''
changing=0
had_capture=0
[[ ! -f /etc/systemd/system/mmod-log-capture.service ]] || had_capture=1
cleanup() {
  result=$?
  trap - EXIT
  if [[ $result != 0 && $changing == 1 ]]; then
    echo "Update failed. Restoring dashboard from $backup"
    systemctl stop mmod mmod-radio mmod-log-capture.service mmod-collector.timer mmod-control.timer mmod-collector.service mmod-control.service || true
    if [[ $had_capture == 0 ]]; then
      systemctl disable mmod-log-capture.service 2>/dev/null || true
      rm -f /etc/systemd/system/mmod-log-capture.service
    fi
    tar -xzf "$backup/dashboard.tar.gz" -C /
    tar -xzf "$backup/units.tar.gz" -C /
    systemctl daemon-reload
    systemctl start mmod mmod-radio mmod-collector.timer mmod-control.timer || true
    echo 'Previous dashboard restored. Radio services were not restarted.'
  fi
  case "$stage" in /tmp/mmod-update.*) rm -rf -- "$stage" ;; esac
  exit "$result"
}
trap cleanup EXIT
# Resolve main once so every downloaded release file comes from the same commit.
curl --fail --silent --show-error --location --retry 2 --max-time 60 \
  https://api.github.com/repos/txlinked/mmod/commits/main -o "$stage/commit.json"
release=$(python3 -c 'import json,re,sys; s=json.load(open(sys.argv[1]))["sha"]; assert re.fullmatch("[a-f0-9]{40}",s); print(s)' "$stage/commit.json")
echo "Downloading MMOD release $release"
curl --fail --silent --show-error --location --retry 2 --max-time 180 \
  "https://raw.githubusercontent.com/txlinked/mmod/$release/mmod-source.tar.gz" -o "$stage/source.tar.gz"
python3 - "$stage" <<'PY'
import pathlib,sys,tarfile
stage=pathlib.Path(sys.argv[1])
with tarfile.open(stage/'source.tar.gz') as archive:
    items=archive.getmembers()
    if sum(m.size for m in items)>20000000: raise ValueError('Unexpected package size')
    for member in items:
        p=pathlib.PurePosixPath(member.name)
        if p.is_absolute() or '..' in p.parts or not p.parts or p.parts[0]!='mmod' or not member.isfile():
            raise ValueError('Unsafe package member')
        target=stage/p
        target.parent.mkdir(parents=True,exist_ok=True)
        target.write_bytes(archive.extractfile(member).read())
source=stage/'mmod'
for name in ['app.py','radio.py','log_capture.py','systemd/mmod-log-capture.service','collector.py','control.py','directories.py','static/index.html','static/app.js','static/mobile.css','requirements.lock','systemd/mmod.service']:
    if not (source/name).is_file():raise ValueError('Incomplete release: '+name)
for path in source.glob('*.py'):compile(path.read_text(),str(path),'exec')
print('Package validation passed')
PY
[[ $verify == 0 ]] || { echo "Verified release $release; nothing installed."; exit 0; }
stamp=$(date -u +%Y%m%dT%H%M%SZ)
umask 077
exec > >(tee -a "/var/log/mmod-update-$stamp.log") 2>&1
backup=/var/backups/mmod-update-$stamp
install -d -m 700 "$backup"
# Includes the current Python environment for rollback if dependencies change.
tar -czf "$backup/dashboard.tar.gz" -C / opt/mmod
tar -czf "$backup/units.tar.gz" /etc/systemd/system/mmod*
tar -czf "$backup/settings.tar.gz" -C / etc/mmod var/lib/mmod/state
echo "Backup: $backup"
changing=1
systemctl stop mmod-log-capture.service 2>/dev/null || true
systemctl stop mmod mmod-radio mmod-collector.timer mmod-control.timer mmod-collector.service mmod-control.service
source="$stage/mmod"
if ! cmp -s "$source/requirements.lock" /opt/mmod/requirements.lock; then
  /opt/mmod/venv/bin/python -m pip install --disable-pip-version-check --no-cache-dir -r "$source/requirements.lock"
fi
for name in app.py radio.py log_capture.py collector.py control.py admin.py directories.py subscriber-update.py setup_config.py requirements.txt requirements.lock VERSION README.md BUILDLOG.md ADVANCED-SETUP.md INSTALL-DELL-3040.md LICENSE; do
  install -m 644 "$source/$name" /opt/mmod/
done
install -m 644 "$source"/static/* /opt/mmod/static/
install -m 644 "$source"/systemd/* /opt/mmod/systemd/
install -m 644 "$source"/systemd/* /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now mmod-subscribers.timer mmod-directories.timer mmod-control.timer mmod-collector.timer
systemctl start mmod-collector.service
systemctl start --no-block mmod-subscribers.service
systemctl enable --now mmod-log-capture.service
systemctl start mmod-radio mmod
python3 - <<'PY'
import json,pathlib,time,urllib.request
values=dict(line.split('=',1) for line in pathlib.Path('/etc/mmod/listen.env').read_text().splitlines() if '=' in line and not line.startswith('#'))
host=values['MMOD_BIND']
if host=='0.0.0.0':host='127.0.0.1'
url='http://'+host+':'+values.get('MMOD_PORT','8000')+'/api/health'
for attempt in range(30):
    try:
        result=json.load(urllib.request.urlopen(url,timeout=3))
        if result['ok']:break
    except (OSError,ValueError):pass
    time.sleep(1)
else:raise RuntimeError('Dashboard health check failed')
PY
printf '%s\n' "$release" > /opt/mmod/release.txt
changing=0
echo "MMOD V$(cat /opt/mmod/VERSION) updated successfully ($release). Refresh your browser."
echo 'Station settings, password, history and radio configuration were preserved.'
echo "Backup: $backup"
echo "Log: /var/log/mmod-update-$stamp.log"
