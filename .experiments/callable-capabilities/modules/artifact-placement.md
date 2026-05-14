---
name: artifact-placement
kind: module
description: Chooses artifact locations by authority, lifetime, audience, and later reuse.
derived_from:
  - .templates/skills/auto/phases/directory.src.md
  - .templates/skills/auto/phases/architecture.src.md
  - .templates/agents/simulator.src.md
  - .templates/agents/engine-builder.src.md
  - .templates/agents/reader.src.md
  - .templates/agents/concept-checker.src.md
  - .templates/agents/critic.src.md
mode: placement
outputs:
  - placement_decision
---

# Artifact Placement

Place artifacts according to what they are for, not according to which run happened to create them.

Useful distinctions:

- raw audit trail belongs in `.logs/` or a run record
- reviewable worker evidence belongs in `_reviews/{slug}/`
- durable source records belong in `literature/notes/`
- reusable reader bridges belong in `concepts/`
- computation source, data, images, and analyses belong under the owning research node's `_materials/`
- independent checks belong under `checks/`
- active research memory belongs in `state.md`, `map.md`, `plan.md`, `findings.md`, or related node surfaces according to curator authority

If the artifact's authority or lifetime is ambiguous, do not choose the most convenient path. Record the ambiguity and route the decision to the owning role.

