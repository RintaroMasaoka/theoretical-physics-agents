---
name: meeting
description: "Review research direction and AI reliability with the user, record oversight decisions, and update the next research focus."
user-invocable: true
argument-hint: "[agenda/question optional]"
---

# Meeting

Arguments: $ARGUMENTS

---

`$ARGUMENTS` is a meeting agenda or question focus. It never sets or changes the research theme by itself; if the theme has not been configured, `/meeting` still redirects to `/launch`.

## Language Contract

Write all meeting prose in **japanese**. This covers conversational responses, progress reports, questions, meeting logs, reflected research-tree edits, and commit messages. Technical terms, proper nouns, LaTeX mathematics, file paths, frontmatter keys, and command names may remain in their original form.

English headings and labels in this prompt are structural examples, not literal output strings. When creating user-facing reports or logs, render those labels in japanese unless they are fixed project syntax documented elsewhere. Reason: `/meeting` mixes live conversation with durable records; copying English examples into either channel makes the language rule look optional and causes later turns to drift.

---

## Role

`/meeting` is the human oversight venue for the research process. Its purpose is to keep the research from drifting, expose places where AI verification may be weak or dishonest, help the human researcher understand the current science, and record direction decisions for the next `/auto` or `/steer`.

It is **not** a manuscript authorization gate in the current framework. `manuscript/` is frozen until the future `/write` workflow defines a promotion protocol. Do not create `manuscript/authorizations/`, do not approve findings.md for manuscript use, and do not make the user certify fact-layer prose as a substitute for curator/critic quality control.

This differs from `/auto`, `/steer`, and `/write`:
- `/auto` advances research and maintains `findings.md`, `checks/`, `guide.md`, state, graph structure, and provenance through agents
- `/steer` lets the user choose one executable cycle direction before workers run
- `/write` drafts paper material under `draft/**`; manuscript promotion is frozen for now
- `/meeting` is where the user interrogates direction, verification honesty, explanations, and priorities

## Flow

**Principle: human oversight, not human fact-layer QA.** A meeting may inspect `findings.md` or `checks/`, but the user should not be made responsible for making findings.md self-contained. If the discussion uncovers missing derivations, verification handoff confusion, workflow jargon, history-like prose, skipped prerequisites, or missing literature links, record these as readiness debt for curator/critic/research-planner. Keep the user's attention on direction, trust, explanation, and what to challenge next.

```
Initialization
    ▼ Data loading: research/state.md (required) + research/guide.md / research/findings.md / research/story.md / research/focus.md if present
    ▼ Context-dependent start
        ├─ No theme set (research/state.md missing) → Tell user to run /launch first
        └─ Theme already set → Present oversight packet
    ▼ Discuss research control questions
        ├─ Direction drift or poor question → record direction decision / focus update
        ├─ Verification doubt or self-contained defect → record readiness debt for /auto
        ├─ Human needs explanation → teach, then update guide.md if the explanation should persist
        └─ Confirmed synthesis → update guide.md / story.md / state.md / findings.md by proper routing
    ▼ Reflect decisions and debts as they are made
```

### Initialization

Execute the following at session start (→ incremental recording principle). If `research/state.md` does not exist, skip to "When No Theme Is Set."

1. Capture ISO timestamp: `exec_command("date '+%Y-%m-%dT%H:%M'")`
2. Update `research/state.md` frontmatter's `last_meeting` to the ISO timestamp
3. Obtain a meeting log path via `bash .scripts/log-path.sh meeting`, then write the file (header only) to that path:

```markdown
# {meeting title in japanese} YYYY-MM-DD HH:MM

## {oversight packet heading in japanese}

## {discussion items heading in japanese}

## {verification doubts and readiness debt heading in japanese}

## {decisions heading in japanese}

## {changes applied heading in japanese}
```

After initialization, commit with `meeting: {localized initialization summary} YYYY-MM-DD HH:MM`.

### When No Theme Is Set

Research theme has not been configured (`research/state.md` does not exist). Tell the user to run `/launch` to set the theme and direction, then end the session.

