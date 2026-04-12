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
Check plan.md
    ├─ No existing theme → New Theme flow
    └─ Theme exists → Theme Change flow
If argument is provided → use it as the initial theme description (skip the first AskUserQuestion)
```

### New Theme

Set the research theme and direction from scratch.

```
AskUserQuestion: Ask user to describe the research theme overview in Other
    ▼ AI presents several approach options → Refine direction (2-3 rounds)
    ▼ Present drafted plan.md structure and get confirmation before writing
    ▼ Create plan.md with the agreed structure
    ▼ If user was redirected here from /meeting, suggest running /meeting now
```

**plan.md skeleton:**

```markdown
<!-- {topic_slug} [{status}]: {one-line summary} -->
# Research Plan: {Title}

## Thesis

{Core claim of the research}

## Story Arc

Step 1: **{title}** — {description} [{status}]
Step 2: ...

## Approach Principles

- {principle}
  > [Launch YYYY-MM-DD] {reason}

## Strategy Notes

### 現在のフェーズ: {phase description}

{Current status, next steps, open questions}

## Background

- {key references and prior work}
```

**Where to reflect:**
- Set topic, field, created_at in `plan.md` frontmatter (HTML comment on line 1)
- Populate all sections shown in the skeleton above

**Principle:** The user decides "what" and "why." AI decides "how." AI drafts the wording of questions and confirms with the user.

### Theme Change

Modify the existing research direction. Read `plan.md` first, then present the current state. If the discussion touches specific research items, load relevant `items/*.md` before reflecting changes.

```
Data loading: plan.md
    ▼ Present current theme summary:
        Theme: {topic}
        Thesis: {thesis, abbreviated}
        Story Arc: {steps overview}
    ▼ AskUserQuestion: What aspect to change?
        - Thesis / research question
        - Story Arc structure (add/remove/reorder steps)
        - Scope (narrow or broaden)
        - Other (free-form)
    ▼ Discuss changes (2-3 rounds)
    ▼ Show concrete diff summary of plan.md changes → get confirmation
    ▼ Reflect in plan.md
```

**Where to reflect:**
- Edit `plan.md` directly. Leave a `> [Launch YYYY-MM-DD] {reason for change}` marker at structural changes so PI can understand the context
- If the change recontextualizes existing results, update affected items' context in `items/*.md` and `Strategy Notes` in `plan.md`
- On a full pivot, update `topic` and `field` in frontmatter as well

**Scope of changes:** Theme changes can range from minor thesis refinements to complete pivots. Match the scale of plan.md edits to the scale of the change — a thesis tweak does not require rewriting Story Arc, and a full pivot does not preserve stale steps.

---

## Deepening the Dialogue

Draw out the user's perspective rather than just accepting instructions.

**Approach options:** When presenting approach options, include trade-offs (scope, difficulty, novelty). Do not present a single "best" option — present genuine alternatives so the user can exercise judgment.

**Ambiguous statements:** When user statements are ambiguous, state AI's interpretation explicitly and confirm. Specify exactly what changes to plan.md before reflecting.

---

## Recording

Get the current datetime with `Bash("date '+%Y-%m-%dT%H:%M'")` at session start.

| Timing | Action |
|---|---|
| After theme is agreed | Write/update `plan.md` |
| After plan.md is written | Commit (see below) |

**Git commits:** Specify changed files individually with `git add` (prevent unintended file inclusion). Commit message format: `launch: {summary of what was set or changed}`. If git is not initialized, run `git init` first, then add and commit the same way.
