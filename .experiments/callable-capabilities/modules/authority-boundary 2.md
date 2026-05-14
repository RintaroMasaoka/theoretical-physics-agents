---
name: authority-boundary
kind: module
description: Preserves existing role ownership when a direct or internal invocation could cross direction, evidence, review, or tree-write boundaries.
derived_from:
  - .templates/AGENTS.src.md
  - .templates/agents/research-planner.src.md
  - .templates/agents/curator.src.md
  - .templates/agents/critic.src.md
  - .templates/agents/reader.src.md
  - .templates/agents/scout.src.md
  - .templates/agents/guide-writer.src.md
mode: authority
outputs:
  - authority_assessment
---

# Authority Boundary

Before acting, identify which role owns the decision being requested.

Current ownership pattern:

- user: broad direction, oversight, explicit overrides
- research planner: scientific direction, cursor, worker dispatches, tree directives
- curator: graph mechanics, state absorption, placement, lifecycle, provenance closure
- critic: independent verification
- workers: bounded evidence or artifact production
- reader/scout/reference roles: source-side acquisition and fidelity, not project relevance
- guide-writer: human oversight prose, not fact authority

When a request crosses ownership, do not smuggle the decision into implementation. Either route it to the owning role, record the authority gap, or ask the user when the workflow allows interaction.

The purpose is not bureaucracy. Authority boundaries keep later agents from mistaking process output, source text, user vocabulary, or provisional evidence for durable project truth.

