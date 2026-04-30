# Theoretical Physics Research Agents

A system that autonomously generates academic papers with minimal human intervention.
Users run `/run` to advance research, `/write` to draft papers, `/meeting` for progress review and course correction, and `/improve` to enhance agent behavior.

## Output Language

All user-facing output is written in **{{ language }}**. This covers:

- Conversational responses to the user
- Any file the system writes into the project — research tree (`research/**` such as `note.md`, `log.md`, `story.md`, `plan.md`, …), session records (`logs/**` such as launch and meeting summaries), and any other prose file
- Deliverables produced by worker sub-agents (see `{{ runtime.common_file }}`)
- Commit messages

Technical terms, proper nouns, and LaTeX mathematics may remain in their original language — the rule is about prose, not formulas or named objects.

## Roles

The system uses different orchestration models in `/run` and `/write`.

### `/run` — peer-agent team

`/run` is a thin scheduler dispatching a team of peer agents. No single "PI" — research judgment, record-keeping, and verification are split across independent agents.

| Role | Agent | Owns |
|---|---|---|
| **Direction** | `physicist` | `research/focus.md` — chooses cursor, formulates worker dispatches, issues tree directives. Thinks as a physicist (curiosity + critical thinking + narrative coherence) |
| **Record** | `curator` | All tree writes: `log.md`, `plan.md`, `note.md`, `conventions.md`, `dead_ends.md`, `report_*.md`, `story.md`, `principles.md`. Executes physicist's tree directives and absorbs worker evidence |
| **Verification** | `critic` | Independent review of every worker deliverable (Target A, auto-attached by the scheduler) and of every curator-lifted note.md derivation (Target B) |
| **Execution** | workers (researcher, simulator, reader, scout, engine-builder, concept-checker, self-check) | Bounded tasks — their deliverables stay provisional until critic has verified them |
| **Session finalisation** | `session-wrap-up` | Mechanical transcription of physicist's session-end wrap-up input into `research/focus.md`, `logs/last_session.md`, and the session log; commits and pushes |

### `/write` — PI-led writing

`/write` keeps the traditional PI model because drafting a paper is one coherent narrative judgment that does not split naturally into peer roles.

| Term | Entity | Role |
|---|---|---|
| **PI** | `/write` skill (main agent) | The lab's PI. Drafts the paper by directing outliner, writer, reviewer, finalizer, and reference-auditor. Responsible for verifying and integrating their output |
| **Students** | Sub-agents such as writer, reviewer, outliner, finalizer | Execute individual tasks under PI's direction. Output is adopted only after PI verification |

### User

The human researcher is the collaborator for both skills — sets direction via `/meeting`, oversees decisions, and overrides when needed.

## Operational Rules

- Do not request user input during `/run` or `/write` execution (all forms prohibited, including {{ runtime.tool_ask_user_question }} and tool permission requests). Users are often away during execution, and prompting them interrupts the session and wastes time
- `/meeting` and `/improve` are the venues for user interaction
- No writing outside the project directory (to prevent contaminating the user's environment)
- Do not pollute the global environment (to prevent interference with other projects and loss of reproducibility)

## Repository Boundary

This checkout is a **research project workspace** unless the user explicitly says they are maintaining the `theoretical-physics-agents` framework itself.

- Never treat `https://github.com/RintaroMasaoka/theoretical-physics-agents` as the research project's GitHub repository
- Before any `git push`, inspect `git remote -v`; if the push destination is the framework repository, treat the push as framework publication and verify the framework/runtime consistency first with `bash .scripts/sync.sh check`
- Project commits may be made locally, but pushing requires a project-owned remote such as the user's private research repository
- Framework prompt or script improvements from this child project are legitimate feedback to the framework. For larger or path-scoped syncs, use `/upstream-sync` or its explicit script workflow: `bash .scripts/sync.sh doctor`, `bash .scripts/sync.sh status`, path-scoped `bash .scripts/sync.sh pull <path>...`, then path-scoped `bash .scripts/sync.sh push <path>...`
- Keep the two channels separate: `origin` is for this research project; `upstream` is for `theoretical-physics-agents` framework feedback
- `.scripts/configure.mjs` installs a local `pre-push` guard that runs `bash .scripts/sync.sh check` and blocks framework pushes only when the framework checks fail. `TPRA_ALLOW_FRAMEWORK_PUSH=1` intentionally bypasses that local check for maintainers
