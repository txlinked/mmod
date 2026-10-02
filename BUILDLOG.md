## V2.0.3

Admin dynamic timer enable/disable switch. Default enabled at 15 minutes; existing minute settings preserved. Disabled timers do not queue disconnects; re-enabling starts a fresh interval. AllStar unaffected.

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

Gateway-policy follow-up: repair legacy root-owned policy/lock files on install and update, preserving values and owner-only permissions. An unreadable or corrupt policy now returns unavailable rather than falsely reporting Dynamic.

Linked panel resilience: retain confirmed links when gateway-policy requests fail, display Policy unavailable, and hide policy toggles until the policy is readable.

Installer/updater now configure explicit multi-network dashboard listeners on assigned 44net and private LAN/ZeroTier IPv4 addresses. Existing radio settings are preserved.

AllStar directory refresh: allow slow downloads and automatically retry failed initial/daily refreshes after 60 seconds; retain the last valid directory on failure.

Restore owner-requested fresh-install credentials admin / mmodadmin. Existing credentials remain preserved during updates. Rebuild the embedded installer and source package with this default.

Bootstrap fix: check/install missing system dependencies before Python, archive extraction or updater locking. Verification-only mode remains read-only.

AllStar display: accept callsign identifiers in connection, mode, keying and received-status parsing. Keep numeric command validation and omit unsupported callsign unlink actions.
