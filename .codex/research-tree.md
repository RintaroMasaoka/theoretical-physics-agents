# Research Tree

Research information is organized into typed surfaces. The active `research/` tree is working research memory; `research/archive/` preserves retired nodes; `manuscript/` is the human-authorized paper surface. Every file has an identity, authority level, and link boundary. These distinctions are not cosmetic: later agents reconstruct context from these files, so mixing fact, state, strategy, backlog, raw audit records, and process-heavy retired nodes lets local mistakes propagate as durable assumptions.

**Language.** Body prose in every durable file described here (manuscript prose, note.md, state.md Current Board / Evidence entries, plan.md, backlog.md, story.md, report_*.md, checks/*.md, principles.md, conventions.md, focus.md, dead_ends.md, …) is written in **japanese**. Exceptions: the structural `##` headings shown in English in this document (e.g., `## Current Board`, `## Evidence`, `## Background`), frontmatter keys, folder slugs, technical terms, proper nouns, and LaTeX mathematics may stay in their original form. The English examples below illustrate structure, not language.

## Authority Layers

`manuscript/` is the highest authority layer: human-authorized, fully self-contained, paper-quality prose. It is not a research log, not a claim registry, and not a link index into the research tree. Its narrow non-prose exception is `manuscript/authorizations/*.md`: meeting-created approval snapshots that record exactly which `note.md` artifact the user approved for manuscript use. If manuscript prose conflicts with `research/**/note.md`, agents follow `manuscript/` and flag the conflict rather than silently reconciling it.

`draft/` is different: it is the `/write` paper-draft workspace (`draft/outline.md`, `draft/conventions.md`, `draft/sections/*.md`, `draft/versions/*.md`). It is not human-authorized authority and does not override `manuscript/` or `research/**/note.md`. A draft only becomes authoritative when a human promotes or rewrites it into `manuscript/`.

`research/**/note.md` is the draft fact layer: agent-maintained, derivation-bearing, and self-contained for established facts at that node, but lower authority than `manuscript/`. It may be newer than the manuscript and is the main surface for reusable research facts, not for current workflow state.

`literature/notes/{id}.md` is a paper-level source record: reader-authored, source-facing, and project-independent. It records what an external paper states in its own notation and convention. It is not a project fact layer and not a bridge surface. Research nodes cite it when they use external results, but the source record itself does not decide how the project should use the paper.

Authority order:

```text
manuscript/
  > research/**/note.md
  > research/**/report_*.md
  > research/**/state.md
  > literature/notes/{id}.md
  > .logs/
```

This is an authority order, not a link chain. `literature/notes/{id}.md` is authoritative only for what the source record says about the external paper; the paper itself remains the ultimate source. `research/**/checks/*.md` is not a standalone claim-authority layer in this ladder; it is the verification/provenance authority attached to linked claims in note.md or report_*.md. A check record can force demotion, revision, or retraction of a claim, but it does not become an independent fact surface. Durable research prose does not link to `.logs/`; `.logs/` is a raw audit archive used only when a workflow explicitly enters audit / archaeology / contamination-tracing mode.

| File | Layer | Role |
|---|---|---|
| `note.md` | Fact layer | **Established node facts.** Agent-maintained prose for claims, definitions, derivations or derivation skeletons, scope, limitations, and source/project boundaries. Not final human authority, not current research state, not a report index. No frontmatter. Does not link to `.logs/` or any dot surface |
| `report_{slug}.md` | Clean analysis artifact | **Worker-authored or worker-originated clean analysis.** A closed, self-contained analysis artifact placed in the node whose scope it serves. Not an authority layer for integrated facts and not a living workspace. A report may later trigger a subnode, but the graph change is a separate authority action |
| `checks/` | Durable verification surface | **Node-local verification records.** Critic verdicts, reproduction records, report reviews, and note reviews. A check file states target, method, result, scope, and limitations in its own prose. It does not link to `.logs/`, is not a substitute for the derivation in note.md/report prose, and is not a standalone fact surface |
| `state.md` | Research state layer | **Graph-structured current board and absorbed evidence ledger.** Has frontmatter (`kind`, `status`). Records what is known, unknown, active, blocked, or disputed at this node, plus compact evidence entries. It is not the fact layer. It absorbs `.logs/` content but does not link to `.logs/` |
| `plan.md` | Decomposition / strategy layer | **Recorded node decomposition and planner-supplied strategy.** Children roles, decomposition rationale, approach choices, and success criteria when they are needed to understand the active graph. Not current evidence, not tactical reminders, not an append-only history |
| `sources.md` | Source map (optional) | **Node-local map of external sources.** States which `literature/notes/{id}.md` records matter to this node, what source-side questions remain, what each source is used for, what it is explicitly not used for, and whether any bridge is absent, candidate, or established elsewhere. It is not a source record, not a fact layer, and not a convention ledger |
| `backlog.md` | Backlog layer (optional) | **Parked executable reminders.** Pending work that should survive beyond `research/focus.md` but is not immediate dispatch, not strategy rationale, not evidence, and not fact. Prune stale items during session-end maintenance |
| `story.md` | — | Narrative structure of children (optional). At root: the paper's overall narrative structure |
| `principles.md` | — | Constraints specific to this subtree (optional). At root: cross-cutting research constraints |
| `conventions.md` | Convention ledger | **Notation and convention source of truth (optional, root by default; subtree-local when needed).** Records choices that change how formulas are read — sign conventions, orderings, normalizations, index names, Fourier transforms, tensor leg orientation, symbol reservations, and terminology-to-symbol mappings. See § conventions.md — Notation and Convention Ledger |
| `dead_ends.md` | Outside fact layer | **Rejected-direction register (optional).** Approaches shown wrong, with the reason and the evidence (counterexample, falsifying computation, or critic-rejected derivation). Free-form prose. Pairs with `asides.md` — together they form the two outside-fact-layer registers (rejected vs parked). At root by default; a node may carry its own when the rejection is clearly subtree-local |
| `asides.md` | Outside fact layer | **Parked off-thread items (optional).** Items not committed to the active thread but worth not forgetting — spare-capacity questions, side curiosities, loose details left unpinned, items of unclear project scope. Free-form prose, no derivation requirement. At root by default; a node may carry its own when the items are clearly subtree-local. Three exits: promoted into a node's note.md (becomes load-bearing), moved to `dead_ends.md` (shown wrong), or stays parked indefinitely. Capture path: workers surface candidate items in their deliverables; curator absorbs them. The user may also append directly during `/meeting`, mirroring the user-collaborative exception for `note.md` (the file is informal, so the second-reader rationale that locks `note.md` to curator does not bind here) |
| `src/` | Computation | Source code tied to a node (measurement, analysis, plot, or verification scripts), each with a companion `{slug}.md` |
| `data/` | Computation | Simulation data (TSV format with metadata headers) |
| `images/` | Computation | Figures and visualizations |
| `lib/` | Computation (root only) | Shared simulation framework modules (managed by engine-builder) |
| `research/archive/` | Retired research memory | **Archived nodes.** Process-heavy, duplicated, superseded, or scaffold-like nodes removed from the active planning surface after their reusable residue has been extracted into active state.md, note.md, report_*.md, dead_ends.md, concepts/, or conventions.md. Archive is history, not normal context |

## Literature Surfaces

External knowledge has two durable surfaces because source truth and project use are different responsibilities.

### `literature/notes/{id}.md` — Source Record

Reader owns paper-level source records. A source record is a project-independent reference card for one paper. It records the paper's own statements, definitions, equations, conventions, assumptions, limitations, and paper-internal ambiguities with section/equation/theorem anchors where available.

A source record must not contain project relevance, proposed project use, project-side interpretation, bridges to project notation, or independent derivations of results already stated in the paper. Those belong in research nodes after a project-side role has decided they matter.

Normal research agents cite `literature/notes/{id}.md` rather than `.logs/*reading*`. Raw reading logs remain audit records and should be opened only for source-audit, archaeology, or when the durable source record is missing/ambiguous.

### `research/**/sources.md` — Node Source Map

`sources.md` is the node-local map between a research question and external source records. It is intentionally thin: it points to source records and states how the node intends to use them, without copying the source note body and without making project claims.

Use this shape when the node needs one:

```markdown
# Sources

## Source Questions
- {source-native fact, convention, theorem, or equation that this node needs checked or extracted}

## Source Records
### arXiv:{id} — {Title}
Source record: [literature note](relative/path/to/literature/notes/{id}.md)

Used in this node for:
- {source-side object or result this node may cite}

Not used in this node for:
- {project object, convention, or bridge this source does not establish}

Bridge status:
- absent | candidate | established in [conventions.md](conventions.md) / [note.md](note.md)
```

`sources.md` is managed by the project-side direction workflow, not by reader. Reader may be dispatched because a `sources.md` source question exists, but reader does not update `sources.md`; reader updates only `literature/notes/{id}.md`, `literature/catalog.jsonl`, `literature/reading_list.md`, and its raw `.logs/` deliverable. This separation prevents a source-reading agent from deciding how the project should use the source.

## Folder Names

Every node is a folder, and the folder name is the only thing a reader sees when browsing the tree. Use a semantic slug describing what the node is about on its own — **Title Case with spaces** is the house style (e.g., `Topic Name`, `Subtopic Name`).

The folder path must be stable under reorderings of the narrative. This rules out any slug that depends on where the node sits in the current story — positional prefixes, sequence indices, phase labels, and similar ordering markers all go stale the moment the story is rewritten. Narrative order lives in the parent's `story.md` or `plan.md`, not in the path.

A reader who sees only the folder name should be able to guess the node's content. If the name only makes sense given the current story, it is the wrong name.

`research/archive/` is the exception to active-node naming. Archived nodes are stored under `research/archive/{YYYY-MM-DD}/{relative-node-path}/` so the original path and archive date remain recoverable. Agents do not browse archive during ordinary context loading; open it only for explicit archaeology, contamination tracing, or when an active file intentionally links to archived process history.

## Computation Artifacts

Research nodes may contain computation subdirectories alongside their text files. This section is the canonical spec — agents that write here (simulator, researcher) follow these rules and cite this section rather than restating them.

### `src/` — Source code tied to a node

Any source code tied to a node lives in `src/`: simulator's measurement / analysis / plot scripts, and researcher's ad-hoc verification scripts for conjectures and examples. Both writers follow the same rules below.

**Node-root prohibition.** Never place source files (`.py`, `.jl`, …) directly in the node folder. Node roots are reserved for narrative files (`state.md`, `plan.md`, `sources.md`, `backlog.md`, `note.md`, `report_*.md`, `story.md`, `principles.md`, `conventions.md`) plus named artifact directories such as `checks/`, `src/`, `data/`, and `images/`. Loose scripts in node roots break the tree's legibility and bypass the `src/` reuse rule, so creating `src/` (even for a single script) is mandatory.

**Placement — lowest common ancestor.** Place a script at the lowest node that is an ancestor of every node that uses it. Common cases: a script used only in node `X` lives in `X/src/`; a script shared across siblings of a parent `P` lives in `P/src/`; if two cousins share a script, it lives in their nearest common ancestor's `src/`. This avoids duplication and makes scripts discoverable from the research context.

**Companion `{slug}.md` required.** Every script `{slug}.{ext}` carries a companion `{slug}.md` in the same `src/` directory — this is the script's permanent label in the tree, so a reader browsing `src/` knows what each file computes without opening the code or grepping `.logs/`. Minimum content: what the script computes, key parameters, and how to run it. For simulator's long-lived measurement scripts the companion expands into a full implementation description (see simulator agent). For researcher's one-off attempt scripts a short blurb (a paragraph or two) is enough while the work is provisional. Once a script supports a note.md / report_*.md claim, the reproducibility summary belongs in the node's `checks/` record or in the promoted report; `.logs/` remains the raw notebook, not the durable verification surface.

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
- Process history or "we changed this on date X" narrative — put the evidence trail in state.md if needed. The ledger states the current convention.

**Entry shape.** Free-form prose is allowed, but each entry must make these four facts recoverable:

```markdown
## {Convention name}
Scope: {project-wide | research/{subtree}/ | specific linked claims}
Convention: {the actual notation / order / sign / normalization rule}
Reason: {why this choice is used, or which external convention it matches}
Consequences: {symbols reserved, formulas affected, links to note.md / report_*.md / checks/*.md that rely on it}
```

The reason is load-bearing: without it, later agents treat the entry as arbitrary dogma and may "simplify" it away. Consequences are also load-bearing: they define the impact surface for a future convention change.

**Maintenance rule.** When curator promotes or rewrites a note.md/report claim that introduces, depends on, or changes a convention, curator must update the nearest applicable `conventions.md` in the same dispatch, then scan affected ancestor/sibling note.md files for inconsistent usage. If the convention is still provisional, state the scope honestly and do not let note.md use it as if project-wide. If two live conventions conflict, curator does not silently choose: keep the narrower convention scoped, add a compatibility note if possible, and flag the conflict to research planner when scientific judgment is needed.

## concepts/ — Reusable Reader Bridges

`concepts/` contains reusable explanations for terms that recur across nodes or would otherwise force repeated local definitions. A concept note is a reader bridge, not a project-fact authority and not a convention ledger. It should help a neighbouring-field researcher understand vocabulary; it must not smuggle in unaccepted project claims, workflow state, or provisional constructions.

**Creation bias.** When a reusable undefined term is discovered, prefer creating a small concept note immediately rather than waiting for a later tree crawl. The later crawl still exists as hygiene, but relying on it as the primary trigger lets jargon accumulate in note.md before anyone notices.

**Pollution control.** A concept note is dangerous when it becomes vague shared doctrine. Keep it narrow: define the term, state the scope, name standard variants if relevant, and point to durable non-dot notes/reports only when needed. Do not place project-specific sign conventions in concepts; use `conventions.md`. Do not place project claims or evidence summaries in concepts; use note.md, report_*.md, checks/, or state.md according to their identities.

**Reading rule.** note.md may link to concepts for reusable explanation, but note.md must remain understandable at the level of its principal claim, scope, derivation skeleton, and limitation without requiring the concept file to carry hidden project substance.

## Epistemic Boundaries — Prose-First Discipline

Research drift often begins before verification: prose quietly stops distinguishing what a source says, how this project interprets it, what this project constructs, what bridge relates two languages, and what is only an internal diagnostic. The framework preserves those boundaries in ordinary research prose, not in a separate claim database and not with visible management tags. The aim is to keep meaning stable while leaving the research tree readable.

**Principal claim unit.** A principal claim is any statement that later work could rely on: a mathematical result, a source reading, a convention, a compatibility bridge, a scope restriction, a negative result, a diagnostic-to-object distinction, or a stable interpretation. Expository restatements, local derivation steps, and reader-guidance sentences are not principal claims unless deleting them would change what future work is allowed to assume.

**Boundary types are meanings, not output labels.** Agents may reason about these distinctions internally, but ordinary claim prose should express them in natural language rather than emitting schema headings such as `Role:`, `Status:`, `Scope:`, or claim IDs. Good prose says "Masaoka Eq. (52) is being read on its own source convention" or "the projector is only a project-side diagnostic here"; it does not turn the research note into a registry. This restriction targets ordinary prose surfaces such as note.md, report_*.md, state.md, story.md, and user-facing summaries. Explicit ledger/metadata surfaces such as `conventions.md` and `checks/*.md` may use their required fields because their identity is to record scoped convention or verification metadata. Machine-readable state may exist in tooling later, but the LLM-facing and user-facing claim surface remains prose.

**Where the boundary is carried.**
- Reader extracts what is written in the source and does not translate it into project convention unless the paper itself gives the translation.
- Researcher states, in ordinary prose, which parts of an argument are source readings, project constructions, compatibility bridges, internal diagnostics, or unresolved discrepancies.
- Critic checks whether a claim changed category while being summarized or lifted: source statements gaining project interpretation, diagnostics becoming target objects, bridge claims missing the explicit map, or restricted results being phrased as unconditional.
- Curator adopts only the principal claims that survive review, writes them as prose in state.md / note.md / report_*.md, and records notation-changing bridges or conventions in `conventions.md`.
- Research planner specifies the intended work mode when dispatching tasks if a confusion is likely: source-native reading, project-side construction, bridge construction, diagnostic audit, or discrepancy resolution.

This is deliberately prose-first. The framework does not require line-by-line claim tagging, and it does not introduce hidden IDs into normal agent context. It requires enough explicit wording that the next agent does not have to infer whether two formulas are being identified, compared through a map, or merely placed side by side.

## Link Governance and `.logs/`

`.logs/` is the raw chronological audit archive: worker/session intermediate outputs, failed attempts, annotated critiques, and workflow traces. It is used for deep research archaeology, contamination-source tracing, prompt/process improvement, and reconstructing how a durable statement was produced when normal tree context is insufficient.

It is **not** part of normal research-tree reading and is **not** a durable citation target. Durable research prose must absorb the necessary content instead of linking to raw logs. This keeps the tree closed as a shared context surface and prevents raw intermediate wording from being reread as durable authority.

**Hard rule:** no durable Markdown surface described here links to `.logs/` or other dot surfaces. This includes manuscript prose, paper-draft prose, concept notes, root-level durable files, and node-local variants such as `draft/**/*.md`, `research/**/note.md`, `research/**/state.md`, `research/**/plan.md`, `research/**/backlog.md`, `research/**/report_*.md`, `research/**/checks/*.md`, `research/**/conventions.md`, `research/**/story.md`, `research/**/principles.md`, `research/**/dead_ends.md`, `research/**/asides.md`, and `concepts/**/*.md`.

Agents may read `.logs/` only when the workflow explicitly asks for audit, archaeology, contamination tracing, or when a maintenance agent is absorbing raw outputs into durable surfaces. After absorption, the durable file states the relevant content in its own prose.

## note.md — Draft Fact Layer

**What note.md is.** `note.md` is the node's draft fact surface: established claims, definitions, derivations or derivation skeletons, scope, limitations, and source/project boundaries written as reusable research prose. It is agent-maintained and can update faster than the manuscript, but it is not the human-authorized final authority. `manuscript/` is the paper-quality highest-authority layer.

**What note.md is not.** It is not current research state, not a chronological log, not a plan, not a backlog, not a report index, and not a stamp registry. A reader should not need `state.md`, `plan.md`, `backlog.md`, `.logs/`, or session memory to know what fact is being stated and why the node currently treats it as established or limited.

**Draft fact means derivation-bearing.** A reader who accepts a claim in note.md must be able to check *why* within note.md itself or through a durable non-dot link whose target is also self-contained for its role. Provenance references are Markdown links to node-local `checks/*.md` records whose front matter summarizes confidence, evidence channels, review channels, and scope; they are **not** a substitute for the derivation. A CONFIRMED claim accompanied only by a linked record gives the reader a stamp and nothing to check. The dividing line between note.md as a fact layer and note.md as an index is exactly this: derivations live in the note, not in `.logs/` or behind metadata.

**Scope of "derivation".** What counts satisfies one of:
- *Inline derivation* — a proof sketch, symbolic / numerical computation with its setup and conclusion, or worked-out argument. Full textbook detail is not required; what is required is that a reader in a neighbouring field can follow the logical chain from premises to conclusion without leaving note.md (modulo Markdown links to concept notes or sibling nodes that supply definitions, referenced lemmas, or derivations covered at another node).
- *Cited external result* — when the claim is a result from external literature used as a premise, cite the source (with section / theorem number where reasonable) in the note itself. The citation *is* the derivation pointer, and the linked provenance record will include `evidence: [literature]`. This route is acceptable for results the project *uses*; it is **not** acceptable for project-central claims (those this project is staking as its own contribution) — project-central claims must carry an inline derivation.

**All confidence levels carry derivation, not only CONFIRMED.** STRONG CONJECTURE, CONJECTURE, and OPEN claims that appear in note.md carry the partial argument, special-case verification, or motivating evidence that *is* available — with explicit scope — rather than being stated as bare tagged sentences. An OPEN claim appears in note.md only when its formulation is itself established knowledge (i.e., the node knows *what* the question is and *why* it is the right question); the answer being unknown is stated, but the framing is substance.

**Audience — the context-free fact reader.** note.md is written for a reader who knows nothing about the research process: no memory of attempts, critic verdicts, revision rounds, session history, `state.md`, `plan.md`, `backlog.md`, or `.logs/`; no prior exposure to this project's internal vocabulary. The reader is presumed to be a working researcher in a neighbouring field, so standard terminology of that field can be used — but project-specific labels, internal diagnostics, and local jargon need a local bridge before use. A concept link is allowed as a reusable explainer, but note.md must still make the claim, scope, derivation skeleton, and limitations understandable without making the concept file the hidden authority.

This audience, combined with the derivation-bearing requirement, is the file's strongest constraint. The prose must read cleanly **in isolation** — not merely "in principle understandable given enough context."

**Fact-layer test (run after any substantive edit).** Ask: *can a future agent safely use this node's established facts without reading process state or raw logs?* If the only way to reconstruct the derivation, scope, or limitation of a claim is by reading `state.md` or `.logs/`, the note is still an index, not a fact surface. The correct response is to either (i) lift the derivation or derivation skeleton into note.md, (ii) replace the bare claim with an honest lower-confidence formulation together with the partial argument that is available, or (iii) remove the claim from note.md pending more work.

**No template.** The content and structure emerge from the research itself. A node studying a mathematical structure will naturally differ from one resolving a paradox or surveying a field. Prescribed sections constrain the researcher's thinking — the prose should take whatever form best captures the established knowledge together with its derivation.

**Content rules (enforced on every curator dispatch):**

1. *No frontmatter* — fact files are clean prose.
2. *Derivation or citation for every principal claim* — per "Scope of derivation" above. A claim stated with a provenance reference but without an inline derivation or a cited source is incomplete and must be completed or demoted before the dispatch closes.
3. *Provenance link alongside every principal claim* — per the Verification Provenance Records section below. The link points to the `checks/*.md` record that summarises the verification chain in front matter and explains it in prose; it does not replace the derivation required by rule 2 and never points to `.logs/`.
4. *No chronology, no process-status phrasing.* The rule excludes **session history** from note.md, not **substance**. A proof, a symbolic computation with its setup and conclusion, or a worked-out argument is the content of a claim; rule 2 requires it to be there. What rule 4 rules out is the state of the investigation — dated status blocks (`Status update YYYY-MM-DD`, `Progress 2026-…`), Current-State / Evidence sections copied from state.md, cycle references (`r2`, `r3 stage`, `latest cycle`), review-state markers (`critic pending`, `REVISE minor`, `awaiting resubmission`), and workflow words (`resubmission`, `previous attempt`). These decay on the next cycle; the confidence information they try to convey is exactly what the linked provenance record encodes. Write the derivation in timeless prose and let the link carry the reader to verification metadata. Conflating substance with session history — treating a derivation as a "process artifact" and stripping it — produces the failure mode this whole section is written to prevent.
5. *No undefined project-internal labels* — ad-hoc identifiers that index items in a working list but have no stable definition elsewhere (e.g., open-question IDs, informal candidate/hypothesis tags, attempt slugs, cycle references) may appear only if they are either (a) introduced with a one-sentence explanation where first used, or (b) replaced by a self-contained description. Preferably just describe the thing in plain prose. A reader should never have to grep the repo to learn what an internal label means.
6. *Every non-common technical term is gated* — for each term that a reader in a neighbouring field would not immediately recognise, use one of two gates:
   - *Markdown link*: `[display text](relative/path.md)` or `[display text](<relative/path with spaces.md>)` pointing to a concept note in `concepts/` or a sibling/ancestor node's note.md. Link targets are relative to the file containing the link. Follow the link to verify it resolves.
   - *Inline definition*: one sentence introducing the term before it is used.
   
   When in doubt, define locally first. Create a concept note in `concepts/` when the term is reusable across nodes or its explanation would otherwise be repeated; concept notes are reader bridges, not authority for project facts.
7. *Every load-bearing convention is either stated or linked* — if a claim depends on a nonstandard notation, sign, order, normalization, or symbol reservation, note.md must either state the convention before use or link to the applicable `conventions.md` entry. Do not rely on a convention being "known from earlier attempts" or buried in state.md. This rule is the convention analogue of rule 6: technical terms need definitions; symbolic choices need convention anchors.

*How rules 5 and 6 divide the work*: rule 5 targets *labels* (no stable definition exists to link to, so the cleanest fix is to describe the thing in prose); rule 6 targets *technical vocabulary* (a stable definition exists or should exist, so the cleanest fix is to link to a concept note).

**Root note.md** captures the project's overall draft fact layer — the core claims, their derivations (or citations), scope, limitations, and how they connect. It may be newer or rougher than `manuscript/`, but when the two conflict `manuscript/` wins.

**Child note.md** captures what that specific investigation established, with derivations.

**When to create**: when a node has derivation-bearing or partially derivation-bearing facts worth reusing as facts. Leaf nodes doing pure computation may remain state/report/check-only until a reusable fact emerges.

**Authorship and authority.** Authorship, write authority, promotion authority, verification authority, and graph authority are separate axes. `note.md` authorship may be carried by a dedicated synthesis role or by a curator-like maintenance role in a given runtime, but it is never ordinary worker-local authorship and never graph authority. The author of a note edit must act as a second reader: lift only reviewed or honestly scoped material, preserve source/project boundaries, and make the prose self-contained.

Research planner never writes note.md directly; its directives live in `research/focus.md § Tree Directives`. Workers may propose facts or structural pressure in their deliverables, but they do not promote claims into note.md by themselves. Curator or the runtime's fact-maintenance role closes the transaction: decides placement, ensures checks exist, applies audits, and flags scientific ambiguity upward.

Two narrow exceptions to the normal fact-maintenance path:

1. **Trivial mechanical fixes.** Typo corrections, fixing a broken Markdown link, renaming a term after a concept note is renamed. The rule of thumb: if the replacement is uniquely determined — any competent reader would produce the same correction, with no judgment about phrasing or structure — the edit is mechanical. If there is any judgment about wording, ordering, or what claim to state, it is not mechanical and must go through curator
2. **User-present collaborative rewrites (`/meeting`, `/launch`).** When the user is actively collaborating — during a meeting discussion, or during the initial project launch — the main agent and user may rewrite note.md together to reflect synthesis produced in the conversation. The user acts as the second reader in real time.

Anything beyond these two categories — adding a section, rewording a claim, updating a provenance link, restructuring prose, inserting a "status update" block — goes through the fact-maintenance transaction. The critic Target B exception is only for separate `checks/` review files, never for note.md prose. A note.md edit written by another channel is legitimate input to the tree, but the next maintenance pass should rewrite it if needed to restore fact-layer quality.

This rule has a failure mode to watch for: note.md drifting into a log-like chronicle with time-stamped "Status update YYYY-MM-DD" sections stacked on top of each other. That shape is the footprint of non-curator appending and signals that curator dispatches have been skipped; the next curator run should consolidate such stacks into a single, present-tense statement of the node's established knowledge.

### Critic layering on note.md

The derivations written into note.md are reusable draft facts. They must pass independent scrutiny **as they appear in note.md**, not merely inherit the scrutiny of an upstream raw attempt. Fact-layer synthesis can introduce new failure modes that the attempt-level critic never saw — simplifications that glossed a gap, notational drift, a step that was obvious to the researcher being compressed past legibility, a composed argument spanning several attempts whose joint soundness was never checked.

The maintenance chain is therefore:

1. Researcher produces a raw attempt in `.logs/` with working-note derivation
2. Critic reviews the attempt (blind or contextual) — the first-layer review
3. The fact-maintenance role lifts the derivation into note.md as reusable fact prose, consolidating across attempts as needed
4. **The maintenance role dispatches critic on the note.md derivation itself** as a separate pass, targeting the derivations touched in this dispatch. Mode is contextual by default (the critic needs the surrounding note.md + ancestor chain to judge whether the lifted derivation suffices for its role in the fact layer); blind mode may be chosen when the derivation is purely mechanical
5. The maintenance role applies the critic's findings (fixing the note.md prose, not annotating it in place — note.md is clean fact prose, so critic writes findings to a separate file under `checks/`)
6. Over repeated maintenance cycles, this layers multiple critic passes over the same note.md section. That accretion is the mechanism by which note.md earns its property of surviving many critic eyes

Each such review is composed into the affected claims' linked provenance records (adding the appropriate review channel to the record's front matter and preserving the critic file in `checks/`). A claim whose **note.md-level** derivation has been critic-reviewed links to a record that reflects *this* review layer, distinct from whatever review the upstream attempt already had.

This layering is not optional decoration — when a note.md carries substantive new derivations (not just prose polish on an already-reviewed derivation), a note.md-level critic pass is part of closing the dispatch. Skipping it reproduces the failure mode the derivation-bearing fact-layer design is meant to prevent.

### `checks/` — Node-local verification record

`checks/` is the node's durable verification ledger. It exists because `.logs/` is a raw chronological audit archive: useful for reconstructing what happened during an explicit audit, but not a normal citation surface. When a verification result is important enough to justify a provenance reference on note.md or report_*.md, the inspectable review artifact lives with the node.

Typical contents:
- `critic_note_{slug}_{YYMMDD_HHMM}.md` — critic Target B reviews of note.md sections, written as separate files so note.md stays clean fact prose
- `check_{slug}.md` — curator-written reproducibility summaries for scripts / computations that support a promoted claim, with links to the relevant `src/`, `data/`, or `images/` artifacts and the exact claim checked

What belongs here is verification substance, not process chronology. A `checks/` file states the target claim, the method, the result, scope restrictions, and provenance contribution in its own prose. It must not link to `.logs/`, and it must not require the reader to open raw notebooks to know what was checked. Conversely, `checks/` is not a loophole around note.md self-containment: note.md still carries the derivation or cited external result. `checks/` records how that derivation was reviewed or reproduced.

**When to create**: when a note.md-level critic pass runs, when a mechanical / numerical check supports a promoted claim, or when a report_*.md needs a stable review record.

**Naming**: descriptive, lowercase-ish slugs with the check type first, e.g. `critic_note_surface_dispersion_260430_1430.md`, `check_sign_convention.md`. Timestamp Target B critic files so repeated review layers do not overwrite each other.

## Verification Provenance Records

Claims in note.md carry a **Markdown link** to a node-local `checks/*.md` record so readers can assess **how** each fact was established, **whether it has been independently reviewed**, and **at what scope**. Claims in report_{slug}.md carry such links once the report is designated as a verified durable artifact or once a report claim is used as support for note.md. A newly worker-authored report may be clean but still unverified; curator/critic close the provenance-link transaction before the report is treated as verified support. The metadata lives in YAML front matter at the top of the linked check file; the note.md/report prose remains ordinary Markdown rather than acquiring a project-specific inline tag syntax.

**Why links plus front matter.** Verification metadata is structured data about a claim, not part of the mathematical sentence itself. YAML front matter is a widely used Markdown convention for document metadata; keeping the axes there makes them machine-readable and keeps note.md clean fact prose. The inline surface should therefore be a normal link such as `[verification](checks/check_projector_identity.md)`, while the target file carries the confidence/evidence/review/scope fields.

**Records accompany, not replace, the derivation.** Every claim linking to a provenance record in note.md must also carry the derivation that supports it (inline or cited — see § note.md — Draft Fact Layer, "Scope of derivation"). The record summarises the verification chain so a reader can decide how much trust to invest; the derivation is what the reader actually checks. A linked claim without an accompanying derivation is the failure mode the whole § note.md — Draft Fact Layer is written to prevent, and no refinement of the record schema repairs it.

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

The body of the check file then explains the same metadata in prose: target claim, method, result, scope restrictions, and the critic or curator judgment. Front matter is the index; the body is the inspectable record.

**Terminal provenance endpoint.** A `checks/*.md` file is the project-internal endpoint of a provenance link, not a routing page to more project documents. When `note.md` or `report_*.md` links to a check record, a reader must be able to evaluate the verification judgment from that record itself. The record may mention project artifacts it absorbed, but it must not make the reader open `state.md`, `report_*.md`, another `checks/*.md`, or `.logs/` to discover the actual evidence, procedure, result, scope, or limitation. If a project-internal artifact matters, absorb the relevant claim, calculation, procedure, result, and limitation into the check body in compact prose.

External literature is different because the paper is a first-order source. Literature references are allowed and often required, but a bare paper link or arXiv ID is not enough: the check body must name the section/equation/theorem/page or similarly precise source location and state the specific source claim being used, with a short quotation when wording matters or an accurate summary when it does not. Long quotation is not the goal; the goal is that the reader knows exactly what passage supports what part of the check.

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
- If provenance is unclear from the available documents, use the lower confidence value and flag back to research planner rather than guessing

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

## report_{slug}.md — Clean Analysis Artifacts

Self-contained analyses authored by a worker or rewritten from a worker deliverable into clean form. A report is a closed artifact: it preserves one analysis at the node whose scope it serves. It is not the node's fact layer, not a living workspace, and not graph authority.

**Relationship to other files:**
- Worker deliverables in `.logs/` are raw audit records. Reports are clean durable analyses produced from or alongside those records
- `note.md` is the node's integrated draft fact layer. Reports are individual analyses that note.md may draw from after verification
- `checks/` stores the stable verification record for reviews and reproducibility checks supporting note.md / report_*.md claims
- Not every deliverable becomes a report. Not every node has reports

**When to create**: when a worker deliverable or assigned report-writing task contains a significant result worth preserving as a clean analysis artifact. A worker may author the report when explicitly assigned, but this is authorship only: the worker does not decide graph placement, fact-layer promotion, status, or whether the report should become a node.

**Naming**: `report_{slug}.md` where `{slug}` is a descriptive identifier (e.g., `report_surface_dispersion.md`, `report_magnetic_c4t.md`).

**Report vs subnode.** `report_{slug}.md` is a closed artifact. `research/{Topic}/` is a living scope: future attempts, state.md, plan.md, checks, conventions, and multiple reports may accumulate there. Avoid `X/report.md` because it makes the node and artifact identities collapse into each other. If a report starts to require follow-up attempts, multiple checks, competing variants, or its own strategy, the graph authority creates or proposes a subnode and places future work there; the original report remains a report.

## plan.md — Decomposition and Planner-Supplied Strategy

A node's active decomposition document: child roles, structural dependencies, and planner-supplied approach choices or success criteria. Curator-maintained means graph consistency, not scientific authorship: research planner may direct strategy changes via `research/focus.md § Tree Directives`; curator rewrites plan.md when node creation, closure, archive, or reparenting makes the recorded decomposition false. Curator does not infer what to try next, which method to prioritize, or success criteria from structure. Rewritten (not appended) when the active decomposition changes.

```markdown
{Free-form decomposition / strategy notes. No prescribed sections.
Typical content: decomposition rationale, why children exist and their roles,
structural dependencies, planner-supplied approach decisions, planner-supplied success criteria, and active structural constraints.}
```

**No template.** The content depends on the node's nature. A branch node might describe why its children exist and how they contribute; a leaf might outline an approach only when that approach is useful durable context rather than a transient task instruction.

**Relationship to state.md**: plan.md records active decomposition and planner-supplied strategy only; state.md captures current understanding and accumulated evidence. When the graph or planner strategy changes, rewrite plan.md; when results come in, update state.md.

**When to create**: When a node has non-trivial decomposition or planner-supplied strategic decisions. Simple leaf nodes doing straightforward work may not need one.

## state.md — Research State

The node's graph-structured research state: current board plus absorbed evidence ledger. It is durable enough for later agents to reconstruct where the node stands, but it is not the fact layer and not a raw chronological log. Every node starts with state.md. plan.md is added when strategic decisions need recording. note.md appears when reusable facts emerge.

```markdown
---
kind: {kind}
status: {status}
---
# {description}

## Current Board
{What is known, what is unknown, active hypotheses, disputed points, blockers, and current status.}

## Evidence
- {entry}: {what was attempted or checked, what was absorbed, what confidence/scope changed, and whether critic accepted/revised/rejected it}
{append-only — never delete evidence entries}
```

Root state.md additionally carries `last_meeting` in frontmatter and a `## Background` section for key references and prior work.

Evidence entries summarize raw outputs; they do not link to `.logs/`. Raw paths may appear in dispatcher prompts and audit tooling, but authored state.md prose is a graph-structured absorption of what matters, not a citation index into the audit archive.

## Example Tree

```
research/
  note.md              (project-level draft facts)
  plan.md              (root-level strategy and decomposition)
  state.md               (background, working state — ladder)
  focus.md            (session cursor: "work here now")
  story.md             (paper narrative structure)
  principles.md        (cross-cutting research constraints)
  conventions.md       (project-wide notation and convention ledger)
  dead_ends.md         (rejected-direction register — outside fact layer)
  asides.md            (parked off-thread items — outside fact layer)
  lib/                 (shared simulation framework — engine-builder manages)
    ClockModel.jl
    XYModel.jl
    test/
  Paradox Resolution/
    note.md            (derivation-bearing: the paradox stated, and the derivation resolving it)
    plan.md            (approach strategy)
    state.md             (research process: current state, evidence)
    report_symmetry_analysis.md  (curator-promoted verified report on symmetry constraints)
    checks/
      critic_note_symmetry_analysis_260430_1430.md
  Lattice BKT/
    note.md            (derivation-bearing knowledge of this direction)
    plan.md            (children decomposition and strategy)
    state.md             (working state, evidence trail)
    src/               (scripts relevant to this branch)
      winding_decay.jl           (simulator's long-lived measurement script)
      winding_decay.md           (companion: algorithm + params + how to run)
      archive/                   (superseded scripts kept for history)
    Coulomb Escape/
      state.md           (leaf: may only have state.md, no note.md yet)
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
| **Manuscript** | `manuscript/` | Read-only except human-authorized writing workflows | Highest-authority, fully self-contained, human-authorized paper prose; `manuscript/authorizations/*.md` stores meeting approval snapshots that authorize promotion from note.md |
| **Paper draft workspace** | `draft/` | Write only through `/write` draft workflows | Paper outline, draft conventions, section drafts, and integrated draft versions. Not human-authorized authority; does not override manuscript or note.md |
| **Research tree — facts** | `research/**/note.md` | Read-only except fact-maintenance transactions and human-present rewrites | Draft fact layer — established claims + derivation/derivation skeleton + scope + limitations + Markdown provenance link |
| **Research tree — reports** | `research/**/report_*.md` | Write only when explicitly assigned report authorship | Self-contained clean analyses; worker-authored or worker-originated; closed artifacts, not living nodes |
| **Research tree — checks** | `research/**/checks/*.md` | Read-only, except curator and critic Target B | Node-local verification records with YAML front matter: note.md critic reviews, reproducibility summaries, and check results supporting provenance links |
| **Research tree — plan** | `research/**/plan.md` | Read-only | Decomposition and planner-supplied strategy: children roles, approach decisions, success criteria |
| **Research tree — state** | `research/**/state.md` | Read-only | Graph-structured current board and absorbed evidence ledger; kind/status frontmatter |
| **Research tree — backlog** | `research/**/backlog.md` | Read-only | Optional parked executable reminders; no claims, evidence, or durable strategy |
| **Convention ledger** | `research/**/conventions.md` | Read-only | Current notation, sign, ordering, normalization, and symbol-reservation choices, scoped to the node/subtree |
| **Concept explainers** | `concepts/` | Read-only, except concept-maintenance transactions | Reusable reader bridges. Not authority for project facts, claims, or conventions |
| **Computation — framework** | `research/lib/` | Read-only (engine-builder writes) | Shared simulation modules |
| **Computation — source** | `research/**/src/` | Write (simulator, researcher; curator archive moves only) | Source code tied to a node: measurement / analysis / plot / verification scripts, each with a companion `{slug}.md` |
| **Computation — data** | `research/**/data/` | Write (simulator) | Simulation data (TSV with metadata headers) |
| **Computation — figures** | `research/**/images/` | Write (simulator) | Visualizations |
| **Retired research memory** | `research/archive/**` | Read only during explicit archaeology; curator writes archive moves | Retired nodes removed from active planning context after reusable value was extracted |
| **Raw audit archive** | `.logs/*_{type}_*.md` | Write (own deliverables only) | Worker/session intermediate outputs for audit, archaeology, contamination tracing, and workflow improvement. Not linked from durable research prose |
| **Session cursor** | `research/focus.md` | Not relevant to workers | Research planner's current focus position in the tree |
| **Session context** | `.logs/last_session.md` | Not relevant to workers | Volatile work context for session handoff, written by session-wrap-up |

**Tree navigation**: `ls research/{path}/` to see active children (subfolders). Ignore `research/archive/` during ordinary context loading. Read `note.md` for draft facts, `sources.md` for node-local source maps, `report_*.md` for clean analyses, `checks/` for node-local verification records, `state.md` for current board and absorbed evidence, `plan.md` for strategy and decomposition, `story.md` for narrative structure, `principles.md` for constraints, and `conventions.md` for notation / convention choices. Read `backlog.md` only when looking for parked executable reminders; do not treat it as a source for claims, evidence, strategy, or state.

Each node has a `kind` and `status` in its **state.md** frontmatter (not note.md). Node status is set by curator, based on research planner's Tree Directives and evidence accumulated in state.md (see `.codex/agents/curator.md` and `.codex/agents/research-planner.md`).

- Writes to the research tree are split by authority, not just by file path: **research planner** writes only `research/focus.md` (cursor + directives + worker dispatch plan); **curator / graph authority** owns node folders, placement, status, lifecycle, reparenting, node archival, report-to-subnode promotion, state.md absorption, and plan.md graph consistency; **fact-maintenance authority** owns note.md synthesis and provenance-link closure; **critic** may write only Target B review files under `research/**/checks/`; simulator writes under `data/`, `images/`, and `src/`; engine-builder writes under `lib/`; workers may write `report_*.md` only when explicitly assigned clean-report authorship in an existing node. If research planner or a worker notices a tactical item worth preserving in `backlog.md`, they propose it; the maintenance path decides whether it belongs there.
- To propose a status change, describe the rationale in your deliverable file
- Honest reporting is paramount: never propose stable for something that has not been sufficiently verified
