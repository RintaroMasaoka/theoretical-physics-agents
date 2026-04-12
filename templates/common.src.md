# Worker Common Rules

## Information Architecture

Research information is organized as a **tree** under `research/`. Every node is a folder containing up to three files:

| File | Role |
|---|---|
| `note.md` | Research content for this node (required). At root: thesis and background. At other nodes: current state, evidence, revisions |
| `story.md` | Narrative structure of children (optional). At root: the paper's overall narrative arc. At interior nodes: how child topics relate and in what order |
| `principles.md` | Constraints specific to this subtree (optional). At root: cross-cutting approach principles |

Example tree:
```
research/
  note.md              (thesis, background)
  story.md             (paper narrative arc)
  principles.md        (cross-cutting constraints)
  paradox_resolution/
    note.md            (this direction's content)
  lattice_bkt/
    note.md
    story.md           (how children relate)
    coulomb_escape/
      note.md
```

| Layer | Location | Worker access | What it contains |
|---|---|---|---|
| **Research tree** | `research/` (recursive folders) | Read-only | Thesis, background, story arc, per-node context, evidence, revisions |
| **Established knowledge** | `notes/*.md`, `concepts/` | Read-only (except `concepts/` — concept-checker may create entries) | Verified results, distilled understanding, concept definitions |
| **Session cursor** | `plan.md` | Not relevant to workers | PI's current focus position in the tree |
| **Session context** | `logs/last_session.md` | Not relevant to workers | PI's volatile work context for session handoff |

**Tree navigation**: `ls research/{path}/` to see children (subfolders). Read `note.md` for research content, `story.md` for narrative structure, `principles.md` for constraints. Navigate up by reading the parent folder's files. The root (`research/note.md`) contains thesis and background; `research/story.md` contains the paper's narrative arc; `research/principles.md` contains cross-cutting approach principles.

Each node has a `kind` and `status` in its note.md frontmatter. Node status determination is PI's responsibility.

- Only PI writes to the research tree and plan.md
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
- **Wiki-links**: `[[note-name]]`, `[[note-name#heading]]`, `[[note-name|display text]]` — references to other note files. To follow a link, search for `{note-name}.md` project-wide
- **Tags**: `#tag-name` — inline classification labels
- **Verification status tags**: `[sympy]`, `[numerical]`, `[limiting case]`, `[literature: arXiv:XXXX]`, `[unverified]` — indicate how a claim was verified. Treat `[unverified]` claims with appropriate caution

Convention — **concept notes**: Files in `concepts/` define a single concept or term. When a non-obvious term appears, it links via `[[term]]` instead of being defined inline

## Constraints

- Write deliverables and logs in **{{ language }}** (technical terms, proper nouns, and equations may remain in their original language)
- Write equations in LaTeX notation (inline: `$...$`, display: `$$...$$`). Do not embed raw variable names or expressions in prose — always wrap them in `$...$`. Use `$$` instead of `\(\)`, `\[\]`, or LaTeX environment names
- Do not request user input in any form (users are often away during `/run` and `/write`. However, you may respond if the user initiates communication)
- No writing outside the project directory
