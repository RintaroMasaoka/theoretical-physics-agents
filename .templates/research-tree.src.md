# Research Tree

Research information is organized as a **tree** under `research/`. Every node is a folder. Files serve distinct roles:

**Language.** Body prose in every file described here (log.md Current State, Evidence entries, note.md, plan.md, story.md, report_*.md, principles.md, focus.md, dead_ends.md, …) is written in **{{ language }}**. Exceptions: the structural `##` headings shown in English in this document (e.g., `## Current State`, `## Evidence`, `## Background`), frontmatter keys, folder slugs, technical terms, proper nouns, and LaTeX mathematics may stay in their original form. The English examples below illustrate structure, not language.

| File | Layer | Role |
|---|---|---|
| `note.md` | Destination (SoT) | **Established knowledge with explicit provenance. Curator-authored** — PI dispatches curator to write and update; PI does not author the prose directly (see § note.md — Ownership below). Free-form prose — no prescribed sections, no frontmatter. Every principal claim carries a verification tag (see Verification Provenance Taxonomy). Written when a node has significant established results. Not every node has one |
| `report_{slug}.md` | Report (with provenance) | **PI-promoted report with explicit provenance tags.** Self-contained analysis promoted from worker deliverables after independent review. Belongs to the node, not to the timeline. See below |
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

Publication-quality knowledge in free-form prose, with every principal claim carrying an explicit provenance tag. "Source of Truth" means **the authoritative record of what is known and at what confidence level**, not "only CONFIRMED claims" — STRONG CONJECTURE, CONJECTURE, and OPEN claims belong in note.md too when they are the node's established state, provided each carries its provenance tag.

**No template.** The content and structure emerge from the research itself. A node studying a mathematical structure will naturally differ from one resolving a paradox or surveying a field. Prescribed sections constrain the researcher's thinking — the prose should take whatever form best captures the established knowledge.

**Constraints (not on content, but on quality):**
- No frontmatter (SoT files are clean prose)
- No process artifacts (Current State, Evidence, task lists — those belong in log.md or plan.md)
- Publication-quality: a collaborator unfamiliar with the research process can follow the argument
- Every principal claim carries an explicit verification tag per the Verification Provenance Taxonomy below (confidence label + method tags + optional scope marker). Bare unannotated CONFIRMED is forbidden. Speculation without supporting tags and open questions belong in plan.md or log.md rather than note.md

**Root note.md** captures the project's overall established understanding — its core claims, scope, and what has been shown. As research progresses, this evolves from a research question into an established account of the project's central findings and how they connect.

**Child note.md** captures what that specific investigation established.

**When to create**: When a node reaches stable and has results worth stating as source of truth. Leaf nodes doing pure computation may never get one.

**Ownership — note.md is curator-authored.** This is the one file in the tree whose prose is written by curator rather than PI. The split exists because note.md demands cognitive modes that compete with PI's research work:

- **Separation of concerns**: PI's attention during `/run` is on advancing research — dispatching workers, reading attempts, making directional decisions. Synthesis of verified evidence into publication-ready prose is a different cognitive mode. When PI tries to hold both, research wins and synthesis drops — empirically, a session with ten cycles of active research typically produces zero updates to note.md if the same agent owns both channels. Giving note.md a dedicated author prevents that drop
- **Second-reader quality**: The agent who produced a result is anchored by the deliverable they wrote and is a poor judge of whether the prose reads cleanly to someone unfamiliar with the research process. note.md's promise is exactly that it reads cleanly to such a reader, so the author should be a second reader — curator, coming to the evidence fresh
- **Cross-tree coherence**: note.md at one node must harmonize with note.md at sibling and ancestor nodes (consistent terminology, valid `[[wiki-links]]`, referenced concept notes). This requires reading the tree holistically, which PI does not do during cycles — PI's reading scope is the ancestor spine plus direct children. Curator reads the whole tree by design
- **Provenance tag assignment**: Every principal claim in note.md carries axis 1 + axis 2-a + axis 2-b + (optional) axis 3 tags. Assigning these correctly requires re-reading the underlying worker deliverables and critic reports to reconstruct the evidence chain. This is exactly curator's core task

PI's role with respect to note.md is therefore: write evidence into log.md, promote verified results into report_{slug}.md when warranted, and **dispatch curator** to distill these into note.md. PI does not directly write substantive note.md prose during `/run` cycles.

Two narrow exceptions to the curator-only rule:

