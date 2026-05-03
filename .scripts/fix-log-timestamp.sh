#!/bin/bash
# PostToolCall hook for Write: auto-correct timestamps in .logs/
# Receives tool call JSON on stdin; renames the file with the real timestamp.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('file_path', ''))
" 2>/dev/null)

# Only process files matching .logs/YYMMDD_HHMM_agent.md or .logs/_DRAFT_agent.md
case "$FILE_PATH" in
  */.logs/[0-9_]*_*.md | */.logs/_DRAFT_*.md)
    BASENAME=$(basename "$FILE_PATH" .md)
    # Extract agent type: strip the timestamp/draft prefix
    AGENT_TYPE=$(echo "$BASENAME" | sed -E 's/^([0-9]{6}_[0-9]{4}|_DRAFT)_//')
    if [ -n "$AGENT_TYPE" ] && [ -f "$FILE_PATH" ]; then
      TIMESTAMP=$(date '+%y%m%d_%H%M')
      DIR=$(dirname "$FILE_PATH")
      NEW_PATH="${DIR}/${TIMESTAMP}_${AGENT_TYPE}.md"
      # Handle collision: append _2, _3, ...
      if [ "$FILE_PATH" != "$NEW_PATH" ] && [ -f "$NEW_PATH" ]; then
        N=2
        while [ -f "${DIR}/${TIMESTAMP}_${AGENT_TYPE}_${N}.md" ]; do
          N=$((N + 1))
        done
        NEW_PATH="${DIR}/${TIMESTAMP}_${AGENT_TYPE}_${N}.md"
      fi
      if [ "$FILE_PATH" != "$NEW_PATH" ]; then
        mv "$FILE_PATH" "$NEW_PATH"
      fi
    fi
    ;;
esac
