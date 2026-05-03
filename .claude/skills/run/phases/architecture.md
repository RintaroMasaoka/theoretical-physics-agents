# Phase: Information Architecture

This phase file is a reference that research planner reads during `/run` to understand the research information model. It is not an execution step; it is the conceptual backdrop for every cycle. Load it when forming direction, and refer back when a tree-editing decision needs the canonical ownership / scoping rules.

---

Research information forms a **tree** under `research/`. Research planner navigates this tree depth-first, with `research/focus.md` as a session cursor that scopes the working context.

## The Research Tree (`research/`)

Every node is a **folder**. File formats are defined in `.claude/research-tree.md` (the canonical reference). Key points for research planner:

**Layer classification**: each file has a typed identity. `manuscript/` is the human-authorized, fully self-contained paper surface and highest authority. `note.md` is the research tree's draft fact layer. `state.md` is the graph-structured current board plus absorbed evidence ledger. `plan.md` is strategy and decomposition. `backlog.md` is parked executable reminders. `.logs/` is the raw chronological audit archive and is not linked from durable research prose.

| File | Layer | Accumulation | Role |
|---|---|---|---|
| `note.md` | Draft facts | Overwrite | **Fact layer.** Established claims, definitions, derivations or derivation skeletons, scope, limitations, and source/project boundaries. Lower authority than `manuscript/`; no workflow state. Canonical spec: `.claude/research-tree.md` § note.md |
| `conventions.md` | Convention ledger | Overwrite | **Notation and convention source of truth.** Current sign/order/normalization/symbol choices needed to read formulas in this project or subtree. Canonical spec: `.claude/research-tree.md` § conventions.md |
| `sources.md` | Source map | Overwrite | **Node-local external-source map.** Links to `literature/notes/{id}.md`, records source questions, intended node-local uses, explicit non-uses, and bridge status. Not a source record, not a fact layer, not a convention ledger |
| `plan.md` | Ladder | Overwrite | **Strategy and approach.** Decomposition rationale, approach decisions, children's roles. Rewritten as strategy evolves |
| `state.md` | Research state | Overwrite + Append | **Current board + absorbed evidence.** Graph-structured state for later agents; no `.logs/` links |
| `backlog.md` | Backlog | Overwrite | **Parked executable reminders.** Pending work scoped to this node/subtree; root `research/backlog.md` is project-wide. No claims, evidence, or durable strategy |
| `dead_ends.md` | Ladder | Append-only | Failed approaches and lessons learned. Prevents state.md bloat |
| `directives.md` | — | Append (meetings only) | Rules and conventions imposed by the user. Autonomous agents cannot modify unilaterally |

Children are subfolders. The tree can nest to arbitrary depth.

- **Creating a node**: research planner requests the child in `research/focus.md § Tree Directives`, or curator creates it from structural-maintenance judgment. Curator runs `mkdir "research/{Topic Name}"`, writes `state.md`, and writes `plan.md` when the node has non-trivial strategic decisions (decomposition, approach choice). `backlog.md` is created only when there is durable pending work scoped to that node/subtree.
- **Recording a dead end**: research planner states the closure or retraction verdict in Tree Directives; curator appends `dead_ends.md` in the node folder when the closure carries a lesson
- **Adding a directive**: write `directives.md` in the folder where the rule applies (typically project root; only through meetings)
- **Seeing children**: `ls` the folder (subfolders = children)

## Context Scoping

**The ancestor chain is research planner's context spine.** When the cursor points to a node, research planner reads along the path from root to cursor — every folder's note.md, sources.md, conventions.md, plan.md, state.md, dead_ends.md, and directives.md. Sibling branches are not loaded.

```
research/                          ← read note.md + sources.md + conventions.md + plan.md + state.md + dead_ends.md + directives.md
  └─ Lattice BKT/                  ← read note.md + sources.md + conventions.md + plan.md + state.md + dead_ends.md + directives.md
       └─ Winding Gap/             ← cursor: read note.md + sources.md + conventions.md + plan.md + state.md + dead_ends.md + directives.md + direct children's note.md + sources.md + conventions.md + plan.md + state.md
  └─ Paradox Resolution/           ← NOT loaded (sibling branch)
```

Directives cascade: a directive at a higher level applies to all descendants. Dead ends at ancestors are also loaded — lessons learned higher in the tree prevent repeating mistakes in subtrees.

| Scope | What research planner loads | When |
|---|---|---|
| **Ancestor chain** | note.md + sources.md + plan.md + state.md + backlog.md + conventions.md + dead_ends.md + directives.md at each ancestor from root to cursor | Each research planner dispatch |
| **Working context** | Cursor node's direct children: note.md + sources.md + conventions.md + plan.md + state.md (depth 1 only) | Each research planner dispatch |
| **Project directives** | `directives.md` at project root (if exists; outside research/) | Each research planner dispatch |
| **Writing context** | note.md + applicable conventions.md at each node (ladder files excluded) | /write |

## Session Cursor (`research/focus.md`)

