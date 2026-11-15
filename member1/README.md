# Person 1 — SecureLab Missions 1–6

This folder contains the complete C and Bash sources, a runner for authentic terminal evidence, and the conceptual answers for Person 1's assigned missions. Mission 6 includes both the handout's pipe example and an additional team-authored POSIX shared-memory comparison; the latter is labeled as a team implementation because the supplied PDFs do not contain the instructor's referenced sample.

Run `bash member1/run_missions.sh` from the repository root on an approved Ubuntu lab machine. The script compiles its sources and records the machine's real output in `member1/evidence/`. It does not use sudo, modify system settings, read other users' process memory, or invent expected outputs. `strace` is optional; if it is missing, the script records that the trace is unavailable.

Use `notes/Missions_1-6_answers.md` for answers to questions 1–18, the IPC comparison, and required diagrams. Use `notes/mission_evidence_template.md` to record the question/prediction/experiment/observation/concept/defense/verification/reflection for each mission. Add actual screenshots or other requested evidence after running on the authorized target. The runner labels the shared-memory output as the team-authored example, not as instructor-provided material.
