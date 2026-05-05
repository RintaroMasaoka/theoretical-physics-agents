# Phase: Cycle Step 3 — Result Collection & State Update

This phase file is a legacy reference for the result-collection concerns that now flow through the scheduler + curator split. It covers FAILED handling, node-splitting triggers, stable/report/retraction judgments, critic modes, researcher resubmission, simulator verification, and note capture. Tree writes described here are expressed as research planner Tree Directives and executed by curator; do not treat this file as permission for the scheduler or research planner to edit `research/**` directly.

---

Retrieve deliverable paths from task return values and Read deliverables directly as needed:

## Handling FAILED Tasks

If an agent returns `FAILED:`, its deliverable does not exist. Papers remaining `unread` are subject to the unread paper principle. Typical response: retry reader next cycle or note in `agenda.md`

## Absorb Evidence via Curator

Every critic-reviewed worker deliverable is passed to curator. Curator records new evidence in the relevant state.md, rewrites `Current Board` when understanding changes, and preserves Evidence as append-only provenance.

## Node Creation — split the tree as it grows (concrete triggers)

The tree must grow with the research, not stay frozen in the shape `/meeting` or `/launch` first gave it. **Node creation is not gated by meeting approval** — `directives.md` is the only meeting-exclusive structure (cf. the file-role table in `architecture.md`). Research planner creates a minimal child immediately when direction-setting needs that child as the same cycle's cursor or worker target; otherwise it requests a split in Tree Directives. Curator closes planner-created children structurally and may also create splits from structural-maintenance judgment when the evidence record already shows the parent has become overloaded. A newly created node that turns out to be a misread can be closed or merged on a later cycle, which is cheaper than leaving the tree stale.

The common failure mode is the opposite — the system keeps working inside existing nodes and the tree stays flat while `.logs/` accumulates many deliverables on sub-topics that deserved their own nodes. Watch for that footprint (flat tree + heavy `.logs/` concentrated on one node) as a signal that node creation has been deferred too long. Apply the following triggers as reasons for minimal planner creation, a Tree Directive, or curator-initiated split; if several fire, create only the clearest child this cycle and let the remaining structure settle on later evidence.

- *Evidence cluster trigger (within-log density)*: if a node's state.md Evidence section accumulates roughly 4+ entries that share a common sub-target (same conjecture being attacked from multiple angles, same sub-object being characterised, same construction being elaborated), the sub-target almost certainly deserves its own child node. Create it and **copy** the relevant evidence entries into the new child's state.md as its initial Evidence; append a single entry in the parent's Evidence section recording the reparenting with a relative Markdown link (e.g., `reparented: {sub-target} evidence copied into [child state](<relative/path/state.md>)`). **Do not move or delete the original entries from the parent** — duplication is intentional, so that the parent's state.md remains a faithful historical record of what was seen at that node at that time. Removing the originals would violate the append-only invariant even though a reparenting entry is appended
- *Multi-attempt trigger (re-dispatch count)*: if researcher has been re-dispatched 2+ times on the same or near-identical sub-problem within one node (typically detectable as multiple `.logs/{timestamp}_attempt_{slug}.md` files sharing a slug), the sub-problem names an emerging sub-topic — promote it to a child node and dispatch future attempts against the child. This is a *faster* signal than the evidence cluster trigger: it fires earlier, before 4 evidence entries accumulate
- *Report-scope trigger*: when a deliverable is ready for promotion into `report_{slug}.md`, check whether the report's topic matches only one of multiple angles listed in the parent's plan.md (children roster / Current Board open angles). If it matches only one angle, create a child node for that scope and place the report there instead of at the parent — reports belong at the node whose scope they match, not at the nearest convenient ancestor
- *Decomposition trigger (proactive)*: if the current node's state.md Current Board lists three or more distinct open angles, the node is a decomposition candidate — the Current Board paragraph typically stops fitting in working memory around that point, and decomposition is precisely the cost the tree structure is meant to amortise. Split at least the two most active angles into children and re-home work appropriately
- *Emerging-focus trigger (cross-cycle recurrence outside plan.md)*: if a sub-topic that was **not** in the original plan.md shows up repeatedly in recent attempts and critic verdicts (i.e., research has organically discovered a new sub-problem that plan.md does not yet anticipate), create a child for it — do not wait for a meeting to bless the new structure. `/meeting` is for course correction, not for permission to reflect what has already been learned. This trigger complements the evidence cluster trigger on the *novelty-to-plan* axis: a sub-topic can fire emerging-focus before it accumulates enough evidence entries to fire evidence cluster

For creation mechanics and structural closure, see research-planner.md, curator.md, and `architecture.md`. **After any node creation, curator updates the parent's plan.md** to record the new child's role and the decomposition rationale; skipping plan.md silently decouples the tree from the plan document. If research planner creates the minimal child, it may set the cursor or worker target to that child in the same cycle, but it must leave parent integration, evidence copy, link hygiene, and lifecycle cleanup to curator via a structural-closure directive.

## Update plan.md (when strategy changes)

If results change the approach — new decomposition, reprioritized children, revised strategy — research planner states the needed change as a Tree Directive or curator applies it from structural-maintenance judgment. Curator updates plan.md. plan.md reflects how to proceed; state.md records what happened and what is known.

