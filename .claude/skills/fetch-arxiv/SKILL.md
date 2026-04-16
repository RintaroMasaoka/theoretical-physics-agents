---
name: fetch-arxiv
description: "Fetch arXiv papers (PDF + LaTeX source). Usage: /fetch-arxiv 2301.00001 [2301.00002 ...]"
user-invocable: true
argument-hint: "ARXIV_ID [ARXIV_ID ...]"
---

# fetch-arxiv — arXiv Paper Fetcher

Fetches arXiv papers (PDF, LaTeX source, BibTeX). The script tries direct download first (~10s per paper) and falls back to a GitHub Actions relay (1-3 min) when direct network access to arXiv is blocked. The fallback triggers a GitHub Actions workflow that downloads the paper from GitHub's infrastructure, pushes the result to a temporary branch (`arxiv-fetch`), and the script pulls it locally. This is fully automatic — callers do not need to know which method is used.

Arguments: $ARGUMENTS

## Execution

```bash
bash .scripts/fetch-arxiv.sh $ARGUMENTS
```

The script handles download, extraction, and BibTeX merge into `literature/references.bib`. Sub-agents can invoke the same command. Before fetching, check if `literature/papers/{id}/` already exists to avoid redundant downloads. After fetching, the main `.tex` file is the one containing `\documentclass`.

Upper limit: 20 papers per fetch (arXiv rate limits and GitHub Actions job duration). The script will reject more than 20 IDs. If more are needed, split into multiple fetches.

## After Fetch

1. Report the list of fetched files to the user (the script prints this)
2. Papers are placed in `literature/papers/{id}/`:
   - `paper.pdf` — PDF file
   - `*.tex`, `*.bib`, `*.sty`, etc. — LaTeX source files

## Error Handling

- **Timeout**: Record the failure in the session output and continue. The user can review GitHub Actions status during `/meeting` if needed
- **Paper not found**: The result will show no files for that ID
- **Network failure**: The script retries automatically. If all retries fail, record the failure and move on rather than blocking execution

## Cleanup

The remote `arxiv-fetch` branch is ephemeral and force-pushed on each run. No manual cleanup is needed.
