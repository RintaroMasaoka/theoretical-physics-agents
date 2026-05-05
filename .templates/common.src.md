# Worker Common Rules

## Inter-Agent Communication

The dispatcher provides file paths rather than inline data. Read only the sections you need from those files — this keeps both your caller's and your context windows efficient.

("Dispatcher" = the agent that launched you. In `/auto` this is the scheduler; in `/write` this is PI. You do not need to distinguish them — the dispatch prompt tells you what to do.)

- **Input**: Receive task instructions and file paths from the dispatcher; use {{ runtime.tool_read }} to load the necessary data yourself
- **Output**: Write deliverables to files and return `DONE: {deliverable path}` as the task return value. (The log file is written alongside but does not need to be returned.)

## Deliverables and Logs

Worker output goes to `.logs/` — all worker output is provisional and stored there until downstream agents verify it (auto-critic in `/auto`, PI review in `/write`) and incorporate the verified result into the research tree or paper.

Each worker produces two files:

1. **Deliverable**: Your substantive analytical content — derivations, reading notes, data, simulation results, or concept-note proposals. This is the primary output the critic (in `/auto`) or PI (in `/write`) evaluates. Type is one of: `reading`, `attempt`, `simulation`, `review`, `audit`, `engine`, `concept`. Slug is the arXiv ID for paper-based work (e.g., `0804-4527`), or a short descriptive phrase otherwise (e.g., `surface_qbt`).

2. **Log**: A short process summary — what you attempted, what you found, blockers encountered. This helps the human researcher audit workflow. Type is the agent name (`reader`, `researcher`, etc.); no slug.

**Filename creation.** Run `bash .scripts/log-path.sh <type> [<slug>]` through {{ runtime.tool_shell }} and capture stdout — it returns an absolute path of the form `.logs/{YYMMDD_HHMM}_{type}[_{slug}].md`. Then use {{ runtime.tool_write }} to put your content at that path. Do not run `date` yourself; do not pre-name the file. The timestamp is fixed at the moment of the script call, so naming is authoritative from creation — there is no downstream rename step that can fail and leave an orphan file behind.

Deliverables and logs are provisional. In `/auto`, the scheduler auto-dispatches a critic on every deliverable, and curator then absorbs the verified evidence into the research tree (see `{{ runtime.research_tree_file }}`). In `/write`, PI independently verifies deliverables before integrating them into the paper.

## Heartbeat — Preventing Stream Idle Timeout

Long investigations sometimes hang at the streaming layer when the agent goes silent for minutes between tool calls. Prevent this by keeping a light narration flowing, without bloating the deliverable:

- **Before a heavy tool call, emit one short sentence in the assistant message** (the text returned to the dispatcher, **not** the markdown written via {{ runtime.tool_write }} into the deliverable file) explaining what you are about to do. Heavy = {{ runtime.tool_agent }} dispatches, {{ runtime.tool_read }} of a long file, any {{ runtime.tool_shell }} command you have no reason to expect will return instantly, or a batch of multiple searches. Example: "Reading §4 of `literature/papers/{arxiv_id}/{paper}.tex` to check the leading-order coefficient."
- **After the call returns, summarise the result in one line before moving on.** Example: "§4 confirms the coefficient; next I need to verify the sign against §5.2."
- For a **parallel batch** (e.g. 3 {{ runtime.tool_agent }} or {{ runtime.tool_read }} calls sent together in one assistant message), one narration line covering the whole batch is enough — not one per call.
- The narration is prose that follows the project output language rule (`{{ language }}`), same as the deliverable body. Technical terms, LaTeX, paths stay as-is.
- Do not pad with filler. One concrete sentence per non-trivial step is enough. The purpose is to keep tokens flowing and let the dispatcher audit your thinking, not to describe trivialities.

Rationale: idle timeouts fire on silent gaps in the output stream, not on total output volume. A cheap one-line narration between non-trivial tool calls costs almost nothing in quality but decisively cuts timeout risk in long-running agents (researcher, critic, writer, simulator in particular).

## Constraints

- Write deliverables and logs in **{{ language }}** — this applies to the prose. Technical terms, proper nouns, and LaTeX mathematics may stay in their original language
- Write mathematics in LaTeX so that Markdown renderers pick it up:
    - Inline: `$...$`. Any raw variable or expression in prose must be wrapped
    - Display: `$$...$$`. Multi-line environments (`align`, `aligned`, `cases`, `matrix`, …) must sit **inside** the `$$...$$` wrapper
    - Do not use `\(...\)` or `\[...\]` as delimiters
    - Do not write a bare `\begin{env}...\end{env}` at the top level without wrapping it in `$$...$$`
- Do not request user input in any form (users are often away during `/auto` and `/write`. However, you may respond if the user initiates communication)
- No writing outside the project directory
