# Phase: Cycle Step 3 — Result Collection & State Update

This phase file is a legacy reference for the result-collection concerns that now flow through the scheduler + curator split. It covers FAILED handling, node-splitting triggers, stable/draft/retraction judgments, critic modes, researcher resubmission, simulator verification, and findings capture. Tree writes described here are expressed as research planner Tree Directives and executed by curator; do not treat this file as permission for the scheduler or research planner to edit `research/**` directly.

---

Retrieve worker submission paths from task return values and read submissions directly as needed:

## Handling FAILED Tasks

If an agent returns `FAILED:`, its expected worker submission or output file does not exist. Papers remaining `unread` are subject to the unread paper principle. Typical response: retry reader next cycle or note in `agenda.md`

## Absorb Evidence via Curator

Every critic-reviewed worker transaction is passed to curator. Curator records admitted evidence in the relevant state.md, rewrites `Current Board` when understanding changes, and preserves Evidence as append-only provenance.

## Node Creation — split the tree as it grows (concrete triggers)

The tree must grow with the research, not stay frozen in the shape `/meeting` or `/launch` first gave it. **Node creation is not gated by meeting approval**. `/meeting` is for human oversight and course correction, not permission to reflect what the research tree has already learned. Research planner creates a minimal child immediately when direction-setting needs that child as the same cycle's cursor or worker target; otherwise it requests a split in Tree Directives. Curator closes planner-created children structurally and may also create splits from structural-maintenance judgment when the evidence record already shows the parent has become overloaded. A newly created node that turns out to be a misread can be closed or merged on a later cycle, which is cheaper than leaving the tree stale.

The common failure mode is the opposite — the system keeps working inside existing nodes and the tree stays flat while `_reviews/` accumulates many transactions on sub-topics that deserved their own nodes. Watch for that footprint (flat tree + many related review transactions under one node) as a signal that node creation has been deferred too long. Apply the following triggers as reasons for minimal planner creation, a Tree Directive, or curator-initiated split; if several fire, create only the clearest child this cycle and let the remaining structure settle on later evidence.

- *Evidence cluster trigger (within-log density)*: if a node's state.md Evidence section accumulates roughly 4+ entries that share a common sub-target (same conjecture being attacked from multiple angles, same sub-object being characterised, same construction being elaborated), the sub-target almost certainly deserves its own child node. Create it and **copy** the relevant evidence entries into the new child's state.md as its initial Evidence; append a single entry in the parent's Evidence section recording the reparenting with a relative Markdown link (e.g., `reparented: {sub-target} evidence copied into [child state](<relative/path/state.md>)`). **Do not move or delete the original entries from the parent** — duplication is intentional, so that the parent's state.md remains a faithful historical record of what was seen at that node at that time. Removing the originals would violate the append-only invariant even though a reparenting entry is appended
- *Multi-attempt trigger (re-dispatch count)*: if researcher has been re-dispatched 2+ times on the same or near-identical sub-problem within one node (typically detectable as multiple `.logs/{timestamp}_attempt_{slug}.md` files sharing a slug), the sub-problem names an emerging sub-topic — promote it to a child node and dispatch future attempts against the child. This is a *faster* signal than the evidence cluster trigger: it fires earlier, before 4 evidence entries accumulate
- *Analysis-scope trigger*: when a transaction is ready for preservation into `_materials/analyses/{slug}.md`, check whether the analysis topic matches only one of multiple angles listed in the parent's plan.md (children roster / Current Board open angles). If it matches only one angle, create a child node for that scope and place the analysis there instead of at the parent — _materials/analyses belong at the node whose scope they match, not at the nearest convenient ancestor
- *Decomposition trigger (proactive)*: if the current node's state.md Current Board lists three or more distinct open angles, the node is a decomposition candidate — the Current Board paragraph typically stops fitting in working memory around that point, and decomposition is precisely the cost the tree structure is meant to amortise. Split at least the two most active angles into children and re-home work appropriately
- *Emerging-focus trigger (cross-cycle recurrence outside plan.md)*: if a sub-topic that was **not** in the original plan.md shows up repeatedly in recent attempts and critic verdicts (i.e., research has organically discovered a new sub-problem that plan.md does not yet anticipate), create a child for it — do not wait for a meeting to bless the new structure. `/meeting` is for course correction, not for permission to reflect what has already been learned. This trigger complements the evidence cluster trigger on the *novelty-to-plan* axis: a sub-topic can fire emerging-focus before it accumulates enough evidence entries to fire evidence cluster

For creation mechanics and structural closure, see research-planner.md, curator.md, and `architecture.md`. **After any node creation, curator updates the parent's plan.md** to record the new child's role and the decomposition rationale; skipping plan.md silently decouples the tree from the plan document. If research planner creates the minimal child, it may set the cursor or worker target to that child in the same cycle, but it must leave parent integration, evidence copy, link hygiene, and lifecycle cleanup to curator via a structural-closure directive.

## Update plan.md (when strategy changes)

If results change the approach — new decomposition, reprioritized children, revised strategy — research planner states the needed change as a Tree Directive or curator applies it from structural-maintenance judgment. Curator updates plan.md. plan.md reflects how to proceed; state.md records what happened and what is known.

## Stable Check (before any status → stable)

