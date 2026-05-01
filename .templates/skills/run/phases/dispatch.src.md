# Phase: Dispatch

This phase file is a reference that `/run` Reads when launching workers and critic, and when dispatching curator. It covers the two allowed launch patterns, the prompt template, the auto-critic rule, and agent-specific dynamic data.

---

## Launch Patterns

Use only the two patterns below. Never `{{ runtime.tool_shell }}("sleep ...")` or `{{ runtime.tool_shell }}("ls ...")` to poll for completion.

### Pattern A — Foreground Parallel (default)

{{#if runtime.is_claude}}
Call multiple `{{ runtime.tool_agent }}` tools in a single message without `run_in_background=true`. All tasks execute in parallel and the scheduler blocks until every one completes.
{{else}}
Call multiple `{{ runtime.tool_agent }}` tools in a single message using the normal dispatch form. All tasks execute in parallel and the scheduler blocks until every one completes.
{{/if}}

```
{{ runtime.tool_agent }}(prompt="...", {{ runtime.tool_agent_type_field }}="researcher")   ─┐
{{ runtime.tool_agent }}(prompt="...", {{ runtime.tool_agent_type_field }}="researcher")   ─┼─ Parallel, auto-block
{{ runtime.tool_agent }}(prompt="...", {{ runtime.tool_agent_type_field }}="simulator")    ─┘
```

This is the default for the Worker Dispatch step and for Auto-Critic.

### Pattern B — Background + Continued Work

{{#if runtime.is_claude}}
Launch with `run_in_background=true`; the scheduler continues other work, and the system notifies on completion. Retrieve via `{{ runtime.tool_task_wait }}`.

```
{{ runtime.tool_agent }}(prompt="...", {{ runtime.tool_agent_type_field }}="researcher"{{ runtime.agent_background_arg }}) → {{ runtime.agent_task_id_name }}
{scheduler continues with other independent work}
← System notification
{{ runtime.agent_wait_example }}
```
{{else}}
Launch normally and capture the returned agent id; the scheduler continues other work, and the system notifies on completion. Retrieve via `{{ runtime.tool_task_wait }}`.

```
{{ runtime.tool_agent }}(prompt="...", {{ runtime.tool_agent_type_field }}="researcher") → {{ runtime.agent_task_id_name }}
{scheduler continues with other independent work}
← System notification
{{ runtime.agent_wait_example }}
```
{{/if}}

Use Pattern B only when the scheduler genuinely has independent work to do in parallel — a rare case in the thin scheduler (Pattern A is usually sufficient because the scheduler's next step depends on the workers' outputs).

## Prompt Template

Each agent is defined in `{{ runtime.agents_dir }}/{agent}.md` and invoked with `{{ runtime.tool_agent_type_field }}="{name}"`. The scheduler's prompt contains only task-specific information — the agent's own definition carries the reading protocol, deliverable format, and operating rules.

```
## Task
{task description — filled in from physicist's focus.md § Worker Dispatches entry}

## Context
Cursor: research/{path}/
{any additional context from physicist's Worker Dispatch entry — kind, previous attempt path, specific sub-problem, etc.}
```

### Agent-Specific Dynamic Data

Each entry is what the scheduler extracts from physicist's `### Worker Dispatches` and shapes into the Task / Context block:

- **scout**: direction to survey (a topic phrase, not an arXiv ID)
- **reader**: `Assigned paper: arXiv:{id}` + `Title: {title}` + what to extract
- **researcher**: `Target: research/{path}/ — {one-line description}` + `kind: {kind}` + `Context: {role within parent's children decomposition}`. On resubmission: previous attempt path + critic's critique path.
- **simulator**: `Target: research/{path}/` + `Physical setup` + `Mathematical definition of observables` + `Success criteria` + `Deliverable number: {N}` + `research/lib/ module list` + `Existing scripts in src/: {list}`
- **engine-builder**: `Model definition` + `Computational method` + `Required features` + existing module path. Or `"Refine lib"` for self-directed improvement.
- **concept-checker**: Document path to read + focus area for concept extraction.
- **self-check**: Target file path (a note.md or plan.md) + what to check for.

The physicist's focus.md entries are written concretely enough that these fields can be extracted mechanically. If a required field listed above cannot be extracted (e.g., a researcher entry with no `Target: research/{path}/` line, or a simulator entry missing the `Deliverable number`), the scheduler re-dispatches physicist once, echoing the exact missing field(s); it does not "decide" whether an entry looks underspecified — structural field-absence is the only trigger. If the second attempt is still missing fields, exit to Session End.

## Auto-Critic Rule

"Worker" here means the execution-tier agents listed in the Worker row of `{{ runtime.instruction_file }}` (researcher / simulator / reader / scout / engine-builder / concept-checker / self-check). Direction-support agents (`direction-auditor`) and scheduler-owned agents (`curator`, `session-wrap-up`) are not workers and receive no auto-critic — the auditor's narrow question format and physicist's required response are its integrity mechanism.

Every worker deliverable returned from Cycle step 4 is critiqued by a critic dispatch in Cycle step 5 — this is automatic, not something physicist requests. The rule is fixed:

- **Target**: A (attempt file inline annotation) — the critic annotates the worker's deliverable file directly.
- **Mode**: blind by default for deliverables whose soundness is mechanical/mathematical (researcher attempts that prove / compute / derive, simulator runs, engine-builder module tests). Contextual for deliverables whose soundness depends on the research narrative (reader summaries, scout surveys, self-check reports). The mode selection rule:

  | Worker | Deliverable type | Default critic mode |
  |---|---|---|
  | researcher | `attempt` | blind (default). Physicist may override to contextual in the dispatch entry by writing `mode: contextual` — only then does the scheduler switch |
  | simulator | `simulation` | blind |
  | engine-builder | `engine` | blind |
  | reader | `reading` | contextual |
  | scout | `survey` | contextual |
  | concept-checker | `concepts/*.md` edits | contextual |
  | self-check | `review` | (no critic — self-check is itself a review) |

  The rule of thumb matches critic's own: *"Does the critic need to know the research purpose?" — No → blind, Yes → contextual.*

- **Dispatch in parallel** with the worker deliverables already in hand: one critic call per deliverable, all launched together in a single message (Pattern A). Critic reads only its target file plus (contextual mode) the ancestor chain.

- **No-critic exceptions.** Physicist may mark a worker dispatch as `no-critic` in focus.md § Worker Dispatches — legitimate for engine-builder refactors with no substantive claim, or for exploratory scout surveys where the deliverable is framed as "what exists, not what is true". Honour the marking. All other deliverables receive auto-critic.

The scheduler does not read critic's output before proceeding to curator — critic writes the verdict inline into the deliverable (Target A), and curator reads both the deliverable and its inline critique together when it runs in Cycle step 6. This is the critic-before-record guarantee: no worker deliverable enters the tree (via curator's lift) without having been independently reviewed.

## Critic on note.md (Target B) — NOT scheduler-dispatched

The scheduler never dispatches critic on a note.md directly. That second-order dispatch is curator's internal step: after lifting a derivation into note.md, curator dispatches critic with Target B (separate critique file, not inline annotation). See `{{ runtime.agents_dir }}/curator.md` § note.md critic layering.

## Curator Dispatch Input

The scheduler passes curator a structured prompt containing **physicist's directives** and **this cycle's evidence**. Curator does not re-discover what changed; the scheduler states it:

```
## Task
Execute the tree directives below and absorb the new evidence into the tree per your own operating rules.

## Tree Directives (from physicist, this cycle)
{verbatim copy of research/focus.md § Tree Directives — each line is an imperative curator should apply}

## New Evidence This Cycle
- {deliverable path} — critic: {ACCEPT / REVISE / REJECT}, critic verdict in same file's end section
- {deliverable path} — critic: ...
- ({blank if no worker dispatches this cycle — structural-review cycle})

## Context
Cursor: research/{path}/
Session cycle: {n} of {N}
Session-end sweep: {true | false}
```

Set `Session-end sweep: true` only on the final dispatch (session-end step 2). Curator reads this flag and performs the tree-wide coherence pass required at session boundaries.

The scheduler does not enumerate "subnodes without note.md" / ".log.md files over 150 lines" / etc. on every cycle — that is curator's own scanning responsibility. The scheduler only reports *what happened this cycle* (directives, evidence, cursor). Curator decides what to change based on its own state of the tree.

Exception — session-end sweep: the scheduler still does not enumerate candidates; curator's own default-create / compress / staleness rules fire automatically when `Session-end sweep: true`.

## Re-dispatch on Critic REVISE / REJECT

Curator's output includes flags for deliverables whose critic verdict was REVISE or REJECT. The scheduler does NOT auto-re-dispatch the worker. The flagged deliverables are surfaced to direction-auditor and physicist in the next cycle's prompts; physicist decides:

- *Re-dispatch the worker* — include a new Worker Dispatch entry citing the previous attempt path + critic file (researcher resubmission pattern).
- *Pivot direction* — the critic's REJECT exposed that the question was wrong; physicist reframes in `## Context` and issues a different direction.
- *Close and move on* — physicist issues a Tree Directive to close the node; curator executes.

Worker resubmission is thus physicist-directed, not scheduler-automatic. This ensures the research direction can redirect when a critic verdict reveals a deeper problem than "the attempt had a bug".