research/focus.md is a lightweight cursor pointing to research planner's current position in the tree. It carries:
- Current focus path
- Short-term context (blockers, immediate next steps)
- Rewritten by research planner at the start of every cycle (regular dispatch) and at session end (transcribed by `session-wrap-up` from the wrap-up-input file's `## Focus` section). See `session-lifecycle.md § Session End` for the wrap-up-input path-creation step.

## Supporting Layers

| Layer | Location | Role |
|---|---|---|
| **Raw audit archive** | `.logs/{timestamp}_{type}_{slug}.md` | Worker/session intermediate outputs used for audit, archaeology, contamination tracing, and workflow improvement. Not a normal context surface and not linked from durable prose |
| **Source records** | `literature/notes/{id}.md` | Reader-managed paper-level source records. Source-facing and project-independent; normal agents cite these instead of `.logs/*reading*` |
| **Node source maps** | `research/**/sources.md` | Research-planner-managed maps from node questions to source records and bridge status. They do not contain source-note bodies or project facts |
| **Concept explainers** | `concepts/` | Reusable reader bridges. Not authority for project facts, conventions, or workflow state |
| **Convention ledgers** | `research/**/conventions.md` | Notation, sign, ordering, normalization, and symbol-reservation choices scoped to the project or subtree |
| **Session handoff** | `.logs/last_session.md` | Operational detail and research planner thinking for next session. Overwritten each session |
| **Session log** | `.logs/{timestamp}_run.md` | Permanent per-session record. One file per session, never overwritten |

## Why This Separation Matters

The typed-surface model separates **human-authorized manuscript prose**, **draft facts**, **current state**, **strategy**, **parked tasks**, and **raw audit material**:

- **manuscript/**: human-authorized, fully self-contained paper-quality authority layer. If it conflicts with research-tree facts, manuscript wins and the conflict is flagged. The narrow exception to prose-only content is `manuscript/authorizations/*.md`, which stores `/meeting` approval snapshots used by `/write` as promotion authority
- **note.md** (draft facts, overwrite): established facts with derivation/derivation skeleton, scope, limitations, and provenance links. It is not current state and not a report index
- **sources.md** (source map, overwrite): Node-local source questions, links to source records, intended uses, non-uses, and bridge status. It is where research planner records why a source matters to the node without letting reader decide project relevance
- **conventions.md** (convention ledger, overwrite): Current symbolic language needed to read note.md formulas. It is loaded with note.md because omitting it makes notation choices decay during synthesis
- **plan.md** (ladder, overwrite): Strategy and approach — decomposition rationale, children's roles, approach decisions. Rewritten when strategy changes
- **state.md** (research state, overwrite + append): current board is rewritten when understanding changes; Evidence accumulates as absorbed state without `.logs/` links
- **backlog.md** (backlog, overwrite): parked pending work. It is deliberately weaker than plan.md: a backlog item is a reminder to execute or check something, not a reasoned statement of why the node is decomposed that way
- **dead_ends.md** (ladder, append-only): Failed approaches. Separated from state.md to keep the working document focused
- **directives.md** (immutable): User-imposed rules. Different authorship model (meetings only)
- **research/focus.md** is a singleton (one file for the entire tree) that tracks research planner's session position — unlike the per-node files above, it prevents breadth-first thrashing by scoping the working context
- **last_session.md** carries volatile operational detail that doesn't belong in the tree

## Knowledge Lifecycle

```
New node → research planner directive or curator structural-maintenance trigger
    ↓ curator mkdir + state.md [status: open]
Curator writes plan.md (decomposition, strategy) if non-trivial
    ↓ investigate
Workers produce deliverables in .logs/ (raw audit archive: research notebooks with derivations)
    ↓ scheduler attaches critic (Target A — worker deliverable)
Reader deliverables also update literature/notes/{id}.md as source records; critic reviews them in source-audit mode against the paper, not against project relevance
    ↓
Curator absorbs critic-reviewed evidence into state.md without log links and, when directed, places or promotes clean analyses → report_{slug}.md in the node (self-contained, derivation preserved)
Curator updates conventions.md when a promoted result introduces or depends on a load-bearing symbolic choice
    ↓ node reaches stable
Fact-maintenance transaction lifts derivations (not just claims) from reports + absorbed state → writes note.md
Curator then dispatches critic (Target B — note.md) to verify the lifted derivation
    ↓ understanding deepens
Fact-maintenance transaction updates note.md with new derivations; re-dispatches critic on touched sections
    ↓ later found wrong
Research planner directs retraction → curator writes state.md + dead_ends.md and closes the fact-layer update
```

**Graph authority is not ordinary authorship.** Research planner's direction authority is expressed in `focus.md`: cursor, worker dispatch plan, and Tree Directives naming what should change. Curator owns graph/lifecycle/placement transactions: state.md absorption, plan.md consistency, node folders, status, reparenting, report-to-subnode promotion, and structural splits. Clean report authorship may be assigned to workers, but workers do not change graph structure. Fact-layer authorship may later move to a dedicated role; until then, curator closes the transaction and enforces the file identity, verification, and link-governance rules.

Two narrow carve-outs preserve the above without friction: (i) trivial mechanical fixes to note.md (typo, broken Markdown-link rename) may be made directly by the acting maintenance/editor role since they change no semantics; (ii) user-present collaborative rewrites under `/meeting` or `/launch` are authoritative (the user serves as second reader in real time). Everything else — adding a section, rewording a claim, inserting a "status update" block, updating a provenance link or record — goes through a curator dispatch.

note.md creation, retraction, format, and ownership are defined canonically in `.claude/research-tree.md`.

**Refresh**: state.md files naturally accumulate text over sessions. Curator compresses them during ordinary touched-file maintenance and the mandatory session-end sweep — moving detailed content to note.md where appropriate. The working state in state.md should stay concise enough to read at a glance.
