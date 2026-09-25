# MMOD release notes

V2.0.0 includes radio monitoring, authenticated administration, AllStar node controls and directory lookups. The AllStar Received column displays time since a locally observed transmission.


V2.0.1: dashboard-only platform detection, local AllStar discovery using existing AMI access, RF inactivity timeout packaging, AllStar SawStat timers, compressed assets and page persistence. ARM/WPSD paths require hardware validation.

## V2.0.2
Restored native YSF/FCS link/unlink using existing local MQTT or UDP interfaces. Commands are not retained; gateway host replies confirm the destination. Monitoring remains independent of MQTT. No radio configuration overrides, INI writes, or gateway restarts. Fixed idle caller rows incorrectly blocking control commands.

### V2.0.2 control permission correction
Allow dashboard requests when gateway INIs are private to the root worker; retain worker-side configuration validation. Idle last-caller rows no longer prevent inactivity processing. Correct native-control confirmation wording.

### V2.0.2 explicit gateway static policy
Removed implicit startup-room timeout exemption. Added persistent authenticated Static/Dynamic controls on linked gateway destinations; switching to Dynamic starts a fresh timer. Worker checks policy again before an automatic unlink.

## V2.0.2 follow-up fixes

DMR2YSF native link and unlink guard only the selected timeslot; automatic expiry uses the same guard. Linked destinations wrap without the Static/Dynamic badge squeezing text. Explicit gateway Static/Dynamic choices persist, while dynamic defaults expire using the configured RF inactivity timer. Native gateway MQTT control uses the existing local broker and configuration, unique clean-session clients and non-retained commands. Fresh installs generate a unique administrator password; updates preserve credentials.
