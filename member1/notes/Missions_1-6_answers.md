# Person 1 — Missions 1–6: explanations and answers

These are conceptual answers, not experiment results. Record the actual machine, commands, output, and any differences in the corresponding evidence files before marking a mission verified. The numbered questions follow both the instructor handout and the detailed team manual.

## Mission 1 — Who Are You?

**1. What is the difference between UID and EUID?** The real UID identifies the user who started the process. The effective UID is the credential the kernel normally consults for permission checks; a set-user-ID program can have a different EUID while retaining the caller's real UID. Real and effective GIDs play corresponding roles for groups.

**2. Why is authentication different from authorization?** Authentication establishes which account or principal is presenting credentials. Authorization evaluates what that authenticated principal may do under permissions and policy. A successful login as Alice does not automatically grant permission to read a root-owned secret.

**3. Which CIA property is affected when an unauthorized user reads a secret file?** Confidentiality, because information was disclosed to a principal without permission.

**Two workstation attack surfaces:** (a) A network service reachable from the network may expose a vulnerable parser or weak configuration. (b) A browser extension with broad permissions can read or alter pages and data available to the browser profile. These are examples to describe, not targets to test.

## Mission 2 — Meet the Kernel

**4. Which system calls did you observe?** Identify the actual trace lines for opening, writing, and closing `hello.txt`. On current Linux/libc, the C `open()` call commonly appears as `openat()` in `strace`; the write and close operations appear as `write()` and `close()`. The file descriptor returned by open is passed to write and close. Use the captured trace for exact descriptor and return values.

**5. Why should an application not directly control hardware?** Central mediation lets the kernel arbitrate permissions, share devices safely, validate requests, and isolate programs. Direct uncoordinated device access could bypass access controls or corrupt another program's state.

**6. Why is the kernel part of the trusted computing base?** The kernel enforces process isolation, credentials, file permissions, and system-call policy. If it fails or is compromised, these protections can be bypassed, so its correctness is security-critical.

**Boundary diagram:** `Application (user space) → open/write/close system-call interface → Linux kernel (checks and performs request) → filesystem resource: hello.txt`.

## Mission 3 — Process Detective

**7. What security-relevant information does `/proc/<PID>/status` reveal?** It exposes process identity and state, parent PID, real/effective/saved IDs, thread count, memory use, and capability sets. Interpret these fields as investigation clues; one unusual value alone does not prove malicious behavior.

**8. Why can resource consumption itself be a security concern?** A process can exhaust memory, CPU, process slots, or file descriptors and prevent legitimate users or services from working. That is an availability risk.

**9. Why is the number of threads useful?** It helps explain concurrency and resource use and can reveal unexpected growth or a thread-heavy workload. Compare it with the program's purpose and a baseline rather than treating a large count as proof of compromise.

The inspector adds process start time (clock ticks since boot) and effective capabilities (`CapEff`) to the handout fields. `/proc` offers a kernel-maintained, quickly inspectable view of a live process; access may be restricted for other users' processes.

## Mission 4 — Can One Process Read Another?

**10. What does a process's address space contain?** Its virtual mappings for executable code, data, heap, stack, shared libraries, and other mapped files or regions. The precise layout is platform- and run-dependent.

**11. Why can't another ordinary process simply dereference the printed pointer?** The pointer is a virtual address interpreted using the originating process's page tables. The same numeric address in another process refers to that process's own mapping, or may be unmapped; it does not act as a cross-process reference.

**12. What role does hardware-assisted memory protection play?** The MMU translates virtual addresses using page tables and enforces access bits such as read, write, and execute. Kernel-managed mappings isolate processes and prevent ordinary user code from accessing protected pages. Privileged debugging interfaces are separate, permission-controlled mechanisms.

**Address-space sketch (layout varies):**

```text
Higher virtual addresses
  stack                  local `secret` is typically here
  shared libraries / mmap regions
  heap                   dynamic allocations
  initialized data / BSS globals
  executable text        program instructions
Lower virtual addresses
```

## Mission 5 — The Race

