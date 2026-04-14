# Research Tree

Research information is organized as a **tree** under `research/`. Every node is a folder. Files are separated into two layers — **destination** (polished knowledge) and **ladder** (research process):

| File | Layer | Role |
|---|---|---|
| `note.md` | Destination (SoT) | **Verified knowledge.** Free-form prose — no prescribed sections, no frontmatter. Written when a node has significant established results. Not every node has one |
| `log.md` | Ladder (process) | **Research process.** Has frontmatter (`kind`, `status`). Contains Current State (rewritten) and Evidence (append-only). PI's working document |
| `story.md` | — | Narrative structure of children (optional). At root: the paper's overall narrative arc |
| `principles.md` | — | Constraints specific to this subtree (optional). At root: cross-cutting approach principles |

## note.md — Source of Truth

Verified, publication-quality knowledge in free-form prose. What this node established as fact through critical verification.

**No template.** The content and structure emerge from the research itself. A node studying a mathematical structure will naturally differ from one resolving a paradox or surveying a field. Prescribed sections constrain the researcher's thinking — the prose should take whatever form best captures the established knowledge.

**Constraints (not on content, but on quality):**
- No frontmatter (SoT files are clean prose)
- No process artifacts (Current State, Evidence, task lists — those belong in log.md)
- Publication-quality: a collaborator unfamiliar with the research process can follow the argument
- Only verified claims. Speculation and open questions belong in log.md

**Root note.md** captures the project's overall established understanding — its core claims, scope, and what has been shown. As research progresses, this evolves from a research question into an established account of the project's central findings and how they connect.

**Child note.md** captures what that specific investigation established.

**When to create**: When a node reaches stable and has results worth stating as source of truth. Leaf nodes doing pure computation may never get one.

## log.md — Research Process

PI's working document. Every node starts with log.md; note.md comes later (if ever).

```markdown
---
kind: {kind}
status: {status}
---
# {description}

## Current State
{What is known, confidence level, open angles.
For branch nodes: why children exist, how they relate, what each contributes.}

## Evidence
- {entry}: {what was verified and how}
{append-only — never delete evidence entries}
```

Root log.md additionally carries `last_meeting` in frontmatter and a `## Background` section for key references and prior work.

## Example Tree

```
research/
  note.md              (project-level verified knowledge — SoT)
  log.md               (background, working state — ladder)
  story.md             (paper narrative arc)
  principles.md        (cross-cutting constraints)
  Paradox Resolution/
    note.md            (polished: what the paradox is and how it's resolved)
    log.md             (research process: evidence, revisions)
  Lattice BKT/
    note.md            (polished knowledge of this direction)
    log.md             (working state, children decomposition)
    Coulomb Escape/
      log.md           (leaf: may only have log.md, no note.md yet)
```

## Data Layers Summary

| Layer | Location | Worker access | What it contains |
|---|---|---|---|
| **Research tree — SoT** | `research/**/note.md` | Read-only | Verified knowledge, free-form polished prose |
| **Research tree — ladder** | `research/**/log.md` | Read-only | Research process: current state, evidence chain, kind/status |
| **Concept definitions** | `concepts/` | Read-only (concept-checker may create entries) | Atomic term definitions, wiki-linked from any file via `[[term]]` |
| **Research notes** | `notes/*.md` | Read-only | Distilled understanding, topic-level summaries |
| **Session cursor** | `plan.md` | Not relevant to workers | PI's current focus position in the tree |
| **Session context** | `logs/last_session.md` | Not relevant to workers | PI's volatile work context for session handoff |

**Tree navigation**: `ls research/{path}/` to see children (subfolders). Read `note.md` for verified knowledge (SoT), `log.md` for current research state and evidence, `story.md` for narrative structure, `principles.md` for constraints.

Each node has a `kind` and `status` in its **log.md** frontmatter (not note.md). Node status determination is PI's responsibility.

- Only PI writes to the research tree and plan.md
- To propose a status change, describe the rationale in your deliverable file
- Honest reporting is paramount: never propose stable for something that has not been sufficiently verified
