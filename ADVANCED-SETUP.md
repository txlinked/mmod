# Install MMOD on another Dell Wyse 3040

This package installs the MMOD dashboard on **Debian 12 or 13, x86_64**, using systemd and Python. Default web port: **8000**. It includes the smaller overview layout, radio activity above the service panels, and personal theme controls.


## 1. Prepare the Dell

Install Debian 12 or 13 amd64 with SSH server and standard system utilities. Connect it to your network and log in with a sudo-capable Linux account. If logged in as root, omit `sudo` in the commands below.

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-venv ca-certificates iproute2 tar
ip -br -4 addr
```


Internet access is needed to download Debian/Python dependencies. Allow about 300 MB of free space for the application, environment and small backups. Existing large logs are read in a bounded window.

## 2. Copy and extract the package

Download `MMOD-Dell3040-install.tar.gz` from this task, then copy it to the other Dell with your file-transfer client or `scp`:

```bash
scp MMOD-Dell3040-install.tar.gz youruser@DELL_IP:~/
```

For a nonstandard SSH port, use `scp -P PORT ...`. Use the new Dell's Linux account and SSH port; dashboard login credentials are separate.

On the Dell:

```bash
mkdir -p ~/mmod-install
tar -xzf ~/MMOD-Dell3040-install.tar.gz -C ~/mmod-install
cd ~/mmod-install/mmod
bash install.sh --help
```

Run from the extracted folder, not from `/opt/mmod`. Keep the original archive for recovery.

## 3. Install on a clean Dell

Replace the example address with the new Dell's actual address, and choose your station title:

```bash
sudo bash install.sh \
  --bind 192.168.1.50 \
  --port 8000 \
  --site "My DMR Repeater" \
  --network "My Radio Club"
```

It is fine if `/etc/mmdvm/MMDVM.ini` does not exist yet. MMOD does not create or program a radio configuration.

## 4. Install beside an existing MMDVM setup

First find the actual configuration path and unit name:

```bash
systemctl cat mmdvmhost.service
```

Look at its `ExecStart` command for the INI path. If your unit has another name, substitute that name. Then install, for example:

```bash
sudo bash install.sh \
  --bind 192.168.1.50 \
  --site "North Site DMR" \
  --network "My Radio Club" \
  --ini /home/repeater/MMDVMHost/MMDVM.ini \
  --host-service mmdvmhost.service
```

The installer preserves existing MMOD settings unless you supply an option changing them. Existing admin credentials are preserved on reruns. It snapshots configured files before changes and checks that radio files remain unchanged. If another process owns the chosen port, installation stops.

## 5. Allow browser access when a firewall is active

For active UFW, add `--firewall-interface` using the interface name from `ip -br -4 addr`, for example:

```bash
sudo bash install.sh \
  --bind 192.168.1.50 \
  --site "North Site DMR" \
  --firewall-interface eno1
```


The browser address is `http://DELL_IP:8000/`. Users must be able to reach the selected LAN/ZeroTier address. This release uses HTTP; use it on your trusted LAN or ZeroTier network, not an Internet port-forward. TLS can be added separately.

## 6. Log in

The overview and theme settings do not require login. For logs and configuration backups:

1. On the Dell, read the generated initial login:

   ```bash
   sudo cat /etc/mmod/initial-admin.txt
   ```

2. Open the dashboard and select **Administration**.
3. Username: **admin**. Enter the randomly generated password from the file.


## 7. Change or recover the admin password

Log in to the Dell through SSH and run:

```bash
sudo python3 /opt/mmod/admin.py
```

Type the new password twice. Use at least **14 characters**. Input is hidden. The command changes the MMOD `admin` password, invalidates existing sessions, and removes the obsolete initial-password note. No service restart is required. Sign in again through Administration.

The same command resets a forgotten MMOD password; it does not require the old one, but does require Linux sudo/root access. It does not change the Dell's Linux/SSH password. There is no password-change form in the web UI in this release.

## 8. Change the main-page information

### Page title and network name

```bash
sudo python3 /opt/mmod/setup_config.py \
  --site "Hilltop DMR Repeater" \
  --network "County Radio Club" \
  --description "Hilltop radio dashboard"
sudo systemctl start mmod-collector.service
sudo systemctl restart mmod.service
```

Reload the browser. The site title updates the overview heading, header and browser title. The network name updates the header. The compact overview intentionally hides the descriptive subtitle to prioritize radio traffic.

These values are saved in `/etc/mmod/config.json`. You can also edit that JSON directly with `sudo nano /etc/mmod/config.json`; validate it with `sudo python3 -m json.tool /etc/mmod/config.json` before applying. Keep valid JSON quotes and commas.

### Callsign, location, frequency and DMR information

MMOD reads these from the configured **MMDVM INI**:

| Dashboard information | MMDVM INI field |
| --- | --- |
| Callsign and sidebar identity | `[General] Callsign` |
| DMR ID | `[General] Id` |
| Location | `[Info] Location` |
| Transmit and receive frequencies | `[Info] TXFrequency`, `RXFrequency` in Hz |
| Color code | `[DMR] ColorCode` |
| Duplex status | `[General] Duplex` |
| Mode enabled flags | Each mode's `Enable` field |

Changing these INI fields can change radio operation when MMDVMHost loads them. Use your normal radio configuration process; do not change real frequencies merely to change a display label. MMOD reads the file, not an authoritative runtime query of the modem, so the displayed configuration may precede changes actually applied to MMDVMHost.

