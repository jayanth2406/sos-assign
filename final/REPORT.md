# SECURELAB — Secure Operating Systems Project Report

**Course:** CS5101 — Secure Operating Systems  
**Report status:** **Non-root scope complete for 15 of 15 selected missions**; the original 22-mission assignment remains partial  
**Target:** Ubuntu 22.04.1 LTS remote lab workstation, host `inhydmupc0899-l`  
**Report date:** 2026-11-02

## Executive summary

This report records actual user-level results for Missions 1–6, 9–11, 13–15, 18, 20, and 21. Thirteen of these missions have runtime or tool output; M18 is conceptual by design and M21 pairs a conceptual VM stack with a `systemd-detect-virt` result of `none`. That result does not independently establish bare-metal hardware. M10’s unsafe sample was run only inside a rootless bubblewrap sandbox, not a VM. The completed work shows credential values, system-call mediation, process maps, unsynchronized counter loss, integrity-check failure after a test-file change, and other bounded experiments. It does not claim a vulnerability or remediation on the host.

The remaining work is outside the user-authorized non-root scope: Missions 7, 8, 12, 16, 17, and 19 need privileged setup/actions, and Mission 22 needs a separate instructor challenge image and rules document. No root-required changes were made. The user-level scope is complete; the original 22-mission project is not.

## System profile

The remote target’s identity and software profile are established by [the live baseline capture](../evidence/remote_baseline.txt) and the later read-only capability collection. The supplied handout recommends Ubuntu Desktop 26.04 in a VM; the observed machine runs Ubuntu 22.04.1, and `systemd-detect-virt` returned `none`. This does not independently establish whether the machine is bare metal.

| Profile item | Status |
|---|---|
| Hostname | `inhydmupc0899-l` |
| OS release | Ubuntu 22.04.1 LTS (Jammy Jellyfish), `VERSION_ID=22.04` |
| Kernel and architecture | Linux `5.15.0-43-generic`, x86_64 |
| Target type | `systemd-detect-virt` returned `none`; no guest VM/hypervisor observed |
| CPU | Not collected |
| RAM and swap | 15 GiB RAM; 2 GiB swap |
| Root filesystem | 486 GiB total, 31 GiB used, 430 GiB available at collection |
| Observed account | `MU`, UID 1002, primary GID 1002 (`MU`); `id` showed group `MU` |
| Working directory and available tools | `/home/MU`; `/usr/bin/gcc`, `/usr/bin/python3` |
| Services and sockets | 43 running services reported; listeners included SSH on `0.0.0.0:22` and `[::]:22`, plus local/other UDP and TCP listeners; see baseline log |
| Firewall, AppArmor, container runtime | UFW status required root; AppArmor module enabled (`Y`) but profile details were not readable; Docker CLI present (20.10.12), no container was run |
| Instructor challenge image and rules | Not supplied |
| Remote access | RustDesk session returned live baseline; Mission 20 later authenticated to localhost over SSH with a temporary key, then removed it |

The baseline and later read-only collection include `id`, `/etc/os-release`, `uname -a`, `free -h`, `df -h`, `systemd-detect-virt`, service state, socket listeners, package update metadata, and available tools. CPU details and several privileged status views remain unknown.

### Connection and transfer summary

The [transfer log](../evidence/transfer_log.txt) records 39 files transferred to `/home/MU/Downloads/sos/securelab-20261102-152707`. The live baseline and subsequent evidence were collected through RustDesk. The first aggregate run exposed a Mission 4 `wait` error caused by waiting inside a `tee` pipeline subshell; the runner was fixed and Person 1 was rerun successfully with exit status 0. The [rerun evidence](../evidence/target/evidence/member1_rerun.log) is the source for Missions 1–6. The [completion audit](COMPLETION_AUDIT.md) predates these results and needs a root refresh.

## Threat model

The project’s authorized scope is a private VM or explicitly approved lab target. Relevant threat actors include an untrusted local account or compromised unprivileged process attempting to read or alter another user’s data, exceed its authority, exhaust shared resources, or cross a process/application boundary. A network actor is relevant only where the actual target exposes a reachable service; its presence has not been established.

The protected resources include private files, process memory, credentials, system configuration, service availability, and the integrity of logs and executable data. The security boundaries examined conceptually are user space versus kernel space, one process address space versus another, a file’s DAC/ACL policy, an IPC endpoint, an application confinement profile, and—if a VM is actually used—the guest/hypervisor/host layers.

