---
name: run
description: "Autonomously execute research cycles. Specify the cycle limit as an argument (e.g., /run 2). Default: 5."
user-invocable: true
---

# /run — Research Cycle Scheduler

`/run` is the **thin scheduler** that drives research forward. It owns no scientific judgment of its own. Each cycle, it dispatches the agent team in a fixed sequence; every substantive decision (what to investigate, what to record, what to verify) is delegated.

The team and who owns what:

| Role | Agent | Owns |
|---|---|---|
| **Direction** | `physicist` | `research/focus.md` — reads the tree, decides the next question, expresses it as a cursor + dispatch plan + tree directives |
| **Record** | `curator` | All tree writes — log.md (Evidence + Current State), plan.md, node creation / status / close / reframe, `report_{slug}.md` promotion, retraction, `dead_ends.md`, note.md (SoT) |
| **Verification** | `critic` | Independent review of every worker deliverable and of curator's note.md lifts |
| **Execution** | researcher / simulator / reader / scout / engine-builder / concept-checker / self-check | Bounded tasks producing deliverables in `logs/` |
| **Session finalisation** | `session-wrap-up` | Mechanical transcription of physicist's wrap-up-input file into session log / focus / last_session / agenda; commit + push |

`/run` itself owns only: the cycle loop, the resume beacon, parallel worker dispatch, auto-attaching critic to each worker, dispatching curator once per cycle with the right inputs, and handing session end to `session-wrap-up`.

## Constraints

- **Write all prose in japanese.** Applies to `research/focus.md`, `logs/`, `agenda.md`, curator's tree writes, all worker deliverables. Technical terms, proper nouns, LaTeX mathematics, file/folder slugs, frontmatter keys, and the structural `##` headings documented in `.codex/research-tree.md` and here may stay in English. The rule is about body prose, not structural tokens.
- `AskUserQuestion` and all other user-input solicitations are prohibited. Users are often away during `/run`; asking blocks the session. Text output to the user is limited to the final report emitted at Session End.
- If the user initiates communication mid-session, respond and continue. Corrections from the user take precedence over scheduled dispatches.
- **`Bash("sleep ...")` is prohibited; polling via `Bash("ls ...")` file-existence checks is prohibited.** For waiting on agent completion use only Pattern A or Pattern B as defined in `phases/dispatch.md`.
- Full paper text is acquired only from arXiv.
- **Paper writing is NOT `/run`'s responsibility.** Writing is handled by the `/write` skill. `/run` drives research only.

## Turn-Yielding Discipline

`/run` is an autonomous loop: the user is not present between cycles, and a closing-tone message mid-run stalls the run waiting for input that never arrives. The failure mode seen in practice: after a compaction or transient interruption, the model wraps up with "cycles 1–N complete, awaiting next instruction" and the run halts with cycles on the budget.

- **Never end a turn mid-run with a user-facing progress report.** Between cycles, the next action is a tool call — the next physicist dispatch, the next worker batch, or Session End. If you are tempted to draft "I have finished cycle N of M; continuing with cycle N+1?", that is the stall — replace it with the actual next dispatch.
- The **only** user-facing closing message is the final Session End report, emitted when `MAX_CYCLES` is exhausted or physicist returns `Status: session_complete`.
- Compaction / reconnect / crash do not terminate a run. The `logs/.run-active` beacon (written at the start of every cycle) and the `SessionStart` hook jointly ensure the next session resumes the loop without a greeting. See `phases/session-lifecycle.md` § Resume for the mechanics and the fallback.
- Progress summaries that genuinely belong somewhere go into `logs/{timestamp}_run.md` (session log, written by `session-wrap-up` from physicist's wrap-up input) or `research/focus.md § Context` (physicist's next-cycle direction). Neither is a yielded turn.

## Arguments

`/run {N}` — cycle limit. Default: 5. Hereafter `MAX_CYCLES`.

## Terminology

| Term | Meaning |
|---|---|
| **Session** | One `/run` execution — from start to final report |
| **Cycle** | One iteration of the scheduler loop (physicist → workers → critic → curator) |
| **Task** | One `Agent` tool call |

One session = up to `MAX_CYCLES` cycles. Multiple tasks can run in parallel within a cycle.

---

## Phase Index

Detail lives in two phase files; read on demand, not all at once.

| File | Loaded when | Purpose |
|---|---|---|
| `phases/dispatch.md` | When launching workers or critic | Pattern A / B launch methods, prompt template, auto-critic rule, per-agent dynamic data |
| `phases/session-lifecycle.md` | Session Start and Session End | Resume check, initial sanity check, scheduler-owned session-end mechanical steps (simulation housekeeping, final sweeps), wrap-up input handoff |

