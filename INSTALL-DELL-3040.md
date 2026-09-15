# MMOD — simple Dell 3040 installation

Use a Dell 3040 running **Debian 12 or 13, 64-bit**, connected to the network. This installs the dashboard, not the radio software.

Copy `mmodinstall.sh` to the Dell and run:

```bash
sudo bash mmodinstall.sh
```

**The installer asks for the information. Press Enter to accept a default.**

1. Repeater/dashboard name.
2. Club or network name.
3. Network address — choose a number from the Dell's address list.
4. Web port — normally **8080**.
5. The detected radio settings file and service are shown. Press Enter to keep them; choose Yes only to change them.
6. If UFW is active, allow dashboard access on the selected interface?
7. Start installation?
8. Choose an **admin password**, entered twice with hidden input. Use at least 14 characters.

It finishes by showing your dashboard address, such as `http://192.168.1.50:8080`.

If Python is missing, run this first:

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-venv ca-certificates iproute2 tar
```


## Log in

Open the displayed address and select **Administration**. Username: **admin**. Use the password you chose during installation.

The overview and theme settings do not need a login. If you skipped choosing a password on a fresh installation, read the generated one with `sudo cat /etc/mmod/initial-admin.txt`.

## Change or reset your password

Through SSH on the Dell:

```bash
sudo python3 /opt/mmod/admin.py
```

Enter the new password twice. This works even if you forgot the old MMOD password. It signs out existing dashboard sessions and removes the obsolete initial-password note. Your Linux/SSH password stays unchanged. No restart is needed.

## Change the main-page name later

Replace the quoted names with yours:

```bash
sudo python3 /opt/mmod/setup_config.py --site "My Repeater" --network "My Club"
sudo systemctl start mmod-collector.service
```

The page refreshes automatically. Callsign, location, frequencies, DMR ID and color code come from your MMDVM INI; use your normal radio configuration process to change those.

Click **Theme** for colors and spacing. Each browser saves its own choices.

See `ADVANCED-SETUP.md` for custom paths, firewall details, NAS backups and troubleshooting. Install logs: `/var/log/mmod-install-*.log`. Build history: `BUILDLOG.md`.

The prompt flow and configuration handling have automated tests. A fresh install on your second Dell has not yet been tested.
