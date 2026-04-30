#!/usr/bin/env sh
set -eu

remote_name="${1:-}"
remote_url="${2:-}"

canonical_url=$(printf '%s' "$remote_url" \
  | sed -E 's#^git@github.com:#https://github.com/#' \
  | sed -E 's#\.git$##' \
  | sed -E 's#/$##' \
  | tr '[:upper:]' '[:lower:]')

case "$canonical_url" in
  *github.com/rintaromasaoka/theoretical-physics-agents)
    if [ "${TPRA_ALLOW_FRAMEWORK_PUSH:-}" = "1" ]; then
      exit 0
    fi

    cat >&2 <<EOF
Refusing to push to the framework repository.

Remote '${remote_name}' points to:
  ${remote_url}

Plain git pushes from this checkout are reserved for the research project.
Create or set a project remote before pushing project work, for example:

  git remote set-url origin <your-project-repo-url>

Framework feedback from a child project should go through the explicit upstream
sync workflow instead of plain git push:

  git remote add upstream https://github.com/RintaroMasaoka/theoretical-physics-agents.git
  bash .scripts/sync.sh status
  bash .scripts/sync.sh push <framework-path>...

Framework maintainers working directly on the framework can intentionally bypass
this guard with:

  TPRA_ALLOW_FRAMEWORK_PUSH=1 git push ${remote_name}
EOF
    exit 1
    ;;
esac

exit 0