The research information model (tree structure, file roles, context scoping, provenance taxonomy) is canonical in `.codex/research-tree.md` — physicist and curator Read it at every dispatch. `/run` itself does not need it in working memory; `/run` reads `research/focus.md` (the dispatch-spec file — treat it as the scheduler's interface with physicist, not as "tree content") only to extract the fields it dispatches on. `/run` never reads node-level files — `log.md`, `plan.md`, `note.md`, `dead_ends.md`, `report_*.md` are exclusively for physicist (read) and curator (read/write).

---

## Session Start

Read `phases/session-lifecycle.md` § Session Start. Key outcomes:

- Beacon-based resume decision (fresh vs. resume mid-cycle)
- Initial sanity gates: `research/log.md` must exist (else "Please /launch first" and stop); `concepts/` exists; `.gitignore` covers `logs/.run-active`
- `research/focus.md` existence check (if missing, the first physicist dispatch initialises it — see session-lifecycle)

`/run` does **not** read node-level tree files at session start. The ancestor-chain read is physicist's responsibility and happens at the start of every cycle (so physicist's context always reflects the post-cycle state, not a stale session-start snapshot).

---

## Cycle Loop

Repeat up to `MAX_CYCLES`. At each iteration:

### 0. Beacon

Overwrite `logs/.run-active` with:

```json
{"remaining": <MAX_CYCLES - cycles_done>, "max_cycles": <MAX_CYCLES>}
```

This is the resume beacon read at Session Start (see `phases/session-lifecycle.md`). Writing it every cycle (not just at session start) means that after a mid-cycle compaction, `remaining` reflects what is owed.

### 1. Physicist Dispatch — Direction

```
Agent(subagent_type="physicist", prompt="""
## Task
Update research/focus.md for the next cycle.

## Recent Deliverables
{paths to worker deliverables produced in the previous cycle, if any}

## Critic Verdicts
{paths to critic outputs from the previous cycle, if any}

## Curator Sweep
{path to curator's output from the previous cycle, if any}
""")
```

On the very first cycle of a session, `Recent Deliverables` / `Critic Verdicts` / `Curator Sweep` are empty (no previous cycle); the physicist initialises from `research/focus.md` and the tree. If `research/focus.md` does not yet exist, include a note in the prompt: `focus.md missing — initialise at research/ root`.

Physicist returns `DONE: research/focus.md`. If it returns `FAILED:`, re-dispatch once with the failure message appended to the prompt. If the second attempt also fails, exit to Session End with a partial report — deciding *why* a failure is recoverable is research judgment, so the scheduler bounds the loop mechanically rather than classifying the failure.

### 2. Parse `research/focus.md`

Before overwriting, remember the **previous cursor** (the `Cursor:` line in the focus.md that physicist just replaced). The scheduler reads focus.md twice in the cycle: once before the physicist dispatch (step 1) to capture the previous cursor, and once after to parse the new directives.

Read the new `research/focus.md`. Extract:

- **Cursor** — the path into the tree (for context when forming worker prompts)
- **Previous cursor** — carried from the pre-dispatch read above
- **Status** — `active` or `session_complete`
- **Retrospect** — `auto`, `skip — {reason}`, or absent
- **Worker Dispatches** — list of `{agent}: {task}` entries
- **Tree Directives** — list of directives for curator
- **Blockers** — informational

If `Status: session_complete` → proceed to Session End (skip remaining cycles).

**Ascent detection.** Compare the new cursor to the previous cursor:

- New cursor is the previous cursor's **immediate parent** (exactly one edge shorter) → **ascent**.
- Otherwise (same, descended into a child, sibling jump, multi-edge upward jump, initial cycle with no previous, or physicist-FAILED recovery that reset cursor to root) → **not ascent**.

The stricter "immediate parent" rule (rather than any proper-prefix) is deliberate. Retrospect reads the new cursor's direct children, so dispatching it after a multi-edge upward jump would have it read children irrelevant to the cycle's subject, and dispatching it after a cursor-reset-to-root recovery (physicist.md § Return Value's FAILED fallback) would have it retrospect at a node physicist did not reach by scientific judgment. Both cases are non-ascents by design; retrospect does not fire. A multi-edge jump additionally violates physicist's one-edge rule — that is a physicist-level problem, not something the scheduler auto-remediates.

### 2.5. Retrospect Auto-Attach on Ascent

If step 2 flagged **ascent** and the `Retrospect` field is `auto` (or absent — default is auto on ascent), dispatch the `retrospect` agent per `phases/dispatch.md` § Retrospect Auto-Attach. Retrospect runs at the new (parent) cursor and returns `DONE: {path}` where `{path}` is `logs/{YYMMDD_HHMM}_retrospect_{node-slug}.md` (obtained by retrospect via `bash .scripts/new-log.sh retrospect {node-slug}` at its start). The scheduler captures the path from the return value and adds it to the curator input's `## New Evidence This Cycle` list in step 5 (it is evidence for the subtree's meaning, in the same way a worker deliverable is evidence for a claim).

