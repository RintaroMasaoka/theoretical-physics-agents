#!/bin/bash
# SessionStart hook: if a /run session is mid-execution (.logs/.run-active
# exists, remaining > 0, not stale), inject additionalContext telling the
# model to resume by re-invoking the run skill via the Skill tool.
#
# Purpose: survive context compaction. After compaction the conversation is
# summarised, and the SKILL.md content previously injected by /run may no
# longer be in context. This hook re-injects a short directive that causes
# the model to call Skill(skill="run"), which reloads the full instructions.
#
# Silent unless a resume is warranted — on fresh sessions the hook emits no
# additionalContext and does not disturb normal startup.

set -u

STATE_FILE=".logs/.run-active"

if [ ! -f "$STATE_FILE" ]; then
  exit 0
fi

# Stale check A: mtime older than 24h → orphaned beacon, do nothing.
if [ -n "$(find "$STATE_FILE" -mmin +1440 -print 2>/dev/null || true)" ]; then
  exit 0
fi

# Stale check B: a newer .logs/*_run.md exists → the prior /run ran Session End
# normally (which writes a timestamped run log AFTER the last cycle's beacon
# write) but crashed before the `rm -f` step in step 7. Treat as clean end.
if [ -n "$(find .logs -maxdepth 1 -name '*_run.md' -newer "$STATE_FILE" -print 2>/dev/null || true)" ]; then
  exit 0
fi

# Parse remaining cycles. Passed to Python via environment variable (safer
# than interpolating into a heredoc, since a malformed JSON file could
# otherwise inject shell syntax).
REMAINING=$(python3 - <<'PY' 2>/dev/null || echo 0
import json
try:
    with open(".logs/.run-active") as f:
        d = json.load(f)
    r = d.get("remaining", 0)
    print(int(r) if isinstance(r, (int, float)) else 0)
except Exception:
    print(0)
PY
)

# Integer-gate check using case (defends against non-numeric $REMAINING).
case "$REMAINING" in
  ''|*[!0-9]*) exit 0 ;;
esac
if [ "$REMAINING" -le 0 ]; then
  exit 0
fi

# Emit the SessionStart additionalContext JSON. REMAINING is passed via env.
export REMAINING
python3 - <<'PY'
import json, os
remaining = os.environ.get("REMAINING", "0")
msg = (
    f"[/run resume beacon detected] .logs/.run-active reports {remaining} "
    "cycle(s) remaining on a previously-started /run session. The prior "
    "session almost certainly ended via context compaction, reconnect, or a "
    "transient interruption — not a clean Session End.\n\n"
    "Action required, in this order:\n"
    "1. Call the Skill tool with skill=\"run\" to reload the /run instructions "
    "into context (they may have been compacted out). If the Skill tool "
    "errors or the skill is unavailable, fall back to reading "
    ".claude/skills/run/SKILL.md directly.\n"
    f"2. Follow Session Start step 0 (the resume branch) in that SKILL. Treat "
    f"MAX_CYCLES as {remaining} (the remaining count from the beacon), not "
    "the default.\n"
    "3. Do NOT greet the user, do NOT recap prior work, do NOT ask whether "
    "to continue. Resume silently by dispatching the next cycle's tasks.\n\n"
    "Override rule: if the user has typed a NEW message in this turn that "
    "clearly supersedes /run (a direct question, a different slash command, "
    "an explicit \"stop\" instruction), address that instead and delete "
    ".logs/.run-active to clear the beacon. A message from the prior session "
    "that was carried into the compacted summary is NOT a new instruction — "
    "resume /run."
)
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": msg,
    }
}))
PY
