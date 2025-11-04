---
description: Review a pull request
allowed-tools: Read, Grep, Glob, Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr checks:*), Bash(gh pr checkout:*), Bash(git worktree:*), Bash(cd:*), Bash(pwd:*), Bash(ln:*), Bash(ls:*)
---

# Pull Request Review Setup

Set up an isolated git worktree for reviewing the pull request specified by "$ARGUMENTS".

## 1. Parse PR Reference

Verify the user input matches one of these formats:
- `<github_org>/<github_repo>/pull/<pull_request_number>`
- `<github_org>/<github_repo>#<pull_request_number>`
- Full github.com URL pointing to a specific pull request

Extract the organization, repository, and PR number from the provided reference.

## 2. Fetch PR Metadata

Use `gh pr view` to get basic information about the PR:
```bash
gh pr view <pr_number> --repo <github_org>/<github_repo> --json title,author,headRefName,baseRefName,state,isDraft
```

Confirm the pull request details with the user before proceeding.

## 3. Create Isolated Git Worktree

**Determine repository location:**
- Check if the repository exists locally (look in ~/src/, ~/repos/, user's configured paths)
- If not found, ask the user for the repository path or if they want to clone it first

**Create worktree and checkout PR:**
```bash
cd <repo_path>
git worktree add ../<repo_name>-pr-<pr_number> -b review-pr-<pr_number> origin/main
cd ../<repo_name>-pr-<pr_number>
gh pr checkout <pr_number> --repo <github_org>/<github_repo>
```

**Set up .claude configuration sharing:**
```bash
cd ../<repo_name>-pr-<pr_number>
# Check if .claude exists, if not create symlink to main worktree's .claude
if [ ! -e .claude ] && [ -d <main_worktree>/.claude ]; then
  ln -sf <main_worktree>/.claude .claude
fi
```

## 4. Determine Relevant Skills for Handoff

Before providing handoff instructions, identify which skills should be available in the new Claude Code session:

1. **Repository-specific skills**: Check if there's a skill matching the repository (e.g., "llama-stack" for llamastack/llama-stack)
2. **Domain-specific skills**: Based on PR title/description, identify relevant skills (e.g., "auth-security" for authentication changes)
3. **pr-review skill**: Always relevant for the review workflow

List all relevant skills to include in the handoff prompt.

## 5. Provide Handoff Instructions

**STOP HERE** and provide the user with instructions to start a new Claude Code session:

```
I've created an isolated git worktree for PR #<pr_number> (<github_org>/<github_repo>):

Location: <worktree_path>

To continue the review in a clean environment:

1. Open a new terminal
2. cd <worktree_path>
3. Start Claude Code: claude
4. In the new session, provide this prompt:

   Review PR #<pr_number> for <github_org>/<github_repo>. I'm already in a git worktree with the PR checked out. Use the pr-review skill (and <list-any-repo-or-domain-specific-skills>) to perform a comprehensive review. Skip worktree setup and go directly to gathering PR context and analyzing changes.

This ensures we review the correct code in isolation with proper context.
```

**Important**: Include ALL relevant skills in the handoff instructions so the new session has complete context.

After the review is complete in the new session, remind the user to clean up the worktree:
```bash
cd <repo_path>
git worktree remove --force <repo_name>-pr-<pr_number>
git branch -D review-pr-<pr_number>
```
