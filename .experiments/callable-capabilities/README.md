---
name: callable-capabilities-experiment
kind: index
description: Experimental typed prompt registry for caller-independent capability invocation and run logging.
---

# Callable Capabilities Experiment

This directory is an experimental prompt registry. It does not participate in the current `.templates` -> `.claude` / `.codex` generation workflow.

The goal is to test a different decomposition:

- `inventory`: decomposition evidence from existing prompts
- `agent`: a thin invocation-to-run converter
- `module`: reusable reading, authority, placement, fidelity, oversight, or lifecycle rule extracted from existing agents
- `contract`: shared invocation, output, review, or logging rule
- `run`: one recorded invocation, regardless of whether the caller was a user or another agent

The physical format follows Claude-style Markdown: YAML frontmatter plus a body. The project-specific schema extends the frontmatter so a future loader can route and log invocations mechanically, while current runtimes can still read the files directly.

## Why This Exists

The existing workflow should remain intact. Current agents in `.templates/agents/*.src.md` and generated runtime files continue to define `/auto`, `/steer`, `/write`, and other established behavior.

This experiment exists to test whether prompt behavior can be composed from typed units instead of being packed into large role prompts or split into too many narrowly named agents.

The first cut is intentionally derived from the current agents. New domain modes such as "optimize implementation" or "prepare scale" should be added only after the current agent responsibilities have been decomposed and the domain-specific need is visible.

## Layout

```text
.experiments/callable-capabilities/
  README.md
  schema.md
  inventory/
    current-agent-decomposition.md
  agents/
    run-orchestrator.md
  contracts/
    standard-run-log.md
    worker-submission-transaction.md
    review-transaction.md
  modules/
    runtime-context-loading.md
    authority-boundary.md
    artifact-placement.md
    source-fidelity.md
    human-oversight-surface.md
    session-handoff.md
```

## Intended Invocation Model

User-invoked and agent-invoked work create the same run record.

```yaml
caller: user | agent
invoked_unit: run-orchestrator
loaded_modules:
  - runtime-context-loading
  - authority-boundary
contracts:
  - standard-run-log
input_refs:
  - path/or/request
```

The caller affects metadata, not the obligation to leave a usable record.

## Current Status

This is not wired into `/auto`, `/steer`, `/write`, Codex agents, or Claude agents. Treat it as a design experiment and source of future prompt refactors.
