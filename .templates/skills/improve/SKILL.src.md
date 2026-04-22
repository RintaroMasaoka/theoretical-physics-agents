---
name: improve
description: "Improve agent prompts and behavior. Follows a flow of gathering complaints → making fixes → verification to ensure quality."
user-invocable: true
argument-hint: "[complaint (optional)]"
---

# System Improvement

Improve the output quality of agents and skills. The user just describes "what's unsatisfactory." AI designs and executes the fix, and an independent agent verifies quality.

Arguments: $ARGUMENTS

---

## Template System

This project uses a template-based generation system. Prompt files are generated from templates — editing generated files directly is incorrect because `.scripts/configure.mjs` overwrites them on each run. Templates are shared with downstream projects via an upstream remote: you pull from it to stay current with others' improvements, and push to it to share your own. Both directions matter (see Prerequisite and Commit & Upstream Sync).

| Layer | Path | Role |
|---|---|---|
| **Template (source of truth)** | `.templates/**/*.src.md` | Edit these |
| **Generated (do not edit)** | `.claude/agents/*.md`, `.claude/skills/*/SKILL.md`, `.claude/CLAUDE.md`, `.claude/common.md` | Overwritten by `node .scripts/configure.mjs` |
| **Config values** | `.claude/config/config.yaml` | Variables substituted into templates via `{{ key }}` syntax |

When reading a target for review, read the `.src.md` file. When making changes, edit the `.src.md` file.

**Mapping**: To find the template for a generated file, strip the `.claude/` prefix, prepend `.templates/`, and insert `.src` before `.md`:
- `.claude/agents/researcher.md` → `.templates/agents/researcher.src.md`
- `.claude/skills/run/SKILL.md` → `.templates/skills/run/SKILL.src.md`
- `.claude/common.md` → `.templates/common.src.md`

---

## Prerequisite: Sync Upstream

Because templates are shared across downstream projects via an upstream remote (see Template System above), your local `.src.md` files may be behind upstream. Before reading or editing any `.src.md` file, run:

```bash
bash .scripts/sync.sh pull
```

Do not read or edit `.src.md` files, do not run `configure.mjs` until this completes. Reading a stale template risks designing a fix against outdated content; editing one and then pushing would overwrite upstream improvements that others have already contributed. Paired with the push in "Commit & Upstream Sync", this pull completes the round-trip: pull → edit → push.

---

## Flow

Complete the Prerequisite (upstream pull) before any branch below. Then:

```
Argument provided → Treat as complaint → Confirm nuances → Execute fix
No argument → AskUserQuestion to clarify intent (3 choices + Other for free-form complaint)

1. "Review the whole system":
    ▼ Data loading: all agent definitions + SKILL.md files
    ▼ AI reviews and presents improvement points
    ▼ AskUserQuestion: select which improvements to adopt
    ▼ Execute fix

2. "Review a specific target":
    ▼ AskUserQuestion: ask user to specify the target (agent name, skill name, file path, etc.)
    ▼ Data loading: only the relevant file(s)
    ▼ AI reviews and presents improvement points
    ▼ AskUserQuestion: select which improvements to adopt
    ▼ Execute fix

3. Has a specific complaint (described in Other):
    ▼ Data loading: only files related to the complaint
    ▼ Align on nuances with the user before deciding the fix approach
    ▼ Execute fix
```

---

## Executing the Fix

### 1. Rewrite

Edit the target `.src.md` file. For structural changes or large rewrites, use Write to replace the entire file — prompt files are small (typically < 200 lines), so whole-file regeneration maintains coherence. For localized fixes, Edit suffices.

Guidelines for rewriting (see Prompt Design Spec for architecture principles):
- Describe the correct approach naturally. Instead of "don't do X" (prohibition), write what should be done
- Write proportionally to the importance of the fix. Don't use a paragraph for a one-line fix
- Add reasons to instructions. With reasons, AI can judge edge cases. Without reasons, instructions become rigid dogma
- Preserve `{{ placeholder }}` syntax — these are config variables resolved by `.scripts/configure.mjs`

### 2. Regenerate

After writing the `.src.md` file, run `node .scripts/configure.mjs` to regenerate all runtime files. Verify the generated output matches expectations.

### 3. Verification Agent

Have a `subagent_type: "prompt-reviewer"` Agent verify the rewritten file. The prompt-reviewer reads the file as a first-time reader with no change context, catching coherence issues the fixer would overlook.

Prompt:
```
## Task

Target file: {path}

Pay special attention to: {areas changed in this fix}
```

### 4. Reflect Verification Results

Report the verification agent's findings to the user, and fix any valid findings. If fixes are made, run `node .scripts/configure.mjs` again.

### 5. User Confirmation

Get approval from the user via AskUserQuestion before committing.

---

## Prompt Design Spec

Architecture principles for prompt files. Check these are satisfied when rewriting.

1. Separation of concerns — Each file covers only its own responsibilities. Common rules go in `.templates/common.src.md` once only
2. Low coupling — Minimize dependencies between files
3. File-path communication — Instead of loading raw data into prompts, write to files and pass paths (prevents prompt bloat and enables data reuse)

---

## Commit & Upstream Sync

After the user approves, commit and push to upstream in one step:

1. **Git commit**: Add changed `.src.md` files and their corresponding generated `.md` files individually with `git add` (not `git add -A`, to avoid committing unrelated changes). Message format: `improve: {summary of changes}`
2. **Upstream sync**: Run `bash .scripts/sync.sh push --yes` — this is the other half of the pull in Prerequisite. Pull ensured you edited fresh templates; push shares your improvements back to the upstream remote so other downstream projects can pull them.
