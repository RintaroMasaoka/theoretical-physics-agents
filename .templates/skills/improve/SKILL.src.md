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

## Problem-space discipline before solution-space work

This skill's first duty is not to edit prompts; it is to **frame the right problem**. A plausible fix found early is evidence about the problem, not permission to start rewriting. Early fixes are dangerous because they collapse the problem space around the first local symptom, making adjacent axes invisible: ownership, audience, information flow, lifecycle, scope, authority, and the user's actual dissatisfaction.

Treat the work as two separated modes:

1. **Problem-space work** — discover and define what is wrong. Broaden first: identify the visible symptom, the user's value judgment, the affected workflow, adjacent design axes, and at least one alternative framing. Then narrow: state the integrated problem in your own words and test whether it explains the observed complaint and nearby likely failures.
2. **Solution-space work** — only after the problem frame is explicit, choose and implement the best prompt change.

While in problem-space work, keep candidate fixes in quarantine. You may name them as hypotheses ("one possible fix would be X, but first I need to know whether the real issue is Y"), but you must not edit files, regenerate prompts, or present an implementation plan as settled. The checkpoint that permits solution-space work is a concise integrated picture: **symptom → underlying cause → affected surfaces → success criterion → why a prompt change here is the right lever**. If any part is still vague and the user is available, ask; if the user is not available, state the uncertainty and choose a conservative next investigation, not a rewrite.

---

## Template System

Prompt files are generated from templates — editing generated files directly is wrong because `.scripts/configure.mjs` overwrites them on each run. Templates are shared with downstream projects via an upstream remote: pull to stay current, push to share.

| Layer | Path | Role |
|---|---|---|
| **Template (source of truth)** | `.templates/**/*.src.md` | Edit these |
| **Generated (do not edit)** | `{{ runtime.agents_dir }}/*.md`, `{{ runtime.skills_dir }}/*/SKILL.md`, `{{ runtime.instruction_file }}`, `{{ runtime.common_file }}` | Overwritten by `configure.mjs` |
| **Config values** | `{{ runtime.config_source_file }}` | Substituted into templates via `{{ key }}` |

When reading a target for review, read the `.src.md`. When making changes, edit the `.src.md`.

**Mapping**: strip `{{ runtime.root_dir }}/`, prepend `.templates/`, insert `.src` before `.md`:
- `{{ runtime.agents_dir }}/researcher.md` → `.templates/agents/researcher.src.md`
- `{{ runtime.skills_dir }}/auto/SKILL.md` → `.templates/skills/auto/SKILL.src.md`
- `{{ runtime.common_file }}` → `.templates/common.src.md`

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

**Residual risk.** This protocol is convention-based: safety depends on every concurrent session also using path-scoped sync. A peer session that bulk-pulls or bulk-pushes can still clobber your in-flight work; commit often and inspect `git log upstream/main` before relying on local state when peers may have run. Stronger locking is outside this skill's current scope.

Paired with the path-scoped push in "Commit & Upstream Sync", this completes a per-file round-trip: pull → edit → push.

---

## Flow

After the Prerequisite:

```
1. Frame the problem          — stay in problem-space until the integrated picture is explicit
2. Propose a solution         — check external prior art, present one best case grounded in the frame
3. Rewrite                    — edit .src.md at a scope that preserves coherence
4. Regenerate & verify        — configure.mjs, blind prompt-reviewer, then fit-to-complaint check
5. User confirmation & commit — push to upstream
```

If an argument is given, treat it as the starting complaint, not as a complete problem statement, and go to step 1. If no argument is given, open with a single {{ runtime.tool_ask_user_question }} to establish the entry point (review the whole system / a specific target / a specific complaint), load only the files implied, then proceed to step 1.

**Gate between steps 2 and 3.** For any improvement that involves conceptual design — changing responsibilities, workflow, abstraction level, authority boundaries, verification policy, or behavior tradeoffs — do not enter Rewrite until the user explicitly approves the problem frame and proposed solution. The AI may judge that a frame is coherent enough to present, but may not treat that judgment as implementation permission. Ambiguous agreement, silence, or the user adding another concern means continue discussion, not edit.