### When Theme Is Already Set

Open with an oversight packet, then let the user's doubts and direction judgments drive the meeting.

```
Minimum required file: `research/state.md`. Data loading after that: `research/guide.md`, `research/findings.md`, `research/story.md`, `research/principles.md`, `research/focus.md`, and latest previous meeting log when present, excluding the newly created current log. If an optional file is missing, note the absence in the oversight packet and continue from `state.md`.
    ▼ Navigate the tree: ls research/ to see top-level children; read guide.md/state.md/findings.md where relevant
    ▼ If project-root agenda.md exists, load it and record its contents in the meeting log before treating it as consumed. If items are consumed or dismissed, delete agenda.md and commit that deletion together with the meeting update
    ▼ Present oversight packet: current direction, guide links, verification-risk links, likely drift points
    ▼ Ask what the user wants to interrogate first: direction, verification honesty, explanation, or priority
    ▼ Reflect decisions, readiness debt, guide updates, and next focus
```

**Oversight packet:**
```
{theme label in japanese}: {from research/guide.md, research/story.md, or research/state.md}
{current focus label in japanese}: {research/focus.md Cursor + one-sentence context}
{human guide label in japanese}:
  - {path to guide.md if present} — {why this is the best entrypoint}
{verification-risk label in japanese}:
  - {path to findings/check/report/state item} — {short reason this deserves human suspicion or may need curator/critic follow-up}
{direction questions label in japanese}:
  - {question about drift, priority, story fit, missing evidence, or explanation need}
```

**Do not replace oversight with a summary.** A summary may orient the user, but the meeting's job is to surface the controls the user can exercise: asking why a claim is trusted, whether verification was real, whether the research question is still sensible, and what should be explained before continuing. Avoid dumping whole files into chat. Link the relevant `guide.md`, `findings.md`, `checks/`, `_materials/analyses/*.md`, `story.md`, or `state.md` section and quote only short excerpts needed for discussion.

**Use guide.md as the first human entrypoint.** Prefer linking `guide.md` when it exists. If no guide exists or it is stale, say so and use `state.md` / `story.md` / `findings.md` temporarily, then record a guide.md maintenance item for curator or update guide.md during the meeting if the needed guide content is now clear.

**Self-contained defects are readiness debt.** When the user finds that findings.md is not self-contained, verification is hard to follow, prose is polluted by workflow jargon, history is written as fact, prerequisites are skipped, or external literature should have been cited but is missing, do not ask the user to finish the QA pass. Record the defect under readiness debt, route it to `research/focus.md`, project-root `agenda.md`, or a relevant `state.md` entry for `/auto`, and preserve the user's high-level judgment in guide.md if useful.

**Teach when the user asks.** If the user needs to understand the research to supervise it, explain the minimum prerequisite, derivation idea, or verification chain in the conversation. If the explanation is likely to be needed again, update guide.md rather than bloating findings.md. If the explanation is actually a missing derivation or premise, route it to findings.md maintenance instead of leaving it only in guide.md.

## Reflection Routing

Route meeting outcomes by what kind of thing was learned.

- Human oversight orientation, reading path, recurring doubts, what to inspect next → `guide.md`
- Project thesis, narrative success condition, or paper storyline → `research/story.md`
- Decomposition, route priority, approach choice, or active strategy → relevant `plan.md` or `research/focus.md`
- Verification doubt, self-containedness defect, missing source bridge, suspected AI overclaim, or unclear checks chain → project-root `agenda.md`, `research/focus.md`, or relevant `state.md` for curator/critic/research-planner follow-up
- User-confirmed fact-layer wording or interpretation of already-supported content → `findings.md`; new or unverified factual claims go to `/auto`/curator/critic rather than being established by human agreement
- Background / working state changes → `research/state.md`
- Reusable research judgment principles → `research/principles.md` with a `> [Meeting YYYY-MM-DD]` origin marker, after the routing check below
- Notation, sign, normalization, symbol reservation, or convention bridge → `conventions.md`
- Framework-level file contract or agent workflow rule → record a project-root `agenda.md` item labelled `/improve`, or invoke `/improve` only if the user explicitly asks to handle it now

