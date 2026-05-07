# Phase: Information Architecture

This phase file is a reference that research planner reads during `/auto` to understand the research information model. It is not an execution step; it is the conceptual backdrop for every cycle. Load it when forming direction, and refer back when a tree-editing decision needs the canonical ownership / scoping rules.

---

Research information forms a **tree** under `research/`. Research planner navigates this tree depth-first, with `research/focus.md` as a session cursor that scopes the working context.

## The Research Tree (`research/`)

Every node is a **folder**. File formats are defined in `.claude/research-tree.md` (the canonical reference). Key points for research planner:

**Layer classification**: each file has a typed identity. `manuscript/` is reserved and frozen in the current workflow. `findings.md` is the research tree's draft fact layer. `guide.md` is the human oversight entrypoint. `state.md` is the graph-structured current board plus absorbed evidence ledger. `plan.md` is strategy and decomposition. `backlog.md` is parked executable reminders. `.logs/` is the raw chronological audit archive and is not linked from durable research prose.

| File | Layer | Accumulation | Role |
|---|---|---|---|
| `findings.md` | Draft facts | Overwrite | **Fact layer.** Established claims, definitions, derivations or derivation skeletons, scope, limitations, and source/project boundaries. Lower authority than `manuscript/`; no workflow state. Canonical spec: `.claude/research-tree.md` § findings.md |
| `guide.md` | Human oversight | Overwrite | **Human entrypoint.** Orientation, reading path, verification map, suspicious points, and oversight questions. Not fact authority. Canonical spec: `.claude/research-tree.md` § guide.md |
| `conventions.md` | Convention ledger | Overwrite | **Notation and convention source of truth.** Current sign/order/normalization/symbol choices needed to read formulas in this project or subtree. Canonical spec: `.claude/research-tree.md` § conventions.md |
| `sources.md` | Source map | Overwrite | **Node-local external-source map.** Links to `literature/notes/{id}.md`, records source questions, intended node-local uses, explicit non-uses, and bridge status. Not a source record, not a fact layer, not a convention ledger |
| `plan.md` | Decomposition / strategy | Overwrite | **Strategy and approach.** Decomposition rationale, approach decisions, children's roles. Rewritten as strategy evolves |
| `state.md` | Research state | Overwrite + Append | **Current board + absorbed evidence.** Graph-structured state for later agents; no `.logs/` links |
| `backlog.md` | Backlog | Overwrite | **Parked executable reminders.** Pending work scoped to this node/subtree; root `research/backlog.md` is project-wide. No claims, evidence, or durable strategy |
| `dead_ends.md` | Outside fact layer | Append-only | Failed approaches and lessons learned. Prevents state.md bloat |
| `principles.md` | Research principles | Overwrite | Current reusable research judgment principles for this subtree. Not thesis, strategy, source priority, notation, fact prose, or workflow rules |

Children are subfolders. The tree can nest to arbitrary depth.

- **Creating a node**: research planner may create a minimal child (`mkdir` + initial `state.md`) when the same cycle's cursor/worker target needs it. Otherwise research planner requests deferred creation in `research/focus.md § Tree Directives`, or curator creates it from structural-maintenance judgment. Curator performs structural closure: parent `plan.md` / `state.md` integration, evidence copy when appropriate, link hygiene, and child `plan.md` when the node has non-trivial strategic structure. `backlog.md` is created only when there is durable pending work scoped to that node/subtree.
- **Recording a dead end**: research planner states the closure or retraction verdict in Tree Directives; curator appends `dead_ends.md` in the node folder when the closure carries a lesson
- **Adding a research principle**: write `principles.md` in the folder where the reusable judgment principle applies (typically root for project-wide principles). `/launch` and `/meeting` are the write-time gates; curator audits and maintains it
- **Seeing children**: `ls` the folder (subfolders = children)

## Context Scoping

**The ancestor chain is research planner's context spine.** When the cursor points to a node, research planner reads along the path from root to cursor — every folder's findings.md, guide.md if present, sources.md, conventions.md, principles.md, plan.md, state.md, and dead_ends.md. Sibling branches are not loaded.

```
research/                          ← read findings.md + guide.md + sources.md + conventions.md + principles.md + plan.md + state.md + dead_ends.md
  └─ Lattice BKT/                  ← read findings.md + guide.md + sources.md + conventions.md + principles.md + plan.md + state.md + dead_ends.md
       └─ Winding Gap/             ← cursor: read findings.md + guide.md + sources.md + conventions.md + principles.md + plan.md + state.md + dead_ends.md + direct children's findings.md + guide.md + sources.md + conventions.md + principles.md + plan.md + state.md
  └─ Paradox Resolution/           ← NOT loaded (sibling branch)
```

Principles cascade: a principle at a higher level applies to descendants unless a lower-level principle narrows or supersedes it. Dead ends at ancestors are also loaded — lessons learned higher in the tree prevent repeating mistakes in subtrees.

| Scope | What research planner loads | When |
|---|---|---|
| **Ancestor chain** | findings.md + guide.md + sources.md + plan.md + state.md + backlog.md + conventions.md + principles.md + dead_ends.md at each ancestor from root to cursor | Each research planner dispatch |
| **Working context** | Cursor node's direct children: findings.md + guide.md + sources.md + conventions.md + principles.md + plan.md + state.md (depth 1 only) | Each research planner dispatch |
| **Writing context** | findings.md + guide.md + applicable conventions.md at each node (ladder files excluded unless needed for gaps) | /write |

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
| **Session log** | `.logs/{timestamp}_auto.md` | Permanent per-session record. One file per session, never overwritten |

