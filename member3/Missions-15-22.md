# SecureLab Missions 15–22 — Member 3 materials

This document supplies conceptual answers, safe evidence commands, and the observed target results for Missions 15–22. The mission manual and supplied handout PDFs are the sources. The adjacent collect.sh script automates read-only checks for Missions 15–21. The sandbox_demo.py program is an optional Mission 15 supplement.

## Current execution boundary

Linux target evidence for Missions 15–21 was collected through the authorized remote run on 2026-11-02; the exact transcript is `evidence/target/evidence/combined_run.txt`. No WSL mission execution was performed. The target identifies as Ubuntu 22.04.1 LTS, kernel 5.15.0-43-generic, host `inhydmupc0899-l`, user MU (UID 1002). The collector and supplementary demo both completed; the `docker info` query and AppArmor profile inspection had documented failures. No hardening changes were performed. Authenticated rootless SSH to localhost succeeded; see `evidence/target/evidence/m20_ssh_loopback.txt`. Mission 22's separate challenge VM and rules/resources document remain absent, so no target findings, remediations, or successful verification can be claimed.

## Mission 15 — The Suspicious Application

### Safe evidence capture

Run in a shell on the Ubuntu target. It starts only a `sleep` process owned by the current user and stops it on exit, including most interruptions.

```sh
sleep 120 &
pid=$!
printf 'PID=%s\n' "$pid"
ps -p "$pid" -o pid,ppid,uid,euid,nlwp,%cpu,%mem,cmd
ls -l "/proc/$pid/fd"
grep -E '^(Name|Uid|Gid|Threads):' "/proc/$pid/status"
ss -lntup
kill "$pid"
```

`ss -lntup` is a host-wide socket listing. Attribute a socket to the selected program only when the output identifies its process; absence of a `sleep` listener is not a general proof that the host has no network exposure.

### Resource table and proposed policy

| Resource | Evidence to record | Needed by `sleep`? | Proposed restriction |
|---|---|---|---|
| Identity | UID/EUID in `ps` and `status` | A normal unprivileged user is sufficient | Run under a dedicated non-root account; deny privilege escalation |
| File access | `/proc/PID/fd` symlinks | Standard input/output/error only | Restrict filesystem view to required read-only paths; no write access to home or system files |
| Networking | Correlated process socket data, if any | No | Deny network access |
| Process control | `ps` PPID and thread count | One process/thread is enough | Restrict process creation and resource use; disallow tracing/ptrace where supported |

The three core restrictions are no network, read-only/minimal filesystem access, and no privilege escalation. These are policy proposals only; do not say a sandbox denial occurred unless an enforcement experiment actually ran.
### Observed target result

The collector-owned `sleep 60` ran as PID 2985226 (PPID 2985222), UID/EUID 1002, with one thread and three open descriptors: stdin pointed to `/dev/null`, and stdout/stderr pointed to the collector pipe. `/proc/PID/status` reported `Name: sleep`, UID/GID 1002, and one thread. The host socket listing did not attribute a socket to `sleep`; it did show the host’s other listeners described under Mission 19. The collector stopped its `sleep` process after capture.

### Supplementary subprocess resource-limit demonstration

Run python3 member3/sandbox_demo.py to start one child process owned by the current user, apply RLIMIT_NOFILE and RLIMIT_CPU to that child, and have it open /dev/null until the descriptor limit is reached. It performs no downloads or privileged changes. This is a small resource-limit demonstration, not a complete sandbox: it does not isolate filesystems, networking, syscalls, or namespaces. The actual run set the child’s RLIMIT_NOFILE soft/hard limits to 16. Opening /dev/null failed with EMFILE after 13 additional descriptors, and the child exited 0. This demonstrates a per-process resource limit only; it does not prove filesystem, network, syscall, or namespace isolation.

### Professor questions 44–46

44. `sleep` needs a CPU timer and ordinary process state; it does not need network access or application data files. 45. Network access, write access outside a dedicated scratch directory, and privilege escalation can be denied without changing its purpose. 46. Least privilege removes resources an exploited process could reach, reducing the damage available after compromise and shrinking its attack surface.

## Mission 16 — Build Your First Container Sandbox

