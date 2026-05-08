# Worker Common Rules

## Inter-Agent Communication

The dispatcher provides file paths rather than inline data. Read only the sections you need from those files — this keeps both your caller's and your context windows efficient.

`_materials/` paths are durable materials, not default context. For discovery, prefer `node .scripts/material-index.mjs research/{path}`: it prints material front matter and short descriptions without exposing full bodies. Open a specific material only under the gated rules in `{{ runtime.research_tree_file }}` § `_materials/` context-loading rule: when assigned, linked, targeted for review/promotion/reproduction, or needed for writing support; otherwise rely on interpreted surfaces first.

("Dispatcher" = the agent that launched you. In `/auto` this is the scheduler; in `/write` this is PI. You do not need to distinguish them — the dispatch prompt tells you what to do.)

- **Input**: Receive task instructions and file paths from the dispatcher; use {{ runtime.tool_read }} to load the necessary data yourself
- **Output**: Write the worker submission to file and return `DONE: {worker submission path}` as the task return value. (The raw log is written alongside but does not need to be returned.)

## Worker Submissions and Logs

Review-eligible worker output is split into two identities:

1. **Worker submission**: the bounded candidate that critic or PI evaluates. In `/auto`, node-scoped worker submissions live at `research/{node path}/_reviews/{slug}/worker.md`; source-reading submissions live at `literature/_reviews/{id}/worker.md`. This is the review packet: claim, derivation, method, evidence, intended destination, scope, and links needed to evaluate it.

2. **Raw log**: a short process trace under `.logs/` — what you attempted, what you found, blockers encountered. This helps the human researcher audit workflow. It is not the critic target by default.

The worker submission starts with the review-contract front matter specified in `{{ runtime.research_tree_file }}` § `_reviews/{slug}/` — Provisional Worker-Critic Transactions. Return `DONE: {worker submission path}` so the scheduler can dispatch critic on the bounded candidate. If a worker is explicitly marked `no-critic`, it may still write a submission for curator/PI, but it should state `intended_destination: none` or the appropriate non-reviewed destination honestly.

**Raw log filename creation.** Run `bash .scripts/log-path.sh <agent-name> [<slug>]` through {{ runtime.tool_shell }} and capture stdout — it returns an absolute path of the form `.logs/{YYMMDD_HHMM}_{agent-name}[_{slug}].md`. Put only the process trace there. Do not run `date` yourself; do not pre-name the log file.

Worker submissions and critic reviews are provisional transactions. In `/auto`, the scheduler auto-dispatches Provisional Review on every review-eligible `worker.md`. Critic writes `critic.md` in the same `_reviews/{slug}/` transaction directory and does not edit `worker.md` inline. If the orchestrator allows one repair loop, worker writes `repair.md` and critic writes `critic_rereview.md`; then the loop stops. Curator reads the transaction before absorbing any evidence into the research tree. When curator later requests Durable Surface Review for touched findings.md or `_materials/analyses/*.md` surfaces, the scheduler dispatches critic on that durable surface and returns the review to curator for provenance closure (see `{{ runtime.research_tree_file }}`). In `/write`, PI independently verifies submissions before integrating them into the paper.

## Heartbeat — Preventing Stream Idle Timeout

Long investigations sometimes hang at the streaming layer when the agent goes silent for minutes between tool calls. Prevent this by keeping a light narration flowing, without bloating the worker submission or output file:

- **Before a heavy tool call, emit one short sentence in the assistant message** (the text returned to the dispatcher, **not** the markdown written via {{ runtime.tool_write }} into the worker submission or output file) explaining what you are about to do. Heavy = {{ runtime.tool_agent }} dispatches, {{ runtime.tool_read }} of a long file, any {{ runtime.tool_shell }} command you have no reason to expect will return instantly, or a batch of multiple searches. Example: "Reading §4 of `literature/papers/{arxiv_id}/{paper}.tex` to check the leading-order coefficient."
- **After the call returns, summarise the result in one line before moving on.** Example: "§4 confirms the coefficient; next I need to verify the sign against §5.2."
- For a **parallel batch** (e.g. 3 {{ runtime.tool_agent }} or {{ runtime.tool_read }} calls sent together in one assistant message), one narration line covering the whole batch is enough — not one per call.
- The narration is prose that follows the project output language rule (`{{ language }}`), same as the worker submission or output body. Technical terms, LaTeX, paths stay as-is.
- Do not pad with filler. One concrete sentence per non-trivial step is enough. The purpose is to keep tokens flowing and let the dispatcher audit your thinking, not to describe trivialities.

Rationale: idle timeouts fire on silent gaps in the output stream, not on total output volume. A cheap one-line narration between non-trivial tool calls costs almost nothing in quality but decisively cuts timeout risk in long-running agents (researcher, critic, writer, simulator in particular).

## Constraints

- Write worker submissions, task outputs, and raw logs in **{{ language }}** — this applies to the prose. Technical terms, proper nouns, and LaTeX mathematics may stay in their original language
- Write mathematics in LaTeX so that Markdown renderers pick it up:
    - Inline: `$...$`. Any raw variable or expression in prose must be wrapped
    - Display: `$$...$$`. Multi-line environments (`align`, `aligned`, `cases`, `matrix`, …) must sit **inside** the `$$...$$` wrapper
    - Do not use `\(...\)` or `\[...\]` as delimiters
    - Do not write a bare `\begin{env}...\end{env}` at the top level without wrapping it in `$$...$$`
- Do not request user input in any form; users are often away during `/auto` and `/write`. If the user initiates communication, answer only that message briefly and continue the assigned workflow unless the user redirects or stops the run
- No writing outside the project directory
