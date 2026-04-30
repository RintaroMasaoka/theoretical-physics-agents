---
name: improve
description: "Improve agent prompts and behavior. The user says what's unsatisfactory; AI understands the complaint deeply, rewrites at the root cause, and an independent reviewer verifies."
user-invocable: true
argument-hint: "[complaint (optional)]"
---

# System Improvement

Improve the quality of agent and skill prompts. The user describes what is unsatisfactory; PI understands the complaint thoroughly, designs a fix **at the root-cause level rather than patching the symptom**, executes it, and has an independent agent verify coherence.

Arguments: $ARGUMENTS

---

## Core principle: root cause, not symptoms

The failure mode this skill must avoid is the **symptomatic fix** — a patch that deflects the observed symptom in the observed place with the observed wording ("don't do X", "don't use this word", "in this case do Y"). An LLM learns to sidestep the pattern at the surface, but the same cause keeps producing new symptoms in new contexts; the prompt accumulates patches and unravels.

A **root-cause fix** climbs up to the cause that generated the symptom — *why* is this behavior unwanted, what tradeoff is at stake, which side should win — and describes the cause itself ("because of X, prefer Y over Z"). Given the cause, an LLM extrapolates the same judgment to unseen situations. Enumerating anti-patterns is a canonical symptomatic pattern: an anti-pattern is the *name* of a symptom, not an explanation of its cause. If the cause is written, anti-patterns follow as natural consequences and the enumeration often becomes unnecessary.

The target prompt is a **hypothesis to question**, not a doctrine to protect. Questioning reaches beyond explicit prescriptive wording to the **underlying premise layer** — the concepts, categories, causal models, goals, and structure the target has adopted. Re-touching surface wording while a symptom-generating premise remains is still symptomatic. The asymmetry justifies the stance: questioning is cheap (propose an alternative, the user judges); not questioning is expensive (stay at the symptom layer and miss unknown symptoms from the same cause). Questioning may conclude with re-adopting the old wording — what is required is avoiding blind preservation, not change for its own sake.

---

## Template System

Prompt files are generated from templates — editing generated files directly is wrong because `.scripts/configure.mjs` overwrites them on each run. Templates are shared with downstream projects via an upstream remote: pull to stay current, push to share.

| Layer | Path | Role |
|---|---|---|
| **Template (source of truth)** | `.templates/**/*.src.md` | Edit these |
| **Generated (do not edit)** | `.claude/agents/*.md`, `.claude/skills/*/SKILL.md`, `.claude/CLAUDE.md`, `.claude/common.md` | Overwritten by `configure.mjs` |
| **Config values** | `.config/config.yaml` | Substituted into templates via `{{ key }}` |

When reading a target for review, read the `.src.md`. When making changes, edit the `.src.md`.

**Mapping**: strip `.claude/`, prepend `.templates/`, insert `.src` before `.md`:
- `.claude/agents/researcher.md` → `.templates/agents/researcher.src.md`
- `.claude/skills/run/SKILL.md` → `.templates/skills/run/SKILL.src.md`
- `.claude/common.md` → `.templates/common.src.md`

**Architecture the template system is built to satisfy.** When your rewrite adds or relocates content, stay within these:

1. **Separation of concerns** — each file covers only its own responsibilities. Rules common to all workers live in `.templates/common.src.md` once.
2. **Low coupling** — minimize dependencies between files.
3. **File-path communication** — pass file paths rather than loading raw data into prompts; prevents prompt bloat and enables reuse.

---

## Prerequisite: Sync Upstream (per-target)

Templates live in `.templates/` and are shared via the upstream remote, so your local `.src.md` may be behind. Before reading or editing any `.src.md`, pull **only the path(s) you will touch** — not the whole framework:

```bash
bash .scripts/sync.sh pull <.src.md path>...
```

Example: `bash .scripts/sync.sh pull .templates/skills/improve/SKILL.src.md .templates/common.src.md`

**Why per-path, not bulk.** A bulk pull overwrites every tracked `.src.md` in the working tree with upstream's version. If a concurrent `/improve` session is mid-edit on another file, bulk pull destroys those uncommitted edits; and a later bulk push would revert that session's already-published changes, because bulk push ships the entire local framework as a snapshot. Path-scoped sync touches only what you name, so sessions working on disjoint files stay isolated.

**When to run the pull** — aligned to the Flow's entry-point fork (see next section):

