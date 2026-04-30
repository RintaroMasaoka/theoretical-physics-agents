# Multi-Target Prompt Generation Design

## Summary

This repository should stop maintaining Claude-specific and Codex-specific skills separately.
The source of truth should be shared templates, and environment-adapted generated outputs should be emitted into `.claude/` and `.codex/`.

The goal is **not** to make Claude and Codex consume the exact same generated file unchanged.
The goal is to make them consume outputs generated from the same logical source.

## Goals

- Eliminate separate manual maintenance of Claude skills and Codex skills
- Keep the logical layer shared across runtimes
- Generate runtime-adapted outputs for Claude and Codex from common source templates
- Absorb Claude/Codex differences in `configure.mjs`
- Make `.templates/` the canonical editable source

## Non-Goals

- Requiring Claude and Codex to use byte-for-byte identical generated files
- Supporting third runtimes beyond Claude and Codex
- Preserving `.agents/` as an active runtime target
- Solving all runtime differences by hand-edited generated files

## Current Problem

The current repository structure is effectively Claude-centric.
Templates under `.templates/` still contain Claude-specific assumptions such as:

- `.claude/...` path references
- Claude-specific file naming
- Claude-specific tool names or invocation vocabulary
- Claude hook and settings assumptions

Because of that, templates are not yet truly runtime-agnostic.
They are closer to "Claude prompts with config substitution" than to a shared multi-target source.

## Design Principle

Separate the system into three layers.

### 1. Logical Layer

This layer should remain shared.
It includes:

- research workflow
- roles and responsibilities
- state transitions
- artifact semantics
- global constraints
- paper/research process rules

### 2. Runtime Adapter Layer

This layer is allowed to differ by target.
It includes:

- output paths
- internal file references
- root instruction filenames
- tool names
- sub-agent invocation wording
- runtime-specific hooks or startup behavior
- environment-specific phrasing for interaction rules

### 3. Generated Output Layer

This layer is target-specific.
It includes:

- `.claude/`
- `.codex/`

## Target Model

`configure.mjs` should become a target-aware generator.

It should support:

- `claude`
- `codex`
- `all`

Each target should define a small runtime descriptor, at minimum:

- `name`
- `outputDir`
- `configPath`
- `rootInstructionFileName`
- `pathAliases`
- `runtimeTerms`

This should be explicit in code rather than inferred from directory naming.

## Source of Truth

The canonical editable source should be:

- `.templates/` for prompt and instruction templates
- shared config source or a clearly-defined config split

Generated files must be treated as non-canonical.
They should not be manually edited.

## Configuration Model

Configuration should be split conceptually into:

### Shared Config

Examples:

- `language`
- `simulation.language`
- `cycles.run`
- `cycles.write`

### Target-Specific Config

Examples:

- output directory
- runtime file names
- runtime path aliases
- hook/settings generation behavior
- runtime-specific vocabulary

The implementation may keep this in one config file or several files, but the responsibility split should be explicit.

## Template API

Templates should stop hardcoding Claude-specific references whenever those references belong to the runtime adapter layer.

Expected mechanisms:

- variable substitution for simple values
- limited target-aware branching for runtime-specific snippets

Examples of values that should become target-aware:

- `{{ runtime.root_dir }}`
- `{{ runtime.common_file }}`
- `{{ runtime.instruction_file }}`
- `{{ runtime.research_tree_file }}`

The design should avoid cloning whole templates unless the logical content genuinely diverges.

## Required Refactor Scope

The following classes of Claude-specific assumptions need to be audited and either parameterized or isolated:

- `.claude/...` path references
- `CLAUDE.md` naming assumptions
- Claude-specific tool names
- Claude-specific sub-agent invocation examples
- Claude hook and startup assumptions
- references to Claude settings files

`.agents/` is treated as legacy residue and should not shape the new design.

## Output Definition

The generated output contract should be defined for both targets.

Expected generated categories:

- root instruction file
- common rules file
- notes syntax file
- research tree file
- agent instruction files
- skill files

Open implementation detail:

- whether both targets also generate target-specific startup/config files from templates

## Validation Requirements

The generator should validate target output quality, not only placeholder substitution.

Minimum checks:

- unresolved placeholder detection
- unused config key detection
- target-crossing path detection
- missing generated file detection

Examples:

- `.claude/` output must not retain `.codex/` references
- `.codex/` output must not retain `.claude/` references, unless explicitly intended

## Proposed Implementation Plan

### Phase 1. Freeze Requirements

- Record goals and non-goals
- Confirm `.claude/` and `.codex/` as the only active targets
- Confirm `.agents/` is legacy and out of scope

### Phase 2. Build a Runtime Diff Matrix

- Audit `.templates/`
- Classify content as `common`, `parameterized`, `claude-only`, or `codex-only`
- Record all runtime-specific assumptions

### Phase 3. Expand `configure.mjs`

- Add target selection support
- Add target runtime descriptors
- Make `--dry-run` target-aware
- Make `--check` target-aware
- Make output location target-aware

### Phase 4. Normalize Templates

- Remove hardcoded `.claude/...` references where they belong to runtime adaptation
- Replace runtime-specific naming with variables or limited branching
- Isolate truly runtime-specific snippets

### Phase 5. Add `.codex/` Generation

- Generate a minimal complete `.codex/`
- Keep `.claude/` generation working throughout the migration

### Phase 6. Strengthen Validation

- Add cross-target leakage checks
- Add stale or incomplete generation detection if useful

### Phase 7. Update Documentation

- Update README
- Document the editable vs generated boundary
- Document generation commands
- Document the target model

## Acceptance Criteria

The work is complete when:

- logical edits are made in one shared source system
- `configure.mjs` can generate both `.claude/` and `.codex/`
- runtime differences are handled by target-aware rendering rather than separate manual maintenance
- generated outputs do not contain accidental cross-target references
- repository documentation matches the actual generation model

## Suggested Commands

The intended command shape should become something like:

```bash
node .scripts/configure.mjs --target claude
node .scripts/configure.mjs --target codex
node .scripts/configure.mjs --target all
node .scripts/configure.mjs --target claude --check
node .scripts/configure.mjs --target codex --check
```

Exact CLI shape can still change, but the target-aware behavior is part of the design.

## Open Questions

- Should shared config remain under one canonical path, or should each target have its own generated config view?
- Which root instruction filename should Codex consume inside `.codex/`?
- Which runtime-specific startup/config files are worth generating versus hand-maintaining?
- Do any templates have genuine logical divergence that justifies per-target partials?