The remote target has Docker CLI 20.10.12 and the `docker.service` was active in the Mission 19 service listing. The read-only `docker info --format` query failed with a Docker CLI panic (exit status 2), so it did not return usable daemon details. Container execution was **SKIPPED / ROOT REQUIRED** under the non-root-only scope; no containers were started. Do not install Docker, start/restart a daemon, or alter group membership on a shared machine without instructor approval. A Docker socket or membership in the `docker` group can grant host-level authority.

### Evidence commands (authorized Docker host only)

```sh
docker --version
sudo docker info | head -25
sudo docker run --rm hello-world
sudo docker run --rm ubuntu:26.04 uname -a
sudo docker run --rm ubuntu:26.04 cat /etc/os-release
sudo docker run --rm ubuntu:26.04 ps
uname -a
cat /etc/os-release
```

Record a blocked result if Docker is absent or permission is denied. Image pulls may use network and disk. The Ubuntu image's `/etc/os-release` describes its userspace; `uname -a` reports the shared host kernel. The minimal image may not include `ps`; preserve that actual result.
### Observed target result

`docker --version` returned Docker version 20.10.12, build 20.10.12-0ubuntu4. `docker info --format` exited 2 after a Go template panic (`reflect: indirection through nil pointer to embedded struct`), so daemon details were unavailable from that command. The service listing separately showed `docker.service` active/running. No `hello-world` or Ubuntu image was run; host/container comparison remains pending.

### Architecture and comparison

```text
CONTAINER: container application -> namespaces / cgroups -> host Linux kernel -> hardware
VM:        guest application -> guest kernel -> virtual devices -> hypervisor -> host hardware
```

| Property | Container | Virtual machine |
|---|---|---|
| Kernel | Shares host kernel | Boots a separate guest kernel |
| Isolation | Namespaces give processes different views; cgroups account for or limit resources | Hypervisor mediates virtual CPU, memory, storage, and devices |
| Resource controls | CPU, memory, process, and other cgroup controllers, subject to configuration/kernel support | VM resource allocation and guest OS controls |
| Main boundary | Kernel and container runtime remain shared dependencies | Hypervisor and virtual-device boundary, plus guest kernel |

### Professor questions 47–49

47. A PID namespace gives processes a separate process-ID view; a container can see its own process tree without seeing the host's full tree. 48. No. Containers normally share the host kernel, while a VM runs a guest kernel behind virtual hardware. 49. Cgroups can account for and, when configured, limit CPU, memory, process counts, I/O, and other supported resources.

## Mission 17 — Linux Says No

The supplied materials say an instructor denial profile is not included. Inspect status and real loaded profiles; do not invent an allowed/denied result or create/load policy on a shared machine.

### Read-only evidence commands

```sh
command -v aa-status || true
cat /sys/module/apparmor/parameters/enabled 2>/dev/null || true
sudo aa-status
sudo aa-unconfined 2>/dev/null | head -20
```

If `aa-status` exists, choose one profile it actually lists. Record the exact profile name, enforce/complain mode, and the executable it confines. If the command or kernel support is absent, record that limitation. A denial experiment is conditional on an instructor-provided application/profile and instructions.
### Observed target result

`/sys/module/apparmor/parameters/enabled` returned `Y`, establishing that the kernel module is enabled. `aa-status` reported insufficient privilege to read the profile set and exited 4, while stating the module is loaded. `aa-unconfined` was unavailable. Profile inspection was **SKIPPED / ROOT REQUIRED** under the non-root-only scope. No loaded-profile name/mode or allow/deny demonstration was collected; the instructor-provided denial demo is also unavailable.

AppArmor is Linux mandatory access control (MAC): centrally defined profiles associate an application with allowed resources/operations. Unix DAC checks owner/group/mode bits; passing DAC checks does not override a MAC denial. The combination is defense in depth because an application may be restricted even when its user identity could otherwise access a file.

### Professor questions 50–52

50. AppArmor constrains an application’s access to files, capabilities, networking and other operations described by its profile. 51. Unix DAC decisions generally depend on the process identity and file owner/group/mode (and ACLs); MAC applies administrator-defined policy to the program regardless of file ownership. 52. MAC can contain a process after compromise by denying actions that DAC alone would permit.

## Mission 18 — Compare Access-Control Models

