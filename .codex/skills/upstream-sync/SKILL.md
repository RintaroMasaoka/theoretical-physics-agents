---
name: upstream-sync
description: "Synchronize framework-level changes between a child research project and the upstream theoretical-physics-agents framework. Use for pulling framework files before editing them or pushing prompt/script/config/workflow improvements upstream."
user-invocable: true
argument-hint: "status|doctor|pull <path...>|push <path...>"
---

# upstream-sync — Framework Synchronization

Synchronize framework-level files between this child research project and the upstream `theoretical-physics-agents` framework.

Arguments: $ARGUMENTS

Use this skill whenever the task is about framework files rather than project research artifacts. Framework files include `README.md`, `.gitignore`, `.github/`, `.config/`, `.scripts/`, runtime hook settings, and `.templates/`.

Do not use plain `git push` for framework feedback from a child project. The sync script performs path-scoped copying, regenerates runtime files in the upstream candidate tree, and checks framework-internal references before pushing.

## Remote Layout

The intended child-project remote layout is:

- `origin`: the child research project's own repository
- `upstream`: `https://github.com/RintaroMasaoka/theoretical-physics-agents.git`

Start every sync operation with:

```bash
bash .scripts/sync.sh doctor
```

If `doctor` reports that `origin` points at `theoretical-physics-agents`, stop and report the remote layout problem. The user must set `origin` to the child project repo and add `upstream` for the framework before real upstream sync can proceed.

## Status

To inspect framework differences:

```bash
bash .scripts/sync.sh status
```

`status` compares local and upstream framework files in both directions, including local-only files. A newly created framework file, such as a helper script or config file, must show up here before it can be pushed safely.

## Pull Before Editing

Before editing a known framework path, pull only the file or directory you will touch:

```bash
bash .scripts/sync.sh pull <path>...
```

Examples:

```bash
bash .scripts/sync.sh pull .templates/skills/improve/SKILL.src.md
bash .scripts/sync.sh pull .scripts/sync.sh
```

Prefer path-scoped pull. Bulk pull is only appropriate when the working set is explicitly the whole framework and there is no concurrent framework-edit session whose uncommitted work could be overwritten.

## Push Framework Changes

After editing framework files and running `node .scripts/generate-runtime.mjs`, push the complete path set needed by the change:

```bash
bash .scripts/sync.sh push <path>... --yes
```

Pass source paths, not only generated runtime files. For prompt changes, pass the `.templates/...src.md` files. For support files, pass the concrete file or owning directory.

When a framework file references another framework-owned path, include the referenced file too. For example, if templates now tell agents to run `.scripts/log-path.sh`, push both the templates and `.scripts/log-path.sh`:

```bash
bash .scripts/sync.sh push .templates/ .scripts/log-path.sh --yes
```

The script checks the candidate upstream tree after rendering. If a framework file references a missing path under framework-owned roots such as `.scripts/`, `.config/`, `.github/`, or `.templates/`, the push fails before publishing.

## Choosing Paths

Use the smallest coherent path set:

- Prompt wording change in one skill: the changed `.templates/.../SKILL.src.md`
- Shared prompt rule affecting many generated files: the changed `.templates/...src.md` source files
- New framework helper: the referring templates plus the helper file under `.scripts/`
- Sync mechanism change: `.scripts/sync.sh` plus any docs/templates that describe the workflow
- Runtime hook or generated-file config change: the runtime hook settings file, `.config/`, or `.scripts/generate-runtime.mjs` as applicable
- Documentation of framework operation: `README.md`

Do not pass project artifacts such as `research/`, `logs/`, `manuscript/`, `literature/`, `agenda.md`, or other project-specific state files; the script rejects paths outside the framework-owned set.

## Verification

Before reporting success:

```bash
bash -n .scripts/sync.sh
node .scripts/generate-runtime.mjs --check
bash .scripts/sync.sh status
```

If `status` still reports local-only or changed framework files, either include those paths in a follow-up push or explain why they are intentionally not part of the upstream sync.