The model trusts the Linux kernel to mediate system calls, credentials, memory mappings, and file access; it also relies on correct administrator policy and trustworthy evidence collection. If the kernel is compromised, kernel-enforced process and file protections may be bypassed. Recovery then depends on trust anchors outside that kernel, such as a trusted host, verified boot chain, protected backups, or rebuilding from known-good media.

## Attack surface

The read-only baseline observed 43 running services and listeners including TCP/22 on all IPv4/IPv6 interfaces, loopback DNS on port 53, loopback printing on TCP/631, TCP/2222, and several UDP listeners. Some sockets were not attributed to a process in the unprivileged output. SSH was active and enabled. These are measured exposure points, not findings of weakness; intended use, firewall policy, and remote reachability were not established. The full listings are in the target collection log.

| Surface | Why it matters | Evidence needed |
|---|---|---|
| Listening services and exposed ports | SSH and other listeners were observed; necessity and reachability are unknown | `ss -lntup`, correlated with service/process ownership |
| User and process credentials | Excess privilege can increase impact after compromise | `id`, process UID/EUID/GID, capabilities and service accounts |
| Files, directories, ACLs and capabilities | Incorrect access can expose or permit modification of protected data | `stat`, `ls -l`, `getfacl`, and an authorized read/write test |
| Process memory and resource use | Isolation errors or resource exhaustion can affect confidentiality or availability | `/proc/<PID>`, process-owned test programs, resource observations |
| IPC endpoints | Unauthorized peers or unsynchronized shared state can undermine processes | Endpoint permissions, peer checks, message validation, synchronization |
| Application sandbox and containers | Weak profiles or excessive container access reduce confinement | Actual loaded policy, runtime configuration, and controlled approved tests |
| Logs and update state | Missing records or known unpatched defects hinder response and protection | Accessible journal/auth logs and package state, with limitations recorded |
| VM/hypervisor boundary | Virtual devices and host management create additional dependencies | Confirmed VM metadata and instructor-approved architecture evidence |

The specific observed host also ran RustDesk, printing, Docker/containerd, Avahi, SSH, and security-agent services. No service was disabled, no firewall rule changed, and no external reachability test was performed. A browser extension with broad permissions remains a general example, not a target observation.

## Mission-by-mission implementation, result, and Q&A references

Fifteen missions were selected for non-root work. M18 is conceptual by design; M21 includes a conceptual VM diagram because no virtualization type was detected. The other thirteen selected missions have actual target output. The table links source/notes and the captured evidence.

