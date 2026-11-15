# Mission 7 - Alice vs Bob

Goal: Compare Bob reading Alice's file at mode 644 and then 600.

**Extra user-level analogue observed:** The run used account MU (uid/gid 1002). The file was mode 644 (owner MU, group MU, others read) and the current owner read it; after chmod it was mode 600 and the current owner still read it. Both alice and bob accounts were absent. This does not establish whether a second user can read the file.

| State observed in current-user analogue | Mode and owner | Current-owner read |
|---|---|---|
| Before | rw-r--r-- 644, MU:MU | Succeeded |
| After | rw------- 600, MU:MU | Succeeded |

Owner bits apply to the file owner, group bits to members of the file's group, and other bits to everyone else. chmod 600 removes group/other access, so Bob should be denied unless another applicable access rule grants it. Alice as owner controls discretionary mode bits. Not granting Bob unneeded access demonstrates least privilege.

**Required Alice/Bob test: SKIPPED ROOT REQUIRED.** On the remote target, both accounts were absent and sudo required a password. No accounts were created and no Bob access test was attempted. The required before/after evidence needs an instructor-approved target with designated test accounts.

Source: evidence/target/member2/runs/M07.b93CWP/evidence.txt and evidence/target/member2/runs/aggregate.NmpGq9/run_missions.txt.
