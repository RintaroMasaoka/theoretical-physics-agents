# Multi-Target Generation Implementation Checklist

This checklist turns the design in `docs/multi-target-generation-design.md` into concrete implementation work.

## Phase 0. Freeze Scope

- [ ] Confirm `.claude/` and `.codex/` are the only active generation targets
- [ ] Confirm `.agents/` is legacy and excluded from the new model
- [ ] Confirm the source of truth is `.templates/`
- [ ] Confirm generated outputs are not to be edited manually

## Phase 1. Audit the Current Template Surface

- [ ] Inventory every file under `.templates/`
- [ ] Search for hardcoded `.claude/` references
- [ ] Search for hardcoded `CLAUDE.md` references
- [ ] Search for Claude-specific tool names and invocation syntax
- [ ] Search for Claude startup/hook/settings assumptions
- [ ] Record findings in a runtime diff matrix

## Phase 2. Define the Target Runtime Descriptor

- [ ] Add a target model for `claude`
- [ ] Add a target model for `codex`
- [ ] Define `outputDir` for each target
- [ ] Define `configPath` for each target
- [ ] Define `rootInstructionFileName` for each target
- [ ] Define path alias values used by templates
- [ ] Define runtime term values used by templates

## Phase 3. Decide the Template Contract

- [ ] List all shared placeholders already supported
- [ ] Add runtime placeholders needed for path references
- [ ] Add runtime placeholders needed for file-name references
- [ ] Decide whether conditional rendering is required
- [ ] If conditional rendering is needed, define the minimum syntax
- [ ] Keep full-template duplication out of scope unless logically necessary

## Phase 4. Refactor `configure.mjs`

- [ ] Add `--target` argument parsing
- [ ] Support `--target claude`
- [ ] Support `--target codex`
- [ ] Support `--target all`
- [ ] Make output directory selection target-aware
- [ ] Make config loading target-aware
- [ ] Make `--dry-run` target-aware
- [ ] Make `--check` target-aware
- [ ] Keep the existing single-target Claude flow working during migration

## Phase 5. Normalize Template References

- [ ] Replace hardcoded `.claude/common.md` references with runtime-aware values
- [ ] Replace hardcoded `.claude/research-tree.md` references with runtime-aware values
- [ ] Replace hardcoded `.claude/notes-syntax.md` references with runtime-aware values
- [ ] Replace hardcoded `.claude/agents/...` references with runtime-aware values
- [ ] Replace hardcoded `.claude/skills/...` references with runtime-aware values
- [ ] Replace hardcoded root instruction file references with runtime-aware values

## Phase 6. Isolate Runtime-Specific Vocabulary

- [ ] Identify places where tool names are part of logical behavior
- [ ] Rewrite shared logical text to avoid runtime-specific wording where possible
- [ ] Parameterize runtime-specific terms where wording must differ
- [ ] Isolate startup/hook behavior from shared workflow logic
- [ ] Ensure user-interaction rules are expressed in target-compatible language

## Phase 7. Generate `.codex/`

- [ ] Define the `.codex/` directory structure
- [ ] Generate the root instruction file for Codex
- [ ] Generate shared support files for Codex
- [ ] Generate agent files for Codex
- [ ] Generate skill files for Codex
- [ ] Verify the generated `.codex/` tree is structurally complete

## Phase 8. Preserve `.claude/`

- [ ] Re-run generation for Claude after refactors
- [ ] Verify `.claude/` output remains structurally complete
- [ ] Verify existing Claude workflow files still render cleanly
- [ ] Check that no Codex-specific paths leaked into `.claude/`

## Phase 9. Add Validation

- [ ] Detect unresolved placeholders per target
- [ ] Detect unused config keys
- [ ] Detect `.claude/` references inside `.codex/` output unless explicitly allowed
- [ ] Detect `.codex/` references inside `.claude/` output unless explicitly allowed
- [ ] Detect missing expected generated files
- [ ] Decide whether stale-generated-file detection is worth adding

## Phase 10. Define the Config Story

- [ ] Decide whether config stays in one shared file or target-specific files
- [ ] Document which config keys are logically shared
- [ ] Document which config keys are runtime-specific
- [ ] Ensure `configure.mjs` implements the chosen config model clearly

## Phase 11. Update Documentation

- [ ] Update README to describe `.claude/` and `.codex/`
- [ ] Update README to describe `.templates/` as the editable source
- [ ] Update README command examples for multi-target generation
- [ ] Document generated-vs-source boundaries
- [ ] Document the target-aware generation model
- [ ] Document that `.agents/` is legacy residue if it still exists locally

## Phase 12. Final Verification

- [ ] Run generation for `claude`
- [ ] Run generation for `codex`
- [ ] Run generation for `all`
- [ ] Run `--check` for `claude`
- [ ] Run `--check` for `codex`
- [ ] Review generated diffs for accidental runtime leakage
- [ ] Verify docs match implementation behavior

## Recommended Execution Order

1. Audit templates
2. Define target descriptors
3. Decide the template contract
4. Refactor `configure.mjs`
5. Normalize template references
6. Generate `.codex/`
7. Add validation
8. Update docs
9. Final verification

## Suggested First PR Scope

Keep the first implementation batch narrow.

- Add target descriptors
- Add `--target` support to `configure.mjs`
- Parameterize core path references
- Generate a minimal `.codex/`
- Add basic cross-target validation

Do not try to perfect every template in the first pass.

## Done Definition

This migration is done when:

- editing happens in one shared template system
- `configure.mjs` emits both `.claude/` and `.codex/`
- runtime-specific differences are adapter-level, not separate manual copies
- validation catches unresolved placeholders and target leakage
- documentation matches the actual workflow
