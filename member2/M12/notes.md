# Mission 12 - The Secret File

This mission belongs to Person 3; included here as requested in the M07-M14 pack. Group membership and /opt changes are privileged system modifications. The remote run created a harmless user-owned analogue inside member2/runs; it did not modify /opt, groups, or accounts. Use the required procedure only on an approved dedicated machine/VM, never a shared workstation.

| Path | Intended owner:group | Required mode | Intended access |
|---|---|---:|---|
| /opt/securelab | root:securelab | 755 | All may traverse/list top level |
| /opt/securelab/public | root:securelab | 755 | All may list/traverse |
| /opt/securelab/employees | root:securelab | 750 | Owner/group may list/traverse |
| /opt/securelab/secrets | root:securelab | 750 | Owner/group may list/traverse |
| .../secrets/incident.txt | root:securelab | 640 | Owner read/write; group read |

**Extra user-level analogue observed:** The user-owned directories had modes 755 (securelab), 755 (public), 750 (employees), and 750 (secrets); the demo incident file was 640. The current owner traversed the directories and read the harmless demo note. The SHA-256 baseline was 179b53f72fbce04bf8df9cf764cf2b8f957af0299af5e81dcc3cc0aa3f21c662 and initially verified OK. After modification, the digest was d37f91d3d4e97fe3988980d14d501dc572a4f1f12b49be3ed97c6679bad0acc1; verification reported FAILED with exit status 1.

**Required /opt hierarchy and Alice/Bob tests: SKIPPED ROOT REQUIRED.** This run used only account MU and a directory under member2/runs; it did not establish group securelab membership or access by Alice/Bob. Both test accounts were absent, and no privileged changes were made.

Directory x permits traversing/searching entries; r permits listing. Parent traversal is needed even if file read bits allow access. The incident file should be available to the approved group. Least privilege gives only the approved group traversal/read permissions; world-readable exposure could disclose confidential information.

Source: evidence/target/member2/runs/M12.4xhgkT/evidence.txt and aggregate M12 section.
