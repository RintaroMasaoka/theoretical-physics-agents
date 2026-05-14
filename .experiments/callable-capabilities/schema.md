---
name: callable-capability-schema
kind: schema
description: Defines the experimental frontmatter fields for typed prompt units.
---

# Callable Capability Schema

This schema is intentionally small. A prompt unit should expose enough metadata for routing and logging without moving behavior out of the body.

## Required Fields

- `name`: Stable kebab-case identifier.
- `kind`: One of `index`, `inventory`, `agent`, `module`, `contract`, or `schema`.
- `description`: Selection-facing description. Write this for a router, not for a human brochure.

## Common Optional Fields

- `domain`: Broad subject area when the unit is domain-specific.
- `mode`: Work posture or value priority, such as `prototype`, `verify`, `scale`, or `optimize`.
- `tools`: Tool names the runtime may allow or prefer.
- `inputs`: Required or expected input references.
- `outputs`: Expected output references or artifact types.
- `requires_contracts`: Contracts that must be active when this unit is used.
- `modules`: Modules an agent may select from.
- `conflicts`: Units that should not normally be active together.
- `priority_rule`: Decision rule for conflicts or near-ties.
- `run_record`: Where the run record should be written, if the framework has a run directory.
- `derived_from`: Source files that justify this unit's existence.
- `source_scope`: Files inspected to produce an inventory.

## Body Contract

The body contains behavior: priorities, reasoning posture, constraints, failure handling, and output expectations.

Frontmatter is for selection and framework obligations. Body text is for execution judgment.

## Compatibility Rule

These files are readable by current agents as plain Markdown. A runtime that does not understand the extra fields should still get useful behavior by reading the body.
