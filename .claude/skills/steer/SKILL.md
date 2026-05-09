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

This structure is load-bearing. `/auto` owns the evolving execution machinery: direction challenge, planner dispatch, focus parsing, presentation boundaries, pre-worker readiness, worker dispatch, Provisional Review, repair loops, curator absorption, Durable Surface Review, guide-writer, session end, wrap-up, commit, and push. `/steer` must not copy those mechanics. It reads and follows the current `/auto` skill and phase files, then inserts only the human checkpoint between planning and execution.

The human is not replacing `research-planner`. `research-planner` still makes the scientific plan in the normal `/auto` `research/focus.md` schema. The human checks whether that plan matches their research judgment before any worker, critic, curator, or session-end action consumes it.

## Constraints

- **Write all prose in japanese.** Applies to conversational text, checkpoint questions, `_reviews/`, `.logs/`, `research/focus.md`, curator tree writes, worker submissions, presenter output, and commit messages. Technical terms, proper nouns, LaTeX mathematics, file/folder slugs, frontmatter keys, and documented structural headings may stay in English.
- Before running, read `.claude/skills/auto/SKILL.md` and the phase files it references. Treat them as the source of truth for every scheduler action not explicitly overridden here.
- The only `/auto` rule overridden by `/steer` is the prohibition on user input during planning. `/steer` may ask the user at the Plan Checkpoint after `research-planner` updates `research/focus.md` and before execution begins. Do not ask user-management questions during worker dispatch, review, curation, durable review, guide writing, or session end. If execution becomes structurally impossible outside the checkpoint, stop and report the structural blocker rather than opening a new decision gate.
- Do not maintain a separate `/steer` cycle implementation. If `/auto` changes a phase, `/steer` inherits that change by reading and following `/auto`.
- `/steer` uses the same cycle limit semantics as `/auto` (`MAX_CYCLES`, `Status: session_complete`, and session-end behavior). It is not forced to one cycle.
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
3. Apply the `/auto` startup, cycle, and session-end rules unless this file explicitly says otherwise.

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

Do not re-describe `/auto`'s downstream steps in `/steer`. The correct downstream step is always: resume the current `/auto` cycle at its `Parse research/focus.md` step with the approved file.

## Session Start

Run the `/auto` Session Start gates and resume handling from `.claude/skills/auto/SKILL.md` / `auto/phases/session-lifecycle.md`, with these adjustments:

- If Arguments are present, treat them as the user's initial steering intent. Pass them into the next `research-planner` dispatch as additional direction context, not as approval to skip the Plan Checkpoint.
- Before each planner dispatch, record whether `research/focus.md` exists and, if it does, record its content or a backup path so a rejected plan can be restored mechanically. If it does not exist, record the absence explicitly.
- Before each planner dispatch, also record enough pre-dispatch tree state to identify files or directories created or modified by that single planner call. This is only for rollback of unapproved planner side effects such as minimal child-node creation. Do not use it to revert unrelated pre-existing user changes.
- If `research/focus.md` is missing, continue as `/auto` would; the planner may initialise it. A rejected first plan restores the missing state by removing the newly created `research/focus.md` unless the user supplies a revision intent for planner retry.

Maintain the same session-local records `/auto` maintains, including direction-challenge evidence paths, curator summaries, review paths, guide target set, and pending durable review requests. `/steer` may add backup/checkpoint log paths, but those are audit aids and not research authority.

## Cycle Loop

For each cycle, follow `/auto` through direction challenge and research-planner dispatch:

1. Run `/auto`'s direction-challenger step unchanged.
2. Before dispatching `research-planner`, back up the current `research/focus.md` if it exists and record whether it was absent. Use a `.logs/` path, for example from `bash .scripts/log-path.sh steer-focus-before`, or another timestamped `.logs/` path if that log type is unavailable. Also record the pre-dispatch state of `research/**` well enough to distinguish planner-created or planner-modified paths from unrelated dirty files.
3. Dispatch `research-planner` in the normal `/auto` direction mode. It writes `research/focus.md`; do not ask it for `/steer` options or a special presenter format.
4. Include in the planner prompt:
   - the ordinary `/auto` direction inputs for this cycle
   - `Human steering intent: {Arguments or latest user revision, or "none"}`
   - `This is a /steer run: write the normal research/focus.md plan. The plan will be shown to the human before execution; do not change output format.`
5. After `research-planner` returns `DONE: research/focus.md`, identify any non-`research/focus.md` tree paths changed by that planner dispatch. Treat them as unapproved planner side effects until the Plan Checkpoint approves the plan. Pause before `/auto` parse/execution and run the Plan Checkpoint below.

If `research-planner` returns `FAILED:`, use `/auto`'s retry/failure handling. Do not run the Plan Checkpoint unless a new `research/focus.md` plan exists.

## Plan Checkpoint

