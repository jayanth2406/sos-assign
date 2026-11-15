# Completion audit against the instructor handout

The requested non-root scope is complete: 15/15 selected mission items. The full original assignment has excluded root-dependent work and an unavailable separate challenge. This audit preserves each original evidence requirement and records the scoped result.

| Mission | Required evidence from handout | Prepared material | Completion evidence still needed |
|---|---|---|---|
| 1 | Output of `id` and the C program.; A short explanation of authentication vs authorization.; Two attack surfaces of a normal workstation. | `member1/src/`, `member1/notes/`, runner | Identity program and id agree on UID/EUID/GID/EGID 1002. |
| 2 | A short trace with open/write/close identified.; Application → system call → kernel → resource diagram. | `member1/src/`, `member1/notes/`, runner | strace captured open/write/close; syscall diagram provided. |
| 3 | Working script.; Open-file-descriptor count.; Short explanation of how `/proc` helps investigation. | `member1/src/`, `member1/notes/`, runner | Own sleep process inspected: UID1002, 1 thread, 3 FDs, no effective capabilities. |
| 4 | `/proc/<PID>/maps` output.; Labelled address-space diagram.; Short explanation of isolation. | `member1/src/`, `member1/notes/`, runner | Own process address and maps recorded; isolation diagram provided. |
| 5 | Several unsynchronized runs.; Mutex-protected run.; Marked critical section in the source. | `member1/src/`, `member1/notes/`, runner | Three unsynchronized results 1000000/1013183/1782455; mutex runs both 2000000. |
| 6 | Working IPC output.; Message passing vs shared memory comparison.; One proposed secure-IPC control. | `member1/src/`, `member1/notes/`, runner | Pipe and synchronized shared-memory exchanges succeeded; shared-memory source labeled team-authored. |
| 7 | Before/after permission output.; Explanation of owner/group/other.; Allowed and denied access evidence. | `member2/M07/` | SKIPPED under user non-root scope; original runtime procedure unavailable without privileges or separate instructor resources. |
| 8 | Before/after getfacl output.; One paragraph comparing permissions and ACLs. | `member2/M08/` | SKIPPED under user non-root scope; original runtime procedure unavailable without privileges or separate instructor resources. |
| 9 | Selected output from id/capsh/getcap.; Diagram comparing broad privilege with narrow privilege. | `member2/M09/` | id/capsh/getcap inspected; effective capability set empty; sudo requires password. |
| 10 | Compiler output.; Observed program behavior.; Diagram showing intended buffer boundary vs copied data. | `member2/M10/` | Rootless sandbox: short input exit0; long input stack smashing exit134. Checked companion rejects oversized input. |
| 11 | checksec output.; ASLR value.; A short explanation linking each defense to a threat. | `member2/M11/` | checksec+ASLR+readelf captured; protected canary/NX/PIE/FullRELRO; reduced no canary/noPIE/PartialRELRO; ASLR2. |
| 12 | Permission design table.; Access tests for Alice and Bob.; Short least-privilege explanation. | `member2/M12/` | SKIPPED under user non-root scope; original runtime procedure unavailable without privileges or separate instructor resources. |
| 13 | Original hash.; Changed hash.; Verification failure and explanation. | `member2/M13/` | Original and changed hashes recorded; verification mismatch observed. |
| 14 | A 5–10 event timeline.; Identification of at least one limitation of logs. | `member2/M14/` | Eight-event journal timeline and visibility limitations documented. |
| 15 | Application resource table.; Proposed sandbox policy.; At least three resources you would restrict. | `member3/Missions-15-22.md` | Resource table/policy plus RLIMIT_NOFILE16; EMFILE after13 additional descriptors. |
| 16 | Container output.; Host vs container architecture diagram.; VM vs container comparison. | `member3/Missions-15-22.md` | SKIPPED under user non-root scope; original runtime procedure unavailable without privileges or separate instructor resources. |
| 17 | AppArmor status.; One profile explanation.; If a denial demo is provided, evidence of allowed vs denied behavior. | `member3/Missions-15-22.md` | SKIPPED under user non-root scope; original runtime procedure unavailable without privileges or separate instructor resources. |
| 18 | Completed comparison table: mechanism / decision basis / example / limitation.; One realistic scenario for each mechanism. | `member3/Missions-15-22.md` | DAC/MAC/RBAC/ACL/capability comparison table and scenarios complete. |
| 19 | Before/after hardening checklist.; At least three changes with justification.; Verification evidence. | `member3/Missions-15-22.md` | SKIPPED under user non-root scope; original runtime procedure unavailable without privileges or separate instructor resources. |
| 20 | Successful local SSH evidence.; Authentication vs authorization explanation. | `member3/Missions-15-22.md` | Authenticated SSH localhost succeeded as MU UID1002; temporary key and added authorization removed. |
| 21 | Application → guest kernel → virtual hardware → hypervisor → host architecture diagram.; One paragraph on the VM's additional attack surface. | `member3/Missions-15-22.md` | Conceptual VM trust diagram and attack surface complete; target virtualization detection returned none. |
| 22 | At least five real observations; classification; applied controls; repeated checks; evidence; nine-section security report | `member3/Missions-15-22.md` | SKIPPED under user non-root scope; original runtime procedure unavailable without privileges or separate instructor resources. |

Additional gates: compiler flags and warnings must be recorded; screenshots must include commands and output; each experiment needs question, prediction, experiment, observation, concept, defense, verification, and reflection; VM/snapshot readiness and the separate final assessment are outside the completed non-root scope.

Questions 1–18 are addressed in member1 notes, 19–43 in member2 notes, 44–80 in member3 notes, and 81–88 in the consolidated report. Runtime observations are linked to actual captures. Personal reflection drafts are labeled and do not claim student experiences.
