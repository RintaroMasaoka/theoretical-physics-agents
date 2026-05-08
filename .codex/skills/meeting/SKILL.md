---
name: meeting
description: "Review AI research deliverables with the user, record approvals, and set research direction."
user-invocable: true
argument-hint: "[theme (optional)]"
---

# Meeting

Arguments: $ARGUMENTS

---

## Language Contract

Write all meeting prose in **japanese**. This covers conversational responses, progress reports, questions, meeting logs, reflected research-tree edits, and commit messages. Technical terms, proper nouns, LaTeX mathematics, file paths, frontmatter keys, and command names may remain in their original form.

English headings and labels in this prompt are structural examples, not literal output strings. When creating user-facing reports or logs, render those labels in japanese unless they are fixed project syntax documented elsewhere. Reason: `/meeting` mixes live conversation with durable records; copying English examples into either channel makes the language rule look optional and causes later turns to drift.

---

## Role

`/meeting` is the human approval gate for AI research outputs. The main object of review is not the AI's summary of progress; it is the actual `research/**/note.md` fact-layer prose that downstream writing would rely on. The meeting points the user to the artifact by clear file links, records explicit approval or requested revision, and captures research-direction instructions that should shape the next `/auto`.

This differs from `/auto` and `/write`:
- `/auto` may create, verify, and maintain `note.md`, but it cannot make a result human-authorized
- `/write` may draft from the research tree, but it may promote content into `manuscript/` only from meeting-authorized material
- `/meeting` is where the user sees the artifact, approves it, rejects it, asks for revision, or redirects the research

## Flow

**Principle: put artifacts in front of the user before asking for decisions.** Meetings are real-time review sessions, but dumping whole source files into the chat makes review harder and turns the meeting transcript into a second, noisy copy of the research tree. Load the minimal state needed to identify candidate `note.md` deliverables, present clickable file links plus a short orientation and review status, then ask for approval, revision, or direction. Use request_user_input for questions (text output questions risk missed responses).

```
Initialization
    ▼ Data loading: research/state.md + research/note.md (if exists) + research/story.md
    ▼ Context-dependent start
        ├─ No theme set (research/state.md missing) → Tell user to run /launch first
        └─ Theme already set → Present deliverable review packet
    ▼ User opens/reviews linked note.md artifacts
        ├─ Approved → Record authorization and prepare manuscript handoff
        ├─ Revision requested → Record required changes and route back to /auto or meeting rewrite
        └─ Direction change → Reflect direction decisions
    ▼ Reflect approvals and decisions as they are made
```

### Initialization

Execute the following at session start (→ incremental recording principle). If `research/state.md` does not exist, skip to "When No Theme Is Set."

1. Capture ISO timestamp: `exec_command("date '+%Y-%m-%dT%H:%M'")`
2. Update `research/state.md` frontmatter's `last_meeting` to the ISO timestamp
3. Obtain a meeting log path via `bash .scripts/log-path.sh meeting`, then write the file (header only) to that path:

```markdown
# {meeting title in japanese} YYYY-MM-DD HH:MM

## {deliverables reviewed heading in japanese}

## {authorizations heading in japanese}

## {discussion items heading in japanese}

## {decisions heading in japanese}

## {changes applied heading in japanese}
```

After initialization, commit with `meeting: {localized initialization summary} YYYY-MM-DD HH:MM`.

### When No Theme Is Set

Research theme has not been configured (`research/state.md` does not exist). Tell the user to run `/launch` to set the theme and direction, then end the session.

### When Theme Is Already Set

Review AI research deliverables first, then discuss direction.

```
Data loading: research/note.md + research/state.md + research/story.md + research/principles.md + research/focus.md + latest meeting log
    ▼ Navigate the tree: ls research/ to see top-level children, read their state.md for status (note.md if exists)
    ▼ If agenda.md exists (agenda accumulated by research planner during /auto), load → append its items to the meeting log → then delete it (prevents stale items from carrying over without losing them on interruption)
    ▼ Identify candidate note.md deliverables for user review
    ▼ Present deliverable review packet: file links + minimal orientation
    ▼ If loaded agenda items exist, display and discuss them as well
    ▼ Ask for approval / revision / direction
    ▼ Reflect authorizations and decisions
```

**Deliverable review packet:**
```
{theme label in japanese}: {from research/note.md or research/state.md title}
{candidate deliverables label in japanese}:
  - {path to note.md} — {one-line reason this is ready for review}

{artifact heading in japanese}: {clickable path to note.md}
{orientation in japanese}: {short context only; not a substitute for the artifact}
{review note in japanese}: Open the linked file for the approval target. Mention any short caveat or section anchor needed to focus review.

{requested decision label in japanese}: approve as manuscript input / request revision / redirect research
```

