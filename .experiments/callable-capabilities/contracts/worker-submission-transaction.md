---
name: worker-submission-transaction
kind: contract
description: Defines the reviewable worker-style deliverable pattern shared by existing execution agents.
derived_from:
  - .templates/agents/researcher.src.md
  - .templates/agents/simulator.src.md
  - .templates/agents/reader.src.md
  - .templates/agents/scout.src.md
  - .templates/agents/engine-builder.src.md
  - .templates/agents/concept-checker.src.md
  - .templates/skills/auto/phases/dispatch.src.md
outputs:
  - worker_submission
  - raw_log
  - completion_value
---

# Worker Submission Transaction

A worker-style run produces a bounded review target, not an unstructured chat answer.

Use this contract when the run creates evidence, source records, computation outputs, framework code, concept proposals, or another artifact that downstream roles may absorb.

## Required Shape

The run must identify:

- transaction kind
- intended destination or consuming role
- review focus
- scope
- evidence type
- raw process log path, when applicable
- artifact paths
- completion value

The completion value should be short and machine-readable enough for a scheduler or later run to route it, usually:

```text
DONE: {deliverable path}
```

or:

```text
FAILED: {reason}
```

## Boundary

This contract does not decide whether the content is true, important, admitted, or durable. It only makes the output reviewable and routable.

