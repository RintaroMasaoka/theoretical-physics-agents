---
name: improve
description: "Improve agent prompts and behavior. Follows a flow of gathering complaints → making fixes → verification to ensure quality."
user-invocable: true
argument-hint: "[complaint (optional)]"
---

# System Improvement

Improve the prompts that drive this project's agents and skills. `/improve` is the one interactive skill in this repo: the user describes a complaint, the AI traces it to the underlying mechanism, rewrites the relevant `.src.md` file(s), has an independent agent verify them, and confirms the final diff with the user via AskUserQuestion before committing.

Arguments: $ARGUMENTS

---

## Core principle — mechanism, not symptom

The largest failure mode of this skill is **symptomatic patching**: spotting a bad output and adding a new rule at the surface ("don't say X", "avoid this anti-pattern", "in this case do Y"). The model sidesteps the specific wording, but the same underlying mechanism keeps producing new variants of the same problem, and every cycle bolts on another patch until the prompt fragments.

**Mechanism-level fix**: trace the symptom back to its cause — why the behavior is undesirable, which tradeoff is being resolved wrongly, what the real priority is — and write that mechanism as a principle. "Because A matters more than B in this situation, prefer X over Y." A model that understands the mechanism extrapolates correctly into unseen cases, so the symptom disappears along with siblings the user has not yet reported.

Enumerating anti-patterns is the canonical shape of symptomatic patching: the named anti-pattern is a symptom, not a mechanism. If the mechanism is written, most of the anti-patterns follow as consequences and no longer need to be listed individually.

Before accepting any fix, apply this check:

- What mechanism produced this symptom? What other symptoms could the same mechanism produce?
- Does the new text **absorb** existing passages, or **sit alongside** them? A mechanism-level fix typically merges several scattered rules into one principle, so the new content lands by replacing, not by adding. If the fix only adds while nothing existing is revised, the principle has not actually been found yet — the new text is probably still a special case dressed up as a principle.

Climbing sometimes fails. A targeted rule is then an acceptable fallback, but flag it in the user-facing summary (not in the file itself) as a fallback so it can be revisited. Do not let the fallback become the default — skipping the attempt is the habit that produces symptom-layer prompts.

---

## Division of labor: What = user, How = AI

The user is the only source of the complaint — only they can say what feels wrong. The AI is responsible for translating that complaint into precise language and for designing the fix. Two moves violate this boundary:

- **AI guesses What**: skipping questions and inferring the complaint from the bad output alone. This burns the single channel that delivers ground truth about the problem.
- **AI outsources How**: asking "how would you like me to fix it?", or letting the artifacts of the discussion pass into the file unfiltered — the user's phrasing, the examples that happened to come up, the emphasis inherited from whichever concern was loudest. The user is the best witness of the problem, but not necessarily the best author of the fix; the discussion is input to understanding, not content for the file. Re-authoring the final text from the file's own purpose, not from the session's shape, is the AI's job.

All the rules below exist to protect this boundary.

---

## Flow

```
Argument provided → treat as initial complaint (equivalent to scope c below)
No argument       → AskUserQuestion to pick scope:
                     a) Review the whole system
                     b) Review a specific target (agent / skill / file)
                     c) Specific complaint (free-form)

Then, regardless of scope:
1. Understand — load files causally related to the complaint, then AskUserQuestion
2. Propose   — one best plan with reasoning, not a menu
3. Implement — rewrite `.src.md` at mechanism level, propagation check, regenerate
4. Verify    — prompt-reviewer agent → reflect findings → user confirms diff → commit & sync
```

File loading by scope: for (a), all agents + skills + `common.md` + `CLAUDE.md`; for (b), the target plus its upstream (`common.md` or invoking skill) and downstream consumers; for (c), only the files causally related to the complaint.

---

## 1. Understanding the complaint

Skipping this step is the main cause of symptomatic patches. Mechanism-level fixes require mechanism-level understanding, and that understanding must come from questioning, not from guessing off the bad output.

