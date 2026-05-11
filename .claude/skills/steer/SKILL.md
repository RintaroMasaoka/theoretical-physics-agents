---
name: steer
description: "Run the normal /auto research loop with a human approval checkpoint after each planner update and before execution."
user-invocable: true
argument-hint: "[steering intent (optional)]"
---

# /steer — Human-Checked Auto Research

Arguments: $ARGUMENTS

---

`/steer` is not a second research scheduler. It is `/auto` with one narrow override: after `research-planner` writes the next `research/focus.md`, execution pauses for a human plan checkpoint. Once the plan is approved, `/steer` resumes the current `/auto` cycle from the ordinary `research/focus.md` parse step and follows `/auto`'s current mechanics.

The human is not replacing `research-planner`. `research-planner` still makes the scientific plan in the normal `/auto` `research/focus.md` schema. The human checks whether that plan matches their research judgment before any worker, critic, curator, or session-end action consumes it.

## Inheritance Rule

`/auto` is the source of truth for research execution. `/steer` adds exactly one approval boundary after `research-planner` writes `research/focus.md` and before `/auto` parses or executes that file. Around that boundary, `/steer` also adds the minimum guards needed to make approval reversible and intelligible: focus backup, planner side-effect tracking, scheduler-written checkpoint presentation, rollback, and bounded revision retry. These guards protect the checkpoint; they do not create a separate execution scheduler.

If `/auto` and `/steer` appear to conflict, `/auto` wins for every post-approval execution mechanic, and `/steer` wins only for the pre-execution approval boundary and its rollback guards.

## Constraints

- **Write all prose in japanese.** Applies to conversational text, checkpoint questions, `_reviews/`, `.logs/`, `research/focus.md`, curator tree writes, worker submissions, checkpoint records, and commit messages. Technical terms, proper nouns, LaTeX mathematics, file/folder slugs, frontmatter keys, and documented structural headings may stay in English.
- Before running, read `.claude/skills/auto/SKILL.md` and the phase files it references. Treat them as the source of truth for every scheduler action not explicitly overridden here.
- The only `/auto` human-interaction rule overridden by `/steer` is the prohibition on user input at the planning/execution boundary. `/steer` may ask the user at the Plan Checkpoint after `research-planner` updates `research/focus.md` and before execution begins. Outside the Plan Checkpoint, do not ask the user for choices, approvals, clarifications, or steering decisions during worker dispatch, review, curation, durable review, guide writing, or session end. If execution becomes structurally impossible outside the checkpoint, stop and report the structural blocker rather than opening a new decision gate.
- Do not maintain a separate `/steer` cycle implementation. If `/auto` changes a phase, `/steer` inherits that change by reading and following `/auto`.
- `/steer` uses the same cycle limit semantics as `/auto`: `MAX_CYCLES` controls the run length, while `Status: session_complete` is only a research-state label. It is not forced to one cycle.
- Acquire new full-paper text only from arXiv, matching `/auto` provenance discipline.
- **Paper writing is NOT `/steer`'s responsibility.** Writing is handled by `/write`.

## Relationship To Other Skills

| Skill | Human role | Execution style |
|---|---|---|
| `/auto N` | Human sets broad direction outside the run; AI chooses and executes each cycle without interruption | autonomous, multi-cycle |
| `/steer N` | Human checks each planner-written `research/focus.md` before it is executed | interactive planning checkpoints, then normal `/auto` execution |
| `/meeting` | Human interrogates direction, verification honesty, and understanding, then records oversight decisions outside execution | live review and recording |

`/steer` may use meeting-like judgment, but it is not a meeting. It does not approve `findings.md` for manuscript use. It only gates whether a proposed execution plan should run.

## Overlay Boundary

At the start of the run:

1. Read `.claude/skills/auto/SKILL.md`.
2. Read any `/auto` phase file needed for the current step, especially `auto/phases/dispatch.md` and `auto/phases/session-lifecycle.md`.
3. Apply the Inheritance Rule: `/auto` supplies startup, cycle, and session-end mechanics; `/steer` supplies only the approval boundary and rollback guards.

