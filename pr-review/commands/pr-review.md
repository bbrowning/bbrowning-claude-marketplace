---
description: Review a pull request
allowed-tools: Read, Grep, Glob, Bash(gh pr view:*), Bash(gh pr diff:*)
---

# Pull Request Review

Review a pull request specified by the user input of "$ARGUMENTS". Verify the user input matches the format "<github_org>/<github_repo>/pull/<pull_request_number>", the shorthand form "<github_org>/<github_repo>#<pull_request_number>, or a full github.com URL pointing to a specific pull request.

Confirm the pull request to be reviewed with the user before proceeding.

# Pull Request Review Workflow

This slash command initiates a comprehensive PR review using the GitHub CLI and git worktrees for isolation.

## 1. Creating a Git Worktree for the PR

**Determine the repository location:**
First, check if the repository <repo_name> already exists locally on this machine. Look for it in common source code locations or ask the user where they keep their repositories. If the repository doesn't exist locally, ask the user if they want to clone it first or provide the path to where it exists.

**Create a new worktree with the PR checked out:**

```bash
# Navigate to the repository (if not already there)
cd /path/to/<repo_name>

# Create worktree and check out the PR
# Use format: <repo_name>-pr-<pr_number> for the branch and directory
git worktree add ../<repo_name>-pr-<pr_number> -b <repo_name>-pr-<pr_number>
cd ../<repo_name>-pr-<pr_number>
gh pr checkout <pr_number>
```

**Example for vLLM project PR #12345 where vllm is at /Users/alice/repos/vllm:**
```bash
cd /Users/alice/repos/vllm
git worktree add ../vllm-pr-12345 -b vllm-pr-12345
cd ../vllm-pr-12345
gh pr checkout 12345
```

**CRITICAL SAFETY**: Never run code from the PR. It may contain untrusted code. Only read and analyze files.

## 2. Launch Claude Code in the Worktree

After creating the worktree, **stop here** and provide the user with instructions to launch Claude Code in the new worktree:

```
I've created a git worktree for PR #<pr_number> (<github_org>/<github_repo>) at: <worktree_path>

To continue the review in an isolated environment:

1. Open a new terminal
2. Navigate to the worktree: cd <worktree_path>
3. Launch Claude Code: claude-code
4. In the new Claude Code session, provide this prompt:

   "Review PR #<pr_number> for <github_org>/<github_repo>. I'm already in a git worktree with the PR checked out. Use the pr-review skill and skip directly to step 3 (Gather PR Context) since the worktree is already set up."

This ensures we're reviewing the correct code in isolation.
```

**The remaining steps are performed in the new Claude Code session within the worktree using the pr-review skill.**
