# Phase: Session Lifecycle

This phase file is a reference that `/auto` Reads at Session Start and Session End. It covers the resume-check logic, the initial sanity gates, the session-end steps the scheduler owns directly, and the close-session script transaction.

The cycle loop between Session Start and Session End is purely mechanical (direction-challenger → research planner → workers → critic → curator → loop) and lives in `SKILL.md § Cycle Loop`. This file covers only the lifecycle bookends.

---

## Session Start

Execute in order.

### 0. Resume Check — `.logs/.auto-active` beacon

The beacon is written at the start of every cycle (SKILL § step 0). Its presence at session start means a prior session was mid-cycle when interrupted (compaction, crash, reconnect). Rules:

- **If the user invoked `/auto {N}` with an explicit `N`, the explicit value wins**: treat as fresh session regardless of beacon state, delete any existing beacon. (Explicit invocation signals new intent.)
- **If `/auto` was invoked without an argument** (`MAX_CYCLES` defaults to `5`), consult the beacon:
  - File exists, `remaining > 0`, **not stale** → resume after interruption. Set `MAX_CYCLES := remaining`, skip any greeting, skip the initial sanity gates below (the prior session passed them), proceed directly to Cycle Loop step 0. Do not re-emit a welcome message.
  - File exists with `remaining <= 0` → prior session ended cleanly between the last cycle and Session End. Delete the beacon; treat as fresh start.
  - File exists but **stale** — mtime older than 24h, or a newer `.logs/*_auto.md` exists → prior session is not truly in flight. Delete the beacon; treat as fresh start.
  - File does not exist → normal fresh start.

Resume is cycle-boundary recovery, not sub-step replay. Do not try to infer and resume from a partially completed sub-step. Restart at Cycle Loop step 0 with the beacon's `remaining` count, and include any already written artifacts from the interrupted cycle in the session evidence only when their paths are known from scheduler state or agent returns.

The beacon is gitignored (see `.gitignore`) and deleted at Session End by `.scripts/close-session.mjs`. On the very first cycle of a fresh session it briefly reads `{"remaining": MAX_CYCLES, …}`; a resume reading `remaining == MAX_CYCLES` is equivalent to "fresh start minus the greeting" — proceed without the greeting.

**Compaction survival fallback.** If the resume hook (via the runtime's session-start hook (if configured), script `.scripts/check-auto-resume.sh`) fails to re-inject the skill content, read `.codex/skills/auto/SKILL.md` directly with the `read file` tool and follow its Session Start from this step.

### 1. Initial Sanity Gates (fresh start only)

- **`research/state.md` does not exist** → display "`research/state.md` が見つかりません。まず `/launch` でテーマを設定してください。" and stop. No further steps, no cycle loop.
- **`research/focus.md` does not exist** → do not attempt to construct it in the scheduler. The first research planner dispatch in the cycle loop will initialise it (see SKILL § Cycle step 2 — pass `focus.md missing — initialise at research/ root` in the dispatch prompt).
- **`concepts/` directory does not exist** → `mkdir concepts/`. Concept notes are written on demand when a reusable undefined term passes the concept gate; they are reader bridges, not project-fact authority.
- **`.gitignore` does not contain `.logs/.auto-active`** → append the line. The beacon must not enter the repo via the close-session staging transaction.

### 2. Session Log Filename

The session log is created at Session End by `.scripts/close-session.mjs`, which calls `bash .scripts/log-path.sh auto` or `bash .scripts/log-path.sh steer` to obtain a timestamped path of the form `.logs/{YYMMDD_HHMM}_{session-kind}.md`. The scheduler does not manage the filename directly.

### 3. Principles Load (informational)

If `research/principles.md` exists at project root, research planner and curator read it through their normal root-context loading. The scheduler itself does not enforce research principles — enforcement is by the agents that read them (research planner for direction, curator for tree writes and identity maintenance).

---

## Session End

Entered when `cycles_done == MAX_CYCLES`, when the user explicitly stops the session, or when the scheduler exits the cycle loop for an unrecoverable failure. `research/focus.md` may say `Status: session_complete`, but that label never terminates `/auto`; it records the planner's research-state judgment while the scheduler continues consuming the user-requested cycle budget.

### 1. Simulation Archive Directives

Run this step only when final `research/focus.md` contains Tree Directives of the form `archive superseded script {path}`. Route these directives to curator during the primary session-end curator sweep; the scheduler does not move files inside `research/**`. Curator should move both the superseded script and its companion `.md` into the node's `_materials/src/archive/` directory and never delete them, so the reasoning history stays searchable. Curator records each move in its sweep output; include that summary in the close-session packet's `## Session Log` § `### Node Changes`.

These archive moves are tree maintenance, so curator executes them together with any accompanying `state.md`, `map.md`, or `plan.md` updates. Keeping the move and the prose record in one role preserves the tree-write authority split.

If research planner's focus.md has no archive directives, skip this step. Which scripts are superseded is a research judgment (research planner's), not a mechanical one.