## Why This Separation Matters

The typed-surface model separates **frozen manuscript prose**, **draft facts**, **human oversight**, **current state**, **strategy**, **parked tasks**, and **raw audit material**:

- **manuscript/**: reserved future paper-authority layer, frozen in the current workflow. If existing manuscript conflicts with research-tree facts, manuscript wins and the conflict is flagged. Do not use manuscript authorization as a substitute for research-memory quality
- **findings.md** (draft facts, overwrite): established facts with derivation/derivation skeleton, scope, limitations, and provenance links. It is not current state and not a draft index
- **guide.md** (human oversight, overwrite): orientation, reading path, verification map, and suspicious points for `/meeting`. It is not fact authority and should link to findings/checks/_materials/analyses/state/story rather than copying them
- **sources.md** (source map, overwrite): Node-local source questions, links to source records, intended uses, non-uses, and bridge status. It is where research planner records why a source matters to the node without letting reader decide project relevance
- **conventions.md** (convention ledger, overwrite): Current symbolic language needed to read findings.md formulas. It is loaded with findings.md because omitting it makes notation choices decay during synthesis
- **plan.md** (ladder, overwrite): Strategy and approach — decomposition rationale, children's roles, approach decisions. Rewritten when strategy changes
- **state.md** (research state, overwrite + append): current board is rewritten when understanding changes; Evidence accumulates as absorbed state without `.logs/` links
- **backlog.md** (backlog, overwrite): parked pending work. It is deliberately weaker than plan.md: a backlog item is a reminder to execute or check something, not a reasoned statement of why the node is decomposed that way
- **dead_ends.md** (ladder, append-only): Failed approaches. Separated from state.md to keep the working document focused
- **principles.md** (research principles, overwrite): Current reusable research judgment principles. It constrains repeated future judgment without absorbing thesis, strategy, source priority, notation, facts, or workflow contracts
- **research/focus.md** is a singleton (one file for the entire tree) that tracks research planner's session position — unlike the per-node files above, it prevents breadth-first thrashing by scoping the working context
- **last_session.md** carries volatile operational detail that doesn't belong in the tree

## Knowledge Lifecycle

```
New node → research planner minimal child creation when immediate dispatch needs it, or curator structural-maintenance trigger/deferred creation
    ↓ minimal state.md [status: open]
Curator closes structure: parent plan/state integration, evidence copy, placement/link hygiene, child plan.md if non-trivial
    ↓ investigate
Workers produce provisional submissions in _reviews/ plus short raw process logs in .logs/
    ↓ scheduler attaches critic (Provisional Review — critic.md in the same transaction)
Reader submissions also update literature/notes/{id}.md as source records; critic reviews them in source-audit mode against the paper, not against project relevance
    ↓
Curator absorbs critic-reviewed transactions into state.md without _reviews/log links and, when directed, preserves clean analyses -> _materials/analyses/{slug}.md in the node (self-contained, derivation preserved)
Curator updates conventions.md when a promoted result introduces or depends on a load-bearing symbolic choice
    ↓ node reaches stable
Fact-maintenance transaction lifts derivations (not just claims) from _materials/analyses + absorbed state -> writes findings.md
Curator requests Durable Surface Review; scheduler dispatches critic on findings.md to verify the lifted derivation
Curator updates guide.md when the human oversight map would otherwise be stale
    ↓ understanding deepens
Fact-maintenance transaction updates findings.md with new derivations; requests Durable Surface Review on touched sections
    ↓ later found wrong
Research planner directs retraction → curator writes state.md + dead_ends.md and closes the fact-layer update
```

**Graph authority is not ordinary authorship.** Research planner's direction authority is expressed in `focus.md`: cursor, worker dispatch plan, and Tree Directives naming what should change. Research planner may also create a minimal child node (`mkdir` + initial state.md) when that structure is the immediate expression of its direction judgment and the same cycle's dispatch needs the child to exist. Curator owns structural closure and graph/lifecycle/placement transactions beyond that minimal surface: state.md absorption, plan.md consistency, parent integration, evidence copy, status, reparenting, archive, analysis-to-subnode promotion when warranted, and structural splits discovered from maintenance. Clean analysis authorship may be assigned to workers, but workers do not change graph structure. Fact-layer authorship may later move to a dedicated role; until then, curator closes the transaction and enforces the file identity, verification, and link-governance rules.

Two narrow carve-outs preserve the above without friction: (i) trivial mechanical fixes to findings.md (typo, broken Markdown-link rename) may be made directly by the acting maintenance/editor role since they change no semantics; (ii) user-present collaborative rewrites under `/meeting` or `/launch` are legitimate fact-layer input when the user is actively confirming the synthesis. This is not manuscript authorization and not a replacement for later curator/critic maintenance if defects are found. Everything else — adding a section, rewording a claim, inserting a "status update" block, updating a provenance link or record — goes through a curator dispatch.

findings.md creation, retraction, format, and ownership are defined canonically in `.claude/research-tree.md`.

**Refresh**: state.md files naturally accumulate text over sessions. Curator compresses them during ordinary touched-file maintenance and the mandatory session-end sweep — moving detailed content to findings.md where appropriate. The working state in state.md should stay concise enough to read at a glance.
