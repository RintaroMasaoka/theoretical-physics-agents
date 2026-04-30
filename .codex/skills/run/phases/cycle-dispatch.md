# Phase: Cycle Step 2 — Task Execution

This phase file is a reference that PI Reads during `/run` when dispatching work to worker agents (after Research Judgment, before Result Collection). It covers the two allowed launch patterns, the prompt template, and the per-agent dynamic data. Load it when entering step 2.

---

**Maximize parallelization.** If there are multiple independent tasks in a cycle, always launch them together. Typical parallel patterns:
- scout 2 directions + reader 2 papers → 4 tasks simultaneously
- researcher 4 problems → 4 tasks simultaneously

Always think "what can be parallelized in this cycle?" and **launch everything at once** unless there are dependencies.

**Launch method:** Use only the following 2 patterns. Do not poll with `Bash("sleep ...")` or `Bash("ls ...")`.

## Pattern A: Foreground Parallel (default)

Call multiple Agents in a single message without `run_in_background`. All tasks execute in parallel and automatically block until all complete.

```
Agent(prompt="...", subagent_type="researcher")   ─┐
Agent(prompt="...", subagent_type="researcher")   ─┼─ Parallel, auto-block
Agent(prompt="...", subagent_type="scout")        ─┘
```

## Pattern B: Background + PI Parallel Work

Launch with `run_in_background=true`, PI continues own work. System notifies on completion; retrieve with `TaskOutput`.

```
Agent(prompt="...", subagent_type="researcher", run_in_background=true) → task_id_1
PI: Continue own work (Read, Edit, etc.)
← System notification
TaskOutput(task_id="task_id_1", block=true)
```

## Prompt Template

Each agent is defined in `.codex/agents/{agent}.md` and invoked with `subagent_type="{name}"`. PI's prompt contains only task-specific information:

```
## Task
{specific instructions}

## Context
{relevant content from the current subtree}
```

## Dynamic Data by Agent

- **scout**: Search direction instructions
- **reader**: `Assigned paper: arXiv:{id}` / `Title: {title}`
- **researcher**: `Target: research/{path}/ — {description}` / `kind: {kind}` / `Context: {role within parent's children decomposition}` / previous attempt path / PI's critique
- **critic**: `Target: research/{path}/ — {description}` / `attempt path: {path}` / `kind: {kind}` / `mode: blind` or `mode: contextual`
- **engine-builder**: `Model definition` / `Computational method` / `Required features` / existing module path. Or `"Refine lib"` for self-directed improvement
- **simulator**: `Target: research/{path}/` / `Physical setup` / `Mathematical definition of observables` / `Success criteria` / `Deliverable number: {N}` / `research/lib/` module list / `Existing scripts in src/: {list}`
- **curator**: Pass concrete pointers when available, but do not narrow curator's scope to those pointers. Physicist/scheduler may enumerate raw **candidates**; filtering, judgment, full-tree scanning, and structural maintenance are curator's (per curator's own default-create and node-splitting rules in `.codex/agents/curator.md`):
  - `Subnodes without note.md: {paths}` (PI lists every subnode missing note.md; curator applies its default-create rule — create when CONFIRMED facts exist in the log.md, skip for pure-computation leaves)
  - `log.md files exceeding ~150 lines: {paths}` (compression candidates; curator decides per its own signs — current-state paragraph density, evidence age, etc.)
  - `Recent CONFIRMED additions: {log.md path — brief descriptions}` (promotion candidates — critic-ACCEPTed items since the last curator dispatch)
  - `Recently retracted / revised: {paths}` (staleness candidates — claims that were demoted or reversed)
  - `Nodes updated this session: {paths}` (general context)
  These are pointers, not constraints — curator reads the tree holistically and may act on structural debt outside the list. If curator declines a candidate (e.g., note.md not yet warranted), that is a legitimate outcome.
