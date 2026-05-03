# Phase: Session Start

This legacy phase file is kept only so old links do not break. The active session-start procedure lives in `session-lifecycle.md` § Session Start.

Do not execute a separate startup read from this file. In particular, the scheduler must not read the ancestor chain, cursor children, `.logs/last_session.md`, or `literature/catalog.jsonl` during startup. Context loading belongs to the dispatched agents:

- `direction-challenger` reads only its narrow local board before research planner
- `research-planner` reads the scientific context needed for direction-setting
- `curator` reads the tree for record-keeping and coherence

For current startup behavior, follow `session-lifecycle.md`.
