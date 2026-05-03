# Notes Syntax

`concepts/` contains scoped reusable reader bridges; concept-checker may create entries, but other workers treat it as read-only unless explicitly assigned concept maintenance. Research facts are stored in the research tree's `note.md` files (one per node), where **each principal claim carries both a derivation or derivation skeleton** (inline or cited — see `{{ runtime.research_tree_file }}` § Scope of "derivation") **and a Markdown link to a provenance record under `checks/`**. Markdown links let you follow durable cross-references; check-file front matter lets you assess the confidence level and review history of claims without adding project-specific tag syntax to note.md prose.

Syntax:
- **Markdown links**: `[display text](relative/path.md)` or `[display text](<relative/path with spaces.md>)` — references to other notes, concept definitions, reports, checks, scripts, data, or figures. Link targets are written relative to the file containing the link. Use the angle-bracket form when the path contains spaces. Heading anchors may be appended when the renderer supports them, e.g. `[display text](../note.md#heading-slug)`.
- **Classification tags**: `#tag-name` — inline classification labels
- **Verification provenance records** — node-local Markdown files under `checks/` with YAML front matter. In note.md/report prose, cite them with a normal Markdown link such as `[verification](checks/check_projector_identity.md)`. The full schema is canonical in `{{ runtime.research_tree_file }}` § Verification Provenance Records. Quick reference:
  - `confidence` (required, one of): `confirmed` / `strong-conjecture` / `conjecture` / `open`
  - `evidence` (first-order channels, one or more for `confirmed`): `proof` / `mechanical` / `numerical` / `literature`
  - `review` (independent review channels, optional): `critic-blind` / `critic-contextual`
  - `scope`: `full` or a concrete restricted-instance description
  - `supports_project_central_claim`: `true` / `false`

Rule — **durable references must be links, except `.logs/`**: In durable prose files, references to non-dot repository files or artifacts should be Markdown links, not bare paths, unless they appear inside code, frontmatter, or a machine-readable command. References to `.logs/` or other dot surfaces are forbidden in durable research prose: absorb the relevant substance instead of linking to raw audit archive files. Dispatcher prompts may pass raw file paths as task inputs; authored research prose may not leave those paths bare or convert `.logs/` paths into links.

Convention — **concept notes**: Files in `concepts/` explain one reusable concept or term. When a non-obvious term appears, define it inline and add a Markdown link to the concept file when a reusable bridge is useful, e.g. `[helicity modulus](../../concepts/helicity_modulus.md)`. Do not use Obsidian-style `[[...]]` links; they hide the path resolution rule and are harder to verify outside Obsidian. Concept notes are not authority for project facts, conventions, or workflow state.
