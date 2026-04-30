#!/usr/bin/env bash
# sync.sh — framework ファイルを upstream (public repo) と同期するスクリプト
#
# 使い方:
#   bash .scripts/sync.sh pull                    — upstream の最新 framework 全体を取り込む
#   bash .scripts/sync.sh pull <path>...          — 指定パスのみ upstream から取り込む
#   bash .scripts/sync.sh push [--yes]            — framework 全体を upstream に送る
#   bash .scripts/sync.sh push <path>... [--yes]  — 指定パスのみ upstream に送る
#   bash .scripts/sync.sh status                  — upstream との差分を表示する
#   bash .scripts/sync.sh check                   — ローカル framework 整合性を検査する
#   bash .scripts/sync.sh doctor                  — remote 設定と framework 参照を検査する
#
# <path> は FRAMEWORK_FILES 配下のファイル/ディレクトリ
# (例: .templates/skills/improve/SKILL.src.md, .scripts/configure.mjs)
#
# 並列作業 (複数の /improve セッション等) では path 指定運用を推奨:
#   - 他セッションが in-flight で触っているファイルを巻き込まずに済む
#   - bulk pull は未コミット編集を silently 上書きする; bulk push は他セッションの
#     published 変更を revert しうる。path 指定ならどちらも起こらない
#   - path を省略した場合は従来通り framework 全体が対象 (後方互換)
#
# 前提:
#   - remote "upstream" が設定済み
#   - push 先の upstream に書き込み権限がある

set -euo pipefail

# ── 同期対象ファイル（framework ファイル）──────────────────────
# これらのファイル/ディレクトリ配下だけが upstream と共有される
FRAMEWORK_FILES=(
  "README.md"
  ".gitignore"
  ".github/"
  ".config/"
  ".scripts/"
  ".claude/settings.json"
  ".templates/"
)

# push 時 (bulk) に upstream から削除すべき stale ファイル
STALE_FILES=(
  "CLAUDE.md"          # .claude/CLAUDE.md と .codex/AGENTS.md に生成
  "AGENTS.md"           # CLAUDE.md に統合済み
  "configure.mjs"       # .scripts/configure.mjs に移動済み
  "scripts/"            # .scripts/ にリネーム済み
  "templates/"          # .templates/ にリネーム済み
  ".agents/"            # .claude/skills/ に移動済み
  "concepts/"           # プロジェクト固有
  "literature/"         # プロジェクト固有
  "logs/"               # プロジェクト固有
  "meetings/"           # プロジェクト固有
  "research/"           # プロジェクト固有
  "work/"               # プロジェクト固有
)

FRAMEWORK_REPO_CANONICAL="github.com/rintaromasaoka/theoretical-physics-agents"
UPSTREAM_REMOTE="upstream"
UPSTREAM_BRANCH="main"
ORIG_ARGS=("$@")

# ── ヘルパー関数 ──────────────────────────────────────────────

die() { echo "Error: $*" >&2; exit 1; }

normalize_remote_url() {
  printf '%s' "$1" \
    | sed -E 's#^git@github.com:#https://github.com/#' \
    | sed -E 's#^[a-z]+://##' \
    | sed -E 's#\.git$##' \
    | sed -E 's#/$##' \
    | tr '[:upper:]' '[:lower:]'
}

is_framework_repo_url() {
  local canonical
  canonical="$(normalize_remote_url "$1")"
  [ "$canonical" = "$FRAMEWORK_REPO_CANONICAL" ] || [ "$canonical" = "www.$FRAMEWORK_REPO_CANONICAL" ]
}

check_upstream() {
  git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1 \
    || die "remote '$UPSTREAM_REMOTE' が見つかりません。先に git remote add $UPSTREAM_REMOTE https://github.com/RintaroMasaoka/theoretical-physics-agents.git を実行してください"
}

check_remote_layout() {
  local origin_url=""
  local upstream_url=""

  origin_url="$(git remote get-url origin 2>/dev/null || true)"
  upstream_url="$(git remote get-url "$UPSTREAM_REMOTE" 2>/dev/null || true)"

  if [ -n "$origin_url" ] && is_framework_repo_url "$origin_url"; then
    echo "Warning: origin が framework repo を指しています。child project では origin は private project repo、upstream が framework repo です。" >&2
    echo "  git remote set-url origin <your-project-repo-url>" >&2
    if [ -z "$upstream_url" ]; then
      echo "  git remote add upstream https://github.com/RintaroMasaoka/theoretical-physics-agents.git" >&2
    fi
  fi
}

