---
name: runtime-context-loading
kind: module
description: Selects the minimal project context appropriate to a run's role, target, and evidence question.
derived_from:
  - .templates/agents/research-planner.src.md
  - .templates/agents/curator.src.md
  - .templates/agents/critic.src.md
  - .templates/agents/simulator.src.md
  - .templates/agents/writer.src.md
  - .templates/agents/guide-writer.src.md
mode: context-loading
outputs:
  - context_plan
---

# Runtime Context Loading

Load context according to the role of the run, not according to curiosity.

The repeated rule in the current agents is that each role has a context aperture:

- direction work follows the cursor and ancestor chain
- curation reads broadly enough to close memory transactions
- blind review avoids broader context to prevent expectation bias
- source audit reads source records and paper files, not project usefulness
- guide writing reads durable surfaces for human orientation
- implementation work reads the target, relevant libraries, and local material indexes

Before opening files, decide what the run is faithful to: direction, memory placement, source fidelity, internal correctness, human oversight, or artifact execution. Then load only the surfaces needed for that fidelity target.

If the needed context is missing, record the missing surface instead of compensating with broad search.

