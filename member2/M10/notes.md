# Mission 10 - The Dangerous Array

The unsafe source accepts only two fixed choices: short ("OK") and a fixed, benign longer test string. It never accepts arbitrary input. compile.sh records compiler output for both the unsafe sample and a bounds-checked companion. The unsafe runtime was run only in a verified rootless bubblewrap sandbox with unshare-all, read-only filesystem, isolated PID/network namespaces, tmpfs /tmp, and core dumps disabled. This was a sandbox run, not a VM run. No exploit payload or other host/process target was used.

**Captured sandbox observations:** The short input copied 3 bytes into the 16-byte buffer, reached the end of the copy, and exited 0. The long input caused "*** stack smashing detected ***: terminated" and exited 134. These results describe this compiler/target/sandbox run; they do not make the unsafe copy acceptable or guarantee the same behavior elsewhere.

**Bounds-checked companion:** The remote safe run accepted the 3-byte short input and exited 0. It rejected the 34-byte long input before copying and exited 1.

The checked companion validates source length including the terminating NUL before memcpy. An out-of-bounds write modifies memory outside the array and can corrupt program state, threatening integrity, availability, or security. Bounds validation prevents copying when input exceeds capacity. Compiler diagnostics and memory protection are useful but do not replace correct bounds checks.

```text
Valid destination boundary: 16 bytes
+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+
| 0  | 1  | 2  | 3  | 4  | 5  | 6  | 7  | 8  | 9  | 10 | 11 | 12 | 13 | 14 | 15 |
+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+
Copied long input including NUL: [ bytes 0 through 15 ][ bytes beyond buffer ... ]
                                                          ^ out-of-bounds writes
```

Source: evidence/target/evidence/m10_bwrap_runtime.txt, aggregate M10 section, and safe_demo.txt.
