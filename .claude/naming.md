# Naming Contract

This file defines how short names enter project memory without being mistaken for stronger, broader, or more standard terminology than the project has established.

A reusable name is a short expression that functions as a handle rather than just prose: a project-coined term, imported source term, recurring diagnostic name, convention-bound phrase, warning label, child/focus label, or any compact expression used without repeating its full local explanation.

The risk is not that the name is unfamiliar. The risk is a prompt-shape effect: when a short expression appears in state, focus, findings, map entries, child names, or repeated worker prose, later LLM passes tend to compress it into a stable object, assume it has the authority of its surface, merge it with nearby terms, or export it into paper prose. The naming contract changes that affordance by making licensed names visibly carry their allowed reuse and making unlicensed names visibly local.

## Observable Triggers

Do not ask whether a phrase will be reused someday. Apply this contract when the current text has one of these observable shapes:

- The expression is used as a label: heading, bullet key, child folder name, focus label, dispatch handle, map entry name, theorem/claim nickname, diagnostic name, or warning name.
- The expression is repeated without its full explanation in the same artifact or copied into another artifact.
- The expression is moved from local attempt prose into a durable or semi-durable surface: `research/focus.md`, state.md, findings.md, guide.md, map.md, plan.md, story.md, conventions, concept notes, clean analyses, source records, or manuscript-facing prose.
- The expression is used to route work: a worker target, tree directive, pre-worker directive, child presentation judgment, blocker, or scheduler-visible context line depends on it.
- The expression stands near a possible source/project/domain boundary: it could be read as source-native, domain-standard, project-defined, project-observed, user-decided, diagnostic, or convention-bound.
- The expression is used without enough immediate prose for a neighbouring-field reader to reconstruct exactly what it means and what it does not license.

A phrase can remain ordinary prose while it is locally explained and not used as a handle. The naming gate fires at the first observable handle use, copy, routing use, or promotion, not at the first moment a thought is phrased.

## Reader Defaults

These defaults are here because LLMs will otherwise infer authority from placement.

- A licensed name is one that has a `Naming decisions` entry, concept-note front matter, convention/source/finding route, or an inline durable definition that answers the contract below.
- An unlicensed short expression is local prose, even if it appears in state.md, focus.md, or another source-of-truth surface. Do not treat it as common, standard, accepted, paper-ready, or safe to reuse as a handle.
- If you need to use an unlicensed expression as a handle, write the smallest `Naming decisions` entry first, or replace the handle with plain prose that carries the needed meaning locally.
- If an unlicensed expression came from an earlier worker or planner, do not silently promote it by repeating it. Either quote/paraphrase the local explanation as local evidence, or license the name with grounding, scope, and permission.
- A source-looking name is not source-native unless it is anchored to a source record. A project-looking name is not project-defined unless its expansion and scope are stated. A diagnostic-looking name is not the target object unless the route explicitly says so.

## Name Contract

Every reusable name must answer these questions, either in a `Naming decisions` block, a concept note front matter, or ordinary durable prose:

1. **Expansion** — What should the name expand to for a reader with no local session history?
2. **Grounding** — Where does that expansion come from: a source, domain convention, project definition, project observation, user decision, mixed basis, or unknown basis?
3. **Stability** — Is the name nonce, provisional, active, deprecated, or retired?
4. **Carry scope** — How far may the name be reused: local, node, subtree, project, or paper?
5. **Claim permission** — What does the name license: name-only use, definition-only use, evidence-linked use, or claim-linked use?
6. **Merge boundary** — What aliases, source terms, symbols, or nearby constructions may or may not be treated as the same thing?
7. **Reader action** — When a later pass encounters the name, should it define locally, link to a concept note, route to conventions, cite a source, link a checked claim, or replace the name with plain prose?

If one of these cannot be answered honestly, do not let the name function as shared vocabulary. Keep the prose local, mark the name provisional with narrow scope, or replace it with plain prose. If the name was previously local and now appears in one of the observable trigger shapes, answer the questions before carrying it forward.

