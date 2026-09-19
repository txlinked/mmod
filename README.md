# MMDVM Mode Open Dashboard — MMOD V2.0.0

Linux dashboard for MMDVM systems. This distribution includes a portable **Debian 12/13 x86_64 installer for Dell Wyse 3040**, defaulting to port 8000.

Start with **[INSTALL-DELL-3040.md](INSTALL-DELL-3040.md)**. It covers clean Debian setup, installation beside existing radio software, configurable station information, firewall access, initial login, password changes/recovery, themes, backups and rollback.

```bash
sudo apt-get update && sudo apt-get install -y curl ca-certificates python3 python3-venv iproute2 tar && curl -fsSL https://raw.githubusercontent.com/txlinked/mmod/main/mmodinstall.sh -o mmodinstall.sh && sudo bash mmodinstall.sh
```


Answer the prompts: station name, network name, a numbered choice of the Dell’s detected IP addresses, web port (8000), admin password, and an optional BrandMeister API key. The detected radio settings file and service are displayed; press Enter to keep them. Runs entirely on the Dell. Debian and radio software must be installed separately.

## Update an existing MMOD computer

Copy and paste this one line into that computer's terminal or SSH session:

```bash
curl -fsSL https://raw.githubusercontent.com/txlinked/mmod/main/mmodupdate.sh -o mmodupdate.sh && sudo bash mmodupdate.sh
```

Keeps your station name, IP address, port, admin password, caller history and radio settings. Backs up the current dashboard first, updates MMOD, and checks dashboard health. Radio services are not restarted. Refresh your browser afterward. Internet access and sudo are required.

Updates are logged in `/var/log/mmod-update-*.log`; backups are in `/var/backups/mmod-update-*`. A failed update attempts to restore the previous dashboard automatically.

## V2.0.0 radio controls

Use **Admin Login** in the header. The compact Radio Control panel appears after login. Administrators can add administrator/operator accounts under **Administration → User Management**. Existing passwords remain valid after updating; sign in again if your old session expires.

**Linked Talkgroups** is a full-width compact bar directly below Repeater online: public TS1/TS2 links come from BrandMeister subscriptions and confirmed YSF gateway events, never from last-heard activity. Signed-in users can select a destination to fill Radio Control. Controls require the corresponding detected gateway setup.