Narrow exception: purely mechanical fixes may proceed without this approval gate when they do not require problem framing, such as typo fixes, placeholder syntax repairs, generated/source path corrections, or an obvious runtime-conditional omission after the user has already accepted the underlying rule. If a fix changes what an agent should value, decide, prioritise, or ask, it is conceptual and needs approval.

---

## 1. Frame the problem

Jumping to a solution before understanding almost always produces a symptomatic fix. A root-cause fix needs root-cause understanding.

**The user's complaint may be pre-problem, not a spec.** The user often arrives with a discomfort, an example, or a proposed move before they have organised the problem for themselves. In that state, implementation is the wrong thinking tool: it turns the AI's first diagnosis into a concrete artifact, which then makes the user react to the artifact ("maybe change this, maybe that") instead of jointly discovering the underlying problem. That loop feels productive but is usually patch churn. Treat the discussion phase as the place where the user's observation is converted into a problem frame; do not use edits as the medium for doing that conversion.

**Do not treat the first plausible fix as progress.** In `/improve`, premature implementation is usually a reasoning failure, not decisiveness: it spends the user's trust before the system has proved it understands the complaint. The right early output is an integrated problem frame, not a patch. If the user challenges your framing, that is useful data; if the user challenges a patch you already made, you have forced them into code-reviewing your misunderstanding.

**Discussion has its own deliverable.** Before proposing an edit, produce a shared problem understanding that is valuable even if no file changes. It should explain: what the user observed, why it bothered them, what hidden expectation or workflow model it violated, what concept abstracts the issue beyond this example, and what would count as improvement. If the user cannot yet answer one of those, keep asking; the inability to answer is itself evidence that the problem is not ready for implementation.

