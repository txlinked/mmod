# Install MMOD

On the Dell running Debian 12 or 13, paste this entire line into the terminal:

```bash
sudo apt-get update && sudo apt-get install -y curl ca-certificates python3 python3-venv iproute2 tar && curl -fsSL https://raw.githubusercontent.com/txlinked/mmod/main/mmodinstall.sh -o mmodinstall.sh && sudo bash mmodinstall.sh
```

Answer the questions. Press **Enter** to accept defaults. The installer detects the Dell’s IP addresses, shows the radio settings it found, defaults to port **8000**, and asks you to choose an admin password.

When it finishes, open the dashboard address shown. Select **Administration** and log in as **admin** using the password you chose.

For changing page information or resetting your password later, see [Advanced setup](ADVANCED-SETUP.md).

Fresh installs: username **admin**, starter password **mmodadmin**. Press Enter to keep it during setup, or choose another password. Change it under Administration after signing in. New passwords require at least **6 characters**. Existing passwords are preserved on updates.


Caller details now include first name and registered city, state, and country from RadioID. The directory downloads in the background after installation and refreshes weekly; names from the existing DMR list remain available until the first download completes. Failed updates retain the last good directory.

The dashboard uses a full-width header, larger activity text, independent timeslot counters that turn red while keyed, and half-second activity polling. Click a callsign to open its QRZ page in a new tab.

## Update later

Copy this line into the MMOD computer’s terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/txlinked/mmod/main/mmodupdate.sh -o mmodupdate.sh && sudo bash mmodupdate.sh
```

Your settings and password are kept. A dashboard backup is made before updating.

## V2.0.0 administration

The installer optionally asks for a BrandMeister v2 API key (hidden entry). Skip it to finish later under **Administration → BrandMeister Setup**. No key is needed to show public BrandMeister links. **Save & Test** checks the detected device's public profile; key authorization is checked when a control is used.

Use the header **Admin Login** button. Signed-in operators can use supported radio controls; administrators can add users and configure BrandMeister. Missing gateways show **Setup required**. Manual destination entry and named directory selection are included. The updater preserves existing login, station, radio, history, and API-key settings.


## AllStarLink node control

Open AllStarLink to view all configured nodes on one page. In Administration → AllStar nodes, add the node number, display name, private/ZeroTier AMI address, port, username and password. Existing passwords stay hidden; leave blank to retain them. Only administrators can add or remove nodes; signed-in operators can link, monitor and unlink. No node credentials are bundled. Updates preserve saved node settings. Keyed rows turn red and move above recently keyed rows, with one-second polling. Last-keyed ordering tracks activity observed since dashboard startup.
