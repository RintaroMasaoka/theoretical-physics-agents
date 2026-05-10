# Research Agents Team for Theoretical Physics

Autonomous and human-steered research system for theoretical physics projects.

The system is organized around file-based research memory. `/auto` runs a peer-agent team that separates direction-setting, execution, verification, and tree maintenance; `/steer` lets the human choose one executable cycle direction before the same machinery runs; `/write` turns accumulated research-tree facts into paper drafts. The repository is tool-agnostic at the instruction level, with shared template sources under `.templates/` and generated runtime-specific outputs under `.claude/` and `.codex/`.

## What This Repository Does

- `/launch` sets the initial research theme and creates the research tree
- `/meeting` reviews direction, verification honesty, and human oversight decisions
- `/steer` runs one human-steered research cycle
- `/auto [N]` advances the research autonomously for up to `N` cycles
- `/write [N]` turns accumulated research-tree facts into paper drafts under `draft/**`
- `/improve` is used to refine prompts, workflows, and agent behavior

Core operating model:

- `/auto` is a thin scheduler; research judgment, worker execution, verification, and durable-memory maintenance are split across peer agents
- `/write` drafts paper material by coordinating outline, section writing, review, integration, and reference checks
- Worker agents perform bounded tasks such as reading, research, critique, outlining, reviewing, simulation, or source-record maintenance
- During `/auto` and `/write`, the system is designed to continue without asking the user for clarification

## Quick Start

### Prerequisites

