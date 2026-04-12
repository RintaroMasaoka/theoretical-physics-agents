---
name: meeting
description: "Start a meeting session for project progress review and course correction."
user-invocable: true
argument-hint: "[theme (optional)]"
---

# Meeting

Arguments: $ARGUMENTS

---

## Flow

**Principle: Ask questions first, then load data only as needed after responses.** Meetings are real-time dialogue, and response delays interrupt the user's thinking. Use AskUserQuestion for questions (text output questions risk missed responses).

```
Initialization
    ▼ Data loading: plan.md
    ▼ Context-dependent start
        ├─ No theme set → Tell user to run /launch first
        └─ Theme already set → Present progress report and open discussion
    ▼ Free discussion with user
    ▼ Reflect decisions as they are made
```

### Initialization

Execute the following at session start (→ incremental recording principle).

1. Get the current datetime with `Bash("date '+%Y-%m-%dT%H:%M'")`  (use this value for all timestamps in the session)
2. Update `plan.md` frontmatter's `last_meeting` to the obtained datetime
3. Create `meetings/YYYY-MM-DD_HHMM.md` using the obtained datetime (header only):

```markdown
# Meeting YYYY-MM-DD HH:MM

## Discussion Items

## Decisions

## Changes Applied
```

After initialization, commit with `meeting: init YYYY-MM-DD HH:MM`.

### When No Theme Is Set

Research theme has not been configured. Tell the user to run `/launch` to set the theme and direction, then end the session.

### When Theme Is Already Set

Review the overall research direction and open discussion.

```
Data loading: notes/index.md + plan.md + latest meeting minutes
    ▼ If meetings/agenda.md exists (agenda accumulated by PI during /run), load → immediately delete (prevent consumed agenda from carrying over to next time)
    ▼ Present progress report
    ▼ If loaded agenda items exist, display and discuss them as well
    ▼ AI presents high-level observations
    ▼ Free discussion with user
    ▼ Reflect decisions
```

**Progress report:**
```
Theme: {topic}
Research Questions:
  stable: {N} items — {key findings}
  active: {N} items — {current focus}
  open: {N} items
Key achievements since last meeting: [summary]
```

**Where to reflect:**
- Structural changes (add/delete/modify story steps, rewrite Thesis) → Edit `plan.md` directly. Leave a `> [Meeting YYYY-MM-DD] {reason for change}` marker at changes so PI can understand the context
- Cross-step approach principles → Add them to the **Approach Principles** section of `plan.md`. Record them with a `> [Meeting YYYY-MM-DD] {reason for change}` marker
- **Significance rewrite**: When the discussion recontextualizes results or establishes what findings mean in the story, rewrite the affected items' context in `items/*.md` and the `Strategy Notes` section in `plan.md` to reflect that synthesis. Meetings produce understanding that won't propagate to documents unless explicitly written. The meeting is the moment of synthesis — capture it in the documents, not just in the minutes

**Principle:** Focus on overall direction, not individual question management. Alignment on "what do we want to say with this research."

---

## Deepening the Dialogue

The goal is not AI reporting and ending, but drawing out the user's perspective to co-shape direction. Actively seek the user's judgment in the following situations.

**Turning points in direction:** Get user approval before reflecting plan.md structural changes (step/thesis/question additions/deletions). Present the content, reason, and the option to maintain the status quo.

**Ambiguous statements:** When user statements are ambiguous, state AI's interpretation explicitly and confirm. Do not stop at abstract agreement — specify exactly what changes to plan.md before reflecting.

**Interpreting results:** After the progress report, do not just state AI's assessment. Ask the user about the result's positioning in the storyline. If assessments differ, use that as discussion material and explore implications for plan.md structure and emphasis.

---

## Incremental Recording Principle

Users may leave at any natural stopping point. Post-processing that writes everything at the end risks not being executed. **Record and reflect on the spot, committing as you go.**

| Timing | Action |
|---|---|
| Session start | Create meeting minutes file + update `last_meeting` (→ see Initialization section) |
| When a topic arises | Append to "Discussion Items" in minutes via Edit |
| When a decision is made | Append to "Decisions" + immediately reflect in relevant files. If it is an approach principle, write it into the **Approach Principles** section of `plan.md` |
| When significance is discussed | Rewrite affected items' context in `items/*.md` and `Strategy Notes` in `plan.md` to reflect the synthesis. Record in "Changes Applied" |
| When a file is changed | Append to "Changes Applied" in minutes + git commit |

**Git commits:** Specify changed files individually with `git add` (prevent unintended file inclusion), and commit in `meeting: {summary of changes}` format. The prefix enables tracking meeting-driven changes in git log.
