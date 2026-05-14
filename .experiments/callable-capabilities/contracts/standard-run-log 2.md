---
name: standard-run-log
kind: contract
description: Requires every reusable invocation to leave a caller-independent run record.
derived_from:
  - existing raw_log conventions in worker prompts
  - .templates/skills/auto/phases/dispatch.src.md
outputs:
  - run_record
run_record: .experiments/callable-capabilities/runs/{run_id}/run.md
---

# Standard Run Log

Every reusable framework invocation must leave a run record. This applies whether the caller was the user or another agent.

The record is not a transcript. It is the minimum state needed for a later human or agent to understand what was attempted, what changed, what evidence exists, and what should happen next.

## Required Fields

```yaml
---
run_id: "{timestamp-or-stable-id}"
caller: user | agent
invoked_unit: "{agent-or-module-name}"
loaded_modules:
  - "{module-name}"
contracts:
  - standard-run-log
status: completed | blocked | partial | failed
input_refs:
  - "{paths-or-request-ids}"
artifact_refs:
  - "{paths-written-or-inspected}"
verification_refs:
  - "{checks-or-review-paths}"
authority_notes: "{role boundary or none}"
next_recommended_action: "{one concise action or none}"
---
```

## Body

The body must contain:

- Request summary
- Module selection rationale
- Actions taken
- Artifacts changed or created
- Verification performed
- Authority or placement boundaries encountered
- Unresolved risks
- Next action

If no artifact was changed, say so explicitly. If the run was blocked, name the missing input or authority rather than silently ending.
