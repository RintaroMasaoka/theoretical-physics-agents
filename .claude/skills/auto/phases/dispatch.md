# Phase: Dispatch

This phase file is a reference that `/auto` Reads when launching workers and critic, and when dispatching curator. It covers the two allowed launch patterns, the prompt template, the auto-critic rule, and agent-specific dynamic data.

---

## Launch Patterns

Use only the two patterns below. Never `Bash("sleep ...")` or `Bash("ls ...")` to poll for completion.

### Pattern A — Foreground Parallel (default)


Call multiple `Agent` tools in a single message without `run_in_background=true`. All tasks execute in parallel and the scheduler blocks until every one completes.


```

Agent(prompt="...", subagent_type="researcher")   ─┐
Agent(prompt="...", subagent_type="researcher")   ─┼─ Parallel, auto-block
Agent(prompt="...", subagent_type="simulator")    ─┘

```

This is the default for the Worker Dispatch step and for Auto-Critic.

### Pattern B — Background + Continued Work


Launch with `run_in_background=true`; the scheduler continues other work, and the system notifies on completion. Retrieve via `TaskOutput`.

```
Agent(prompt="...", subagent_type="researcher", run_in_background=true) → task_id
{scheduler continues with other independent work}
← System notification
TaskOutput(task_id=task_id, block=true)
```


Use Pattern B only when the scheduler genuinely has independent work to do in parallel — a rare case in the thin scheduler (Pattern A is usually sufficient because the scheduler's next step depends on the workers' outputs).

## Prompt Template

Each agent is defined in `.claude/agents/{agent}.md`.

Invoke it with `subagent_type="{name}"`. The scheduler's prompt contains only task-specific information — the agent's own definition carries the reading protocol, deliverable format, and operating rules.


```

## Task
{task description — filled in from research planner's focus.md § Worker Dispatches entry}

## Context
Cursor: research/{path}/
{any additional context from research planner's Worker Dispatch entry — kind, previous attempt path, specific sub-problem, etc.}
```

### Agent-Specific Dynamic Data

Each entry is what the scheduler extracts from research planner's `### Worker Dispatches` and shapes into the Task / Context block:

- **scout**: direction to survey (a topic phrase, not an arXiv ID)
- **reader**: `Assigned paper: arXiv:{id}` + `Title: {title}` + `Extraction scope: {source-native definitions / equations / conventions / sections to inspect}`. Do not pass project relevance or proposed use
- **researcher**: `Target: research/{path}/ — {one-line description}` + `kind: {kind}` + `Context: {role within parent's children decomposition}`. On resubmission: previous attempt path + critic's critique path.
- **simulator**: `Target: research/{path}/` + `Physical setup` + `Mathematical definition of observables` + `Success criteria` + `Deliverable number: {N}` + `research/lib/ module list` + `Existing scripts in src/: {list}`
- **engine-builder**: `Model definition` + `Computational method` + `Required features` + existing module path. Or `"Refine lib"` for self-directed improvement.
- **concept-checker**: Document path to read + focus area for concept extraction.
- **self-check**: Target file path (a note.md or plan.md) + what to check for.

The research planner's focus.md entries are written concretely enough that these fields can be extracted mechanically. If a required field listed above cannot be extracted (e.g., a researcher entry with no `Target: research/{path}/` line, or a simulator entry missing the `Deliverable number`), the scheduler re-dispatches research planner once, echoing the exact missing field(s); it does not "decide" whether an entry looks underspecified — structural field-absence is the only trigger. If the second attempt is still missing fields, exit to Session End.

## Auto-Critic Rule

"Worker" here means the execution-tier agents listed in the Worker row of `.claude/CLAUDE.md` (researcher / simulator / reader / scout / engine-builder / concept-checker / self-check). Direction-support agents (`direction-challenger`) and scheduler-owned agents (`curator`, `session-wrap-up`) are not workers and receive no auto-critic — the challenger's narrow opposition format and research planner's required response are its integrity mechanism.