The checkpoint exists to let the human evaluate the planner's research judgment, not to manage workers one by one.

### Presenter Dispatch

Dispatch `research-plan-presenter` after `research/focus.md` has been written and before any downstream `/auto` step reads it for execution.

```

Agent(subagent_type="research-plan-presenter", prompt="""
## Task
Present the proposed `research/focus.md` plan as a self-contained human checkpoint. Do not change `research/focus.md` or any research-tree file. Return the checkpoint inline.


## Inputs
Proposed plan: research/focus.md
Previous focus backup: {backup path, or "none"}
Planner side effects pending approval: {created/modified paths outside research/focus.md, or "none"}
Human steering intent: {Arguments or latest user revision, or "none"}
Direction challenge: {path returned by direction-challenger, or unavailable note}
Cycle: {cycle_number} of {MAX_CYCLES}
""")
```

If the presenter returns `FAILED: plan not self-contained enough to present — {reason}`, restore the previous focus state and roll back unapproved planner side effects, then re-dispatch `research-planner` once with the presenter's reason as a clarity failure. If the second presenter attempt also fails, stop before execution and report the failure; do not run workers from an opaque plan.

### User Checkpoint

Present the checkpoint compactly and ask one approval question with `AskUserQuestion`:

- approve and run this plan
- revise the plan with a free-form instruction
- reject and stop before execution

The user may comment on worker choices, but interpret that as revision input for the planner unless it is a purely clerical correction to the displayed plan. The scheduler must not independently redesign the worker plan.

### Outcomes

- **Approve**: leave `research/focus.md` as written by `research-planner`. Resume `/auto` at its `Parse research/focus.md` step and execute the cycle with the current `/auto` mechanics.
- **Revise**: restore the previous focus state, then re-dispatch `research-planner` in normal `/auto` direction mode with the user's revision as `Human steering intent`. If a backup path exists, restore it to `research/focus.md`; if the previous focus state was absent, remove the newly created `research/focus.md`. Also roll back planner-created or planner-modified side-effect paths from this unapproved planner attempt. If any side effect cannot be distinguished from pre-existing user work, stop before execution and report the ambiguous rollback instead of guessing. After the restored state is clean, re-dispatch planner, then run presenter and checkpoint again. Limit retries to prevent an endless planning conversation; after two rejected revisions in the same cycle, stop before execution and suggest `/meeting` if the disagreement is conceptual.
- **Reject / stop**: restore the previous focus state using the same backup-or-absence rule and roll back unapproved planner side effects. Proceed to `/auto` Session End only if the user asked to end and the tree state still needs mechanical finalisation; otherwise stop without worker, critic, curator, guide-writer, or wrap-up actions from the rejected plan.

Approval is the boundary. Before approval, `research/focus.md` is a proposed plan even though it is stored at the normal path. After approval, it becomes the ordinary `/auto` scheduler interface.

## Execution After Approval

After approval, do not use `/steer`-specific execution instructions. Continue with `/auto`'s current Cycle Loop from `Parse research/focus.md` through Cycle End:

- parse every section the current `/auto` parser expects, including sections added after this `/steer` prompt was written
- run presentation-boundary, pre-worker readiness, worker, critic, curator, durable-review, and guide-target bookkeeping exactly as `/auto` specifies
- carry failures, review flags, curator summaries, and pending durable-review requests exactly as `/auto` specifies
- loop to the next planning checkpoint while `cycles_done < MAX_CYCLES` and `Status` remains `active`

This section is intentionally referential. If it appears less detailed than `/auto`, that is correct: `/auto` is the implementation.

## Session End

Use `/auto`'s current Session End mechanics from `auto/phases/session-lifecycle.md`, including final curator sweep, pending Durable Surface Review drain, guide-writer sweep, final research-planner session-end dispatch, `session-wrap-up`, commit, push, and final user summary.

`/steer` adjustments:

- The final report should include the human-approved plan decisions and any rejected/revised checkpoint attempts that materially changed the run.
- Session logs should identify the run as `steer` where `/auto` allows the scheduler to choose the session kind. Do not fork the session-end protocol to achieve this.
- If a rejected plan was restored and no approved cycle ran afterward, say so plainly and do not imply that worker evidence was produced.

## Failure Handling

- If focus backup or restore fails, stop before execution; do not run a plan whose approval state is ambiguous.
- If rollback of planner-created side effects is ambiguous, stop before execution and report the ambiguous paths. Do not run workers from a plan whose unapproved tree writes may still be present.
- If the presenter fails twice for opacity, stop before execution and report the presentation failure.
- If the user revises twice in the same cycle without approval, stop before execution and recommend resolving the disagreement in `/meeting`.
- Once a plan is approved, use `/auto` failure handling for workers, critic, curator, durable reviews, guide-writer, session-wrap-up, commit, and push.
