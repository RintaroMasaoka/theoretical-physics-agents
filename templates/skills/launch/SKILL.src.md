---
name: launch
description: "Set or change the research theme and direction."
user-invocable: true
argument-hint: "[theme description (optional)]"
---

# Launch

Arguments: $ARGUMENTS

---

## Flow

**Principle: Ask questions first, then load data only as needed.** This skill is real-time dialogue — minimize response delays. Use AskUserQuestion for all questions (text output risks missed responses).

```
Check research/note.md
    ├─ Does not exist → New Theme flow
    └─ Exists → Theme Change flow
If argument is provided → use it as the initial theme description (skip the first AskUserQuestion)
```

### New Theme

Set the research theme and direction from scratch.

```
AskUserQuestion: Ask user to describe the research theme overview in Other
    ▼ AI presents several approach options → Refine direction (2-3 rounds)
    ▼ Present drafted structure and get confirmation before writing
    ▼ Create research/ tree:
        1. research/note.md (thesis + background)
        2. research/story.md (narrative arc)
        3. research/principles.md (approach principles, empty if none)
        4. research/{step}/note.md for each Story Arc step (child nodes)
        5. plan.md (session cursor pointing to the first active child)
```

**Root note (`research/note.md`):**

```markdown
---
kind: narrative
status: active
last_meeting: ""
---
# {Title}

## Thesis
{Core claim of the research}

## Background
{Key references and prior work}
```

**Story arc (`research/story.md`):**

```markdown
# Story Arc

Step 1: **{title}** — {why the reader needs this here} [open]
  → [{child_folder}/]({child_folder}/)
Step 2: ...
```

**Approach principles (`research/principles.md`):**

```markdown
# Approach Principles

{Cross-cutting methodological constraints that apply to the whole project. Leave empty if none yet}
```

**Child nodes (`research/{step}/note.md`):**

```markdown
---
kind: {appropriate kind}
status: open
---
# {description}

## Current State
{Initial assessment}
```

`plan.md` is a lightweight pointer that tells `/run` where to resume work. `/launch` initializes it; `/run` updates it each session.

**Session cursor (`plan.md`):**

```markdown
# Focus

Working on: research/{first_active_child}/
{Why starting here}

## This Session
- (to be filled by /run)
```

**Principle:** The user decides "what" and "why." AI decides "how." AI drafts the wording and confirms with the user.

### Theme Change

Modify the existing research direction. Read `research/note.md` and `research/story.md` first, then present the current state. If the discussion touches specific nodes, navigate the tree and load relevant note.md files before reflecting changes.

```
Data loading: research/note.md + research/story.md
    ▼ Present current theme summary:
        Thesis: {thesis, abbreviated}
        Story Arc: {steps overview with status}
    ▼ AskUserQuestion: What aspect to change?
        - Thesis / research question
        - Story Arc structure (add/remove/reorder steps)
        - Scope (narrow or broaden)
        - Other (free-form)
    ▼ Discuss changes (2-3 rounds)
    ▼ Show concrete changes → get confirmation
    ▼ Reflect in research/ tree
```

**Where to reflect:**
- Thesis / Background → edit `research/note.md`
- Narrative arc → edit `research/story.md`
- Approach principles → edit `research/principles.md`
- New research directions → create child folders with note.md
- Recontextualized results → update affected note.md files in the subtree
- Full pivot → update all root files, restructure children as needed
- Session cursor → update `plan.md` if the current focus node was moved, removed, or is no longer the logical next step
- Leave `> [Launch YYYY-MM-DD] {reason}` markers in affected files at structural changes so `/run` can understand why the tree changed

**Scope of changes:** Match the scale of edits to the scale of the change — a thesis tweak doesn't require restructuring the tree, and a full pivot doesn't preserve stale nodes.

---

## Deepening the Dialogue

Draw out the user's perspective rather than just accepting instructions.

**Approach options:** Present genuine alternatives with trade-offs (scope, difficulty, novelty). Do not present a single "best" option.

**Ambiguous statements:** State AI's interpretation explicitly and confirm. Specify exactly what changes to which files before reflecting.

---

## Recording

Get the current datetime with `Bash("date '+%Y-%m-%dT%H:%M'")` at session start.

| Timing | Action |
|---|---|
| After theme is agreed | Write/update research/ tree + plan.md |
| After files are written | Commit (see below) |

**Git commits:** Specify changed files individually with `git add`. Commit message format: `launch: {summary of what was set or changed}`. If git is not initialized, run `git init` first.
