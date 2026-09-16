# MMOD release history

## 2026-09-14

- Standalone Debian 12/13 x86_64 installer with compact dashboard and customizable themes.
- Interactive station names, detected local IPv4 selection, port 8000 default, visible radio file/service defaults, and admin password setup.
- Includes login, password reset, display customization and backup instructions.
- Single-file installer embeds and verifies its source package.
- Ten automated tests passed; fresh installation on a second physical Dell remains untested.

## 2026-09-14 — Footer credit

- Added N3DMC to the shared footer visible on every dashboard view. Rebuilt the GitHub installer and source archive.

## 2026-09-14 — Administration controls

- Added current-password-verified password changes and session invalidation.
- Added authenticated, CSRF-protected Start/Stop/Restart/Reload for configured radio services and confirmed whole-computer reboot. A constrained root worker performs the operations. Unsupported reloads do not restart services.
- Seventeen automated tests passed, including authorization, password replacement, duplicate requests, command restrictions and reboot confirmation. Live UI verified; radio PIDs stayed unchanged during dashboard deployment. No live stop or reboot was performed.

## Starter password and six-character minimum

- Fresh installations use admin / mmodadmin and optionally choose a different password during setup. Existing credentials are preserved.
- Web and CLI password changes require at least six characters.

- Renamed the reboot heading/button to Reboot and clarified the note: System reboot.

## 2026-09-15 — Default port 8000

- Changed fresh-install default port to 8000. Existing installations retain their configured port during guided setup. Installer still detects occupied ports and asks the operator to resolve conflicts.

## 2026-09-15 — Live slots and compact password form

- Separate half-second radio monitor and one-second browser radio refresh. TS1/TS2 track starts, late entry, ends and watchdogs independently. Last heard begins at call start.
- Local name index uses SQLite to limit memory; country uses subscriber country or CTY prefix lookup. No per-call Internet queries.
- Horizontal password-change fields with mobile stacking.
- Two parser tests passed; Waco endpoint and live overview verified. Actual radio/log buffering remains outside dashboard control.

- Matched requested Current / Last Caller Details and Gateway Activity tables. Two timeslot rows retain last caller when idle; activity uses local timestamps and loss where logged. Missing location stays blank.


## 2026-09-15 — Full-width dashboard and caller details

- Published the approved header navigation, larger body text, and compact layout.
- Added RadioID city/state/country and first-name lookup with an on-disk index, background initial download, validated weekly refresh, and fallback to the existing DMR name list.
- Removed separate Country columns; location includes country, using USA for United States.
- Added red keyed counters, half-second polling, duration updates, heartbeat, and stale-feed handling for both timeslots.
- Callsigns link to their QRZ pages in a new tab.
- Preserved installer prompts, port 8000 default, theme customization, admin password changes, service controls, and N3DMC footer.

## 2026-09-15 — New MMDVM-Host MQTT support and Debian Python

- Detect modern MMDVM-Host installations and subscribe to their configured MQTT log topic when file logs are unavailable. Keep legacy file-log support.
- Ignore retained MQTT messages and report disconnected or missing log sources instead of silently showing an empty healthy feed.
- Use the dashboard virtual environment for the radio monitor and include paho-mqtt 2.1.0.
- Prefer Debian system Python over legacy /usr/local Python overrides during installation.
- Verified a real KI4BLU TS1 TG3100 transmission through MQTT without restarting the radio service.

- Correct cross-mode caller identity by correlating DMR2YSF source logs with transport ID, mapped target, slot and timestamp. Do not identify a fallback repeater ID as the caller. Verified N5YAI / John / Justin, Texas, USA on Waco TS2.

- Retain completed last callers independently for each slot across rolling activity and restarts. Display Name and Location in Gateway Activity and keep retained callers available in All activity. Label confirmed cross-mode calls DMR2YSF in both tables.

- Persist relevant MQTT call log events to a bounded local history file and reload them after monitor restarts. Ignore debug chatter to avoid unnecessary writes. Recovered Copperas Cove caller history from the radio console.
