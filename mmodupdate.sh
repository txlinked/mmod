#!/bin/bash
# Update an existing MMOD installation without changing repeater settings.
set -euo pipefail
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
if [[ "${1:-}" == --help ]]; then
  echo 'sudo bash mmodupdate.sh [--verify-only]'
  echo 'Updates the MMOD dashboard only. Preserves station settings, passwords, history and radio configuration.'
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
had_limit=0
had_links=0
[[ ! -f /etc/systemd/system/mmod-links.service ]] || had_links=1
[[ ! -f /etc/systemd/system/mmod-log-capture.service ]] || had_capture=1
[[ ! -f /etc/systemd/system/mmod-log-limit.service ]] || had_limit=1
cleanup() {
  result=$?
  trap - EXIT
  if [[ $result != 0 && $changing == 1 ]]; then
    echo "Update failed. Restoring dashboard from $backup"
    systemctl stop mmod mmod-radio mmod-log-capture.service mmod-collector.timer mmod-control.timer mmod-collector.service mmod-control.service || true
    systemctl stop mmod-log-limit.timer mmod-log-limit.service 2>/dev/null || true
    if [[ $had_limit == 0 ]]; then
      systemctl disable mmod-log-limit.timer 2>/dev/null || true
      rm -f /etc/systemd/system/mmod-log-limit.service /etc/systemd/system/mmod-log-limit.timer
    fi
    if [[ $had_capture == 0 ]]; then
      systemctl disable mmod-log-capture.service 2>/dev/null || true
      rm -f /etc/systemd/system/mmod-log-capture.service
    fi
    systemctl stop mmod-links.timer mmod-links.service mmod-subscribers.timer mmod-subscribers.service mmod-directories.timer mmod-directories.service 2>/dev/null || true
    if [[ $had_links == 0 ]]; then
      systemctl disable mmod-links.timer 2>/dev/null || true
      rm -f /etc/systemd/system/mmod-links.service /etc/systemd/system/mmod-links.timer
    fi
    rm -f /etc/systemd/system/mmod-control.service.d/v2.conf
    # Stop writers before restoring SQLite and local secrets.
    rm -f /var/lib/mmod/state/auth.sqlite /var/lib/mmod/state/auth.sqlite-wal /var/lib/mmod/state/auth.sqlite-shm /var/lib/mmod/state/auth.sqlite-journal /etc/mmod/control-profile.json
    tar -xzf "$backup/settings.tar.gz" -C /
    tar -xzf "$backup/dashboard.tar.gz" -C /
    tar -xzf "$backup/units.tar.gz" -C /
    systemctl daemon-reload
systemctl enable --now mmod-allstar-directory.timer
systemctl start --no-block mmod-allstar-directory.service
    systemctl start mmod mmod-radio mmod-collector.timer mmod-control.timer mmod-subscribers.timer mmod-directories.timer || true
    [[ $had_capture == 0 ]] || systemctl start mmod-log-capture.service || true
    [[ $had_limit == 0 ]] || systemctl start mmod-log-limit.timer || true
    [[ $had_links == 0 ]] || systemctl start mmod-links.timer || true
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
for name in ['idle_links.py','allstar.py','static/allstar.js','static/allstar.css','accounts.py','v2_api.py','v2_radio.py','brandmeister.py','discover_controls.py','link_status.py','systemd/mmod-links.timer','static/v2.js','static/links.js','app.py','radio.py','log_capture.py','log_limit.py','systemd/mmod-log-limit.timer','systemd/mmod-log-capture.service','collector.py','control.py','directories.py','static/index.html','static/app.js','static/mobile.css','requirements.lock','systemd/mmod.service']:
    if not (source/name).is_file():raise ValueError('Incomplete release: '+name)
for path in source.glob('*.py'):compile(path.read_text(),str(path),'exec')
print('Package validation passed')
PY
[[ $verify == 0 ]] || { echo "Verified release $release; nothing installed."; exit 0; }
# Dashboard-only update; existing radio software is managed separately.
python3 "$stage/mmod/platform_detect.py"
platform_kind=$(python3 "$stage/mmod/platform_detect.py" --kind)
stamp=$(date -u +%Y%m%dT%H%M%SZ)
umask 077
exec > >(tee -a "/var/log/mmod-update-$stamp.log") 2>&1
backup=/var/backups/mmod-update-$stamp
install -d -m 700 "$backup"
# Includes the current Python environment for rollback if dependencies change.
tar -czf "$backup/dashboard.tar.gz" -C / opt/mmod
tar -czf "$backup/units.tar.gz" /etc/systemd/system/mmod*
# Quiesce SQLite and all MMOD writers before the state backup/migration.
systemctl stop mmod mmod-radio mmod-control.timer mmod-control.service mmod-collector.timer mmod-collector.service
systemctl stop mmod-links.timer mmod-links.service mmod-log-capture.service mmod-log-limit.timer mmod-log-limit.service mmod-subscribers.timer mmod-subscribers.service mmod-directories.timer mmod-directories.service 2>/dev/null || true
if ! tar -czf "$backup/settings.tar.gz" -C / etc/mmod var/lib/mmod/state; then
  systemctl start mmod mmod-radio mmod-control.timer mmod-collector.timer mmod-subscribers.timer mmod-directories.timer
  [[ $had_capture == 0 ]] || systemctl start mmod-log-capture.service
  [[ $had_limit == 0 ]] || systemctl start mmod-log-limit.timer
  [[ $had_links == 0 ]] || systemctl start mmod-links.timer
  exit 1
fi
echo "Backup: $backup"
changing=1
systemctl stop mmod-log-capture.service 2>/dev/null || true
systemctl stop mmod-log-limit.timer mmod-log-limit.service 2>/dev/null || true
systemctl stop mmod mmod-radio mmod-collector.timer mmod-control.timer mmod-collector.service mmod-control.service
source="$stage/mmod"
if ! cmp -s "$source/requirements.lock" /opt/mmod/requirements.lock; then
  /opt/mmod/venv/bin/python -m pip install --disable-pip-version-check --no-cache-dir -r "$source/requirements.lock"
fi
for name in platform_detect.py discover_allstar.py idle_links.py app.py allstar.py allstar-directory.py accounts.py v2_api.py v2_radio.py brandmeister.py discover_controls.py link_status.py radio.py log_capture.py log_limit.py collector.py control.py admin.py directories.py subscriber-update.py setup_config.py requirements.txt requirements.lock VERSION README.md BUILDLOG.md ADVANCED-SETUP.md INSTALL-DELL-3040.md LICENSE; do
  install -m 644 "$source/$name" /opt/mmod/
done
install -m 644 "$source"/static/* /opt/mmod/static/
install -m 644 "$source"/systemd/* /opt/mmod/systemd/
install -m 644 "$source"/systemd/* /etc/systemd/system/
if [[ "$platform_kind" == wpsd ]]; then
  touch /etc/mmod/wpsd-monitor-only
  echo 'WPSD: dashboard monitoring only; radio configuration and log management remain with WPSD.'
  printf '{}\n' > /etc/mmod/control-profile.json
else
  python3 /opt/mmod/discover_controls.py
fi
/opt/mmod/venv/bin/python /opt/mmod/discover_allstar.py
systemctl daemon-reload
systemctl enable --now mmod-allstar-directory.timer
systemctl start --no-block mmod-allstar-directory.service
systemctl enable --now mmod-links.timer
systemctl start --no-block mmod-links.service
systemctl enable --now mmod-subscribers.timer mmod-directories.timer mmod-control.timer mmod-collector.timer
systemctl start mmod-collector.service
systemctl start --no-block mmod-subscribers.service
[[ "$platform_kind" == wpsd ]] || systemctl enable --now mmod-log-capture.service
[[ "$platform_kind" == wpsd ]] || systemctl enable --now mmod-log-limit.timer
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
        radio=json.load(urllib.request.urlopen(url.replace('/api/health','/api/radio'),timeout=3))
        if result['ok'] and not radio.get('error') and time.time()-radio['updated']<5:break
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

# Remove only legacy MMOD runtime overrides; original radio INIs are untouched.
for unit in ysfgateway mmdvmhost mmdvm-host; do
  override="/run/systemd/system/$unit.service.d/90-mmod.conf"
  if [ -f "$override" ]; then
    mkdir -p /var/backups/mmod-legacy-overrides
    cp -p "$override" "/var/backups/mmod-legacy-overrides/$unit-$(date +%s).conf"
    rm -f "$override"
    echo "Removed legacy MMOD override for $unit. Restart that radio service when idle to use its original configuration."
  fi
done
systemctl daemon-reload