### 2. Primary Session-End Curator Sweep — Mandatory

Dispatch curator one final time with:

```

spawn_agent(prompt="""
Read and follow `.codex/agents/curator.md` as your role definition. Treat the rest of this prompt as task-specific input.

## Task
Session-end tree-wide coherence pass. Apply your default operating rules (research-memory shape repair, parent map maintenance, admitted fact-layer materialisation, state.md compression, staleness cleanup, Markdown-link audit, cross-file coherence) across the whole tree. Do not write guide.md; guide-writer is dispatched after your sweep.


## Tree Directives
{verbatim copy of final research/focus.md § Tree Directives; use `(none)` only if the section is empty}

## New Evidence This Cycle
(none — no worker dispatch on the final step)

## This Session's Evidence
- Deliverables: {list of worker submission paths produced this session, if any}
- Critic verdicts: {list of Provisional Review and Durable Surface Review outputs produced this session, if any}
- Prior curator summaries: {list of curator DONE summaries / paths from this session, if any}

## Context
Cursor: {cursor from research/focus.md}
Session cycle: {n} of {N}
Session-end sweep: true
""")
```

The sweep is **not optional** and **not skippable** on the grounds that "nothing felt substantial this session". Its rationale: admitted findings.md materialisation, route repair, and cross-tree coherence consistently fall off research planner's attention during research cycles — synthesis and direction compete for the same cognitive budget and direction wins. The session-end sweep is the at-least-once-per-session guarantee that the maintenance channel executes.

Curator returns `DONE: {summary}`. If it returns `FAILED:`, record the failure in the close-session packet's `## Last Session` so the next session picks it up; do not block Session End on a curator failure.

This is the primary session-end curator sweep, not necessarily the last curator dispatch. Step 3 may require Durable Surface Review and a curator follow-up if the review mutates or demotes durable surfaces.

### 3. Drain Pending Durable Surface Reviews

If the final curator sweep or an earlier cycle carried pending Durable Surface Review requests, dispatch those reviews and re-dispatch curator to apply them, subject to the two-round cap in `phases/dispatch.md`. The affected claims must not be treated as confirmed until the review is drained or explicitly flagged as unresolved. If the cap is hit, record the verification gap for research planner and proceed; do not loop indefinitely.

### 4. Guide-writer Sweep — Human Oversight Guides

After the primary session-end curator sweep and after pending Durable Surface Reviews have been drained, dispatch guide-writer with the scheduler's session-local guide target set. The scheduler builds this set mechanically from paths it already knows: root `research/`, all cursors seen this session, worker target nodes, curator cursor nodes, presentation-boundary parent/child nodes, Durable Surface Review target nodes, and final-cursor ancestors. De-duplicate the set before rendering it in the prompt. Do not inspect git, build a staleness manifest, or ask curator whether a guide is stale to decide guide targets.

```

spawn_agent(prompt="""
Read and follow `.codex/agents/guide-writer.md` as your role definition. Treat the rest of this prompt as task-specific input.

## Task
Session-end guide sweep. For each target below, read the durable node surfaces and update guide.md only if the human oversight entrypoint is missing or stale. Do not decide research direction, claim admission, verification status, or graph placement.


## Guide Sweep Targets
{each node path in the session-local guide target set, de-duplicated, including research/}

## Context
Final cursor: {cursor from research/focus.md}
Curator final sweep summary: {DONE summary from step 2, or failure note}
Durable Surface Review summary: {final drained review summary, if any}
""")
```

guide-writer returns `DONE: {summary}`. If it flags fact-layer, verification, or graph contradictions, include those flags in the final research planner dispatch. If guide-writer fails, record the failure in the close-session packet's `## Last Session`; do not block Session End.

