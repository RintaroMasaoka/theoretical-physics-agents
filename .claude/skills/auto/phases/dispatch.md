# Phase: Dispatch

This phase file is a reference that `/auto` Reads when launching workers and critic, and when dispatching curator. It covers the two allowed launch patterns, the prompt template, Provisional Review, Durable Surface Review, and agent-specific dynamic data.

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

This is the default for the Worker Dispatch step and for Provisional Review.

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

Invoke it with `subagent_type="{name}"`. The scheduler's prompt contains only task-specific information — the agent's own definition carries the reading protocol, output format, and operating rules.


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
- **simulator**: `Target: research/{path}/` + `Physical setup` + `Mathematical definition of observables` + `Success criteria` + `Run number: {N}` + `research/_materials/lib/ module list` + `Existing scripts in _materials/src/: {list}`
- **engine-builder**: `Model definition` + `Computational method` + `Required features` + existing module path. Or `"Refine lib"` for self-directed improvement.
- **concept-checker**: Document path to read + focus area for concept extraction.
- **self-check**: Target file path (a findings.md, guide.md, or plan.md) + what to check for.

The research planner's focus.md entries are written concretely enough that these fields can be extracted mechanically. If a required field listed above cannot be extracted (e.g., a researcher entry with no `Target: research/{path}/` line, or a simulator entry missing the `Run number`), the scheduler re-dispatches research planner once, echoing the exact missing field(s); it does not "decide" whether an entry looks underspecified — structural field-absence is the only trigger. If the second attempt is still missing fields, stop the current cycle before worker launch and proceed to Session End with a failure note that worker dispatch was blocked by missing structural fields; preserve any outputs already produced earlier in the session.

## Provisional Review Rule

"Worker" here means the execution-tier agents listed in the Worker row of `.claude/CLAUDE.md` (researcher / simulator / reader / scout / engine-builder / concept-checker / self-check). Direction-support agents (`direction-challenger`) and scheduler-owned agents (`curator`, `guide-writer`, `session-wrap-up`) are not workers and receive no Provisional Review — the challenger's narrow opposition format, guide-writer's read-only-from-durable-surfaces boundary, and research planner's required response are their integrity mechanisms.

Every review-eligible `worker.md` submission returned from Cycle step 4 is critiqued by a critic dispatch in Cycle step 5 — this is automatic, not something research planner requests. The rule is fixed:

- **Review kind**: Provisional Review — the critic reviews `research/{path}/_reviews/{slug}/worker.md` or `literature/_reviews/{id}/worker.md`, writes `critic.md` in the same transaction directory, and does not edit the worker submission inline.
- **Mode**: blind by default for worker submissions whose soundness is mechanical/mathematical (researcher attempts that prove / compute / derive, simulator runs, engine-builder module tests). Source-audit for reader submissions, because the question is fidelity to the paper rather than fit to the project. Contextual for submissions whose soundness depends on the research narrative (scout surveys, concept proposals). The mode selection rule:

	  | Worker | Submission type | Default critic mode |
  |---|---|---|
  | researcher | `attempt` | blind (default). Research planner may override to contextual in the dispatch entry by writing `mode: contextual` — only then does the scheduler switch |
  | simulator | `simulation` | blind |
  | engine-builder | `engine` | blind |
  | reader | `reading` | source-audit |
  | scout | `survey` | contextual |
	  | concept-checker | `concept` proposal in `_reviews/` | contextual |
  | self-check | `review` | (no critic — self-check is itself a review) |

  The rule of thumb matches critic's own: *"What is the target faithful to?" — internal mathematics → blind; source text → source-audit; research narrative → contextual.*

- **Dispatch in parallel** with the worker submissions already in hand: one critic call per submission, all launched together in a single message (Pattern A). Critic reads only the context allowed by its mode: target file plus paper/source-note files for source-audit, target file plus ancestor chain for contextual, and target file only for blind. Each critic returns `DONE: {critic review path}`.

