#!/usr/bin/env bash
# sync.sh — framework ファイルを upstream (public repo) と同期するスクリプト
#
# 使い方:
#   bash .scripts/sync.sh pull                    — upstream の最新 framework 全体を取り込む
#   bash .scripts/sync.sh pull <path>...          — 指定パスのみ upstream から取り込む
#   bash .scripts/sync.sh push [--yes]            — framework 全体を upstream に送る
#   bash .scripts/sync.sh push <path>... [--yes]  — 指定パスのみ upstream に送る
#   bash .scripts/sync.sh status                  — upstream との差分を表示する
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
  "AGENTS.md"
  "CLAUDE.md"
  ".gitignore"
  ".github/"
  ".scripts/"
  ".claude/config/"
  ".claude/settings.json"
  ".templates/"
)

# push 時 (bulk) に upstream から削除すべき stale ファイル
STALE_FILES=(
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

UPSTREAM_REMOTE="upstream"
UPSTREAM_BRANCH="main"
ORIG_ARGS=("$@")

# ── ヘルパー関数 ──────────────────────────────────────────────

die() { echo "Error: $*" >&2; exit 1; }

check_upstream() {
  git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1 \
    || die "remote '$UPSTREAM_REMOTE' が見つかりません。先に git remote add $UPSTREAM_REMOTE <url> を実行してください"
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
    cp -R "$item_clean"/* "$dest_root/$item_clean/" 2>/dev/null || true
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

  local item
  for item in "${targets[@]}"; do
    git checkout "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH" -- "$item" 2>/dev/null && \
      echo "  ✓ $item" || \
      echo "  - $item (upstream に存在しないためスキップ)"
  done

  echo ""
  echo "==> configure.mjs を実行してランタイムファイルを再生成中..."
  node .scripts/configure.mjs

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
  check_upstream
  echo "==> upstream/$UPSTREAM_BRANCH を fetch 中..."
  git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH"

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
  check_upstream
  echo "==> upstream/$UPSTREAM_BRANCH を fetch 中..."
  git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH" 2>/dev/null

  echo ""
  echo "==> framework ファイルの差分 (upstream vs local):"
  local has_diff=false
  for item in "${FRAMEWORK_FILES[@]}"; do
    # ファイルの場合
    if [ -f "$item" ]; then
      if ! diff -q <(git show "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH:$item" 2>/dev/null) "$item" >/dev/null 2>&1; then
        echo "  変更あり: $item"
        has_diff=true
      fi
    fi
    # ディレクトリの場合は中のファイルを比較
    if [ -d "$item" ]; then
      while IFS= read -r -d '' file; do
        local rel="${file#./}"
        if ! diff -q <(git show "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH:$rel" 2>/dev/null) "$rel" >/dev/null 2>&1; then
          echo "  変更あり: $rel"
          has_diff=true
        fi
      done < <(find "$item" -type f -print0)
    fi
  done

  if [ "$has_diff" = false ]; then
    echo "  差分なし — upstream と同期済みです"
  fi
}

# ── メイン ────────────────────────────────────────────────────

# --yes フラグと位置引数を分離
AUTO_YES=false
args=()
for arg in "$@"; do
  case "$arg" in
    --yes|-y) AUTO_YES=true ;;
    *) args+=("$arg") ;;
  esac
done

# サブコマンドと path 引数を分離
subcmd="${args[0]:-}"
PATH_ARGS=()
if [ ${#args[@]} -gt 1 ]; then
  PATH_ARGS=("${args[@]:1}")
fi

case "$subcmd" in
  pull)   do_pull ;;
  push)   do_push ;;
  status) do_status ;;
  *)
    echo "使い方: $0 {pull|push|status} [path...]"
    echo ""
    echo "  pull              — upstream の最新 framework 全体を取り込む"
    echo "  pull <path>...    — 指定パスのみ取り込む (並列作業向け)"
    echo "  push [--yes]      — ローカルの framework 全体を upstream に送る"
    echo "  push <path>...    — 指定パスのみ送る (並列作業向け)"
    echo "  status            — upstream との差分を確認する"
    echo ""
    echo "<path> は FRAMEWORK_FILES 配下 (.templates/, .scripts/, ... など) である必要があります。"
    exit 1
    ;;
esac
