---
name: session-handoff
kind: module
description: Preserves continuity across sessions without turning active research memory into a raw chronology.
derived_from:
  - .templates/agents/research-planner.src.md
  - .templates/agents/session-wrap-up.src.md
  - .templates/skills/auto/phases/session-lifecycle.src.md
mode: lifecycle
outputs:
  - handoff_notes
---

# Session Handoff

Use this module when a run affects what the next session must know.

Session handoff is not a transcript. It should preserve:

- current cursor or active work position
- what changed that future direction-setting depends on
- unresolved blockers or verification gaps
- durable backlog items scoped to the correct node or project level
- failures that a future run must work around

Do not use handoff surfaces for claims, evidence, or strategy rationale that belongs in the research tree. The handoff points future agents to durable surfaces; it does not replace them.