| Mission | Status and observed result | Q&A and evidence |
|---|---|---|
| 1 — Who Are You? | **Verified.** `id` and the C program both reported real/effective UID 1002 and GID 1002. | [Source and Q1–3](../member1/notes/Missions_1-6_answers.md), [evidence](../evidence/target/evidence/member1_rerun.log) |
| 2 — Meet the Kernel | **Verified.** `hello.txt` contained the message; `strace` showed `openat(...hello.txt...) = 3`, `write(3, ..., 23) = 23`, and `close(3) = 0`. | [Source and Q4–6](../member1/notes/Missions_1-6_answers.md), [evidence](../evidence/target/evidence/member1_rerun.log) |
| 3 — Process Detective | **Verified.** The owned `sleep` process had UID/GID 1002, one thread, three open FDs, zero effective capabilities, and a captured start time. | [Inspector and Q7–9](../member1/notes/Missions_1-6_answers.md), [evidence](../evidence/target/evidence/member1_rerun.log) |
| 4 — Can One Process Read Another? | **Verified.** The program’s own PID and stack variable appeared in `/proc/PID/maps`; the map included executable, heap, shared libraries, and `[stack]`. The corrected rerun waited successfully (exit 0). | [Source, diagram, and Q10–12](../member1/notes/Missions_1-6_answers.md), [evidence](../evidence/target/evidence/member1_rerun.log) |
| 5 — The Race | **Verified.** Unsynchronized counts were 1,000,000; 1,013,183; and 1,782,455 versus expected 2,000,000. Both mutex runs reached 2,000,000. | [Sources and Q13–15](../member1/notes/Missions_1-6_answers.md), [evidence](../evidence/target/evidence/member1_rerun.log) |
| 6 — Two Processes Need to Talk | **Verified.** The pipe child received the parent message. The team-authored POSIX shared-memory example exchanged its message using a mode-0600 object and process-shared semaphores. This is not the instructor-referenced sample, which was absent from both PDFs. | [Sources, comparison, and Q16–18](../member1/notes/Missions_1-6_answers.md), [evidence](../evidence/target/evidence/member1_rerun.log) |
| 7 — Alice vs Bob | **Out of non-root scope.** Alice/Bob accounts were absent and the required cross-account test needs approved test accounts. A separate MU-owned 644/600 analogue does not satisfy it. | [Notes and Q19–21](../member2/M07/notes.md), [captured limitation](../evidence/target/member2/runs/M07.b93CWP/evidence.txt) |
| 8 — The Permission Maze | **Out of non-root scope.** ACL metadata on a self-created file was captured, but no Bob/nobody cross-account read was attempted. | [Notes and Q22–24](../member2/M08/notes.md), [captured limitation](../evidence/target/member2/runs/M08.4L02Df/evidence.txt) |
| 9 — Too Much Power | **Verified, read-only.** Effective capability set was empty; `getcap` showed `cap_net_raw=ep` on `ping` and `mtr-packet`; sudo required a password. | [Notes and Q25–27](../member2/M09/notes.md), [aggregate output](../evidence/target/evidence/combined_run.txt) |
| 10 — The Dangerous Array | **Verified in rootless bubblewrap only.** Short input completed with exit 0; long input triggered stack-smashing detection and exit 134. The bounds-checked companion accepted short input and rejected long input. This was not a VM run and no exploit was attempted. | [Notes, sources, and Q28–30](../member2/M10/notes.md), [runtime output](../evidence/target/evidence/m10_bwrap_runtime.txt) |
| 11 — Why Didn’t the Attack Work? | **Verified, inspection only.** Official Ubuntu `checksec` 2.4.0-1 was extracted under the user workspace. Protected binary: full RELRO, canary, NX, PIE. Reduced build: partial RELRO, no canary, NX, no PIE. ASLR value was 2; neither binary was executed. | [Notes and Q31–34](../member2/M11/notes.md), [checksec result](../evidence/target/evidence/m11_checksec.txt), [ASLR/tool details](../evidence/checksec_final_status.txt) |
| 12 — The Secret File | **Out of non-root scope.** The required `/opt` root-owned layout and Alice/Bob tests were not performed. A home-directory/user-owned analogue is not equivalent. | [Notes and Q35–37](../member2/M12/notes.md), [captured limitation](../evidence/target/member2/runs/M12.4xhgkT/evidence.txt) |
| 13 — Can We Trust the File? | **Verified.** SHA-256 verification passed before the test file changed and failed afterward; both digests were captured. | [Notes and Q38–40](../member2/M13/notes.md), [aggregate output](../evidence/target/evidence/combined_run.txt) |
| 14 — What Happened While I Was Away? | **Verified with limited journal access.** Eight real events were transcribed. The user-readable journal omitted other users’ messages; the SSH unit journal had no entries, which does not establish no SSH activity. | [Timeline and Q41–43](../member2/M14/notes.md), [aggregate output](../evidence/target/evidence/combined_run.txt) |
| 15 — The Suspicious Application | **Verified for the owned test process.** `sleep` had one thread and three FDs; a separate child with `RLIMIT_NOFILE=16` hit `EMFILE` after opening 13 additional FDs. This is a resource-limit demonstration, not a complete sandbox. | [Resource table and Q44–46](../member3/Missions-15-22.md), [runtime output](../evidence/target/evidence/combined_run.txt) |
| 16 — Build Your First Container Sandbox | **Out of non-root scope.** Docker CLI was present, but no daemon/container run was performed; daemon/status access was unavailable to this account. | [Notes and Q47–49](../member3/Missions-15-22.md), [aggregate output](../evidence/target/evidence/combined_run.txt) |
| 17 — Linux Says No | **Out of non-root scope.** AppArmor was enabled, but `aa-status` could not read the profile set without additional privilege; no policy denial was tested. | [Notes and Q50–52](../member3/Missions-15-22.md), [aggregate output](../evidence/target/evidence/combined_run.txt) |
| 18 — Compare Access-Control Models | **Completed conceptually.** DAC/MAC/RBAC/ACL/capability table and realistic scenarios are documented; no terminal output is required. | [Comparison and Q53–57](../member3/Missions-15-22.md) |
| 19 — Harden the Machine | **Out of non-root scope.** A read-only baseline was captured, but UFW status required root and no system changes or before/after hardening were performed. | [Plan and Q58–61](../member3/Missions-15-22.md), [aggregate output](../evidence/target/evidence/combined_run.txt) |
| 20 — Secure Remote Access | **Verified.** Localhost SSH authentication succeeded using a temporary key; the script removed that key and preserved original `authorized_keys` entries. No public exposure or permanent SSH configuration change was performed. | [Notes and Q62–64](../member3/Missions-15-22.md), [SSH transcript](../evidence/target/evidence/m20_ssh_loopback.txt) |
| 21 — Who Protects the VM? | **Conceptual model completed; no VM observation.** `systemd-detect-virt` returned `none`; bare-metal status was not independently established. The required VM trust stack is shown as conceptual only. | [Diagrams and Q65–67](../member3/Missions-15-22.md), [target identification](../evidence/target/evidence/combined_run.txt) |
| 22 — Final Challenge | **Pending instructor resources.** The separate challenge VM/snapshot and rules document were not supplied. No five findings, root-level remediation, or re-tests are claimed. | [Workflow and Q68–80](../member3/Missions-15-22.md) |

