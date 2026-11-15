# Missions 7-14 execution pack

Follows doc/missions.txt. The answer notes cover original Think About It questions 19-43: M07 19-21, M08 22-24, M09 25-27, M10 28-30, M11 31-34, M12 35-37, M13 38-40, and M14 41-43.

The captured remote evidence and status matrix are in status.md. M07/M08/M12 Alice/Bob and /opt tasks remain SKIPPED ROOT REQUIRED. Their user-level analogues are supplemental and do not satisfy those required tests.

M10's short and long unsafe cases were run in a verified rootless bubblewrap sandbox (unshare-all, read-only filesystem, isolated PID/network, tmpfs /tmp, core dumps disabled), not a VM. Short exited 0; long reported stack-smashing detection and exited 134. The bounds-checked companion accepted short input and rejected long input. M11 checksec 2.4.0-1, ASLR, and ELF stack-permission evidence are captured; no binary was executed. All results are linked in the per-mission notes and status matrix.
