# Research Tree

Research information is organized as a **tree** under `research/`. Every node is a folder. Files serve distinct roles:

**Language.** Body prose in every file described here (log.md Current State, Evidence entries, note.md, plan.md, story.md, report_*.md, principles.md, focus.md, dead_ends.md, …) is written in **japanese**. Exceptions: the structural `##` headings shown in English in this document (e.g., `## Current State`, `## Evidence`, `## Background`), frontmatter keys, folder slugs, technical terms, proper nouns, and LaTeX mathematics may stay in their original form. The English examples below illustrate structure, not language.

| File | Layer | Role |
|---|---|---|
| `note.md` | Destination (SoT) | **Verified knowledge.** Free-form prose — no prescribed sections, no frontmatter. Written when a node has significant established results. Not every node has one |
| `report_{slug}.md` | Report (verified) | **PI-verified report.** Self-contained analysis promoted from worker deliverables and verified through independent review. Belongs to the node, not to the timeline. See below |
| `plan.md` | Ladder (strategy) | **Strategy and approach.** How to attack this node — decomposition rationale, approach decisions, children's roles. Rewritten as strategy evolves |
| `log.md` | Ladder (process) | **Research process.** Has frontmatter (`kind`, `status`). Contains Current State (rewritten) and Evidence (append-only). PI's working document |
| `story.md` | — | Narrative structure of children (optional). At root: the paper's overall narrative structure |
| `principles.md` | — | Constraints specific to this subtree (optional). At root: cross-cutting research constraints |
| `src/` | Computation | Source code tied to a node (measurement, analysis, plot, or verification scripts), each with a companion `{slug}.md` |
| `data/` | Computation | Simulation data (TSV format with metadata headers) |
| `images/` | Computation | Figures and visualizations |
| `lib/` | Computation (root only) | Shared simulation framework modules (managed by engine-builder) |

## Folder Names

Every node is a folder, and the folder name is the only thing a reader sees when browsing the tree. Use a semantic slug describing what the node is about on its own — **Title Case with spaces** is the house style (e.g., `Topic Name`, `Subtopic Name`).

The folder path must be stable under reorderings of the narrative. This rules out any slug that depends on where the node sits in the current story — positional prefixes, sequence indices, phase labels, and similar ordering markers all go stale the moment the story is rewritten. Narrative order lives in the parent's `story.md` or `plan.md`, not in the path.

A reader who sees only the folder name should be able to guess the node's content. If the name only makes sense given the current story, it is the wrong name.

## Computation Artifacts

Research nodes may contain computation subdirectories alongside their text files. This section is the canonical spec — agents that write here (simulator, researcher) follow these rules and cite this section rather than restating them.

### `src/` — Source code tied to a node

Any source code tied to a node lives in `src/`: simulator's measurement / analysis / plot scripts, and researcher's ad-hoc verification scripts for conjectures and examples. Both writers follow the same rules below.

**Node-root prohibition.** Never place source files (`.py`, `.jl`, …) directly in the node folder. Node roots are reserved for narrative files (`log.md`, `plan.md`, `note.md`, `report_*.md`, `story.md`, `principles.md`). Loose scripts in node roots break the tree's legibility and bypass the `src/` reuse rule, so creating `src/` (even for a single script) is mandatory.

**Placement — lowest common ancestor.** Place a script at the lowest node that is an ancestor of every node that uses it. Common cases: a script used only in node `X` lives in `X/src/`; a script shared across siblings of a parent `P` lives in `P/src/`; if two cousins share a script, it lives in their nearest common ancestor's `src/`. This avoids duplication and makes scripts discoverable from the research context.

**Companion `{slug}.md` required.** Every script `{slug}.{ext}` carries a companion `{slug}.md` in the same `src/` directory — this is the script's permanent label in the tree, so a reader browsing `src/` knows what each file computes without opening the code or grepping `logs/`. Minimum content: what the script computes, key parameters, and how to run it. For simulator's long-lived measurement scripts the companion expands into a full implementation description (see simulator agent). For researcher's one-off attempt scripts a short blurb (a paragraph or two) is enough — the full derivation and numerical results live in the attempt deliverable at `logs/{timestamp}_attempt_{slug}.md`, which links the script by its repo-relative path.