normalize_path() {
  local path="$1"
  path="${path#./}"
  while [[ "$path" == */ && "$path" != "/" ]]; do
    path="${path%/}"
  done
  [[ "$path" = /* ]] && die "絶対パスは指定できません: $1"
  [[ "$path" = *".."* ]] && die "'..' を含むパスは指定できません: $1"
  printf '%s\n' "$path"
}

# 与えられた相対パスが FRAMEWORK_FILES の範囲内にあるか判定
is_framework_path() {
  local path="$1"
  local item
  for item in "${FRAMEWORK_FILES[@]}"; do
    # ファイル完全一致
    if [ "$path" = "$item" ]; then
      return 0
    fi
    # ディレクトリ (末尾 /) の前方一致
    if [[ "$item" == */ ]]; then
      if [[ "$path" == "$item"* ]] || [ "$path" = "${item%/}" ]; then
        return 0
      fi
    fi
  done
  return 1
}

# 与えられたパス配列すべてが framework 範囲内か検証
validate_paths() {
  local path
  for path in "$@"; do
    is_framework_path "$path" \
      || die "'$path' は framework パス外です (FRAMEWORK_FILES を参照)"
  done
}

framework_reference_regex() {
  local item item_clean escaped parts=()
  for item in "${FRAMEWORK_FILES[@]}"; do
    item_clean="${item%/}"
    if [[ "$item" == */ ]]; then
      escaped="$(printf '%s' "$item_clean" | sed -E 's/[][(){}.^$+*?|\\]/\\&/g')"
      parts+=("$escaped/[A-Za-z0-9._/-]+")
    else
      escaped="$(printf '%s' "$item_clean" | sed -E 's/[][(){}.^$+*?|\\]/\\&/g')"
      parts+=("$escaped")
    fi
  done
  local IFS='|'
  printf '(%s)' "${parts[*]}"
}

list_framework_files_at_root() {
  local root="$1"
  local item item_clean
  for item in "${FRAMEWORK_FILES[@]}"; do
    item_clean="${item%/}"
    if [ -f "$root/$item_clean" ]; then
      printf '%s\n' "$item_clean"
    elif [ -d "$root/$item_clean" ]; then
      (cd "$root" && find "$item_clean" -type f ! -name '.DS_Store' -print)
    fi
  done
}

list_local_framework_files() {
  list_framework_files_at_root "."
}

list_upstream_framework_files() {
  local item
  for item in "${FRAMEWORK_FILES[@]}"; do
    git ls-tree -r --name-only "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH" -- "$item" 2>/dev/null || true
  done
}

upstream_has_file() {
  git cat-file -e "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH:$1" 2>/dev/null
}

local_framework_has_changes() {
  local item item_clean
  for item in "$@"; do
    item_clean="${item%/}"
    if [ -n "$(git status --porcelain -- "$item_clean")" ]; then
      return 0
    fi
  done
  return 1
}

validate_framework_references() {
  local root="$1"
  local label="$2"
  local missing=false
  local ref
  local regex
  regex="$(framework_reference_regex)"

  while IFS= read -r ref; do
    if [ ! -e "$root/$ref" ]; then
      echo "  missing in $label: $ref" >&2
      missing=true
    fi
  done < <(
    list_framework_files_at_root "$root" \
      | while IFS= read -r file; do
          grep -Eoh "$regex" "$root/$file" 2>/dev/null || true
        done \
      | sed -E 's#[),.;:]+$##' \
      | grep -v '\.\.\.' \
      | sort -u
  )

  [ "$missing" = false ] || die "framework ファイルが存在しない framework 内パスを参照しています"
}

# upstream clone (tmpdir) にローカルのパスをコピー
# ディレクトリは一旦消してから再帰コピー (古いファイルの残留を防ぐ)
copy_to_upstream_clone() {
  local item="$1"
  local dest_root="$2"
  local item_clean="${item%/}"  # 末尾 / を除去

  if [ ! -e "$item_clean" ]; then
    echo "  - $item_clean (ローカルに存在しないためスキップ)"
    return 0
  fi

  if [ -d "$item_clean" ]; then
    rm -rf "$dest_root/$item_clean"
    mkdir -p "$dest_root/$item_clean"
    cp -R "$item_clean"/. "$dest_root/$item_clean/"
  else
    mkdir -p "$dest_root/$(dirname "$item_clean")"
    cp "$item_clean" "$dest_root/$item_clean"
  fi
  echo "  ✓ $item_clean"
}

# ── self-update: pull 時に sync.sh 自身を先に更新 ────────────

