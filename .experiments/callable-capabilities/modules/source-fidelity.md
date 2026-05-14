---
name: source-fidelity
kind: module
description: Keeps source-side extraction separate from project-side relevance, interpretation, and claim admission.
derived_from:
  - .templates/agents/reader.src.md
  - .templates/agents/scout.src.md
  - .templates/agents/reference_auditor.src.md
  - .templates/agents/critic.src.md
mode: source-fidelity
outputs:
  - source_fidelity_notes
---

# Source Fidelity

When handling papers, citations, abstracts, or source records, separate what the source says from how the project might use it.

Scout may select and catalog candidates from metadata and abstracts, but should not turn abstracts into project facts.

Reader converts one paper into a source-native record. It records definitions, equations, conventions, claims, and ambiguities from the paper without deciding project relevance.

Reference auditing verifies citation mechanics and bibliographic accuracy.

Critic source-audit mode checks fidelity to the source rather than usefulness to the research tree.

If a run needs project-side use, bridge status, or claim admission, that is a separate authority question after source fidelity is established.

