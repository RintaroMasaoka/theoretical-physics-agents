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
    ▼ Data loading: research/log.md + research/note.md (if exists) + research/story.md
    ▼ Context-dependent start
        ├─ No theme set (research/log.md missing) → Tell user to run /launch first
        └─ Theme already set → Present progress report and open discussion
    ▼ Free discussion with user
    ▼ Reflect decisions as they are made
```

### Initialization

Execute the following at session start (→ incremental recording principle). If `research/log.md` does not exist, skip to "When No Theme Is Set."

1. Capture two timestamps: (a) ISO format via `Bash("date '+%Y-%m-%dT%H:%M'")` and (b) log format via `Bash("date '+%y%m%d_%H%M'")`
2. Update `research/log.md` frontmatter's `last_meeting` to the ISO timestamp
3. Create `logs/{log_timestamp}_meeting.md` (header only):

```markdown
# Meeting YYYY-MM-DD HH:MM

## Discussion Items

## Decisions

## Changes Applied
```

After initialization, commit with `meeting: init YYYY-MM-DD HH:MM`.

### When No Theme Is Set

Research theme has not been configured (`research/log.md` does not exist). Tell the user to run `/launch` to set the theme and direction, then end the session.

### When Theme Is Already Set

Review the overall research direction and open discussion.

```
Data loading: research/note.md + research/log.md + research/story.md + research/principles.md + notes/index.md + latest meeting log
    ▼ Navigate the tree: ls research/ to see top-level children, read their log.md for status (note.md if exists)
    ▼ If agenda.md exists (agenda accumulated by PI during /run), load → immediately delete (prevents stale items from carrying over to the next meeting)
    ▼ Present progress report
    ▼ If loaded agenda items exist, display and discuss them as well
    ▼ AI presents high-level observations
    ▼ Free discussion with user
    ▼ Reflect decisions
```

**Progress report:**
```
Theme: {from research/note.md or research/log.md title}
Research Tree:
  stable: {N} nodes — {key findings}
  active: {N} nodes — {current focus}
  open: {N} nodes
Key achievements since last meeting: [summary]
```

**Where to reflect:**
- Changes to the paper's narrative structure (add/remove/reorder steps) → Edit `research/story.md`. Leave a `> [Meeting YYYY-MM-DD] {reason}` marker
- Verified understanding changes → Edit `research/note.md`
- Background / working state changes → Edit `research/log.md`
- Cross-cutting constraints → Edit `research/principles.md` with a `> [Meeting YYYY-MM-DD]` marker
- Direction changes scoped to a specific branch → Edit that branch's note.md (if exists) or log.md
- **Significance rewrite**: When the discussion recontextualizes results, rewrite affected note.md files to reflect that synthesis. Meetings produce understanding that won't propagate to documents unless explicitly written. The meeting is the moment of synthesis — capture it in the documents, not just in the meeting log

**Principle:** Focus on overall direction, not individual node management. Alignment on "what do we want to say with this research."

---

## Deepening the Dialogue

The goal is not AI reporting and ending, but drawing out the user's perspective to co-shape direction. Actively seek the user's judgment in the following situations.

**Turning points in direction:** Get user approval before reflecting structural changes to the narrative structure in `research/story.md` (step additions/deletions/reordering). Present the content, reason, and the option to maintain the status quo.

**Ambiguous statements:** State AI's interpretation explicitly and confirm. Specify exactly what changes to which files before reflecting.

**Interpreting results:** After the progress report, do not just state AI's assessment. Ask the user about the result's positioning in the storyline. If assessments differ, use that as discussion material and explore implications for tree structure and emphasis.

---

## Incremental Recording Principle

Users may leave at any natural stopping point. Post-processing that writes everything at the end risks not being executed. **Record and reflect on the spot, committing as you go.**

| Timing | Action |
|---|---|
| Session start | Create meeting log file in `logs/` + update `last_meeting` (→ see Initialization section) |
| When a topic arises | Append to "Discussion Items" in the meeting log via Edit |
| When a decision is made | Append to "Decisions" + immediately reflect in relevant files. Constraints go to `research/principles.md` |
| When significance is discussed | Rewrite affected note.md files to reflect the synthesis. Record in "Changes Applied" |
| When a file is changed | Append to "Changes Applied" in the meeting log + git commit |

**Git commits:** Specify changed files individually with `git add`, commit in `meeting: {summary of changes}` format.
