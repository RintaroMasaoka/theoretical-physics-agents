#!/usr/bin/env bash
# fetch-arxiv.sh — Fetch arXiv papers (auto-detects environment)
#
# Usage:
#   bash .scripts/fetch-arxiv.sh <arxiv_id> [<arxiv_id> ...]
#
# Downloads PDF + LaTeX source for each paper.
# Results are placed in literature/papers/{id}/.
#
# The script automatically chooses the fastest available method:
#   1. Direct download via curl (works locally, ~10s per paper)
#   2. GitHub Actions relay (fallback for restricted networks, 1-3 min)

set -euo pipefail

MAX_PAPERS=20
BRANCH="arxiv-fetch"
LOCAL_DIR="literature/papers"

# --- Argument validation ---
if [ $# -eq 0 ]; then
    echo "Usage: $0 <arxiv_id> [<arxiv_id> ...]"
    echo "  e.g.: $0 2301.00001 2301.00002"
    exit 1
fi

if [ $# -gt $MAX_PAPERS ]; then
    echo "Error: Maximum $MAX_PAPERS papers per fetch (got $#). Pass only the highest-priority IDs."
    exit 1
fi

IDS=("$@")

# --- Validate arXiv ID format ---
for id in "${IDS[@]}"; do
    if ! [[ "$id" =~ ^[0-9]{4}\.[0-9]{4,5}(v[0-9]+)?$ ]]; then
        echo "Error: Invalid arXiv ID format: $id"
        echo "  Expected format: YYMM.NNNNN (e.g., 2301.00001)"
        exit 1
    fi
done

echo "=== Fetching ${#IDS[@]} paper(s): ${IDS[*]} ==="

# ── Environment detection ────────────────────────────────────
# Cloud/sandboxed environments (Codex, etc.) set HTTPS_PROXY because
# direct internet access is blocked. This check is instant (no network).

if [ -n "${HTTPS_PROXY:-}" ] || [ -n "${https_proxy:-}" ]; then
    CAN_DIRECT=false
    echo "Network: proxy detected, using GitHub Actions relay"
else
    CAN_DIRECT=true
    echo "Network: direct access"
fi

# ── Direct download (used when CAN_DIRECT=true) ─────────────

try_direct_download() {
    local id=$1
    local dir="$LOCAL_DIR/$id"
    mkdir -p "$dir"

    # Download e-print source
    if ! curl -sL --connect-timeout 10 --max-time 60 \
         -o "$dir/source" "https://arxiv.org/e-print/$id" 2>/dev/null; then
        rm -f "$dir/source"
        return 1
    fi

    # Verify: non-empty and not an HTML error page
    if [ ! -s "$dir/source" ]; then
        rm -f "$dir/source"
        return 1
    fi
    if file -b "$dir/source" | grep -qi "html"; then
        rm -f "$dir/source"
        return 1
    fi

    # Extract based on file type
    local ftype
    ftype=$(file -b "$dir/source")
    case "$ftype" in
        *gzip*|*tar*)
            (cd "$dir" && tar xzf source 2>/dev/null) || \
            (cd "$dir" && gunzip -k source 2>/dev/null) || true
            ;;
    esac

    # Download PDF
    curl -sL --connect-timeout 10 --max-time 120 \
         -o "$dir/paper.pdf" "https://arxiv.org/pdf/$id" 2>/dev/null || true

    # Download BibTeX citation
    curl -sL --connect-timeout 10 --max-time 10 \
         -o "$dir/cite.bib" "https://arxiv.org/bibtex/$id" 2>/dev/null || true
    # Remove cite.bib if it's empty or HTML
    if [ -f "$dir/cite.bib" ]; then
        if [ ! -s "$dir/cite.bib" ] || file -b "$dir/cite.bib" | grep -qi "html"; then
            rm -f "$dir/cite.bib"
        fi
    fi

    return 0
}

DIRECT_OK=()
NEED_RELAY=()

# Skip already-downloaded papers, then route by probe result
for id in "${IDS[@]}"; do
    if [ -d "$LOCAL_DIR/$id" ] && ls "$LOCAL_DIR/$id"/*.tex &>/dev/null; then
        echo "  ✓ $id (already exists locally)"
        DIRECT_OK+=("$id")
    elif [ "$CAN_DIRECT" = true ]; then
        if try_direct_download "$id"; then
            echo "  ✓ $id (direct download)"
            DIRECT_OK+=("$id")
        else
            echo "  ✗ $id (direct download failed, queued for relay)"
            NEED_RELAY+=("$id")
        fi
    else
        NEED_RELAY+=("$id")
    fi
done

# ── GitHub Actions relay (for restricted networks or individual failures) ──

relay_download() {
    local ids=("$@")
    local poll_interval=30
    local max_polls=20  # 10 minutes max

    # Build request.json
    local request_json
    request_json=$(python3 -c "
import json, sys, datetime
ids = sys.argv[1:]
data = {
    'ids': ids,
    'requested_at': datetime.datetime.utcnow().isoformat()
}
print(json.dumps(data, indent=2))
" "${ids[@]}")

    # Push request via git plumbing (no branch switch needed)
    local workflow_file=".github/workflows/fetch-arxiv.yml"
    if [ ! -f "$workflow_file" ]; then
        echo "Error: $workflow_file not found. Cannot use GitHub Actions relay."
        return 1
    fi

    echo "Pushing request to origin/$BRANCH..."
    local request_blob workflow_blob workflow_tree github_workflows_tree root_tree commit_hash
    request_blob=$(echo "$request_json" | git hash-object -w --stdin)
    workflow_blob=$(git hash-object -w "$workflow_file")
    workflow_tree=$(printf "100644 blob %s\tfetch-arxiv.yml\n" "$workflow_blob" | git mktree)
    github_workflows_tree=$(printf "040000 tree %s\tworkflows\n" "$workflow_tree" | git mktree)
    root_tree=$(printf "100644 blob %s\trequest.json\n040000 tree %s\t.github\n" "$request_blob" "$github_workflows_tree" | git mktree)
    commit_hash=$(git commit-tree "$root_tree" -m "arxiv fetch request: ${ids[*]}")
    git push -f origin "$commit_hash:refs/heads/$BRANCH" 2>&1

    echo "Request pushed. Waiting for GitHub Actions (polling every ${poll_interval}s, max ${max_polls} attempts)..."

    # Poll for results
    local fetched=false
    for i in $(seq 1 "$max_polls"); do
        sleep "$poll_interval"
        git fetch origin "$BRANCH" --quiet 2>/dev/null || { echo "  fetch failed, retrying..."; continue; }

        if git show "origin/$BRANCH:result.json" &>/dev/null; then
            local status
            status=$(git show "origin/$BRANCH:result.json" | python3 -c "import json,sys; print(json.load(sys.stdin).get('status',''))" 2>/dev/null) || { echo "  result.json parse error, retrying..."; continue; }
            if [ "$status" = "complete" ]; then
                fetched=true
                echo "Fetch complete!"
                break
            fi
        fi
        echo "  Waiting... ($i/$max_polls)"
    done

    if [ "$fetched" != "true" ]; then
        echo "Error: Fetch timed out after $((max_polls * poll_interval)) seconds"
        echo "Check GitHub Actions status manually."
        return 1
    fi

    # Extract results locally
    echo "Extracting papers to $LOCAL_DIR/..."
    for id in "${ids[@]}"; do
        mkdir -p "$LOCAL_DIR/$id"
        local files
        files=$(git ls-tree -r --name-only "origin/$BRANCH" -- "$id/" 2>/dev/null || true)
        if [ -z "$files" ]; then
            echo "  WARNING: No files found for $id"
            continue
        fi
        echo "$files" | while IFS= read -r file; do
            local target="$LOCAL_DIR/$file"
            mkdir -p "$(dirname "$target")"
            git show "origin/$BRANCH:$file" > "$target"
        done
        echo "  ✓ $id (via GitHub Actions)"
        DIRECT_OK+=("$id")
    done
}

if [ ${#NEED_RELAY[@]} -gt 0 ]; then
    echo ""
    echo "--- Using GitHub Actions relay for: ${NEED_RELAY[*]} ---"
    relay_download "${NEED_RELAY[@]}" || true
fi

# ── Merge BibTeX entries into literature/references.bib ──────

REFBIB="literature/references.bib"
touch "$REFBIB"
BIB_ADDED=0
for id in "${IDS[@]}"; do
    cite="$LOCAL_DIR/$id/cite.bib"
    if [ -f "$cite" ]; then
        if ! grep -qF "eprint = {$id}" "$REFBIB" 2>/dev/null; then
            echo "" >> "$REFBIB"
            cat "$cite" >> "$REFBIB"
            BIB_ADDED=$((BIB_ADDED + 1))
        fi
    fi
done
if [ "$BIB_ADDED" -gt 0 ]; then
    echo "Added $BIB_ADDED BibTeX entry/entries to $REFBIB"
fi

# ── Report ───────────────────────────────────────────────────

echo ""
echo "=== Results ==="
for id in "${IDS[@]}"; do
    dir="$LOCAL_DIR/$id"
    if [ -d "$dir" ] && [ "$(ls -A "$dir" 2>/dev/null)" ]; then
        echo "  arXiv:$id"
        for f in "$dir"/*; do
            [ -f "$f" ] || continue
            local_name=$(basename "$f")
            size=$(wc -c < "$f" | tr -d ' ')
            echo "    $local_name  ($size bytes)"
        done
    else
        echo "  arXiv:$id — FAILED"
    fi
done
echo ""
echo "Papers saved to $LOCAL_DIR/"
echo "=== Done ==="
