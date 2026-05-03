# Phase: Node Management

This phase file is a reference that `/run` Reads when reasoning about research tree nodes. Naming conventions, `kind` (cognitive mode), `status` (research disposition), and the authority split for node operations live here.

---

## Naming Convention

Folders are named in **Title Case with spaces**, using **semantic slugs** that describe the research content (e.g., `research/Winding Gap/`, not `research/01_analysis/`). **No ordering-encoded prefixes** — numbering forces manual reordering as the tree evolves and couples the path to presentation-layer concerns. Canonical rationale: `{{ runtime.research_tree_file }}` § Folder Names.

## kind (Cognitive Mode)

kind defines the nature of a node and determines the **cognitive mode** when passing it to the researcher. Research planner may propose new kinds in `research/focus.md`; curator records the chosen kind in the node's state.md frontmatter when creating or updating the node.

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
| **observation** | Record and explore a finding | Research planner decides whether to pursue |

## status (Research Disposition)

| status | Research disposition |
|--------|---------|
| **open** | Not yet started |
| **active** | Currently investing cycles |
| **stable** | Has results the research planner and later manuscript workflows can reference. Deepening is always an option |
| **closed** | Not being pursued |

## Closing Nodes

Research planner decides the research verdict and expresses it as a Tree Directive; curator executes the tree write. Update status to `closed`. If the closure is informative, add an entry to the node's `dead_ends.md`. If the node has a plan.md describing children, update or remove it to reflect the closure. If the closed node has active/stable children, reparent them (move the subfolder to an appropriate location).

## Splitting Nodes

Node splitting is a structural-maintenance operation, not a cosmetic cleanup. A node exists to keep one coherent evidence stream, strategy, and worker context together. When a parent starts carrying separable evidence streams, keeping everything in the parent makes future dispatches worse: workers receive muddy context, plan.md stops explaining the actual decomposition, and Current Board becomes a list of unrelated frontiers.

Authority is deliberately split:

- **Research planner** requests splits when the scientific direction needs a child node. It names the sub-question and why it now deserves independent focus.
- **Curator** executes the split and may initiate one from the maintenance side when the evidence record already shows structural debt. Curator scans the whole tree every dispatch, so it is the agent positioned to notice broad overloaded nodes even when research planner is focused on the cursor's immediate direction.

Typical triggers: repeated attempts on the same sub-problem, several Evidence entries sharing a sub-target, a compound construction with separable phases or artifacts, three or more open angles in Current Board, or repeated recent evidence that the parent's plan.md does not account for.
