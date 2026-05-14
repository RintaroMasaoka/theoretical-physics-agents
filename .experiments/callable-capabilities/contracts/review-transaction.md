---
name: review-transaction
kind: contract
description: Defines independent review transactions for worker submissions and durable surfaces.
derived_from:
  - .templates/agents/critic.src.md
  - .templates/agents/curator.src.md
  - .templates/skills/auto/phases/dispatch.src.md
outputs:
  - review_file
  - verdict
---

# Review Transaction

Independent review is a transaction with a target, mode, verdict, and separate review artifact.

Use this contract when a run asks for verification or records verification. The review must not be merged into the target being reviewed.

## Review Kinds

`Provisional Review` targets a worker-style submission or its bounded repair. The review file lives in the same transaction directory.

`Durable Surface Review` targets a durable findings or analysis surface after it has been materialized. The review file lives under the target node's `checks/` directory.

## Modes

`blind`: use when internal mathematical, numerical, or source-local consistency can be checked without project context.

`source-audit`: use when fidelity to a source paper is the question.

`contextual`: use when soundness depends on research role, scope, provenance, or relation to ancestor claims.

## Boundary

Review can accept, reject, block, or require revision at the stated scope. It does not by itself admit a claim into findings, choose the research direction, or perform graph placement.