- **No-critic exceptions.** Research planner may mark a worker dispatch as `no-critic` in focus.md § Worker Dispatches — legitimate for engine-builder refactors with no substantive claim, or for exploratory scout surveys where the submission is framed as "what exists, not what is true". Honour the marking. All other submissions receive Provisional Review.

The scheduler reads only enough of the critic return to pair each transaction directory with its critic review path and verdict summary for curator. It does not interpret the review, except for the loop budget below. Curator reads the transaction directory when it runs in Cycle step 6. This is the critic-before-record guarantee: no review-eligible worker submission enters the tree (via state absorption, analysis preservation, or findings lift) without having been independently reviewed. Self-check and explicit `no-critic` submissions may be absorbed only under their exception rationale and must not be described as independently critic-verified.

### Optional repair loop

Default is one critic pass. If critic returns `ACCEPT`, `REJECT`, or `REVISE-NONBLOCKING`, do not loop; pass the transaction to curator. If critic returns `REVISE-BLOCKING` or `OPAQUE`, the scheduler may run **one** repair loop when the critic explains a cheap, bounded repair:

```text
worker.md -> critic.md -> repair.md -> critic_rereview.md -> stop
```

The repair prompt sends the original `worker.md`, `critic.md`, and the instruction to write only `repair.md` in the same transaction directory. Then dispatch critic on `repair.md`; critic writes `critic_rereview.md`. Even if the re-review is still blocking or opaque, stop looping and pass the blocked transaction to curator/research planner.

## Durable Surface Review Rule

Durable Surface Review is scheduler-dispatched from curator's request. Curator owns admitted findings/analysis materialisation and provenance closure, but the scheduler owns agent orchestration. This boundary is load-bearing: sub-agent to sub-agent dispatch is harness-dependent, so a curator-internal critic launch can silently fail in some runtimes. Curator therefore returns a `Durable Surface Review needed:` block instead of launching critic itself.

The scheduler reads curator's return after each curator dispatch. If the return contains one or more durable review requests, dispatch critic once per request using Pattern A. Critic writes the review under the target node's `checks/` directory, never under `.logs/` and never inline into the target surface.

Expected curator block:

```text
Durable Surface Review needed:
- path: research/{path}/findings.md or research/{path}/_materials/analyses/{slug}.md
  surface: findings | analysis
  mode: contextual | blind
  scope: {sections / claims touched}
  reason: {why independent durable-surface review is required}
```

Critic prompt shape:

```

## Task
Review kind: Durable Surface Review
path: research/{path}/findings.md or research/{path}/_materials/analyses/{slug}.md
surface: findings | analysis
mode: contextual | blind
scope pointer: {scope copied from curator request}
reason from curator: {reason copied from curator request}
```

Use curator's requested mode unless it is missing; default to `contextual`. Use `blind` only when curator says the touched derivation/analysis calculation is purely mechanical and the question is internal consistency. Contextual Durable Surface Review is the only checkpoint that can see cross-tree provenance honesty: whether durable prose, linked checks metadata, source/project boundaries, declared scope, and ancestor context still agree after curator's synthesis.

After the critic returns `DONE: {checks/... critic path}`, re-dispatch curator with the review result so curator can apply findings, compose provenance metadata, demote or rewrite claims, and request a follow-up review if its fixes materially changed the durable surface. One scheduler follow-up round is mandatory in the same cycle when possible. If curator requests another Durable Surface Review after applying the first review, carry that pending request into the next cycle's `Curator Sweep`; at Session End, drain pending durable reviews before `session-wrap-up` unless a review/fix loop exceeds two rounds on the same surface, in which case flag the unresolved verification gap for research planner and do not treat the affected claim as confirmed.

## Curator Dispatch Input

For pre-worker readiness transactions, the scheduler passes curator only the readiness directives, planned worker dispatches, and cursor context. This pass happens before evidence-producing work, so it must not be treated as evidence absorption:

```text
## Task
Pre-Worker Readiness Transaction. Execute the pre-worker tree directives below so workers read a valid active-memory context. Perform content-preserving routing work only: repair graph/lifecycle/context-route surfaces, compress residue, relocate/archive/demote/re-link material, create/close/reframe placement when authorized, and return whether the planned worker dispatch remains valid. Do not perform content audit, substantive findings/analysis edits, provenance closure, or Durable Surface Review requests in this pre-worker transaction.

## Pre-Worker Tree Directives
{verbatim copy of research/focus.md § Pre-Worker Tree Directives}

## Planned Worker Dispatches
{verbatim copy of research/focus.md § Worker Dispatches — for validity check only}

## New Evidence This Cycle
(none — this transaction prepares active memory before evidence-producing work)

## Context
Cursor: research/{path}/
Session cycle: {n} of {N}
Pre-worker readiness: true
```

Curator returns either `Dispatch readiness: valid` or `Dispatch readiness: invalidated`. The pre-worker pass must not request or launch Durable Surface Review. The scheduler continues to worker dispatch only for `valid`; for `invalidated`, it records the curator summary for the next research-planner cycle and does not invent a replacement worker plan.

For ordinary evidence absorption, the scheduler passes curator a structured prompt containing **research planner's post-worker directives** and **this cycle's evidence**. Curator does not re-discover what changed; the scheduler states it:

```
## Task
Execute the tree directives below and absorb the new evidence into the tree per your own operating rules.

## Tree Directives (from research planner, this cycle)
{verbatim copy of research/focus.md § Tree Directives — each line is an imperative curator should apply}

## Pre-Worker Curator Summary
{DONE summary from the pre-worker readiness transaction, or "(none)"}

## New Evidence This Cycle
- {transaction directory} — worker: {worker.md or repair.md}; critic review: {critic.md or critic_rereview.md}; verdict: {ACCEPT / REJECT / REVISE-NONBLOCKING / REVISE-BLOCKING / OPAQUE}
- {transaction directory} — worker: {worker.md or repair.md}; critic review: {critic.md or critic_rereview.md}; verdict: ...
- ({blank if no worker dispatches this cycle — structural-review cycle})

## Durable Surface Reviews
- {findings/analysis path} — critic review: {checks/critic_... path}; verdict: {ACCEPT / REVISE / REJECT}; requested scope: {scope}
- ({blank if this curator dispatch is the first pass and no durable-surface reviews are ready})

## Context
Cursor: research/{path}/
Session cycle: {n} of {N}
Session-end sweep: {true | false}
```

Set `Session-end sweep: true` only on the final dispatch (session-end step 2). Curator reads this flag and performs the tree-wide coherence pass required at session boundaries.

The scheduler does not enumerate "subnodes without findings.md" / "state.md files over 150 lines" / etc. on every cycle — that is curator's own scanning responsibility. The scheduler only reports *what happened this cycle* (directives, evidence, cursor). Curator decides what to change based on its own state of the tree.

Exception — session-end sweep: the scheduler still does not enumerate candidates; curator's own default-create / compress / staleness rules fire automatically when `Session-end sweep: true`.

## Re-dispatch on Critic REVISE-BLOCKING / OPAQUE

After the optional one-repair loop, curator's output may include flags for transactions whose final critic review was `REVISE-BLOCKING`, `OPAQUE`, or `REJECT`. The scheduler does not run another worker-critic loop. The flagged transactions are surfaced to direction-challenger and research planner in the next cycle's prompts; research planner decides:

- *Re-dispatch the worker* — include a new Worker Dispatch entry citing the previous transaction directory and critic file.
- *Pivot direction* — the critic's REJECT exposed that the question was wrong; research planner reframes in `## Context` and issues a different direction.
- *Close and move on* — research planner issues a Tree Directive to close the node; curator executes.

Further worker resubmission is thus research planner-directed, not scheduler-automatic. This ensures the research direction can redirect when a critic verdict reveals a deeper problem than "the submission had a fixable bug".
