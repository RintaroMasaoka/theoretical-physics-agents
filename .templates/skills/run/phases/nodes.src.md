# Phase: Node Management

This phase file is a reference that PI Reads during `/run` when creating, modifying status, or closing a research tree node. Naming conventions, `kind` (cognitive mode), `status` (PI's disposition), and closing mechanics all live here.

---

## Naming Convention

Folders are named in **Title Case with spaces**, using **semantic slugs** that describe the research content (e.g., `research/Winding Gap/`, not `research/01_analysis/`). **No ordering-encoded prefixes** — numbering forces manual reordering as the tree evolves and couples the path to presentation-layer concerns. Canonical rationale: `{{ runtime.research_tree_file }}` § Folder Names.

## kind (Cognitive Mode)

kind defines the nature of a node and determines the **cognitive mode** when passing it to the researcher. PI may introduce new kinds.

| kind | Cognitive Mode | Description |
|------|---------------|-------------|
| **narrative** | Tell the story | Paper's argument and proof flow. Not something to "solve" |
| **task** | Execute concretely | Clear work (proof, construction, calculation) |
| **subtask** | Execute part of a task | A portion of a parent task |
| **question** | Investigate (answer may not exist) | Genuinely unknown. Accepts no-answer or ill-posed |
| **conjecture** | Prove or refute | Believed true but unverified |
| **example** | Calculate precisely on a concrete case | Concrete verification of theory |
| **caution** | Verify risks in assumptions/logic | Finding problems is the job |
| **gap** | Analyze what's missing | Analysis, not resolution |
| **observation** | Record and explore a finding | PI decides whether to pursue |

## status (PI's Disposition)

| status | PI's disposition |
|--------|---------|
| **open** | Not yet started |
| **active** | Currently investing cycles |
| **stable** | Has results PI can reference. Deepening is always an option |
| **closed** | Not being pursued |

## Closing Nodes

Update status to `closed`. If the closure is informative, add an entry to the node's `dead_ends.md`. If the node has a plan.md describing children, update or remove it to reflect the closure. If the closed node has active/stable children, reparent them (move the subfolder to an appropriate location).
