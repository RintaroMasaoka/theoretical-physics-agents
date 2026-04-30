# Phase: Cycle Step 2 — Task Execution

This phase file is a reference that PI Reads during `/run` when dispatching work to worker agents (after Research Judgment, before Result Collection). It covers the two allowed launch patterns, the prompt template, and the per-agent dynamic data. Load it when entering step 2.

---

**Maximize parallelization.** If there are multiple independent tasks in a cycle, always launch them together. Typical parallel patterns:
- scout 2 directions + reader 2 papers → 4 tasks simultaneously
- researcher 4 problems → 4 tasks simultaneously

Always think "what can be parallelized in this cycle?" and **launch everything at once** unless there are dependencies.

**Launch method:** Use only the following 2 patterns. Do not poll with `{{ runtime.tool_shell }}("sleep ...")` or `{{ runtime.tool_shell }}("ls ...")`.

## Pattern A: Foreground Parallel (default)

{{#if runtime.is_claude}}
Call multiple {{ runtime.tool_agent }} dispatches in a single message without `run_in_background=true`. All tasks execute in parallel and automatically block until all complete.
{{else}}
Call multiple {{ runtime.tool_agent }} dispatches in a single message using the normal dispatch form. All tasks execute in parallel and automatically block until all complete.
{{/if}}

```
{{ runtime.tool_agent }}(prompt="...", {{ runtime.tool_agent_type_field }}="researcher")   ─┐
{{ runtime.tool_agent }}(prompt="...", {{ runtime.tool_agent_type_field }}="researcher")   ─┼─ Parallel, auto-block
{{ runtime.tool_agent }}(prompt="...", {{ runtime.tool_agent_type_field }}="scout")        ─┘
```

## Pattern B: Background + PI Parallel Work

{{#if runtime.is_claude}}
Launch with `run_in_background=true`, PI continues own work. System notifies on completion; retrieve with `{{ runtime.tool_task_wait }}`.

```
{{ runtime.tool_agent }}(prompt="...", {{ runtime.tool_agent_type_field }}="researcher"{{ runtime.agent_background_arg }}) → {{ runtime.agent_task_id_name }}
PI: Continue own work (Read, Edit, etc.)
← System notification
{{ runtime.agent_wait_example }}
```
{{else}}
Launch normally and capture the returned agent id, PI continues own work. System notifies on completion; retrieve with `{{ runtime.tool_task_wait }}`.

```
{{ runtime.tool_agent }}(prompt="...", {{ runtime.tool_agent_type_field }}="researcher") → {{ runtime.agent_task_id_name }}
PI: Continue own work (Read, Edit, etc.)
← System notification
{{ runtime.agent_wait_example }}
```
{{/if}}

## Prompt Template

Each agent is defined in `{{ runtime.agents_dir }}/{agent}.md` and invoked with `{{ runtime.tool_agent_type_field }}="{name}"`. PI's prompt contains only task-specific information:

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
- **curator**: Pass concrete pointers when available, but do not narrow curator's scope to those pointers. Physicist/scheduler may enumerate raw **candidates**; filtering, judgment, full-tree scanning, and structural maintenance are curator's (per curator's own default-create and node-splitting rules in `{{ runtime.agents_dir }}/curator.md`):
  - `Subnodes without note.md: {paths}` (PI lists every subnode missing note.md; curator applies its default-create rule — create when CONFIRMED facts exist in the log.md, skip for pure-computation leaves)
  - `log.md files exceeding ~150 lines: {paths}` (compression candidates; curator decides per its own signs — current-state paragraph density, evidence age, etc.)
  - `Recent CONFIRMED additions: {log.md path — brief descriptions}` (promotion candidates — critic-ACCEPTed items since the last curator dispatch)
  - `Recently retracted / revised: {paths}` (staleness candidates — claims that were demoted or reversed)
  - `Nodes updated this session: {paths}` (general context)
  These are pointers, not constraints — curator reads the tree holistically and may act on structural debt outside the list. If curator declines a candidate (e.g., note.md not yet warranted), that is a legitimate outcome.