If `Retrospect: skip — {reason}` is set, honour the skip: no retrospect dispatch this cycle. The scheduler does not enforce what counts as a valid reason — that check is physicist's in the next cycle's review of its own focus.md.

If not ascent, skip this step entirely.

Retrospect runs in **parallel** with the worker dispatch in step 3 whenever both are non-empty — retrospect reads the tree only, worker dispatches produce new claims, neither blocks the other. Use a single-message multi-tool call.

### 3. Worker Dispatch — Parallel

If `Worker Dispatches` is non-empty, launch all workers in parallel per `phases/dispatch.md` (Pattern A by default).

Each worker's prompt follows the template in `phases/dispatch.md` § Prompt Template — the scheduler fills in task-specific fields from the physicist's dispatch entries, plus the cursor path for context.

If `Worker Dispatches` is empty, skip this step. A structural-review cycle (only Tree Directives) is legitimate.

### 4. Critic — Auto-Attach

For every worker deliverable returned in step 3, dispatch a critic (Target A — attempt inline annotation) per `phases/dispatch.md` § Auto-Critic Rule. Critic runs in blind mode by default for deliverables that are mechanical/mathematical (researcher attempts, simulator runs), contextual mode when the deliverable's soundness depends on the research narrative (reader summaries, scout surveys). The rule for mode selection is in `phases/dispatch.md`.

Worker deliverables skipped from critic: none by default. Physicist may in rare cases mark a dispatch as "no-critic" in `### Worker Dispatches` (e.g., an engine-builder refactor with no substantive claim to verify); honour such markings.

Critic writes its verdict inline into the worker's deliverable file (Target A). Collect the set of annotated deliverable paths for step 5.

### 5. Curator Dispatch — Execute Tree Changes

Dispatch curator once per cycle with:

```
Agent(subagent_type="curator", prompt="""
## Task
Execute the tree directives below and absorb the new evidence (worker deliverables + critic verdicts) into the tree per your own operating rules.

## Tree Directives (from physicist, this cycle)
{verbatim copy of focus.md § Tree Directives}

## New Evidence This Cycle
- {worker deliverable path} — critic verdict: {ACCEPT / REVISE / REJECT}, critic file: {same path, end section}
- ...

## Context
Cursor: {cursor path from focus.md}
Session cycle: {cycle_number} of {MAX_CYCLES}
""")
```

Curator reads the deliverables, critic verdicts, and tree state; executes the directives; updates log.md / plan.md / note.md / status / report_*.md / dead_ends.md per its own operating rules; returns `DONE: {summary}`.

If curator returns with REVISE or REJECT critic verdicts unresolved — i.e., a worker deliverable whose critic verdict is REVISE means the worker should be re-dispatched next cycle — curator flags these in its return. The scheduler records the flag; physicist sees the flagged deliverables in the next cycle's prompt (step 1 `Recent Deliverables` and `Critic Verdicts`) and decides whether to re-dispatch.

### 6. Cycle End

Increment `cycles_done`. If `cycles_done < MAX_CYCLES` and `Status` is still `active`, loop to step 0. Else proceed to Session End.

---

## Session End

Read `phases/session-lifecycle.md` § Session End. Summary:

1. **Simulation housekeeping** — if simulator ran, `/run` checks `research/**/src/` for superseded scripts and moves them to `src/archive/`. This is a mechanical step (physicist judges which are superseded — express as Tree Directives in the final focus.md — but the `mv` itself is scheduler-level).
2. **Final curator sweep** — dispatch curator once more with an empty `Tree Directives` list and the accumulated evidence, asking for a tree-wide coherence pass (per curator's own session-end mandate).
3. **Pivot-review dispatch** — dispatch the `pivot-review` agent once. Reads the whole tree and this session's logs; writes a 5-slot forcing artifact (direction restatement, wandering candidates, direction dependencies, adjacent pivots, flag for PI) to a path it obtained via `bash .scripts/new-log.sh pivot-review` and returned as `DONE: {path}`. Mandatory — not skippable on "nothing felt interesting this session" grounds. Capture the returned path and pass it to step 4 as evidence.
4. **Final physicist dispatch (session-end mode)** — physicist writes the wrap-up-input file (path obtained via `bash .scripts/new-log.sh wrap-up-input` and returned as `DONE: {path}`), consulting the pivot-review output when shaping the next session's Focus and any `## Agenda` items. Capture the returned path for step 5.
5. **`session-wrap-up` dispatch** — the agent consumes the wrap-up-input file (path passed in the dispatch prompt), writes `research/focus.md` / `logs/last_session.md` / a session log file (path obtained via `bash .scripts/new-log.sh run`) / `agenda.md`, deletes `logs/.run-active`, commits, pushes. Returns `DONE: committed {hash}` or `FAILED: {reason}`.
6. **Final report to user** — emit the session summary to the user. This is the **only** user-facing closing message (per Turn-Yielding Discipline). Yield after emitting.
