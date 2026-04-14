# Worker Common Rules

## Inter-Agent Communication

PI provides file paths rather than inline data. Read only the sections you need from those files — this keeps both PI's and your context windows efficient.

- **Input**: Receive task instructions and file paths from PI; Read the necessary data yourself
- **Output**: Write deliverables to files and return `DONE: {deliverable path}` as the Task return value

## Logs (Progress Records for Humans)

Capture a session timestamp at start: `Bash("date '+%y%m%d_%H%M'")` (e.g., `260413_1530`). Use this for both the log filename and the deliverable filename.

Write a work summary to `logs/{timestamp}_{agent}.md` (e.g., `logs/260413_1530_reader.md`). The deliverable contains your analytical output. The log is a brief narrative summary of what you did, what you found, and any issues encountered — it helps the human researcher audit the research process. Logs are not a decision input for PI.

## Constraints

- Write deliverables and logs in **japanese** (technical terms, proper nouns, and equations may remain in their original language)
- Write equations in LaTeX notation (inline: `$...$`, display: `$$...$$`). Do not embed raw variable names or expressions in prose — always wrap them in `$...$`. Use `$$` instead of `\(\)`, `\[\]`, or LaTeX environment names
- Do not request user input in any form (users are often away during `/run` and `/write`. However, you may respond if the user initiates communication)
- No writing outside the project directory