**Do not replace artifact review with a summary.** A summary may orient the user, but it is not the approval target. If a `note.md` is being considered for authorization, provide a clickable path to the file and make clear that the linked file, not the orientation paragraph, is what is being approved. Do not paste the whole body into chat by default. Only quote a short excerpt when it is necessary to discuss a specific sentence or ambiguity. Do not paraphrase away limitations, scopes, check links, caveats, or source/project boundary language when describing what the user is about to review.

**Candidate selection:** Prefer `note.md` files that are stable, recently changed since the last meeting, central to `research/story.md`, or directly blocking manuscript progress. If there are many, present the highest-impact few first and say what was deferred. Do not make the user approve a hidden batch.

**Self-contained orientation:** Throughout the meeting, briefly explain any technical term, mathematical object, internal label, or named entity (e.g. matrix, operator, algorithm, node name, abbreviation, theorem) on its first mention in this conversation when it is needed for the decision. Never assume the user remembers a term from prior meetings, but keep explanations proportional so the chat remains a review surface rather than a rewritten source file.

**Research note hygiene:** A `note.md` is durable fact-layer synthesis, not a meeting transcript or process log. User-facing notes should read as the current understanding: avoid embedding meeting-history markers, session chronology, or approval provenance in the prose unless the historical fact itself is part of the scientific claim. Put provenance, approvals, agenda, and route history in `.logs/`, `state.md`, `story.md`, or authorization snapshots. Meeting-confirmed revisions to `note.md` should remove stale labels and over-specific framing that the user rejects, so downstream `/write` sees a clean notebook rather than a log.

## Context-Route Invalidation

Meetings are also where the user can reject how the research tree is routing an element to future agents. The issue is not only the element itself. In this workflow, an element's effective role is assigned by context routing: where it is stored, which durable surface contains it, and which handoff prompt will later read that surface. A term, method, claim, proof, figure, check, dataset, summary, convention, confidence label, or plan can become "current understanding", "evidence", "proof support", "canonical terminology", "manuscript input", or "next-cycle instruction" because it sits on a surface that future agents read in that role.

When user feedback rejects an element in the role by which the tree is routing it, do not treat the feedback as a local edit or a future preference. Seed a curator-owned context-route invalidation transaction. The meeting owns capturing the user-confirmed rejection and scope; curator owns repairing durable context routes. If repair requires computation, broad regeneration, or worker execution, curator records the open transaction and routes it to the next `/auto` focus instead of leaving the rejected route active.

Open this transaction when all three are true:
- **Element**: the user rejects a term, method, claim, proof, artifact, convention, summary, data product, or framing in the role it is currently serving
- **Route**: that element appears, or plausibly appears, on a durable surface or handoff path that future agents will read (`note.md`, `state.md`, `checks/`, `report_*.md`, `conventions.md`, `principles.md`, `research/focus.md`, active data/figure/script surfaces, or a linked archive)
- **Risk**: leaving it in that route would let a future agent receive it as current understanding, evidence, proof, canonical method/term, validation support, or operational instruction

First state your interpretation and confirm if the scope is ambiguous. Then write the decision under the localized decisions heading and dispatch curator with a transaction seed:

```markdown
Rejected routed role:
- Element: {what is being rejected}
- Rejected role: {the role the tree currently gives it — evidence, current understanding, proof support, canonical term, method, etc.}
- Accepted replacement or unresolved: {replacement role/element if known, otherwise state unresolved}
- Scope: {tree path(s) and surfaces in scope}
- User-confirmed reason: {short reason in the user's terms}
- Suspected routes: {surfaces or artifact classes likely to carry the rejected role}
- Urgency: {why this must be closed now or why it can be routed to /auto}
```

Dispatch curator with that seed:

```

spawn_agent(prompt="""
Read and follow `.codex/agents/curator.md` as your role definition. Treat the rest of this prompt as task-specific input.

## Task
Context-route invalidation transaction from /meeting. The user has rejected an element in the role by which durable research surfaces may be routing it. Capture the transaction, repair any durable context routes you are authorised to repair now, and record or route any regeneration/worker work needed before the rejected role can be considered closed.


## Transaction Seed
{the Rejected routed role block above}

## Meeting Context
{short meeting-log path and any file links already discussed}
""")
```

Do not ask curator to decide whether the user's rejection is scientifically correct. The meeting has already established the user-facing decision; curator's job is context-route mechanics and transaction closure. If the rejection is unresolved or the user is still deciding, do not dispatch curator yet — record it as a discussion item or agenda item instead.

When curator returns, append the curator summary and changed paths under the localized changes-applied heading, then commit the meeting log plus curator-touched files with the normal `meeting:` prefix. In `/meeting`, there is no `session-wrap-up`; meeting is responsible for recording and committing curator's returned tree changes. If curator reports an open regeneration or worker task, record it in `research/focus.md` or the relevant backlog/agenda exactly as curator specifies, so the next `/auto` sees the transaction before ordinary research resumes.

## Authorization Gate

