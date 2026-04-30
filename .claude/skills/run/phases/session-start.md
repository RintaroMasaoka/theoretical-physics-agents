# Phase: Session Start

This phase file is a reference for `/run` session startup. It defines the resume-check logic, the context read sequence for the first physicist dispatch, the unread-paper rule, and the initial sanity check. Execute each step in order.

---

## Initial Check (before step 0)

These guards must fire *before* the step sequence begins, because later steps read files whose absence changes the dispatch prompt. The scheduler does not repair tree files here; tree writes still go through physicist/curator ownership.

- `research/log.md` does not exist → Display "Please set a theme via `/launch`" and stop (no further steps run)
- `research/focus.md` does not exist → Continue, but mark the first physicist prompt with `focus.md missing — initialise at research/ root`. Physicist writes `research/focus.md`; the scheduler does not create it
- `concepts/` does not exist → Continue with `concepts/ missing` noted for curator/concept-checker. Do not create concept notes during session start

## Steps

0. **Resume check** — read `logs/.run-active` if it exists. Precedence rules:
   - **If the user invoked `/run {N}` with an explicit argument, that argument always wins** — treat this as a fresh session regardless of the beacon. Delete a stale beacon if present. (Explicit invocation signals new intent from the user)
   - If `/run` was invoked without an explicit argument (so `MAX_CYCLES` defaults to `5`), consult the beacon:
     - File exists, `remaining > 0`, and **not stale** → this is a resume after an interruption (context compaction, crash, reconnect). Treat `MAX_CYCLES` as the `remaining` value from the file, skip the initial TodoWrite planning step, and proceed directly to step 1. Do not emit a greeting or recap — just resume work
     - File exists with `remaining <= 0` → prior session ended cleanly between cycle and Session End; delete it, normal fresh start
     - File exists but is **stale** — defined as either (i) file mtime older than 24 hours, or (ii) a newer `logs/*_run.md` exists → the prior session is not truly in flight; delete the beacon and treat as fresh start
     - File does not exist → normal fresh start
   - Note: the beacon is written at the start of every cycle (Cycle step 0 — Cycle Bookkeeping — defined in `SKILL.md`'s cycle workflow), so on the very first cycle of a fresh session it briefly reads `{"remaining": MAX_CYCLES, …}`. A crash between that write and any real work is harmless: a resume reading `remaining == MAX_CYCLES` is equivalent to a fresh start minus the greeting
1. Session log filename: created at Session End by `session-wrap-up` via `bash .scripts/log-path.sh run`; not the scheduler's concern at start
2. Read `research/focus.md` if it exists (the session cursor — where the previous session left off). If missing, use `research/` as the provisional cursor only for context loading and pass the missing-focus note to physicist
3. Read `logs/last_session.md` (if it exists — previous session's operational context)
4. Read `directives.md` at project root (if it exists — methodology rules from meetings)
5. Read the **ancestor chain** from root to cursor (inclusive): for each folder in the path, read `note.md` (if exists), `plan.md` (if exists), `log.md`, `conventions.md` (if exists), `dead_ends.md` (if exists), and `directives.md` (if exists)
6. Read the **cursor folder's direct children**: `ls` the folder → read each child's note.md (if exists) + conventions.md (if exists) + plan.md (if exists) + log.md (depth 1 only — not recursive)
7. Read `literature/reading_list.md`

## Unread Paper Principle

For papers marked `unread` in reading_list.md, PI must not describe their content, claims, methods, or results. Only the arXiv ID, title, authors, and a one-sentence abstract summary may be stated (see `.claude/common.md` verification procedures).

## Feedback Processing

- If files contain `> [Meeting ...]` markers: A direction change was decided in a meeting. Read and understand the reason before starting work. Do not revert these changes
- `directives.md` (project root and any subtree): Follow them throughout the session. PI must not change these unilaterally
