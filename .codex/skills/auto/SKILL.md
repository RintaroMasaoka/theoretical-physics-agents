---
name: auto
description: "Autonomously execute research cycles. Specify the cycle limit as an argument (e.g., /auto 2). Default: 5."
user-invocable: true
---

# /auto — Research Cycle Scheduler

`/auto` is the **thin scheduler** that drives research forward. It owns no scientific judgment of its own. Each cycle, it dispatches the agent team in a fixed sequence; every substantive decision (what to investigate, what to record, what to verify) is delegated.

The team and who owns what:

| Role | Agent | Owns |
|---|---|---|
| **Direction challenge** | `direction-challenger` | Pre-direction opposition: challenges value, goal, necessity, frame, scale, authority, and inertia anchors before the direction hardens |
| **Direction** | `research-planner` | `research/focus.md` — reads the tree, decides the next question, expresses it as a cursor + dispatch plan + tree directives |
| **Tree transaction** | `curator` | Graph/lifecycle/placement, state.md absorbed evidence, plan.md consistency, conventions/checks placement, report placement/promotion, retraction, `dead_ends.md`, and current-runtime note.md fact transactions |
| **Verification** | `critic` | Independent review of every worker deliverable and of note.md fact-layer lifts |
| **Execution** | researcher / simulator / reader / scout / engine-builder / concept-checker / self-check | Bounded tasks producing provisional deliverables in `.logs/` or direct review output as specified by their agent prompt |
| **Session finalisation** | `session-wrap-up` | Mechanical transcription of research planner's wrap-up-input file into session log / focus / last_session / node-scoped backlog.md / agenda; commit + push |

`/auto` itself owns only: the cycle loop, the resume beacon, pre-direction challenge dispatch, parallel worker dispatch, auto-attaching critic to each worker, dispatching curator once per cycle with the right inputs, and handing session end to `session-wrap-up`.

## Constraints

- **Write all prose in japanese.** Applies to `research/focus.md`, `.logs/`, `agenda.md`, curator's tree writes, all worker deliverables. Technical terms, proper nouns, LaTeX mathematics, file/folder slugs, frontmatter keys, and the structural `##` headings documented in `.codex/research-tree.md` and here may stay in English. The rule is about body prose, not structural tokens.
- `request_user_input` and all other user-input solicitations are prohibited. Users are often away during `/auto`; asking blocks the session. Text output to the user is limited to the final report emitted at Session End.
- If the user initiates communication mid-session, respond and continue. Corrections from the user take precedence over scheduled dispatches.
- **`exec_command("sleep ...")` is prohibited; polling via `exec_command("ls ...")` file-existence checks is prohibited.** For waiting on agent completion use only Pattern A or Pattern B as defined in `phases/dispatch.md`.
- Full paper text is acquired only from arXiv.
- **Paper writing is NOT `/auto`'s responsibility.** Writing is handled by the `/write` skill. `/auto` drives research only.

## Turn-Yielding Discipline

`/auto` is an autonomous loop: the user is not present between cycles, and a closing-tone message mid-run stalls the run waiting for input that never arrives. The failure mode seen in practice: after a compaction or transient interruption, the model wraps up with "cycles 1–N complete, awaiting next instruction" and the run halts with cycles on the budget.

- **Never end a turn mid-run with a user-facing progress report.** Between cycles, the next action is a tool call — the next direction-challenger dispatch, the next research planner dispatch, the next worker batch, or Session End. If you are tempted to draft "I have finished cycle N of M; continuing with cycle N+1?", that is the stall — replace it with the actual next dispatch.
- The **only** user-facing closing message is the final Session End report, emitted when `MAX_CYCLES` is exhausted or research planner returns `Status: session_complete`.
- Compaction / reconnect / crash do not terminate a run. The `.logs/.auto-active` beacon (written at the start of every cycle) and the `SessionStart` hook jointly ensure the next session resumes the loop without a greeting. See `phases/session-lifecycle.md` § Resume for the mechanics and the fallback.
- Progress summaries that genuinely belong somewhere go into `.logs/{timestamp}_auto.md` (session log, written by `session-wrap-up` from research planner's wrap-up input) or `research/focus.md § Context` (research planner's next-cycle direction). Neither is a yielded turn.

## Arguments

`/auto {N}` — cycle limit. Default: 5. Hereafter `MAX_CYCLES`.

## Terminology

| Term | Meaning |
|---|---|
| **Session** | One `/auto` execution — from start to final report |
| **Cycle** | One iteration of the scheduler loop (direction-challenger → research planner → workers → critic → curator) |
| **Task** | One `spawn_agent` tool call |

One session = up to `MAX_CYCLES` cycles. Multiple tasks can run in parallel within a cycle.

---

## Phase Index

Detail lives in two phase files; read on demand, not all at once.

