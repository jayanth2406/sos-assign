# Non-root scope: 15/15 selected items complete (100%)

Scope follows the user instruction to ignore tasks requiring root. Runtime items use evidence from RustDesk ID1; conceptual items are labeled. Original assignment completion beyond this scope is not claimed.

| Mission | Verified result |
|---|---|
| 1 | Identity program and id agree on UID/EUID/GID/EGID 1002. |
| 2 | strace captured open/write/close; syscall diagram provided. |
| 3 | Own sleep process inspected: UID1002, 1 thread, 3 FDs, no effective capabilities. |
| 4 | Own process address and maps recorded; isolation diagram provided. |
| 5 | Three unsynchronized results 1000000/1013183/1782455; mutex runs both 2000000. |
| 6 | Pipe and synchronized shared-memory exchanges succeeded; shared-memory source labeled team-authored. |
| 9 | id/capsh/getcap inspected; effective capability set empty; sudo requires password. |
| 10 | Rootless sandbox: short input exit0; long input stack smashing exit134. Checked companion rejects oversized input. |
| 11 | checksec+ASLR+readelf captured; protected canary/NX/PIE/FullRELRO; reduced no canary/noPIE/PartialRELRO; ASLR2. |
| 13 | Original and changed hashes recorded; verification mismatch observed. |
| 14 | Eight-event journal timeline and visibility limitations documented. |
| 15 | Resource table/policy plus RLIMIT_NOFILE16; EMFILE after13 additional descriptors. |
| 18 | DAC/MAC/RBAC/ACL/capability comparison table and scenarios complete. |
| 20 | Authenticated SSH localhost succeeded as MU UID1002; temporary key and added authorization removed. |
| 21 | Conceptual VM trust diagram and attack surface complete; target virtualization detection returned none. |

Excluded original missions: 7,8,12,16,17,19 require privileged procedures; 22 lacks its separate challenge and authorized remediation scope. User-owned analogues are extras, not replacements for excluded cross-account proof.

M10 uses a rootless sandbox rather than a VM. M21 is conceptual. The first full runner recorded a failed parent/child wait, and its pipeline masked the aggregate exit status; both source bugs were corrected. The targeted M1–6 rerun exited 0, and its new evidence supersedes the failed M4 wait. Supplementary results are in `evidence/target/evidence/`.
