---
name: current-agent-decomposition
kind: inventory
description: First-pass decomposition of existing agent prompts into agent-specific cores, shared modules, and shared contracts.
source_scope:
  - .templates/agents/*.src.md
  - .templates/skills/auto/phases/*.src.md
---

# Current Agent Decomposition

This inventory is the source discipline for the experiment. Modules should be extracted from existing agent responsibilities before new generic modes are invented.

The current workflow already has strong role boundaries. The experimental registry should not replace them with a vague router. It should factor out repeated contracts and reading protocols so agents can become smaller without losing the system's authority structure.

## Extraction Rule

Only extract a module or contract when at least one of these is true:

- The same responsibility appears across multiple agents.
- The responsibility is currently duplicated in an agent and a scheduler phase file.
- A future user-invoked run would need the same rule as an agent-invoked run.
- The responsibility is not the scientific identity of the agent but a shared way to read, write, verify, place, or hand off work.

Do not extract the core judgment that makes an agent distinct.

## Cross-Agent Modules and Contracts

| Candidate | Kind | Derived from | Why it is real |
|---|---|---|---|
| `runtime-context-loading` | module | research-planner, curator, critic, simulator, writer, guide-writer | Many agents define startup reading protocols. The repeated concern is not "read files" but "load only the context appropriate to this role and evidence question." |
| `authority-boundary` | module | research-planner, curator, critic, reader, scout, concept-checker, guide-writer | Agents repeatedly say what they must not decide. This is a shared system invariant, not agent prose decoration. |
| `worker-submission-transaction` | contract | researcher, simulator, reader, scout, engine-builder, concept-checker, auto dispatch | Worker outputs repeatedly need `_reviews/{slug}/worker.md`, raw logs, review focus, and a dispatcher-readable completion value. |
| `review-transaction` | contract | critic, auto dispatch, curator | Provisional Review and Durable Surface Review are scheduler-level transactions used across workers and durable surfaces. |
| `artifact-placement` | module | simulator, engine-builder, reader, scout, concept-checker, curator, directory/architecture phases | Placement rules recur because artifacts have different authority and lifetimes: research tree, literature records, concepts, materials, logs, checks. |
| `source-fidelity` | module | reader, scout, reference-auditor, critic source-audit mode | Source-side facts must not be mixed with project relevance. This appears in several agents. |
| `human-oversight-surface` | module | guide-writer, meeting workflow, writer/reviewer boundary | The system needs human-readable surfaces that point to authority without becoming a second authority layer. |
| `session-handoff` | module | research-planner session-end mode, session-wrap-up, session-lifecycle | End-of-session continuity is a shared lifecycle concern rather than a single agent's scientific job. |
| `standard-run-log` | contract | common worker logs, user desire for direct calls, auto dispatch records | User-invoked and agent-invoked reusable work need the same run record shape. This is new but grounded in existing raw_log and transaction records. |

## Agent Cores That Should Stay Agent-Specific

| Agent | Core responsibility | Should not be extracted as a generic module |
|---|---|---|
| `research-planner` | Choose scientific direction, cursor movement, worker dispatches, and tree directives. | Direction judgment, liveness, priority, and scientific route value. |
| `direction-challenger` | Apply bounded pre-direction opposition before the route hardens. | The act of deciding the replacement direction. |
| `curator` | Close research-memory transactions and maintain graph/state/provenance coherence. | Broad tree write authority and placement decisions. |
| `critic` | Independently verify worker submissions and durable surfaces in the requested mode. | Admission of claims into findings or choice of scientific repair route. |
| `researcher` | Produce bounded theoretical derivations or investigations requested by planner. | Project direction, graph edits, and claim admission. |
| `simulator` | Implement, run, verify, analyze, and visualize numerical computations using shared simulation modules. | Engine-library changes and graph/fact-layer promotion. |
| `engine-builder` | Build shared simulation framework modules for later simulator use. | Measurement-specific analysis and scientific target selection. |
| `reader` | Convert one paper into a project-independent source record. | Project relevance, bridge status, and use in a node. |
| `scout` | Discover candidate literature and update the catalog using metadata/abstracts. | Deep paper interpretation. |
| `concept-checker` | Propose scoped reader bridges for reusable terms. | Project facts, conventions, and durable concept-file authority. |
| `guide-writer` | Maintain human oversight entrypoints. | Fact authority and derivation copying. |
| `self-check` | Read one document as a first-time reader with no context. | Contextual project review. |
| `writer`, `outliner`, `reviewer`, `finalizer`, `reference-auditor` | Paper-writing pipeline roles. | Research-tree direction or auto-cycle evidence admission. |
| `prompt-reviewer` | Blind coherence review of prompt files. | Complaint-specific prompt fixing. |

## First Experimental Cut

The first cut should not include domain modes like `prepare-scale` or `optimize-implementation`. Those may later become computation-domain modules, but they are not the first shared extraction.

The initial registry should contain:

- `contracts/standard-run-log.md`
- `contracts/worker-submission-transaction.md`
- `contracts/review-transaction.md`
- `modules/runtime-context-loading.md`
- `modules/authority-boundary.md`
- `modules/artifact-placement.md`
- `modules/source-fidelity.md`
- `modules/human-oversight-surface.md`
- `modules/session-handoff.md`
- `agents/run-orchestrator.md`

`run-orchestrator` should be written last and kept thin. It should convert an invocation into a recorded run by selecting from modules/contracts already justified here.