Under **Administration → BrandMeister Setup**, add a masked **v2 API key**, choose **Save & Test**, or remove the saved key. The repeater ID is detected locally. The test checks profile reachability; actual key permissions are checked by BrandMeister when a control is used. Public linked groups do not require a key. Create your key in your [BrandMeister account](https://news.brandmeister.network/introducing-user-api-keys/). It must have access to your repeater. The optional installer prompt can be skipped and completed here later. Updates preserve the key; no key is bundled in this release.

BrandMeister Link adds a **persistent static subscription**; Unlink removes that selected static TG. Other static groups are preserved. Dynamic groups are displayed but cannot be individually unlinked here because the upstream command clears all dynamic groups on the slot. Simplex controls require separate setup. Auto-disconnect applies to YSF/FCS only. YSF/FCS changes briefly restart their shared gateway; Save as default sets its boot destination. Active/stale radio monitoring blocks routing changes. Use the mode/network directory or enter a destination manually.

Requirements: existing compatible radio software, working local activity logs, Debian 12/13 x86_64, systemd, and outbound HTTPS for directories/BrandMeister. The installer detects supported gateway paths and marks missing controls as Setup required. No MQTT connection is used by MMOD. Radio configuration is changed only when you use supported controls; installation does not retune or restart radio services.

## Included

- Small overview panels with recent radio traffic placed above service details.
- Live Linux system metrics, MMDVM mode configuration and gateway service state.
- Administrator login, filtered radio logs, downloadable configuration backups and SHA-256 manifests.
- Five-second collector with snapshots in RAM, unprivileged FastAPI/Uvicorn web service and systemd startup.
- Per-browser dark/light/system themes, five accents and two density choices.
- Main page title and network label controlled by `/etc/mmod/config.json` through `setup_config.py`.
- Starter password mmodadmin for new installations, PBKDF2 password hashes, server-side sessions, CSRF protection and login throttling.
- MIT license, source, tests, installer and build records.

Calls, modes and frequencies reflect configuration/logs, not a direct modem query. Unknown firmware remains unknown. V2 offers authenticated controls for detected BrandMeister and YSF/FCS gateways. Other modes are listed as Setup required; it does not install missing radio software or implement AllStar control. The collector flags stale data after 30 seconds.

## Development and record


Run `python3 -m unittest discover -s tests` to test. Rebuild the single-file installer with `python3 build_single_file.py mmodinstall.sh`. Run the test suite and shell syntax checks before publishing a release. Installation logs are saved at `/var/log/mmod-install-*.log`.

Administration includes password changes, Start/Stop/Restart/Reload for configured radio services, and whole-Dell reboot with confirmation. Extract `mmod-source.tar.gz` to access the source and tests.

Fresh installs: username **admin**, starter password **mmodadmin**. Press Enter to keep it during setup, or choose another password. Change it under Administration after signing in. New passwords require at least **6 characters**. Existing passwords are preserved on updates.

Live DMR monitoring: TS1 and TS2 update independently about once per second, and Last heard includes calls as they start. Calls must first appear in the MMDVMHost log. Names use the local DMR ID list or transmitted alias. Country uses an optional local subscriber country field or the CTY callsign prefix database downloaded from https://www.country-files.com/cty/cty.dat during installation; it is not current physical location. Missing information is shown as unavailable. If start/end events are lost, an active call expires after 180 seconds.


Caller details now include first name and registered city, state, and country from RadioID. The directory downloads in the background after installation and refreshes nightly between 04:00 and 05:00 in system local time; names from the existing DMR list remain available until the first download completes. Failed updates retain the last good directory.

Numeric repeater IDs use RadioID's separate official repeater directory. Repeater entries show their registered callsign and location, plus the registered callsign’s first name when present in the subscriber directory. This identifies the registration, not necessarily the person transmitting. Subscriber identities take precedence. Nightly refreshes also repair saved last-caller and activity records without requiring a new call. Unknown IDs remain numeric. Updates request a directory refresh automatically.

The dashboard uses a full-width header, larger activity text, independent timeslot counters that turn red while keyed, and half-second activity polling. Click a callsign to open its QRZ page in a new tab.

MMOD reads local radio logs and does not connect to MQTT. It uses the configured MMDVM file log first. If no file exists, mmod-log-capture captures the configured radio service’s GNU screen console or system journal without restarting the radio. Captured output is stored in /var/lib/mmod/console/MMDVM.log, with one rotated backup at approximately 5 MiB per file. Console capture requires the radio to emit activity log messages (DisplayLevel 1 or higher). An existing but stale file log must be corrected or explicitly overridden; MMOD cannot recover events the radio never logged.

For a custom file, set radio_log_file in /etc/mmod/config.json to its absolute path. Check capture with sudo journalctl -u mmod-log-capture and /run/mmod/log-source.json. MMOD leaves Mosquitto and the radio’s own MQTT configuration unchanged. Installation uses Debian system Python, avoiding older /usr/local Python overrides.

Weekly destination directories: DMR networks, YSF/FCS, D-Star, P25 and NXDN are searchable under System & modes. The POCSAG/DAPNET entry reports upstream availability and accepts a local public rubric export at /etc/mmod/dapnet-rubrics.json. It does not expose personal pager addresses.
Lists refresh Sunday between 04:00 and 05:00 in system time via mmod-directories.timer. Failed downloads keep the last successful list. Run sudo systemctl start mmod-directories to refresh now; inspect sudo journalctl -u mmod-directories. Initial downloads run in the background. WPSD/RefCheck attribution is retained in the cache and visible in the directory panel. D-Star host lists supply reflector IDs; no location names are invented. Lists are reference data and do not enable radio modes or change routing.

Radio/MMOD text logs use a 10 MiB threshold checked every 10 seconds by mmod-log-limit.timer. Oversized files are trimmed in place to their newest approximately 5 MiB; old data is discarded, while the saved 20 activity records and last callers are retained. This covers configured MMDVM logs, nearby gateway logs, MMOD console capture and MMOD install/update logs, not unrelated system journals or backup archives. Directory indexing runs in the background so large downloads do not stop live monitoring. Startup reads only a bounded log tail.

Gateway Activity uses country-only labels (USA, UK, and other country names) to save space. Current / Last Caller Details retains the full registered location.

Administration activity is saved locally and accessible using **View admin log**, which opens a popup with the latest 40 entries. The log retains up to 2,000 entries.