1. **Trivial mechanical fixes.** Typo corrections, fixing a broken `[[wiki-link]]`, renaming a term after a concept note is renamed. The rule of thumb: if the replacement is uniquely determined — any competent reader would produce the same correction, with no judgment about phrasing or structure — the edit is mechanical. If there is any judgment about wording, ordering, or what claim to state, it is not mechanical and must go through curator
2. **User-present collaborative rewrites (`/meeting`, `/launch`).** When the user is actively collaborating — during a meeting discussion, or during the initial project launch — PI and user may rewrite note.md together to reflect synthesis produced in the conversation. These skills explicitly treat note.md as the destination for human-in-the-loop narrative decisions. The user acts as the second reader in real time, which is what curator otherwise provides; so the curator-only rule does not bind

Anything beyond these two categories — adding a section, rewording a claim, updating a provenance tag, restructuring prose, inserting a "status update" block — goes through curator. A PI-authored substantive edit that was made by mistake (e.g., during a fast-paced cycle) is legitimate input to the tree, but curator will rewrite it on the next dispatch to restore SoT quality; PI should not defend such edits as final.

This rule has a failure mode to watch for: note.md drifting into a log-like chronicle with time-stamped "Status update YYYY-MM-DD" sections stacked on top of each other. That shape is the footprint of PI-direct appending and signals that curator dispatches have been skipped; the next curator run should consolidate such stacks into a single, present-tense statement of the node's established knowledge.

## Verification Provenance Taxonomy

Claims in note.md (and report_{slug}.md) carry an explicit verification tag so readers can assess **how** each fact was established, **whether it has been independently reviewed**, and **at what scope**. The tag decomposes into orthogonal axes. The purpose is to prevent a single "verified" label from collapsing distinct kinds of evidence (symbolic computation, literature citation, independent critique, small-instance checks) into one opaque stamp.

### Axis 1 — Confidence

| Tag | Meaning |
|---|---|
| `CONFIRMED` | Verified with no known counterexamples. Publishable as stated |
| `STRONG CONJECTURE` | Substantial partial evidence; holds in principal cases but full scope is not closed |
| `CONJECTURE` | Motivated and locally supported, but not sufficiently verified |
| `OPEN` | Unresolved |

### Axis 2-a — First-order evidence (how the claim was actually established; one or more)

These describe the **evidence chain itself**. A claim may rest on more than one when multiple derivations agree.

| Tag | Meaning |
|---|---|
| `[proof]` | Formal mathematical proof — hand-checked or machine-checked derivation closing the claim at its declared scope |
| `[mechanical]` | Symbolic / exact computation (SymPy, SageMath, exact enumeration). Computer output is unaffected by LLM reasoning biases |
| `[numerical]` | Finite-tolerance numerical check with stated convergence criteria |
| `[literature]` | Established in cited external literature. Being cited as a premise — not yet independently re-derived in this project |

### Axis 2-b — Independent review (orthogonal to 2-a; whether the evidence has been adversarially critiqued)

These describe **who checked the evidence**. Independent review **composes with** first-order evidence — it does not substitute for it. `[critic-*]` alone cannot support CONFIRMED (see Rules). A claim with both `[proof]` and `[critic-blind]` is strictly stronger than either alone, because the proof has been subjected to adversarial scrutiny by an independent channel. Likewise `[literature, critic-blind]` records that a cited result was not just taken on faith but was re-examined by an independent critic for whether it actually supports the use being made of it.

| Tag | Meaning |
|---|---|
| `[critic-blind]` | Independent adversarial critique by the critic agent in **blind mode** (no research context loaded). Removes expectation bias. The strongest review tier when the claim is mechanical or self-contained |
| `[critic-contextual]` | Critic agent in **contextual mode** (ancestor chain loaded). Used when soundness genuinely depends on the claim's role in the overall narrative — e.g., "does this argument suffice for its intended position in the story?" |

When critic runs its own SymPy/numerical computation during review, that adds a first-order tag too — e.g., `[mechanical, critic-blind]`. A standalone `[critic-*]` tag (no axis 2-a) is rare — it indicates the critic's evidence was purely logical (just a soundness review of the researcher's argument structure) — and per the rules below such a standalone tag can attach only to labels at or below STRONG CONJECTURE.

### Axis 3 — Scope marker (optional; restricts the verified region)

By default the claim is taken to be verified over its **full declared scope**. When that is not the case, attach an explicit scope marker — never leave scope implicit. A bare `[special-case]` without description is forbidden because readers cannot otherwise evaluate what was covered.

| Marker | Meaning |
|---|---|
| `[special-case: {description}]` | Verified only on a restricted instance. The description must identify the instance — e.g., `[special-case: N=2 torus]`, `[special-case: triangle+pendant graph]`, `[special-case: 9 specific bonds]` |