## Stable Check (before any status → stable)

Curator rewrites `Current Board` before marking stable — what is known, confidence, unexplored angles. If writing reveals significant open directions, keep `active` and create or request children. A node moves to `stable` when results are reliable enough to reference and remaining directions are not urgent.

## Promote to Report (when appropriate)

If a worker deliverable (in `.logs/`) contains a significant result, research planner may direct clean report creation or placement and curator closes the transaction in the relevant research tree node. Reports are self-contained clean analysis artifacts. They belong to the node whose scope they serve, not to the raw chronology. Not every deliverable gets a report.

## Feed note.md Through a Fact-Layer Transaction

note.md is the draft fact layer — canonical rule in `{{ runtime.research_tree_file }}` § note.md. It is not current state, not a report index, and not final manuscript authority.

Operational rule: when a result reaches reusable fact status, close a fact-layer transaction — claim, derivation or derivation skeleton, scope, limitations, source/project boundary, and check link. In the current runtime curator closes this transaction; do not write note.md prose directly from the scheduler or research planner role. This applies to updates as well as first creation.

## Contribution Assessment

Review the researcher's self-assessment as input to the next research planner direction. Curator writes the adopted evidence judgment in the relevant state.md after reading the critic verdict. When referencing papers not marked `read`, note "provisional judgment as {paper} is unread".

## Retraction

When a previously CONFIRMED claim is falsified, research planner directs retraction and curator writes the retraction evidence into state.md, the lesson into dead_ends.md, and the note.md update that removes or downgrades the claim.

## Float-up Protocol

After updating a leaf, check if the parent's work is complete:
1. `ls` the parent folder — are all children stable or closed?
2. If yes, read the parent's state.md and plan.md. If Current Board, status, or plan.md needs revision, express that as a Tree Directive; curator executes.
3. Continue floating up as long as levels complete
4. When the cursor's subtree fully completes: read root `research/note.md` to decide the next direction. **Update research/focus.md** to the new focus

## Direction Review (when a major subtree — a direct child of root — fully completes, not every cycle)

- Read root `research/note.md`. Did the results advance the argument?
- Does the argument structure need revision? Does each step's why still hold?
- Should nodes be restructured? (close, reframe, reparent)

## Update {{ runtime.tool_update_plan }} (required)

Check off completed tasks, insert new, reprioritize

## Critic Verification Mode (scheduler dispatches critic with Target A — the worker deliverable)

- **Blind mode**: For mechanical/mathematical checks. Critic reads only the worker deliverable, without research context. Eliminates expectation bias
- **Contextual mode**: For logical/value judgments. Critic reads the ancestor chain from root to the **target node being critiqued** (not merely the current cursor) — note.md + plan.md + state.md + dead_ends.md + directives.md at each level

Rule of thumb: "Does the critic need to know the research purpose?" — No → blind, Yes → contextual.

*Critic on note.md (Target B) is curator's internal step, not research planner's or scheduler's.* Curator dispatches critic on lifted note.md derivations as part of its own maintenance workflow (see `{{ runtime.agents_dir }}/curator.md` § note.md critic layering). `/auto` cycles do not dispatch critic on note.md directly — that second-order dispatch is nested inside the curator dispatch already in the cycle.

## Researcher Resubmission

Every researcher attempt must go through critic before its results enter the research tree. Worker deliverables are single-pass outputs that may contain errors or off-target framing — critic provides independent verification before curator absorbs the evidence. If research planner decides to close the node without adopting results, critic is not required. Critic annotates the attempt (strikethrough + comments + Critique section). Research planner decides:
- **ACCEPT**: Let curator update state.md evidence with verification basis and update note.md if warranted
- **REVISE**: Pass annotated attempt path to researcher for resubmission
- **REJECT**: Fundamental approach change. Research planner reconsiders direction

## Simulator Result Verification

Research planner checks the scientific meaning; simulator/critic check the mechanics:
- Whether each verification protocol item was actually executed
- Whether agreement in known limits is quantitatively sufficient
- When results disagree with predictions, distinguish code bug from physics
- When results agree, question whether the agreement is genuine
- **Check figures**: View PNGs via {{ runtime.tool_read }} tool, visually confirm trends and agreement

## Simulator Resubmission

Pass previous deliverable path and code path, specify what to improve. Same physical setup → same deliverable number; changed setup → new number.

## Note Capture (record findings while fresh)

1. Capture research planner synthesis in `research/focus.md` if it affects direction; curator writes the corresponding absorbed evidence in state.md. Deliverables are raw proposals/audit records; state entries are curated current board. Do not copy-paste prose from deliverables into state.md or note.md, and do not link durable tree prose to `.logs/`.
2. Evidence entries should record what was verified and how: e.g., `attempt_14: z = 2πκ − 2 derivation. critic ACCEPT (mechanical: PASS 3/3, logical: sound)`
3. If errors found in deliverables, annotate directly (`~~error~~ [→ correction]`)

## Knowledge Base Maintenance (dispatch curator when needed — not every cycle)

Curator runs fact-layer polishing, durable-link integrity, state.md compression, staleness cleanup, and node splitting as part of ordinary dispatches and the mandatory session-end sweep. Review via `git diff`.
