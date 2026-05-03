# Phase: Cycle Dispatch (legacy pointer)

This phase file is kept only so old links do not break. The active worker and critic dispatch procedure lives in `dispatch.md`.

Do not execute a separate cycle-dispatch procedure from this file. In the current `/run` model, the scheduler is thin: `direction-challenger` challenges, `research-planner` writes `research/focus.md`, the scheduler launches worker dispatches from that file, critic is auto-attached, and `curator` absorbs verified evidence. Duplicating those mechanics here would create a second authority surface.

For current dispatch behavior, follow `dispatch.md`.