self_update() {
  # 既に再実行済みなら何もしない（無限ループ防止）
  [ "${_SYNC_SELF_UPDATED:-}" = 1 ] && return 0

  local self_path
  self_path="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  local self_rel=".scripts/sync.sh"

  # upstream 版を取得して差分チェック
  local upstream_content
  upstream_content=$(git show "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH:$self_rel" 2>/dev/null) || return 0

  if ! echo "$upstream_content" | diff -q - "$self_path" >/dev/null 2>&1; then
    echo "==> sync.sh 自体が更新されました。新しい版で再実行します..."
    git checkout "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH" -- "$self_rel"
    export _SYNC_SELF_UPDATED=1
    exec bash "$self_path" "${ORIG_ARGS[@]}"
  fi
}

# ── pull: upstream → private repo ─────────────────────────────

do_pull() {
  check_remote_layout
  check_upstream
  echo "==> upstream/$UPSTREAM_BRANCH を fetch 中..."
  git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH"

  # sync.sh 自身が変わっていたら新しい版で再実行
  self_update

  local -a targets
  if [ ${#PATH_ARGS[@]} -eq 0 ]; then
    echo "==> framework 全体を upstream から取り込み中..."
    targets=("${FRAMEWORK_FILES[@]}")
  else
    validate_paths "${PATH_ARGS[@]}"
    echo "==> 指定された framework パスを upstream から取り込み中..."
    targets=("${PATH_ARGS[@]}")
  fi

  if [ "${FORCE_PULL:-false}" != true ] && local_framework_has_changes "${targets[@]}"; then
    die "取り込み対象に未コミット変更があります。先に commit/stash するか、意図的に上書きする場合は --force を付けてください"
  fi

  local item
  for item in "${targets[@]}"; do
    git checkout "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH" -- "$item" 2>/dev/null && \
      echo "  ✓ $item" || \
      echo "  - $item (upstream に存在しないためスキップ)"
  done

  echo ""
  echo "==> configure.mjs を実行してランタイムファイルを再生成中..."
  node .scripts/configure.mjs
  validate_framework_references "." "local checkout"

  echo ""
  echo "Done! 取り込んだファイルを確認してください:"
  echo "  git diff --cached    # ステージングされた変更"
  echo "  git diff             # 未ステージの変更"
  echo ""
  echo "問題なければコミット:"
  echo "  git add -A && git commit -m 'sync: pull framework updates from upstream'"
}

# ── push: private repo → upstream ─────────────────────────────

do_push() {
  check_remote_layout
  check_upstream
  echo "==> upstream/$UPSTREAM_BRANCH を fetch 中..."
  git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH"

  validate_framework_references "." "local checkout"

  # 一時ディレクトリに upstream をクローン
  local tmpdir
  tmpdir=$(mktemp -d)
  trap "rm -rf '$tmpdir'" EXIT

  local upstream_url
  upstream_url=$(git remote get-url "$UPSTREAM_REMOTE")

  echo "==> upstream を一時ディレクトリにクローン中..."
  git clone --depth 1 --branch "$UPSTREAM_BRANCH" "$upstream_url" "$tmpdir/repo" 2>&1 | grep -v '^$'

  local -a targets
  local is_bulk=false
  if [ ${#PATH_ARGS[@]} -eq 0 ]; then
    is_bulk=true
    echo "==> stale ファイルを削除中..."
    for item in "${STALE_FILES[@]}"; do
      if [ -e "$tmpdir/repo/$item" ]; then
        rm -rf "$tmpdir/repo/$item"
        echo "  ✗ $item (削除 — stale)"
      fi
    done
    echo "==> framework 全体をコピー中..."
    targets=("${FRAMEWORK_FILES[@]}")
  else
    validate_paths "${PATH_ARGS[@]}"
    echo "==> 指定された framework パスをコピー中..."
    targets=("${PATH_ARGS[@]}")
  fi

  local item
  for item in "${targets[@]}"; do
    copy_to_upstream_clone "$item" "$tmpdir/repo"
  done

  echo "==> configure.mjs を実行してランタイムファイルを再生成中..."
  (cd "$tmpdir/repo" && node .scripts/configure.mjs 2>&1 | sed 's/^/  /')

  validate_framework_references "$tmpdir/repo" "upstream candidate"

  echo ""
  echo "==> upstream クローンでの差分:"
  (cd "$tmpdir/repo" && git add -A && git diff --cached --stat)

  if (cd "$tmpdir/repo" && git diff --cached --quiet); then
    echo ""
    echo "変更がありません。upstream は最新です。"
    exit 0
  fi

  echo ""
  if [ "$is_bulk" = true ]; then
    echo "上記の変更を upstream に push します (bulk)。"
  else
    echo "上記の変更を upstream に push します (path-scoped: ${PATH_ARGS[*]})。"
  fi
  if [ "${AUTO_YES:-false}" = true ]; then
    confirm="y"
  else
    read -r -p "続行しますか？ [y/N] " confirm
  fi
  case "$confirm" in
    [yY]|[yY][eE][sS])
      (cd "$tmpdir/repo" && \
        git add -A && \
        git commit -m "sync: framework updates from private repo" && \
        git push origin "$UPSTREAM_BRANCH")
      echo ""
      echo "Done! upstream に push しました。"
      ;;
    *)
      echo "キャンセルしました。"
      exit 0
      ;;
  esac
}

# ── status: 差分表示 ─────────────────────────────────────────

do_status() {
  check_remote_layout
  check_upstream
  echo "==> upstream/$UPSTREAM_BRANCH を fetch 中..."
  git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH" 2>/dev/null

  echo ""
  echo "==> framework ファイルの差分 (upstream vs local):"
  local has_diff=false

  local rel
  while IFS= read -r rel; do
    if [ -f "$rel" ] && upstream_has_file "$rel"; then
      if ! diff -q <(git show "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH:$rel") "$rel" >/dev/null 2>&1; then
        echo "  変更あり: $rel"
        has_diff=true
      fi
    elif [ -f "$rel" ]; then
      echo "  local only: $rel"
      has_diff=true
    elif upstream_has_file "$rel"; then
      echo "  upstream only: $rel"
      has_diff=true
    fi
  done < <({ list_local_framework_files; list_upstream_framework_files; } | sort -u)

  if [ "$has_diff" = false ]; then
    echo "  差分なし — upstream と同期済みです"
  fi

  echo ""
  echo "==> framework 参照検査:"
  validate_framework_references "." "local checkout"
  echo "  OK"
}

do_doctor() {
  check_remote_layout

  echo ""
  echo "==> remote:"
  git remote -v

  echo ""
  echo "==> framework 参照検査:"
  validate_framework_references "." "local checkout"
  echo "  OK"

  check_upstream

  echo ""
  echo "==> upstream/$UPSTREAM_BRANCH を fetch 中..."
  git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH" 2>/dev/null
}

do_check() {
  echo "==> configure.mjs の設定・テンプレート検査:"
  node .scripts/configure.mjs --check

  echo ""
  echo "==> 生成済み runtime ファイルの鮮度検査:"
  local dry_run_output
  dry_run_output="$(node .scripts/configure.mjs --dry-run)"
  printf '%s\n' "$dry_run_output"
  if printf '%s\n' "$dry_run_output" | grep -E '\((changed|new)\)' >/dev/null; then
    die "生成済み framework/runtime ファイルが stale です。node .scripts/configure.mjs を実行して生成物をコミットしてください"
  fi

  echo ""
  echo "==> framework 参照検査:"
  validate_framework_references "." "local checkout"
  echo "  OK"
}

# ── メイン ────────────────────────────────────────────────────

# --yes フラグと位置引数を分離
AUTO_YES=false
FORCE_PULL=false
args=()
for arg in "$@"; do
  case "$arg" in
    --yes|-y) AUTO_YES=true ;;
    --force) FORCE_PULL=true ;;
    *) args+=("$arg") ;;
  esac
