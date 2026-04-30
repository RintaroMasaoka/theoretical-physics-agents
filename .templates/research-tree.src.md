# Research Tree

Research information is organized as a **tree** under `research/`. Every node is a folder. Files serve distinct roles:

**Language.** Body prose in every file described here (log.md Current State, Evidence entries, note.md, plan.md, story.md, report_*.md, checks/*.md, principles.md, conventions.md, focus.md, dead_ends.md, …) is written in **{{ language }}**. Exceptions: the structural `##` headings shown in English in this document (e.g., `## Current State`, `## Evidence`, `## Background`), frontmatter keys, folder slugs, technical terms, proper nouns, and LaTeX mathematics may stay in their original form. The English examples below illustrate structure, not language.

| File | Layer | Role |
|---|---|---|
| `note.md` | Destination (SoT) | **Derivation-bearing paper-quality knowledge. Curator-authored** — see § note.md — Ownership below. Free-form prose — no prescribed sections, no frontmatter. Every principal claim carries **both** a derivation (inline or cited, see Scope of derivation) and a Markdown link to a `checks/*.md` verification record (see Verification Provenance Records). Written when a node has significant established results. Not every node has one |
| `report_{slug}.md` | Report (with provenance) | **Verified report with explicit provenance references.** Self-contained analysis promoted from worker deliverables after independent critic review. Curator creates when physicist directs promotion. Belongs to the node, not to the timeline. See below |
| `checks/` | Verification record | **Node-local verification record.** Stable critic-note reviews, reproduction notes, and mechanical/numerical check summaries for the node's note.md / report_*.md claims. These are the durable review artifacts a reader may inspect without leaving the tree. They are evidence ledgers, not substitutes for derivations in note.md |
| `plan.md` | Ladder (strategy) | **Strategy and approach.** How to attack this node — decomposition rationale, approach decisions, children's roles. Rewritten by curator as strategy evolves (physicist directs the change via `research/focus.md § Tree Directives`) |
| `log.md` | Ladder (process) | **Research process.** Has frontmatter (`kind`, `status`). Contains Current State (rewritten) and Evidence (append-only). Curator writes: every worker deliverable becomes an Evidence entry, every shift in understanding updates Current State |
| `story.md` | — | Narrative structure of children (optional). At root: the paper's overall narrative structure |
| `principles.md` | — | Constraints specific to this subtree (optional). At root: cross-cutting research constraints |
| `conventions.md` | Convention ledger | **Notation and convention source of truth (optional, root by default; subtree-local when needed).** Records choices that change how formulas are read — sign conventions, orderings, normalizations, index names, Fourier transforms, tensor leg orientation, symbol reservations, and terminology-to-symbol mappings. See § conventions.md — Notation and Convention Ledger |
| `dead_ends.md` | Off-SoT register | **Rejected-direction register (optional).** Approaches shown wrong, with the reason and the evidence (counterexample, falsifying computation, or critic-rejected derivation). Free-form prose. Pairs with `asides.md` — together they form the two off-SoT registers (rejected vs parked). At root by default; a node may carry its own when the rejection is clearly subtree-local |
| `asides.md` | Off-SoT register | **Parked off-thread items (optional).** Items not committed to the active thread but worth not forgetting — spare-capacity questions, side curiosities, loose details left unpinned, items of unclear project scope. Free-form prose, no derivation requirement. At root by default; a node may carry its own when the items are clearly subtree-local. Three exits: promoted into a node's note.md (becomes load-bearing), moved to `dead_ends.md` (shown wrong), or stays parked indefinitely. Capture path: workers surface candidate items in their deliverables; curator absorbs them. The user may also append directly during `/meeting`, mirroring the user-collaborative exception for `note.md` (the file is informal, so the second-reader rationale that locks `note.md` to curator does not bind here) |
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

**Node-root prohibition.** Never place source files (`.py`, `.jl`, …) directly in the node folder. Node roots are reserved for narrative files (`log.md`, `plan.md`, `note.md`, `report_*.md`, `story.md`, `principles.md`, `conventions.md`) plus named artifact directories such as `checks/`, `src/`, `data/`, and `images/`. Loose scripts in node roots break the tree's legibility and bypass the `src/` reuse rule, so creating `src/` (even for a single script) is mandatory.

**Placement — lowest common ancestor.** Place a script at the lowest node that is an ancestor of every node that uses it. Common cases: a script used only in node `X` lives in `X/src/`; a script shared across siblings of a parent `P` lives in `P/src/`; if two cousins share a script, it lives in their nearest common ancestor's `src/`. This avoids duplication and makes scripts discoverable from the research context.

**Companion `{slug}.md` required.** Every script `{slug}.{ext}` carries a companion `{slug}.md` in the same `src/` directory — this is the script's permanent label in the tree, so a reader browsing `src/` knows what each file computes without opening the code or grepping `logs/`. Minimum content: what the script computes, key parameters, and how to run it. For simulator's long-lived measurement scripts the companion expands into a full implementation description (see simulator agent). For researcher's one-off attempt scripts a short blurb (a paragraph or two) is enough while the work is provisional. Once a script supports a note.md / report_*.md claim, the reproducibility summary belongs in the node's `checks/` record or in the promoted report; `logs/` remains the raw notebook, not the durable verification surface.

**Retirement.** Superseded scripts move to `src/archive/` rather than being deleted, so the reasoning history stays searchable.

**Hygiene.** Do not commit `__pycache__/`, `.ipynb_checkpoints/`, or any per-machine bytecode generated by running scripts.

### `data/`, `images/`, and root `lib/`

- **`data/`**: Simulation data in TSV format with structured metadata headers. Placement: the node that **owns the investigation** — data belongs to the node where the measured observable is studied. Managed by simulator (see simulator agent for TSV metadata-header format and archival rules)
- **`images/`**: Figures and visualizations. Placement: same node as the data they visualize. Managed by simulator
- **`research/lib/`** (root only): Shared simulation framework modules managed by engine-builder. `lib/test/` contains module tests

Agents that are not simulator, researcher, or engine-builder treat all of `src/`, `data/`, `images/`, and `lib/` as read-only context.

## conventions.md — Notation and Convention Ledger

`conventions.md` is the tree's ledger for choices that determine how symbols, formulas, and technical phrases are read. It is distinct from `concepts/`: a concept note defines what an object is; a convention entry fixes how this project denotes, orders, or normalizes that object. For example, "Grassmann variable" belongs in `concepts/`; "the site integration measure is ordered as ..." belongs in `conventions.md`.

**Why this file exists.** Notational drift is not a local typo. A sign convention, Fourier convention, tensor-leg order, or symbol reservation can silently change the meaning of claims across siblings. Keeping these choices in ordinary prose inside one note.md makes them invisible to the next branch; scattering them across logs makes the reader reconstruct the project's language archaeologically. A convention ledger gives curator one place to reconcile the tree's symbolic language before the inconsistency reaches note.md or the manuscript.

**Placement and scope.**
- Root `research/conventions.md` carries project-wide conventions and symbol reservations.
- A node may carry its own `conventions.md` only when the choice is genuinely subtree-local or intentionally differs from the parent. The child entry must state the parent convention it refines or overrides.
- If a subtree-local convention becomes used outside that subtree, promote or copy the entry to the lowest common ancestor and update the old entry to point there. Do not let sibling branches rely on private conventions.

**What belongs here.**
- Symbol reservations and overloaded-symbol decisions: e.g., "$D_i$ always means the canonical defect tensor after the sign factor; bare tensors are written $D_i^{\mathrm{bare}}$."
- Sign, orientation, ordering, and normalization choices: integration measure order, tensor leg ordering, Fourier transform convention, phase conventions, index ordering.
- Project-specific terminology-to-symbol mappings when the term and symbol must stay paired across nodes.
- Known compatibility bridges: how this project's convention translates to a cited paper's convention, with a reference when available.

**What does not belong here.**
- General definitions of technical concepts — put those in `concepts/` and link them.
- Derivations proving a claim — put those in note.md or a promoted report; the convention ledger may link to the derivation.
- Process history or "we changed this on date X" narrative — put the evidence trail in log.md if needed. The ledger states the current convention.

**Entry shape.** Free-form prose is allowed, but each entry must make these four facts recoverable:

```markdown
## {Convention name}
Scope: {project-wide | research/{subtree}/ | specific linked claims}
Convention: {the actual notation / order / sign / normalization rule}
Reason: {why this choice is used, or which external convention it matches}
Consequences: {symbols reserved, formulas affected, links to note.md / report_*.md / checks/*.md that rely on it}
```

The reason is load-bearing: without it, later agents treat the entry as arbitrary dogma and may "simplify" it away. Consequences are also load-bearing: they define the impact surface for a future convention change.

**Maintenance rule.** When curator promotes or rewrites a note.md/report claim that introduces, depends on, or changes a convention, curator must update the nearest applicable `conventions.md` in the same dispatch, then scan affected ancestor/sibling note.md files for inconsistent usage. If the convention is still provisional, state the scope honestly and do not let note.md use it as if project-wide. If two live conventions conflict, curator does not silently choose: keep the narrower convention scoped, add a compatibility note if possible, and flag the conflict to physicist when scientific judgment is needed.

## note.md — Source of Truth

**What note.md is.** The paper's substantive content *in situ* — for each principal claim the node has established, the claim **together with the derivation that establishes it** (proof sketch, symbolic computation, argument, or cited external result) written to paper quality. Stacking the note.md files of the tree in narrative order should yield the body of the paper. An abstract-level registry of claims (each line a sentence plus a provenance link, with the actual derivation kept elsewhere) is **not** note.md; it is a table of contents mistakenly labelled SoT.

**"Source of Truth" means derivation-bearing.** A reader who accepts a claim in note.md must be able to check *why* within note.md itself — because the derivation is present. Provenance references are Markdown links to node-local `checks/*.md` records whose front matter summarizes confidence, evidence channels, review channels, and scope; they are **not** a substitute for the derivation. A CONFIRMED claim accompanied only by a linked record gives the reader a stamp and nothing to check, which forces the reader into `logs/` and defeats note.md's purpose. The dividing line between note.md as a paper seed and note.md as an index is exactly this: derivations live in the note, not behind the record.

**Scope of "derivation".** What counts satisfies one of:
- *Inline derivation* — a proof sketch, symbolic / numerical computation with its setup and conclusion, or worked-out argument. Full textbook detail is not required; what is required is that a reader in a neighbouring field can follow the logical chain from premises to conclusion without leaving note.md (modulo Markdown links to concept notes or sibling nodes that supply definitions, referenced lemmas, or derivations covered at another node).
- *Cited external result* — when the claim is a result from external literature used as a premise, cite the source (with section / theorem number where reasonable) in the note itself. The citation *is* the derivation pointer, and the linked provenance record will include `evidence: [literature]`. This route is acceptable for results the project *uses*; it is **not** acceptable for project-central claims (those this project is staking as its own contribution) — project-central claims must carry an inline derivation.

**All confidence levels carry derivation, not only CONFIRMED.** STRONG CONJECTURE, CONJECTURE, and OPEN claims that appear in note.md carry the partial argument, special-case verification, or motivating evidence that *is* available — with explicit scope — rather than being stated as bare tagged sentences. An OPEN claim appears in note.md only when its formulation is itself established knowledge (i.e., the node knows *what* the question is and *why* it is the right question); the answer being unknown is stated, but the framing is substance.

**Audience — the context-free reader.** note.md is the one file in the tree written **for a reader who knows nothing about the research process**: no memory of attempts, critic verdicts, revision rounds, or session history; no access to `logs/`, `plan.md`, or `log.md`; no prior exposure to this project's internal vocabulary. The reader is presumed to be a working researcher in a neighbouring field, so standard terminology of that field can be used — but anything project-specific (internal IDs, attempt labels, working-group jargon) must be introduced before use, or linked to a concept note / sibling note.md with an explicit Markdown link. The test: if reading note.md leaves the reader needing to open any other file in this repository — whether to understand *what* the node has established or to check *why* it holds — note.md has failed. Markdown links are the acceptable form of "other file" — following a link to a concept definition or a sibling node's derivation is part of normal reading; forcing the reader into `log.md` or `logs/` is not.

This audience, combined with the derivation-bearing requirement, is the file's strongest constraint. The prose must read cleanly **in isolation** — not merely "in principle understandable given enough context."

**Paper-skeleton test (run after any substantive edit).** Ask: *can a reader assemble this node's contribution into the paper body from note.md alone?* If the only way to reconstruct the derivation of a claim is by reading `logs/`, the note.md is still an abstract, not a paper section — it fails. The correct response is to either (i) lift the derivation into note.md at paper-quality detail, (ii) replace the bare claim with an honest lower-confidence formulation together with the partial derivation that is available, or (iii) remove the claim from note.md pending more work. A bare tagged claim whose derivation lives only in `logs/` is **never** the correct end state.

**No template.** The content and structure emerge from the research itself. A node studying a mathematical structure will naturally differ from one resolving a paradox or surveying a field. Prescribed sections constrain the researcher's thinking — the prose should take whatever form best captures the established knowledge together with its derivation.

**Content rules (enforced on every curator dispatch):**

1. *No frontmatter* — SoT files are clean prose.
2. *Derivation or citation for every principal claim* — per "Scope of derivation" above. A claim stated with a provenance reference but without an inline derivation or a cited source is incomplete and must be completed or demoted before the dispatch closes.
3. *Provenance link alongside every principal claim* — per the Verification Provenance Records section below. The link points to the `checks/*.md` record that summarises the verification chain in front matter and explains it in prose; it does not replace the derivation required by rule 2.
4. *No chronology, no process-status phrasing.* The rule excludes **session history** from note.md, not **substance**. A proof, a symbolic computation with its setup and conclusion, or a worked-out argument is the content of a claim; rule 2 requires it to be there. What rule 4 rules out is the state of the investigation — dated status blocks (`Status update YYYY-MM-DD`, `Progress 2026-…`), Current-State / Evidence sections copied from log.md, cycle references (`r2`, `r3 stage`, `latest cycle`), review-state markers (`critic pending`, `REVISE minor`, `awaiting resubmission`), and workflow words (`resubmission`, `previous attempt`). These decay on the next cycle; the confidence information they try to convey is exactly what the linked provenance record encodes. Write the derivation in timeless prose and let the link carry the reader to verification metadata. Conflating substance with session history — treating a derivation as a "process artifact" and stripping it — produces the failure mode this whole section is written to prevent.
5. *No undefined project-internal labels* — ad-hoc identifiers that index items in a working list but have no stable definition elsewhere (e.g., open-question IDs, informal candidate/hypothesis tags, attempt slugs, cycle references) may appear only if they are either (a) introduced with a one-sentence explanation where first used, or (b) replaced by a self-contained description. Preferably just describe the thing in plain prose. A reader should never have to grep the repo to learn what an internal label means.
6. *Every non-common technical term is gated* — for each term that a reader in a neighbouring field would not immediately recognise, use one of two gates:
   - *Markdown link*: `[display text](relative/path.md)` or `[display text](<relative/path with spaces.md>)` pointing to a concept note in `concepts/` or a sibling/ancestor node's note.md. Link targets are relative to the file containing the link. Follow the link to verify it resolves.
   - *Inline definition*: one sentence introducing the term before it is used.
   
   When in doubt, link; create a concept note in `concepts/` if one does not yet exist (see the curator agent's Knowledge Base Maintenance section).
7. *Every load-bearing convention is either stated or linked* — if a claim depends on a nonstandard notation, sign, order, normalization, or symbol reservation, note.md must either state the convention before use or link to the applicable `conventions.md` entry. Do not rely on a convention being "known from earlier attempts" or buried in log.md. This rule is the convention analogue of rule 6: technical terms need definitions; symbolic choices need convention anchors.

*How rules 5 and 6 divide the work*: rule 5 targets *labels* (no stable definition exists to link to, so the cleanest fix is to describe the thing in prose); rule 6 targets *technical vocabulary* (a stable definition exists or should exist, so the cleanest fix is to link to a concept note).

**Root note.md** captures the project's overall established understanding — the core claims, their derivations (or citations), scope, and how they connect. As research progresses, this evolves from a research question into a derivation-bearing account of the project's central findings.

**Child note.md** captures what that specific investigation established, with derivations.

**When to create**: When a node reaches stable and has derivation-bearing results worth stating as source of truth. Leaf nodes doing pure computation may never get one.

**Ownership — note.md is curator-authored.** This is the one file in the tree whose prose is written by curator. In the `/run` model, research judgment is split across three agents — physicist (direction, owns `research/focus.md`), curator (tree writes, owns every file under `research/**` except `research/focus.md` and curator-dispatched critic Target B review files under `checks/`), critic (auto-attached review). note.md is curator's deepest responsibility: the split exists because note.md demands cognitive modes that would otherwise compete with active research for attention:

- **Derivation lifting and provenance linking (curator's core task)**: each principal claim in note.md carries its derivation *and* a Markdown link to a node-local `checks/*.md` record whose front matter contains confidence, first-order evidence, independent review, and optional scope. Lifting the derivation into paper-quality prose and then writing/linking the record correctly both require re-reading the underlying worker deliverables, report_*.md, and critic reports to reconstruct what was actually shown — including identifying the right level of detail to preserve in note.md vs. defer to a Markdown link. Provenance linking alone — attaching stamps to bare claim sentences — is the degenerate form § note.md — Source of Truth rules out; curator's mandate is the harder lift of writing the derivation into the note
- **Separation of concerns**: physicist's attention during `/run` is on direction — what question matters next, whether the story holds together. Lifting verified evidence *with its derivation* into publication-quality prose is a different cognitive mode; combining it with direction-setting reliably starves synthesis under research load. Giving note.md a dedicated author (curator, auto-dispatched every cycle) prevents that drop
- **Second-reader quality**: The agent who produced a result is anchored by the deliverable they wrote and is a poor judge of whether the prose reads cleanly to someone unfamiliar with the research process. note.md's promise is exactly that it reads cleanly to such a reader, with the derivation checkable in isolation, so the author should be a second reader — curator, coming to the evidence fresh
- **Cross-tree coherence**: note.md at one node must harmonize with note.md at sibling and ancestor nodes (consistent terminology and notation, valid Markdown links, referenced concept notes and convention entries, derivations that compose across node boundaries). This requires reading the tree holistically, which physicist does not do during cycles — physicist's reading scope is the ancestor spine plus direct children. Curator reads the whole tree by design

Curator's role with respect to note.md: every cycle, read worker deliverables and their critic verdicts together with physicist's tree directives, append Evidence to log.md, promote verified results into `report_{slug}.md` when physicist directs, preserve durable verification records in `checks/`, and — when a node accumulates CONFIRMED / STRONG CONJECTURE claims with derivations — lift those derivations (not just claims) into note.md at paper quality. Physicist never writes note.md directly; physicist's directives live in `research/focus.md § Tree Directives` and curator executes them.

Two narrow exceptions to curator-only note.md authorship (for any agent, not only curator's):

1. **Trivial mechanical fixes.** Typo corrections, fixing a broken Markdown link, renaming a term after a concept note is renamed. The rule of thumb: if the replacement is uniquely determined — any competent reader would produce the same correction, with no judgment about phrasing or structure — the edit is mechanical. If there is any judgment about wording, ordering, or what claim to state, it is not mechanical and must go through curator
2. **User-present collaborative rewrites (`/meeting`, `/launch`).** When the user is actively collaborating — during a meeting discussion, or during the initial project launch — the main agent and user may rewrite note.md together to reflect synthesis produced in the conversation. These skills explicitly treat note.md as the destination for human-in-the-loop narrative decisions. The user acts as the second reader in real time, which is what curator otherwise provides; so the curator-only rule does not bind

Anything beyond these two categories — adding a section, rewording a claim, updating a provenance link, restructuring prose, inserting a "status update" block — goes through curator. The critic Target B exception is only for separate `checks/` review files, never for note.md prose. A note.md edit written by another channel (e.g., a mistaken direct edit during a fast-paced cycle, or a legacy accretion from an earlier process model) is legitimate input to the tree, but curator will rewrite it on the next dispatch to restore SoT quality.

This rule has a failure mode to watch for: note.md drifting into a log-like chronicle with time-stamped "Status update YYYY-MM-DD" sections stacked on top of each other. That shape is the footprint of non-curator appending and signals that curator dispatches have been skipped; the next curator run should consolidate such stacks into a single, present-tense statement of the node's established knowledge.

### Critic layering on note.md

The derivations written into note.md are the substance the paper will carry. They must pass independent scrutiny **as they appear in note.md**, not merely inherit the scrutiny of the upstream attempt in `logs/`. Curator's distillation can introduce new failure modes that the attempt-level critic never saw — simplifications that glossed a gap, notational drift, a step that was obvious to the researcher being compressed past legibility, a composed argument spanning several attempts whose joint soundness was never checked.

The maintenance chain is therefore:

1. Researcher produces an attempt in `logs/` with full working-note derivation
2. Critic reviews the attempt (blind or contextual) — the existing first-layer review
3. Curator lifts the derivation into note.md at paper quality, consolidating across attempts as needed
4. **Curator dispatches critic on the note.md derivation itself** as a separate pass, targeting the derivations touched in this dispatch. Mode is contextual by default (the critic needs the surrounding note.md + ancestor chain to judge whether the lifted derivation suffices for its role in the narrative); blind mode may be chosen when the derivation is purely mechanical
5. Curator applies the critic's findings (fixing the note.md prose, not annotating it in place — note.md is publication-quality prose, so critic writes findings to a separate file under `checks/` that curator consumes; see the critic and curator agents)
6. Over repeated maintenance cycles, this layers multiple critic passes over the same note.md section. That accretion is the mechanism by which note.md earns its property of surviving many critic eyes

Curator composes each such review into the affected claims' linked provenance records (adding the appropriate review channel to the record's front matter and preserving the critic file in `checks/`). A claim whose **note.md-level** derivation has been critic-reviewed links to a record that reflects *this* review layer, distinct from whatever review the upstream attempt already had. Over time this produces note.md prose whose derivations have been re-examined in their published form, which is exactly what a paper seed requires.

This layering is not optional decoration — when a note.md carries substantive new derivations (not just prose polish on an already-reviewed derivation), a note.md-level critic pass is part of closing the dispatch. Skipping it reproduces the failure mode the whole "derivation-bearing SoT" design is meant to prevent.

### `checks/` — Node-local verification record

`checks/` is the node's durable verification ledger. It exists because `logs/` is a chronological workbench: useful for reconstructing what happened, but the research tree is intended to be clean and self-contained without routine archaeology through session notebooks. When a verification result is important enough to justify a provenance reference on note.md or report_*.md, the review artifact a reader may inspect should live with the node.

Typical contents:
- `critic_note_{slug}_{YYMMDD_HHMM}.md` — critic Target B reviews of note.md sections, written as separate files so note.md stays publication-quality prose
- `check_{slug}.md` — curator-written reproducibility summaries for scripts / computations that support a promoted claim, with links to the relevant `src/`, `data/`, or `images/` artifacts and the exact claim checked

What belongs here is verification substance, not process chronology. A `checks/` file states the target claim, the method, the result, scope restrictions, and provenance contribution. It may cite raw `logs/` notebooks as provenance, but it must not require the reader to open them to know what was checked. Conversely, `checks/` is not a loophole around note.md self-containment: note.md still carries the derivation or cited external result. `checks/` records how that derivation was reviewed or reproduced.

**When to create**: when a note.md-level critic pass runs, when a mechanical / numerical check supports a promoted claim, or when a report_*.md needs a stable review record that should survive outside the chronological `logs/` stream.

**Naming**: descriptive, lowercase-ish slugs with the check type first, e.g. `critic_note_surface_dispersion_260430_1430.md`, `check_sign_convention.md`. Timestamp Target B critic files so repeated review layers do not overwrite each other.

## Verification Provenance Records

Claims in note.md (and report_{slug}.md) carry a **Markdown link** to a node-local `checks/*.md` record so readers can assess **how** each fact was established, **whether it has been independently reviewed**, and **at what scope**. The metadata lives in YAML front matter at the top of the linked check file; the note.md prose remains ordinary Markdown rather than acquiring a project-specific inline tag syntax.

**Why links plus front matter.** Verification metadata is structured data about a claim, not part of the mathematical sentence itself. YAML front matter is a widely used Markdown convention for document metadata; keeping the axes there makes them machine-readable and keeps note.md publication-quality. The inline surface should therefore be a normal link such as `[verification](checks/check_projector_identity.md)`, while the target file carries the confidence/evidence/review/scope fields.

**Records accompany, not replace, the derivation.** Every claim linking to a provenance record in note.md must also carry the derivation that supports it (inline or cited — see § note.md — Source of Truth, "Scope of derivation"). The record summarises the verification chain so a reader can decide how much trust to invest; the derivation is what the reader actually checks. A linked claim without an accompanying derivation is the failure mode the whole § note.md — Source of Truth is written to prevent, and no refinement of the record schema repairs it.

### Front Matter Schema

Every `checks/*.md` file that supports a note.md or report_{slug}.md claim starts with YAML front matter of this shape:

```yaml
---
claim: "projector identity"
claim_path: "../note.md#optional-heading-or-claim-anchor"
confidence: confirmed
evidence:
  - proof
  - mechanical
review:
  - critic-blind
scope: full
supports_project_central_claim: true
---
```

Fields:

| Field | Meaning |
|---|---|
| `claim` | Short identifier for the claim being certified; enough to disambiguate within the node |
| `claim_path` | Relative Markdown link target to the note.md/report location whose claim this record supports |
| `confidence` | One of `confirmed`, `strong-conjecture`, `conjecture`, `open` |
| `evidence` | First-order evidence channels: `proof`, `mechanical`, `numerical`, `literature`. One or more when multiple derivations agree |
| `review` | Independent review channels: `critic-blind`, `critic-contextual`. Empty list if no independent review has been accepted |
| `scope` | `full` when the full declared scope is verified, otherwise a concrete description of the restricted instance |
| `supports_project_central_claim` | `true` when the project is staking this claim as its own contribution; `false` for external results cited as premises |

The body of the check file then explains the same metadata in prose: target claim, method, result, scope restrictions, links to scripts/data/literature, and the critic or curator judgment. Front matter is the index; the body is the inspectable record.

### Confidence

| Value | Meaning |
|---|---|
| `confirmed` | Verified with no known counterexamples. Publishable as stated |
| `strong-conjecture` | Substantial partial evidence; holds in principal cases but full scope is not closed |
| `conjecture` | Motivated and locally supported, but not sufficiently verified |
| `open` | Unresolved |

### First-Order Evidence

These describe the **evidence chain itself**. A claim may rest on more than one when multiple derivations agree.

| Value | Meaning |
|---|---|
| `proof` | Formal mathematical proof — hand-checked or machine-checked derivation closing the claim at its declared scope |
| `mechanical` | Symbolic / exact computation (SymPy, SageMath, exact enumeration). Computer output is unaffected by LLM reasoning biases |
| `numerical` | Finite-tolerance numerical check with stated convergence criteria |
| `literature` | Established in cited external literature. Being cited as a premise — not yet independently re-derived in this project |

### Independent Review

These describe **who checked the evidence**. Independent review **composes with** first-order evidence — it does not substitute for it. A record with `review: [critic-blind]` and no first-order `evidence` cannot support `confidence: confirmed` (see Rules). A claim with both `evidence: [proof]` and `review: [critic-blind]` is strictly stronger than either alone, because the proof has been subjected to adversarial scrutiny by an independent channel. Likewise `evidence: [literature]` plus `review: [critic-blind]` records that a cited result was not just taken on faith but was re-examined by an independent critic for whether it actually supports the use being made of it.

| Value | Meaning |
|---|---|
| `critic-blind` | Independent adversarial critique by the critic agent in **blind mode** (no research context loaded). Removes expectation bias. The strongest review tier when the claim is mechanical or self-contained |
| `critic-contextual` | Critic agent in **contextual mode** (ancestor chain loaded). Used when soundness genuinely depends on the claim's role in the overall narrative — e.g., "does this argument suffice for its intended position in the story?" |

When critic runs its own SymPy/numerical computation during review, that adds first-order evidence too — e.g., `evidence: [mechanical]` plus `review: [critic-blind]`. A standalone review channel with no first-order evidence is rare — it indicates the critic's evidence was purely logical (just a soundness review of the researcher's argument structure) — and per the rules below such a record can attach only to confidence levels at or below `strong-conjecture`.

### Scope

By default `scope: full` means the claim is verified over its **full declared scope**. When that is not the case, write a concrete scope description — never leave scope implicit. A vague value such as `scope: special-case` is forbidden because readers cannot otherwise evaluate what was covered.

### Rules

- Every `confidence: confirmed` record must carry at least one first-order `evidence` value. Bare confirmation with no first-order evidence is forbidden because readers cannot then evaluate the claim. A `review` value alone does not count as first-order evidence
- Evidence and review channels compose freely when both apply. Always declare every applicable channel — omitting a true channel understates the verification chain
- A record whose `scope` is not `full` **cannot** use `confidence: confirmed` — the strongest allowed value is `strong-conjecture`, because full-scope verification is missing by definition
- `evidence: [literature]` alone (no independent review, no local re-derivation) does not suffice for **project-central claims** — meaning a claim this project is staking out as its own contribution, as opposed to a premise cited from external work. A citation-only record with `confidence: confirmed`, `evidence: [literature]`, and `supports_project_central_claim: false` is fine when the claim is explicitly framed as the external result itself — e.g., "Theorem X of {Author et al.} holds" — and no project contribution is being attested. To reach `confirmed` on a project-central claim, pair `literature` with an independent channel: either a first-order re-derivation (`proof`, `mechanical`, `numerical`) or an independent review (`critic-blind` / `critic-contextual`) that examined the citation's applicability to the specific use being made of it
- If provenance is unclear from the available documents, use the lower confidence value and flag back to physicist rather than guessing

### Strength Guide (informal)

Strength grows monotonically along two directions: (i) more first-order evidence channels when independent channels agree, (ii) addition of independent review on top of first-order evidence. Rough ordering of individual contributions — `proof` is the strongest single first-order channel; `mechanical` and `critic-blind` are comparably strong second tiers; `numerical` below those; `literature` alone is weakest as first-order support for project claims. `critic-contextual` adds a soundness check but does not by itself close a mechanical question. Any non-`full` scope weakens the combined record by restricting the verified region.

### Examples (illustrative shapes)

These are shape-examples showing how the record fields compose; the specific claims are illustrative, not tied to any particular project.

| Claim shape | Linked record front matter |
|---|---|
| A project-central algebraic identity with a hand proof that a critic then re-verified by running an independent symbolic script in blind mode | `confidence: confirmed`; `evidence: [proof, mechanical]`; `review: [critic-blind]`; `scope: full` |
| A structural lemma derived by hand and independently read by critic with ancestor context loaded | `confidence: confirmed`; `evidence: [proof]`; `review: [critic-contextual]`; `scope: full` |
| An explicit matrix or closed-form expression checked by the researcher's symbolic script and re-verified by the critic's independent blind symbolic script | `confidence: confirmed`; `evidence: [mechanical]`; `review: [critic-blind]`; `scope: full` |
| A cited external theorem used as-is, not re-derived here — framed as citing the external result itself, not as a project contribution | `confidence: confirmed`; `evidence: [literature]`; `review: []`; `supports_project_central_claim: false` |
| A dictionary/identification between an external result and this project's own objects, where critic has reviewed coherence but full re-derivation is pending | `confidence: strong-conjecture`; `evidence: [literature]`; `review: [critic-contextual]`; `scope: full` |
| A counting/dimension claim established symbolically only on the smallest parameter instance | `confidence: strong-conjecture`; `evidence: [mechanical]`; `review: []`; `scope: "smallest parameter instance"` |
| A structural separation tested on one small concrete example | `confidence: strong-conjecture`; `evidence: [mechanical]`; `review: []`; `scope: "one concrete example"` |
| A numerical agreement with prediction on a specific parameter choice, checked by critic in blind mode | `confidence: strong-conjecture`; `evidence: [numerical]`; `review: [critic-blind]`; `scope: "specific parameter choice"` |
| The same claim extended to the full declared scope, not yet verified | `confidence: open`; `evidence: []`; `review: []`; `scope: full` |

## report_{slug}.md — Promoted Verified Reports

Self-contained analyses that have been independently reviewed by the critic agent (auto-attached when the source deliverable was produced) and promoted from worker deliverables in `logs/` (a flat directory for raw research notebooks, outside the tree). Think of these as a student's report submitted for the record — structured, verified, and complete enough to stand on their own.

**Relationship to other files:**
- Worker deliverables in `logs/` are research notebooks (raw work). Reports are the verified, promoted subset
- `note.md` is the node's integrated knowledge. Reports are individual analyses that note.md may draw from
- `checks/` stores the stable verification record for reviews and reproducibility checks supporting note.md / report_*.md claims
- Not every deliverable becomes a report. Not every node has reports

**When to create**: When a worker deliverable contains a significant, verified result worth preserving as structured knowledge in the tree. Physicist directs promotion via `research/focus.md § Tree Directives`; curator creates the report.

**Naming**: `report_{slug}.md` where `{slug}` is a descriptive identifier (e.g., `report_surface_dispersion.md`, `report_magnetic_c4t.md`).

## plan.md — Strategy and Approach

A node's strategic document — decomposition into children, approach choices, and their rationale. Curator-maintained: physicist may direct strategy changes via `research/focus.md § Tree Directives`; curator also rewrites plan.md when its structural-maintenance rules create or repair decomposition, without changing scientific direction. Rewritten (not appended) when strategy evolves.

```markdown
{Free-form strategy notes. No prescribed sections.
Typical content: decomposition rationale, why children exist and their roles,
approach decisions and alternatives considered, strategic priorities.}
```

**No template.** The content depends on the node's nature. A branch node might describe why its children exist and how they contribute; a leaf might outline the approach to a specific calculation or proof.

**Relationship to log.md**: plan.md is forward-looking (how to proceed), while log.md captures current understanding and accumulated evidence. When strategy changes, rewrite plan.md; when results come in, update log.md.

**When to create**: When a node has non-trivial strategic decisions — decomposition into children, choice of approach, prioritization. Simple leaf nodes doing straightforward work may not need one.

## log.md — Research Process

The node's research-process log — current state and evidence chain. Curator-maintained: every cycle, curator appends an Evidence entry for each new worker deliverable (with its critic verdict) and rewrites Current State when understanding shifts. Every node starts with log.md. plan.md is added when strategic decisions need recording. note.md comes last, when results are stable.

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
  conventions.md       (project-wide notation and convention ledger)
  dead_ends.md         (rejected-direction register — off-SoT)
  asides.md            (parked off-thread items — off-SoT)
  lib/                 (shared simulation framework — engine-builder manages)
    ClockModel.jl
    XYModel.jl
    test/
  Paradox Resolution/
    note.md            (derivation-bearing: the paradox stated, and the derivation resolving it)
    plan.md            (approach strategy)
    log.md             (research process: current state, evidence)
    report_symmetry_analysis.md  (curator-promoted verified report on symmetry constraints)
    checks/
      critic_note_symmetry_analysis_260430_1430.md
  Lattice BKT/
    note.md            (derivation-bearing knowledge of this direction)
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
        check_sign_convention.md (short blurb; promoted checks live under checks/)
      data/            (simulation data for this investigation)
      images/          (figures generated from this data)
      report_escape_rate.md
      checks/
        check_sign_convention.md
```

## Data Layers Summary

| Layer | Location | Worker access | What it contains |
|---|---|---|---|
| **Research tree — SoT** | `research/**/note.md` | Read-only | Derivation-bearing verified knowledge — claim + derivation + Markdown provenance link, free-form prose written to paper quality (the paper's substance) |
| **Research tree — reports** | `research/**/report_*.md` | Read-only | Self-contained analyses promoted from worker deliverables in `logs/` after critic acceptance |
| **Research tree — checks** | `research/**/checks/*.md` | Read-only, except curator and critic Target B | Node-local verification records with YAML front matter: note.md critic reviews, reproducibility summaries, and check results supporting provenance links |
| **Research tree — plan** | `research/**/plan.md` | Read-only | Strategy: decomposition rationale, approach decisions, children's roles |
| **Research tree — log** | `research/**/log.md` | Read-only | Process: current state, evidence chain, kind/status |
| **Convention ledger** | `research/**/conventions.md` | Read-only | Current notation, sign, ordering, normalization, and symbol-reservation choices, scoped to the node/subtree |
| **Concept definitions** | `concepts/` | Read-only (concept-checker and curator may create/update entries) | Atomic term definitions, linked from any file via explicit Markdown links |
| **Computation — framework** | `research/lib/` | Read-only (engine-builder writes) | Shared simulation modules |
| **Computation — source** | `research/**/src/` | Write (simulator, researcher) | Source code tied to a node: measurement / analysis / plot / verification scripts, each with a companion `{slug}.md` |
| **Computation — data** | `research/**/data/` | Write (simulator) | Simulation data (TSV with metadata headers) |
| **Computation — figures** | `research/**/images/` | Write (simulator) | Visualizations |
| **Research notebooks** | `logs/*_{type}_*.md` | Write (own deliverables only) | Worker deliverables: reading notes, attempts, simulations |
| **Session cursor** | `research/focus.md` | Not relevant to workers | Physicist's current focus position in the tree |
| **Session context** | `logs/last_session.md` | Not relevant to workers | Volatile work context for session handoff, written by session-wrap-up |

**Tree navigation**: `ls research/{path}/` to see children (subfolders). Read `note.md` for verified knowledge (SoT), `report_*.md` for verified analyses, `checks/` for node-local verification records, `plan.md` for strategy and decomposition, `log.md` for current research state and evidence, `story.md` for narrative structure, `principles.md` for constraints, and `conventions.md` for notation / convention choices.

Each node has a `kind` and `status` in its **log.md** frontmatter (not note.md). Node status is set by curator, based on physicist's Tree Directives and evidence accumulated in log.md (see `{{ runtime.agents_dir }}/curator.md` and `{{ runtime.agents_dir }}/physicist.md`).

- Writes to the research tree are split by agent: **physicist** writes only `research/focus.md` (cursor + directives + worker dispatch plan); **curator** writes everything else in the tree — node folders, `log.md`, `plan.md`, `dead_ends.md`, `asides.md`, `report_*.md`, `checks/`, `note.md`, `story.md`, `principles.md`, and `conventions.md` — executing physicist's directives plus its own default operating rules (including splitting overloaded nodes when the evidence record has outgrown the parent scope; see § note.md — Ownership and curator.md); **critic** may write only curator-dispatched Target B review files under `research/**/checks/`; simulator writes under `data/`, `images/`, and `src/`; engine-builder writes under `lib/`. No other agent writes to the tree
- To propose a status change, describe the rationale in your deliverable file
- Honest reporting is paramount: never propose stable for something that has not been sufficiently verified