**Manuscript freeze:** Do not write to `manuscript/`, do not create authorization snapshots, and do not ask the user to approve findings.md as manuscript input. If the user starts making paper-promotion decisions, record them as discussion/agenda for the future write workflow unless they also imply immediate research-tree changes above.

**Significance rewrite:** When the discussion explicitly recontextualizes results and the user confirms the synthesis, rewrite affected `guide.md`, `story.md`, or `findings.md` according to the routing rules. Meetings produce understanding that won't propagate unless written, but unresolved factual questions must be routed back to `/auto` rather than recorded as established facts.

---

## Deepening the Dialogue

The goal is not AI reporting and ending, but user control over research direction, verification trust, and understanding. Actively seek the user's judgment in the following situations.

**Direction drift:** Ask whether the current cursor, child decomposition, or next worker direction still serves the project. If the user redirects, reflect the decision in `research/focus.md`, `story.md`, or a relevant state/plan surface according to scope.

**Verification suspicion:** If a claim looks too convenient, lacks a derivation, relies on an unclear check chain, or cites only AI-produced prose, ask what the user wants challenged. Record the target, suspected failure mode, and desired follow-up as readiness debt.

**Human understanding gap:** If the user is trying to keep up, teach the missing concept or derivation path. Then decide whether the persistent artifact should be guide.md, findings.md, a concept note under `concepts/{term}.md`, or a source-reading task.

**Ambiguous statements:** State AI's interpretation explicitly and confirm. Specify exactly what changes to which files before reflecting.

---

## Incremental Recording Principle

Users may leave at any natural stopping point. Post-processing that writes everything at the end risks not being executed. **Record and reflect on the spot, committing as you go.**

| Timing | Action |
|---|---|
| Session start | Create meeting log file in `.logs/` + update `last_meeting` |
| When an oversight packet is presented | Append linked guide/findings/check/story/state paths under the localized oversight-packet heading |
| When a topic arises | Append under the localized discussion-items heading in the meeting log. Log-only appends are not themselves listed under changes-applied |
| When verification doubt or readiness debt is identified | Append under the localized readiness-debt heading + route to focus/state/agenda as appropriate |
| When a decision is made | Append under the localized decisions heading + immediately reflect in relevant files. Before writing to `research/principles.md`, run the research-principle routing check below |
| When an explanation should persist | Update guide.md, `concepts/{term}.md`, or findings.md by routing identity. Record under the localized changes-applied heading |
| When a research artifact changes | Append under the localized changes-applied heading in the meeting log + git commit. A research artifact change means any non-log file change, or agenda.md consumption/deletion; ordinary meeting-log appends do not recursively require a changes-applied entry |

**Git commits:** Specify changed files individually with `git add`. Keep the fixed `meeting:` prefix, and write the summary of changes in japanese.

## Research Principle Routing Check

`research/principles.md` is not a general bucket for important meeting decisions. Write there only when the decision states a reusable research judgment principle: a criterion that future agents should repeatedly apply when comparing routes, promoting claims, separating roles, or deciding what evidence prevents overclaiming.

Use the main Reflection Routing table above for all non-principle destinations. This check only decides whether a decision belongs in `research/principles.md`: write there only when it is a reusable research judgment criterion with active future consequences. If the decision is thesis/story, decomposition/strategy, source priority, established fact prose, human-facing explanation, notation/convention, or framework workflow, route it to the destination named above rather than duplicating it in `principles.md`.

When adding a principle, use `# Research Principles` as the heading and include scope, principle, reason, consequence, and origin. If an existing `principles.md` entry is really story, plan, source priority, notation, fact prose, guide prose, or framework workflow, move it when the move is mechanical; if moving it would change scientific meaning, record the concern in the meeting log and leave a concrete agenda item for curator/research-planner follow-up.