The overlay point is exactly:

```
/auto direction-challenger
    ▼
/auto research-planner dispatch writes research/focus.md
    ▼
/steer Plan Checkpoint: backup-aware human approval
    ▼
/auto parse research/focus.md and execute the cycle
```

Apply the Inheritance Rule here. The correct downstream step is always: resume the current `/auto` cycle at its `Parse research/focus.md` step with the approved file.

## Session Start

Run the `/auto` Session Start gates and resume handling from `.claude/skills/auto/SKILL.md` / `auto/phases/session-lifecycle.md`, with these adjustments:

- If Arguments are present, treat them as the user's initial steering intent. Pass them into the next `research-planner` dispatch as additional direction context, not as approval to skip the Plan Checkpoint.
- Before each planner dispatch, take the Planner Pre-Dispatch Snapshot defined below.
- If `research/focus.md` is missing, continue as `/auto` would; the planner may initialise it. A rejected or revised first plan restores the missing state by removing the newly created `research/focus.md` before any planner retry; revision intent is passed only after this rollback, so no unapproved plan becomes the retry baseline.

Maintain the same session-local records `/auto` maintains, including direction-challenge evidence paths, curator summaries, review paths, guide target set, and pending durable review requests. `/steer` may add backup/checkpoint log paths, but those are audit aids and not research authority.

## Planner Pre-Dispatch Snapshot

Before every `research-planner` direction dispatch, create a snapshot that is strong enough to restore the approval boundary without guessing:

1. **Focus state** — record whether `research/focus.md` exists. If it exists, back up its full content to a `.logs/` path. If it is absent, record that absence explicitly.
2. **Research-tree path state** — record `git status --short research` and a complete `research/**` path list before planner dispatch, so created and deleted paths can be identified afterward.
3. **Restorable content state** — for clean tracked files, the pre-dispatch repository blob is the restore source. For all already-dirty tracked files and untracked `research/**` files reported by the pre-dispatch status, back up full content before planner dispatch; do not make the default depend on guessing the planner's possible write scope.
4. **Rollback standard** — after planner dispatch, compare against this snapshot to identify paths changed outside `research/focus.md`. Restore only paths attributable to the unapproved planner attempt. If any planner-touched path cannot be restored to its exact pre-dispatch state without risking unrelated user work, stop before execution and report ambiguous rollback.

## Cycle Loop

For each cycle, follow `/auto` through direction challenge and research-planner dispatch:

1. Run `/auto`'s direction-challenger step unchanged.
2. Before dispatching `research-planner`, take the Planner Pre-Dispatch Snapshot.
3. Dispatch `research-planner` in the normal `/auto` direction mode. It writes `research/focus.md`; do not ask it for `/steer` options or a special checkpoint format.
4. Include in the planner prompt:
   - the ordinary `/auto` direction inputs for this cycle
   - `Human steering intent: {Arguments or latest user revision, or "none"}`
   - `This is a /steer run: write the normal research/focus.md plan. The plan will be shown to the human before execution; do not change output format.`
5. After `research-planner` returns `DONE: research/focus.md`, identify any non-`research/focus.md` tree paths changed by that planner dispatch. Treat them as unapproved planner side effects until the Plan Checkpoint approves the plan. Pause before `/auto` parse/execution and run the Plan Checkpoint below.

If `research-planner` returns `FAILED:`, use `/auto`'s retry/failure handling. Do not run the Plan Checkpoint unless a new `research/focus.md` plan exists. Any `/auto` retry that eventually writes a new `research/focus.md` must re-enter the Plan Checkpoint before parse or execution.

## Plan Checkpoint

The checkpoint exists to let the human evaluate the planner's research judgment, not to manage workers one by one.

### Checkpoint Construction

Construct the checkpoint in the scheduler itself after `research/focus.md` has been written and before any downstream `/auto` step reads it for execution. Do not dispatch a subagent for this presentation step: the human must see the proposed plan in the main conversation, and subagent/session outputs are not a reliable user-visible decision surface.

