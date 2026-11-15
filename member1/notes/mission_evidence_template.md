# Person 1 — Mission Evidence Notes Template

Duplicate this section for each mission and fill it only after the approved-target experiment. The prediction is written before running; the observation is the actual result. Do not copy the “what to expect” descriptions from the handouts into the observation field.

## Mission __ — Title

**Status:** Prepared / Run on approved target / Blocked (state why)  
**Date and timezone:**  
**Target identifier (do not expose credentials):**  
**Evidence files:**

### Question
What security question did this mission investigate?

### Prediction (record before experiment)
What do you expect, and which OS rule or mechanism leads you to expect it?

### Experiment
Commands and source/build details used:

### Observation (actual output only)
What did the target actually do? Include differences from the prediction and link the exact output/screenshot. If not run, write “Not run” and the reason.

### Concept
Which operating-system concept explains this observation?

### Defense
Which control is relevant, and what risk does it address?

### Verification
What same check demonstrated the control’s effect? If not run, say so.

### Reflection
What would be at risk if the control were absent, and what limitation remains?

---

## Mission-specific evidence reminders

- **M1:** Include `id` plus C UID/GID output; explain authentication versus authorization; record two example attack surfaces without testing them.
- **M2:** Include `hello.txt` and the actual trace lines for `openat`/`open`, `write`, and `close`; add the application → system call → kernel → resource diagram.
- **M3:** Include the owned test PID, status fields, descriptor count, and extra field from `proc_inspector.sh`; stop the test process afterward.
- **M4:** Include the program PID/output and its actual `/proc/<PID>/maps`; add the labeled address-space diagram. Inspect only the process started for this mission.
- **M5:** Record at least three separate unsynchronized runs and one mutex-protected run; identify the critical section in the source. An unsynchronized run may happen to reach the expected count.
- **M6:** Record pipe output, compare pipe and shared memory, and state the proposed endpoint/message control. If using `shared_memory_ipc.c`, label it as the team-authored substitute; the instructor example was absent from the supplied PDFs.

## Status before target access

No target observations are prefilled in this template. The evidence runner records real terminal output after it is executed on the approved Ubuntu target. It does not generate screenshots; capture those separately if required by the instructor.
