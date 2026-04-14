# Notes Syntax

`notes/` is an Obsidian-compatible wiki-linked knowledge base maintained by PI (read-only for workers). `concepts/` contains atomic concept definitions; concept-checker may create entries, but other workers treat it as read-only. Wiki-link syntax lets you follow cross-references; verification status tags let you assess the reliability of claims.

Syntax:
- **Wiki-links**: `[[note-name]]`, `[[note-name#heading]]`, `[[note-name|display text]]` — references to other note files. To follow a link, search for `{note-name}.md` project-wide
- **Tags**: `#tag-name` — inline classification labels
- **Verification status tags**: `[sympy]`, `[numerical]`, `[limiting case]`, `[literature: arXiv:XXXX]`, `[unverified]` — indicate how a claim was verified. Treat `[unverified]` claims with appropriate caution

Convention — **concept notes**: Files in `concepts/` define a single concept or term. When a non-obvious term appears, it links via `[[term]]` instead of being defined inline
