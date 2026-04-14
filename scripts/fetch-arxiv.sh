#!/usr/bin/env bash
# fetch-arxiv.sh — Fetch arXiv papers via GitHub Actions relay
#
# Usage:
#   bash scripts/fetch-arxiv.sh <arxiv_id> [<arxiv_id> ...]
#
# Downloads PDF + LaTeX source for each paper.
# Results are placed in research/papers/{id}/.
#
# Mechanism:
#   1. Push request to arxiv-fetch branch (orphan, force-push)
#   2. GitHub Actions downloads papers from arXiv
#   3. This script polls until results appear
#   4. Extracts results to local research/papers/

set -euo pipefail

MAX_PAPERS=20
POLL_INTERVAL=30
MAX_POLLS=20  # 10 minutes max
BRANCH="arxiv-fetch"
LOCAL_DIR="research/papers"

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

# --- Build request.json ---
REQUEST_JSON=$(python3 -c "
import json, sys, datetime
ids = sys.argv[1:]
data = {
    'ids': ids,
    'requested_at': datetime.datetime.utcnow().isoformat()
}
print(json.dumps(data, indent=2))
" "${IDS[@]}")

# --- Push request via git plumbing (no branch switch needed) ---
# The orphan commit must include the workflow file, otherwise GitHub Actions
# won't trigger (push events look for workflows on the pushed branch).
echo "Pushing request to origin/$BRANCH..."

WORKFLOW_FILE=".github/workflows/fetch-arxiv.yml"
if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "Error: $WORKFLOW_FILE not found. Run from the repo root."
    exit 1
fi

REQUEST_BLOB=$(echo "$REQUEST_JSON" | git hash-object -w --stdin)
WORKFLOW_BLOB=$(git hash-object -w "$WORKFLOW_FILE")

# Build tree: request.json + .github/workflows/fetch-arxiv.yml
WORKFLOW_TREE=$(printf "100644 blob %s\tfetch-arxiv.yml\n" "$WORKFLOW_BLOB" | git mktree)
GITHUB_WORKFLOWS_TREE=$(printf "040000 tree %s\tworkflows\n" "$WORKFLOW_TREE" | git mktree)
GITHUB_TREE=$(printf "040000 tree %s\t.github\n" "$GITHUB_WORKFLOWS_TREE" | git mktree)
ROOT_TREE=$(printf "100644 blob %s\trequest.json\n040000 tree %s\t.github\n" "$REQUEST_BLOB" "$GITHUB_WORKFLOWS_TREE" | git mktree)

COMMIT=$(git commit-tree "$ROOT_TREE" -m "arxiv fetch request: ${IDS[*]}")
git push -f origin "$COMMIT:refs/heads/$BRANCH" 2>&1

echo "Request pushed. Waiting for GitHub Actions (polling every ${POLL_INTERVAL}s, max ${MAX_POLLS} attempts)..."

# --- Poll for results ---
FETCHED=false
for i in $(seq 1 "$MAX_POLLS"); do
    sleep "$POLL_INTERVAL"

    git fetch origin "$BRANCH" --quiet 2>/dev/null || { echo "  fetch failed, retrying..."; continue; }

    if git show "origin/$BRANCH:result.json" &>/dev/null; then
        STATUS=$(git show "origin/$BRANCH:result.json" | python3 -c "import json,sys; print(json.load(sys.stdin).get('status',''))" 2>/dev/null) || { echo "  result.json parse error, retrying..."; continue; }
        if [ "$STATUS" = "complete" ]; then
            FETCHED=true
            echo "Fetch complete!"
            break
        fi
    fi

    echo "  Waiting... ($i/$MAX_POLLS)"
done

if [ "$FETCHED" != "true" ]; then
    echo "Error: Fetch timed out after $((MAX_POLLS * POLL_INTERVAL)) seconds"
    echo "Check GitHub Actions status manually."
    exit 1
fi

# --- Extract results locally ---
echo "Extracting papers to $LOCAL_DIR/..."

FAIL_COUNT=0
for ID in "${IDS[@]}"; do
    mkdir -p "$LOCAL_DIR/$ID"

    # List files for this paper on the remote branch
    FILES=$(git ls-tree -r --name-only "origin/$BRANCH" -- "$ID/" 2>/dev/null || true)

    if [ -z "$FILES" ]; then
        echo "  WARNING: No files found for $ID"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        continue
    fi

    echo "$FILES" | while IFS= read -r file; do
        TARGET="$LOCAL_DIR/$file"
        mkdir -p "$(dirname "$TARGET")"
        git show "origin/$BRANCH:$file" > "$TARGET"
    done
done

if [ "$FAIL_COUNT" -eq "${#IDS[@]}" ]; then
    echo "Error: No papers were fetched successfully."
    exit 1
fi

# --- Merge BibTeX entries into literature/references.bib ---
REFBIB="literature/references.bib"
touch "$REFBIB"
BIB_ADDED=0
for ID in "${IDS[@]}"; do
    CITE="$LOCAL_DIR/$ID/cite.bib"
    if [ -f "$CITE" ]; then
        # Check if this eprint is already in references.bib
        if ! grep -qF "eprint = {$ID}" "$REFBIB" 2>/dev/null; then
            echo "" >> "$REFBIB"
            cat "$CITE" >> "$REFBIB"
            BIB_ADDED=$((BIB_ADDED + 1))
        fi
    fi
done
if [ "$BIB_ADDED" -gt 0 ]; then
    echo "Added $BIB_ADDED BibTeX entry/entries to $REFBIB"
fi

# --- Report ---
echo ""
echo "=== Results ==="
git show "origin/$BRANCH:result.json" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for pid, files in data.get('papers', {}).items():
    print(f'  arXiv:{pid}')
    for f in files:
        path = f['path'] if isinstance(f, dict) else f
        size = f.get('size', 0) if isinstance(f, dict) else 0
        if size > 0:
            print(f'    {path}  ({size:,} bytes)')
        else:
            print(f'    {path}')
print()
"

echo "Papers saved to $LOCAL_DIR/"
echo "=== Done ==="
