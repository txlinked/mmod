# MMDVM Mode Open Dashboard — MMOD

Linux dashboard for MMDVM systems. This distribution includes a portable **Debian 12/13 x86_64 installer for Dell Wyse 3040**, defaulting to port 8000.

Start with **[INSTALL-DELL-3040.md](INSTALL-DELL-3040.md)**. It covers clean Debian setup, installation beside existing radio software, configurable station information, firewall access, initial login, password changes/recovery, themes, backups and rollback.

```bash
sudo apt-get update && sudo apt-get install -y curl ca-certificates python3 python3-venv iproute2 tar && curl -fsSL https://raw.githubusercontent.com/txlinked/mmod/main/mmodinstall.sh -o mmodinstall.sh && sudo bash mmodinstall.sh
```


Answer the prompts: station name, network name, a numbered choice of the Dell’s detected IP addresses, web port (8000), and admin password. The detected radio settings file and service are displayed; press Enter to keep them. Runs entirely on the Dell. Debian and radio software must be installed separately.

## Update an existing MMOD computer

Copy and paste this one line into that computer's terminal or SSH session:

```bash
curl -fsSL https://raw.githubusercontent.com/txlinked/mmod/main/mmodupdate.sh -o mmodupdate.sh && sudo bash mmodupdate.sh
```

Keeps your station name, IP address, port, admin password, caller history and radio settings. Backs up the current dashboard first, updates MMOD, and checks dashboard health. Radio services are not restarted. Refresh your browser afterward. Internet access and sudo are required.

Updates are logged in `/var/log/mmod-update-*.log`; backups are in `/var/backups/mmod-update-*`. A failed update attempts to restore the previous dashboard automatically.

## Included

- Small overview panels with recent radio traffic placed above service details.
- Live Linux system metrics, MMDVM mode configuration and gateway service state.
- Administrator login, filtered radio logs, downloadable configuration backups and SHA-256 manifests.
- Five-second collector with snapshots in RAM, unprivileged FastAPI/Uvicorn web service and systemd startup.
- Per-browser dark/light/system themes, five accents and two density choices.
- Main page title and network label controlled by `/etc/mmod/config.json` through `setup_config.py`.
- Starter password mmodadmin for new installations, PBKDF2 password hashes, server-side sessions, CSRF protection and login throttling.
- MIT license, source, tests, installer and build records.

Calls, modes and frequencies reflect configuration/logs, not a direct modem query. Unknown firmware remains unknown. This version does not edit radio settings, install missing modes, or implement AllStar control. The collector flags stale data after 30 seconds.

## Development and record


Run `python3 -m unittest discover -s tests` to test. Rebuild the single-file installer with `python3 build_single_file.py mmodinstall.sh`. Seventeen tests and shell syntax checks passed; a fresh installation on a second physical Dell has not been tested. Installation logs are saved at `/var/log/mmod-install-*.log`.

Administration includes password changes, Start/Stop/Restart/Reload for configured radio services, and whole-Dell reboot with confirmation. Extract `mmod-source.tar.gz` to access the source and tests.

Fresh installs: username **admin**, starter password **mmodadmin**. Press Enter to keep it during setup, or choose another password. Change it under Administration after signing in. New passwords require at least **6 characters**. Existing passwords are preserved on updates.

Live DMR monitoring: TS1 and TS2 update independently about once per second, and Last heard includes calls as they start. Calls must first appear in the MMDVMHost log. Names use the local DMR ID list or transmitted alias. Country uses an optional local subscriber country field or the CTY callsign prefix database downloaded from https://www.country-files.com/cty/cty.dat during installation; it is not current physical location. Missing information is shown as unavailable. If start/end events are lost, an active call expires after 180 seconds.


Caller details now include first name and registered city, state, and country from RadioID. The directory downloads in the background after installation and refreshes weekly; names from the existing DMR list remain available until the first download completes. Failed updates retain the last good directory.

The dashboard uses a full-width header, larger activity text, independent timeslot counters that turn red while keyed, and half-second activity polling. Click a callsign to open its QRZ page in a new tab.

Modern MMDVM-Host installations that publish logs through MQTT are supported automatically when file logs are absent. MMOD subscribes to the configured broker and host/log topic without changing radio settings. Installation uses Debian system Python, avoiding older /usr/local Python overrides.

Weekly destination directories: DMR networks, YSF/FCS, D-Star, P25 and NXDN are searchable under System & modes. The POCSAG/DAPNET entry reports upstream availability and accepts a local public rubric export at /etc/mmod/dapnet-rubrics.json. It does not expose personal pager addresses.
Lists refresh Sunday between 04:00 and 05:00 in system time via mmod-directories.timer. Failed downloads keep the last successful list. Run sudo systemctl start mmod-directories to refresh now; inspect sudo journalctl -u mmod-directories. Initial downloads run in the background. WPSD/RefCheck attribution is retained in the cache and visible in the directory panel. D-Star host lists supply reflector IDs; no location names are invented. Lists are reference data and do not enable radio modes or change routing.