**13. Why can the unsynchronized result be lower than expected?** `counter++` is a read-modify-write sequence, not one indivisible operation. Two threads can read the same old value, each calculate the same next value, and overwrite one another's update. In C, the unsynchronized conflicting accesses also constitute a data race with undefined behavior, so no exact outcome is guaranteed.

**14. Which region is the critical section?** In `race_fixed.c`, the protected `counter++` between `pthread_mutex_lock(&lock)` and `pthread_mutex_unlock(&lock)` is the critical section.

**15. Why can a race condition become a security vulnerability?** A race can make a check and its later use observe inconsistent state, lose accounting updates, or let concurrent operations bypass limits or authorization logic. The exact impact depends on the program and its invariants.

**Example interleaving:** T1 reads 5; T2 reads 5; T1 writes 6; T2 writes 6. Two increments happened but the stored value rose only once. The mutex serializes the protected update. The unsafe program may happen to print the expected value on some runs; that does not make it correct.

## Mission 6 — Two Processes Need to Talk

**16. Why is a pipe different from shared memory?** A pipe is a kernel-managed byte stream accessed through read/write file descriptors; in this example the parent sends bytes and the child receives them. Shared memory maps the same region into both processes, so each can read/write common storage directly. `src/shared_memory_ipc.c` is a team-authored POSIX `shm_open`/`mmap(MAP_SHARED)` comparison example; it was not included in the instructor handout.

**17. Why does shared memory normally require synchronization?** Both processes can access the same data concurrently. Locks, semaphores, or another protocol are needed to prevent races and define when data is complete and safe to read. A pipe's stream semantics simplify transport, though an application protocol may still need framing and validation.

**18. What must be protected in secure IPC: the data, the endpoint, or both?** Both. Restrict who can connect to or map the endpoint, and validate/protect message contents because an authorized or compromised peer can still send malformed or unauthorized requests.

| Property | Pipe / message passing | Shared memory |
|---|---|---|
| Data flow | Kernel-mediated byte stream via read/write descriptors | Both processes access a shared mapped region; the team example uses POSIX `shm_open` and `mmap(MAP_SHARED)` |
| Coordination | Stream ordering; application may define framing | Usually needs locks/semaphores and a shared protocol; the example uses process-shared semaphores |
| Access control | Protect endpoint and inherited/open descriptors | Restrict mapping/segment access and lifetime; the example creates its object with mode `0600` |
| Main failure risk | Wrong peer, malformed or misframed message | Shared-state races and inconsistent data |

**Team-authored shared-memory example:** The parent creates a uniquely named POSIX shared-memory object with owner-only (`0600`) permissions, maps it as `MAP_SHARED`, and forks a child that inherits the mapping. A process-shared `ready` semaphore publishes the message; an `acknowledged` semaphore keeps the parent from destroying the mapping before the child reads it. The program unlinks the object and destroys the semaphores after the exchange. This is an additional team implementation because the supplied handout delegates the shared-memory design to the instructor but does not include that code. Its output, when actually run, should be saved separately from the pipe output.

**Proposed secure IPC control:** Create the endpoint with access restricted to the intended service account/group, authenticate or otherwise validate the peer where needed, and validate message length and fields before acting on them. For shared memory, set restrictive permissions and use a process-shared synchronization protocol.

## Evidence checklist and truthful status

Run `../run_missions.sh` from the approved Ubuntu lab workspace, or invoke it by path. It writes command transcripts and observed output to `member1/evidence/`. Complete [the mission evidence template](mission_evidence_template.md) with the Question, Prediction, Experiment, actual Observation, Concept, Defense, Verification, and Reflection. The diagrams and conceptual answers are included above. The runner only records Missions 1–6 and does not create screenshots; capture screenshots with command and output visible if the instructor requires them.

Mission 6's handout refers to a shared-memory example supplied separately, but neither supplied PDF includes its implementation. The source in `src/shared_memory_ipc.c` is a team-authored comparison implementation, not the instructor's missing example. If run, report it under that label; do not claim it came from the instructor. Do not claim outputs that were not observed.
