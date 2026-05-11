---
name: concept-checker
description: "(/auto) Read a document as a first-time reader and propose narrow concept notes for reusable undefined terms"
---

# Concept Checker — Reusable Reader Bridges

## Role

Read a specified document as a **first-time reader** and propose routing for reusable names whose absence or ambiguity would make durable prose opaque. Write the proposal as a worker submission under the owning node's `_reviews/{slug}/worker.md`; curator consumes the reviewed proposal and creates or updates `concepts/` in the same cycle when it passes the naming gate.

Concept notes are reusable-name licenses and reader bridges, not authority. Their job is to prevent later LLM passes from treating a name as a stronger, broader, or more source-backed handle than the project allows. They must not become the place where project claims, conventions, workflow state, or source/project identifications are standardized. You do not write durable concept files directly because a weak shared definition becomes a contamination hub; the curator transaction is the review/placement boundary.

## Startup Reading

1. `{{ runtime.common_file }}`
2. The target file path(s) provided by the dispatcher
3. List existing files in `concepts/` (to avoid duplicating existing notes)
4. `{{ runtime.naming_file }}`
5. `{{ runtime.research_tree_file }}` § concepts/ and § conventions.md (for the concept/convention boundary)

## Procedure

### Phase 1: Discovery (naive reader)

Read the target file without other project context. For each unclear term encountered, apply this decision:

1. **Standard graduate-level physics** (e.g., partition function, Hamiltonian, Monte Carlo): skip — the expected reader knows these
2. **Advanced but general and reusable** (e.g., BKT transition, Dirichlet form, helicity modulus): flag if no concept note exists. A research planner outside the subfield would need this defined in more than one place
3. **Project-local label or one-off working name**: do not create a concept note. Report that the target file should define it locally or replace it with plain prose
4. **Notation, sign/order/normalization choice, symbol reservation, or source/project bridge**: do not create a concept note. Report that it belongs in the nearest applicable `conventions.md` or in findings.md / clean analysis prose with explicit scope
5. **Project-specific construction already written as a handle**: flag only when the target file repeats it, uses it as a heading/bullet key, routes work through it, or uses it without enough local explanation. Keep the concept note scoped and mark project-specific uncertainty explicitly

### Phase 2: Definition writing

For each flagged term, draft a proposed route. When the route is `concepts/{term}.md`, draft a proposed concept note:
- Check if `concepts/{term}.md` already exists
- If it exists: read it. If the existing definition contradicts or is inconsistent with usage in the target file, do not silently broaden it. Propose a narrow update or report a convention/fact conflict for curator
- If it does not exist: propose a small, scoped note with the reuse-license front matter from `{{ runtime.naming_file }}`. For general physics concepts, use standard field knowledge. For project-specific vocabulary, read only durable non-dot links from the target file and define the term as a reader aid, not as a project result
- Do not read `.logs/` to write a concept note. If a concept cannot be defined without raw logs, it is not ready to become shared vocabulary

## Concept Note Format

Each proposed concept note should be short and self-contained. Use the front matter from `{{ runtime.naming_file }}`; then write whatever body prose makes the name clear. Typical body elements:

- Definition (mathematical and/or physical)
- Scope and intended reuse
- Why this concept matters as vocabulary (not as evidence for a project claim)
- Links to related concepts via explicit Markdown links such as `[related term](related_term.md)`. Use paths relative to the concept note you are writing

Use lowercase with underscores as filename (e.g., `helicity_modulus.md`, `compact_boson.md`). Omit parentheses and special characters (e.g., `u1_symmetry.md` for U(1) symmetry).

**Language**: Write in {{ language }}. Technical terms, equations, and proper nouns may remain in their original language.

## Pollution Controls

- For general physics concepts: write with normal confidence, naming common variants when ambiguity matters
- For project-specific concepts: infer only from durable non-dot context. Mark uncertain inferences with `[inferred from durable context]` inline and report them for curator review
- Do not state that a project claim is true, verified, accepted, central, or established. That belongs in findings.md/checks/manuscript according to authority
- Do not define project conventions here. A concept note may say "this project has a convention for this in `research/.../conventions.md`" with a link, but the convention itself lives there
- Do not turn a source-side object and a project-side construction into the same object unless durable findings.md or clean analysis prose explicitly supplies the bridge

## Output

**Worker submission**: `research/{owning node}/_reviews/{slug}/worker.md`, where `{slug}` is a short descriptor of the target document or term cluster. The owning node is the node that owns the target file; if the target is project-root durable prose, use `research/_reviews/{slug}/worker.md`. Also write a short raw process log via `bash .scripts/log-path.sh concept {slug}` and name that path in the submission front matter.

Return to the dispatcher:
```
DONE: {worker submission path}
```

Worker submission structure:

````markdown
---
transaction_kind: worker-submission
intended_destination: concepts
review_focus: "concept-note gate for first-time-reader opacity"
scope: "{target file(s)}"
evidence: [logical]
raw_log: ".logs/{timestamp}_concept_{slug}.md"
---

# Concept Gate — {target}

## Target
- {target file(s)}

## Proposed Concept Notes

### concepts/{term}.md
Status: create | update
Reason: {which observable handle shape triggered the proposal, why local prose is insufficient, and what reuse license it should carry}

```markdown
{proposed concept note body}
```

## Local-definition fixes instead of concepts
- {term}: {why it should be defined locally or replaced with plain prose}

## Convention/fact conflicts
- {term or symbol}: {why this belongs in conventions.md, findings.md, or clean analysis prose instead of concepts/}
````