### 5. Final Research planner Dispatch (Session-End Mode)

```

spawn_agent(prompt="""
Read and follow `.codex/agents/research-planner.md` as your role definition. Treat the rest of this prompt as task-specific input.

## Task
mode: session-end


Obtain a close-session packet path via `bash .scripts/log-path.sh close-session-packet` and write to it per the session-end-mode format in your agent definition. Return the path as `DONE: {path}`.

## This Session's Evidence (summary)
- Deliverables: {list of paths produced this session}
- Critic verdicts: {list of Provisional Review and Durable Surface Review files}
- Curator sweeps: {list of curator deliverables / summaries}
- Guide-writer sweep: {guide-writer DONE summary and flags, if available}
- Direction-challenge outputs: {list of timestamped direction-challenge paths captured from direction-challenger DONE returns this session, if any}
- Node changes: {new nodes, closes, status changes, analysis preservations — enumerate}
- Simulation-script archives: {moves from step 1, if any}
""")
```

Research planner writes the close-session packet file and returns `DONE: {path}` where `{path}` is the timestamped packet file it created. Capture this path for step 6. Do not write `research/focus.md` yourself; `.scripts/close-session.mjs` transcribes the `## Focus` section into it.

If research planner returns `FAILED:`, the scheduler writes a minimal close-session packet itself and continues to step 6. Preserve the current cursor/focus as-is, include all accumulated session-end notes already known to the scheduler (original terminal reason, unrecoverable cycle failure if any, curator or guide-writer failures, unresolved Durable Surface Review gaps), then add `research planner session-end packet failed: {reason}` under `## Last Session`; use commit message `auto: session ended (research planner session-end packet failed)`. This avoids leaving the session uncommitted without erasing the original reason the session reached this fallback.

### 6. Close Session Transaction

Before closing, write a session-owned stage manifest to a timestamped `.logs/` path, preferably from `bash .scripts/log-path.sh close-session-manifest`. The manifest is a newline-delimited list of paths that belong to this session and should be committed in addition to the files written by the close-session script. Include worker submissions, critic reviews, durable reviews, curator-touched files, guide-writer-touched guides, generated session packets/manifests, and any `.gitignore` change made by the startup gates. Do not include unrelated pre-existing user edits. If ownership is ambiguous, stop before the close-session transaction and report the ambiguous paths instead of committing by broad `git add`.

Run:

```bash
node .scripts/close-session.mjs --packet {close-session packet path captured from step 5} --kind {auto|steer} --stage-manifest {manifest path}
```

The script validates the packet, writes `research/focus.md` / `.logs/last_session.md` / a session log file / node-scoped `backlog.md` files (if the packet has a Backlog section) / `agenda.md` (if the packet has an Agenda section), deletes `.logs/.auto-active`, stages only script-touched paths plus manifest-listed paths, commits with the packet's research-planner-authored message, and pushes. It prints `DONE: committed {hash} and pushed`, `DONE: no changes to commit`, or `FAILED: {reason}`.

If `git push` fails (network, auth, non-fast-forward), the commit is preserved locally; the final draft (step 7) notes the push failure so the user can retry.

### 7. Final Draft (to the user)

The **only** user-facing closing message of the session (per Turn-Yielding Discipline in SKILL). Emit a concise summary covering:

- Cycles completed (`cycles_done` / `MAX_CYCLES`)
- Work performed and key results
- Node status changes and new nodes created
- Deliverable paths produced this session
- Agenda items recorded (if any)
- Commit hash / push status (from `.scripts/close-session.mjs` output)

After emitting the draft, yield the turn. Do not issue further tool calls.

---

## Failure Handling

If a dispatch fails mid-cycle and the scheduler cannot recover, do **not** silently stall. Choose one:

- *Recoverable* — the next cycle's research planner dispatch can work around it. Log the failure to be surfaced in `Recent Deliverables` for the next research planner dispatch, then loop normally.
- *Unrecoverable* — the scheduler exits the cycle loop early and proceeds to Session End. The final research planner dispatch (step 5) records the failure in `## Last Session`; the close-session packet's commit message is `auto: session ended (unrecoverable: {reason})`.

Either way, never end a turn without either the next dispatch or the Session End final draft. Stalling mid-session is the failure mode the Turn-Yielding Discipline exists to prevent.
