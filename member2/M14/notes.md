# Mission 14 - What Happened While I Was Away?

Collected at 2026-11-02 15:27:43 +05:30 as MU. The readable journal exposed user/session events only; it explicitly said messages from other users were not visible and system journal files were unavailable due to insufficient permissions. SSH service status was active (running), enabled, since Oct 28 19:42 IST. The readable SSH unit journal had no entries. This is a log-access limitation, not evidence that SSH had no activity.

Timeline from actual readable journal entries. The journal shows local times without year; the collection date supplies the date context:

| # | Time (IST, 2026-11-02) | Source | Event as observed | What it may mean |
|---:|---|---|---|---|
| 1 | 15:14:38 | xdg-desktop-portal | Failed to stop screen cast session: session not started | Portal reported no active session to stop. |
| 2 | 15:15:29 | xdg-desktop-portal | Unhandled parent window type; failed to associate portal window with parent | Desktop portal could not associate a window. |
| 3 | 15:15:29 | gnome-shell | setup_framebuffers assertion width > 0 failed | Window-system assertion was logged. |
| 4 | 15:15:48 | org.gnome.Nautilus | Failed to start Wayland (MissingProtocol), fell back to X11 | Application used its logged fallback path. |
| 5 | 15:16:18 | rustdesk | GTK widget/window assertions and FlBinaryMessenger-without-engine messages | RustDesk logged UI/runtime assertions. |
| 6 | 15:27:07 | dbus-daemon | Requested activation of Tracker3 Miner Extract, requested by uid 1002 process tracker-miner-fs-3 | A user-session service activation was requested. |
| 7 | 15:27:07 | systemd user manager | Starting, then started Tracker metadata extractor | User-session service startup was logged. |
| 8 | 15:27:43 | sudo / pam_unix | Authentication conversation failed; could not identify password for MU | The noninteractive sudo check could not obtain a password; this is not evidence of a malicious login. |

The timestamps establish ordering within the captured local journal; they do not establish malicious activity. The output also showed an SSH service but no accessible SSH unit events, and last showed prior MU tty2 and reboot records plus an older 127.0.0.1 session. There is no basis here to infer unauthorized access.

Useful investigation events can include authentication failures/successes, account changes, service starts/stops, and security-relevant changes. Timestamps establish sequence and correlation, with care for timezone and clock accuracy. Logs may be missing, rotated, inaccessible, incomplete, or modified by privileged users; absence from available logs does not prove no activity occurred.

Source: aggregate remote run, M14 section.