- **One question at a time via AskUserQuestion.** Grouping questions silently encodes a hypothesis about the problem's structure (that these concerns are linked, that this order matters). Asking independently lets each answer reshape the next question, so exploration is not locked to your initial guess.
- **Ask about axes, not about prescribed fixes.** "A or B or C?" forces the user into options you imagined. "Closer to more X, or more Y?" lets them locate themselves on a tradeoff. If you need finer resolution, add another axis rather than subdividing one axis into more options.
- **Stay on What.** See § Division of labor — "how should it be fixed?" is your question, not the user's.
- **Sufficiency test.** If you imagine writing the fix now and worry you will miss something the user obviously cares about, you are not done asking. One more question is cheaper than one wrong fix.
- **Echo before proposing.** Restate the problem in your words so the user can catch misreads before they are baked into a concrete proposal.

---

## 2. Proposing one best plan

After the echo-back is confirmed, present **one** plan — your best judgment together with the reasoning — not a menu. A menu pushes the decision back to the user; a single plan invites pushback on the *reasoning*, which is where real alignment happens. Treat the plan as a starting point for discussion; if the user redirects, follow.

---

## 3. Implementation

### Apply the core-principle check

Before committing to any change, run the two questions in § Core principle (what mechanism produced this symptom, and does the new text absorb existing passages or sit alongside them). This is not optional prelude — it is where the decision of *what to write* actually happens.

### Write reasons, not bare imperatives

"Do X" without "because Y" is rigid and breaks the first time a novel case appears. "Because Y, do X" lets the model extrapolate. Writing the reason is also the smallest unit of universalization — the act of writing *why* forces one level of abstraction up.

### Make text length match importance

Length and emphasis are read as importance signals. A minor nit inflated to a paragraph will be over-obeyed; a critical rule buried in prose will be missed. One-line fix → one line.

### Re-author from the file's purpose, not the session's shape

The discussion that produced the fix leaves artifacts — the user's phrasing, the examples that came up, the objections answered in a particular order, the emphasis inherited from the loudest concern. These are input for your understanding, but they are invisible to the cold reader, who can only anchor content to the file's stated subject. Before keeping any such artifact, ask: "would a reader who never saw the discussion still derive why this specific choice is here from the subject itself?" If not, re-author from the purpose; do not transcribe from the session.

### Rewrite in units of coherence

Patches stacked on top of older text contradict their own premises, and after a mechanism-level rewrite the new principle usually subsumes several old passages — leaving them in place produces a file that states both principle and redundant special cases. Whole-file `Write` is the safest unit when the resulting diff remains human-reviewable at a glance; switch to per-section edits when the file is long enough that a full rewrite obscures the actual change. The test for scope is: "after this fix, does anything else in the file now contradict or duplicate it?" If yes, include it in the rewrite.

### Propagation check

The prompts form a pipeline — skills orchestrate agents, agents share rules through `common.md`, agents pass outputs to downstream consumers. Changes cascade:

- Changed `common.md` → every agent and skill inherits from it; confirm none now contradict the new rule
- Changed `/run` or `/write` orchestration → the agents those skills delegate to must still match the new input contract
- Changed an agent's output format → downstream consumers (curator, writer, reviewer, …) expecting the old format need updating
- Changed `AGENTS.md` or `CLAUDE.md` → any specialized file that restates those rules needs to align
- Preserve `{{ key }}` placeholders intact — they are resolved per-project from `config.yaml`, so inlining a resolved value hardcodes one project's config into a template shared across downstream projects

If propagation is wide, update every affected file in the same pass. Half-done propagation surfaces as the next "something feels off" cycle.

---

## Template system

Prompt files are **generated**. Editing generated files is wrong because `configure.mjs` overwrites them.

