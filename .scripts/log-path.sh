#!/usr/bin/env bash
# Choose a timestamped log path under .logs/ and print it to stdout.
#
# Usage:
#   bash .scripts/log-path.sh <type> [<slug>]
#
# Output: absolute path of the form
#   {project}/.logs/{YYMMDD_HHMM}_{type}[_{slug}].md
#
# The path does not yet exist as a file; the caller writes content to it.
# The timestamp is fixed at the moment of this script's invocation, so naming
# is authoritative from path selection.
#
# Collision is resolved by appending _2, _3, ... if the same minute already
# produced a file with the same type/slug.

set -e

TYPE="$1"
SLUG="$2"

if [ -z "$TYPE" ]; then
  echo "Usage: bash .scripts/log-path.sh <type> [<slug>]" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOGS_DIR="$ROOT/.logs"
mkdir -p "$LOGS_DIR"

TS=$(date '+%y%m%d_%H%M')

if [ -n "$SLUG" ]; then
  BASE="${TS}_${TYPE}_${SLUG}"
else
  BASE="${TS}_${TYPE}"
fi

OUT="$LOGS_DIR/${BASE}.md"
N=2
while [ -e "$OUT" ]; do
  OUT="$LOGS_DIR/${BASE}_${N}.md"
  N=$((N + 1))
done

echo "$OUT"
