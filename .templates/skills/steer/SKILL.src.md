---
name: steer
description: "Run one human-steered research cycle: present direction options, accept the user's steering decision, then execute workers, critic, curator, and wrap-up semi-automatically."
user-invocable: true
argument-hint: "[steering intent (optional)]"
---

# /steer — Human-Steered Research Cycle

Arguments: $ARGUMENTS

---

`/steer` runs **one** research cycle with the human researcher owning the cycle-start direction decision. It is the interactive sibling of `/auto`: `/auto` delegates direction choice to `research-planner` and keeps moving across cycles; `/steer` pauses at the start, turns the current research state into a small set of concrete direction options, asks the user to choose or modify one, then executes the selected cycle with the same worker / critic / curator machinery as `/auto`.

The point is not manual worker management. Worker dispatches are an implementation of a research direction. The user's job is to steer the scientific question, priority, and framing; the scheduler's job is to translate that steering into a dispatch plan and run the mechanical orchestration.

## Constraints

- **Write all prose in {{ language }}.** Applies to conversational text, questions, `_reviews/`, `.logs/`, `research/focus.md`, curator tree writes, worker submissions, and commit messages. Technical terms, proper nouns, LaTeX mathematics, file/folder slugs, frontmatter keys, and documented structural headings may stay in English.
- When dispatching any subagent from `/steer`, include the active language requirement in the task-specific prompt so downstream submissions and outputs follow the same prose language. The skill's language contract is not satisfied by the scheduler's own messages alone.
- `/steer` is interactive only at the **Steering Gate**. After the user approves a direction, do not ask further worker-management questions unless execution becomes structurally impossible.
- Run exactly one cycle. Do not loop into a second cycle; end with a concise report and leave the next direction for a later `/steer`, `/auto`, or `/meeting`.
- Acquire new full-paper text only from arXiv, to keep provenance reproducible and avoid ingesting unverified copies. Metadata or citation checks may still use other sources when needed.
- **Paper writing is NOT `/steer`'s responsibility.** Writing is handled by `/write`.

## Relationship To Other Skills

| Skill | Human role | Execution style |
|---|---|---|
| `/auto N` | Human sets broad direction outside the run; AI chooses each cycle's next direction | autonomous, multi-cycle |
| `/steer` | Human chooses or revises the next cycle direction at cycle start | interactive gate, then one semi-automatic cycle |
| `/meeting` | Human interrogates direction, verification honesty, and understanding, then records oversight decisions outside execution | live review and recording |

`/steer` may use meeting-like judgment, but it is not a meeting. It does not approve `findings.md` for manuscript use. It injects human research judgment into the next executable cycle.

## Phase References

Reuse `/auto`'s mechanics rather than duplicating them:

| File | Loaded when | Purpose |
|---|---|---|
| `{{ runtime.skills_dir }}/auto/phases/dispatch.md` | After the Steering Gate, when launching workers and critic | Pattern A / B launch methods, prompt template, auto-critic rule, per-agent dynamic data |
| `{{ runtime.skills_dir }}/auto/phases/session-lifecycle.md` | For sanity checks and Session End mechanics | Initial gates, final curator sweep, research planner wrap-up input, `session-wrap-up` handoff |

The research information model is canonical in `{{ runtime.research_tree_file }}`. `/steer` reads enough of the tree to present direction options; workers, critic, curator, and research planner keep their normal ownership boundaries.

---

## Flow

```
Session Start
    ▼ Load current research state and recent execution context
    ▼ Direction-challenger writes pre-direction opposition
    ▼ Research planner drafts 2-4 steering options, not a final focus.md
    ▼ Steering Gate: user chooses, combines, or modifies a direction
    ▼ Scheduler writes research/focus.md from the approved steering decision
    ▼ Worker dispatch → critic auto-attach → curator absorption
    ▼ Session End: final curator sweep → research planner wrap-up → session-wrap-up
    ▼ Final report to user
```

## Session Start

Perform the following `/steer` sanity gates, adapted from `/auto`:

- `research/state.md` must exist; if missing, tell the user to run `/launch` first and stop.
- `concepts/` exists.
- `.gitignore` covers `.logs/.auto-active`; `/steer` does not normally write that beacon, but the shared finalizer expects the active-run beacon to be ignored.
- If `research/focus.md` is missing, continue; the approved steering decision will initialise it.

Load only the state needed to explain the next decision:

- `research/state.md`
- `research/focus.md` if present
- `research/story.md` if present
- `research/principles.md` if present (active research judgment principles)
- `.logs/last_session.md` if present
- `agenda.md` if present
- top-level `research/*/state.md` files, and node-level files only when needed to make a candidate direction intelligible

If Arguments are present, treat them as the user's initial steering intent. They constrain the option-generation step, but they are not approval to skip the Steering Gate.

## 1. Direction-Challenger Dispatch

Dispatch `direction-challenger` before option generation, as in `/auto`. Its role is still opposition: it challenges inertia, value, scope, authority, and frame before the direction hardens.

```
{{#if runtime.is_codex}}
{{ runtime.tool_agent }}(prompt="""
Read and follow `{{ runtime.agents_dir }}/direction-challenger.md` as your role definition. Treat the rest of this prompt as task-specific input.

## Task
Write the pre-direction challenge for this `/steer` cycle. Obtain a path via `bash .scripts/log-path.sh direction-challenge` and return it as `DONE: {path}`.
{{else}}
{{ runtime.tool_agent }}({{ runtime.tool_agent_type_field }}="direction-challenger", prompt="""
## Task
Write the pre-direction challenge for this `/steer` cycle. Obtain a path via `bash .scripts/log-path.sh direction-challenge` and return it as `DONE: {path}`.
{{/if}}

## Context
Steering intent from user: {Arguments, or "none"}
Current focus summary: {brief summary of research/focus.md if present}
Recent agenda / last session: {brief summary or paths}
""")
```