Approval is explicit and scoped. Treat only a clear user statement of approval for a displayed artifact as authorization. Silence, ambiguous agreement, approval of a summary, or approval of a future revision does not authorize the underlying `note.md`.

When the user approves a `note.md` artifact:

1. Append the reviewed path and decision under the localized authorizations heading in the meeting log
2. Create or update an authorization snapshot under `manuscript/authorizations/` containing:
   - timestamp
   - source `note.md` path
   - approval scope stated by the user
   - any exclusions, limitations, or requested manuscript framing
   - the exact `note.md` body from the linked file at the time of approval
3. Record the path to that authorization snapshot in the meeting log
4. Treat the snapshot, not the mutable `note.md`, as the authorized handoff to manuscript writing

Reason: `note.md` can continue to evolve under `/auto`; authorization must attach to the linked artifact version the user actually reviewed. The snapshot is the bridge from agent-maintained draft facts to human-authorized manuscript authority.

If the user requests revision instead of approval, record the requested changes under decisions, update `research/focus.md` or relevant `state.md` / `principles.md` as appropriate, and do not create an authorization snapshot. If the user collaboratively rewrites `note.md` during the meeting and then approves the rewritten artifact, show the final rewritten text before recording authorization.

**Where to reflect:**
- Changes to the paper's narrative structure (add/remove/reorder steps) → Edit `research/story.md`. Leave a `> [Meeting YYYY-MM-DD] {reason}` marker
- User-confirmed fact-layer understanding changes → Edit `research/note.md` only when the user has explicitly confirmed the understanding or approved the wording during the meeting. Unresolved factual changes go to `research/focus.md`, `state.md`, or `agenda.md` for `/auto`
- Background / working state changes → Edit `research/state.md`
- User-approved manuscript input → Write `manuscript/authorizations/{timestamp}_{slug}.md` with the exact approved artifact
- Cross-cutting constraints → Edit `research/principles.md` with a `> [Meeting YYYY-MM-DD]` marker
- User rejection of a routed element-role that could remain active in durable context → Seed a curator context-route invalidation transaction before continuing ordinary review
- Direction changes scoped to a specific branch → Edit that branch's `state.md` or the global `research/focus.md`; edit `note.md` only when the direction also changes user-confirmed fact-layer understanding
- Next `/auto` session's focus changed → Edit `research/focus.md` (the session cursor that tells `/auto` where to resume). Set the `Working on:` path to the new focus node and update context accordingly
- **Significance rewrite**: When the discussion explicitly recontextualizes results and the user confirms the synthesis, rewrite affected note.md files to reflect that fact-layer understanding. Meetings produce understanding that won't propagate to documents unless explicitly written, but unresolved factual questions must be routed back to `/auto` rather than recorded as established facts

**Principle:** Focus on artifact approval and overall direction, not individual node management. Alignment on "what is now authorized to become the paper, and what should research do next."

---

## Deepening the Dialogue

The goal is not AI reporting and ending, but user judgment over artifacts and direction. Actively seek the user's judgment in the following situations.

**Deliverable approval:** After linking a candidate `note.md` as the approval target, ask whether it is approved as manuscript input, needs revision, or should redirect the research. If approval is partial, restate the approved scope and exclusions before writing the authorization snapshot.

**Turning points in direction:** Get user approval before reflecting structural changes to the narrative structure in `research/story.md` (step additions/deletions/reordering). Present the content, reason, and the option to maintain the status quo.

**Ambiguous statements:** State AI's interpretation explicitly and confirm. Specify exactly what changes to which files before reflecting.

**Interpreting results:** After the deliverable review packet, do not just state AI's assessment. Ask the user about the result's positioning in the storyline. If assessments differ, use that as discussion material and explore implications for tree structure and emphasis.

---

## Incremental Recording Principle

Users may leave at any natural stopping point. Post-processing that writes everything at the end risks not being executed. **Record and reflect on the spot, committing as you go.**

| Timing | Action |
|---|---|
| Session start | Create meeting log file in `.logs/` + update `last_meeting` (→ see Initialization section) |
| When a deliverable is presented | Append path and review status under the localized deliverables-reviewed heading |
| When a deliverable is approved | Append under the localized authorizations heading + write `manuscript/authorizations/{timestamp}_{slug}.md` |
| When a topic arises | Append under the localized discussion-items heading in the meeting log via Edit |
| When a decision is made | Append under the localized decisions heading + immediately reflect in relevant files. Constraints go to `research/principles.md` |
| When a routed role is rejected | Append the transaction seed under decisions + dispatch curator or record why it is deferred |
| When significance is discussed and confirmed | Rewrite affected note.md files to reflect the confirmed synthesis. Record under the localized changes-applied heading |
| When a file is changed | Append under the localized changes-applied heading in the meeting log + git commit |

**Git commits:** Specify changed files individually with `git add`. Keep the fixed `meeting:` prefix, and write the summary of changes in japanese.
