---
name: fetch-arxiv
description: "Fetch arXiv papers (PDF + LaTeX source) via GitHub Actions relay. Usage: /fetch-arxiv 2301.00001 [cond-mat/9905027 ...]"
user-invocable: true
argument-hint: "ARXIV_ID [ARXIV_ID ...]"
---

# fetch-arxiv — arXiv Paper Fetcher

Fetches arXiv papers by relaying the download through GitHub Actions, bypassing cloud environment network restrictions.

Arguments: $ARGUMENTS

## Accepted ID Formats

- **New format**: `YYMM.NNNNN[vN]` — e.g., `2301.00001`, `2301.00001v2`
- **Legacy format**: `archive[.SUBJ]/YYMMNNN[vN]` — e.g., `cond-mat/9905027`, `hep-th/0506213`, `math.AG/0506213`

Legacy-ID papers are saved under `literature/papers/{archive}/{YYMMNNN}/` (the `/` in the ID becomes a directory separator).

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

{{#if runtime.is_codex}}
## Codex Permission Handling

This skill uses a fixed project script that writes Git objects, pushes an ephemeral branch, fetches results, and writes under `literature/`. Those operations may fail under Codex sandboxing even though the procedure is routine for this project.

If the normal command fails with `Operation not permitted`, `.git/FETCH_HEAD`, `.git/objects`, `git hash-object`, `git mktree`, `git commit-tree`, `git push`, or another likely sandbox-related Git permission error, and the runtime allows approval requests, immediately rerun the **same** command with `sandbox_permissions="require_escalated"` and propose `prefix_rule=["bash", ".scripts/fetch-arxiv.sh"]`. The approval request should describe the fixed purpose: fetching arXiv paper sources through the project relay. If approval requests are unavailable in the current runtime, report a permission-gated fetch failure rather than reclassifying it as paper unavailability.

Do not treat this failure as evidence that the paper is unavailable, that arXiv failed, or that the research should proceed from abstracts. It is an execution capability issue for the standard fetch path.
{{/if}}

Upper limit: 20 papers per fetch (GitHub Actions artifact size and arXiv rate limits). If more are needed, split into multiple fetches.

## After Fetch

1. If user-invoked, report the list of fetched files to the user; if called by a sub-agent, return the fetched file list to the caller. The script prints this list.
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

{{#if runtime.is_codex}}
For Codex sub-agents, use the same permission-handling rule above.
{{/if}}

## Error Cases

- **Timeout**: If the script times out, suggest the user check GitHub Actions status
- **Paper not found**: If the arXiv ID is invalid, the result will show no files for that ID
- **Network failure**: The script retries git fetch on failure. If persistent, retry the whole command
- **Permission failure**: In Codex, follow the permission-handling rule above before recording fetch failure

## Cleanup

The remote `arxiv-fetch` branch is ephemeral and requires no manual cleanup. Local files in `literature/papers/` can be deleted freely when no longer needed.
