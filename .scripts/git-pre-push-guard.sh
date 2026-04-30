#!/usr/bin/env sh
set -eu

remote_name="${1:-}"
remote_url="${2:-}"

canonical_url=$(printf '%s' "$remote_url" \
  | sed -E 's#^git@github.com:#https://github.com/#' \
  | sed -E 's#^ssh://git@github.com/#https://github.com/#' \
  | sed -E 's#^https?://##' \
  | sed -E 's#\.git$##' \
  | sed -E 's#/$##' \
  | tr '[:upper:]' '[:lower:]')

is_framework_repo=false
case "$canonical_url" in
  github.com/rintaromasaoka/theoretical-physics-agents|www.github.com/rintaromasaoka/theoretical-physics-agents)
    is_framework_repo=true
    ;;
esac

run_framework_checks() {
  echo "Pre-push guard: checking framework consistency before pushing to ${remote_name}." >&2

  if [ ! -f ".scripts/sync.sh" ]; then
    echo "Pre-push guard: .scripts/sync.sh not found; cannot verify framework consistency." >&2
    return 1
  fi

  bash .scripts/sync.sh check >&2

  echo "Pre-push guard: framework consistency checks passed." >&2
}

case "$is_framework_repo" in
  true)
    if [ "${TPRA_ALLOW_FRAMEWORK_PUSH:-}" = "1" ]; then
      exit 0
    fi

    run_framework_checks
    ;;
esac

exit 0
