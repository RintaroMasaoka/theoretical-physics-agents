# Phase: Session End

This phase file is a reference that PI Reads during `/run` when the session terminates (MAX_CYCLES reached or PI judges completion). It covers the simulation housekeeping + mandatory curator sweep that PI must do directly, and the handoff to the `session-wrap-up` agent for the mechanical finalization (session log, focus.md, last_session.md, beacon cleanup, commit+push).

---

End the session when MAX_CYCLES is reached or PI judges completion.
No need to rush — the next `/run` resumes from where you left off.

**Do not suggest transitioning to `/write`**. The user decides when research is mature enough for writing.

## PI-owned Steps (require research judgment)

1. **Simulation housekeeping** (if simulator ran): Check research nodes' `src/` for superseded scripts. Move to `src/archive/` — never delete. Which are superseded is a research judgment (which physical setup is the current canonical one?) — PI does this, not the wrap-up agent. Note each move in the wrap-up input (step 3 below) so it is recorded in `logs/last_session.md`.

2. **Knowledge base coherence** (mandatory at session end — not optional, not skippable on the grounds that changes "felt minor"): Dispatch **curator** to sweep the tree. Before dispatching, scan the tree yourself and include in the curator's prompt the concrete checklist described under `curator` in the agent-specific dynamic data of `cycle-dispatch.md` — subnodes without note.md, log.md files over ~150 lines, CONFIRMED claims added since the last curator dispatch, and recently retracted/revised claims. A bare "review the tree" dispatch is not enough: without those pointers, curator's default (note.md creation when CONFIRMED facts exist) cannot be reliably triggered. The rationale is that note.md promotion consistently falls off PI's attention during research cycles — synthesis and research compete for the same cognitive budget and research wins, so the maintenance channel must be guaranteed at session boundaries. Curator's work, once complete, is reviewed via `git diff` before commit.

## Mechanical Steps (delegated to `session-wrap-up` agent)

3. **Assemble wrap-up input** by first running `bash .scripts/new-log.sh wrap-up-input` to obtain a timestamped path of the form `logs/{YYMMDD_HHMM}_wrap-up-input.md`, then writing the substantive content there. The `session-wrap-up` agent distributes it to the right files, cleans up the beacon, and commits/pushes — it receives the path explicitly via its dispatch prompt (step 4).

   **Parse contract** (must match what the agent expects): Top-level section boundaries are the five canonical `##` headings in the order `## Focus`, `## Last Session`, `## Session Log`, `## Agenda` (optional — omit the heading entirely if not needed), `## Commit`. Anything between two canonical headings (or between `## Commit` and EOF) is that section's body. **Intra-section `##` headings (e.g., the `## Next Session` / `## Blockers` inside the Focus body) are transcribed verbatim into the output file** — PI does not need to demote them. The full rule is duplicated in `.claude/agents/session-wrap-up.md` § Parse rule.

   The input file format:

   ```markdown
   # Wrap-up Input

   ## Focus
   {body to write into research/focus.md — see template below}

   ## Last Session
   {body to write into logs/last_session.md — see template below}

   ## Session Log
   ### Accomplished
   - {what was done, key results}
   ### Node Changes
   - {status changes, new nodes created, nodes closed, simulation-script archive moves}
   ### Deliverables
   - {paths to deliverables produced}

   ## Agenda (optional)
   - {item 1 — self-contained, states what about and what decision is needed}
   - {item 2}

   ## Commit
   message: run: {concise summary of achievements}
   ```

   **Templates referenced above.**

   `## Focus` body (overwrites `research/focus.md`):
   ```markdown
   # Focus

   Working on: research/{path}/
   {What was accomplished, where to resume}

   ## Next Session
   - {concrete next steps}

   ## Blockers
   {If any}
   ```

   `## Last Session` body (overwrites `logs/last_session.md`):
   - Active nodes' operational detail (sizes, seed counts, blockers)
   - PI's thinking for next session
   - Anything useful to future PI that doesn't belong in the tree

   The `Session Log` section becomes `logs/{YYMMDD_HHMM}_run.md` (permanent record, never overwrite). The `session-wrap-up` agent obtains its path via `bash .scripts/new-log.sh run` at the moment of writing, so the timestamp reflects when the log was finalised rather than session start.

   `Agenda` is optional. If present, the wrap-up agent overwrites `agenda.md` with these items.

4. **Dispatch `session-wrap-up`**:

   ```
   Agent(subagent_type="session-wrap-up", prompt="Wrap up the /run session.\n\nWrap-up input: {path returned by new-log.sh in step 3}\n\nExecute per your own specification.")
   ```

   The agent will: write the session log / focus.md / last_session.md / agenda.md, delete `logs/.run-active`, `git add` the relevant paths, `git commit` with the PI-provided message, and `git push`. It returns `DONE: committed {hash}` or `FAILED: {reason}`.

   **Prerequisite**: `logs/.run-active` must be listed in `.gitignore`. If you notice it is missing from `.gitignore`, add it before the dispatch so a crash-left beacon never accidentally enters the repo via the wrap-up's `git add`.

## Final Report (to the user)

5. Display the final report:
   - Work performed and results
   - Deliverable paths
   - Node status changes
   - If agenda was written, mention it

This is the **only** user-facing closing message of the session (per the Turn-Yielding Discipline in SKILL.md). After this, yield the turn.
