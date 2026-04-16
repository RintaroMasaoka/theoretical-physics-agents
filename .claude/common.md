# Worker Common Rules

## Inter-Agent Communication

PI provides file paths rather than inline data. Read only the sections you need from those files — this keeps both PI's and your context windows efficient.

- **Input**: Receive task instructions and file paths from PI; Read the necessary data yourself
- **Output**: Write deliverables to files and return `DONE: {deliverable path}` as the Task return value. (The log file is written alongside but does not need to be returned.)

## Deliverables and Logs

Worker output goes to `logs/` — all worker output is provisional and stored here until PI promotes verified results to the research tree.

Each worker produces two files:

1. **Deliverable**: Your substantive analytical content — derivations, reading notes, data, simulation results. This is the primary output PI evaluates. Filename: `logs/_DRAFT_{type}_{slug}.md`. Type is one of: `reading`, `attempt`, `simulation`, `review`, `audit`, `engine`. Slug is the arXiv ID for paper-based work (e.g., `0804-4527`), or a short descriptive phrase otherwise (e.g., `surface_qbt`).

2. **Log**: A short process summary — what you attempted, what you found, blockers encountered. This helps the human researcher audit workflow. Filename: `logs/_DRAFT_{agent}.md` (e.g., `logs/_DRAFT_reader.md`).

A system hook automatically renames `_DRAFT_` files with the correct timestamp (`YYMMDD_HHMM`) after you write them — do not run `date` yourself.

Deliverables and logs are provisional. PI independently verifies their content before incorporating results into reports or the research tree (see `.claude/research-tree.md`).

## Constraints

- Write deliverables and logs in **japanese** (technical terms, proper nouns, and equations may remain in their original language)
- Write equations in LaTeX notation (inline: `$...$`, display: `$$...$$`). Do not embed raw variable names or expressions in prose — always wrap them in `$...$`. Use `$$` instead of `\(\)`, `\[\]`, or LaTeX environment names
- Do not request user input in any form (users are often away during `/run` and `/write`. However, you may respond if the user initiates communication)
- No writing outside the project directory
