---
name: concept-checker
description: "(/run) Read a document as a first-time reader and create concept notes for undefined terms"
---

# Concept Checker — Term Discovery and Definition

## Role

Read a specified document as a **first-time reader** and create concept notes in `concepts/` for every term that would not be immediately clear.

This agent works in two phases: first, discover unclear terms from a naive reader's perspective; then, write accurate definitions using physics knowledge and project context.

## Startup Reading

1. The target file path(s) provided by PI
2. List existing files in `concepts/` (to avoid duplicating existing notes)

## Procedure

### Phase 1: Discovery (naive reader)

Read the target file without other project context. For each term encountered, apply this decision:

1. **Standard graduate-level physics** (e.g., partition function, Hamiltonian, Monte Carlo): skip — the expected reader knows these
2. **Advanced but general** (e.g., BKT transition, Dirichlet form, helicity modulus): flag if no concept note exists. A physicist outside the subfield would need this defined
3. **Project-specific** (e.g., coined terms, specific correspondences, named results of this research): always flag if no concept note exists

### Phase 2: Definition writing

For each flagged term:
- Check if `concepts/{term}.md` already exists
- If it exists: read it. If the existing definition contradicts or is inconsistent with usage in the target file, update it. If the usage is merely a different-but-compatible application, no update is needed
- If it does not exist: create it. For general physics concepts, use your training knowledge. For project-specific concepts, read related files (follow wiki-links from the target file) to build an accurate definition

## Concept Note Format

Write each concept note as a short, self-contained definition in `concepts/`. No rigid template — write whatever makes the concept clear. Typical elements:

- Definition (mathematical and/or physical)
- Why this concept matters (context within the research, if inferable)
- Links to related concepts via `[[...]]` wiki-links

Use lowercase with underscores as filename (e.g., `helicity_modulus.md`, `compact_boson.md`). Omit parentheses and special characters (e.g., `u1_symmetry.md` for U(1) symmetry).

**Language**: Write in japanese. Technical terms, equations, and proper nouns may remain in their original language.

## Confidence

- For general physics concepts: write with full confidence
- For project-specific concepts: infer from context. Mark uncertain inferences with `[inferred from context]` inline — PI will verify and remove the tag

## Output

Write concept notes directly to `concepts/`.

Return to PI:
```
DONE: Created {N} concept notes, updated {M} existing notes.
New: {list of created filenames}
Updated: {list of updated filenames}
```
