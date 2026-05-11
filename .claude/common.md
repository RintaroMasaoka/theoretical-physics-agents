# Worker Common Rules

These rules are shared by execution-tier workers that write reviewable submissions (`researcher`, `simulator`, `reader`, `scout`, `engine-builder`, `concept-checker`, and similar worker roles). Research planner, curator, critic, session-wrap-up, and other scheduler/maintenance roles read this file for shared conventions, but their role-specific prompts override this file's worker-submission output contract.

## Inter-Agent Communication

The dispatcher provides file paths rather than inline data. Read only the sections you need from those files — this keeps both your caller's and your context windows efficient.

`_materials/` paths are durable materials, not default context. For discovery, prefer `node .scripts/material-index.mjs research/{path}`: it prints material front matter and short descriptions without exposing full bodies. Open a specific material only under the gated rules in `.claude/research-tree.md` § `_materials/` context-loading rule: when assigned, linked, targeted for review/promotion/reproduction, or needed for writing support; otherwise rely on interpreted surfaces first.

("Dispatcher" = the agent that launched you. In `/auto` this is the scheduler; in `/write` this is PI. You do not need to distinguish them — the dispatch prompt tells you what to do.)

- **Input**: Receive task instructions and file paths from the dispatcher; use Read to load the necessary data yourself
- **Output**: Write the worker submission to file and return `DONE: {worker submission path}` as the task return value. (The raw log is written alongside but does not need to be returned.)

## Worker Submissions and Logs

Review-eligible worker output is split into two identities:

1. **Worker submission**: the bounded candidate that critic or PI evaluates. In `/auto`, node-scoped worker submissions live at `research/{node path}/_reviews/{slug}/worker.md`; source-reading submissions live at `literature/_reviews/{id}/worker.md`. This is the review packet: claim, derivation, method, evidence, intended destination, scope, and links needed to evaluate it.

2. **Raw log**: a short process trace under `.logs/` — what you attempted, what you found, blockers encountered. This helps the human researcher audit workflow. It is not the critic target by default.

The worker submission starts with the review-contract front matter specified in `.claude/research-tree.md` § `_reviews/{slug}/` — Provisional Worker-Critic Transactions. Return `DONE: {worker submission path}` so the scheduler can dispatch critic on the bounded candidate. If a worker is explicitly marked `no-critic`, it may still write a submission for curator/PI, but it should state `intended_destination: none` or the appropriate non-reviewed destination honestly.

If your submission gives a short expression handle shape — repeated shorthand, heading/bullet key, diagnostic label, warning label, translated source term, or a name passed to curator/planner/workers as a reusable reference — add a compact `Naming decisions` section as specified in `.claude/naming.md`. Do not scan for glossary terms. If you reuse an unlicensed phrase from earlier context as a handle, license it here instead of silently promoting it.

**Raw log filename creation.** Run `bash .scripts/log-path.sh <agent-name> [<slug>]` through Bash and capture stdout — it returns an absolute path of the form `.logs/{YYMMDD_HHMM}_{agent-name}[_{slug}].md`. Put only the process trace there. Do not run `date` yourself; do not pre-name the log file.

Worker submissions and critic reviews are provisional transactions. In `/auto`, the scheduler auto-dispatches Provisional Review on every review-eligible `worker.md`. Critic writes `critic.md` in the same `_reviews/{slug}/` transaction directory and does not edit `worker.md` inline. If the orchestrator allows one repair loop, worker writes `repair.md` and critic writes `critic_rereview.md`; then the loop stops. Curator reads the transaction before absorbing any evidence into the research tree. When curator later requests Durable Surface Review for touched findings.md or `_materials/analyses/*.md` surfaces, the scheduler dispatches critic on that durable surface and returns the review to curator for provenance closure (see `.claude/research-tree.md`). In `/write`, PI independently verifies submissions before integrating them into the paper.

## Heartbeat — Preventing Stream Idle Timeout

Long investigations sometimes hang at the streaming layer when the agent goes silent for minutes between tool calls. Prevent this by keeping a light narration flowing, without bloating the worker submission or output file:

- **Before a heavy tool call, emit one short sentence in the assistant message** (the text returned to the dispatcher, **not** the markdown written via Write into the worker submission or output file) explaining what you are about to do. Heavy = Agent dispatches, Read of a long file, any Bash command you have no reason to expect will return instantly, or a batch of multiple searches. Example: "Reading §4 of `literature/papers/{arxiv_id}/{paper}.tex` to check the leading-order coefficient."
- **After the call returns, summarise the result in one line before moving on.** Example: "§4 confirms the coefficient; next I need to verify the sign against §5.2."
- For a **parallel batch** (e.g. 3 Agent or Read calls sent together in one assistant message), one narration line covering the whole batch is enough — not one per call.
- The narration is prose that follows the project output language rule (`japanese`), same as the worker submission or output body. Technical terms, LaTeX, paths stay as-is.
- Do not pad with filler. One concrete sentence per non-trivial step is enough. The purpose is to keep tokens flowing and let the dispatcher audit your thinking, not to describe trivialities.

Rationale: idle timeouts fire on silent gaps in the output stream, not on total output volume. A cheap one-line narration between non-trivial tool calls costs almost nothing in quality but decisively cuts timeout risk in long-running agents (researcher, critic, writer, simulator in particular).

## Constraints

- Write worker submissions, task outputs, and raw logs in **japanese** — this applies to the prose. Technical terms, proper nouns, and LaTeX mathematics may stay in their original language
- Write mathematics in LaTeX so that Markdown renderers pick it up:
    - Inline: `$...$`. Any raw variable or expression in prose must be wrapped
    - Display: `$$...$$`. Multi-line environments (`align`, `aligned`, `cases`, `matrix`, …) must sit **inside** the `$$...$$` wrapper
    - Do not use `\(...\)` or `\[...\]` as delimiters
    - Do not write a bare `\begin{env}...\end{env}` at the top level without wrapping it in `$$...$$`
- Do not request user input in any form; users are often away during `/auto` and `/write`. If the user initiates communication, answer only that message briefly and continue the assigned workflow unless the user redirects or stops the run
- No writing outside the project directory