To point MMOD to a different INI without editing that INI:

```bash
sudo python3 /opt/mmod/setup_config.py --ini /your/actual/MMDVM.ini
sudo systemctl start mmod-collector.service
```

For nonstandard service names, use `--host-service my-mmdvm.service` and edit the `services` array in the JSON for other gateways. The `backup_files` array should list the actual gateway INIs and service files you want archived. Missing files are skipped. Keep absolute paths; do not add large radio logs or private SSH keys.

### Colors and spacing

Click **Theme** at the top right. Choose dark, light or system mode, one of five accents, and comfortable or compact density. Preferences are stored separately in each browser. The small overview layout remains small in both density modes.

### Change the listening address or port

```bash
sudo python3 /opt/mmod/setup_config.py --bind NEW_LOCAL_IP --port 8000
sudo systemctl restart mmod.service
```

Use an actual local IPv4 address instead of `NEW_LOCAL_IP`. Adjust firewall rules for the new address/port and remove the obsolete rule if it is no longer needed. `setup_config.py` edits settings only; firewall changes happen only through the installer's explicit firewall option or your manual firewall administration.

## 9. Verify and troubleshoot

```bash
systemctl status mmod mmod-collector.timer --no-pager
journalctl -u mmod -u mmod-collector -n 80 --no-pager
ss -ltn | grep ':8000'
```

Visit `http://DELL_IP:8000/api/health`. A healthy collector returns `{"ok":true,"version":"0.1.0"}`. The installer checks this locally; also test from your browser to verify network/firewall access. If status is stale, inspect the collector journal and INI paths. If login fails, use the password-reset command above.


## 10. Backups and removal

Daily/on-demand radio configuration archives are kept at `/var/lib/mmod/backups` (latest 14). Download them through Administration. These contain configuration secrets. They are not full drive backups and do not include the dashboard's password/session database.

For an independent MMOD backup to your mounted NAS or other storage, stop **only MMOD's web service** briefly to capture a consistent session database, then restart it even if the backup command fails:

```bash
sudo bash -c '
  set -e
  destination=/YOUR/MOUNTED/NAS/mmod-backup.tar.gz
  test -d "$(dirname "$destination")"
  systemctl stop mmod.service
  trap "systemctl start mmod.service" EXIT
  umask 077
  tar -C / --exclude=opt/mmod/venv --exclude=opt/mmod/__pycache__ \
      -czf "$destination" opt/mmod etc/mmod var/lib/mmod
'
```

Replace the destination with an existing, verified NAS mount. Confirm it is mounted before running; do not write a supposed NAS backup to the local disk by mistake. Keep the downloaded installer archive independently too. The NAS archive contains credentials and must remain private. Do not copy ZeroTier identities between live machines.

To stop/remove MMOD from startup:

```bash
sudo systemctl disable --now mmod.service mmod-collector.timer
```

Radio services continue running. Source and backups remain available. Remove its specific firewall rule separately if needed.

## Validation limits


## Administration controls

Sign in and use **Change admin password**. Enter your current password and your new password twice (at least 6 characters). All sessions sign out after the change. The SSH password is separate.

**Radio service controls** apply to installed services listed in the panel. Start restores stopped services; Stop and Restart interrupt radio traffic. Reload only works for services that support it and reports unsupported services without restarting them. **Reboot Dell** restarts the entire computer after you type REBOOT.

Fresh installs: username **admin**, starter password **mmodadmin**. Press Enter to keep it during setup, or choose another password. Change it under Administration after signing in. New passwords require at least **6 characters**. Existing passwords are preserved on updates.

Live DMR monitoring: TS1 and TS2 update independently about once per second, and Last heard includes calls as they start. Calls must first appear in the MMDVMHost log. Names use the local DMR ID list or transmitted alias. Country uses an optional local subscriber country field or the CTY callsign prefix database downloaded from https://www.country-files.com/cty/cty.dat during installation; it is not current physical location. Missing information is shown as unavailable. If start/end events are lost, an active call expires after 180 seconds.


### DMR2YSF caller identity
When a bridge substitutes its default DMR ID, MMOD can recover the YSF callsign from its local log. Add `crossmode_sources` to `/etc/mmod/config.json`, with entries containing `log_directory`, `slot`, and `target_offset` matching your DMRGateway rewrite. Example for TS2 with a 7000000 rewrite offset: `{"log_directory":"/home/repeater/DMR2YSF","slot":2,"target_offset":7000000}`. Configure only bridges actually present. The lookup requires a matching transport ID, mapped talkgroup and start timestamp; it never substitutes the repeater owner's identity for an unknown caller.

Weekly destination directories: DMR networks, YSF/FCS, D-Star, P25 and NXDN are searchable under System & modes. The POCSAG/DAPNET entry reports upstream availability and accepts a local public rubric export at /etc/mmod/dapnet-rubrics.json. It does not expose personal pager addresses.
Lists refresh Sunday between 04:00 and 05:00 in system time via mmod-directories.timer. Failed downloads keep the last successful list. Run sudo systemctl start mmod-directories to refresh now; inspect sudo journalctl -u mmod-directories. Initial downloads run in the background. WPSD/RefCheck attribution is retained in the cache and visible in the directory panel. D-Star host lists supply reflector IDs; no location names are invented. Lists are reference data and do not enable radio modes or change routing.
