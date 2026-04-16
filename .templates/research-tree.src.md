# Research Tree

Research information is organized as a **tree** under `research/`. Every node is a folder. Files serve distinct roles:

| File | Layer | Role |
|---|---|---|
| `note.md` | Destination (SoT) | **Verified knowledge.** Free-form prose — no prescribed sections, no frontmatter. Written when a node has significant established results. Not every node has one |
| `report_{slug}.md` | Report (verified) | **PI-verified report.** Self-contained analysis promoted from worker deliverables and verified through independent review. Belongs to the node, not to the timeline. See below |
| `plan.md` | Ladder (strategy) | **Strategy and approach.** How to attack this node — decomposition rationale, approach decisions, children's roles. Rewritten as strategy evolves |
| `log.md` | Ladder (process) | **Research process.** Has frontmatter (`kind`, `status`). Contains Current State (rewritten) and Evidence (append-only). PI's working document |
| `story.md` | — | Narrative structure of children (optional). At root: the paper's overall narrative structure |
| `principles.md` | — | Constraints specific to this subtree (optional). At root: cross-cutting research constraints |

## note.md — Source of Truth

Verified, publication-quality knowledge in free-form prose. What this node established as fact through critical verification.

**No template.** The content and structure emerge from the research itself. A node studying a mathematical structure will naturally differ from one resolving a paradox or surveying a field. Prescribed sections constrain the researcher's thinking — the prose should take whatever form best captures the established knowledge.

**Constraints (not on content, but on quality):**
- No frontmatter (SoT files are clean prose)
- No process artifacts (Current State, Evidence, task lists — those belong in log.md or plan.md)
- Publication-quality: a collaborator unfamiliar with the research process can follow the argument
- Only verified claims. Speculation and open questions belong in plan.md or log.md

**Root note.md** captures the project's overall established understanding — its core claims, scope, and what has been shown. As research progresses, this evolves from a research question into an established account of the project's central findings and how they connect.

**Child note.md** captures what that specific investigation established.

**When to create**: When a node reaches stable and has results worth stating as source of truth. Leaf nodes doing pure computation may never get one.

## report_{slug}.md — PI-Verified Reports

Self-contained analyses that PI has verified (through independent review by the critic sub-agent) and promoted from worker deliverables in `logs/` (a flat directory for raw research notebooks, outside the tree). Think of these as a student's report submitted to PI — structured, verified, and complete enough to stand on their own.

**Relationship to other files:**
- Worker deliverables in `logs/` are research notebooks (raw work). Reports are the verified, promoted subset
- `note.md` is the node's integrated knowledge. Reports are individual analyses that note.md may draw from
- Not every deliverable becomes a report. Not every node has reports

**When to create**: When a worker deliverable contains a significant, verified result that PI wants to preserve as structured knowledge in the tree node. PI creates the report after independent review.

**Naming**: `report_{slug}.md` where `{slug}` is a descriptive identifier (e.g., `report_surface_dispersion.md`, `report_magnetic_c4t.md`).

## plan.md — Strategy and Approach

PI's strategic document for a node. Captures how to attack the problem — decomposition into children, approach choices, and their rationale. Rewritten as strategy evolves.

```markdown
{Free-form strategy notes. No prescribed sections.
Typical content: decomposition rationale, why children exist and their roles,
approach decisions and alternatives considered, strategic priorities.}
```

**No template.** The content depends on the node's nature. A branch node might describe why its children exist and how they contribute; a leaf might outline the approach to a specific calculation or proof.

**Relationship to log.md**: plan.md is forward-looking (how to proceed), while log.md captures current understanding and accumulated evidence. When strategy changes, rewrite plan.md; when results come in, update log.md.

**When to create**: When a node has non-trivial strategic decisions — decomposition into children, choice of approach, prioritization. Simple leaf nodes doing straightforward work may not need one.

## log.md — Research Process

PI's working document. Every node starts with log.md. plan.md is added when strategic decisions need recording. note.md comes last, when results are stable.

```markdown
---
kind: {kind}
status: {status}
---
# {description}

## Current State
{What is known, confidence level, open angles.}

## Evidence
- {entry}: {what was verified and how}
{append-only — never delete evidence entries}
```

Root log.md additionally carries `last_meeting` in frontmatter and a `## Background` section for key references and prior work.

## Example Tree

```
research/
  note.md              (project-level verified knowledge — SoT)
  plan.md              (root-level strategy and decomposition)
  log.md               (background, working state — ladder)
  focus.md            (session cursor: "work here now")
  story.md             (paper narrative structure)
  principles.md        (cross-cutting research constraints)
  Paradox Resolution/
    note.md            (polished: what the paradox is and how it's resolved)
    plan.md            (approach strategy)
    log.md             (research process: current state, evidence)
    report_symmetry_analysis.md  (PI-verified report on symmetry constraints)
  Lattice BKT/
    note.md            (polished knowledge of this direction)
    plan.md            (children decomposition and strategy)
    log.md             (working state, evidence trail)
    Coulomb Escape/
      log.md           (leaf: may only have log.md, no note.md yet)
```

## Data Layers Summary

| Layer | Location | Worker access | What it contains |
|---|---|---|---|
| **Research tree — SoT** | `research/**/note.md` | Read-only | Verified knowledge, free-form polished prose |
| **Research tree — reports** | `research/**/report_*.md` | Read-only | PI-verified self-contained analyses |
| **Research tree — plan** | `research/**/plan.md` | Read-only | Strategy: decomposition rationale, approach decisions, children's roles |
| **Research tree — log** | `research/**/log.md` | Read-only | Process: current state, evidence chain, kind/status |
| **Concept definitions** | `concepts/` | Read-only (concept-checker may create entries) | Atomic term definitions, wiki-linked from any file via `[[term]]` |
| **Research notebooks** | `logs/*_{type}_*.md` | Write (own deliverables only) | Worker deliverables: reading notes, attempts, simulations |
| **Session cursor** | `research/focus.md` | Not relevant to workers | PI's current focus position in the tree |
| **Session context** | `logs/last_session.md` | Not relevant to workers | PI's volatile work context for session handoff |

**Tree navigation**: `ls research/{path}/` to see children (subfolders). Read `note.md` for verified knowledge (SoT), `report_*.md` for PI-verified analyses, `plan.md` for strategy and decomposition, `log.md` for current research state and evidence, `story.md` for narrative structure, `principles.md` for constraints.

Each node has a `kind` and `status` in its **log.md** frontmatter (not note.md). Node status determination is PI's responsibility.

- Only PI writes to the research tree (including plan.md and focus.md)
- To propose a status change, describe the rationale in your deliverable file
- Honest reporting is paramount: never propose stable for something that has not been sufficiently verified
