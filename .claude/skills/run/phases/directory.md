# Phase: Directory Structure

This phase file is a reference that PI Reads during `/run` to locate files in the project. It is not an execution step; it is a layout map. Pair with `architecture.md` (concepts) — this file answers "where does thing X live on disk" and complements architecture's "why is thing X a separate file".

---

```
research/                 # Research tree — the single knowledge structure
  note.md                 #   Root: verified knowledge (SoT, free-form)
  plan.md                 #   Root: strategy and decomposition
  log.md                  #   Root: background, working state (ladder)
  focus.md               #   Session cursor: "work here now"
  lib/                    #   Shared simulation framework (engine-builder)
    test/                 #     Module tests
  {Branch Name}/          #   Research direction (Title Case with spaces)
    note.md               #     Verified knowledge (free-form prose)
    plan.md               #     (optional) Strategy and approach for this branch
    log.md                #     Research process (current state, evidence)
    report_{slug}.md      #     (optional) PI-verified report (format: see .claude/research-tree.md)
    dead_ends.md          #     (optional) Failed approaches and lessons
    directives.md         #     (optional) Subtree-specific rules from meetings
    src/                  #     Measurement scripts and descriptions (simulator)
    data/                 #     Simulation data (simulator)
    images/               #     Figures and visualizations (simulator)
    {Child Name}/
      log.md              #     Leaf: may only have log.md (no note.md yet)
directives.md             # Project-wide methodology rules from meetings
concepts/                 # Concept definitions (one term per file)
  {term}.md
literature/
  reading_list.md
  papers/{arxiv_id}/
manuscript/               # Paper (managed by /write)
logs/                     # Worker deliverables + chronological history
  {timestamp}_{type}_{slug}.md  # Worker deliverables (reading notes, attempts, etc.)
  {timestamp}_{agent}.md  #   Worker logs (brief work summaries)
  {timestamp}_run.md      #   Session logs (PI's session records)
  last_session.md         #   Session handoff (overwrite each session)
agenda.md                 # Items for next meeting (consumed by /meeting)
```

## Root Files

File formats (note.md, plan.md, log.md) are defined in `.claude/research-tree.md`. This section covers only files specific to `/run` operations.

### Directives (`directives.md`)

Rules imposed by the user through meetings. PI cannot create or modify directives unilaterally. At any level: project root for global rules, subtree folders for scoped rules. Higher-level directives cascade to descendants.

```markdown
# Directives

## {Topic area}
- {rule}
  > [Meeting YYYY-MM-DD] {reason for this rule}
```

### Dead Ends (`dead_ends.md`)

Optional. For nodes where approaches have been tried and failed. Prevents log.md from accumulating failed-approach details that obscure the working state.

```markdown
# Dead Ends

## {Approach name}
**Tried**: {what was attempted}
**Failed because**: {root cause, not just symptoms}
**Lesson**: {what to avoid or keep in mind}
```

### Session Cursor (`research/focus.md`)

A ~10–20 line file. No frontmatter. Overwritten at each session end (see `session-end.md` for the template). Points to the current focus node and carries short-term context only.

### concepts/ — Concept Definitions

Atomic definitions (one term per file). Linked from notes via explicit Markdown links. Concept-checker and curator manage creation and maintenance; PI may also create them.
