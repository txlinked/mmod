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
