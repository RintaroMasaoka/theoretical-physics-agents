# Phase: Information Architecture

This phase file is a reference that physicist reads during `/run` to understand the research information model. It is not an execution step; it is the conceptual backdrop for every cycle. Load it when forming direction, and refer back when a tree-editing decision needs the canonical ownership / scoping rules.

---

Research information forms a **tree** under `research/`. Physicist navigates this tree depth-first, with `research/focus.md` as a session cursor that scopes the working context.

## The Research Tree (`research/`)

Every node is a **folder**. File formats are defined in `.claude/research-tree.md` (the canonical reference). Key points for physicist:

**Layer classification**: each file is tagged either **Destination** (verified knowledge that survives as the node's final output — note.md plus convention anchors that make its formulas readable), **Convention ledger** (current symbolic language for a project/subtree), **Ladder** (working/scaffolding files that evolve as understanding grows — plan.md, .log.md, dead_ends.md), or **Workbench** (hidden short-term operator state such as `.todo.md`). The metaphor: Ladder files are how you *climb* to the Destination; Workbench files keep tactical residue off the Ladder. `/write` loads note.md together with applicable conventions.md files; Ladder and Workbench files are for the research process itself.

| File | Layer | Accumulation | Role |
|---|---|---|---|
| `note.md` | Destination | Overwrite | **Source of truth.** Derivation-bearing paper-quality prose — each principal claim carries its derivation (inline or cited) plus a Markdown link to a `checks/*.md` provenance record. No template, no frontmatter. Canonical spec: `.claude/research-tree.md` § note.md |
| `conventions.md` | Convention ledger | Overwrite | **Notation and convention source of truth.** Current sign/order/normalization/symbol choices needed to read formulas in this project or subtree. Canonical spec: `.claude/research-tree.md` § conventions.md |
| `plan.md` | Ladder | Overwrite | **Strategy and approach.** Decomposition rationale, approach decisions, children's roles. Rewritten as strategy evolves |
| `.log.md` | Ladder | Overwrite + Append | **Research process.** Current State (rewritten), Evidence (appended). Curator-maintained record of what the node knows and how it learned it |
| `.todo.md` | Workbench | Overwrite | **Hidden tactical backlog.** Curator-maintained short-term checklist for active node-local work. No claims, evidence, or durable strategy |
| `dead_ends.md` | Ladder | Append-only | Failed approaches and lessons learned. Prevents .log.md bloat |
| `directives.md` | — | Append (meetings only) | Rules and conventions imposed by the user. PI cannot modify unilaterally |

Children are subfolders. The tree can nest to arbitrary depth.

- **Creating a node**: physicist requests the child in `research/focus.md § Tree Directives`, or curator creates it from structural-maintenance judgment. Curator runs `mkdir "research/{Topic Name}"`, writes `.log.md`, writes `plan.md` when the node has non-trivial strategic decisions (decomposition, approach choice), and may write `.todo.md` when there is tactical work that would otherwise live only in memory.
- **Recording a dead end**: physicist states the closure or retraction verdict in Tree Directives; curator appends `dead_ends.md` in the node folder when the closure carries a lesson
- **Adding a directive**: write `directives.md` in the folder where the rule applies (typically project root; only through meetings)
- **Seeing children**: `ls` the folder (subfolders = children)

## Context Scoping

**The ancestor chain is physicist's context spine.** When the cursor points to a node, physicist reads along the path from root to cursor — every folder's note.md, conventions.md, plan.md, .log.md, dead_ends.md, and directives.md. Sibling branches are not loaded.

```
research/                          ← read note.md + conventions.md + plan.md + .log.md + dead_ends.md + directives.md
  └─ Lattice BKT/                  ← read note.md + conventions.md + plan.md + .log.md + dead_ends.md + directives.md
       └─ Winding Gap/             ← cursor: read note.md + conventions.md + plan.md + .log.md + dead_ends.md + directives.md + direct children's note.md + conventions.md + plan.md + .log.md
  └─ Paradox Resolution/           ← NOT loaded (sibling branch)
```

Directives cascade: a directive at a higher level applies to all descendants. Dead ends at ancestors are also loaded — lessons learned higher in the tree prevent repeating mistakes in subtrees.

| Scope | What physicist loads | When |
|---|---|---|
| **Ancestor chain** | note.md + plan.md + .log.md + conventions.md + dead_ends.md + directives.md at each ancestor from root to cursor; `.todo.md` only for the cursor node when present | Each physicist dispatch |
| **Working context** | Cursor node's direct children: note.md + conventions.md + plan.md + .log.md (depth 1 only) | Each physicist dispatch |
| **Project directives** | `directives.md` at project root (if exists; outside research/) | Each physicist dispatch |
| **Writing context** | note.md + applicable conventions.md at each node (ladder files excluded) | /write |

## Session Cursor (`research/focus.md`)

research/focus.md is a lightweight cursor pointing to PI's current position in the tree. It carries:
- Current focus path
- Short-term context (blockers, immediate next steps)
- Rewritten by physicist at the start of every cycle (regular dispatch) and at session end (transcribed by `session-wrap-up` from the wrap-up-input file's `## Focus` section). See `session-lifecycle.md § Session End` for the wrap-up-input path-creation step.

## Supporting Layers

| Layer | Location | Role |
|---|---|---|
| **Worker deliverables** | `.logs/{timestamp}_{type}_{slug}.md` | Provisional research notebooks produced by workers. Kept outside the tree because they are single-pass outputs awaiting PI verification |
| **Concept definitions** | `concepts/` | Atomic term definitions (one per file). Linked from notes via explicit Markdown links |
| **Convention ledgers** | `research/**/conventions.md` | Notation, sign, ordering, normalization, and symbol-reservation choices scoped to the project or subtree |
| **Session handoff** | `.logs/last_session.md` | Operational detail, PI's thinking for next session. Overwritten each session |
| **Session log** | `.logs/{timestamp}_run.md` | Permanent per-session record. One file per session, never overwritten |

## Why This Separation Matters

The three-layer model separates **what we know**, **how we'll proceed**, and **what we've done**:

- **note.md** (destination, overwrite): Free-form verified knowledge. `/write` loads note.md plus applicable conventions.md — the ladder is excluded so the writing context stays clean
- **conventions.md** (convention ledger, overwrite): Current symbolic language needed to read note.md formulas. It is loaded with note.md because omitting it makes notation choices decay during synthesis
- **plan.md** (ladder, overwrite): Strategy and approach — decomposition rationale, children's roles, approach decisions. Rewritten when strategy changes
- **.log.md** (ladder, overwrite + append): curator-maintained process record. Current State is rewritten when understanding changes; Evidence accumulates but is periodically compressed without dropping the evidence chain
- **.todo.md** (workbench, overwrite): curator-maintained tactical backlog for the node currently being worked. It is deliberately weaker than plan.md: a todo item is a reminder to execute or check something, not a reasoned statement of why the node is decomposed that way
- **dead_ends.md** (ladder, append-only): Failed approaches. Separated from .log.md to keep the working document focused
- **directives.md** (immutable): User-imposed rules. Different authorship model (meetings only)
- **research/focus.md** is a singleton (one file for the entire tree) that tracks PI's session position — unlike the per-node files above, it prevents breadth-first thrashing by scoping the working context
- **last_session.md** carries volatile operational detail that doesn't belong in the tree

## Knowledge Lifecycle

```
New node → physicist directive or curator structural-maintenance trigger
    ↓ curator mkdir + .log.md [status: open]
Curator writes plan.md (decomposition, strategy) if non-trivial
    ↓ investigate
Workers produce deliverables in .logs/ (research notebooks with derivations)
    ↓ scheduler attaches critic (Target A — attempt file)
Curator absorbs critic-reviewed evidence and, when directed, promotes verified results → report_{slug}.md in the node (self-contained, derivation preserved)
Curator updates conventions.md when a promoted result introduces or depends on a load-bearing symbolic choice
    ↓ node reaches stable
Curator lifts derivations (not just claims) from reports + .log.md → writes note.md
Curator then dispatches critic (Target B — note.md) to verify the lifted derivation
    ↓ understanding deepens
Curator updates note.md with new derivations; re-dispatches critic on touched sections
    ↓ later found wrong
Physicist directs retraction → curator writes .log.md + dead_ends.md and updates note.md
```

**The tree is curator-authored except for `research/focus.md`.** The diagram above is not a convention — it is the ownership rule and the substance rule combined. Physicist's tree authority is direction-setting in `focus.md`: cursor, worker dispatch plan, and Tree Directives naming what should change. Curator's tree authority is execution and maintenance: .log.md, plan.md, `.todo.md`, node folders, reports, dead ends, note.md, story, principles, conventions, and structural splits when the evidence record has outgrown a parent. This keeps scientific direction separate from the record-writing and cross-tree coherence work that otherwise crowd it out.

Two narrow carve-outs preserve the above without friction: (i) trivial mechanical fixes to note.md (typo, broken Markdown-link rename) may be made directly by PI since they change no semantics; (ii) user-present collaborative rewrites under `/meeting` or `/launch` are authoritative (the user serves as second reader in real time). Everything else — adding a section, rewording a claim, inserting a "status update" block, updating a provenance link or record — goes through a curator dispatch.

note.md creation, retraction, format, and ownership are defined canonically in `.claude/research-tree.md`.

**Refresh**: .log.md files naturally accumulate text over sessions. Curator compresses them during ordinary touched-file maintenance and the mandatory session-end sweep — moving detailed content to note.md where appropriate. The working state in .log.md should stay concise enough to read at a glance.