Every worker deliverable returned from Cycle step 4 is critiqued by a critic dispatch in Cycle step 5 — this is automatic, not something research planner requests. The rule is fixed:

- **Target**: A (worker deliverable inline annotation) — the critic annotates the worker's deliverable file directly.
- **Mode**: blind by default for deliverables whose soundness is mechanical/mathematical (researcher attempts that prove / compute / derive, simulator runs, engine-builder module tests). Source-audit for reader deliverables, because the question is fidelity to the paper rather than fit to the project. Contextual for deliverables whose soundness depends on the research narrative (scout surveys, concept proposals). The mode selection rule:

  | Worker | Deliverable type | Default critic mode |
  |---|---|---|
  | researcher | `attempt` | blind (default). Research planner may override to contextual in the dispatch entry by writing `mode: contextual` — only then does the scheduler switch |
  | simulator | `simulation` | blind |
  | engine-builder | `engine` | blind |
  | reader | `reading` | source-audit |
  | scout | `survey` | contextual |
  | concept-checker | `concept` proposal in `.logs/` | contextual |
  | self-check | `review` | (no critic — self-check is itself a review) |

  The rule of thumb matches critic's own: *"What is the target faithful to?" — internal mathematics → blind; source text → source-audit; research narrative → contextual.*

- **Dispatch in parallel** with the worker deliverables already in hand: one critic call per deliverable, all launched together in a single message (Pattern A). Critic reads only the context allowed by its mode: target file plus paper/source-note files for source-audit, target file plus ancestor chain for contextual, and target file only for blind.

- **No-critic exceptions.** Research planner may mark a worker dispatch as `no-critic` in focus.md § Worker Dispatches — legitimate for engine-builder refactors with no substantive claim, or for exploratory scout surveys where the deliverable is framed as "what exists, not what is true". Honour the marking. All other deliverables receive auto-critic.

The scheduler does not read critic's output before proceeding to curator — critic writes the verdict inline into the deliverable (Target A), and curator reads both the deliverable and its inline critique together when it runs in Cycle step 6. This is the critic-before-record guarantee: no worker deliverable enters the tree (via curator's lift) without having been independently reviewed.

## Critic on note.md (Target B) — NOT scheduler-dispatched

The scheduler never dispatches critic on a note.md directly. That second-order dispatch is curator's internal step: after lifting a derivation into note.md, curator dispatches critic with Target B (separate critique file, not inline annotation). See `.claude/agents/curator.md` § note.md critic layering.

## Curator Dispatch Input

The scheduler passes curator a structured prompt containing **research planner's directives** and **this cycle's evidence**. Curator does not re-discover what changed; the scheduler states it:

```
## Task
Execute the tree directives below and absorb the new evidence into the tree per your own operating rules.

## Tree Directives (from research planner, this cycle)
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

The scheduler does not enumerate "subnodes without note.md" / "state.md files over 150 lines" / etc. on every cycle — that is curator's own scanning responsibility. The scheduler only reports *what happened this cycle* (directives, evidence, cursor). Curator decides what to change based on its own state of the tree.

Exception — session-end sweep: the scheduler still does not enumerate candidates; curator's own default-create / compress / staleness rules fire automatically when `Session-end sweep: true`.

## Re-dispatch on Critic REVISE / REJECT

Curator's output includes flags for deliverables whose critic verdict was REVISE or REJECT. The scheduler does NOT auto-re-dispatch the worker. The flagged deliverables are surfaced to direction-challenger and research planner in the next cycle's prompts; research planner decides:

- *Re-dispatch the worker* — include a new Worker Dispatch entry citing the previous attempt path + critic file (researcher resubmission pattern).
- *Pivot direction* — the critic's REJECT exposed that the question was wrong; research planner reframes in `## Context` and issues a different direction.
- *Close and move on* — research planner issues a Tree Directive to close the node; curator executes.

Worker resubmission is thus research planner-directed, not scheduler-automatic. This ensures the research direction can redirect when a critic verdict reveals a deeper problem than "the attempt had a bug".
