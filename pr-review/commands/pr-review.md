---
description: Review a pull request
allowed-tools: Read, Grep, Glob, Bash(gh pr view:*), Bash(gh pr diff:*)
---

# Pull Request Review

Review a pull request specified by the user input of "$ARGUMENTS". Verify the user input matches the format "<github_org>/<github_repo>/pull/<pull_request_number>", the shorthand form "<github_org>/<github_repo>#<pull_request_number>, or a full github.com URL pointing to a specific pull request.

Confirm the pull request to be reviewed with the user before proceeding.

# Pull Request Review Workflow

This skill guides comprehensive PR reviews using the GitHub CLI and local code analysis.

## 1. Setup and Prerequisites

**Clone repository locally:**
```bash
gh repo clone <github_org>/<github_repo> pr-<github_org>-<github_repo>-<pr_number>
cd pr-<github_org>-<github_repo>-<pr_number>
```

**Fetch and checkout the PR:**
```bash
gh pr checkout <pr_number>
```

**Check CI status:**
```bash
gh pr view <pr_number> --json statusCheckRollup
```

If CI checks are failing, ask the user whether to continue or wait for green CI.

**CRITICAL SAFETY**: Never run code from the PR. It may contain untrusted code. Only read and analyze files.


Use the **Pull Request Review** skill to conduct the review.