- **Specific target known** — pull that path now, before reading.
- **Complaint without named target** — defer until step 1 identifies the target(s), then pull before reading.
- **Whole-system review** — run `sync.sh pull` with no arguments (bulk is the correct tool here, because the working set really is the whole framework and — by definition of this branch — you are not delegating any file to a concurrent session).

If you discover additional targets mid-rewrite, pull each before touching it.

**Residual risk (flagged as a fallback after climbing stopped here).** This protocol is convention-based: safety depends on every concurrent session also using path-scoped sync. A peer session that bulk-pulls or bulk-pushes can still clobber your in-flight work; commit often and inspect `git log upstream/main` before relying on local state when peers may have run. A stronger fix (lock file, dirty-path refusal in `sync.sh`, session registry) is deferred.

Paired with the path-scoped push in "Commit & Upstream Sync", this completes a per-file round-trip: pull → edit → push.

---

## Flow

After the Prerequisite:

```
1. Understand the complaint   — iterate questions until the root cause is visible
2. Propose a solution         — check external prior art, present one best case
3. Rewrite                    — edit .src.md at a scope that preserves coherence
4. Regenerate & verify        — configure.mjs, then prompt-reviewer agent
5. User confirmation & commit — push to upstream
```

If an argument is given, treat it as the complaint and go to step 1. If no argument is given, open with a single AskUserQuestion to establish the entry point (review the whole system / a specific target / a specific complaint), load only the files implied, then proceed to step 1.

---

## 1. Understand the complaint

Jumping to a solution before understanding almost always produces a symptomatic fix. A root-cause fix needs root-cause understanding.