done

# サブコマンドと path 引数を分離
subcmd="${args[0]:-}"
PATH_ARGS=()
if [ ${#args[@]} -gt 1 ]; then
  PATH_ARGS=("${args[@]:1}")
fi
if [ ${#PATH_ARGS[@]} -gt 0 ]; then
  normalized_paths=()
  for path in "${PATH_ARGS[@]}"; do
    normalized_paths+=("$(normalize_path "$path")")
  done
  PATH_ARGS=("${normalized_paths[@]}")
fi

case "$subcmd" in
  pull)   do_pull ;;
  push)   do_push ;;
  status) do_status ;;
  check)  do_check ;;
  doctor) do_doctor ;;
  *)
    echo "使い方: $0 {pull|push|status|check|doctor} [path...]"
    echo ""
    echo "  pull              — upstream の最新 framework 全体を取り込む (--force で未コミット変更を上書き)"
    echo "  pull <path>...    — 指定パスのみ取り込む (並列作業向け)"
    echo "  push [--yes]      — ローカルの framework 全体を upstream に送る"
    echo "  push <path>...    — 指定パスのみ送る (並列作業向け)"
    echo "  status            — upstream との差分を確認する"
    echo "  check             — ローカル framework 整合性を検査する"
    echo "  doctor            — remote 設定と framework 参照を検査する"
    echo ""
    echo "<path> は FRAMEWORK_FILES 配下 (.templates/, .scripts/, ... など) である必要があります。"
    exit 1
    ;;
esac
