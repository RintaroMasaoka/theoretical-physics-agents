# Phase: Dispatch

This phase file is a reference that `/run` Reads when launching workers and critic, and when dispatching curator. It covers the two allowed launch patterns, the prompt template, the auto-critic rule, and agent-specific dynamic data.

---

## Launch Patterns

Use only the two patterns below. Never `Bash("sleep ...")` or `Bash("ls ...")` to poll for completion.

### Pattern A — Foreground Parallel (default)

Call multiple `Agent` tools in a single message without `run_in_background`. All tasks execute in parallel and the scheduler blocks until every one completes.

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

Each agent is defined in `.claude/agents/{agent}.md` and invoked with `subagent_type="{name}"`. The scheduler's prompt contains only task-specific information — the agent's own definition carries the reading protocol, deliverable format, and operating rules.

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

"Worker" here means the execution-tier agents listed in the Worker row of `AGENTS.md` (researcher / simulator / reader / scout / engine-builder / concept-checker / self-check). Synthesis agents (`retrospect`, `pivot-review`) and scheduler-owned agents (`curator`, `session-wrap-up`) are not workers and receive no auto-critic — their forcing-artifact format (synthesis agents) or scheduler-owned role (curator/wrap-up) is the integrity mechanism.

Every worker deliverable returned from step 3 is critiqued by a critic dispatch in step 4 — this is automatic, not something physicist requests. The rule is fixed:

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

The scheduler does not read critic's output before proceeding to curator — critic writes the verdict inline into the deliverable (Target A), and curator reads both the deliverable and its inline critique together when it runs in step 5. This is the critic-before-record guarantee: no worker deliverable enters the tree (via curator's lift) without having been independently reviewed.

## Critic on note.md (Target B) — NOT scheduler-dispatched

The scheduler never dispatches critic on a note.md directly. That second-order dispatch is curator's internal step: after lifting a derivation into note.md, curator dispatches critic with Target B (separate critique file, not inline annotation). See `.claude/agents/curator.md` § note.md critic layering.

## Retrospect Auto-Attach on Ascent

When SKILL § Cycle step 2 detects an ascent (new cursor is a proper prefix of the previous cursor) and the focus.md `Retrospect` field is `auto` or absent, dispatch `retrospect` in step 2.5 alongside the worker dispatch in step 3 (same message, Pattern A).

```
Agent(subagent_type="retrospect", prompt="""
## Task
Write the 5-slot retrospect forcing artifact at the new parent cursor. See your agent definition for the 5 slots and the required output path.

## Context
Previous cursor: research/{prev path}/
New cursor (parent): research/{new path}/
Session cycle: {n} of {N}
""")
```

Retrospect returns `DONE: {path}` where `{path}` is `logs/{YYMMDD_HHMM}_retrospect_{node-slug}.md` (obtained via `bash .scripts/new-log.sh retrospect {node-slug}` at retrospect's start). The scheduler captures the returned path and adds it to the curator input's `## New Evidence This Cycle` list in step 5, labelled as a retrospect deliverable rather than a worker deliverable:

```
## New Evidence This Cycle
- {worker deliverable} — critic: ACCEPT
- {timestamped retrospect path captured from retrospect's DONE return} — retrospect (no critic; forcing-artifact, not a claim)
```

Retrospect is a synthesis pass, not a claim; it receives no critic (its "verdict" would be whether each slot honestly reflects the tree, which is exactly what retrospect itself is asserting via the forcing-artifact format). Curator reads the retrospect slots as input to note.md / plan.md updates and as one piece of evidence shaping whether the parent's question should be reframed (retrospect's Slot 5 names reframe proposals explicitly).

If `Retrospect: skip — {reason}` is set, skip the dispatch. The scheduler logs the skip reason into curator's input so curator knows retrospect was deliberately deferred this cycle:

```
## New Evidence This Cycle
- {worker deliverable} — critic: ACCEPT
- retrospect: skipped — {reason copied verbatim from focus.md}
```

If not ascent, no retrospect line appears in curator's input; the cycle is ordinary.

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

The scheduler does not enumerate "subnodes without note.md" / "log.md files over 150 lines" / etc. on every cycle — that is curator's own scanning responsibility. The scheduler only reports *what happened this cycle* (directives, evidence, cursor). Curator decides what to change based on its own state of the tree.

Exception — session-end sweep: the scheduler still does not enumerate candidates; curator's own default-create / compress / staleness rules fire automatically when `Session-end sweep: true`.

## Re-dispatch on Critic REVISE / REJECT

Curator's output includes flags for deliverables whose critic verdict was REVISE or REJECT. The scheduler does NOT auto-re-dispatch the worker. The flagged deliverables are surfaced to physicist in the next cycle's prompt (SKILL § Cycle step 1) under `Recent Deliverables` / `Critic Verdicts`; physicist decides:

- *Re-dispatch the worker* — include a new Worker Dispatch entry citing the previous attempt path + critic file (researcher resubmission pattern).
- *Pivot direction* — the critic's REJECT exposed that the question was wrong; physicist reframes in `## Context` and issues a different direction.
- *Close and move on* — physicist issues a Tree Directive to close the node; curator executes.

Worker resubmission is thus physicist-directed, not scheduler-automatic. This ensures the research direction can redirect when a critic verdict reveals a deeper problem than "the attempt had a bug".
