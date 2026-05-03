# Phase: Session Lifecycle

This phase file is a reference that `/run` Reads at Session Start and Session End. It covers the resume-check logic, the initial sanity gates, the session-end steps the scheduler owns directly, and the hand-off to `session-wrap-up`.

The cycle loop between Session Start and Session End is purely mechanical (direction-challenger → research planner → workers → critic → curator → loop) and lives in `SKILL.md § Cycle Loop`. This file covers only the lifecycle bookends.

---

## Session Start

Execute in order.

### 0. Resume Check — `.logs/.run-active` beacon

The beacon is written at the start of every cycle (SKILL § step 0). Its presence at session start means a prior run was mid-cycle when interrupted (compaction, crash, reconnect). Rules:

- **If the user invoked `/run {N}` with an explicit `N`, the explicit value wins**: treat as fresh session regardless of beacon state, delete any existing beacon. (Explicit invocation signals new intent.)
- **If `/run` was invoked without an argument** (`MAX_CYCLES` defaults to `5`), consult the beacon:
  - File exists, `remaining > 0`, **not stale** → resume after interruption. Set `MAX_CYCLES := remaining`, skip any greeting, skip the initial sanity gates below (the prior session passed them), proceed directly to Cycle Loop step 0. Do not re-emit a welcome message.
  - File exists with `remaining <= 0` → prior session ended cleanly between the last cycle and Session End. Delete the beacon; treat as fresh start.
  - File exists but **stale** — mtime older than 24h, or a newer `.logs/*_run.md` exists → prior session is not truly in flight. Delete the beacon; treat as fresh start.
  - File does not exist → normal fresh start.

The beacon is gitignored (see `.gitignore`) and deleted at Session End by `session-wrap-up`. On the very first cycle of a fresh session it briefly reads `{"remaining": MAX_CYCLES, …}`; a resume reading `remaining == MAX_CYCLES` is equivalent to "fresh start minus the greeting" — proceed without the greeting.

**Compaction survival fallback.** If the resume hook (via the runtime's session-start hook (if configured), script `.scripts/check-run-resume.sh`) fails to re-inject the skill content, read `.codex/skills/run/SKILL.md` directly with the `read file` tool and follow its Session Start from this step.

### 1. Initial Sanity Gates (fresh start only)

- **`research/state.md` does not exist** → display "`research/state.md` が見つかりません。まず `/launch` でテーマを設定してください。" and stop. No further steps, no cycle loop.
- **`research/focus.md` does not exist** → do not attempt to construct it in the scheduler. The first research planner dispatch in the cycle loop will initialise it (see SKILL § Cycle step 2 — pass `focus.md missing — initialise at research/ root` in the dispatch prompt).
- **`concepts/` directory does not exist** → `mkdir concepts/`. Concept notes are written on demand when a reusable undefined term passes the concept gate; they are reader bridges, not project-fact authority.
- **`.gitignore` does not contain `.logs/.run-active`** → append the line. The beacon must not enter the repo via `session-wrap-up`'s `git add`.

### 2. Session Log Filename

The session log is created at Session End by `session-wrap-up`, which calls `bash .scripts/log-path.sh run` to obtain a timestamped path of the form `.logs/{YYMMDD_HHMM}_run.md`. The scheduler does not manage the filename directly.

### 3. Directives Load (informational)

If `directives.md` exists at project root, the scheduler passes its path to research planner and curator in their dispatch prompts (they handle reading). The scheduler itself does not enforce directives — enforcement is by the agents that read them (research planner for direction, curator for tree writes).

---

## Session End

Entered when `cycles_done == MAX_CYCLES`, or when research planner has returned `Status: session_complete` in `research/focus.md`, or when the scheduler exits the cycle loop for any other reason (unrecoverable failure). Execute in order.

### 1. Simulation Housekeeping (if simulator ran this session)

Research planner's final focus.md may include Tree Directives of the form `archive superseded script {path}`. Route these directives to curator during the final curator sweep; the scheduler does not move files inside `research/**`.

```
mv research/{path}/src/{slug}.{ext} research/{path}/src/archive/
mv research/{path}/src/{slug}.md research/{path}/src/archive/
```

Never delete — superseded scripts move to `src/archive/` so the reasoning history stays searchable. Curator records each move in its sweep output; include that summary in the wrap-up input's `## Session Log` § `### Node Changes`.

These archive moves are tree maintenance, so curator executes them together with any accompanying `state.md` or `plan.md` updates. Keeping the move and the prose record in one role preserves the tree-write authority split.

If research planner's focus.md has no archive directives, skip this step. Which scripts are superseded is a research judgment (research planner's), not a mechanical one.

### 2. Final Curator Sweep — Mandatory

Dispatch curator one final time with:

```

spawn_agent(prompt="""
Read and follow `.codex/agents/curator.md` as your role definition. Treat the rest of this prompt as task-specific input.

## Task
Session-end tree-wide coherence pass. Apply your default operating rules (fact-layer creation when reusable facts have enough derivation/review support, state.md compression for files over ~150 lines, staleness cleanup, Markdown-link audit, cross-file coherence) across the whole tree.


## Tree Directives
{verbatim copy of final research/focus.md § Tree Directives; use `(none)` only if the section is empty}

## New Evidence This Cycle
(none — no worker dispatch on the final step)

## Context
Cursor: {cursor from research/focus.md}
Session cycle: {n} of {N}
Session-end sweep: true
""")
```

The sweep is **not optional** and **not skippable** on the grounds that "nothing felt substantial this session". Its rationale: note.md promotion and cross-tree coherence consistently fall off research planner's attention during research cycles — synthesis and direction compete for the same cognitive budget and direction wins. The session-end sweep is the at-least-once-per-session guarantee that the maintenance channel runs.

Curator returns `DONE: {summary}`. If it returns `FAILED:`, record the failure in the wrap-up input's `## Last Session` so the next session picks it up; do not block Session End on a curator failure.

### 3. Final Research planner Dispatch (Session-End Mode)

```

spawn_agent(prompt="""
Read and follow `.codex/agents/research-planner.md` as your role definition. Treat the rest of this prompt as task-specific input.

## Task
mode: session-end


Obtain a wrap-up-input path via `bash .scripts/log-path.sh wrap-up-input` and write to it per the session-end-mode format in your agent definition. Return the path as `DONE: {path}`.

## This Session's Evidence (summary)
- Deliverables: {list of paths produced this session}
- Critic verdicts: {list of critic files or inline-annotated paths}
- Curator sweeps: {list of curator deliverables / summaries}
- Direction-challenge outputs: {list of timestamped direction-challenge paths captured from direction-challenger DONE returns this session, if any}
- Node changes: {new nodes, closes, status changes, report promotions — enumerate}
- Simulation-script archives: {moves from step 1, if any}
""")
```

Research planner writes the wrap-up input file and returns `DONE: {path}` where `{path}` is the timestamped wrap-up-input file it created. Capture this path for step 4. Do not write `research/focus.md` yourself; `session-wrap-up` transcribes the `## Focus` section into it.

If research planner returns `FAILED:`, the scheduler writes a minimal wrap-up input itself (cursor preserved as-is, `## Last Session` noting "research planner wrap-up failed: {reason}", commit message `run: session ended (research planner wrap-up failed)`) and continues to step 4. This avoids leaving the session uncommitted.

### 4. Dispatch `session-wrap-up`

```

spawn_agent(prompt="Read and follow `.codex/agents/session-wrap-up.md` as your role definition. Treat the rest of this prompt as task-specific input.\n\nWrap up the /run session.\n\nWrap-up input: {wrap-up-input path captured from step 3}\n\nExecute per your own specification.")

```

The agent: reads the wrap-up input at the path provided, writes `research/focus.md` / `.logs/last_session.md` / a session log file (created via `bash .scripts/log-path.sh run`) / node-scoped `backlog.md` files (if the input had a Backlog section) / `agenda.md` (if the input had an Agenda section), deletes `.logs/.run-active`, `git add`s the touched paths, `git commit`s with the message supplied in the wrap-up input (research planner-authored), `git push`es. Returns `DONE: committed {hash}` or `FAILED: {reason}`.

If `git push` fails (network, auth, non-fast-forward), the commit is preserved locally; the final report (step 5) notes the push failure so the user can retry.

### 5. Final Report (to the user)

The **only** user-facing closing message of the session (per Turn-Yielding Discipline in SKILL). Emit a concise summary covering:

- Cycles completed (`cycles_done` / `MAX_CYCLES`)
- Work performed and key results
- Node status changes and new nodes created
- Deliverable paths produced this session
- Agenda items recorded (if any)
- Commit hash / push status (from `session-wrap-up` return)

After emitting the report, yield the turn. Do not issue further tool calls.

---

## Failure Handling

If a dispatch fails mid-cycle and the scheduler cannot recover, do **not** silently stall. Choose one:

- *Recoverable* — the next cycle's research planner dispatch can work around it. Log the failure to be surfaced in `Recent Deliverables` for the next research planner dispatch, then loop normally.
- *Unrecoverable* — the scheduler exits the cycle loop early and proceeds to Session End. The final research planner dispatch (step 3) records the failure in `## Last Session`; the commit message is `run: session ended (unrecoverable: {reason})`.

Either way, never end a turn without either the next dispatch or the Session End final report. Stalling mid-session is the failure mode the Turn-Yielding Discipline exists to prevent.
