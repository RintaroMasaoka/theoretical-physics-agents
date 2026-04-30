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

**Principle: Ask questions first, then load data only as needed.** This skill is real-time dialogue — minimize response delays. Use {{ runtime.tool_ask_user_question }} for all questions (text output risks missed responses).

```
Check research/log.md
    ├─ Does not exist → New Theme flow
    └─ Exists → Theme Change flow
If argument is provided → use it as the initial theme description (skip the first {{ runtime.tool_ask_user_question }})
```

### New Theme

Set the research theme and direction from scratch.

```
{{ runtime.tool_ask_user_question }}: Ask user to describe the research theme overview in Other
    ▼ AI presents several approach options → Refine direction (2-3 rounds)
    ▼ Present drafted structure and get confirmation before writing
    ▼ Create research/ tree:
        1. research/note.md (project's initial understanding — free-form, no template)
        2. research/log.md (background, working state — with frontmatter)
        3. research/story.md (narrative structure)
        4. research/principles.md (constraints, empty if none)
        5. research/{step}/log.md for each step in the narrative structure (child nodes start with log.md)
        6. research/focus.md (session cursor pointing to the first active child)
```

File formats (note.md, log.md) are defined in `{{ runtime.research_tree_file }}`. The content emerges from the research discussion — there are no prescribed section names. AI drafts the prose and confirms with the user.

**Child folder names** follow the tree-wide naming convention in `{{ runtime.research_tree_file }}` (§ Folder Names): semantic slugs describing the node, not ordering-encoded paths.

**Narrative structure (`research/story.md`):**

```markdown
# Narrative Structure

Step 1: **{title}** — {why the reader needs this here} [open]
  → [{child_folder}/]({child_folder}/)
Step 2: ...
```

**Constraints (`research/principles.md`):**

```markdown
# Constraints

{Cross-cutting research constraints that apply to the whole project. Leave empty if none yet}
```

`research/focus.md` is a lightweight pointer that tells `/run` where to resume work. `/launch` initializes it; `/run` updates it each session.

**Session cursor (`research/focus.md`):**

```markdown
# Focus

Working on: research/{first_active_child}/
{Why starting here}

## This Session
- (to be filled by /run)
```

**Principle:** The user decides "what" and "why." AI decides "how." AI drafts the wording and confirms with the user.

### Theme Change

Modify the existing research direction. Read `research/note.md` (if exists), `research/log.md`, and `research/story.md` first, then present the current state. If the discussion touches specific nodes, navigate the tree and load relevant files before reflecting changes.

```
Data loading: research/note.md + research/log.md + research/story.md
    ▼ Present current theme summary:
        Core understanding: {from note.md, abbreviated}
        Narrative Structure: {steps overview with status}
    ▼ {{ runtime.tool_ask_user_question }}: What aspect to change?
        - Research question / core claims
        - Narrative Structure (add/remove/reorder steps)
        - Scope (narrow or broaden)
        - Other (free-form)
    ▼ Discuss changes (2-3 rounds)
    ▼ Show concrete changes → get confirmation
    ▼ Reflect in research/ tree
```

**Where to reflect:**
- Verified understanding → edit `research/note.md`
- Background / working state → edit `research/log.md`
- Narrative Structure → edit `research/story.md`
- Constraints → edit `research/principles.md`
- New research directions → create child folders with log.md
- Recontextualized results → update affected note.md files in the subtree
- Full pivot → update all root files, restructure children as needed
- Session cursor → update `research/focus.md` if the current focus node was moved, removed, or is no longer the logical next step
- Leave `> [Launch YYYY-MM-DD] {reason}` markers in affected files at structural changes so `/run` can understand why the tree changed

**Scope of changes:** Match the scale of edits to the scale of the change — a minor refinement doesn't require restructuring the tree, and a full pivot doesn't preserve stale nodes.

---

## Deepening the Dialogue

Draw out the user's perspective rather than just accepting instructions.

**Approach options:** Present genuine alternatives with trade-offs (scope, difficulty, novelty). Do not present a single "best" option.

**Ambiguous statements:** State AI's interpretation explicitly and confirm. Specify exactly what changes to which files before reflecting.

---

## Recording

Capture ISO timestamp at session start via `{{ runtime.tool_shell }}("date '+%Y-%m-%dT%H:%M'")` for traceability markers. Obtain the launch log path via `bash .scripts/new-log.sh launch` — the script returns a timestamped path of the form `logs/{YYMMDD_HHMM}_launch.md`; write the launch log to that path.

| Timing | Action |
|---|---|
| After theme is agreed | Write/update research/ tree (including focus.md) |
| After files are written | Write launch log + Commit (see below) |

**Launch log:** Obtain the path via `bash .scripts/new-log.sh launch` (returns `logs/{YYMMDD_HHMM}_launch.md`); write to that path (permanent record):

```markdown
# Launch YYYY-MM-DD HH:MM

## Theme
{theme description or change summary}

## Structure Created
- {files and directories created or modified}

## Decisions
- {key decisions made during the session}
```

**Git commits:** Specify changed files individually with `git add`. Commit message format: `launch: {summary of what was set or changed}`. If git is not initialized, run `git init` first.
