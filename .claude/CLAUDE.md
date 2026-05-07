# Theoretical Physics Research Agents

A system that advances theoretical-physics research with either autonomous or human-steered agent orchestration.
Users run `/auto` to advance research autonomously, `/steer` to choose the next research direction before one semi-automatic cycle, `/write` to draft papers, `/meeting` for progress review and course correction, and `/improve` to enhance agent behavior.

## Output Language

All user-facing output is written in **japanese**. This covers:

- Conversational responses to the user
- Any file the system writes into the project — research tree (`research/**` such as `findings.md`, `state.md`, `story.md`, `plan.md`, …), session records (`.logs/**` such as launch and meeting summaries), and any other prose file
- Worker submissions, raw logs, and other task outputs produced by sub-agents (see `.claude/common.md`)
- Commit messages

Technical terms, proper nouns, and LaTeX mathematics may remain in their original language — the rule is about prose, not formulas or named objects.

## Roles

The system uses different orchestration models in `/auto`, `/steer`, and `/write`.

### `/auto` — peer-agent team

`/auto` is a thin scheduler dispatching a team of peer agents. No single "PI" — research judgment, record-keeping, and verification are split across independent agents.

| Role | Agent | Owns |
|---|---|---|
| **Direction challenge** | `direction-challenger` | Pre-direction opposition for research planner: challenges value, goal, necessity, frame, scale, authority, and inertia anchors before the direction hardens |
| **Direction** | `research-planner` | `research/focus.md` — chooses cursor, formulates worker dispatches, issues tree directives. Thinks as a research planner (curiosity + critical thinking + narrative coherence) |
| **Tree transaction** | `curator` | Graph/lifecycle/placement, state.md absorbed evidence, guide.md maintenance, plan.md consistency, conventions/checks placement, `_materials/analyses/` material placement, retraction, `dead_ends.md`, and current-runtime findings.md fact transactions. Executes research planner's tree directives and absorbs reviewed worker transactions |
| **Verification** | `critic` | Independent Provisional Review for every review-eligible `_reviews/{slug}/worker.md` submission and Durable Surface Review for every curator-touched findings/analysis surface requested by curator and dispatched by the scheduler |
| **Execution** | workers (researcher, simulator, reader, scout, engine-builder, concept-checker, self-check) | Bounded tasks — their `_reviews/` submissions stay provisional until critic has verified them |
| **Session finalisation** | `session-wrap-up` | Mechanical transcription of research planner's session-end wrap-up input into `research/focus.md`, `.logs/last_session.md`, node-scoped `backlog.md`, and the session log; commits and pushes |

### `/steer` — human-steered cycle

`/steer` uses the same peer-agent execution machinery as `/auto`, but inserts a human steering gate at the start of the cycle. The AI presents direction options with their worker consequences; the human chooses or revises the research direction; then the scheduler executes one cycle through workers, critic, curator, and wrap-up.

### `/write` — PI-led writing

`/write` keeps the traditional PI model because drafting a paper is one coherent narrative judgment that does not split naturally into peer roles.

| Term | Entity | Role |
|---|---|---|
| **PI** | `/write` skill (main agent) | The lab's PI. Drafts the paper by directing outliner, writer, reviewer, finalizer, and reference-auditor. Responsible for verifying and integrating their output |
| **Students** | Sub-agents such as writer, reviewer, outliner, finalizer | Execute individual tasks under PI's direction. Output is adopted only after PI verification |

### User

The human researcher is the collaborator for all skills — sets broad direction via `/launch` and `/meeting`, steers individual cycles via `/steer`, and overrides when needed.

## Operational Rules

- Do not request user input during `/auto` or `/write` execution (all forms prohibited, including AskUserQuestion and tool permission requests). Users are often away during execution, and prompting them interrupts the session and wastes time
- `/steer`, `/meeting`, `/launch`, and `/improve` are the venues for user interaction
- No writing outside the project directory (to prevent contaminating the user's environment)
- Do not pollute the global environment (to prevent interference with other projects and loss of reproducibility)

## Repository Boundary

This checkout is a **research project workspace** unless the user explicitly says they are maintaining the `theoretical-physics-agents` framework itself.

- Never treat `https://github.com/RintaroMasaoka/theoretical-physics-agents` as the research project's GitHub repository
- Before any `git push`, inspect `git remote -v`; if the push destination is the framework repository, stop and report that the project remote has not been configured
- Project commits may be made locally, but pushing requires a project-owned remote such as the user's private research repository
- Framework prompt or script improvements from this child project are legitimate feedback to the framework, but they must use `/upstream-sync` or its explicit script workflow: `bash .scripts/sync.sh doctor`, `bash .scripts/sync.sh status`, path-scoped `bash .scripts/sync.sh pull <path>...`, then path-scoped `bash .scripts/sync.sh push <path>...`
- Keep the two channels separate: `origin` is for this research project; `upstream` is for `theoretical-physics-agents` framework feedback
- `.scripts/configure.mjs` installs a local `pre-push` guard that physically refuses pushes to the framework repository unless `TPRA_ALLOW_FRAMEWORK_PUSH=1` is set by a maintainer
