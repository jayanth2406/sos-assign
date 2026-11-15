# Member 2 status matrix: Missions 7-14

Based on the captured remote aggregate and supplemental evidence in evidence/target/evidence/. No additional execution was performed for this status update.

| Mission | Status | Verified observation / limitation |
|---|---|---|
| M07 | SKIPPED ROOT REQUIRED | Required Alice/Bob access test was not performed: both accounts were absent and sudo required a password. Extra current-user mode analogue verified: mode 644 then 600; owner MU read in both states. |
| M08 | SKIPPED ROOT REQUIRED | Required Alice/Bob ACL read test was not performed because accounts were absent. Extra user-owned ACL metadata verified: user:nobody:r-- entry and r-- mask; no identity switch or cross-account read. |
| M09 | VERIFIED (read-only inspection) | id/capsh/getcap collected. Current shell had no effective capabilities; getcap showed cap_net_raw=ep on /usr/bin/mtr-packet and /usr/bin/ping. sudo -l required a password. |
| M10 | VERIFIED (rootless sandbox) | In verified bubblewrap isolation, short input copied 3 bytes and exited 0; long input produced stack-smashing detection and exited 134. No VM claim. Checked companion accepted short input and rejected long input. |
| M11 | VERIFIED | checksec 2.4.0-1, ASLR value 2, and readelf captured. Protected: Full RELRO/canary/NX/PIE. Reduced build: Partial RELRO/no canary/NX/no PIE. Neither binary was executed. |
| M12 | SKIPPED ROOT REQUIRED | Required /opt hierarchy and Alice/Bob tests were not performed; no privileged changes were made. Extra user-owned mode/traversal/read/hash analogue verified. |
| M13 | VERIFIED | SHA-256 check was OK before modification and FAILED after; both digests were captured. |
| M14 | VERIFIED (limited log view) | Eight entries were transcribed from the accessible journal. Journal access was restricted; SSH service was active but its unit journal showed no entries. |

“SKIPPED ROOT REQUIRED” means the source experiment requires privileged setup or account switching unavailable in the captured session. Current-user analogues are supplemental evidence only and do not satisfy those cross-account/system-path requirements. M10 ran only in the verified rootless bubblewrap sandbox; it was not run in a VM.
