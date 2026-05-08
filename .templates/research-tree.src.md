# Research Tree

Research information is organized into typed surfaces. The active `research/` tree is working research memory; `research/archive/` preserves retired nodes; `manuscript/` is reserved for future human-authorized paper surfaces and is frozen in the current research workflow. Every file has an identity, authority level, and link boundary. These distinctions are not cosmetic: later agents reconstruct context from these files, so mixing fact, state, strategy, backlog, provisional review transactions, raw audit records, semantically placed materials, and process-heavy retired nodes lets local mistakes propagate as durable assumptions.

**Language.** Body prose in every durable file described here (manuscript prose, findings.md, state.md Current Board / Evidence entries, map.md, plan.md, backlog.md, story.md, _materials/analyses/*.md, checks/*.md, principles.md, conventions.md, focus.md, dead_ends.md, …) is written in **{{ language }}**. Provisional review transaction prose under `_reviews/` is also written in **{{ language }}** unless it quotes source/code. Exceptions: the structural `##` headings shown in English in this document (e.g., `## Current Board`, `## Evidence`, `## Background`), frontmatter keys, schema keys, folder slugs, technical terms, proper nouns, and LaTeX mathematics may stay in their original form. Field labels shown in examples such as `Scope:`, `Principle:`, or `Reason:` name semantic fields, not fixed English literals; localize them in authored prose unless a frontmatter/schema contract explicitly fixes the key. The English examples below illustrate structure, not language.

## Authority Layers

`manuscript/` is reserved for the future highest authority layer: human-authorized, fully self-contained, paper-quality prose. In the current workflow it is frozen: `/auto`, `/steer`, `/meeting`, and the current `/write` flow do not create, update, or promote into `manuscript/`. If existing manuscript prose conflicts with `research/**/findings.md`, agents follow `manuscript/` and flag the conflict rather than silently reconciling it. Future write-skill work may define the promotion protocol, but this research-tree contract does not use manuscript authorization as a substitute for research-memory quality.

`draft/` is different: it is the `/write` paper-draft workspace (`draft/outline.md`, `draft/conventions.md`, `draft/sections/*.md`, `draft/versions/*.md`). It is not human-authorized authority and does not override `manuscript/` or `research/**/findings.md`.

`research/**/findings.md` is the draft fact layer: agent-maintained, derivation-bearing, and self-contained for established facts at that node. It may be newer than frozen manuscript material and is the main surface for reusable research facts, not for current workflow state or human oversight.

`research/**/map.md` is the parent-level context-routing map for a node's direct children. It tells future research planners and workers how to read the child set without opening every child in full: each child's parent role, lifecycle status, parent implication, whether it is live, and the condition under which it should be reopened. It is not a fact layer, not a plan, and not a paper narrative.

`research/**/guide.md` is the human oversight entrypoint for a node or subtree. It helps the human researcher manage direction, verification doubts, and understanding without turning the meeting into line-by-line fact-layer QA. It is not an authority layer and must point to `findings.md`, `checks/`, `_materials/analyses/*.md`, `map.md`, `story.md`, or `state.md` for the surfaces that carry substance.

`research/**/_materials/` is a visible non-authority material layer inside the node. It is durable because code, data, figures, shared modules, and clean analyses must be reusable by semantic location rather than lost in chronological logs. It is not claim authority. A claim becomes reusable research memory only when the fact-maintenance transaction admits it into `findings.md` with appropriate provenance, or records its state honestly in `state.md`. In the current agent set, curator carries that fact-maintenance transaction responsibility as part of research-memory maintenance; this is a context-management role, not a claim that curator independently re-derives specialist truth.

`research/**/_reviews/` is a visible provisional review-transaction layer inside a node. It is where review-eligible worker submissions and critic judgments meet before curator decides what enters interpreted memory or durable materials. It is not raw process history, not claim authority, not durable support, and not normal reading context. Its identity is transaction state: "what was submitted for review, what critic judged, whether one repair was attempted, and what curator may now absorb or block." Source-reading review transactions that are not node-scoped live under `literature/_reviews/{id}/` with the same identity.

`literature/notes/{id}.md` is a paper-level source record: reader-authored, source-facing, and project-independent. It records what an external paper states in its own notation and convention. It is not a project fact layer and not a bridge surface. Research nodes cite it when they use external results, but the source record itself does not decide how the project should use the paper.

Authority order for project-side claim-bearing interpreted-memory surfaces:

```text
manuscript/
  > research/**/findings.md
  > research/**/state.md
  > literature/notes/{id}.md
```

This is an authority order for project-side interpretation, not source-native truth and not a link chain. `_materials/` is intentionally absent: its contents may be durable and semantically placed, but they are materials, not interpreted research memory. `_reviews/` is also absent: it is a provisional transaction layer, not reusable memory. Analyses under `_materials/analyses/` may contain claims as authored materials; later agents may inspect them as support material, but may not treat them as adopted node facts until `findings.md`, `state.md`, or a `checks/` record says what was admitted, rejected, limited, or still unverified. For source-native claims about what an external paper states, `literature/notes/{id}.md` is the project source record and takes priority over project-side state/finding summaries; the paper itself remains the ultimate source. `research/**/checks/*.md` is not a standalone claim-authority layer in this ladder; it is the verification/provenance authority attached to linked claims in findings.md or analysis materials. A check record can force demotion, revision, or retraction of a claim, but it does not become an independent fact surface. `.logs/` is outside the ladder: it is a raw audit fallback used only when a workflow explicitly enters audit / archaeology / contamination-tracing mode.

| File | Layer | Role |
|---|---|---|
| `findings.md` | Fact layer | **Established node facts.** Agent-maintained prose for claims, definitions, derivations or derivation skeletons, scope, limitations, and source/project boundaries. Not final human authority, not current research state, not a draft index. No frontmatter. Does not link to `.logs/` or hidden workflow/config surfaces as research evidence |
| `guide.md` | Human oversight entrypoint | **Node-local guide for human research management.** Explains what the node is for, why it matters, what to read first, what is trusted or suspicious, and which verification/direction questions deserve human attention. Not fact authority, not a replacement for findings.md/checks/_materials/analyses, not meeting minutes |
| `_reviews/{slug}/` | Provisional review transaction | **Bounded worker-critic transaction.** Contains `worker.md`, `critic.md`, optional `repair.md`, and optional `critic_rereview.md`. Not raw log, not durable support, not normal context |
| `_materials/analyses/{slug}.md` | Material | **Clean analysis material.** A closed, self-contained analysis placed in the node whose scope it serves. Not claim authority, not the integrated fact layer, and not a living workspace. Fact-maintenance may later distill admitted claims into findings.md or use the analysis as inspectable support |
| `checks/` | Durable verification surface | **Node-local verification records.** Critic verdicts, reproduction records, analysis reviews, and findings reviews. A check file states target, method, result, scope, and limitations in its own prose. It does not link to `.logs/`, is not a substitute for the derivation in findings.md/analysis prose, and is not a standalone fact surface |
| `state.md` | Research state layer | **Graph-structured current board and absorbed evidence ledger.** Has frontmatter (`kind`, `status`). Records what is known, unknown, active, blocked, or disputed at this node, plus compact evidence entries. It is not the fact layer. It absorbs `.logs/` content but does not link to `.logs/` |
| `map.md` | Context-routing map (optional) | **Parent-level map of direct children.** Records how to read each child from the parent: role, lifecycle/status, parent implication, live work, reopen/read condition, and cross-child relation when needed. Not fact authority, not strategy, not an append-only history, not human-facing guide prose |
| `plan.md` | Decomposition / strategy layer | **Recorded node decomposition and planner-supplied strategy.** Children roles, decomposition rationale, approach choices, and success criteria when they are needed to understand the active graph. Not current evidence, not tactical reminders, not an append-only history |
| `sources.md` | Source map (optional) | **Node-local map of external sources.** States which `literature/notes/{id}.md` records matter to this node, what source-side questions remain, what each source is used for, what it is explicitly not used for, and whether any bridge is absent, candidate, or established elsewhere. It is not a source record, not a fact layer, and not a convention ledger |
| `backlog.md` | Backlog layer (optional) | **Parked executable reminders.** Pending work that should survive beyond `research/focus.md` but is not immediate dispatch, not strategy rationale, not evidence, and not fact. Prune stale items during session-end maintenance |
| `story.md` | — | Narrative structure of children (optional). At root: the paper's overall narrative structure |
| `principles.md` | Research principles | **Current reusable research judgment principles (optional).** Principles that repeatedly constrain how agents compare routes, promote claims, separate roles, or decide what would count as evidence across this subtree. At root: project-wide research principles. See § principles.md — Research Principles |
| `conventions.md` | Convention ledger | **Notation and convention source of truth (optional, root by default; subtree-local when needed).** Records choices that change how formulas are read — sign conventions, orderings, normalizations, index names, Fourier transforms, tensor leg orientation, symbol reservations, and terminology-to-symbol mappings. See § conventions.md — Notation and Convention Ledger |
| `dead_ends.md` | Outside fact layer | **Rejected-direction register (optional).** Approaches shown wrong, with the reason and the evidence (counterexample, falsifying computation, or critic-rejected derivation). Free-form prose. Pairs with `asides.md` — together they form the two outside-fact-layer registers (rejected vs parked). At root by default; a node may carry its own when the rejection is clearly subtree-local |
| `asides.md` | Outside fact layer | **Parked off-thread items (optional).** Items not committed to the active thread but worth not forgetting — spare-capacity questions, side curiosities, loose details left unpinned, items of unclear project scope. Free-form prose, no derivation requirement. At root by default; a node may carry its own when the items are clearly subtree-local. Three exits: promoted into a node's findings.md (becomes load-bearing), moved to `dead_ends.md` (shown wrong), or stays parked indefinitely. Capture path: workers surface candidate items in their submissions; curator absorbs them. The user may also append directly during `/meeting`; the file is intentionally informal and carries no fact authority |
| `_materials/src/` | Material | Source code tied to a node (measurement, analysis, plot, or verification scripts), each with a companion `{slug}.md`; not claim authority |
| `_materials/data/` | Material | Simulation data (TSV format with metadata headers); not claim authority |
| `_materials/images/` | Material | Figures and visualizations; not claim authority |
| `_materials/lib/` | Material (root only) | Shared simulation framework modules (managed by engine-builder); not claim authority |
| `research/archive/` | Retired research memory | **Archived nodes.** Process-heavy, duplicated, superseded, or scaffold-like nodes removed from the active planning surface after their reusable residue has been extracted into active state.md, findings.md, _materials/analyses/*.md, dead_ends.md, concepts/, or conventions.md. Archive is history, not normal context |

## Research-Memory Shape — Node Identity and Context Routing

The active tree's folder shape is part of the research-memory contract, not a cosmetic filing scheme. The identity of `research/` is compressed working memory for future research judgment. Therefore node boundaries, parent-child relations, status, and archival placement are decided by how future agents should read the work: what belongs in the same judgment context, what needs a separate evidence stream, what has become reusable memory, and what should be removed from normal context after residue extraction.

Research-memory shape decisions are rooted in file and node identity:

- A **node** is a research object, question, construction, result, bridge, warning, gap, or component of a parent story. It is not a container for whatever happened while working nearby.
- A **parent-child relation** says what the child supplies to the parent: evidence, a reusable component, a caution, a bridge, a still-live question, or a decomposed sub-problem. If that role is no longer true, the tree shape is stale even when every file is locally well written.
- A **status** says how normal context loading should treat the node. `active` invites future work, `stable` allows reuse with remaining limitations, `closed` records that the line is no longer pursued, and archive removes process-heavy history from ordinary reading after its reusable residue has been extracted.
- A **surface location** routes meaning. `findings.md` reads as adopted draft fact, `state.md` as working memory and evidence ledger, `map.md` as parent-child context-routing map, `plan.md` as decomposition/strategy, `_materials/` as inspectable non-authority material, `dead_ends.md` as rejected lesson, `guide.md` as human oversight route, and `archive/` as retired history.

Good research-memory shape is tested by future reading, not by neatness. A future research planner, worker, critic, or human should be able to read the normal surfaces for a node and know why the node exists, what it supplies to its parent, what evidence stream supports it, what remains live, and whether opening its children or retired history is necessary. If a parent Current Board must track independent frontiers, if repeated evidence entries describe a sub-problem with its own success criterion, if a child has become process history after its result was extracted, or if a node's name/background no longer matches its role, the problem is research-memory shape before it is prose quality.

The usual operations follow from this identity:

- **Split** when an already-present evidence stream or live question needs its own reading context.
- **Reframe** when a node's current role differs from its name/background but the work remains live.
- **Reparent** when the node's natural parent has changed and future readers would otherwise load it in the wrong context.
- **Close** when the line is no longer pursued, after recording any reusable lesson or remaining limitation.
- **Archive** when the active value has been extracted and the remaining node mainly makes future agents reconstruct process history.
- **No-op** when the node still carries a coherent single identity for its parent and its active surfaces route that identity correctly.

These operations should be auditable. A research-memory shape change must leave enough rationale in state.md, map.md, plan.md, or the relevant parent surface that the next agent can see which node identity, parent contract, evidence stream, or context route changed. guide.md may later summarize the change for human oversight, but it is not where the tree transaction is recorded. This is the replacement for pre-approval: the tree manager acts autonomously inside the active-memory contract, records the reason, and leaves any future research-priority implication for the normal direction loop to read.

## map.md — Parent-Level Research Map

`map.md` exists so a parent node can be read without forcing every future research planner to full-read every direct child. It is a context-routing surface: a compact map from the parent to its child nodes. Its job is to answer "which children matter for this parent right now, what does each child supply, and when should I open it?" before any agent spends context on child internals.

Create or update `map.md` when a parent has multiple direct children whose roles are not obvious from folder names, when a child is closed / parked / stable / reframed / reparented / archived, when a child-to-parent presentation boundary lands, when a parent Current Board would otherwise become a long child roster, or when session-end maintenance sees active / stable / parked roles mixing unclearly. Do not create `map.md` merely because a node exists; if a parent has a single obvious child or `state.md` already gives a clear context route, no map is needed.

`map.md` is not a fact authority and must not replace child facts. Factual claims and derivations live in `findings.md`, `state.md`, `_materials/analyses/*.md`, and `checks/`. `map.md` may summarize a child's implication for the parent, but it should link to the child surface that carries the actual state or fact. It is also not `plan.md`: it should not say what to try next unless that line is framed as a read/reopen condition for a child. Strategy, method choice, and success criteria belong in `plan.md` or `research/focus.md`.

Recommended shape:

```markdown
# Map

## Parent Reading
{one short paragraph: how this parent should be read now and what kind of child set it has}

## Children

### [Child Name/](Child%20Name/)
Status: active | stable | closed | parked | archived-link
Parent role: {what this child supplies to the parent}
Parent implication: {the current consequence for the parent board, in one or two sentences}
Live work: {none | yes — short statement | blocked until ...}
Open when: {condition under which a planner/worker should deep-read or reopen this child}

### [Another Child/](Another%20Child/)
...
```

Use ordinary prose when that is clearer than the field labels above. The invariant is not the exact headings; the invariant is recoverability of role, status, parent implication, live-work state, and reopen/deep-read condition for each nontrivial child.

Reading rule: for parent-level direction, start from `state.md` plus `map.md` when it exists. Deep-read only children whose map entry is active, missing, contradictory, stale, or directly relevant to the next worker target. Closed, parked, and stable children should not be reopened during ordinary direction-setting just because they exist.

`story.md` is not part of this protocol. If a writing workflow later needs a paper narrative or presentation order, it may define or use `story.md` for that purpose. Do not use `story.md` as the parent-child routing map unless a future framework change explicitly redefines it.

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
- absent | candidate | established in [conventions.md](conventions.md) / [findings.md](findings.md)
```

`sources.md` is managed by the project-side direction workflow, not by reader. Reader may be dispatched because a `sources.md` source question exists, but reader does not update `sources.md`; reader updates only `literature/notes/{id}.md`, `literature/catalog.jsonl`, `literature/reading_list.md`, and its `literature/_reviews/{id}/worker.md` source-reading submission plus raw process log. This separation prevents a source-reading agent from deciding how the project should use the source.

## principles.md — Research Principles

`principles.md` is the ledger of currently active research judgment principles for a node or subtree. A principle is not an important fact, not the project thesis, not a route priority, not a source to read next, not a notation choice, and not a transient instruction. It is a reusable criterion that changes future research judgment: what kind of inference is allowed, which roles must stay separate, what evidence threshold prevents overclaiming, or what comparison may not be promoted without an explicit bridge.

**Why this file exists.** Some mistakes recur across many nodes because they are not local facts: analogy gets treated as identification, diagnostic routes get promoted as theorem evidence, source-native statements get rewritten as project-side claims, or a temporary route priority becomes a hidden premise. If those constraints live only in `map.md`, `story.md`, or `plan.md`, they look like local routing or strategy and are forgotten when the cursor moves. If they live in `findings.md`, they pollute the fact layer. A research-principles ledger gives agents a compact current rule set for judgment without turning the tree into a transcript.

**What belongs here.**
- A criterion that should be applied repeatedly across the subtree when promoting, rejecting, comparing, or routing claims.
- A role-separation rule, such as keeping a diagnostic route distinct from a positive theorem route unless an explicit bridge is established.
- An evidence threshold that prevents a known class of overclaiming across multiple future decisions.
- A project-local research norm whose reason and consequence remain active beyond the meeting or cycle that produced it.

**What does not belong here.**
- The project thesis, narrative success condition, or paper storyline — put that in `story.md`.
- Parent-child role, child status, parent implication, or reopen/deep-read condition — put that in `map.md`.
- Decomposition, route priority, approach choice, or active strategy — put that in `plan.md` or `research/focus.md`.
- Source priority, source questions, intended uses, or non-uses — put that in `sources.md` or `backlog.md`.
- Established facts, derivations, or limitations — put those in `findings.md`, `_materials/analyses/*.md`, `checks/`, or `state.md` according to their authority.
- Notation, sign, normalization, symbol reservation, or convention bridges — put those in `conventions.md`.
- Framework-level file contracts or agent workflow rules — improve the framework prompt rather than recording them as project research principles.

**Entry shape.** Free-form prose is allowed, but each entry must make these facts recoverable:

```markdown
# Research Principles

## {Principle name}
Scope: {project-wide | research/{subtree}/ | specific recurring judgment}
Principle: {the reusable judgment rule}
Reason: {why this principle exists}
Consequence: {what future agents should accept, reject, separate, or route differently because of it}
Origin: > [Launch|Meeting|Cycle YYYY-MM-DD] {short reason}
```

The reason and consequence are load-bearing. Without a reason, a principle becomes dogma; without a consequence, it becomes a vague slogan that later agents cannot apply or cleanly retire.

**Maintenance rule.** `/launch` and `/meeting` perform the write-time routing check before adding a principle. Curator performs the maintenance check when touching `principles.md` and during session-end sweep: entries that are really story, plan, source priority, notation, fact prose, or framework workflow rules should be moved to the right surface when the move is mechanical, or flagged for human/research-planner judgment when the scientific meaning would change.

## Folder Names

Every node is a folder, and the folder name is the only thing a reader sees when browsing the tree. Use a semantic slug describing what the node is about on its own — **Title Case with spaces** is the house style (e.g., `Topic Name`, `Subtopic Name`).

The folder path must be stable under reorderings of the narrative. This rules out any slug that depends on where the node sits in the current story — positional prefixes, sequence indices, phase labels, and similar ordering markers all go stale the moment the story is rewritten. Parent-child reading roles live in `map.md`; strategy and decomposition live in `plan.md`; any future paper narrative order belongs outside the path as well.

A reader who sees only the folder name should be able to guess the node's content. If the name only makes sense given the current story, it is the wrong name.

`research/archive/` is the exception to active-node naming. Archived nodes are stored under `research/archive/{YYYY-MM-DD}/{relative-node-path}/` so the original path and archive date remain recoverable. Agents do not browse archive during ordinary context loading; open it only for explicit archaeology, contamination tracing, or when an active file intentionally links to archived process history.

## `_materials/` — Durable Non-Authority Materials

Research nodes may contain `_materials/` alongside interpreted-memory files. This section is the canonical spec for durable materials — agents that write here follow these rules and cite this section rather than restating them.

`_materials/` exists because `.logs/` is chronological audit memory. Chronology is correct for audit, but it is the wrong ordering principle for code, data, figures, shared modules, and clean analyses: those need to be found by node, observable, and API. Placing them under `_materials/` preserves semantic locality without giving them the authority aura of node-root memory files.

Everything under `_materials/` is a material. It may be read, rerun, cited by a check, or distilled into findings, but it is not itself an adopted node fact. Companions and analysis materials may describe what a material computes or argues; conclusions become research memory only through `state.md`, `checks/`, or `findings.md` transactions.

### `_materials/` context-loading rule

`_materials/` is visible so agents can discover that durable material exists, not so every agent loads the material by default. Normal tree orientation may list `_materials/` directories and filenames, but content loading is gated by task relevance. This keeps durable materials from becoming a second chronological context dump.

Use `node .scripts/material-index.mjs research/{path}` as the default discovery tool for a node or subtree. It prints only `_materials/**/*.md` front matter and a short description, not material bodies. This index output is safe ordinary context; it tells an agent what materials exist and why they might matter without loading derivations, code, data, or figure payloads.

Read full `_materials/` contents when one of these conditions holds:
- **Assigned ownership**: simulator/researcher is writing or rerunning node-local `_materials/src|data|images`; engine-builder is writing or refactoring `research/_materials/lib/`.
- **Explicit target**: the dispatcher, a Tree Directive, or a Durable Surface Review names a specific `_materials/analyses/{slug}.md`, script, data file, image, or lib module.
- **Durable link/provenance**: `findings.md`, `guide.md`, `state.md`, a `checks/*.md` record, or an analysis material links the material and the current task needs to understand that support.
- **Promotion, retraction, or archival decision**: curator must decide whether a reviewed worker transaction should become `_materials/analyses/`, whether an analysis material supports findings.md, whether a script is superseded, or whether a node can be archived.
- **Writing support**: `/write` roles need a linked clean analysis, figure, or check to write a paper section faithfully.

Do not read full `_materials/` contents when the task is ordinary direction-setting, cursor navigation, sibling overview, research-memory shape discovery, or narrative orientation and the interpreted surfaces already carry the relevant state. In those cases, read `findings.md`, `guide.md`, `state.md`, `map.md`, `plan.md`, `story.md`, `conventions.md`, and `checks/` summaries first, then use the material index if `_materials/` exists or an interpreted surface mentions supporting material. Open the material only if the decision actually depends on its content.

Granularity matters. Prefer material-index output, `_materials/src/{slug}.md` companions, check records, and TSV metadata headers before opening code bodies or full data. Prefer image filenames/captions or the analysis/check that cites a figure before inspecting binary image files. Code/data/image bulk reads are for simulator, engine-builder, reproducibility checks, or explicit audit — not for ordinary research-tree context.

### Material index metadata

Markdown files under `_materials/` carry YAML front matter for context indexing. This is **not claim metadata** and does not confer authority. It is a lightweight label so ordinary context loading can decide whether to open the artifact body.

Minimum front matter for `_materials/analyses/{slug}.md` and `_materials/src/{slug}.md` companions:

```yaml
---
material_kind: analysis | script-companion | lib-note
description: "{one sentence: what this material is for}"
scope: "research/{node path}/"
status: active | superseded
---
```

Optional fields may include `created_from`, `produces`, `consumes`, `related_checks`, or `review_state`. Keep them descriptive and non-authoritative: they help route context, but the verification truth still lives in `checks/`, and adopted claims still live in `findings.md` or `state.md`.

### `_materials/src/` — Source code tied to a node

Any source code tied to a node lives in `_materials/src/`: simulator's measurement / analysis / plot scripts, and researcher's ad-hoc verification scripts for conjectures and examples. Both writers follow the same rules below.

**Node-root prohibition.** Never place source files (`.py`, `.jl`, …), data, figures, or clean analyses directly in the node folder. Node roots are reserved for interpreted-memory files (`state.md`, `map.md`, `plan.md`, `sources.md`, `backlog.md`, `findings.md`, `guide.md`, `story.md`, `principles.md`, `conventions.md`, `dead_ends.md`, `asides.md`) plus authority-support directories such as `checks/` and the single material directory `_materials/`. Loose materials in node roots make them look adopted as research memory, so creating `_materials/` (and the relevant child such as `_materials/src/`) is mandatory.

**Placement — lowest common ancestor.** Place a script at the lowest node that is an ancestor of every node that uses it. Common cases: a script used only in node `X` lives in `X/_materials/src/`; a script shared across siblings of a parent `P` lives in `P/_materials/src/`; if two cousins share a script, it lives in their nearest common ancestor's `_materials/src/`. This avoids duplication and makes scripts discoverable from the research context.

**Companion `{slug}.md` required.** Every script `{slug}.{ext}` carries a companion `{slug}.md` in the same `_materials/src/` directory — this is the script's permanent label in the tree, so material-index output tells a reader what each file computes without opening the code or grepping `.logs/`. The companion starts with material index metadata, then states what the script computes, key parameters, and how to run it. For simulator's long-lived measurement scripts the companion expands into a full implementation description (see simulator agent). For researcher's one-off attempt scripts a short blurb (a paragraph or two) is enough while the work is provisional. Once a script supports a findings.md claim or an `_materials/analyses/*.md` analysis, the reproducibility summary belongs in the node's `checks/` record or in the analysis material; `.logs/` remains the raw notebook, not the durable verification surface.

**Retirement.** Superseded scripts move to `_materials/src/archive/` rather than being deleted, so the reasoning history stays searchable.

**Hygiene.** Do not commit `__pycache__/`, `.ipynb_checkpoints/`, or any per-machine bytecode generated by running scripts.

### `_materials/data/`, `_materials/images/`, and root `_materials/lib/`

- **`_materials/data/`**: Simulation data in TSV format with structured metadata headers. Placement: the node that **owns the investigation** — data belongs to the node where the measured observable is studied. Managed by simulator (see simulator agent for TSV metadata-header format and archival rules)
- **`_materials/images/`**: Figures and visualizations. Placement: same node as the data they visualize. Managed by simulator
- **`research/_materials/lib/`** (root only): Shared simulation framework modules managed by engine-builder. `_materials/lib/test/` contains module tests

Agents that are not simulator, researcher, or engine-builder treat all of `_materials/src/`, `_materials/data/`, `_materials/images/`, and `_materials/lib/` as read-only context, except that curator may perform planner-directed archival moves from `_materials/src/` to `_materials/src/archive/`. That exception is move-only: curator does not edit code, data, figures, or companion descriptions while moving superseded scripts under the lifecycle protocol.

## `_reviews/{slug}/` — Provisional Worker-Critic Transactions

`_reviews/` is the bounded review-transaction layer. It exists because critic should review a **submitted candidate**, not raw chronological process. The worker submission is the review packet; no separate review-packet surface is needed.

Node-scoped transactions live at:

```text
research/{node path}/_reviews/{slug}/
  worker.md
  critic.md
  repair.md            # optional, at most one worker repair
  critic_rereview.md   # optional, at most one critic re-review
```

Source-reading transactions that are not node-scoped live at `literature/_reviews/{id}/` with the same file names.

### Identity

- `worker.md` is the worker's bounded candidate: the claim, derivation, computation, source extraction, scope, evidence, and intended destination that critic should review.
- `critic.md` is the verifier's separate judgment on `worker.md`.
- `repair.md` is the worker's one allowed repair when the orchestrator decides that a `REVISE-BLOCKING` or `OPAQUE` verdict is cheap and worth retrying.
- `critic_rereview.md` is critic's final judgment on the repair.
- `.logs/` remains raw process trace and audit fallback. A transaction may point to a raw log path in front matter, but ordinary review should not require opening it.

### Worker submission shape

Every review-eligible worker writes `worker.md` with a review contract:

```markdown
---
transaction_kind: worker-submission
intended_destination: state | findings | _materials/analyses | dead_ends | checks | source_record | none
review_focus: "{the claim, derivation, computation, extraction, or construction critic should check}"
scope: "{claimed scope}"
evidence: [proof | mechanical | numerical | literature]
raw_log: ".logs/{...}.md"
---

# Worker submission — {slug}

{Bounded candidate prose. It should be sufficient for critic to judge the submitted claim without reading raw process chronology. Include links to source records, scripts, data, figures, or literature files when those are part of the evidence.}
```

The worker still writes a short raw process log under `.logs/` for audit and human workflow inspection. That raw log is not the critic target by default.

### Critic verdicts and loop budget

Critic uses these verdicts for provisional transactions:

- `ACCEPT` — the submitted target survived review at the stated scope. Curator may absorb the accepted substance into state.md and may materialise it into findings.md or analysis support only when an admission source already says that durable placement is intended.
- `REJECT` — the submitted claim should not enter durable memory.
- `REVISE-NONBLOCKING` — the submission has issues, but curator may still absorb a narrowed state.md entry, lower-confidence working state, or limited lesson without worker repair. It is not permission to promote the claim into findings.md unless a separate admission source covers the narrowed claim.
- `REVISE-BLOCKING` — the submitted claim cannot be absorbed as intended until the worker repairs the candidate.
- `OPAQUE` — the submission failed as a review packet; critic cannot identify what to judge or what evidence supports it.

The orchestrator may run at most one repair loop:

```text
worker.md -> critic.md -> optional repair.md -> critic_rereview.md -> stop
```

If the second critic judgment is still blocking or opaque, stop the worker-critic loop and pass the blocked transaction to curator/research planner. Do not let local repair churn consume the research cycle.

### Context-loading rule

Ordinary direction-setting and tree navigation do not read `_reviews/`. Curator reads transactions listed by the scheduler, transactions named in Tree Directives, and recent transactions needed for session-end coherence. Research planner reads only curator's absorbed summaries and flags unless a blocked transaction is explicitly handed back for direction judgment. Critic reads `worker.md` or `repair.md` as the target, plus only the context allowed by its mode.

Raw `.logs/` are opened from a review transaction only when the submission is opaque, the provenance contract appears inconsistent, the scheduler explicitly requests audit mode, or curator needs audit fallback to understand a blocked transaction. Durable prose must still absorb the substance and never link to `.logs/`.

## conventions.md — Notation and Convention Ledger

`conventions.md` is the tree's ledger for choices that determine how symbols, formulas, and technical phrases are read. It is distinct from `concepts/`: a concept note defines what an object is; a convention entry fixes how this project denotes, orders, or normalizes that object. For example, "Grassmann variable" belongs in `concepts/`; "the site integration measure is ordered as ..." belongs in `conventions.md`.

**Why this file exists.** Notational drift is not a local typo. A sign convention, Fourier convention, tensor-leg order, or symbol reservation can silently change the meaning of claims across siblings. Keeping these choices in ordinary prose inside one findings.md makes them invisible to the next branch; scattering them across logs makes the reader reconstruct the project's language archaeologically. A convention ledger gives curator one place to reconcile the tree's symbolic language before the inconsistency reaches findings.md or the manuscript.

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
- Derivations proving a claim — put those in findings.md or a clean analysis draft; the convention ledger may link to the derivation.
- Process history or "we changed this on date X" narrative — put the evidence trail in state.md if needed. The ledger states the current convention.

**Entry shape.** Free-form prose is allowed, but each entry must make these four facts recoverable:

```markdown
## {Convention name}
Scope: {project-wide | research/{subtree}/ | specific linked claims}
Convention: {the actual notation / order / sign / normalization rule}
Reason: {why this choice is used, or which external convention it matches}
Consequences: {symbols reserved, formulas affected, links to findings.md / _materials/analyses/*.md / checks/*.md that rely on it}
```

The reason is load-bearing: without it, later agents treat the entry as arbitrary dogma and may "simplify" it away. Consequences are also load-bearing: they define the impact surface for a future convention change.

**Maintenance rule.** When curator preserves or rewrites a findings.md/analysis claim that introduces, depends on, or changes a convention, curator must update the nearest applicable `conventions.md` in the same dispatch, then scan affected ancestor/sibling findings.md files for inconsistent usage. If the convention is still provisional, state the scope honestly and do not let findings.md use it as if project-wide. If two live conventions conflict, curator does not silently choose: keep the narrower convention scoped, add a compatibility note if possible, and flag the conflict to research planner when scientific judgment is needed.

## concepts/ — Reusable Reader Bridges

`concepts/` contains reusable explanations for terms that recur across nodes or would otherwise force repeated local definitions. A concept note is a reader bridge, not a project-fact authority and not a convention ledger. It should help a neighbouring-field researcher understand vocabulary; it must not smuggle in unaccepted project claims, workflow state, or provisional constructions.

**Creation bias.** When a reusable undefined term is discovered, prefer creating a small concept note immediately rather than waiting for a later tree crawl. The later crawl still exists as hygiene, but relying on it as the primary trigger lets jargon accumulate in findings.md before anyone notices.

**Pollution control.** A concept note is dangerous when it becomes vague shared doctrine. Keep it narrow: define the term, state the scope, name standard variants if relevant, and point to durable non-dot notes or `_materials/analyses/` only when needed. Do not place project-specific sign conventions in concepts; use `conventions.md`. Do not place project claims or evidence summaries in concepts; use findings.md, `_materials/analyses/*.md`, checks/, or state.md according to their identities.

**Reading rule.** findings.md may link to concepts for reusable explanation, but findings.md must remain understandable at the level of its principal claim, scope, derivation skeleton, and limitation without requiring the concept file to carry hidden project substance.

## Epistemic Boundaries — Prose-First Discipline

Research drift often begins before verification: prose quietly stops distinguishing what a source says, how this project interprets it, what this project constructs, what bridge relates two languages, and what is only an internal diagnostic. The framework preserves those boundaries in ordinary research prose, not in a separate claim database and not with visible management tags. The aim is to keep meaning stable while leaving the research tree readable.

**Principal claim unit.** A principal claim is any statement that later work could rely on: a mathematical result, a source reading, a convention, a compatibility bridge, a scope restriction, a negative result, a diagnostic-to-object distinction, or a stable interpretation. Expository restatements, local derivation steps, and reader-guidance sentences are not principal claims unless deleting them would change what future work is allowed to assume.

**Boundary types are meanings, not output labels.** Agents may reason about these distinctions internally, but ordinary claim prose should express them in natural language rather than emitting schema headings such as `Role:`, `Status:`, `Scope:`, or claim IDs. Good prose says "the cited paper's Eq. (n) is being read on its own source convention" or "the projector is only a project-side diagnostic here"; it does not turn the research note into a registry. This restriction targets ordinary prose surfaces such as findings.md, _materials/analyses/*.md, state.md, story.md, and user-facing summaries. Explicit ledger/metadata surfaces such as `conventions.md` and `checks/*.md` may use their required fields because their identity is to record scoped convention or verification metadata. Machine-readable state may exist in tooling later, but the LLM-facing and user-facing claim surface remains prose.

**Where the boundary is carried.**
- Reader extracts what is written in the source and does not translate it into project convention unless the paper itself gives the translation.
- Researcher states, in ordinary prose, which parts of an argument are source readings, project constructions, compatibility bridges, internal diagnostics, or unresolved discrepancies.
- Critic checks whether a claim changed category while being summarized or lifted: source statements gaining project interpretation, diagnostics becoming target objects, bridge claims missing the explicit map, or restricted results being phrased as unconditional.
- Curator adopts only the principal claims that survive review, writes them as prose in state.md / findings.md / _materials/analyses/*.md, and records notation-changing bridges or conventions in `conventions.md`.
- Research planner specifies the intended work mode when dispatching tasks if a confusion is likely: source-native reading, project-side construction, bridge construction, diagnostic audit, or discrepancy resolution.

This is deliberately prose-first. The framework does not require line-by-line claim tagging, and it does not introduce hidden IDs into normal agent context. It requires enough explicit wording that the next agent does not have to infer whether two formulas are being identified, compared through a map, or merely placed side by side.

## Link Governance and `.logs/`

`.logs/` is the raw chronological audit archive: worker/session intermediate outputs, failed attempts, annotated critiques, and workflow traces. It is used for deep research archaeology, contamination-source tracing, prompt/process improvement, and reconstructing how a durable statement was produced when normal tree context is insufficient.

It is **not** part of normal research-tree reading and is **not** a durable citation target. Durable research prose must absorb the necessary content instead of linking to raw logs. This keeps the tree closed as a shared context surface and prevents raw intermediate wording from being reread as durable authority.

**Hard rule:** durable research and manuscript prose must not link to `.logs/` as evidence or provenance. This includes manuscript prose, paper-draft prose, concept notes, root-level durable files, and node-local variants such as `draft/**/*.md`, `research/**/findings.md`, `research/**/state.md`, `research/**/plan.md`, `research/**/backlog.md`, `research/**/_materials/analyses/*.md`, `research/**/checks/*.md`, `research/**/conventions.md`, `research/**/story.md`, `research/**/principles.md`, `research/**/dead_ends.md`, `research/**/asides.md`, and `concepts/**/*.md`. Hidden workflow/config surfaces such as the runtime instruction directory, `.templates/`, and `.scripts/` are likewise not research evidence; reference them only from framework documentation, prompts, or workflow-improvement notes, not as support for research claims.

Agents may read `.logs/` only when the workflow explicitly asks for audit, archaeology, contamination tracing, or when a maintenance agent is absorbing raw outputs into durable surfaces. After absorption, the durable file states the relevant content in its own prose.

## findings.md — Draft Fact Layer

**What findings.md is.** `findings.md` is the node's draft fact surface: established claims, definitions, derivations or derivation skeletons, scope, limitations, and source/project boundaries written as reusable research prose. It is agent-maintained and can update faster than the manuscript, but it is not the human-authorized final authority. `manuscript/` is the paper-quality highest-authority layer.

**What findings.md is not.** It is not current research state, not a chronological log, not a plan, not a backlog, not a draft index, and not a stamp registry. A reader should not need `state.md`, `plan.md`, `backlog.md`, `.logs/`, or session memory to know what fact is being stated and why the node currently treats it as established or limited.

**Draft fact means derivation-bearing.** A reader who accepts a claim in findings.md must be able to check *why* within findings.md itself or through a durable non-dot link whose target is also self-contained for its role. Provenance references are Markdown links to node-local `checks/*.md` records whose front matter summarizes confidence, evidence channels, review channels, and scope; they are **not** a substitute for the derivation. A high-confidence claim accompanied only by a linked record gives the reader metadata and nothing to check. The dividing line between findings.md as a fact layer and findings.md as an index is exactly this: derivations live in findings.md, not in `.logs/` or behind metadata.

**Scope of "derivation".** What counts satisfies one of:
- *Inline derivation* — a proof sketch, symbolic / numerical computation with its setup and conclusion, or worked-out argument. Full textbook detail is not required; what is required is that a reader in a neighbouring field can follow the logical chain from premises to conclusion without leaving findings.md (modulo Markdown links to concept notes or sibling nodes that supply definitions, referenced lemmas, or derivations covered at another node).
- *Cited external result* — when the claim is a result from external literature used as a premise, cite the source (with section / theorem number where reasonable) in findings.md itself. The citation *is* the derivation pointer, and the linked provenance record will include `evidence: [literature]`. This route is acceptable for results the project *uses*; it is **not** acceptable for project-central claims (those this project is staking as its own contribution) — project-central claims must carry an inline derivation.

**All confidence levels carry derivation.** Claims that appear in findings.md carry the argument, special-case verification, motivating evidence, or established problem formulation that *is* available — with explicit scope — rather than being stated as bare status sentences. An unresolved claim appears in findings.md only when its formulation is itself established knowledge (i.e., the node knows *what* the question is and *why* it is the right question); the answer being unknown is stated, but the framing is substance.

**Audience — the context-free fact reader.** findings.md is written for a reader who knows nothing about the research process: no memory of attempts, critic verdicts, revision rounds, session history, `state.md`, `plan.md`, `backlog.md`, or `.logs/`; no prior exposure to this project's internal vocabulary. The reader is presumed to be a working researcher in a neighbouring field, so standard terminology of that field can be used — but project-specific labels, internal diagnostics, and local jargon need a local bridge before use. A concept link is allowed as a reusable explainer, but findings.md must still make the claim, scope, derivation skeleton, and limitations understandable without making the concept file the hidden authority.

This audience, combined with the derivation-bearing requirement, is the file's strongest constraint. The prose must read cleanly **in isolation** — not merely "in principle understandable given enough context."

**Fact-layer test (run after any substantive edit).** Ask: *can a future agent safely use this node's established facts without reading process state or raw logs?* If the only way to reconstruct the derivation, scope, or limitation of a claim is by reading `state.md` or `.logs/`, findings.md is still an index, not a fact surface. The correct response is to either (i) lift the derivation or derivation skeleton into findings.md, (ii) replace the bare claim with an honest lower-confidence formulation together with the partial argument that is available, or (iii) remove the claim from findings.md pending more work.

**No template.** The content and structure emerge from the research itself. A node studying a mathematical structure will naturally differ from one resolving a paradox or surveying a field. Prescribed sections constrain the researcher's thinking — the prose should take whatever form best captures the established knowledge together with its derivation.

**Content rules (enforced on every findings.md / fact-maintenance dispatch):**

1. *No frontmatter* — fact files are clean prose.
2. *Derivation or citation for every principal claim* — per "Scope of derivation" above. A claim stated with a provenance reference but without an inline derivation or a cited source is incomplete and must be completed or demoted before the dispatch closes.
3. *Provenance link alongside every principal claim* — per the Verification Provenance Records section below. The link points to the `checks/*.md` record that summarises the verification chain in front matter and explains it in prose; it does not replace the derivation required by rule 2 and never points to `.logs/`.
4. *No chronology, no process-status phrasing.* The rule excludes **session history** from findings.md, not **substance**. A proof, a symbolic computation with its setup and conclusion, or a worked-out argument is the content of a claim; rule 2 requires it to be there. What rule 4 rules out is the state of the investigation — dated status blocks (`Status update YYYY-MM-DD`, `Progress 2026-…`), Current-State / Evidence sections copied from state.md, cycle references (`r2`, `r3 stage`, `latest cycle`), review-state markers (`critic pending`, `REVISE minor`, `awaiting resubmission`), and workflow words (`resubmission`, `previous attempt`). These decay on the next cycle; the confidence information they try to convey is exactly what the linked provenance record encodes. Write the derivation in timeless prose and let the link carry the reader to verification metadata. Conflating substance with session history — treating a derivation as a "process artifact" and stripping it — produces the failure mode this whole section is written to prevent.
5. *No undefined project-internal labels* — ad-hoc identifiers that index items in a working list but have no stable definition elsewhere (e.g., open-question IDs, informal candidate/hypothesis tags, attempt slugs, cycle references) may appear only if they are either (a) introduced with a one-sentence explanation where first used, or (b) replaced by a self-contained description. Preferably just describe the thing in plain prose. A reader should never have to grep the repo to learn what an internal label means.
6. *Every non-common technical term is gated* — for each term that a reader in a neighbouring field would not immediately recognise, use one of two gates:
   - *Markdown link*: `[display text](relative/path.md)` or `[display text](<relative/path with spaces.md>)` pointing to a concept note in `concepts/` or a sibling/ancestor node's findings.md. Link targets are relative to the file containing the link. Follow the link to verify it resolves.
   - *Inline definition*: one sentence introducing the term before it is used.
   
   When in doubt, define locally first. Create a concept note in `concepts/` when the term is reusable across nodes or its explanation would otherwise be repeated; concept notes are reader bridges, not authority for project facts.
7. *Every load-bearing convention is either stated or linked* — if a claim depends on a nonstandard notation, sign, order, normalization, or symbol reservation, findings.md must either state the convention before use or link to the applicable `conventions.md` entry. Do not rely on a convention being "known from earlier attempts" or buried in state.md. This rule is the convention analogue of rule 6: technical terms need definitions; symbolic choices need convention anchors.

*How rules 5 and 6 divide the work*: rule 5 targets *labels* (no stable definition exists to link to, so the cleanest fix is to describe the thing in prose); rule 6 targets *technical vocabulary* (a stable definition exists or should exist, so the cleanest fix is to link to a concept note).

**Root findings.md** captures the project's overall draft fact layer — the core claims, their derivations (or citations), scope, limitations, and how they connect. It may be newer or rougher than `manuscript/`, but when the two conflict `manuscript/` wins.

**Child findings.md** captures what that specific investigation established, with derivations.

**When to create**: when a node has admitted derivation-bearing or partially derivation-bearing facts worth reusing as facts. Leaf nodes doing pure computation may remain state/draft/check-only until a reusable fact emerges. An accepted worker/critic transaction is evidence, not by itself an admission decision; if the route owner has not decided that the claim belongs in the integrated fact layer, keep it in state.md or analysis material and flag the admission decision.

**Authorship and authority.** Authorship, write authority, promotion authority, verification authority, and graph authority are separate axes. `findings.md` authorship may be carried by a dedicated synthesis role or by a curator-like maintenance role in a given runtime, but it is never ordinary worker-local authorship and never graph authority. The author of a findings.md edit must act as a second reader: lift only reviewed or honestly scoped material, preserve source/project boundaries, and make the prose self-contained.

Research planner never writes findings.md directly; its directives live in `research/focus.md § Tree Directives`. Workers may propose facts or structural pressure in their submissions, but they do not promote claims into findings.md by themselves. Curator or the runtime's fact-maintenance role closes the transaction: implements admitted placement, ensures checks exist, applies audits, and flags scientific ambiguity upward. It does not choose between scientifically meaningful repair options, decide that a reviewed result is important enough to become a reusable fact, or promote route preference into fact-layer prose without an admission source.

Two narrow exceptions to the normal fact-maintenance path:

1. **Trivial mechanical fixes.** Typo corrections, fixing a broken Markdown link, renaming a term after a concept note is renamed. This includes a broken provenance Markdown link when the intended target is uniquely determined, such as a moved check file or renamed heading, and the fix does not change which record certifies the claim. The rule of thumb: if the replacement is uniquely determined — any competent reader would produce the same correction, with no judgment about phrasing or structure — the edit is mechanical. If there is any judgment about wording, ordering, what claim to state, or which verification record should certify the claim, it is not mechanical and must go through curator
2. **User-present collaborative rewrites (`/meeting`, `/launch`).** When the user is actively collaborating — during a meeting discussion, or during the initial project launch — the main agent and user may rewrite findings.md together to reflect synthesis produced in the conversation. The user acts as the second reader in real time.

Anything beyond these two categories — adding a section, rewording a claim, changing which provenance record certifies a claim, restructuring prose, inserting a "status update" block — goes through the fact-maintenance transaction. The critic Durable Surface Review exception is only for separate `checks/` review files, never for findings.md prose. A findings.md edit written by another channel is legitimate input to the tree, but the next maintenance pass should rewrite it if needed to restore fact-layer quality.

This rule has a failure mode to watch for: findings.md drifting into a log-like chronicle with time-stamped "Status update YYYY-MM-DD" sections stacked on top of each other. That shape is the footprint of non-maintenance appending and signals that fact-layer transaction closure has been skipped; the next maintenance run should consolidate such stacks only when the admitted meaning is already clear. If consolidation would require choosing the research interpretation, it should block and return the decision to research planner or meeting rather than hiding the choice inside prose cleanup.

### Critic layering on findings.md

The derivations written into findings.md are reusable draft facts. They must pass independent scrutiny **as they appear in findings.md**, not merely inherit the scrutiny of an upstream raw attempt. Fact-layer synthesis can introduce new failure modes that the attempt-level critic never saw — simplifications that glossed a gap, notational drift, a step that was obvious to the researcher being compressed past legibility, a composed argument spanning several attempts whose joint soundness was never checked.

The maintenance chain is therefore:

1. Researcher produces a raw attempt in `.logs/` with working-note derivation
2. Critic reviews the attempt (blind or contextual) — the first-layer review
3. The fact-maintenance role lifts the derivation into findings.md as reusable fact prose, consolidating across attempts as needed
4. **The maintenance role requests scheduler-dispatched Durable Surface Review on the findings.md derivation itself** as a separate pass, targeting the derivations touched in this dispatch. Mode is contextual by default (the critic needs the surrounding findings.md + ancestor chain to judge whether the lifted derivation suffices for its role in the fact layer); blind mode may be chosen when the derivation is purely mechanical. In the current scheduler model, the maintenance pass may return a `Durable Surface Review needed:` block; the scheduler launches critic and then re-dispatches curator to apply the returned review.
5. The maintenance role applies the critic's findings after the review returns (fixing the findings.md prose, not annotating it in place — findings.md is clean fact prose, so critic writes findings to a separate file under `checks/`)
6. Over repeated maintenance cycles, this layers multiple critic passes over the same findings.md section. That accretion is the mechanism by which findings.md earns its property of surviving many critic eyes

Each such review is composed into the affected claims' linked provenance records (adding the appropriate review channel to the record's front matter and preserving the critic file in `checks/`). A claim whose **findings.md-level** derivation has been critic-reviewed links to a record that reflects *this* review layer, distinct from whatever review the upstream attempt already had.

This layering is not optional decoration — when a findings.md carries substantive new derivations (not just prose polish on an already-reviewed derivation), a findings.md-level critic pass is part of closing the dispatch. Skipping it reproduces the failure mode the derivation-bearing fact-layer design is meant to prevent.

## guide.md — Human Oversight Entrypoint

`guide.md` is the node's human-facing control surface. It exists because a human meeting should not become exhaustive fact-layer QA. The guide helps the human researcher manage the research: understand the node's purpose, interrogate suspicious verification, ask for missing explanations, and decide whether the direction still serves the project.

**What guide.md is.** A short, maintained orientation to the node or subtree for human oversight. It tells a reader what the node is for, why it matters, what the main findings are at a high level, how to inspect the evidence, what remains doubtful, and what questions are worth bringing to `/meeting` or `/steer`. It should let the human decide where to look next without first reading the node's working ledger.

**What guide.md is not.** It is not a fact authority, not a substitute for findings.md, not a meeting transcript, not a progress log, and not a second copy of derivations. If a statement would later be reused as a research fact, it belongs in `findings.md` with provenance; if it is current operational state, it belongs in `state.md`; if it is paper narrative, it belongs in `story.md`; if it is verification substance, it belongs in `checks/`.

**Required stance.** The guide is allowed to be explanatory and suspicious. It should help the human ask good oversight questions rather than reassure them. A good guide points to uncertainty, weak links, unreviewed derivations, reliance on external literature, and places where the AI may have overfit a route or hidden a premise.

**Reading-route discipline.** Do not make `state.md` the default first read. `state.md` is working memory and evidence absorption; it can be long, chronological, and distracting by design. A guide should summarize the present oversight issue in ordinary prose, then point to the smallest surface that answers the next question: `findings.md` for reusable facts, `checks/` for verification, `_materials/analyses/` for a clean derivation or computation, `plan.md` for decomposition, and `state.md` only when the human specifically needs current working-state details or evidence chronology.

**Language discipline.** Technical terms are fine when they are the research language. Internal workflow labels and compressed agent vocabulary are not fine as the main guide language. If a term is needed for oversight, introduce it by saying what concrete risk, decision, or dependency it names; otherwise replace it with the plain research consequence.

**Typical content.** No rigid template is required, but a useful guide usually makes these recoverable:
- The node's role in the project or parent subtree
- The shortest reading path for a human returning to the topic
- The main reusable findings, with links to `findings.md` sections rather than copied derivations
- Verification map: which `checks/*.md` or `_materials/analyses/*.md` support the main findings, and what kind of doubt remains
- Oversight questions: what the human should challenge, ask to be taught, or redirect next

**Maintenance rule.** guide-writer updates guide.md during the session-end guide sweep over scheduler-supplied target nodes. The scheduler supplies paths only: root, cursors seen this session, worker target nodes, curator cursor nodes, presentation-boundary parent/child nodes, Durable Surface Review target nodes, and final-cursor ancestors. guide-writer reads the durable surfaces directly and updates guide.md only when the human oversight entrypoint is missing or stale. Curator does not write guide.md and does not decide what human-facing explanation should be shown. `/meeting` may also update guide.md live when the user asks for a different explanation, records a recurring doubt, or reframes what they need to monitor. Updating guide.md must not be treated as authorization of findings.md; if the meeting or guide-writer exposes a fact-layer defect, route it back to curator/critic/research planner as readiness debt.

### `checks/` — Node-local verification record

`checks/` is the node's durable verification ledger. It exists because `.logs/` is a raw chronological audit archive: useful for reconstructing what happened during an explicit audit, but not a normal citation surface. When a verification result is important enough to justify a provenance reference on findings.md or an analysis material, the inspectable review record lives with the node.

Typical contents:
- `critic_findings_{slug}_{YYMMDD_HHMM}.md` — critic Durable Surface Reviews of findings.md sections, written as separate files so findings.md stays clean fact prose
- `check_{slug}.md` — curator-written reproducibility summaries for scripts / computations that support a promoted claim, with links to the relevant `_materials/src/`, `_materials/data/`, or `_materials/images/` artifacts and the exact claim checked

What belongs here is verification substance, not process chronology. A `checks/` file states the target claim, the method, the result, scope restrictions, and provenance contribution in its own prose. It must not link to `.logs/`, and it must not require the reader to open raw notebooks to know what was checked. Conversely, `checks/` is not a loophole around findings.md self-containment: findings.md still carries the derivation or cited external result. `checks/` records how that derivation was reviewed or reproduced.

**When to create**: when a findings.md-level critic pass runs, when a mechanical / numerical check supports a promoted claim, or when an `_materials/analyses/*.md` analysis needs a stable review record before curator can use it as support.

**Naming**: descriptive, lowercase-ish slugs with the check type first, e.g. `critic_findings_surface_dispersion_260430_1430.md`, `check_sign_convention.md`. Timestamp Durable Surface Review files so repeated review layers do not overwrite each other.

## Verification Provenance Records

Claims in findings.md carry a **Markdown link** to a node-local `checks/*.md` record so readers can assess **how** each fact was established, **whether it has been independently reviewed**, and **at what scope**. Analysis materials may also link to checks when the analysis itself has been reviewed, but the link does not turn the material into node fact authority. A newly worker-authored analysis may be clean but still unverified; curator/critic close the provenance-link transaction before curator cites the analysis as support or distills it into findings.md. The metadata lives in YAML front matter at the top of the linked check file; the findings.md/analysis prose remains ordinary Markdown rather than acquiring a project-specific inline tag syntax.

**Why links plus front matter.** Verification metadata is structured data about a claim, not part of the mathematical sentence itself. YAML front matter is a widely used Markdown convention for document metadata; keeping the axes there makes them machine-readable and keeps findings.md clean fact prose. The inline surface should therefore be a normal link such as `[verification](checks/check_projector_identity.md)`, while the target file carries the confidence/evidence/review/scope fields.

**Records accompany, not replace, the derivation.** Every claim linking to a provenance record in findings.md must also carry the derivation that supports it (inline or cited — see § findings.md — Draft Fact Layer, "Scope of derivation"). The record summarises the verification chain so a reader can decide how much trust to invest; the derivation is what the reader actually checks. A linked claim without an accompanying derivation is the failure mode the whole § findings.md — Draft Fact Layer is written to prevent, and no refinement of the record schema repairs it.

### Check Record Kinds and Front Matter

Every `checks/*.md` file starts with YAML front matter. The required fields depend on the check record kind. A `provenance` record is the metadata endpoint linked from a findings.md or _materials/analyses/{slug}.md claim. A `durable-surface-review` record is critic's review record for a findings.md section or analysis material; it may later be composed into one or more provenance records by curator. Curator-written reproducibility summaries use `record_kind: reproducibility` and include the checked material, method, result, scope, and any claim path they support.

All check bodies explain their front matter in prose: target claim or surface, method, result, scope restrictions, and the critic or curator judgment. Front matter is the index; the body is the inspectable record.

### Provenance Front Matter Schema

Every `checks/*.md` file that supports a findings.md or _materials/analyses/{slug}.md claim uses `record_kind: provenance` and starts with YAML front matter of this shape:

```yaml
---
record_kind: provenance
claim: "projector identity"
claim_path: "../findings.md#optional-heading-or-claim-anchor"
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
| `record_kind` | `provenance` for a claim-linked provenance endpoint |
| `claim` | Short identifier for the claim being certified; enough to disambiguate within the node |
| `claim_path` | Relative Markdown link target to the findings.md/analysis location whose claim this record supports |
| `confidence` | One of `confirmed`, `strong-conjecture`, `conjecture`, `open` |
| `evidence` | First-order evidence channels: `proof`, `mechanical`, `numerical`, `literature`. One or more when multiple derivations agree |
| `review` | Independent review channels: `critic-blind`, `critic-contextual`. Empty list if no independent review has been accepted |
| `scope` | `full` when the full declared scope is verified, otherwise a concrete description of the restricted instance |
| `supports_project_central_claim` | `true` when the project is staking this claim as its own contribution; `false` for external results cited as premises |

### Durable Surface Review Front Matter Schema

Critic-written reviews of findings.md sections or analysis materials use `record_kind: durable-surface-review`. They are review records, not claim-linked provenance endpoints. Curator may later compose an accepted review channel into one or more `record_kind: provenance` records.

```yaml
---
record_kind: durable-surface-review
target: "../findings.md#optional-heading-or-claim-anchor"
surface: findings
review_mode: contextual
verdict: ACCEPT
scope: "claim or section reviewed"
---
```

Fields:

| Field | Meaning |
|---|---|
| `record_kind` | `durable-surface-review` for critic review of a durable prose surface |
| `target` | Relative Markdown link target to the reviewed findings.md section or `_materials/analyses/{slug}.md` material |
| `surface` | `findings` or `analysis` |
| `review_mode` | `blind` or `contextual` |
| `verdict` | `ACCEPT`, `REVISE`, or `REJECT` |
| `scope` | Concrete description of the reviewed claim, section, derivation, or analysis scope |

### Reproducibility Front Matter Schema

Curator-written reproduction or check summaries use `record_kind: reproducibility`. They record a first-order procedure/result that may support a later provenance record. The terminal provenance link for a principal findings.md or analysis claim still points to `record_kind: provenance`; a reproducibility record may be linked as supporting material or summarized inside that provenance record, but it is not itself the claim's provenance endpoint.

```yaml
---
record_kind: reproducibility
target: "../_materials/src/check_identity.py"
method: "symbolic exact check"
result: PASS
scope: "finite N=4 instance"
claim_path: "../findings.md#optional-heading-or-claim-anchor"
---
```

Fields:

| Field | Meaning |
|---|---|
| `record_kind` | `reproducibility` for curator-written reproduction/check summaries |
| `target` | Relative Markdown link target to the checked material, claim, script, data, figure, or analysis |
| `method` | Short method label: symbolic exact check, numerical reproduction, data/figure audit, source comparison, etc. |
| `result` | `PASS`, `FAIL`, `MIXED`, or a similarly concrete result label when the check is not binary |
| `scope` | Concrete coverage of the check |
| `claim_path` | Optional relative Markdown link target to the findings.md or analysis claim this check supports |

**Terminal provenance endpoint.** A `checks/*.md` file is the project-internal endpoint of a provenance link, not a routing page to more project documents. When `findings.md` or `_materials/analyses/*.md` links to a check record, a reader must be able to evaluate the verification judgment from that record itself. The record may mention project artifacts it absorbed, but it must not make the reader open `state.md`, `_materials/analyses/*.md`, another `checks/*.md`, or `.logs/` to discover the actual evidence, procedure, result, scope, or limitation. If a project-internal artifact matters, absorb the relevant claim, calculation, procedure, result, and limitation into the check body in compact prose.

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

When critic runs its own SymPy/numerical computation during review, that adds first-order evidence too — e.g., `evidence: [mechanical]` plus `review: [critic-blind]`. A review channel never means "the evidence exists"; it means an independent agent checked evidence stated elsewhere. If the target contains an actual proof argument, record `evidence: [proof]` and the critic channel that reviewed it. A review-only record with no first-order evidence is allowed only for non-principal orientation or coherence judgments and cannot support confidence above `conjecture`.

### Scope

`scope` means **verified coverage**, not the intended breadth of the claim. `scope: full` means the evidence verifies the claim over its full declared scope. When verification covers less than the claim says or when the claim is still open, write a concrete restricted coverage such as `smallest parameter instance`, `one concrete example`, or `not yet verified beyond formulation`. A vague value such as `scope: special-case` is forbidden because readers cannot otherwise evaluate what was covered.

### Rules

- Every `confidence: confirmed` record must carry at least one first-order `evidence` value. Bare confirmation with no first-order evidence is forbidden because readers cannot then evaluate the claim. A `review` value alone does not count as first-order evidence
- Evidence and review channels compose freely when both apply. Always declare every applicable channel — omitting a true channel understates the verification chain
- A record whose `scope` is not `full` **cannot** use `confidence: confirmed` — the strongest allowed value is `strong-conjecture`, because full-scope verification is missing by definition
- `evidence: [literature]` alone (no local re-derivation) does not suffice for **project-central claims** — meaning a claim this project is staking out as its own contribution, as opposed to a premise cited from external work. A citation-only record with `confidence: confirmed`, `evidence: [literature]`, and `supports_project_central_claim: false` is fine when the claim is explicitly framed as the external result itself — e.g., "Theorem X of {Author et al.} holds" — and no project contribution is being attested. To reach `confirmed` on a project-central claim, findings.md must carry a local derivation or bridge and the record must include a first-order evidence channel (`proof`, `mechanical`, or `numerical` as applicable). Independent review of citation applicability strengthens that bridge, but it does not replace the local derivation requirement
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
| A dictionary/identification between an external result and this project's own objects, where critic has reviewed coherence but full re-derivation is pending | `confidence: strong-conjecture`; `evidence: [literature]`; `review: [critic-contextual]`; `scope: "bridge coherence reviewed; full local re-derivation pending"` |
| A counting/dimension claim established symbolically only on the smallest parameter instance | `confidence: strong-conjecture`; `evidence: [mechanical]`; `review: []`; `scope: "smallest parameter instance"` |
| A structural separation tested on one small concrete example | `confidence: strong-conjecture`; `evidence: [mechanical]`; `review: []`; `scope: "one concrete example"` |
| A numerical agreement with prediction on a specific parameter choice, checked by critic in blind mode | `confidence: strong-conjecture`; `evidence: [numerical]`; `review: [critic-blind]`; `scope: "specific parameter choice"` |
| The same claim extended to the full declared scope, not yet verified | `confidence: open`; `evidence: []`; `review: []`; `scope: "not yet verified beyond formulation"` |

## `_materials/analyses/{slug}.md` — Clean Analysis Materials

Self-contained analyses authored by a worker or rewritten from a reviewed worker submission into clean form. An analysis material is a closed material object: it preserves one analysis at the node whose scope it serves so the analysis can be inspected without opening `_reviews/` or `.logs/`. It is not the node's fact layer, not adopted claim authority, not a living workspace, and not graph authority.

**Relationship to other files:**
- `_reviews/{slug}/worker.md` is the provisional candidate critic reviewed. `_materials/analyses/{slug}.md` is the durable clean material curator preserves after the transaction.
- `.logs/` is raw audit process. Analysis materials are clean durable analyses produced from reviewed submissions, not copied process chronology.
- `findings.md` is the node's integrated fact layer. Analysis materials are individual support objects that findings.md may draw from after verification and curator synthesis.
- `checks/` stores the stable verification record for reviews and reproducibility checks supporting findings.md / _materials/analyses/*.md claims.
- Not every worker submission becomes an analysis material. Not every node has `_materials/analyses/`.

**When to create**: create an analysis material only when the analysis is worth preserving as a closed material object, not merely because a worker produced text. Strong signals:
- The analysis is self-contained and reusable, but too long, computational, figure-heavy, or locally scoped to belong in findings.md.
- A simulation or construction needs reproducibility details, figures, parameters, or worked examples that future readers may inspect without opening `.logs/`.
- The result is not yet integrated into findings.md, but it is a meaningful support object that curator/critic can review, cite, limit, or reject.
- Multiple future tasks would otherwise need to reread the same review transaction or rerun the same setup from logs.

Do not create an analysis material when the material is only attempt chronology, a scratch derivation with unresolved gaps, a short fact that belongs directly in findings.md/state.md, a tactical TODO for backlog.md, or a living research scope that should become a node.

A worker may author the analysis material directly when explicitly assigned, but this is authorship only: the worker does not decide node placement beyond the assigned existing node, fact-layer promotion, status, or whether the material should become a node. Curator does not re-judge the specialist conclusion from scratch; curator manages whether the material has enough review, scope, and provenance to be cited, distilled, limited, or rejected in interpreted memory.

**Minimum shape**:

```markdown
---
material_kind: analysis
description: "{one sentence: what analysis this material preserves}"
scope: "research/{node path}/"
status: active
review_state: unreviewed | reviewed | partial
---

# {Analysis Title}

{Self-contained analysis prose. Include the setup, method, result, limitations, and links to checks or artifacts needed to inspect it. Do not require `.logs/` to understand the claim, method, result, or limitation.}
```

**Naming**: `_materials/analyses/{slug}.md` where `{slug}` is a descriptive identifier (e.g., `_materials/analyses/surface_dispersion.md`, `_materials/analyses/magnetic_c4t.md`).

**Analysis vs subnode.** `_materials/analyses/{slug}.md` is a closed material object. `research/{Topic}/` is a living scope: future attempts, state.md, plan.md, checks, conventions, and multiple analysis materials may accumulate there. Avoid `X/analysis.md` because it makes the node and material identities collapse into each other. If an analysis starts to require follow-up attempts, multiple checks, competing variants, or its own strategy, the graph authority creates or proposes a subnode and places future work there; the original analysis remains material.

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

The node's graph-structured research state: current board plus absorbed evidence ledger. It is durable enough for later agents to reconstruct where the node stands, but it is not the fact layer and not a raw chronological log. Every node starts with state.md. plan.md is added when strategic decisions need recording. findings.md appears when reusable facts emerge.

```markdown
---
kind: {kind}
status: {status}
---
# {description}

## Background
{Why this node exists, what parent/project context it isolates, and any stable references needed to understand the current board.}

## Current Board
{What is known, what is unknown, active hypotheses, disputed points, blockers, and current status.}

## Evidence
- {entry}: {what was attempted or checked, what was absorbed, what confidence/scope changed, and whether critic accepted/revised/rejected it}
{append-only — never delete evidence entries}

## Revisions
- {entry}: {retractions, reframes, reparenting notes, scope changes, and other durable changes to the node's interpretation}
{append-only — never delete revision entries}
```

Root state.md additionally carries `last_meeting` in frontmatter. Its `## Background` section is project-wide: key references, prior work, and launch-level context.

Evidence entries summarize raw outputs; they do not link to `.logs/`. Raw paths may appear in dispatcher prompts and audit tooling, but authored state.md prose is a graph-structured absorption of what matters, not a citation index into the audit archive.

## Example Tree

```
research/
  findings.md              (project-level draft facts)
  guide.md              (human oversight entrypoint)
  plan.md              (root-level strategy and decomposition)
  state.md               (background, working state — ladder)
  focus.md            (session cursor: "work here now")
  story.md             (paper narrative structure)
  principles.md        (research judgment principles)
  conventions.md       (project-wide notation and convention ledger)
  dead_ends.md         (rejected-direction register — outside fact layer)
  asides.md            (parked off-thread items — outside fact layer)
  _materials/lib/                 (shared simulation framework — engine-builder manages)
    ClockModel.jl
    XYModel.jl
    test/
  Paradox Resolution/
    findings.md            (derivation-bearing: the paradox stated, and the derivation resolving it)
    guide.md            (what to inspect and what remains suspicious)
    plan.md            (approach strategy)
    state.md             (background, current state, evidence, revisions)
    _materials/analyses/
      symmetry_analysis.md  (curator-preserved verified analysis on symmetry constraints)
    checks/
      critic_findings_symmetry_analysis_260430_1430.md
    conventions.md       (optional subtree-local notation/convention choices)
    asides.md            (optional parked off-thread items scoped to this subtree)
  Lattice BKT/
    findings.md            (derivation-bearing knowledge of this direction)
    guide.md            (human-facing reading and oversight map)
    plan.md            (children decomposition and strategy)
    state.md             (working state, evidence trail)
    _materials/src/               (scripts relevant to this branch)
      winding_decay.jl           (simulator's long-lived measurement script)
      winding_decay.md           (companion: algorithm + params + how to run)
      archive/                   (superseded scripts kept for history)
    Coulomb Escape/
      state.md           (leaf: may only have state.md, no findings.md yet)
      _materials/src/             (scripts specific to this leaf)
        escape_rate.jl           (simulator's measurement)
        escape_rate.md
        check_sign_convention.py (researcher's one-off verification)
        check_sign_convention.md (short blurb; promoted checks live under checks/)
      _materials/data/            (simulation data for this investigation)
      _materials/images/          (figures generated from this data)
      _materials/analyses/
        escape_rate.md
      checks/
        check_sign_convention.md
```

## Data Layers Summary

| Layer | Location | Worker access | Write authority / exceptions | What it contains |
|---|---|---|---|---|
| **Manuscript** | `manuscript/` | No write access in current workflow | Frozen until a future human-authorized manuscript protocol exists | Reserved future highest-authority, fully self-contained, human-authorized paper prose. Current `/auto`, `/steer`, `/meeting`, and `/write` do not create or promote into it |
| **Paper draft workspace** | `draft/` | No direct write access from research workers | `/write` draft workflows only | Paper outline, draft conventions, section drafts, and integrated draft versions. Not human-authorized authority; does not override manuscript or findings.md |
| **Research tree — facts** | `research/**/findings.md` | Read-only | Fact-maintenance transactions; trivial mechanical fixes; user-present `/launch` and `/meeting` collaborative rewrites | Draft fact layer — established claims + derivation/derivation skeleton + scope + limitations + Markdown provenance link |
| **Research tree — guides** | `research/**/guide.md` | Read-only | guide-writer session-end sweep; human-present meeting updates | Human oversight entrypoint; orientation, reading path, verification map, and challenge questions. Not fact authority |
| **Analysis materials** | `research/**/_materials/analyses/*.md` | Write only when explicitly assigned clean-analysis authorship | Worker assigned by planner, or curator preservation transaction from a reviewed `_reviews/` submission | Self-contained clean analyses; worker-authored or worker-originated; material support, not node fact authority |
| **Research tree — checks** | `research/**/checks/*.md` | Read-only | Critic Durable Surface Review; curator reproducibility/provenance records | Node-local verification records with YAML front matter: findings.md critic reviews, reproducibility summaries, and check results supporting provenance links |
| **Research tree — sources** | `research/**/sources.md` | Read-only | Research planner source-map transactions | Node-local map of external source records, intended uses, explicit non-uses, and bridge status |
| **Research tree — plan** | `research/**/plan.md` | Read-only | Curator graph-consistency maintenance from planner directives and absorbed evidence | Decomposition and planner-supplied strategy: children roles, approach decisions, success criteria |
| **Research tree — state** | `research/**/state.md` | Read-only | Curator evidence absorption, board rewrite, status/kind frontmatter | Graph-structured current board and absorbed evidence ledger; kind/status frontmatter |
| **Research tree — backlog** | `research/**/backlog.md` | Propose items in submissions | Curator maintenance | Optional parked executable reminders; no claims, evidence, or durable strategy |
| **Research story** | `research/**/story.md` | Read-only | `/launch`, `/meeting`, or curator maintenance | Narrative structure and paper-story positioning; not fact proof or verification surface |
| **Research principles** | `research/**/principles.md` | Read-only | `/launch`, `/meeting`, or curator maintenance | Current reusable research judgment principles; not thesis, strategy, sources, notation, fact prose, or framework workflow rules |
| **Convention ledger** | `research/**/conventions.md` | Read-only | Curator/fact-maintenance when touched claims introduce or depend on conventions; human-present oversight flows | Current notation, sign, ordering, normalization, and symbol-reservation choices, scoped to the node/subtree |
| **Rejected directions** | `research/**/dead_ends.md` | Propose lessons in submissions | Curator maintenance | Lessons from rejected or falsified approaches; outside the fact layer |
| **Parked asides** | `research/**/asides.md` | Propose items in submissions | `/meeting` or curator maintenance | Off-thread items worth not forgetting; outside the fact layer |
| **Concept explainers** | `concepts/` | Read-only | Concept-maintenance transactions | Reusable reader bridges. Not authority for project facts, claims, or conventions |
| **Operational artifacts — framework** | `research/_materials/lib/` | Read-only unless assigned engine-builder role | Engine-builder | Shared simulation modules; material, not claim authority |
| **Operational artifacts — source** | `research/**/_materials/src/` | Write only when assigned simulator/researcher source work | Simulator/researcher for assigned node-local code; curator archive moves only | Source code tied to a node: measurement / analysis / plot / verification scripts, each with a companion `{slug}.md`; material, not claim authority |
| **Operational artifacts — data** | `research/**/_materials/data/` | Write only when assigned simulator data work | Simulator | Simulation data (TSV with metadata headers); material, not claim authority |
| **Operational artifacts — figures** | `research/**/_materials/images/` | Write only when assigned simulator figure work | Simulator | Visualizations; material, not claim authority |
| **Retired research memory** | `research/archive/**` | Read only during explicit archaeology | Curator archive moves | Retired nodes removed from active planning context after reusable value was extracted |
| **Review transactions** | `research/**/_reviews/{slug}/` and `literature/_reviews/{id}/` | Write only the assigned transaction file | Worker writes `worker.md`/`repair.md`; critic writes `critic.md`/`critic_rereview.md`; curator reads and absorbs | Provisional worker-critic transactions. Not durable authority and not linked from durable research prose |
| **Raw audit archive** | `.logs/*_{type}_*.md` | Write own raw process logs only | Producing worker/session role; session-wrap-up for session context | Chronological process traces for audit, archaeology, contamination tracing, and workflow improvement. Not critic targets by default and not linked from durable research prose |
| **Session cursor** | `research/focus.md` | Read-only | Research planner | Research planner's current focus position in the tree |
| **Session context** | `.logs/last_session.md` | Read-only when provided as startup context | Session-wrap-up | Volatile work context for session handoff |

**Tree navigation**: `ls research/{path}/` to see active children (subfolders). Ignore `research/archive/` during ordinary context loading. Read `findings.md` for draft facts, `guide.md` for human oversight orientation, `sources.md` for node-local source maps, `_materials/analyses/*.md` for clean analyses as material support rather than adopted facts, `checks/` for node-local verification records, `state.md` for current board and absorbed evidence, `plan.md` for strategy and decomposition, `story.md` for narrative structure, `principles.md` for reusable research judgment principles, and `conventions.md` for notation / convention choices. Read `backlog.md` only when looking for parked executable reminders; do not treat it as a source for claims, evidence, strategy, or state.

Each node has a `kind` and `status` in its **state.md** frontmatter (not findings.md). Node status is set by curator, based on research planner's Tree Directives and evidence accumulated in state.md (see `{{ runtime.agents_dir }}/curator.md` and `{{ runtime.agents_dir }}/research-planner.md`).

- Writes to the research tree are split by authority and transaction, not just by file path. **Research planner** normally writes `research/focus.md` (cursor + directives + worker dispatch plan); in `/auto` direction mode it also has two narrow current-direction exceptions: minimal child-node creation when needed for immediate dispatch, and current-cursor `sources.md` creation/update when external source usage is part of the direction decision. **Curator / graph authority** owns node folders, placement, status, lifecycle, reparenting, node archival, analysis-to-subnode promotion when warranted, state.md absorption, and plan.md graph consistency. **Fact-maintenance authority** owns admitted findings.md materialisation and provenance-link closure; in the current agent set curator carries this transaction role, but the authority is the transaction contract, not a claim that broad-context curator re-evaluates specialist truth from scratch or chooses between scientific alternatives. **guide-writer** owns guide.md as human oversight prose during session-end sweeps; guide.md never authorizes claims, status, or graph changes. Trivial mechanical fixes and user-present `/launch` / `/meeting` collaborative rewrites are explicit exceptions; see § findings.md — Draft Fact Layer for the exact boundary. **Critic** writes provisional review files only inside the same `_reviews/` transaction and Durable Surface Review files under `research/**/checks/`. Simulator writes operational materials under `_materials/data/`, `_materials/images/`, and `_materials/src/`; engine-builder writes shared operational materials under `_materials/lib/`; workers may write `_materials/analyses/*.md` only when explicitly assigned clean-analysis authorship in an existing node. Those material writes do not authorize fact-layer adoption, graph placement beyond the assigned node, or status changes. If research planner or a worker notices a tactical item worth preserving in `backlog.md`, they propose it; the maintenance path decides whether it belongs there.
- To propose a status change, describe the rationale in your worker submission
- Honest reporting is paramount: never propose stable for something that has not been sufficiently verified
