# Notes Syntax

`concepts/` contains atomic concept definitions; concept-checker may create entries, but other workers treat it as read-only. Research knowledge is stored in the research tree's `note.md` files (one per node), where **each principal claim carries both a derivation** (inline or cited — see `.codex/research-tree.md` § Scope of "derivation") **and a provenance tag**. Markdown links let you follow cross-references; verification provenance tags let you assess the confidence level and review history of claims.

Syntax:
- **Markdown links**: `[display text](relative/path.md)` or `[display text](<relative/path with spaces.md>)` — references to other notes, concept definitions, reports, checks, scripts, data, or figures. Link targets are written relative to the file containing the link. Use the angle-bracket form when the path contains spaces. Heading anchors may be appended when the renderer supports them, e.g. `[display text](../note.md#heading-slug)`.
- **Classification tags**: `#tag-name` — inline classification labels
- **Verification provenance tags** — a compound tag of the shape `{CONFIDENCE} [{evidence}, {review}, {scope}]`. The full taxonomy is canonical in `.codex/research-tree.md` § Verification Provenance Taxonomy. Quick reference:
  - Confidence label (required, one of): `CONFIRMED` / `STRONG CONJECTURE` / `CONJECTURE` / `OPEN`
  - First-order evidence (axis 2-a, one or more): `[proof]` / `[mechanical]` / `[numerical]` / `[literature]`
  - Independent review (axis 2-b, optional): `[critic-blind]` / `[critic-contextual]`
  - Scope marker (axis 3, optional when verification covered only a restricted instance): `[special-case: {description}]` — description mandatory
  - Tags compose freely within one bracket set: `CONFIRMED [mechanical, critic-blind]`, `STRONG CONJECTURE [literature, proof, critic-contextual, special-case: N=3 torus]`, etc.

Rule — **references must be links**: In prose files, any reference to another repository file or artifact must be a Markdown link, not a bare path, unless it appears inside code, frontmatter, or a machine-readable command. This keeps the tree browsable without grep and lets audits check that references resolve. Dispatcher prompts may pass raw file paths as task inputs; authored research prose may not leave those paths bare.

Convention — **concept notes**: Files in `concepts/` define a single concept or term. When a non-obvious term appears, either define it inline or link it with a Markdown link to the concept file, e.g. `[helicity modulus](../../concepts/helicity_modulus.md)`. Do not use Obsidian-style `[[...]]` links; they hide the path resolution rule and are harder to verify outside Obsidian.