If the challenger fails, continue with `Direction Challenge: unavailable — {failure}`. The challenge is useful input, not a blocker.

## 2. Steering Option Generation

Ask `research-planner` for **options**, not an update to `research/focus.md`. The planner should read the tree and return a short option packet to the scheduler, without writing files.

Before dispatching research planner, run `node .scripts/literature-status.mjs --limit=8` if `literature/catalog.jsonl` exists. Pass the output verbatim in `## Literature Status`.

```
{{#if runtime.is_codex}}
{{ runtime.tool_agent }}(prompt="""
Read and follow `{{ runtime.agents_dir }}/research-planner.md` as your role definition. Treat the rest of this prompt as task-specific input.

## Task
Draft 2-4 steering options for one `/steer` cycle. Do not edit research/focus.md. Return the option packet inline.
{{else}}
{{ runtime.tool_agent }}({{ runtime.tool_agent_type_field }}="research-planner", prompt="""
## Task
Draft 2-4 steering options for one `/steer` cycle. Do not edit research/focus.md. Return the option packet inline.
{{/if}}

## Required Option Format
For each option:
- Direction: the research question or strategic move
- Why now: what makes it valuable at the current state
- What it would test or reduce: uncertainty / risk / bottleneck
- Worker plan: concrete worker dispatches likely needed, with agents named
- Tree effect: likely tree directive(s) curator would receive
- Failure meaning: what we learn if the attempt fails or critic rejects it

## Inputs
Steering intent from user: {Arguments, or "none"}
Direction Challenge: {path returned by direction-challenger, or unavailable note}
Current research state summary: {paths / concise summary loaded at Session Start}
Literature Status: {output, or "No literature catalog present"}
""")
```

If the option packet is vague, over-focused on worker names, or lacks scientific tradeoffs, re-dispatch once asking for the missing fields. Do not compensate by inventing the options silently; the value of `/steer` is the visible decision surface.

## 3. Steering Gate

Present the option packet to the user in compact form. Do not paste large research files into chat. Make clear that the user is choosing the **research direction**, not managing workers.

Use `{{ runtime.tool_ask_user_question }}` with one question:

- Ask which direction to run for this cycle, allowing the user to choose an option, combine options, or provide a modification.
- Keep options short enough to compare. Include the worker plan only as the execution consequence of each direction.

If the user gives a modification, interpret it as a steering decision and restate the resulting direction once. If the restatement changes the substance, ask for confirmation. If the user selects cleanly, proceed.

Do not ask the user to approve each worker. Worker choices can be lightly corrected by the user, but the scheduler owns translating the approved direction into a coherent dispatch plan.

## 4. Materialize `research/focus.md`

Write the approved steering decision into `research/focus.md` in the normal scheduler interface shape:

```markdown
# Focus

Cursor: research/{path}/
Status: active

## Context
{2-5 sentences: current state, user-approved steering decision, and why this direction now}

## Direction Challenge Response
- Human steering: {user-approved direction; include how it accepts/rejects/overrides the direction challenge if relevant}

## Next Session

### Worker Dispatches
- **{agent}**: {concrete task}

### Tree Directives
- {directive for curator}

### Blockers
{blocker, or empty}
```

The steering record is not meeting approval or manuscript authorization. It is durable execution rationale for the next agents.

If the approved direction requires no worker dispatches and only tree maintenance, write an empty Worker Dispatches section and concrete Tree Directives. A structural-review cycle is legitimate.

## 5. Execute One Cycle

From this point, follow `/auto`'s Cycle Loop steps 3-6 for exactly one cycle:

1. Parse `research/focus.md`
2. Launch Worker Dispatches in parallel using `{{ runtime.skills_dir }}/auto/phases/dispatch.md`
3. Auto-attach critic to every review-eligible worker submission per the Provisional Review Rule
4. Dispatch curator once with the Tree Directives and the new evidence

If the approved steering decision is explicitly a no-op or session-close decision, materialize `Status: session_complete`, skip worker dispatch, and proceed to Session End. Otherwise materialize `Status: active`.

## 6. Session End

Follow `/auto`'s Session End mechanics with these `/steer` adjustments:

1. Run the final curator sweep.
2. Dispatch research planner in session-end mode to write the wrap-up-input file.
3. Dispatch `session-wrap-up` with the wrap-up-input path.
4. Tell the user what direction was chosen, what ran, what curator recorded, and what should be considered next.

Session logs should use `bash .scripts/log-path.sh steer` when the scheduler itself writes a steering log. The normal `session-wrap-up` session log may still use its own configured log type.

## Failure Handling

- If a worker fails, continue to critic / curator with the failure path or failure note when possible; curator and the next planner need to see the failed attempt.
- If critic returns `REVISE-BLOCKING`, `OPAQUE`, or `REJECT`, do not auto-resubmit beyond the one repair loop allowed by `/auto` dispatch rules. Curator records the flag, and the next `/steer` or `/auto` decides whether to retry, pivot, or close.
- If curator fails once, re-dispatch once with the failure message appended. If it fails again, end with a partial report and leave `_reviews/` transactions and raw `.logs/` untouched.
- If `session-wrap-up` fails, report the failure and the files that still need manual finalization.
