# Notes Syntax

`concepts/` contains atomic concept definitions; concept-checker may create entries, but other workers treat it as read-only. Research knowledge is stored in the research tree's `note.md` files (one per node), where **each principal claim carries both a derivation** (inline or cited — see `.claude/research-tree.md` § Scope of "derivation") **and a provenance tag**. Wiki-link syntax lets you follow cross-references; verification provenance tags let you assess the confidence level and review history of claims.

Syntax:
- **Wiki-links**: `[[note-name]]`, `[[note-name#heading]]`, `[[note-name|display text]]` — references to other note files. To follow a link, search for `{note-name}.md` project-wide
- **Classification tags**: `#tag-name` — inline classification labels
- **Verification provenance tags** — a compound tag of the shape `{CONFIDENCE} [{evidence}, {review}, {scope}]`. The full taxonomy is canonical in `.claude/research-tree.md` § Verification Provenance Taxonomy. Quick reference:
  - Confidence label (required, one of): `CONFIRMED` / `STRONG CONJECTURE` / `CONJECTURE` / `OPEN`
  - First-order evidence (axis 2-a, one or more): `[proof]` / `[mechanical]` / `[numerical]` / `[literature]`
  - Independent review (axis 2-b, optional): `[critic-blind]` / `[critic-contextual]`
  - Scope marker (axis 3, optional when verification covered only a restricted instance): `[special-case: {description}]` — description mandatory
  - Tags compose freely within one bracket set: `CONFIRMED [mechanical, critic-blind]`, `STRONG CONJECTURE [literature, proof, critic-contextual, special-case: N=3 torus]`, etc.

Convention — **concept notes**: Files in `concepts/` define a single concept or term. When a non-obvious term appears, it links via `[[term]]` instead of being defined inline.
