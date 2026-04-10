---
name: fetch-arxiv
description: "Fetch arXiv papers (PDF + LaTeX source) via GitHub Actions relay. Usage: /fetch-arxiv 2301.00001 [2301.00002 ...]"
user-invocable: true
---

# fetch-arxiv — arXiv Paper Fetcher

Fetches arXiv papers by relaying the download through GitHub Actions, bypassing cloud environment network restrictions.

## Mechanism

```
[This environment]                    [GitHub Actions]              [arXiv]
   push request.json       ──>       trigger workflow     ──>     download PDF + source
   to arxiv-fetch branch              extract LaTeX                 
                                      push results        ──>     orphan branch
   poll & extract           <──       (force-push)
```

## Usage

Arguments: one or more arXiv IDs, space-separated.

```
/fetch-arxiv 2301.00001
/fetch-arxiv 2301.00001 2301.00002 2301.00003
```

Upper limit: 20 papers per fetch. If more are needed, pass only the highest-priority IDs.

## Execution

Run the fetch script:

```bash
bash scripts/fetch-arxiv.sh {ARXIV_IDS}
```

where `{ARXIV_IDS}` are the arXiv IDs from the arguments, space-separated.

**Important**: This command takes 1-3 minutes (GitHub Actions execution + polling). The script handles everything automatically: push request, poll for completion, extract results.

## After Fetch

1. Report the list of fetched files to the user (the script prints this)
2. Papers are placed in `literature/papers/{id}/`:
   - `paper.pdf` — PDF file
   - `*.tex`, `*.bib`, `*.sty`, etc. — LaTeX source files
3. The main `.tex` file is the one containing `\documentclass`

## For Sub-agents (reader, researcher, etc.)

Sub-agents can invoke the fetch script directly via Bash when paper acquisition via curl/WebFetch fails:

```bash
bash scripts/fetch-arxiv.sh {arxiv_id}
```

The script is self-contained and does not require branch switching.

## Error Cases

- **Timeout**: Actions may take longer than expected. If the script times out, suggest the user check GitHub Actions status
- **Paper not found**: If the arXiv ID is invalid, the result will show no files for that ID
- **Network failure**: The script retries git fetch on failure. If persistent, retry the whole command

## Cleanup

The `arxiv-fetch` remote branch is an orphan that gets force-pushed on each fetch. It holds only the latest results and does not accumulate history. GitHub's GC reclaims unreachable blobs over time.

Local files in `literature/papers/` can be deleted freely when no longer needed.