The non-root completion count is 15/15: M1–6, M9–11, M13–15, M18, and M20–21. M18 is conceptual by design; M21’s VM stack is conceptual because no virtualization type was detected. The original 22-mission assignment remains partial. The source-to-evidence organization and permission boundaries are in the [detailed team manual](../doc/missions.txt). A supplementary [RustDesk desktop screenshot](../evidence/screenshots/nonroot_live_desktop.png) shows previously saved race, IPC, M10, and SSH transcripts; it is not a fresh rerun or independent result.

## Conceptual security observations (not verified target findings)

1. Linux processes carry real and effective credentials; the effective identity normally informs access checks. Authentication establishes identity, while authorization evaluates an operation against policy.
2. User applications rely on system calls so the kernel can mediate access to files and devices. That makes the kernel part of the trusted computing base.
3. `/proc` exposes useful live process metadata, but resource exhaustion can threaten availability and access to other users’ process data may be restricted.
4. A virtual address is interpreted through a process’s page tables; it is not a globally dereferenceable physical address. The MMU and kernel enforce process mapping permissions.
5. An unsynchronized `counter++` is a data race. Lost updates can corrupt accounting or security-sensitive state; a mutex protects the critical section but the actual output must be captured.
6. A pipe offers a kernel-managed byte stream. Shared memory exposes common mapped data and therefore needs synchronization plus endpoint/peer access control. The included shared-memory program is team-authored and is not the omitted instructor sample.
7. DAC modes, ACLs, capabilities, and MAC profiles make distinct authorization decisions. They should be selected based on the resource and authority needed, not treated as interchangeable labels.
8. A buffer overrun can corrupt adjacent state. Bounds checks prevent an oversized copy; ASLR, NX, PIE, and stack canaries provide different layers of mitigation but do not make unsafe code correct.
9. Hashes can detect a mismatch against a trusted baseline but do not prove who created a file. Protecting the baseline or using signatures is needed for stronger authenticity.
10. Logs support event reconstruction but may be incomplete, inaccessible, rotated, or altered. A missing log entry alone does not prove an event did not occur.
11. Least privilege can reduce service resources, exposed ports, filesystem access, process authority, and remote account rights. Actual service state and policy need measurement before proposing a specific change.
12. Containers share the host kernel; VMs add a guest kernel and virtualization layer. Both have boundaries and dependencies that must be secured.

These observations are bounded to the actual demonstrations listed above. They do not establish an exploitable flaw or security weakness on the host.

## Remediation rationale

No system-wide hardening remediation was performed. The observed changes were confined to test artifacts: the Mission 13 file was edited to demonstrate hash mismatch, the Mission 10 test input triggered a stack-canary abort inside rootless bubblewrap, and Mission 20’s temporary SSH authorized key was removed after the localhost test. Future controls should follow measured evidence and preserve rollback:

- Restrict a secret file and its parent directories to the intended owner/group; use a named-user ACL only for a justified exception. Verify with the original read attempt as both allowed and denied test accounts.
- Give services only the user identity, file access, and Linux capabilities required for their function. Avoid granting full root authority when a narrower capability or privilege-separated design is sufficient.
- Use mutexes or another appropriate synchronization primitive to protect shared state, and use length validation before writing to fixed-size buffers.
- Confine applications with an approved MAC profile or container policy only after confirming the intended resource needs and profile behavior.
- Remove or restrict only services and ports shown by the measured baseline to be unnecessary. Apply updates only through the approved process. Record the exact before state, change, rollback, and repeated check.
- For IPC, restrict who can reach/map the endpoint, validate peers and messages, and synchronize shared state. The team-authored Mission 6 program demonstrated a 0600 shared-memory object and process-shared semaphores.

The final challenge remediation must use findings from its separate approved VM. Possible examples in the handout are not evidence that those weaknesses exist on the missing image.

## Verification status

