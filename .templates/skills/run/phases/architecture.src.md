# Phase: Information Architecture

This phase file is a reference that PI Reads during `/run` to understand the research information model. It is not an execution step; it is the conceptual backdrop for every cycle. Load it once at session start, refer back when a tree-editing decision needs the canonical ownership / scoping rules.

---

Research information forms a **tree** under `research/`. PI navigates this tree depth-first, with `research/focus.md` as a session cursor that scopes the working context.

## The Research Tree (`research/`)

Every node is a **folder**. File formats are defined in `.claude/research-tree.md` (the canonical reference). Key points for PI:

**Layer classification**: each file is tagged either **Destination** (verified knowledge that survives as the node's final output — currently only note.md) or **Ladder** (working/scaffolding files that evolve as understanding grows — plan.md, log.md, dead_ends.md). The metaphor: Ladder files are how you *climb* to the Destination; the Destination is what remains after the climb. `/write` loads only Destination files; Ladder files are for the research process itself.

| File | Layer | Accumulation | Role |
|---|---|---|---|
| `note.md` | Destination | Overwrite | **Source of truth.** Derivation-bearing paper-quality prose — each principal claim carries its derivation (inline or cited) plus a provenance tag. No template, no frontmatter. Canonical spec: `.claude/research-tree.md` § note.md |
| `plan.md` | Ladder | Overwrite | **Strategy and approach.** Decomposition rationale, approach decisions, children's roles. Rewritten as strategy evolves |
| `log.md` | Ladder | Overwrite + Append | **Research process.** Current State (rewritten), Evidence (appended). PI's working document |
| `dead_ends.md` | Ladder | Append-only | Failed approaches and lessons learned. Prevents log.md bloat |
| `directives.md` | — | Append (meetings only) | Rules and conventions imposed by the user. PI cannot modify unilaterally |

Children are subfolders. The tree can nest to arbitrary depth.

- **Creating a node**: `mkdir "research/{Topic Name}"` + write `log.md` (start working). Write `plan.md` when the node has non-trivial strategic decisions (decomposition, approach choice). When results stabilize, **dispatch curator** to create `note.md` — PI does not author note.md prose directly (see research-tree.md § note.md — Ownership, and the Knowledge Lifecycle diagram below)
- **Recording a dead end**: write `dead_ends.md` in the node folder (or append if it exists)
- **Adding a directive**: write `directives.md` in the folder where the rule applies (typically project root; only through meetings)
- **Seeing children**: `ls` the folder (subfolders = children)

## Context Scoping

**The ancestor chain is PI's context spine.** When the cursor points to a node, PI reads along the path from root to cursor — every folder's note.md, plan.md, log.md, dead_ends.md, and directives.md. Sibling branches are not loaded.

```
research/                          ← read note.md + plan.md + log.md + dead_ends.md + directives.md
  └─ Lattice BKT/                  ← read note.md + plan.md + log.md + dead_ends.md + directives.md
       └─ Winding Gap/             ← cursor: read note.md + plan.md + log.md + dead_ends.md + directives.md + direct children's note.md + plan.md + log.md
  └─ Paradox Resolution/           ← NOT loaded (sibling branch)
```

Directives cascade: a directive at a higher level applies to all descendants. Dead ends at ancestors are also loaded — lessons learned higher in the tree prevent repeating mistakes in subtrees.

| Scope | What PI loads | When |
|---|---|---|
| **Ancestor chain** | note.md + plan.md + log.md + dead_ends.md + directives.md at each ancestor from root to cursor | Always at session start (/run) |
| **Working context** | Cursor node's direct children: note.md + plan.md + log.md (depth 1 only) | Always at session start (/run) |
| **Project directives** | `directives.md` at project root (if exists; outside research/) | Always at session start |
| **Writing context** | note.md only at each node (ladder files excluded) | /write |

## Session Cursor (`research/focus.md`)

research/focus.md is a lightweight cursor pointing to PI's current position in the tree. It carries:
- Current focus path
- Short-term context (blockers, immediate next steps)
- Rewritten by physicist at the start of every cycle (regular dispatch) and at session end (transcribed by `session-wrap-up` from the wrap-up-input file's `## Focus` section). See `session-lifecycle.md § Session End` for the wrap-up-input path-creation step.

## Supporting Layers

| Layer | Location | Role |
|---|---|---|
| **Worker deliverables** | `logs/{timestamp}_{type}_{slug}.md` | Provisional research notebooks produced by workers. Kept outside the tree because they are single-pass outputs awaiting PI verification |
| **Concept definitions** | `concepts/` | Atomic term definitions (one per file). Wiki-linked from any file via `[[term]]` |
| **Session handoff** | `logs/last_session.md` | Operational detail, PI's thinking for next session. Overwritten each session |
| **Session log** | `logs/{timestamp}_run.md` | Permanent per-session record. One file per session, never overwritten |

## Why This Separation Matters

The three-layer model separates **what we know**, **how we'll proceed**, and **what we've done**:

- **note.md** (destination, overwrite): Free-form verified knowledge. `/write` loads only these — the ladder is excluded so the writing context stays clean
- **plan.md** (ladder, overwrite): Strategy and approach — decomposition rationale, children's roles, approach decisions. Rewritten when strategy changes
- **log.md** (ladder, overwrite + append): PI's working document. Current State is rewritten when understanding changes. Evidence accumulates but is periodically compressed by curator
- **dead_ends.md** (ladder, append-only): Failed approaches. Separated from log.md to keep the working document focused
- **directives.md** (immutable): User-imposed rules. Different authorship model (meetings only)
- **research/focus.md** is a singleton (one file for the entire tree) that tracks PI's session position — unlike the per-node files above, it prevents breadth-first thrashing by scoping the working context
- **last_session.md** carries volatile operational detail that doesn't belong in the tree

## Knowledge Lifecycle

```
New node → mkdir + log.md [status: open]
    ↓ plan approach
PI writes plan.md (decomposition, strategy) if non-trivial
    ↓ investigate
Workers produce deliverables in logs/ (research notebooks with derivations)
    ↓ PI verifies via critic (Target A — attempt file)
PI promotes verified results → report_{slug}.md in the node (self-contained, derivation preserved)
    ↓ node reaches stable — PI dispatches curator
Curator lifts derivations (not just claims) from reports + log.md → writes note.md
Curator then dispatches critic (Target B — note.md) to verify the lifted derivation
    ↓ understanding deepens — PI dispatches curator again
Curator updates note.md with new derivations; re-dispatches critic on touched sections
    ↓ later found wrong
PI writes retraction evidence into log.md + dead_ends.md → dispatches curator to update note.md
```

**note.md is curator-authored, not PI-authored, and carries the derivation — not just the claim.** The diagram above is not a convention — it is the ownership rule and the substance rule combined. PI's tree-editing authority covers log.md (every cycle), plan.md (when strategy changes), dead_ends.md (when approaches fail), and report_{slug}.md (when promoting a verified result). note.md is the one file PI does not write substantively: its prose comes from curator, dispatched by PI, with each principal claim accompanied by its derivation (inline or cited) and its provenance tag. The reasons — separation of concerns, second-reader quality, cross-tree coherence, derivation lifting, tag assignment — are stated in `.claude/research-tree.md` § note.md under **Ownership**, which is the canonical rule.

Two narrow carve-outs preserve the above without friction: (i) trivial mechanical fixes to note.md (typo, broken wiki-link rename) may be made directly by PI since they change no semantics; (ii) user-present collaborative rewrites under `/meeting` or `/launch` are authoritative (the user serves as second reader in real time). Everything else — adding a section, rewording a claim, inserting a "status update" block, updating a provenance tag — goes through a curator dispatch.

note.md creation, retraction, format, and ownership are defined canonically in `.claude/research-tree.md`.

**Refresh**: log.md files naturally accumulate text over sessions. Periodically, PI dispatches **curator** to compress them — moving detailed content to note.md where appropriate. The working state in log.md should stay concise enough to read at a glance.