| Layer | Path | Edit? |
|---|---|---|
| Template (source of truth) | `.templates/**/*.src.md` | Yes |
| Generated | `.claude/agents/*.md`, `.claude/skills/*/SKILL.md`, `.claude/CLAUDE.md`, `.claude/common.md` | No |
| Config | `.claude/config/config.yaml` | Yes |

Mapping from generated to template: strip `.claude/`, prepend `.templates/`, insert `.src` before `.md`.
- `.claude/agents/researcher.md` → `.templates/agents/researcher.src.md`
- `.claude/skills/run/SKILL.md` → `.templates/skills/run/SKILL.src.md`
- `.claude/common.md` → `.templates/common.src.md`

After editing `.src.md` files, run `node .scripts/configure.mjs` and skim the generated output to confirm substitution worked.

---

## 4. Verification

A `subagent_type: "prompt-reviewer"` Agent inspects the rewritten file as a first-time reader. The fixer knows the intent and is blind to leftover traces or imbalance; an independent reader catches them. The observation framework below is what separates a coherence check from a shallow proofread — each point names a specific mechanism of prompt decay, which is why the agent can judge edge cases rather than just matching patterns.

Prompt:

```
Review the rewritten prompt file as a first-time reader and report issues.

Target file: {path}
Focus area (what changed in this fix): {one-line summary}

## What this file must satisfy

The file is an instruction document for another LLM that reads it without context.
Verification is grounded in: "can a cold reader act correctly from just this text?"

## Observation points

### 1. Residue — overfit to a specific incident
Past incidents or failure cases referenced without being lifted to a general principle.
Examples illuminate a mechanism when tied to one; a bare example ("this happened once")
floats loose and reads as a symptomatic patch when the reader's situation differs.

### 2. Balance — text length vs. importance
A minor point given disproportionate space, or a critical instruction buried in prose.
Length and emphasis are read as importance signals; misalignment distorts priorities.
Paragraphs added late tend to be inflated by the context of the time.

### 3. Instructions without reasons — non-extrapolatability
"Do X" statements without "because Y". Without the reason, the reader can only follow
the exact shape of the rule and breaks at the first novel case.

### 4. Coherence of instructions — contradiction, premise, scope
(a) Contradictions within the same file.
(b) Implicit premises of one instruction broken elsewhere in the file.
(c) Ambiguous scope: when does the instruction apply, when does it not?

### 5. Duplication & scatter — non-localized information
The same intent stated in multiple places. The reader interprets each instance
slightly differently and cannot tell which takes precedence. Related statements
should live together, with references from the other places.

### 6. Unmotivated specifics — content not justified by the file itself
Specific examples, named cases, particular phrasings, or local emphasis whose
presence a reader of only this file cannot explain from the subject matter.
The reader has no access to whatever external process produced the text, so
any element that lands as "why *this* example, why *these* words, why *this*
emphasis here?" is a signal that the content is anchored to something outside
the file rather than to its own purpose. Test: "reading only this file, can I
derive why this specific choice is here from the subject?" If not, flag it —
the fixer can then tell whether the subject should motivate it explicitly or
the passage should be cut.

## Report format
For each finding: quoted passage, which observation point it hits, why it is a
problem grounded in that point's mechanism, and a concrete fix. If no issues,
report "no issues".
```

Relay the reviewer's valid findings to the user, apply them, regenerate via `configure.mjs` if anything changed, and confirm the final diff with the user via AskUserQuestion. User approval is the single gate between verification and commit.

---

## Commit & upstream sync

Once approved:

1. **Commit**: `git add` each changed `.src.md` and its generated `.md` counterpart individually (avoid `git add -A`, which picks up unrelated changes). Message format: `improve: {summary}`
2. **Upstream sync**: Run `bash .scripts/sync.sh push --yes` to push framework changes (`.templates/`, config, `AGENTS.md`, `.scripts/`) to the upstream remote — the public repo that other projects pull from. This keeps all downstream projects aligned with the improvement.
