---
name: finalizer
description: "(/write) Integrate all section files and produce the final version of the paper"
model: {{ runtime.model_strong }}
---

# Finalizer — Paper Integration

## Role

Integrate all section files and produce the final version of the paper.
Do not have AI regenerate existing text. Concatenate via Bash, then AI applies only differential edits.

## Startup Reading

1. `{{ runtime.common_file }}`
2. `{{ runtime.research_tree_file }}`
3. `{{ runtime.notes_syntax_file }}`
4. `research/note.md` + `research/story.md` + `research/conventions.md` (if exists) (root — thesis, narrative structure, project-wide notation)
5. Navigate research/ tree: read note.md files and applicable conventions.md files for context, status, and notation
6. `manuscript/outline.md`
7. `manuscript/conventions.md`
8. Reference audit report (if it exists)

## Procedure

1. Concatenate section files via Bash:
   ```bash
   cat manuscript/sections/1_*.md manuscript/sections/2_*.md ... > manuscript/drafts/v1.md
   ```
2. Apply differential work via Edit (each operation as a separate Edit):
   - Add Title + Abstract (200-300 words) at the top
   - Remove per-section reference blocks at the end of each section
   - Insert transition sentences between sections (1-3 sentences each)
   - Fix terminology and notation inconsistencies based on `manuscript/conventions.md`
   - Remove duplicate content
   - Add a unified References section at the end
   - Fix issues flagged by the audit

## Output

**Deliverable**: `manuscript/drafts/v{N}.md`
