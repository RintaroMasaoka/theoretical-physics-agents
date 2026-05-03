# Phase: Directory Structure

This phase file is a reference that research planner reads during `/run` to locate files in the project. It is not an execution step; it is a layout map. Pair with `architecture.md` — this file answers "where does thing X live on disk" and complements architecture's "why is thing X a separate file".

---

```
research/                 # Research tree — draft facts, state, strategy, graph
  note.md                 #   Root: draft fact layer (free-form)
  plan.md                 #   Root: strategy and decomposition
  backlog.md              #   Root: project-wide parked work
  state.md                #   Root: current board + absorbed evidence
  focus.md               #   Session cursor: "work here now"
  lib/                    #   Shared simulation framework (engine-builder)
    test/                 #     Module tests
  {Branch Name}/          #   Research direction (Title Case with spaces)
    note.md               #     Draft facts (free-form prose)
    sources.md            #     (optional) Node-local map of external source records and intended uses
    plan.md               #     (optional) Strategy and approach for this branch
    backlog.md            #     (optional) Parked work scoped to this subtree
    state.md              #     Current board + absorbed evidence
    report_{slug}.md      #     (optional) Clean analysis artifact (format: see .claude/research-tree.md)
    dead_ends.md          #     (optional) Failed approaches and lessons
    directives.md         #     (optional) Subtree-specific rules from meetings
    src/                  #     Measurement scripts and descriptions (simulator)
    data/                 #     Simulation data (simulator)
    images/               #     Figures and visualizations (simulator)
    {Child Name}/
      state.md              #     Leaf: may only have state.md (no note.md yet)
directives.md             # Project-wide methodology rules from meetings
concepts/                 # Reusable reader bridges (one scoped explainer per file)
  {term}.md
literature/
  catalog.jsonl
  reading_list.md       # Generated human view of catalog.jsonl; do not edit by hand
  references.bib
  notes/{arxiv_id}.md    # Durable paper-level source records managed by reader
  papers/{arxiv_id}/
manuscript/               # Human-authorized, fully self-contained paper surface
draft/                    # /write paper-draft workspace; not authority
  outline.md
  conventions.md
  sections/{N}_{slug}.md
  versions/v{N}.md
.logs/                    # Raw chronological audit archive
  {timestamp}_{type}_{slug}.md  # Worker deliverables (reading notes, attempts, etc.)
  {timestamp}_{agent}.md  #   Worker logs (brief work summaries)
  {timestamp}_run.md      #   Session logs
  last_session.md         #   Session handoff (overwrite each session)
agenda.md                 # Items for next meeting (consumed by /meeting)
```

## Root Files

File formats (note.md, plan.md, backlog.md, state.md) are defined in `.claude/research-tree.md`. This section covers only files specific to `/run` operations.

### Directives (`directives.md`)

Rules imposed by the user through meetings. Research planner cannot create or modify directives unilaterally. At any level: project root for global rules, subtree folders for scoped rules. Higher-level directives cascade to descendants.

```markdown
# Directives

## {Topic area}
- {rule}
  > [Meeting YYYY-MM-DD] {reason for this rule}
```

### Dead Ends (`dead_ends.md`)

Optional. For nodes where approaches have been tried and failed. Prevents state.md from accumulating failed-approach details that obscure the working state.

```markdown
# Dead Ends

## {Approach name}
**Tried**: {what was attempted}
**Failed because**: {root cause, not just symptoms}
**Lesson**: {what to avoid or keep in mind}
```

### Session Cursor (`research/focus.md`)

A ~10–20 line file. No frontmatter. Overwritten at each session end (see `session-lifecycle.md` for the handoff). Points to the current focus node and carries short-term context only.

### concepts/ — Reusable Reader Bridges

Scoped explanations for reusable terms. Linked from notes when helpful, but not authority for project facts, conventions, or workflow state. Concept-checker proposes notes through reviewed `.logs/` deliverables; curator/maintenance agents create and maintain the durable files. The user may also create them.