| Mechanism | Decision basis | Example | Limitation |
|---|---|---|---|
| DAC | Owner-controlled permissions for user/group/other | Student sets a private file to mode `0600` | Owner can mistakenly share too much; privileged users may bypass ordinary checks |
| MAC | Centrally administered policy label/profile | AppArmor confines a web browser to browser data and required libraries | Incomplete or incorrect policy can permit excess or break legitimate behavior |
| RBAC | Role membership and permissions assigned to each role | Database administrator role can manage schema and accounts | Roles can become too broad; stale memberships accumulate |
| ACL | Named user/group entries on an object | Grant one lab partner read access without changing the file’s owning group | Many exceptions are hard to audit and maintain |
| Capability | A process receives a narrow privileged operation/right | A service receives only the capability needed to bind a low-numbered port | A capability can still be dangerous if too broad or attached to a vulnerable process |

### Professor questions 53–57

53. The resource owner normally controls DAC permissions. 54. An administrator or system policy author defines MAC policy. 55. RBAC grants database operations to a database-admin role, then assigns authorized people to that role; users inherit those role permissions. 56. A capability divides authority into specific rights, allowing a process a narrow privileged operation without granting full root authority. 57. ACLs add named-user/group exceptions to the basic owner/group/other permission model, enabling more precise sharing.
### Observed completion status

The conceptual comparison, five scenarios, and answers 53–57 are complete. Mission 18 requires no terminal output; this is a conceptual deliverable, not a claim that these mechanisms were experimentally exercised on the target.

## Mission 19 — Harden the Machine

No privileged host changes have been made. On a shared machine, provide the baseline and a proposed, reversible plan. The manual lists `apt update`, which modifies package-list state; skip it unless authorized. `apt list --upgradable` uses local package metadata and can be stale, so label that limitation. Do not disable SSH/networking, change firewall rules, install updates, or stop services without an approved dedicated target and rollback.

### Read-only baseline commands

```sh
date -Is
cat /etc/os-release
uname -r
apt list --upgradable 2>/dev/null | head -30
systemctl --type=service --state=running --no-pager
ss -lntup
sudo ufw status verbose 2>/dev/null || true
```

Record the timestamp and command/result pairs. These commands describe a baseline; they do not prove hardening. Some details may be hidden without elevated privileges.
### Observed target baseline

The target was Ubuntu 22.04.1 LTS (Jammy), kernel `5.15.0-43-generic`, at 2026-11-02 15:27 +05:30. The cached `apt list --upgradable` output showed multiple available package updates (including `apparmor`, `apt`, `avahi-daemon`, and others), but was truncated to the first 30 entries and uses possibly stale local metadata. `systemctl` listed 43 running services. The socket listing showed TCP 22 on `0.0.0.0` and `[::]`; TCP 2222 on `0.0.0.0`; TCP 631 and 36689 on loopback; UDP 53 on loopback, 631, 53520, 54469 (attributed to `rustdesk` PID 2966218), and 5353; and IPv6 UDP 39559 and 5353. UFW status could not be read because the command requires root. Service and port necessity cannot be judged without the machine’s intended role. No hardening change was applied; no before/after verification exists.
### Scope outcome

UFW status inspection and all hardening changes/retests were **SKIPPED / ROOT REQUIRED** under the non-root-only scope. No privileged or system-wide changes were made.

### Three-change plan template (proposals, not completed changes)

| Condition to verify first | Proposed change if justified and approved | Risk / rollback | Verification |
|---|---|---|---|
| An explicitly identified, unused test service is running | Stop and disable only that service | Could disrupt dependent work; re-enable with `sudo systemctl enable --now SERVICE` | Compare `systemctl is-enabled` and running-service list before/after |
| A nonessential service listens on an identified interface/port | Restrict its bind address or add a narrowly scoped firewall rule | Could interrupt legitimate access; restore saved config/rule | Repeat `ss -lntup` and firewall status; test intended access |
| Approved security updates are missing | Apply the instructor-approved package update procedure | Package changes can regress service; use snapshot/package rollback plan | Repeat package version/update check and relevant service checks |

Replace placeholders only after a real baseline identifies the service, port, or patch. If nothing supports the proposed condition, do not present it as a finding. Capture before/after evidence only for authorized changes.

### Before/after checklist (fill only after an approved change)