Read only what is needed to make the proposed plan understandable:

1. `research/focus.md`
2. the direction-challenge file if provided
3. the previous focus backup if needed to explain what changed
4. the current cursor's `state.md`, `map.md`, `plan.md`, `findings.md`, `guide.md`, `sources.md`, `principles.md`, or direct-child summaries only when `research/focus.md` mentions them or when the plan is otherwise not self-contained

Do not deep-read the whole tree. Do not open worker submissions, critic reviews, or raw logs unless `research/focus.md` explicitly cites a path whose meaning is essential to the checkpoint.

The checkpoint must include:

```markdown
## Proposed Plan

### Current Situation
{2-5 sentences that let the human understand the local state without opening research/**. Include the live question, recent relevant result or obstacle, and why this cycle matters.}

### Planner Judgment
{What the planner is deciding: cursor move/stay, main research direction, and the reason this plan is preferred now. Include how it handles the direction challenge or human steering intent when relevant.}

### What This Cycle Will Decide
- {uncertainty, bottleneck, or research-routing risk this cycle is meant to reduce}

### Execution Consequence
- Cursor: `research/{path}/`
- Pre-worker directives: {short faithful summary, or "none"}
- Workers: {short faithful summary, or "none"}
- Tree directives: {short faithful summary, or "none"}
- Blockers: {short faithful summary, or "none"}
- Pending planner side effects: {created/modified paths awaiting approval, or "none"}

### Risk If Wrong
{What execution effort, tree routing, or approval-state cleanup would be affected if this plan is the wrong next step, and where the normal /auto machinery would likely catch that planning problem: critic, curator, durable review, next planner cycle, or human checkpoint. Do not judge whether the scientific claim itself is true.}
```

Do not change the plan while constructing the checkpoint. If the focus file says worker A and tree directive B, the Execution Consequence must preserve A and B. Include unknown or newly added `research/focus.md` sections under Execution Consequence rather than dropping them; `/auto` may evolve, and `/steer` must not silently erase sections it does not understand.

If the plan cannot be made self-contained without reading a large or unclear body of context, restore the previous focus state and roll back unapproved planner side effects, then re-dispatch `research-planner` once with the opacity reason as a clarity failure. This one checkpoint-clarity retry is separate from the human revision retry limit. If the second checkpoint construction also fails, restore the previous focus state and roll back the second unapproved planner attempt before stopping. If that rollback is ambiguous, stop and report the ambiguous paths. Do not run workers from an opaque plan.

### User Checkpoint

Present the checkpoint compactly and ask one approval question with `AskUserQuestion`. The approval request is the human's decision surface, not a mere control prompt. The user-visible checkpoint must be self-contained in the same prompt, tool payload, or ordinary message that asks for the decision; do not rely on earlier progress updates, hidden tool output, subagent/session output, or a previous turn for the actual proposal.

At minimum, the decision surface must include:

- the proposed plan's cursor and scientific judgment in a short faithful summary
- whether workers will run, and which worker consequences matter if any
- the main tree directives or execution consequences that approval would authorize
- pending planner side effects outside `research/focus.md`, or an explicit "none"
- the previous-focus backup / restore consequence so rejection and revision are concrete
- the three possible outcomes below

Before yielding at any checkpoint, write a Checkpoint Resume Record. This is required even when `AskUserQuestion` succeeds, because the next user turn must be able to resume from a durable record rather than hidden tool state. The Checkpoint Resume Record is a timestamped `.logs/` file, preferably from `bash .scripts/log-path.sh steer-checkpoint` when available. If that log type is unavailable, use another timestamped `.logs/` path. It must include: cycle number, current `research/focus.md` proposal state, previous focus backup or absence marker, planner side effects pending approval, checkpoint text or summary, human steering intent, checkpoint-clarity retry count, human revision retry count, and the expected user replies. On the next user turn, read the latest unresolved Checkpoint Resume Record before interpreting `approve`, `revise`, or `reject`, so the decision is applied to the correct proposed plan.

