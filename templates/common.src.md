# Worker Common Rules

## Information Architecture

Research information is organized in 4 layers:

| Layer | Location | Worker access | What it contains |
|---|---|---|---|
| **Research map** | `plan.md` | Read-only | Story Arc (the narrative backbone of the research) with item tree, strategy, principles |
| **Item context** | `items/*.md` | Read-only | Per-item work context: evidence, revisions, children, current state |
| **Established knowledge** | `notes/*.md`, `concepts/` | Read-only (except `concepts/` — concept-checker may create entries) | Verified results, distilled understanding, concept definitions |
| **Session context** | `logs/last_session.md` | Not relevant to workers | PI's volatile work context for session handoff |

**plan.md tree**: The Story Arc in plan.md lists items as `{id} [{status}]: {description}`. Item IDs are descriptive slugs (`snake_case`, e.g., `main_theorem_proof`). Items with complex context link to `items/{id}.md`; simple items appear only as lines in plan.md with no corresponding file. Each item has a `kind` (narrative, task, question, conjecture, example, caution, gap, observation, etc.) and a `status` (open, active, stable, closed).

**items/*.md**: Frontmatter contains `id`, `parent`, `kind`, `status`, `contribution`. Body contains current state, evidence chain, revision history, and children. The `parent` field tracks the item's position in the tree hierarchy.

Item status determination requires the context of the entire research and is PI's responsibility.

- Only PI writes to plan.md and items/
- To propose a status change, describe the rationale in your deliverable file
- Honest reporting is paramount: never propose stable for something that has not been sufficiently verified

## Inter-Agent Communication

PI will not paste data into your task prompt. Instead, PI provides file paths; you read only the sections you need. This keeps both PI's and your context windows efficient.

- **Input**: Receive task instructions and file paths from PI; Read the necessary data yourself
- **Output**: Write deliverables to files and return `DONE: {deliverable path}` as the Task return value

## Logs (Progress Records for Humans)

Write a work summary to `logs/{agent}_{timestamp}.md`. The deliverable contains your analytical output. The log is a brief narrative summary of what you did, what you found, and any issues encountered — it helps the human researcher audit the research process. Logs are not a decision input for PI.

## Research Notes Format

`notes/` is an Obsidian-compatible wiki-linked knowledge base maintained by PI (read-only for workers). `concepts/` contains atomic concept definitions; concept-checker may create entries, but other workers treat it as read-only. Understanding the syntax lets you follow cross-references and assess the reliability of claims.

Syntax:
- **Wiki-links**: `[[note-name]]`, `[[note-name#heading]]`, `[[note-name|display text]]` — references to other note files. To follow a link, search for `{note-name}.md` project-wide (wiki-links resolve by filename, not by directory path)
- **Tags**: `#tag-name` — inline classification labels (e.g., `#conjecture`, `#verified`, `#key-result`)
- **Verification status tags**: `[sympy]`, `[numerical]`, `[limiting case]`, `[literature: arXiv:XXXX]`, `[unverified]` — indicate how a claim was verified. Treat `[unverified]` claims with appropriate caution; do not cite them as established results

Convention — **concept notes**: Files in `concepts/` are small (< 1 page) and define a single concept or term. When a non-obvious term appears, it links to the concept note via `[[term]]` instead of being defined inline. This keeps definitions canonical and reusable

## Constraints

- Write deliverables and logs in **{{ language }}** (technical terms, proper nouns, and equations may remain in their original language)
- Write equations in LaTeX notation (inline: `$...$`, display: `$$...$$`). Do not embed raw variable names or expressions in prose — always wrap them in `$...$`. Use `$$` instead of `\(\)`, `\[\]`, or LaTeX environment names — `$$` is the standard syntax recognized by most Markdown readers
- Do not request user input in any form (users are often away during `/run` and `/write`, and asking questions interrupts the session. However, you may respond if the user initiates communication)
- No writing outside the project directory