- A compatible coding-agent environment
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) if you want to use the included `.claude/` configuration directly
- Codex if you want to use the generated `.codex/` runtime files directly
- [Node.js](https://nodejs.org/) for `generate-runtime.mjs`

### Setup

1. Clone the repository
2. Optionally edit `.config/config.yaml`
3. Run `node .scripts/generate-runtime.mjs` to generate runtime files
4. Start your agent session in the project root

By default, `node .scripts/generate-runtime.mjs` generates both `.claude/` and `.codex/`.

If you are using Claude Code, `.claude/settings.json` runs `node .scripts/generate-runtime.mjs` automatically on session start, so generated prompt files stay in sync with the templates and config.

### Minimal Workflow

1. Run `/launch` to define the research theme and initialize `research/`
2. Run `/meeting` if you want to inspect or revise the direction before execution
3. Run `/auto 2` to test a short autonomous research session, or `/steer` to choose the next cycle direction manually
4. Inspect generated artifacts such as `research/focus.md`, `research/**/state.md`, `research/**/findings.md`, `research/**/checks/`, and `.logs/last_session.md`
5. Use larger `/auto N` sessions once the direction and tree structure are behaving well
6. Try `/write 2` only with the understanding that it is currently much less validated than `/auto`

## Validation and Expectations

This repository aims to be honest about maturity rather than claiming that all workflows are equally production-ready.

### More validated today

- `/meeting`
- `/steer`
- `/auto`
- The research-tree workflow around `research/`, `literature/`, `concepts/`, and `.logs/`

### Less validated today

- `/write`
- The end-to-end paper assembly loop
- Review and refinement behavior driven by real paper-writing use rather than template design alone

That means the main current value of the repository is autonomous research progression, not yet fully validated autonomous paper production.

## Command Summary

| Command | Purpose | Maturity |
|---|---|---|
| `/launch` | Set or change the research theme and initialize the tree | Usable |
| `/meeting` | Interactive oversight, explanation, verification review, and course correction | Usable |
| `/steer` | Human-chosen direction for one semi-automatic research cycle | Usable |
| `/auto [N]` | Autonomous peer-agent research cycles | Most validated |
| `/write [N]` | Draft and refine the paper from accumulated research-tree facts | Experimental |
| `/improve` | Improve prompts, workflows, and behavior | Usable |

## Repository Layout

```text
README.md                 # Project overview and operational expectations
.scripts/generate-runtime.mjs    # Generates runtime files from config + templates

.config/
└── config.yaml           # Main editable shared config

.claude/
├── agents/*.md           # Generated agent instructions
├── skills/*/SKILL.md     # Generated skills
└── settings.json         # Claude Code settings, including SessionStart hook

.codex/
├── agents/*.md           # Generated agent instructions
└── skills/*/SKILL.md     # Generated skills

.templates/               # Prompt templates (source of truth for generated runtime files)
└── AGENTS.src.md         # Shared root instruction template
```

## Runtime Artifacts

During actual research and writing sessions, the project creates working files in the repository root. Typical artifacts include:

- `research/state.md`: root research state with background, current board, and meeting metadata
- `research/focus.md`: current session cursor and scheduler interface for the next research cycle
- `research/story.md`: project narrative structure
- `research/**/state.md`: node-local current board and absorbed evidence ledger
- `research/**/findings.md`: derivation-bearing draft fact layer for reusable claims
- `research/**/guide.md`: human oversight entrypoint for a node or subtree
- `research/**/checks/`: durable verification and provenance records
- `research/**/_reviews/`: provisional worker/critic transactions (`worker.md`, `critic.md`, optional repair loop)
- `research/**/_materials/analyses/`: clean analyses kept as node-local material, not adopted fact authority
- `research/**/_materials/src/`, `research/**/_materials/data/`, `research/**/_materials/images/`: node-local computation scripts, data, and figures
- `research/_materials/lib/`: shared simulation framework modules
- `research/archive/`: retired process-heavy nodes whose reusable value has been extracted
- `literature/catalog.jsonl`, `literature/notes/`, `literature/papers/`: source metadata, durable source records, and fetched paper files
- `concepts/`: reusable reader bridges for terms that recur across nodes
- `draft/`: `/write` paper-draft workspace (`outline.md`, `sections/`, `versions/`)
- `agenda.md`: items for future meetings or research follow-up
- `.logs/*`: raw chronological process logs, session records, and audit history; not critic targets by default
- `.logs/last_session.md`: handoff summary for the next `/auto`
- `.logs/last_write_session.md`: handoff summary for the next `/write`

## Configuration

The main editable config is `.config/config.yaml`.
It is the shared config source for both `.claude/` and `.codex/`.

By default, the repository is configured for Japanese user-facing responses.

Current supported top-level values include:

| Key | Meaning |
|---|---|
| `language` | User-facing response language |
| `simulation.language` | Preferred language for simulation code |
| `simulation.visualization` | Preferred visualization backend for simulation plots |
| `cycles.auto` | Default cycle count for `/auto` |
| `cycles.write` | Default cycle count for `/write` |

Prompt content lives in `.templates/`, and generated files are rebuilt from those templates.

Manual commands:

```bash
node .scripts/generate-runtime.mjs
node .scripts/generate-runtime.mjs --dry-run
node .scripts/generate-runtime.mjs --check
node .scripts/generate-runtime.mjs --target claude
node .scripts/generate-runtime.mjs --target codex
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

`.scripts/generate-runtime.mjs` installs a local `pre-push` guard. When a push targets
the framework repository, the guard first checks that the framework templates,
config, generated runtime files, and framework-internal references are
consistent. It blocks stale or unvalidated framework pushes, not framework
pushes as such. You can run the same local check explicitly:

```bash
bash .scripts/sync.sh check
```

For larger or path-scoped framework syncs, use `/upstream-sync` or the
underlying script:

```bash
bash .scripts/sync.sh doctor
bash .scripts/sync.sh status
bash .scripts/sync.sh pull .templates/skills/auto/SKILL.src.md
# edit, regenerate, test
node .scripts/generate-runtime.mjs
bash .scripts/sync.sh push .templates/skills/auto/SKILL.src.md --yes
```

Use the smallest coherent path set when syncing. Path-scoped operations avoid
overwriting unrelated in-flight framework edits.

Framework maintainers can intentionally bypass the local consistency check:

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

The system is intentionally opinionated.

- During `/auto` and `/write`, do not block on user questions
- Keep all writes inside the project directory
- Avoid global installs and other machine-level side effects
- Prefer file-based state and handoff over large prompt-only context
- Track progress honestly; unresolved work should not be marked resolved

These rules are defined canonically in `.templates/AGENTS.src.md` and emitted into the runtime-specific instruction files.

## License

MIT
