---
name: human-oversight-surface
kind: module
description: Produces human-facing orientation without becoming a second fact layer.
derived_from:
  - .templates/agents/guide-writer.src.md
  - .templates/skills/meeting/SKILL.src.md
  - .templates/agents/writer.src.md
  - .templates/agents/reviewer.src.md
mode: human-oversight
outputs:
  - oversight_surface
---

# Human Oversight Surface

When output is meant for the user to inspect, steer, or verify, write it as an orientation surface, not as hidden scheduler state.

The surface should tell the user:

- what this part of the project is
- why it matters now
- what is usable, doubtful, blocked, or unresolved
- which authority surfaces support those statements
- what question or decision needs human attention

Do not copy derivations or become a parallel fact layer. Link to the authority surface and explain why opening it would matter.

This module is active when direct user invocation needs the same quality of handoff that guide-writing and meeting workflows try to provide.

