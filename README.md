# Theoretical Physics Research Agents

Autonomous research and paper-writing framework for theoretical physics projects.

This repository is meant to be copied into a concrete research project. It gives
Claude Code and Codex a shared set of agents, skills, project-state conventions,
and safety guards so they can run long research sessions, maintain a research
tree, and eventually draft a paper from accumulated results.

The instruction source of truth is runtime-agnostic:

- `.templates/` contains the editable prompt and skill templates
- `.config/config.yaml` contains shared configuration values
- `.scripts/configure.mjs` renders runtime files into `.claude/` and `.codex/`

Generated files under `.claude/` and `.codex/` are overwritten by the configure
step. Edit `.templates/**/*.src.md` instead.

## Current Status

As of 2026-04-30, the research workflow is the most mature part of the system.
Use `/launch`, `/meeting`, and `/run` as the main operating loop. The writing
workflow exists and is structured, but should still be treated as experimental
until it has been exercised more in real end-to-end paper projects.

Practical expectation:

- `/launch`: usable for initializing or changing a research direction
- `/meeting`: usable for human-in-the-loop review and course correction
- `/run`: main autonomous research loop
- `/write`: experimental paper drafting loop
- `/improve`: framework prompt and behavior improvement workflow
- `/upstream-sync`: framework synchronization workflow for child projects
- `/fetch-arxiv`: helper for fetching arXiv PDFs and sources through GitHub Actions

## Operating Model

The system separates research, record-keeping, verification, and writing.

### `/run`: peer-agent research team

`/run` is a thin scheduler. It does not make scientific judgments itself; it
dispatches specialist agents and routes their outputs through independent review
and curation.

| Role | Agent | Owns |
|---|---|---|
| Direction | `physicist` | `research/focus.md`, next questions, dispatch plans, tree directives |
| Record | `curator` | `research/**` writes, including `log.md`, `plan.md`, `note.md`, `report_*.md`, node creation, and status updates |
| Verification | `critic` | Independent review of worker deliverables and curator-lifted `note.md` derivations |
| Execution | `researcher`, `simulator`, `reader`, `scout`, `engine-builder`, `concept-checker`, `self-check` | Bounded research tasks and deliverables under `logs/` |
| Session finalization | `session-wrap-up` | Session logs, handoff files, focus updates, agenda, commit/push mechanics |

During `/run`, user questions are avoided because runs are expected to continue
while the user is away. If the user interrupts with a correction, the newest user
instruction takes precedence.

### `/write`: PI-led paper drafting

`/write` keeps a PI-style structure because paper drafting is a coherent
narrative task. It uses agents such as `outliner`, `writer`, `reviewer`,
`finalizer`, and `reference-auditor` to produce and check manuscript artifacts.

`/write` reads the research tree and writes under `manuscript/` and `logs/`. It
does not conduct new research; gaps found during writing are reported back to
`agenda.md` for later `/meeting` or `/run` work.

## Quick Start

### Prerequisites

- A compatible coding-agent environment
- Claude Code if you want to use `.claude/`
- Codex if you want to use `.codex/`
- Node.js for `.scripts/configure.mjs`
- GitHub access if you want `/fetch-arxiv` or upstream framework sync

### Setup

```bash
git clone <this-repo-or-your-project-repo> my-research-project
cd my-research-project
node .scripts/configure.mjs
```

If you downloaded this framework as a GitHub archive and want the contents
directly in the current directory:

```bash
mkdir my-research-project
cd my-research-project
curl -L https://github.com/RintaroMasaoka/theoretical-physics-agents/archive/refs/heads/main.tar.gz | tar xz --strip-components=1
node .scripts/configure.mjs
```

### Start a Project

1. Run `/launch` to set the research theme and initialize `research/`.
2. Run `/meeting` when you want an interactive progress review or direction change.
3. Run `/run 2` for a short autonomous research test.
4. Inspect `research/focus.md`, `research/**`, `logs/last_session.md`, and `agenda.md`.
5. Use larger `/run N` sessions once the direction is stable.
6. Try `/write 2` only after the research tree has enough stable material.

## Commands

| Command | Purpose | Notes |
|---|---|---|
| `/launch [theme]` | Set or change the research theme and initialize the research tree | Interactive |
| `/meeting [topic]` | Review progress, discuss agenda items, and course-correct | Interactive |
| `/run [N]` | Execute autonomous research cycles | Default `N` comes from `.config/config.yaml` |
| `/write [N]` | Draft and refine manuscript artifacts from the research tree | Experimental |
| `/improve [complaint]` | Improve framework prompts, skills, and behavior | Edits templates, then regenerates runtime files |
| `/upstream-sync status|doctor|pull|push` | Sync framework-level files with upstream | Prefer path-scoped operations |
| `/fetch-arxiv ARXIV_ID...` | Fetch arXiv PDFs and LaTeX sources via GitHub Actions | Supports new and legacy arXiv IDs |

## Repository Layout

