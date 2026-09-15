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
