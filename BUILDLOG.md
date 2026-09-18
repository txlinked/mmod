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

2026-09-15: Added searchable destination directories, per-source failure status, last-good cache and randomized weekly refresh. Included updater and timer in standalone installer.

Caller elapsed time uses seconds, minutes, then whole hours. Completed calls disappear from current caller and activity tables after 24 hours; the two slot placeholders remain. Radio logs are retained.

2026-09-16: Match delayed DMR2YSF calls through recorded transmission end; persist up to 2,000 enriched completed calls within 24 hours across rolling logs/restarts. Phone tables stack into labeled rows. 29 tests passed.

2026-09-16: Activity retains only the latest 15 calls, newest first, independently of the two last-caller rows. Removed the 24-hour activity retention rule.

2026-09-16: User requested 20 activity calls; raised retained and displayed limit to 20.
2026-09-16: Current callers have a narrow left Slot column; Mode shows only the mode. DMR2YSF route labels support both RF and network calls when explicitly configured.

2026-09-16: Gateway and All Activity now separate Mode and TS columns. Installer includes display frequency/color-code overrides, mode-route labeling, mobile layout, weekly directories and latest-20 history.

2026-09-16: Added standalone mmodupdate.sh and one-line GitHub update instructions for existing computers, preserving local settings and credentials, backing up dashboard/environment and checking HTTP health with rollback on failure.

2026-09-16: Named this release V1.0.0. Dashboard footer, health API, installer, updater and VERSION agree.

## Local log capture — 2026-09-16

Removed MMOD MQTT subscription and paho-mqtt dependency. Added local MMDVM file, GNU screen console, and journal capture with bounded rotation. Installer and updater install the capture service; radio services and broker configuration remain unchanged. Existing station settings and history are preserved.

## Repeater identity lookup — 2026-09-17

Fixed unresolved repeater IDs by adding RadioID's official repeater directory alongside subscribers. Refresh persisted last callers and activity identities when directories become available, even during idle periods. Repeater IDs resolve to the registered callsign and subscriber first name where available; individual transmitting operators are not inferred. Weekly atomic downloads retain previous valid data on failure. Installer and updater include the fix and start directory refreshes. All 36 tests passed, including regression coverage for late directory arrival, saved history, corrupt refreshes, subscriber precedence and unknown IDs.

Follow-up: fixed startup scans of oversized logs and moved subscriber indexing off the live loop. Added 10 MiB text-log maintenance, retaining a bounded tail without changing radio configuration.

RadioID subscriber and repeater directories now refresh nightly between 04:00 and 05:00 local time on all installations. Destination/talkgroup lists retain their weekly schedule.
