# Mission 11 - Why Didn't the Attack Work?

**Captured inspection observations:** Both the protected build and the reduced-compiler-protection build completed with exit status 0. checksec 2.4.0-1 reported Full RELRO, canary, NX, and PIE for memory_protected; it reported Partial RELRO, no canary, NX, and no PIE for memory_reduced. The package was downloaded and extracted user-locally, not installed with root privileges. The system ASLR value was 2. readelf reported GNU_STACK as RW (without an E flag) for both binaries. Neither binary was executed, and OS ASLR was not changed.

| Protection | Threat addressed | Where it works | Limitation |
|---|---|---|---|
| RELRO | Restricts modification of relocation-related data | ELF loader/linker setup | Does not prevent unrelated memory errors |
| ASLR | Makes memory addresses harder to predict | Kernel process address layout | Leaks/repeated attempts may reduce value; does not repair memory errors |
| NX | Blocks execution from pages marked non-executable | Page permissions on mapped memory | Does not stop data corruption or code-reuse attacks |
| Stack canary | Detects certain stack overwrites before return | Instrumented protected stack frames | Not all corruption is detected; coverage and integrity matter |
| PIE | Allows main executable relocation | Position-independent executable plus loader/ASLR | Relocation alone is not randomization and does not remove unsafe behavior |

The reduced-compiler-protection binary was built without stack-protector and PIE flags. Its checksec output still reports NX enabled; GNU_STACK RW without E likewise shows the stack segment is not marked executable in these ELF headers. The protected binary has a canary and PIE. These are binary configuration observations, not proof that unsafe code cannot be exploited.

ASLR obscures address locations. NX prevents execution from non-executable regions. A canary attempts to detect stack smashing. Defense in depth combines controls with different failure modes; none makes unsafe code acceptable.

Source: evidence/target/evidence/m11_checksec.txt and aggregate M11 section.
