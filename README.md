# CS5101 SECURELAB — non-root execution completed

The requested **non-root scope is complete: 15/15 selected mission items (100%)**. Three parallel `gpt-6-luna` agents prepared and reviewed the work. Experiments ran on ID1 (`62 420 769`) through authenticated RustDesk MCP, on Ubuntu 22.04.1 as account MU, UID 1002. No assignment mission ran in WSL and no privileged system change was performed.

Start with [the final report](final/REPORT.md), [the requirement audit](final/COMPLETION_AUDIT.md), and [the progress checklist](final/NONROOT_STATUS.md). The full original 22-mission assignment includes excluded tasks; this completion claim applies to the user-requested non-root scope.

Selected missions: **1–6, 9–11, 13–15, 18, 20–21**. Missions 7, 8, 12, 16, 17 and 19 require privileged account/system/daemon/policy access for their original runtime procedures and are skipped. Mission 22 is excluded because its separate instructor challenge/rules are missing and its original remediation requires unavailable scope. Current-user mode/ACL/directory analogues are supplied as extras and do not impersonate Alice/Bob.

Actual command transcripts are under [evidence/target](evidence/target). [The desktop screenshot](evidence/screenshots/nonroot_live_desktop.png) shows authentic recorded command/output transcripts. Conceptual answers and diagrams remain organized in `member1`, `member2`, and `member3`.

Mission 10 ran fixed benign inputs in a rootless Bubblewrap sandbox with an isolated PID/network view, a read-only filesystem and temporary `/tmp`: short input exited 0; oversized input triggered stack smashing and exited 134. This is a documented user-level sandbox adaptation, not a VM claim. Mission 21 supplies the required conceptual VM diagram; target detection returned `none`, which does not prove bare metal. Localhost SSH succeeded using a temporary key; it and its authorization entry were removed afterward.

The working remote folder is `/home/MU/Downloads/sos/securelab-20261102-152707`. The basic user-level collector can be rerun there with `bash run_all.sh`; supplemental memory, checksec and SSH evidence is preserved separately. Existing system services, firewall, policies and accounts were left as found.

Credentials remain only in the ignored `rust-keys.txt`; they are excluded from archives and Git. Local shell/Python syntax checks and archive checks are recorded in `evidence/local_checks.txt`.
