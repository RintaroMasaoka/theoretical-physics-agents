---
name: fetch-arxiv
description: "Fetch arXiv papers (PDF + LaTeX source) via GitHub Actions relay. Usage: /fetch-arxiv 2301.00001 [2301.00002 ...]"
user-invocable: true
argument-hint: "ARXIV_ID [ARXIV_ID ...]"
---

# fetch-arxiv — arXiv Paper Fetcher

Fetches arXiv papers by relaying the download through GitHub Actions, bypassing cloud environment network restrictions.

Arguments: $ARGUMENTS

## Mechanism

```
[This environment]                    [GitHub Actions]              [arXiv]
   push request.json       ──>       trigger workflow     ──>     download PDF + source
   to arxiv-fetch branch              extract LaTeX
                                      push results        ──>     orphan branch
   poll & extract           <──       (force-push)
```

## Execution

Run the fetch script with the arXiv IDs from the arguments:

```bash
bash .scripts/fetch-arxiv.sh $ARGUMENTS
```

**Important**: This command takes 1-3 minutes (GitHub Actions execution + polling). The script handles everything automatically: push request, poll for completion, extract results.

Upper limit: 20 papers per fetch (GitHub Actions artifact size and arXiv rate limits). If more are needed, split into multiple fetches.

## After Fetch

1. Report the list of fetched files to the user (the script prints this)
2. Papers are placed in `literature/papers/{id}/`:
   - `paper.pdf` — PDF file
   - `*.tex`, `*.bib`, `*.sty`, etc. — LaTeX source files
3. The main `.tex` file is the one containing `\documentclass`

## For Sub-agents

Sub-agents can invoke the fetch script directly via Bash when direct download (curl/WebFetch) fails due to network restrictions:

```bash
bash .scripts/fetch-arxiv.sh {arxiv_id}
```

The script manages the `arxiv-fetch` branch internally; callers do not need to switch branches or manage git state.

## Error Cases

- **Timeout**: If the script times out, suggest the user check GitHub Actions status
- **Paper not found**: If the arXiv ID is invalid, the result will show no files for that ID
- **Network failure**: The script retries git fetch on failure. If persistent, retry the whole command

## Cleanup

The remote `arxiv-fetch` branch is ephemeral and requires no manual cleanup. Local files in `literature/papers/` can be deleted freely when no longer needed.