## Working Surfaces

Working surfaces may include a `Naming decisions` section when they give a name handle shape or promote an earlier local phrase into a handle. Omit the section when no such name appears.

```markdown
## Naming decisions

- `{name}`: expansion: {one-sentence expansion}. Grounding: {source | domain | project-definition | project-observation | user-decision | mixed | unknown}. Stability: {nonce | provisional | active | deprecated | retired}. Carry scope: {local | node | subtree | project | paper}. Claim permission: {name-only | definition-only | evidence-linked | claim-linked}. Merge boundary: {allowed aliases or do-not-merge targets, if relevant}. Proposed route: {inline definition | concepts/{term}.md | conventions.md | source anchor | findings/checks | plain prose replacement}.
```

Working prose may also use a short Markdown badge on first use when ambiguity would otherwise leak:

```markdown
{name} (`project-definition`; `subtree`; `definition-only`)
```

Badge order is `grounding; carry scope; claim permission`. Badges are allowed in working surfaces such as `worker.md`, `_reviews/`, state.md, and `research/focus.md`. They should not remain in durable reader prose.

## Concept Notes

`concepts/{term}.md` stores a reusable-name contract plus a reader explanation. It is not proof that a claim is true and not a convention ledger.

Use this front matter when a name becomes a reusable reader bridge:

```yaml
---
term: "{name}"
aliases: []

expansion: >
  {one-sentence expansion}

grounding:
  kind: source | domain | project-definition | project-observation | user-decision | mixed | unknown
  anchors: []

stability: nonce | provisional | active | deprecated | retired
carry_scope: local | node | subtree | project | paper

claim_permission: name-only | definition-only | evidence-linked | claim-linked
claim_anchors: []

merge_boundary:
  allowed_aliases: []
  do_not_merge_with:
    - term: "{nearby name, source term, symbol, or construction}"
      reason: "{why merging would overstate the project state}"

reader_action: >
  {what a later pass should do when encountering or using the name}
---
```

The body of the concept note explains the name in ordinary prose. It may link to related concepts, source records, conventions, findings, or checks, but it must not hide project claims inside the explanation.

## Routing Rules

Route names by the permission they need:

- **Local or nonce name**: define inline or replace with plain prose.
- **Reusable reader bridge**: create or update `concepts/{term}.md`.
- **Notation, sign, order, normalization, or symbol-bound name**: route to `conventions.md` or link the applicable convention.
- **Source-native name**: anchor to the source record or source-specific prose; do not translate into project language silently.
- **Project claim, equivalence, or established construction**: route through findings.md and checks; a concept note alone is insufficient.
- **Diagnostic or warning name**: keep local unless it is reused as a reader bridge; never let it imply the target object or claim is established.

## Role Split

The agent whose current output first gives a phrase handle shape writes the cheapest available `Naming decisions` entry. This may be the first author, but often it is the later agent that repeats the phrase, turns it into a child/focus label, copies it into a route, or moves it into durable prose. This includes research planner when it coins or reuses a child name, dispatch handle, focus label, or tree-directive term.

Curator closes naming routes for names surfaced by planner `Naming Decisions`, worker `Naming decisions`, concept-checker/self-check findings, or durable prose curator is already editing. Curator should not run a full-tree naming audit on every dispatch.

Concept-checker and self-check are audit tools for suspected opacity. They are not the primary creation path for every concept note.

## Durable Prose

Durable reader prose should not preserve raw badges or management labels. Before promotion, each reusable name should be handled by one of:

- ordinary prose definition at first use
- Markdown link to a concept note
- convention link or convention statement
- source anchor
- findings/checks link for claim-bearing use
- plain-prose replacement when the name should not become shared vocabulary

If a durable paragraph relies on a reusable name but none of those routes is available, the paragraph is not ready for promotion.