**Division of labor by where information lives.** Information **inside the user** (motivation, constraints, what they've tried, values, judgment criteria) must be asked. Information **outside the user** (prior solutions to similar prompt-design problems, general prompt-engineering principles, adjacent-domain knowledge) is AI's job to fetch via web search and background knowledge. Sending the user to look up external information is a division-of-labor failure. Equally, prompt-design implementation choices — naming a concept, deciding what to foreground, predicting how an LLM will read wording, drawing the line between a specific instruction and a general principle — are AI's domain. Returning them to the user dumps a decision the user lacks material to make. If the user volunteers vocabulary, take it as data; do not invite them to decide.

**Broaden before narrowing.** Before choosing a target or edit, inspect adjacent axes that could change the diagnosis: whether the problem is about timing, authorship, authority, context loading, persistence, user visibility, lifecycle, evaluation, or handoff. A complaint often names the place where pain surfaced, not the place where the design is wrong. For example, "this file should exist here" may actually be about memory durability, write ownership, reader audience, or task-local versus project-global scope. If a proposed fix would be different under one of these framings, the framing is not settled yet.

**How-language is a danger signal.** Users often express a deep dissatisfaction in the language of an implementation move: "put X here", "make Y do Z", "rename this", "add a file", "forbid that". Treat such `how` wording as a hypothesis about the problem, not the problem itself. The missing information is usually the `why`: what observation triggered the proposal, what responsibility boundary looked wrong, what workflow pressure made the current design feel distorted, or what value tradeoff the user is trying to protect. Do not hard-code a single question like "why do you think that?"; choose the least distorting move for the situation — ask for the originating observation, restate a likely hidden concern and invite correction, or compare two plausible framings. The rule is: if the user gave a `how` without enough `why`, recover the `why` before editing.

**Minimum inquiry loop.** In ambiguous complaints, cycle through these facets before leaving problem-space:

1. **Originating observation** — what concrete behaviour, output, or interaction made the user dissatisfied?
2. **Felt mismatch** — why did that behaviour feel wrong; what expectation did it violate?
3. **Cost of the mismatch** — what work did the user have to do because of it, or what risk did it create?
4. **Abstraction** — what general concept explains this instance and nearby likely failures?
5. **Success test** — how would the user recognise that future behaviour changed?

Do not run this as a questionnaire when one answer naturally covers several facets. The point is not form completion; it is preventing the AI from substituting its own tidy diagnosis for the user's still-forming judgment. If the user corrects the abstraction, treat that as progress and revise the frame before discussing edits.

**Every reply is a partial verbalization.** A single answer captures one facet, in one vocabulary, at one level of detail — not because the user is inarticulate but because verbalizing any internal state forces a choice that leaves other facets out. So questions do not end in one round: ask the same target from different facets, at different concreteness, under different hypotheses, and refine the integrated picture as precision grows. Start with a direct question. Read the reply as a partial verbalization — notice what facet it missed, where precision is thin, where it looks generated on the spot rather than genuine — and pick the next question: ask directly, name a facet and ask about it ("is it for this purpose?"), present a hypothesis and have the user evaluate it, raise concreteness, or surface a relevant area the user did not bring up. Not a lookup table — pick based on the texture of the reply. When a reply does not mesh with the stated complaint, hides in generalities, or looks like an ad-hoc answer, switch to hypothesis-presenting to re-ground it.

**{{ runtime.tool_ask_user_question }} operation.**

- **One question at a time.** Grouping embeds a hypothesis about the problem's structure and anchors both sides inside that frame. One-at-a-time lets each reply stand alone and the next question be re-planned.
- **Ask by axis, not by candidate.** Listing "A / B / C" forces a user whose real position fits none to pick the nearest or write Other — both distorting. A good question places the user on an axis (tradeoff dimension) so off-list answers still position themselves. Continuous preferences: odd-count scales (3 or 5) — do not binarize, the middle carries information. Discrete branches: 2 choices suffice. For finer resolution, add an axis, not an option — refining the list returns to the candidate trap.

**Integrated-picture checkpoints.** At junctures — during questioning, before proposing — reflect back "here is how I understand it" and let the user react. Partial-verbalization fragments cohere only after AI integrates them, and the integration can only be tested against the user's internal reaction. A correction is itself another partial verbalization: update the picture and, if needed, ask again from another facet. The final checkpoint before solution-space work must cover:

- **Symptom**: what happened that disappointed the user
- **Underlying cause**: what premise, tradeoff, or workflow pressure produced it
- **Affected surfaces**: which prompts/files/roles/lifecycle steps could be implicated
- **Success criterion**: how the user would tell the behavior has changed
- **Edit lever**: why a prompt change, and this prompt location, is the right lever

The checkpoint must be explicit in the conversation before editing. If the user gave only a target file or a desired edit, that does not satisfy the checkpoint. For conceptual changes, user confirmation of the frame and proposed solution is the permission boundary: do not proceed because the AI believes enough correction has been gathered. Ask for approval plainly after presenting the frame and proposal; if the user does not approve, keep discussing.

**Stopping rule.** Not "understanding is complete" (unreachable — every reply is partial) but "the marginal precision from one more question is no longer worth the solution-quality gain". If a solution written now would miss a facet the user obviously cares about, ask one more. When in doubt, ask.

---

## 2. Propose a solution

**Check external prior art for conceptual changes.** Before generating a conceptual prompt-design solution from scratch, see whether similar problems have well-tested answers — web search, prompt-engineering best practices, adjacent-domain knowledge. Mechanical repairs do not need this step unless the local convention is unclear. This is the "outside the user" side of the division-of-labor rule, at the design step.

**Start the proposal with the problem frame.** The first paragraph of the proposal should say what problem you believe you are solving and why the obvious local fix is insufficient or sufficient. This makes the proposal falsifiable before implementation. If you cannot state the frame crisply, return to Section 1; do not compensate with a longer solution.

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
- **Runtime neutrality in templates.** A `.src.md` file is a multi-runtime contract, not the current agent's private prompt. Do not write the source as if the runtime you are currently using is the only reader. If Claude and Codex need different operational instructions, express the shared principle once and put the runtime-specific mechanics inside `{{#if runtime.is_codex}} ... {{else}} ... {{/if}}` blocks (or the corresponding runtime config placeholder). This prevents a Codex `/improve` session from accidentally making the Claude output worse, and vice versa.
- **Length proportional to importance, within what remains after universalization.** First, universality pulls total length *down* by removing derived items. Within what remains, length reflects relative importance — don't spend a paragraph on a one-line fix, don't bury a central instruction. A distilled root-cause principle can be short and still central; emphasis comes from position and framing, not raw word count alone.
- **Preserve `{{ placeholder }}` syntax** — config variables resolved by `configure.mjs`.

### Rewrite in coherence-preserving units

Choose the scope of the rewrite so that no contradictions or duplications remain with what surrounds it. For short files (most prompts here), the whole file is safest. For long files, rewrite the semantic unit — the section — that the change touches. Test: "after this change, are there contradictions or duplications with other parts of the file?" If yes, widen the scope.

---

## 4. Regenerate and verify

**Regenerate.** After writing the `.src.md`, run `node .scripts/configure.mjs` and confirm the generated output looks right.

**Blind prompt-reviewer.** Run the prompt-reviewer as a blind coherence check on the rewritten file. The reviewer is the guard against the fixer flattering the user's complaint by overfitting the prompt, over-emphasising the incident, or leaving debate traces that feel responsive but weaken the document.

The reviewer must receive only the target file and the review instructions, not the complaint, conversation history, problem frame, or intended fix. Its value comes from not knowing what the edit was trying to satisfy.

{{#if runtime.is_codex}}
Codex has two runtime constraints:

1. Codex may only spawn sub-agents when the user explicitly asks for sub-agents, delegation, or parallel agent work.
2. Codex does not support custom named `agent_type` values for local prompt files.

Invoking `/improve` is an explicit request for this skill's workflow, and this workflow includes independent reviewer verification. Therefore, do not ask again before blind review in Codex. Launch the default/general sub-agent mechanism available in the current Codex runtime with no custom `agent_type`, and explicitly instruct it to read and follow `{{ runtime.agents_dir }}/prompt-reviewer.md`, then review only the target file. Do not replace this with an informal "please review" prompt; that silently drops the checklist.

If the current runtime still refuses agent launch, or the user explicitly disables reviewer agents for this run, do not spawn. Record that independent blind review was not run because reviewer-agent launch was unavailable or disabled, then perform the fit-to-complaint check yourself and surface the residual verification gap in the final report.
{{else}}
Dispatch `prompt-reviewer` through {{ runtime.tool_agent }} on the rewritten file, using `{{ runtime.tool_agent_type_field }}: "prompt-reviewer"` where the runtime requires an agent-type field.
{{/if}}

```
Target file: {path}
Review only the target file. Apply the prompt-reviewer checklist as a blind coherence review. Do not inspect the conversation, diff, complaint, problem frame, intended fix, or changed areas.
```

The agent's verification criteria live in its own prompt. It will report quoted passages, issue types, and suggested improvements.

**Fit-to-complaint check.** After the blind review, run a separate fit check yourself before asking for user approval. Use only the explicit problem frame from step 1, the success criterion, and the diff; do not re-open the whole conversation to mine extra justification. The check must answer:

- Does the change address the user's originating observation, not merely the latest wording?
- Is the success criterion represented as an operational prompt constraint?
- Is the fix phrased at the abstract concept level rather than as an incident patch?
- Did the blind reviewer find coherence issues that would make the fit illusory? If the reviewer was not run because the runtime/user did not permit agent launch, what residual coherence risk remains?
- Did the change overreact by adding weight, ceremony, or prohibitions beyond the problem frame?

If the fit check fails, return to problem framing or rewrite as appropriate. Do not ask the user to approve a change that only passed blind coherence.

**Reflect and confirm.** Apply valid blind-review findings and fit-check findings, then re-run `configure.mjs` if changes were made. Then present the final change to the user via {{ runtime.tool_ask_user_question }} for approval.

---

## Commit & Upstream Sync

After approval:

1. **Commit**: add changed `.src.md` files and their corresponding generated `.md` files individually with `git add` (not `git add -A`, to avoid committing unrelated changes). Message format: `improve: {summary}`.
2. **Push upstream (path-scoped)**: `bash .scripts/sync.sh push <changed .src.md path>... --yes`. Pass only the `.src.md` paths you edited — symmetric with the path-scoped pull in Prerequisite, for the same concurrency-isolation reason.
