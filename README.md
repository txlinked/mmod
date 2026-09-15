# MMDVM Mode Open Dashboard — MMOD

Linux dashboard for MMDVM systems. This distribution includes a portable **Debian 12/13 x86_64 installer for Dell Wyse 3040**, defaulting to port 8080.

Start with **[INSTALL-DELL-3040.md](INSTALL-DELL-3040.md)**. It covers clean Debian setup, installation beside existing radio software, configurable station information, firewall access, initial login, password changes/recovery, themes, backups and rollback.

```bash
sudo apt-get update && sudo apt-get install -y curl ca-certificates python3 python3-venv iproute2 tar && curl -fsSL https://raw.githubusercontent.com/txlinked/mmod/main/mmodinstall.sh -o mmodinstall.sh && sudo bash mmodinstall.sh
```


Answer the prompts: station name, network name, a numbered choice of the Dell’s detected IP addresses, web port (8080), and admin password. The detected radio settings file and service are displayed; press Enter to keep them. Runs entirely on the Dell. Debian and radio software must be installed separately.

## Included

- Small overview panels with recent radio traffic placed above service details.
- Live Linux system metrics, MMDVM mode configuration and gateway service state.
- Administrator login, filtered radio logs, downloadable configuration backups and SHA-256 manifests.
- Five-second collector with snapshots in RAM, unprivileged FastAPI/Uvicorn web service and systemd startup.
- Per-browser dark/light/system themes, five accents and two density choices.
- Main page title and network label controlled by `/etc/mmod/config.json` through `setup_config.py`.
- Random initial password per installation, PBKDF2 password hashes, server-side sessions, CSRF protection and login throttling.
- MIT license, source, tests, installer and build records.
- Built for Debian 13

Calls, modes and frequencies reflect configuration/logs, not a direct modem query. Unknown firmware remains unknown. This version does not edit radio settings, restart radios, install missing modes, or implement AllStar control. The collector flags stale data after 30 seconds.

## Development and record


Run `python3 -m unittest discover -s tests` to test. Rebuild the single-file installer with `python3 build_single_file.py mmodinstall.sh`. Ten tests and shell syntax checks passed; a fresh installation on a second physical Dell has not been tested. Installation logs are saved at `/var/log/mmod-install-*.log`.