**Retirement.** Superseded scripts move to `src/archive/` rather than being deleted, so the reasoning history stays searchable.

**Hygiene.** Do not commit `__pycache__/`, `.ipynb_checkpoints/`, or any per-machine bytecode generated by running scripts.

### `data/`, `images/`, and root `lib/`

- **`data/`**: Simulation data in TSV format with structured metadata headers. Placement: the node that **owns the investigation** — data belongs to the node where the measured observable is studied. Managed by simulator (see simulator agent for TSV metadata-header format and archival rules)
- **`images/`**: Figures and visualizations. Placement: same node as the data they visualize. Managed by simulator
- **`research/lib/`** (root only): Shared simulation framework modules managed by engine-builder. `lib/test/` contains module tests

Agents that are not simulator, researcher, or engine-builder treat all of `src/`, `data/`, `images/`, and `lib/` as read-only context.

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
  lib/                 (shared simulation framework — engine-builder manages)
    ClockModel.jl
    XYModel.jl
    test/
  Paradox Resolution/
    note.md            (polished: what the paradox is and how it's resolved)
    plan.md            (approach strategy)
    log.md             (research process: current state, evidence)
    report_symmetry_analysis.md  (PI-verified report on symmetry constraints)
  Lattice BKT/
    note.md            (polished knowledge of this direction)
    plan.md            (children decomposition and strategy)
    log.md             (working state, evidence trail)
    src/               (scripts relevant to this branch)
      winding_decay.jl           (simulator's long-lived measurement script)
      winding_decay.md           (companion: algorithm + params + how to run)
      archive/                   (superseded scripts kept for history)
    Coulomb Escape/
      log.md           (leaf: may only have log.md, no note.md yet)
      src/             (scripts specific to this leaf)
        escape_rate.jl           (simulator's measurement)
        escape_rate.md
        check_sign_convention.py (researcher's one-off verification)
        check_sign_convention.md (short blurb; full derivation in logs/)
      data/            (simulation data for this investigation)
      images/          (figures generated from this data)
      report_escape_rate.md
```

## Data Layers Summary

| Layer | Location | Worker access | What it contains |
|---|---|---|---|
| **Research tree — SoT** | `research/**/note.md` | Read-only | Verified knowledge, free-form polished prose |
| **Research tree — reports** | `research/**/report_*.md` | Read-only | PI-verified self-contained analyses |
| **Research tree — plan** | `research/**/plan.md` | Read-only | Strategy: decomposition rationale, approach decisions, children's roles |
| **Research tree — log** | `research/**/log.md` | Read-only | Process: current state, evidence chain, kind/status |
| **Concept definitions** | `concepts/` | Read-only (concept-checker may create entries) | Atomic term definitions, wiki-linked from any file via `[[term]]` |
| **Computation — framework** | `research/lib/` | Read-only (engine-builder writes) | Shared simulation modules |
| **Computation — source** | `research/**/src/` | Write (simulator, researcher) | Source code tied to a node: measurement / analysis / plot / verification scripts, each with a companion `{slug}.md` |
| **Computation — data** | `research/**/data/` | Write (simulator) | Simulation data (TSV with metadata headers) |
| **Computation — figures** | `research/**/images/` | Write (simulator) | Visualizations |
| **Research notebooks** | `logs/*_{type}_*.md` | Write (own deliverables only) | Worker deliverables: reading notes, attempts, simulations |
| **Session cursor** | `research/focus.md` | Not relevant to workers | PI's current focus position in the tree |
| **Session context** | `logs/last_session.md` | Not relevant to workers | PI's volatile work context for session handoff |

**Tree navigation**: `ls research/{path}/` to see children (subfolders). Read `note.md` for verified knowledge (SoT), `report_*.md` for PI-verified analyses, `plan.md` for strategy and decomposition, `log.md` for current research state and evidence, `story.md` for narrative structure, `principles.md` for constraints.

Each node has a `kind` and `status` in its **log.md** frontmatter (not note.md). Node status determination is PI's responsibility.

- Only PI writes to the research tree (including plan.md and focus.md)
- To propose a status change, describe the rationale in your deliverable file
- Honest reporting is paramount: never propose stable for something that has not been sufficiently verified
