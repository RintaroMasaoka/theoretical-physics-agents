#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "usage: bash .scripts/new-log.sh <type> [slug]" >&2
  exit 2
fi

type="$1"
slug="${2:-}"
stamp="$(date '+%y%m%d_%H%M')"

mkdir -p logs

if [[ -n "$slug" ]]; then
  path="logs/${stamp}_${type}_${slug}.md"
else
  path="logs/${stamp}_${type}.md"
fi

if [[ -e "$path" ]]; then
  suffix=2
  base="${path%.md}"
  while [[ -e "${base}_${suffix}.md" ]]; do
    suffix=$((suffix + 1))
  done
  path="${base}_${suffix}.md"
fi

: > "$path"
printf '%s\n' "$path"
