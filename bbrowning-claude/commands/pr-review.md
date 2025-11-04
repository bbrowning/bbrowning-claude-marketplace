---
description: Review a pull request
allowed-tools: Read, Grep, Glob, Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr checks:*), Bash(gh pr checkout:*), Bash(git worktree:*), Bash(cd:*), Bash(pwd:*), Skill
---

# Pull Request Review

Review a pull request specified by the user input of "$ARGUMENTS".

## Parse PR Reference

Verify the user input matches one of these formats:
- `<github_org>/<github_repo>/pull/<pull_request_number>`
- `<github_org>/<github_repo>#<pull_request_number>`
- Full github.com URL pointing to a specific pull request

Extract the organization, repository, and PR number from the provided reference.

Confirm the pull request to be reviewed with the user before proceeding.

## Invoke PR Review Skill

Use the Skill tool to invoke `bbrowning-claude:pr-review`, which will:
1. Create an isolated git worktree for the PR
2. Set up .claude configuration sharing
3. Provide handoff instructions to continue the review in the worktree
4. Include all relevant skills (repository-specific and domain-specific) in the handoff prompt

All PR review workflow logic is contained in the pr-review skill to ensure a single source of truth.