**Non-root mission scope: 15/15 deliverables verified or completed conceptually.** Runtime/tool output was collected for M1–6, M9–11, M13–15, and M20. M18 is a conceptual comparison; M21 is a conceptual VM stack paired with the observed `systemd-detect-virt none` result. The first M1–6 aggregate invocation logged a wait error because `wait` ran in a `tee` pipeline subshell; the parent-shell wait fix was transferred and the dedicated M1–6 rerun exited 0. The actual rerun log is linked in the mission table.

The seven excluded missions are M7, M8, M12, M16, M17, M19, and M22. M7/M8/M12 require cross-account or root-owned filesystem setup; M16/M17 need additional privileged access for the requested runtime checks; M19 requires approved system hardening changes; M22 requires a separate instructor target and rules. No host-level hardening change or M22 finding is claimed. The root-level tasks and full-assignment status are summarized in [the completion audit](COMPLETION_AUDIT.md), which still needs its status table refreshed to match these results.

## Evidence-based reflections

These statements are grounded in the captured demonstrations; they describe the evidence and do not invent an individual team member’s feelings.

- The clearest contrast is Mission 5: the three unsynchronized runs lost 217,545–1,000,000 increments, while both mutex-protected runs reached 2,000,000. Team members can say whether this outcome surprised them.
- Mission 6 shows that access to a shared-memory endpoint and synchronization of its contents solve different problems: the demo uses mode `0600` for the object and process-shared semaphores for publication/acknowledgment. Both controls matter.
- Mission 4’s actual `/proc/PID/maps` showed distinct executable, heap, library, and stack mappings; the printed local variable address fell within the mapped stack. This made the virtual-address boundary concrete without attempting to read another process.
- Least privilege appeared in the unprivileged process’s empty effective capability set, the owner-only shared-memory object, the resource-limited child, and the temporary SSH account key that was removed after the test. These examples do not prove all host processes or files follow least privilege.
- If the kernel were compromised, it could potentially bypass process isolation and filesystem checks that it enforces. Recovery would depend on independent trust anchors, protected backups, and rebuilding from trusted media.

## Questions 81–88 applied to one representative file-access control

The representative example is the non-root Mission 7 owner-mode analogue: a harmless file owned by `MU`, first mode `0644`, then `0600`. The owner successfully read the file in both states. The Alice/Bob cross-account check was not performed, so denial for another user remains a permission-based prediction, not an observed result. See the [captured M07 analogue](../evidence/target/member2/runs/M07.b93CWP/evidence.txt).

**81. What resource is being protected?** The contents of the harmless test file and its confidentiality/integrity.

**82. Who is trusted?** `MU`, the file owner, was trusted for the owner permissions observed. The experiment did not establish which other account could read it.

**83. Who is untrusted?** Any other account is outside the tested owner identity. At mode `0600`, group and other mode bits grant no access, but an actual second-account denial was not tested.

**84. What boundary separates them?** The file’s owner/group/other mode bits, evaluated by the kernel against the process credentials. Parent-directory traversal also matters for files in nested paths.

**85. What mechanism enforces the boundary?** Linux DAC checks using UID/GID credentials, Unix mode bits, and directory search permissions. The kernel enforces those checks during path lookup and file open.

**86. What happens when access is denied?** A read by a non-owner without a matching group or other permission should fail with a permission error and disclose no contents. The experiment demonstrated the owner’s read, not another account’s denial.

**87. Can the mechanism itself fail?** Yes. Incorrect owner/group/mode settings, an overly permissive parent directory, unintended group membership, a broader ACL, a privileged process, or a compromised kernel can invalidate the intended boundary. A mode listing alone does not establish effective access in every context.

**88. How would I verify that the defense is actually working?** Record `stat`/`ls -l`, `getfacl`, and both test identities. Repeat the same read as the owner and a second approved test account, confirming owner access and the non-owner’s denial at mode `0600`; retain both outputs. This report has the owner-side evidence only, so the cross-account verification remains incomplete.

## Future improvements

1. Obtain approval and a dedicated test environment for M7/M8/M12 cross-account checks, M16 container execution, M17 policy denial testing, and M19 hardening changes.
2. Obtain the separate Mission 22 VM/snapshot, rules/resources, credentials, and rollback procedure. Record at least five authorized findings, apply approved controls, and rerun the original checks.
3. If the course requires the instructor’s exact M6 shared-memory version, request that missing source and compare it with the team-authored POSIX demonstration.
4. Refresh [the completion audit](COMPLETION_AUDIT.md) to distinguish the 15 non-root deliverables verified here from root-required tasks and the pending Mission 22 challenge.

The non-root scope is complete. The original 22-mission assignment remains incomplete because the privileged missions and Mission 22 are outside this scope. This report does not certify that the workstation is secure.