| File | Loaded when | Purpose |
|---|---|---|
| `phases/dispatch.md` | When launching workers or critic | Pattern A / B launch methods, prompt template, auto-critic rule, per-agent dynamic data |
| `phases/session-lifecycle.md` | Session Start and Session End | Resume check, initial sanity check, scheduler-owned session-end mechanical steps (simulation housekeeping, final sweeps), wrap-up input handoff |

The research information model (tree structure, file roles, context scoping, convention ledger, provenance taxonomy) is canonical in `.codex/research-tree.md` — direction-challenger, research planner, and curator read it at every dispatch. `/auto` itself does not need it in working memory; `/auto` reads `research/focus.md` (the dispatch-spec file — treat it as the scheduler's interface with research planner, not as "tree content") only to extract the fields it dispatches on. `/auto` never reads node-level files directly. Node-level files are read by direction-challenger in its narrow local challenge scope, by research planner for direction-setting, and by curator for tree writing.

---

## Session Start

Read `phases/session-lifecycle.md` § Session Start. Key outcomes:

- Beacon-based resume decision (fresh vs. resume mid-cycle)
- Initial sanity gates: `research/state.md` must exist (else "Please /launch first" and stop); `concepts/` exists; `.gitignore` covers `.logs/.auto-active`
- `research/focus.md` existence check (if missing, the first research planner dispatch initialises it after direction-challenger runs — see session-lifecycle)

`/auto` does **not** read node-level tree files at session start. The ancestor-chain read is research planner's responsibility and happens at the start of every cycle (so research planner's context always reflects the post-cycle state, not a stale session-start snapshot).

---

## Cycle Loop

Repeat up to `MAX_CYCLES`. At each iteration:

### 0. Beacon

Overwrite `.logs/.auto-active` with:

```json
{"remaining": <MAX_CYCLES - cycles_done>, "max_cycles": <MAX_CYCLES>}
```

This is the resume beacon read at Session Start (see `phases/session-lifecycle.md`). Writing it every cycle (not just at session start) means that after a mid-cycle compaction, `remaining` reflects what is owed.

### 1. Direction-Challenger Dispatch — Pre-Direction Opposition

```

spawn_agent(prompt="""
Read and follow `.codex/agents/direction-challenger.md` as your role definition. Treat the rest of this prompt as task-specific input.

## Task
Write the pre-direction challenge for this cycle. Obtain a path via `bash .scripts/log-path.sh direction-challenge` and return it as `DONE: {path}`.


## Previous-Cycle Material
Critic flags: {REVISE / REJECT flags from the previous cycle, if any; do not include raw deliverable paths unless needed to identify the flag}
Curator flags: {flagged-for-research planner-review items from the previous curator sweep, if any}
Curator sweep summary: {short summary or path, if available}

## Context
Session cycle: {cycle_number} of {MAX_CYCLES}
""")
```

The challenger reads only its narrow local scope and returns `DONE: {path}`. If it returns `FAILED:`, continue to research planner with `Direction Challenge: unavailable — {failure}`. The challenge is helpful but not load-bearing; research planner owns the decision.

### 2. Research planner Dispatch — Direction

Before dispatching research planner, run `node .scripts/literature-status.mjs --limit=8` if `literature/catalog.jsonl` exists. Pass the output verbatim in `## Literature Status`. This is scheduler-owned context condensation: research planner should see unread/read/fetch pressure automatically without spending direction-setting attention parsing the full catalog unless the summary makes literature decisive.

```

spawn_agent(prompt="""
Read and follow `.codex/agents/research-planner.md` as your role definition. Treat the rest of this prompt as task-specific input.

## Task
Update research/focus.md for the next cycle.


## Direction Challenge
{path returned by direction-challenger, or unavailable note}

## Recent Deliverables
{paths to worker deliverables produced in the previous cycle, if any}

## Critic Verdicts
{paths to critic outputs from the previous cycle, if any}

## Curator Sweep
{path to curator's output from the previous cycle, if any}

## Literature Status
{output of `node .scripts/literature-status.mjs --limit=8`, or "No literature catalog present"}
""")
```

On the very first cycle of a session, `Recent Deliverables` / `Critic Verdicts` / `Curator Sweep` are empty (no previous cycle); the research planner initialises from `research/focus.md` and the tree. If `research/focus.md` does not yet exist, include a note in the prompt: `focus.md missing — initialise at research/ root`.

Research planner returns `DONE: research/focus.md`. If it returns `FAILED:`, re-dispatch once with the failure message appended to the prompt. If the second attempt also fails, exit to Session End with a partial report — deciding *why* a failure is recoverable is research judgment, so the scheduler bounds the loop mechanically rather than classifying the failure.

### 3. Parse `research/focus.md`

Before overwriting, remember the **previous cursor** (the `Cursor:` line in the focus.md that research planner just replaced). The scheduler reads focus.md twice in the cycle: once before the research planner dispatch (step 2) to capture the previous cursor, and once after to parse the new directives.