**Division of labor by where information lives.** Information **inside the user** (motivation, constraints, what they've tried, values, judgment criteria) must be asked. Information **outside the user** (prior solutions to similar prompt-design problems, general prompt-engineering principles, adjacent-domain knowledge) is AI's job to fetch via web search and background knowledge. Sending the user to look up external information is a division-of-labor failure. Equally, prompt-design implementation choices — naming a concept, deciding what to foreground, predicting how an LLM will read wording, drawing the line between a specific instruction and a general principle — are AI's domain. Returning them to the user dumps a decision the user lacks material to make. If the user volunteers vocabulary, take it as data; do not invite them to decide.

**Every reply is a partial verbalization.** A single answer captures one facet, in one vocabulary, at one level of detail — not because the user is inarticulate but because verbalizing any internal state forces a choice that leaves other facets out. So questions do not end in one round: ask the same target from different facets, at different concreteness, under different hypotheses, and refine the integrated picture as precision grows. Start with a direct question. Read the reply as a partial verbalization — notice what facet it missed, where precision is thin, where it looks generated on the spot rather than genuine — and pick the next question: ask directly, name a facet and ask about it ("is it for this purpose?"), present a hypothesis and have the user evaluate it, raise concreteness, or surface a relevant area the user did not bring up. Not a lookup table — pick based on the texture of the reply. When a reply does not mesh with the stated complaint, hides in generalities, or looks like an ad-hoc answer, switch to hypothesis-presenting to re-ground it.

**AskUserQuestion operation.**

- **One question at a time.** Grouping embeds a hypothesis about the problem's structure and anchors both sides inside that frame. One-at-a-time lets each reply stand alone and the next question be re-planned.
- **Ask by axis, not by candidate.** Listing "A / B / C" forces a user whose real position fits none to pick the nearest or write Other — both distorting. A good question places the user on an axis (tradeoff dimension) so off-list answers still position themselves. Continuous preferences: odd-count scales (3 or 5) — do not binarize, the middle carries information. Discrete branches: 2 choices suffice. For finer resolution, add an axis, not an option — refining the list returns to the candidate trap.

**Integrated-picture checkpoints.** At junctures — during questioning, before proposing — reflect back "here is how I understand it" and let the user react. Partial-verbalization fragments cohere only after AI integrates them, and the integration can only be tested against the user's internal reaction. A correction is itself another partial verbalization: update the picture and, if needed, ask again from another facet.

**Stopping rule.** Not "understanding is complete" (unreachable — every reply is partial) but "the marginal precision from one more question is no longer worth the solution-quality gain". If a solution written now would miss a facet the user obviously cares about, ask one more. When in doubt, ask.

---

## 2. Propose a solution

**Check external prior art first.** Before generating a solution from scratch, see whether similar prompt-design problems have well-tested answers — web search, prompt-engineering best practices, adjacent-domain knowledge. This is the "outside the user" side of the division-of-labor rule, at the design step.

**One best case, not parallel alternatives.** Present the case you judge best, with reasons. Parallel alternatives dump the selection (a prompt-design judgment — see Section 1) back to the user, and additionally frame the interaction as menu-selection rather than critique, which discourages questioning the framing itself. The presented case is a discussion starting point, not a decision — if the user chooses a different direction, move there. The user's reaction is another partial verbalization, so expect one or two update cycles rather than one final reading.

---

## 3. Rewrite

Edit the target `.src.md`. For structural changes or large rewrites, use Write for the whole file — prompt files are small (typically < 200 lines) and whole-file replacement keeps coherence. For localized fixes, Edit suffices.

### Aim for universality

Universality is the **observable consequence** of a root-cause fix: specific instructions derive as consequences of one principle, so the text gets shorter, less repetitive, and easier to navigate. Failure produces the opposite fingerprint — per-symptom special cases pile up, the file grows, duplicates appear. Bloat, repetition, and hard-to-read prompts are signs the fixer did not climb high enough.

Before accepting a specific fix, pause and ask:

- What cause produced this symptom? What other symptoms could the same cause produce?
- Does my fix **subsume the old wording as a special case of a higher principle**, or does it merely **narrow the scope / add an exception / swap vocabulary**? If the latter, go back to the target's premises (as defined in the Core principle) and question those.
- Can the new wording absorb existing statements under a single more abstract principle? If yes, rewrite existing wording rather than adding a new item.
- After this change, is the file shorter or longer? A correctly-located root-cause fix often shortens it. If length grew, suspect the fix is still symptomatic.

Climbing sometimes fails. When it does, add the specific instruction and **mark explicitly that it is a fallback after failing to climb**, so it stays open to future re-examination. What must not happen is skipping the climb.

### Points to check while rewriting

- **Always give a reason.** With a reason, the LLM extrapolates correctly to edge cases. Without one, "do this" freezes into dogma that breaks in new contexts. Writing "why" is the smallest unit of universality — it pulls you toward the root cause.
- **No contradictions or premise mismatches.** Two places in the same file must not prescribe incompatible things; one instruction must not implicitly rely on a condition another instruction undermines.
- **Scope must be explicit.** "When to apply / when not to" — if ambiguous, the instruction leaks outside its intended range or fails inside it. Scope ambiguity is especially dangerous for prohibitions: a prohibition detached from its cause mechanically over-applies and chills legitimate behavior. Write the cause next to the prohibition.
- **Length proportional to importance, within what remains after universalization.** First, universality pulls total length *down* by removing derived items. Within what remains, length reflects relative importance — don't spend a paragraph on a one-line fix, don't bury a central instruction. A distilled root-cause principle can be short and still central; emphasis comes from position and framing, not raw word count alone.
- **Preserve `{{ placeholder }}` syntax** — config variables resolved by `configure.mjs`.

### Rewrite in coherence-preserving units

Choose the scope of the rewrite so that no contradictions or duplications remain with what surrounds it. For short files (most prompts here), the whole file is safest. For long files, rewrite the semantic unit — the section — that the change touches. Test: "after this change, are there contradictions or duplications with other parts of the file?" If yes, widen the scope.

---

## 4. Regenerate and verify

**Regenerate.** After writing the `.src.md`, run `node .scripts/configure.mjs` and confirm the generated output looks right.

**prompt-reviewer agent.** Dispatch a `subagent_type: "prompt-reviewer"` Agent on the rewritten file. The fixer knows the problem's history and overlooks residues and imbalance; a context-less reader catches that. Prompt:

```
Target file: {path}
Pay special attention to: {areas changed in this fix}
```

The agent's verification criteria live in its own prompt. It will report quoted passages, issue types, and suggested improvements.

**Reflect and confirm.** Apply valid findings and re-run `configure.mjs` if changes were made. Then present the final change to the user via AskUserQuestion for approval.

---

## Commit & Upstream Sync

After approval:

1. **Commit**: add changed `.src.md` files and their corresponding generated `.md` files individually with `git add` (not `git add -A`, to avoid committing unrelated changes). Message format: `improve: {summary}`.
2. **Push upstream (path-scoped)**: `bash .scripts/sync.sh push <changed .src.md path>... --yes`. Pass only the `.src.md` paths you edited — symmetric with the path-scoped pull in Prerequisite, for the same concurrency-isolation reason.
