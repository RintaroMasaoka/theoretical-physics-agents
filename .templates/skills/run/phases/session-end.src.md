# Phase: Session End (legacy pointer)

This phase file is kept only so old links do not break. The active session-end procedure lives in `session-lifecycle.md` § Session End, and the research planner-owned wrap-up-input format lives in `{{ runtime.agents_dir }}/research-planner.md` § Session-End Mode.

Do not execute a separate session-end procedure from this file. Session-end mechanics are scheduler-owned: final curator sweep, final research planner dispatch in session-end mode, then `session-wrap-up`. The research planner contributes judgment through the wrap-up-input file; it does not dispatch curator or run session finalisation itself.

For current session-end behavior, follow `session-lifecycle.md`.
