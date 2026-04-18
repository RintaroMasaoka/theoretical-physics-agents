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

- Write deliverables and logs in **{{ language }}** — this applies to the prose. Technical terms, proper nouns, and LaTeX mathematics may stay in their original language
- Write mathematics in LaTeX so that Markdown renderers pick it up:
    - Inline: `$...$`. Any raw variable or expression in prose must be wrapped
    - Display: `$$...$$`. Multi-line environments (`align`, `aligned`, `cases`, `matrix`, …) must sit **inside** the `$$...$$` wrapper
    - Do not use `\(...\)` or `\[...\]` as delimiters
    - Do not write a bare `\begin{env}...\end{env}` at the top level without wrapping it in `$$...$$`
- Do not request user input in any form (users are often away during `/run` and `/write`. However, you may respond if the user initiates communication)
- No writing outside the project directory