```text
README.md

.config/
└── config.yaml                 # Shared editable config

.scripts/
├── configure.mjs               # Renders .templates/ into .claude/ and .codex/
├── sync.sh                     # Path-scoped framework upstream sync
├── git-pre-push-guard.sh       # Refuses accidental framework pushes
├── fetch-arxiv.sh              # GitHub Actions relay for arXiv downloads
└── log-path.sh                 # Timestamped log path helper

.templates/
├── AGENTS.src.md               # Root instruction template
├── common.src.md               # Shared worker rules
├── notes-syntax.src.md         # Wiki-link and provenance tag syntax
├── research-tree.src.md        # Canonical research tree data model
├── agents/*.src.md             # Agent templates
└── skills/*/SKILL.src.md       # Skill templates

.claude/                        # Generated Claude Code runtime files
.codex/                         # Generated Codex runtime files
```

Typical project artifacts created during real work:

```text
research/
├── note.md                     # Root source-of-truth synthesis
├── log.md                      # Root research process state
├── story.md                    # Paper narrative / tree structure
├── principles.md               # Cross-cutting constraints
├── focus.md                    # Current run cursor and dispatch interface
└── <node>/
    ├── log.md
    ├── plan.md
    ├── note.md
    ├── report_*.md
    ├── src/
    ├── data/
    └── images/

concepts/                       # Atomic concept notes linked with [[wiki-links]]
literature/papers/              # arXiv PDFs and extracted sources
manuscript/                     # /write output
logs/                           # Worker deliverables and session records
agenda.md                       # Items for the next meeting or run
```

## Research Tree

`research/` is the durable project memory. Every research node is a folder.
Important files have distinct roles:

| File | Role |
|---|---|
| `note.md` | Source-of-truth prose. Principal claims require both derivation or citation and a verification provenance tag |
| `log.md` | Process state with frontmatter, current state, and append-only evidence |
| `plan.md` | Node strategy and decomposition rationale |
| `report_{slug}.md` | Promoted verified report from a worker deliverable |
| `story.md` | Narrative ordering of children |
| `principles.md` | Constraints for a subtree |
| `dead_ends.md` | Rejected approaches and why they failed |
| `asides.md` | Parked off-thread ideas |
| `src/`, `data/`, `images/` | Computation artifacts tied to a node |

Folder names are semantic, stable slugs, not numbered narrative positions.
Narrative order belongs in `story.md` or `plan.md`, not in path names.

The canonical specification is `.templates/research-tree.src.md`, rendered to
`.claude/research-tree.md` and `.codex/research-tree.md`.

## Configuration

Edit `.config/config.yaml`, then regenerate runtime files:

```bash
node .scripts/configure.mjs
```

Supported config keys:

| Key | Meaning |
|---|---|
| `language` | User-facing and internal project prose language |
| `simulation.language` | Preferred simulation language |
| `simulation.visualization` | Preferred plotting backend |
| `cycles.run` | Default `/run` cycle count |
| `cycles.write` | Default `/write` cycle count |

Useful configure commands:

```bash
node .scripts/configure.mjs --check
node .scripts/configure.mjs --dry-run
node .scripts/configure.mjs --target claude
node .scripts/configure.mjs --target codex
```

Claude Code also has a session-start hook in `.claude/settings.json` that runs
the configure step automatically.

## Git Remotes and Upstream Sync

Child research projects should use two remotes:

- `origin`: the private or project-owned research repository
- `upstream`: `https://github.com/RintaroMasaoka/theoretical-physics-agents.git`

Set them explicitly:

```bash
git remote set-url origin <your-project-repo-url>
git remote add upstream https://github.com/RintaroMasaoka/theoretical-physics-agents.git
```

`.scripts/configure.mjs` installs a local `pre-push` guard that refuses plain
pushes to the framework repository. This prevents accidentally treating
`RintaroMasaoka/theoretical-physics-agents` as a private research project
remote.

Framework improvements from a child project should go through `/upstream-sync`
or the underlying script:

```bash
bash .scripts/sync.sh doctor
bash .scripts/sync.sh status
bash .scripts/sync.sh pull .templates/skills/run/SKILL.src.md
# edit, regenerate, test
node .scripts/configure.mjs
bash .scripts/sync.sh push .templates/skills/run/SKILL.src.md --yes
```

Use the smallest coherent path set when syncing. Path-scoped operations avoid
overwriting unrelated in-flight framework edits.

Framework maintainers working directly in the framework repository can
intentionally bypass the push guard:

```bash
TPRA_ALLOW_FRAMEWORK_PUSH=1 git push origin main
```

## arXiv Fetching

`/fetch-arxiv` downloads papers through a GitHub Actions relay, which is useful
when the local agent environment cannot fetch arXiv directly.

```bash
/fetch-arxiv 2301.00001 hep-th/0506213
```

Fetched files are written under `literature/papers/`:

```text
literature/papers/2301.00001/paper.pdf
literature/papers/2301.00001/*.tex
literature/papers/hep-th/0506213/paper.pdf
```

## Design Constraints

- Keep writes inside the project directory.
- Avoid global installs and machine-level side effects.
- During `/run` and `/write`, do not block on user questions.
- Record durable state in files instead of relying on prompt memory.
- Treat generated runtime files as build output.
- Preserve provenance: claims in `note.md` need derivations or citations plus
  verification tags.
- Track unresolved work honestly in `agenda.md`, `log.md`, or the appropriate
  node files.

## License

MIT