Curator rewrites `Current Board` before marking stable — what is known, confidence, unexplored angles. If writing reveals significant open directions, keep `active` and create or request children. A node moves to `stable` when results are reliable enough to reference and remaining directions are not urgent.

## Promote to Draft (when appropriate)

If a worker transaction contains a significant result, research planner may direct clean analysis creation or placement and curator closes the transaction in the relevant research tree node. Analyses are self-contained clean materials. They belong to the node whose scope they serve, not to the raw chronology. Not every submission gets an analysis material.

## Feed findings.md Through a Fact-Layer Transaction

findings.md is the draft fact layer — canonical rule in `.claude/research-tree.md` § findings.md. It is not current state, not a draft index, and not final manuscript authority.

Operational rule: when a result reaches reusable fact status, close a fact-layer transaction — claim, derivation or derivation skeleton, scope, limitations, source/project boundary, and check link. In the current runtime curator closes this transaction; do not write findings.md prose directly from the scheduler or research planner role. This applies to updates as well as first creation.

## Contribution Assessment

Review the researcher's self-assessment as input to the next research planner direction. Curator writes the adopted evidence judgment in the relevant state.md after reading the critic verdict. When referencing papers not marked `read`, note "provisional judgment as {paper} is unread".

## Retraction

When a previously high-confidence claim is falsified, research planner directs retraction and curator writes the retraction evidence into state.md, the lesson into dead_ends.md, and the findings.md update that removes or downgrades the claim.

## Float-up Protocol

The authoritative cursor rule is `.claude/agents/research-planner.md` § Float-up Protocol. Ascent happens at most one edge per research-planner dispatch. Do not jump to a sibling, root, or newly chosen focus from this collection phase.

When a leaf appears complete, research planner may ascend one edge in `research/focus.md`. That ascent is a presentation boundary: research planner writes the child presentation judgment as Tree Directives, and curator makes the child readable from the parent before parent-level planning resumes. Further ascent, sibling choice, or session completion is decided in later research-planner dispatches after each boundary has landed.

## Direction Review (when a major subtree — a direct child of root — fully completes, not every cycle)

- Read root `research/findings.md`. Did the results advance the argument?
- Does the argument structure need revision? Does each step's why still hold?
- Should nodes be restructured? (close, reframe, reparent)

## Update TodoWrite (required)

Check off completed tasks, insert new, reprioritize

## Critic Verification Mode (scheduler dispatches Provisional Review on the worker submission)

- **Blind mode**: For mechanical/mathematical checks. Critic reads only the worker submission, without research context. Eliminates expectation bias
- **Contextual mode**: For logical/value judgments. Critic reads the ancestor chain from root to the **target node being critiqued** (not merely the current cursor) — findings.md + plan.md + state.md + principles.md + dead_ends.md at each level

Rule of thumb: "Does the critic need to know the research purpose?" — No → blind, Yes → contextual.

*Critic on findings.md is Durable Surface Review.* Curator requests it as part of its own maintenance workflow (see `.claude/agents/curator.md` § findings.md critic layering), and the scheduler dispatches it from the orchestration root. `/auto` cycles do not ask research planner to schedule this review as a worker dispatch.

## Researcher Resubmission

Every researcher attempt must go through Provisional Review before its results enter the research tree. Worker submissions are single-pass candidates that may contain errors or off-target framing — critic provides independent verification before curator absorbs the evidence. If research planner decides to close the node without adopting results, critic is not required. Critic writes `critic.md` separately in the same `_reviews/{slug}/` transaction; it does not annotate the worker submission inline. Research planner decides next direction from curator's flags:
- **ACCEPT**: Let curator update state.md evidence with verification basis and update findings.md if warranted
- **REVISE-NONBLOCKING**: Let curator absorb only the narrowed content critic allowed
- **REVISE-BLOCKING / OPAQUE**: Scheduler may run one repair loop; if still blocked, research planner decides resubmission or pivot next cycle
- **REJECT**: Fundamental approach change. Research planner reconsiders direction

## Simulator Result Verification

Research planner checks the scientific meaning; simulator/critic check the mechanics:
- Whether each verification protocol item was actually executed
- Whether agreement in known limits is quantitatively sufficient
- When results disagree with predictions, distinguish code bug from physics
- When results agree, question whether the agreement is genuine
- **Check figures**: View PNGs via Read tool, visually confirm trends and agreement

## Simulator Resubmission

Pass previous transaction path and code path, specify what to improve. Same physical setup -> same analysis slug or repair transaction; changed setup -> new slug.

## Note Capture (record findings while fresh)

1. Capture research planner synthesis in `research/focus.md` if it affects direction; curator writes the corresponding absorbed evidence in state.md. Worker submissions are provisional candidates; state entries are curated current board. Do not copy-paste prose from worker submissions into state.md or findings.md, and do not link durable tree prose to `_reviews/` or `.logs/`.
2. Evidence entries should record what was verified and how: e.g., `attempt_14: z = 2πκ − 2 derivation. critic ACCEPT (mechanical: PASS 3/3, logical: sound)`
3. If errors are found in worker submissions, critic records them in `critic.md` / `critic_rereview.md`; do not mutate the worker submission inline.

## Knowledge Base Maintenance (curator dispatches every cycle)

Curator is dispatched every cycle and again at session end. This section lists maintenance concerns curator handles during those dispatches: fact-layer polishing, durable-link integrity, state.md compression, staleness cleanup, and node splitting. Review via `git diff`.
