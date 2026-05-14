# Phase: Session End (legacy pointer)

This phase file is kept only so old links do not break. The active session-end procedure lives in `session-lifecycle.md` § Session End, and the research planner-owned close-session packet format lives in `.codex/agents/research-planner.md` § Session-End Mode.

Do not execute a separate session-end procedure from this file. Session-end mechanics are scheduler-owned: final curator sweep, final research planner dispatch in session-end mode, then `.scripts/close-session.mjs`. The research planner contributes judgment through the close-session packet; it does not dispatch curator or run session finalisation itself.

For current session-end behavior, follow `session-lifecycle.md`.