If `AskUserQuestion` is unavailable, rejected by the runtime, or cannot carry the full checkpoint content, fall back to an ordinary user-facing message after writing the Checkpoint Resume Record. The fallback message must contain the same self-contained decision surface and then stop for the user's reply. When yielding the turn at a checkpoint, the last assistant message in that turn must still contain the proposal summary and consequences; never end with only "approve / revise / reject" or equivalent option labels.

- approve and run this plan
- revise the plan with a free-form instruction
- reject and stop before execution

The user may comment on worker choices, but interpret that as revision input for the planner unless it is a purely clerical correction to the displayed plan. The scheduler must not independently redesign the worker plan.

### Outcomes

- **Approve**: leave `research/focus.md` as written by `research-planner`. Resume `/auto` at its `Parse research/focus.md` step and execute the cycle with the current `/auto` mechanics.
- **Revise**: restore the previous focus state, then re-dispatch `research-planner` in normal `/auto` direction mode with the user's revision as `Human steering intent`. If a backup path exists, restore it to `research/focus.md`; if the previous focus state was absent, remove the newly created `research/focus.md`. Also roll back planner-created or planner-modified side-effect paths from this unapproved planner attempt. If any side effect cannot be distinguished from pre-existing user work, stop before execution and report the ambiguous rollback instead of guessing. After the restored state is clean, re-dispatch planner, then construct the checkpoint again. Human revision retries are counted separately from checkpoint-clarity retries; after two human revisions in the same cycle without approval, stop before execution and suggest `/meeting` if the disagreement is conceptual.
- **Reject / stop**: restore the previous focus state using the same backup-or-absence rule and roll back unapproved planner side effects. A plain reject is terminal for the current `/steer` run and means stop before execution; report inline and do not enter Session End, wrap up, commit, or push. If approved cycle(s) already ran and the user explicitly writes that they want to reject this plan and end the session, proceed to `/auto` Session End from the last approved state; the rejected plan itself remains unconsumed.

Approval is the boundary. Before approval, `research/focus.md` is a proposed plan even though it is stored at the normal path. After approval, it becomes the ordinary `/auto` scheduler interface.

## Execution After Approval

After approval, apply the Inheritance Rule. Resume at `/auto`'s current `Parse research/focus.md` step and follow `/auto` until its cycle-end condition is reached. Parse every section the current `/auto` parser expects, including sections added after this `/steer` prompt was written; carry failures, review flags, curator summaries, guide-target bookkeeping, and pending review requests exactly as `/auto` specifies. Loop to the next planning checkpoint while `cycles_done < MAX_CYCLES`, regardless of the `Status` label in `research/focus.md`.

This section is intentionally referential. If it appears less detailed than `/auto`, that is correct: `/auto` is the implementation.

## Session End

Use `/auto`'s current Session End mechanics from `auto/phases/session-lifecycle.md` under the Inheritance Rule.

`/steer` adjustments:

- The final report should include the human-approved plan decisions and any rejected/revised checkpoint attempts that materially changed the run.
- Session logs should identify the run as `steer` where `/auto` allows the scheduler to choose the session kind. Do not fork the session-end protocol to achieve this.
- If a rejected plan was restored and no approved cycle ran afterward, say so plainly and do not imply that worker evidence was produced.

## Failure Handling

- If focus backup or restore fails, stop before execution; do not run a plan whose approval state is ambiguous.
- If rollback of planner-created side effects is ambiguous, stop before execution and report the ambiguous paths. Do not run workers from a plan whose unapproved tree writes may still be present.
- If checkpoint construction fails twice for opacity, stop before execution and report the presentation failure.
- If the user revises twice in the same cycle without approval, stop before execution and recommend resolving the disagreement in `/meeting`.
- Once a plan is approved, use `/auto` failure handling for workers, critic, curator, durable reviews, guide-writer, session-wrap-up, commit, and push.
