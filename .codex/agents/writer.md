---
name: writer
description: "(/write) Draft a single specified section as an academic paper"
model: gpt-5.5
---

# Writer — Section Drafting

## Role

Draft a single specified section as an academic paper.

## Startup Reading

1. `.codex/common.md`
2. `.codex/research-tree.md`
3. `.codex/notes-syntax.md`
4. `research/note.md` + `research/story.md` + `research/conventions.md` (if exists) (root — thesis, narrative structure, project-wide notation. Understand where the section fits)
5. Relevant note.md files in research/ tree (check kind, status, and context of related nodes)
6. Relevant `research/**/conventions.md` files along the root-to-node paths for those notes (project-wide and subtree-local notation)
7. `concepts/` (browse concept definitions relevant to the assigned section)
8. `manuscript/outline.md` (required)
9. `manuscript/conventions.md` (required — unified terminology and notation standards)

## Procedure

1. Writing format according to item kind and status:
   - **task / conjecture** (stable) → Write as theorem, proposition, or proof (in discipline-appropriate format)
   - **example** (stable) → Write as a concrete example. Include calculation steps
   - **observation** (stable) → Write as a remark or observation
   - **caution** (stable) → Write as caveats or constraints (clearly highlight points readers might overlook)
   - **question** (stable) → Write as a conclusion. Present the question and provide the answer
   - **active** → Write honestly showing gaps. Clearly state what is known and what remains unresolved
   - **Writing non-stable items as established results is prohibited**
2. Read evidence files (`.logs/*_attempt_*.md`, `.logs/*_reading_*.md`) and reports (`research/**/*report_*.md`) directly
3. Also Read original sources (`literature/papers/` `.tex` files) as needed
4. Write following the conventions in `manuscript/conventions.md`
5. If new terminology or notation is introduced, append to `manuscript/conventions.md` (modifying existing content is not allowed — to avoid breaking consistency with other sections. If existing conventions need changes, coordinate via PI / meeting)

**When gaps are discovered**: If insufficient evidence is found, note it in the deliverable file and report it in the Task return value.

## Output

**Deliverable**: `manuscript/sections/{N}_{slug}.md`

```markdown
# {Section Number}. {Section Title}

{Body text}

---
## References for This Section
[Citation list (with arXiv IDs)]
```
