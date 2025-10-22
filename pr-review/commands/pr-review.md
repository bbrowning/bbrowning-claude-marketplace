---
description: Review a pull request
---

# Pull Request Review

Review a pull request specified by the user input of "$ARGUMENTS". Verify the user input matches the format "<github_org>/<github_repo>/pull/<pull_request_number>", the shorthand form "<github_org>/<github_repo>#<pull_request_number>, or a full github.com URL pointing to a specific pull request.

Confirm the pull request to be reviewed with the user before proceeding.

Delegate to the appropriate skill to handle reviews for different GitHub repositories.

## Generic Review Process

Follow this standard process for reviewing pull requests:

**Setup Variables**
- Define the clone directory path: `CLONE_DIR="$PWD/pr-<github_org>-<github_repo>-<pull_request_number>"`
- Use this variable for ALL subsequent file operations and git commands
- NEVER use `cd` to change directories - always use absolute paths with the CLONE_DIR variable

**Prerequisites**
- Use the `gh` CLI tool for all github interactions.
- Ensure CI status checks are all green. If any are not green, prompt the user whether they want to continue the review or stop until CI is green - `gh pr view --repo <github_org>/<github_repo>` along with any flags you need to interpret PR status, comments, etc
- Clone the remote repository: `gh repo clone <github_org>/<github_repo> "$CLONE_DIR"`. Skip if the directory already exists.

**Fetching Changes**
- Update the base branch: `git -C "$CLONE_DIR" pull`
- Fetch the PR diff: `gh pr diff <pull_request_number> --repo <github_org>/<github_repo> > "$CLONE_DIR/pr_changes.diff"`
- DO NOT run any code as part of the pull request review. The pull request may contain untrusted code submitted by users and we should not run that locally.

**Reviewing Code**
- All PR changes are in `$CLONE_DIR/pr_changes.diff`
- Read files from the cloned repo using absolute paths: `$CLONE_DIR/path/to/file`
- Use the Read tool with paths like `$CLONE_DIR/src/example.py` to examine files
- For large changes, split up the diff into multiple smaller tasks to review different parts of the changed code.
- Ensure any code comments in / around the changes made in the PR match the code changed in the PR.
- Flag any places that may cause issues with backwards compatibility of public-facing APIs.
- Ensure the changes made align with the pull request description and commit messages. Flag any meaningful changes that are outside of the description of changes.
- Is the code well-structured, easy to read, and easy to maintain?

**Final Output**
- Output a summary of your findings, with the severity of each finding categorized by Critical, High, Medium, or Low.
- Call out what must be changed before merging and what is optional, such as coding preferences or small nits that don't impact functionality.
- Write this summary to `$CLONE_DIR/pr_review_results.md`