| Check | Baseline command and result | Approved change / expected state | Recheck command and actual result | Status |
|---|---|---|---|---|
| OS, kernel, update state | Pending target | Record approved patch/version | Repeat OS/kernel/package check | Pending |
| Running services | Pending target | Only the justified service changes | Repeat service listing and targeted status | Pending |
| Listening ports | Pending target | Only the justified port/interface changes | Repeat socket listing and firewall status | Pending |

No checklist row is marked complete until the exact recheck result is collected.

### Professor questions 58–61

58. Keep services required for the machine’s intended role; disable only verified unused services with approval and rollback. 59. Expose only ports required by that role, on the narrowest needed interfaces and source ranges. 60. Patch management removes known defects attackers can exploit, reducing exposure to documented vulnerabilities. 61. Recording a change and its rollback path supports review, makes the result reproducible, and protects availability if the change has an unintended effect.

## Mission 20 — Secure Remote Access

The available Windows SSH client does not show that Ubuntu `sshd` exists or is listening. Do not install/enable SSH or expose port 22 without approval. Keep the test on localhost or the lab network.

### Evidence commands (approved Ubuntu target)

```sh
command -v sshd || true
sudo systemctl status ssh --no-pager
ss -lnt | grep ':22' || true
ssh localhost
# In the authenticated session:
whoami
hostname
exit
journalctl -u ssh --since '15 minutes ago' --no-pager | tail -30
```

If no server/listener exists, report the experiment blocked by environment. Do not weaken authentication to force success. Verify a newly presented host fingerprint through the lab administrator before accepting it, and redact usernames or addresses if the report is shared publicly.
### Observed target status

The service was active and enabled. `ss -lnt` showed port 22 listening on both `0.0.0.0` and `[::]`. `sshd -V` printed OpenSSH_8.9p1 after rejecting `-V` as an unknown option. The rootless localhost test succeeded with a temporary unique key for the current account: output included `SECURELAB_SSH_LOGIN_OK`, UID/GID 1002, and exit status 0. The key was removed afterward and original authorized-key entries were preserved. See `evidence/target/evidence/m20_ssh_loopback.txt`. This proves local key authentication only; it does not establish remote-network reachability or test authorization to access other users’ files. Do not infer public reachability from the wildcard bind alone.

SSH encrypts the connection and authenticates the server (host key) and client/user (for example, key or password). Authentication establishes identity; authorization then comes from Unix permissions, ACLs, groups, capabilities, and system policy to decide what that identity may do. SSH service logs can provide login evidence; the exact journal unit name depends on the distribution.

### Professor questions 62–64

62. SSH authenticates the server to the client using its host key and authenticates the connecting user using the configured method. 63. Authorization controls after login determine which files and operations are allowed. 64. Inspect the SSH service journal (`journalctl -u ssh` or the distribution’s equivalent auth log), subject to access and retention.

## Mission 21 — Who Protects the VM?

Linux target outputs were collected through RustDesk MCP, but no hypervisor/guest relationship was confirmed. Record the virtualization detection result without treating it as proof of bare-metal hardware. Label the required VM diagram as conceptual and keep the actual-target stack unconfirmed.

### Evidence commands (Linux target)

```sh
cat /etc/os-release
systemd-detect-virt || true
uname -a
```

### Trust diagrams

```text
REQUIRED VM MODEL (conceptual unless an actual VM was examined)
Application -> guest kernel -> virtual hardware -> hypervisor -> host OS -> physical hardware
                    [guest trust boundary]       [virtualization boundary]

ACTUAL TARGET STACK (fill after target type is observed; currently pending)
Application -> [guest or native] Linux kernel -> [virtualization layer if present] -> host / physical hardware
```

The guest OS trust boundary contains the guest kernel and privileged guest services. The hypervisor or virtualization layer controls virtual hardware presented to the guest. A VM adds dependencies on hypervisor correctness, virtual-device emulation, host configuration and patching, management-plane access, and guest-to-host isolation. A VM can improve separation while adding components that also need protection.
### Observed target result

`systemd-detect-virt` printed `none` and exited 1; `uname -a` reported Linux host `inhydmupc0899-l` with kernel `5.15.0-43-generic`. This indicates the utility detected no supported virtualization environment, but does not prove bare-metal hardware. No hypervisor/guest relationship was directly identified, so only the required VM diagram is conceptual and the actual-target stack remains unconfirmed.