### Rules

- Every `CONFIRMED` must carry at least one axis 2-a tag. Bare "CONFIRMED" with no first-order evidence is forbidden because readers cannot then evaluate the claim. An axis 2-b tag alone does not count as first-order evidence
- Axis 2-a and 2-b tags compose freely when both apply (e.g., `[proof, critic-blind]`, `[literature, critic-contextual]`, `[mechanical, numerical, critic-blind]`). Always declare every applicable tag — omitting a true channel understates the verification chain
- A claim tagged with `[special-case: ...]` **cannot** be elevated to CONFIRMED — the strongest allowed label is `STRONG CONJECTURE`, because full-scope verification is missing by definition
- `[literature]` alone (no independent review, no local re-derivation) does not suffice for **project-central claims** — meaning a claim this project is staking out as its own contribution, as opposed to a premise cited from external work. (A citation-only `CONFIRMED [literature]` is fine when the claim is explicitly framed as the external result itself, e.g., "Kausch's decomposition holds" — no project contribution is being attested.) To reach CONFIRMED on a project-central claim, pair `[literature]` with an independent channel: either a first-order re-derivation (`[proof]`, `[mechanical]`, `[numerical]`) or an independent review (`[critic-blind]` / `[critic-contextual]`) that examined the citation's applicability to the specific use being made of it
- If provenance is unclear from the available documents, use the lower confidence label and flag for PI rather than guessing

### Strength guide (informal)

Strength grows monotonically along two directions: (i) more axis 2-a tags when independent channels agree, (ii) addition of axis 2-b review on top of axis 2-a. Rough ordering of individual contributions — `[proof]` is the strongest single first-order tag; `[mechanical]` and `[critic-blind]` are comparably strong second tiers; `[numerical]` below those; `[literature]` alone is weakest as first-order support for project claims. `[critic-contextual]` adds a soundness check but does not by itself close a mechanical question. Any `[special-case: ...]` marker weakens the combined label by restricting the verified region.

### Examples (applied to this project)

| Claim | Label |
|---|---|
| Generic algebraic identity with a hand proof that a critic then verified by running an independent SymPy script in blind mode | `CONFIRMED [proof, mechanical, critic-blind]` (the critic's own SymPy contributes `[mechanical]`; the hand proof contributes `[proof]`; the review channel contributes `[critic-blind]`) |
| Dimension of the Jacobson radical via Artin–Wedderburn | `CONFIRMED [proof, critic-contextual]` (proof plus soundness check by critic reading the algebraic context) |
| Explicit 8×8 $R_{2\pi} = \mathbb{1}_8 - 4\pi L_{\eta\zeta}$ — researcher's SymPy verification plus critic's independent blind re-verification | `CONFIRMED [mechanical, critic-blind]` |
| Kausch's internal statement that $Z[\mathcal{C}_2]$ decomposes into 4 terms, cited but not re-derived | `CONFIRMED [literature]` (Kausch's own result — not a project-central claim, so the CONFIRMED rule on `[literature]` alone does not bite; were the project claiming this decomposition as its own contribution, the strongest allowed label would be STRONG CONJECTURE until re-derived or independently reviewed) |
| Correspondence between those 4 terms and this project's 4 anyon sectors (dictionary) | `STRONG CONJECTURE [literature, critic-contextual]` (literature is the premise; critic has reviewed the dictionary's coherence but full re-derivation is pending) |
| TGSD = 4 on the $N=2$ torus via bond-CAR identities | `STRONG CONJECTURE [mechanical, special-case: N=2]` |
| Parity-sector separation tested on one small graph | `STRONG CONJECTURE [mechanical, special-case: triangle+pendant graph]` |
| ED-computed ground-state count for $N=3$ torus agreeing with prediction | hypothetical `STRONG CONJECTURE [numerical, critic-blind, special-case: N=3]` |
| TGSD = $4^g$ on the actual 2D lattice at general $N \ge 3$ | `OPEN` |

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

- Writes to the research tree flow through PI's authority: PI writes `log.md`, `plan.md`, `dead_ends.md`, `report_*.md`, `focus.md`, `story.md`, and `principles.md` directly; curator writes `note.md` on PI's dispatch (see § note.md — Ownership); simulator writes under `data/`, `images/`, and `src/`; engine-builder writes under `lib/`. No other agent writes to the tree
- To propose a status change, describe the rationale in your deliverable file
- Honest reporting is paramount: never propose stable for something that has not been sufficiently verified
