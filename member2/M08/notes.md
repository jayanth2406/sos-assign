# Mission 8 - The Permission Maze

**Extra user-level ACL metadata analogue observed:** getfacl and setfacl were available. The owner-only file began at mode 600 with ACL owner rw-, group ---, other ---. The script added user:nobody:r--; the ACL mask became r-- and ls -l showed mode 640. This demonstrates a named-user ACL entry and mask behavior on a self-created file. No nobody/Bob read attempt was made, so it does not prove another identity's access.

**Required Alice/Bob ACL test: SKIPPED ROOT REQUIRED.** The remote target had no Alice or Bob accounts, and no cross-account read was attempted. Do not treat the metadata analogue as completion of the required permission test.

Adding the ACL creates a named-user entry and may update the mask. ACLs express per-user permissions beyond owner/group/other. Least privilege is shown by granting Bob read without write. In the actual ACL output, the mask limited the named entry to read; a named user's effective access is the intersection of its entry and the mask.

| Evidence | Observation |
|---|---|
| Initial ACL | user::rw-, group::---, other::---; mode 600 |
| Updated ACL | user:nobody:r--, mask::r--; mode 640 |
| Successful read as named user | Not tested |

Source: evidence/target/member2/runs/M08.4L02Df/evidence.txt and evidence/target/member2/runs/aggregate.NmpGq9/run_missions.txt.
