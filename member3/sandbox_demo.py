#!/usr/bin/env python3
"""M15 supplementary demo: run this program's own child with POSIX rlimits.

Linux/Unix only. No downloads, network access, privileged operations, or file
creation. This demonstrates per-process resource limits, not a complete sandbox.
"""

import os
import subprocess
import sys


CHILD = r'''
import errno
import os
import resource

soft, hard = resource.getrlimit(resource.RLIMIT_NOFILE)
print(f"child pid={os.getpid()} RLIMIT_NOFILE soft={soft} hard={hard}")
opened = []
try:
    for _ in range(128):
        opened.append(os.open("/dev/null", os.O_RDONLY))
except OSError as exc:
    if exc.errno != errno.EMFILE:
        raise
    print(f"open denied at descriptor limit after {len(opened)} additional descriptors: {exc}")
else:
    print(f"opened {len(opened)} descriptors without reaching the limit")
finally:
    for fd in opened:
        os.close(fd)
'''


def set_child_limits() -> None:
    """Apply modest limits to the child before Python starts."""
    import resource

    resource.setrlimit(resource.RLIMIT_NOFILE, (16, 16))
    resource.setrlimit(resource.RLIMIT_CPU, (2, 3))


def main() -> int:
    if os.name != "posix":
        print("This supplementary demo requires a POSIX/Linux environment.", file=sys.stderr)
        return 2

    try:
        import resource  # noqa: F401 - ensure the POSIX resource API exists
    except ImportError:
        print("Python's resource module is unavailable on this platform.", file=sys.stderr)
        return 2

    print("M15 supplementary demonstration: own child process with RLIMIT_NOFILE=16 and RLIMIT_CPU=2/3 seconds")
    print("This is not a complete sandbox: it does not isolate filesystems, networking, syscalls, or namespaces.")
    result = subprocess.run(
        [sys.executable, "-c", CHILD],
        check=False,
        preexec_fn=set_child_limits,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        timeout=8,
    )
    print(result.stdout, end="")
    print(f"child exit status={result.returncode}")
    return result.returncode


if __name__ == "__main__":
    raise SystemExit(main())