### Professor questions 65–67

65. The guest OS boundary includes the guest kernel and privileged guest services. 66. The hypervisor/virtualization layer controls and presents virtual hardware to the guest. 67. Virtualization adds the hypervisor, virtual devices, host management interfaces, and guest-to-host boundary as security dependencies and possible attack surface.

## Mission 22 — Final Challenge: Secure the Machine

**Blocked pending instructor resources.** The supplied handout says the challenge uses a deliberately misconfigured Linux VM/snapshot and separate rules/resources document. Neither is present in the provided files. Do not use the ordinary workstation or invent findings. Root/lead should obtain the authorized target, scope, credentials and rollback instructions before execution.

### Required baseline on the authorized challenge target

```sh
date -Is
cat /etc/os-release
id
ps aux | head -35
ss -lntup
systemctl --type=service --state=running --no-pager
find /etc -maxdepth 1 -type f | head -20
sudo ufw status verbose 2>/dev/null || true
```

Adapt commands to the provided rules and available privileges. Record scope and OS version before any test. The handout assigns Member 3 integrity/logs/confinement; coordinate with the lead so those observations are distinct and the final team report still contains at least five verified findings across all members.

### Finding record (fill only with observed evidence)

| ID | Observation and exact evidence | Classification | Risk | Control and approval | Original check after fix | Rollback |
|---|---|---|---|---|---|---|
| F-01 | Pending target | Pending | Pending | Pending | Pending | Pending |
| F-02 | Pending target | Pending | Pending | Pending | Pending | Pending |
| F-03 | Pending target | Pending | Pending | Pending | Pending | Pending |
| F-04 | Pending target | Pending | Pending | Pending | Pending | Pending |
| F-05 | Pending target | Pending | Pending | Pending | Pending | Pending |

Use classifications from the handout: confidentiality, integrity, availability, authentication, authorization, isolation, or attack surface. A command output is an observation; call it a verified vulnerability only when it demonstrates a security-relevant condition and scope. For each approved remediation, preserve pre-change state and rerun the same check.

### Required final report structure

1. Executive summary
2. System profile
3. Threat model
4. Attack surface
5. Findings and evidence
6. Remediation and rationale
7. Verification
8. Reflection
9. Future improvements

### Professor questions 68–80

68. Establish the baseline with timestamp, OS/kernel, identity, process list, services, listening sockets, important configuration files, and available security status; preserve actual output. 69. The five observations must come from the authorized target; they cannot be supplied honestly before inspection. 70. Classify each finding as confidentiality, integrity, availability, authentication, authorization, isolation, or attack surface according to its demonstrated impact. 71. Choose a control that directly addresses the observed cause, such as restrictive permissions/ACLs, a least-privilege account or capability, a MAC profile, service/firewall restriction, or approved patch. 72. Apply only after approval and recording the original state and rollback. 73. Repeat the original check and compare actual output. 74. Capture command and result together, with mission/finding ID and timestamp; protect credentials and sensitive data. 75. Use the nine report sections above and distinguish observations from conclusions.

76. **Reflection draft, not a report of team experience:** MAC can be a surprising protection because ordinary file ownership may allow a user to read a file while an enforcing application profile still denies that application access. Replace this with the team’s genuine reflection and, if available, its Mission 17 evidence. 77. **Conceptual example:** a compromised network service can be constrained by both DAC (run as an unprivileged account with access only to its data) and MAC (confine the executable’s filesystem and network operations); a firewall can further limit reachable peers. These controls protect different boundaries. This is an example, not a discovered target finding. 78. **Experiment reference pending:** the Mission 16 comparison is intended to show that a container gets its own process view while uname -a still reports the shared host kernel. Cite the actual team experiment only if it ran; otherwise label this as the concept the experiment would illustrate. 79. Least privilege appears in restricting process resources (15), container resource scope (16), confined app profiles (17), narrow roles/ACLs/capabilities (18), minimum services/ports (19), and limited remote account rights (20). 80. If the kernel is compromised, it can potentially bypass process, filesystem and isolation controls enforced by that kernel; protection then depends on recovery/trust anchors outside the compromised kernel, such as a trusted host/hypervisor, measured/secure boot, offline backups, and rebuilding from known-good media.
