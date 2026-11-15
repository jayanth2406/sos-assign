# Mission 9 - Too Much Power

Remote read-only observations: id reported uid/gid 1002 (MU). Noninteractive sudo -l reported that a password is required. capsh reported Current: = (no effective capabilities in the current shell); the bounding set included CAP_NET_BIND_SERVICE and other capabilities. getcap reported /usr/bin/mtr-packet and /usr/bin/ping with cap_net_raw=ep.

CAP_NET_RAW permits use of raw and packet sockets where the capability is effective. In this output the file capability is attached to those named executables; it does not mean the current shell has that capability. No capabilities were changed.

```text
Broad authority                         Narrow authority
+---------------------------+           +---------------------------+
| root application          |           | app + one needed capability|
| many privileged operations|           | limited operation set      |
+-------------+-------------+           +-------------+-------------+
              | compromise                              | compromise
              v                                         v
     broad system impact                       smaller possible impact
```

Giving every program root makes any bug potentially system-wide. A capability is a discrete, narrower unit of privileged authority. Privilege separation limits damage by giving each component only required access.

Source: aggregate remote run, M09 section. Status: inspection captured; sudo policy requires an interactive password and no changes were made.
