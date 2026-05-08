# Phase: Directory Structure

This phase file is a reference that research planner reads during `/auto` to locate files in the project. It is not an execution step; it is a layout map. Pair with `architecture.md` — this file answers "where does thing X live on disk" and complements architecture's "why is thing X a separate file".

---

```
research/                 # Research tree — draft facts, state, strategy, graph
  findings.md                 #   Root: draft fact layer (free-form)
  guide.md                 #   Root: human oversight entrypoint
  plan.md                 #   Root: strategy and decomposition
  backlog.md              #   Root: project-wide parked work
  state.md                #   Root: current board + absorbed evidence
  focus.md               #   Session cursor: "work here now"
  story.md                #   Root: paper narrative structure
  principles.md           #   Root: project-wide research judgment principles
  conventions.md          #   Root: project-wide notation and convention ledger
  dead_ends.md            #   Root: rejected-direction register
  asides.md               #   Root: parked off-thread items
  _materials/lib/                    #   Shared simulation framework (engine-builder)
    test/                 #     Module tests
  {Branch Name}/          #   Research direction (Title Case with spaces)
    findings.md               #     Draft facts (free-form prose)
    guide.md               #     (optional) Human oversight entrypoint for this branch
    sources.md            #     (optional) Node-local map of external source records and intended uses
    plan.md               #     (optional) Strategy and approach for this branch
    backlog.md            #     (optional) Parked work scoped to this subtree
    state.md              #     Current board + absorbed evidence
    _reviews/             #     (optional) Provisional worker-critic transactions
      {slug}/
        worker.md         #       Worker submission / candidate
        critic.md         #       Critic Provisional Review
        repair.md         #       Optional one repair
        critic_rereview.md
    _materials/analyses/              #     (optional) Clean analyses; material support, not fact authority
      {slug}.md           #       Format: see .codex/research-tree.md
    checks/               #     (optional) Durable verification records and reviews
      {slug}.md           #       YAML frontmatter required; format by record kind
    dead_ends.md          #     (optional) Failed approaches and lessons
    asides.md             #     (optional) Parked off-thread items scoped to this subtree
    principles.md         #     (optional) Subtree-specific research judgment principles
    conventions.md        #     (optional) Subtree-specific notation/convention choices
    _materials/src/                  #     Measurement scripts and descriptions (simulator)
    _materials/data/                 #     Simulation data (simulator)
    _materials/images/               #     Figures and visualizations (simulator)
    {Child Name}/
      state.md              #     Leaf: may only have state.md (no findings.md yet)
concepts/                 # Reusable reader bridges (one scoped explainer per file)
  {term}.md
literature/
  catalog.jsonl
  reading_list.md       # Generated human view of catalog.jsonl; do not edit by hand
  references.bib
  _reviews/{arxiv_id}/   # Source-reading worker/critic transactions
  notes/{arxiv_id}.md    # Durable paper-level source records managed by reader
  papers/{arxiv_id}/
manuscript/               # Frozen / reserved future paper authority
draft/                    # /write paper-draft workspace; not authority
  outline.md
  conventions.md
  sections/{N}_{slug}.md
  versions/v{N}.md
.logs/                    # Raw chronological audit archive
  {timestamp}_{type}_{slug}.md  # Raw process logs, not critic targets by default
  {timestamp}_{agent}.md  #   Brief work summaries
  {timestamp}_auto.md      #   Session logs
  last_session.md         #   Session handoff (overwrite each session)
agenda.md                 # Items for next meeting (consumed by /meeting)
```

## Root Files

File formats (findings.md, guide.md, plan.md, backlog.md, state.md) are defined in `.codex/research-tree.md`. This section covers only files specific to `/auto` operations.

### Research Principles (`research/**/principles.md`)

Reusable research judgment principles that constrain future reasoning in the project or subtree. These are not general meeting notes, route priorities, source priorities, notation choices, fact claims, or framework workflow rules. Higher-level principles cascade to descendants unless a lower-level principle narrows or supersedes them.

```markdown
# Research Principles

## {Principle name}
Scope: {project-wide | research/{subtree}/ | specific recurring judgment}
Principle: {the reusable judgment rule}
Reason: {why this principle exists}
Consequence: {what future agents should accept, reject, separate, or route differently because of it}
Origin: > [Meeting YYYY-MM-DD] {short reason}
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

Compact, but always in the structured format required by `.codex/agents/research-planner.md` § `research/focus.md` Format. No frontmatter. Overwritten at each session end (see `session-lifecycle.md` for the handoff). Points to the current focus node and carries short-term context only.

### concepts/ — Reusable Reader Bridges

Scoped explanations for reusable terms. Linked from findings.md or _materials/analyses when helpful, but not authority for project facts, conventions, or workflow state. Concept-checker proposes notes through reviewed `_reviews/` worker submissions; curator/maintenance agents create and maintain the durable files. The user may also create them.
