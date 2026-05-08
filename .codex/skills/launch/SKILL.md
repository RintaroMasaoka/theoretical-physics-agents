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

**Principle: Ask questions first, then load data only as needed.** This skill is real-time dialogue — minimize response delays. Use request_user_input for all questions (text output risks missed responses).

```
Check research/state.md
    ├─ Does not exist → New Theme flow
    └─ Exists → Theme Change flow
If argument is provided → use it as the initial theme description (skip the first request_user_input)
```

### New Theme

Set the research theme and direction from scratch.

```
request_user_input: Ask user to describe the research theme overview in Other
    ▼ AI presents several approach options → Refine direction (2-3 rounds)
    ▼ Present drafted structure and get confirmation before writing
    ▼ Create research/ tree:
        1. research/findings.md (project's initial understanding — free-form, no template)
        2. research/guide.md (human oversight entrypoint — what to watch, ask, and read first)
        3. research/state.md (background, working state — with frontmatter)
        4. research/story.md (narrative structure)
        5. research/principles.md (research principles, only if reusable principles are already known)
        6. research/{step}/state.md for each step in the narrative structure (child nodes start with state.md)
        7. research/focus.md (session cursor pointing to the first active child)
```

File formats (findings.md, guide.md, state.md) are defined in `.codex/research-tree.md`. The content emerges from the research discussion — findings.md captures reusable draft facts, guide.md captures the human oversight entrypoint, and state.md captures working state. AI drafts the prose and confirms with the user.

**Child folder names** follow the tree-wide naming convention in `.codex/research-tree.md` (§ Folder Names): semantic slugs describing the node, not ordering-encoded paths.

**Narrative structure (`research/story.md`):**

```markdown
# Narrative Structure

Step 1: **{title}** — {why the reader needs this here} [open]
  → [{child_folder}/]({child_folder}/)
Step 2: ...
```

**Research principles (`research/principles.md`, optional):**

```markdown
# Research Principles

## {Principle name}
Scope: project-wide
Principle: {reusable judgment rule that will constrain future research decisions}
Reason: {why this principle exists}
Consequence: {what agents should accept, reject, separate, or route differently because of it}
Origin: > [Launch YYYY-MM-DD] {short reason}
```

Create this file only when the launch discussion has produced an actual reusable research judgment principle. Do not create an empty placeholder. Research goals, narrative success conditions, route priorities, source priorities, notation choices, and workflow/file-format rules belong in `story.md`, `plan.md`, `sources.md`/`backlog.md`, `conventions.md`, or the framework prompts instead.

`research/focus.md` is a lightweight pointer that tells `/auto` where to resume work. `/launch` initializes it; `/auto` updates it each session.

**Session cursor (`research/focus.md`):**

```markdown
# Focus

Cursor: research/{first_active_child}/
Status: active

## Context
{2-5 sentences: why starting here and what is live at the cursor}

## Direction Challenge Response
- Launch initialization: no prior direction challenge; starting from the first active child because {why this is the right first focus}

## Next Session

### Worker Dispatches
- (to be filled by research planner or /auto)

### Tree Directives
- (empty unless launch created a structural cleanup directive)

## Blockers
{empty unless launch identified a blocker}
```

**Principle:** The user decides "what" and "why." AI decides "how." AI drafts the wording and confirms with the user.

### Theme Change

Modify the existing research direction. Read `research/findings.md` (if exists), `research/guide.md` (if exists), `research/state.md`, and `research/story.md` first, then present the current state. If the discussion touches specific nodes, navigate the tree and load relevant files before reflecting changes.

```
Data loading: research/findings.md + research/guide.md + research/state.md + research/story.md
    ▼ Present current theme summary:
        Core understanding: {from findings.md, abbreviated}
        Human oversight: {from guide.md if present}
        Narrative Structure: {steps overview with status}
    ▼ request_user_input: What aspect to change?
        - Research question / core claims
        - Narrative Structure (add/remove/reorder steps)
        - Scope (narrow or broaden)
        - Other (free-form)
    ▼ Discuss changes (2-3 rounds)
    ▼ Show concrete changes → get confirmation
    ▼ Reflect in research/ tree
```

**Where to reflect:**
- Verified understanding → edit `research/findings.md`
- Human-facing orientation / doubts / reading path → edit `research/guide.md`
- Background / working state → edit `research/state.md`
- Narrative Structure → edit `research/story.md`
- Reusable research judgment principles → edit `research/principles.md`
- New research directions → create child folders with state.md
- Recontextualized results → update affected findings.md files in the subtree
- Full pivot → update all root files, restructure children as needed
- Session cursor → update `research/focus.md` if the current focus node was moved, removed, or is no longer the logical next step
- Leave `> [Launch YYYY-MM-DD] {reason}` markers only on structural/state surfaces where chronology belongs: `story.md`, `plan.md`, `state.md` Evidence/Revisions, and `principles.md` Origin fields. Never put launch markers in `findings.md` fact prose.

**Scope of changes:** Match the scale of edits to the scale of the change — a minor refinement doesn't require restructuring the tree, and a full pivot doesn't preserve stale nodes.

---

## Deepening the Dialogue

Draw out the user's perspective rather than just accepting instructions.

**Approach options:** Present genuine alternatives with trade-offs (scope, difficulty, novelty). Do not present a single "best" option.

**Ambiguous statements:** State AI's interpretation explicitly and confirm. Specify exactly what changes to which files before reflecting.

---

## Recording

Capture ISO timestamp at session start via `exec_command("date '+%Y-%m-%dT%H:%M'")` for traceability markers. Obtain the launch log path via `bash .scripts/log-path.sh launch` — the script returns a timestamped path of the form `.logs/{YYMMDD_HHMM}_launch.md`; write the launch log to that path.

| Timing | Action |
|---|---|
| After theme is agreed | Write/update research/ tree (including focus.md) |
| After files are written | Write launch log + Commit (see below) |

**Launch log:** Obtain the path via `bash .scripts/log-path.sh launch` (returns `.logs/{YYMMDD_HHMM}_launch.md`); write to that path (permanent record):

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