Read the new `research/focus.md`. Extract:

- **Cursor** — the path into the tree (for context when forming worker prompts)
- **Previous cursor** — carried from the pre-dispatch read above
- **Status** — `active` or `session_complete`
- **Worker Dispatches** — list of `{agent}: {task}` entries
- **Tree Directives** — list of directives for curator
- **Blockers** — informational

If `Status: session_complete` → proceed to Session End (skip remaining cycles).

The scheduler does not auto-remediate cursor jumps. If research planner violates its one-edge cursor discipline, the next research planner dispatch must repair the direction; the scheduler only parses fields and continues.

### 4. Worker Dispatch — Parallel

If `Worker Dispatches` is non-empty, launch all workers in parallel per `phases/dispatch.md` (Pattern A by default).

Each worker's prompt follows the template in `phases/dispatch.md` § Prompt Template — the scheduler fills in task-specific fields from the research planner's dispatch entries, plus the cursor path for context.

If `Worker Dispatches` is empty, skip this step. A structural-review cycle (only Tree Directives) is legitimate.

### 5. Critic — Auto-Attach

For every worker deliverable returned in step 4, dispatch a critic (Target A — worker-deliverable inline annotation) per `phases/dispatch.md` § Auto-Critic Rule. Critic runs in blind mode by default for deliverables that are mechanical/mathematical (researcher attempts, simulator runs), source-audit mode for reader deliverables, and contextual mode when the deliverable's soundness depends on the research narrative (scout surveys, concept proposals). The rule for mode selection is in `phases/dispatch.md`.

Worker deliverables skipped from critic: none by default. Research planner may in rare cases mark a dispatch as "no-critic" in `### Worker Dispatches` (e.g., an engine-builder refactor with no substantive claim to verify); honour such markings.

Critic writes its verdict inline into the worker's deliverable file (Target A). Collect the set of annotated deliverable paths for step 6.

### 6. Curator Dispatch — Execute Tree Changes

Dispatch curator once per cycle with:

```

spawn_agent(prompt="""
Read and follow `.codex/agents/curator.md` as your role definition. Treat the rest of this prompt as task-specific input.

## Task
Execute the tree directives below and absorb the new evidence (worker deliverables + critic verdicts) into the tree per your own operating rules.


## Tree Directives (from research planner, this cycle)
{verbatim copy of focus.md § Tree Directives}

## New Evidence This Cycle
- {worker deliverable path} — critic verdict: {ACCEPT / REVISE / REJECT}, critic file: {same path, end section}
- ...

## Context
Cursor: {cursor path from focus.md}
Session cycle: {cycle_number} of {MAX_CYCLES}
""")
```

Curator reads the deliverables, critic verdicts, and tree state; executes the directives; absorbs raw outputs into state.md without `.logs/` links; updates plan.md / conventions.md / note.md / status / report_*.md / checks / dead_ends.md per its operating rules; returns `DONE: {summary}`.

If curator returns with unresolved REVISE or REJECT critic verdicts, curator flags these in its return. The scheduler records the flag; direction-challenger and research planner see the flagged deliverables in the next cycle's prompts, and research planner decides whether to re-dispatch, pivot, or close.

### 7. Cycle End

Increment `cycles_done`. If `cycles_done < MAX_CYCLES` and `Status` is still `active`, loop to step 0. Else proceed to Session End.

---

## Session End

Read `phases/session-lifecycle.md` § Session End. Summary:

1. **Simulation housekeeping decision** — if simulator ran, research planner may identify superseded scripts in final `research/focus.md` Tree Directives. Do not move them in the scheduler.
2. **Final curator sweep** — dispatch curator once more with the final Tree Directives and accumulated evidence, asking for a tree-wide coherence pass (per curator's own session-end mandate). Curator executes any `archive superseded script {path}` directives by moving the script and its companion `.md` to `src/archive/`.
3. **Final research planner dispatch (session-end mode)** — research planner writes the wrap-up-input file (path obtained via `bash .scripts/log-path.sh wrap-up-input` and returned as `DONE: {path}`), using the final curator sweep and this session's direction-challenge files as evidence for the next session's Focus and any `## Agenda` items. Capture the returned path for step 4.
4. **`session-wrap-up` dispatch** — the agent consumes the wrap-up-input file (path passed in the dispatch prompt), writes `research/focus.md` / `.logs/last_session.md` / a session log file (path obtained via `bash .scripts/log-path.sh auto`) / node-scoped `backlog.md` files / `agenda.md`, deletes `.logs/.auto-active`, commits, pushes. Returns `DONE: committed {hash}` or `FAILED: {reason}`.
5. **Final report to user** — emit the session summary to the user. This is the **only** user-facing closing message (per Turn-Yielding Discipline). Yield after emitting.
