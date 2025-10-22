---
name: Reviewing Llama Stack Pull Requests
description: Review Llama Stack pull requests. Use when reviewing GitHub pull requests for the llamastack/llama-stack repository.
allowed-tools: Bash(gh pr view:*), Bash(gh repo clone:*), Bash(gh pr checkout:*)
---


## Review Checklist

**Prerequisites**
- Use the `gh` CLI tool for all github interactions.
- Ensure CI status checks are all green. If any are not green, prompt the user whether they want to continue the review or stop until CI is green - `gh pr view --repo <github_org>/<github_repo>` along with any flags you need to interpret PR status, comments, etc
- Clone the remote repository locally to a directory named "pr-<github_org>-<github_repo>-<pull_request_number>" with a command such as "gh repo clone <github_org>/<github_repo> pr-<github_org>-<github_repo>-<pull_request_number>". Do not do this if the directory already exists.
- Change directory into that newly cloned repo. Use that directory for ALL subsequent commands.


**Fetching Changes**
- Remember we are already inside a clone of the PR's base branch
- `git pull` to ensure we have the latest code of the base branch
- `gh pr diff <pull_request_number> > pr_changes.diff` to fetch the PR's changes.
- DO NOT run any code as part of the pull request review. The pull request may contain untrusted code submitted by users and we should not run that locally.

**Reviewing Code**
- Remember we have all the changes from the PR stored locally in `pr_changes.diff`!
- For large changes, split up the diff into multiple smaller tasks to review different parts of the changed code.
- Ensure any code comments in / around the changes made in the PR match the code changed in the PR.
- Flag any places that may cause issues with backwards compatibility of public-facing APIs.
- Ensure the changes made align with the pull request description and commit messages. Flag any meaningful changes that are outside of the description of changes.
- Is the code well-structured, easy to read, and easy to maintain?

**Final Output**
- Output a summary of your findings, with the severity of each finding categorized by Critical, High, Medium, or Low.
- Call out what must be changed before merging and what is optional, such as coding preferences or small nits that don't impact functionality.
- Write this summary to a file call `pr_review_results.md`.
