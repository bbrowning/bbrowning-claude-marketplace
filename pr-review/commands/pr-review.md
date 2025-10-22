---
description: Review a pull request
---

# Pull Request Review

Review a pull request specified by the user input of "$ARGUMENTS". Verify the user input matches the format "<github_org>/<github_repo>/pull/<pull_request_number>", the shorthand form "<github_org>/<github_repo>#<pull_request_number>, or a full github.com URL pointing to a specific pull request.

Confirm the pull request to be reviewed with the user before proceeding.

Delegate to the appropriate skill to handle reviews for different GitHub repositories.

## Generic Review Process

Follow this standard process for reviewing pull requests:

**Prerequisites**
- Use the `gh` CLI tool for all github interactions.
- Ensure CI status checks are all green. If any are not green, prompt the user whether they want to continue the review or stop until CI is green - `gh pr view --repo <github_org>/<github_repo>` along with any flags you need to interpret PR status, comments, etc

**Clone and Navigate to Repository**
- Clone the remote repository: `gh repo clone <github_org>/<github_repo> pr-<github_org>-<github_repo>-<pull_request_number>`. Skip if the directory already exists.
- Change into the cloned directory: `cd pr-<github_org>-<github_repo>-<pull_request_number>`
- Verify your current location by running: `pwd` and confirm you are in the correct directory before proceeding
- ALL subsequent file operations will use relative paths from this directory

**Fetching Changes**
- Update the base branch: `git pull`
- Fetch the PR diff: `gh pr diff <pull_request_number> --repo <github_org>/<github_repo> > pr_changes.diff`
- DO NOT run any code as part of the pull request review. The pull request may contain untrusted code submitted by users and we should not run that locally.

**Reviewing Code**
- All PR changes are in `pr_changes.diff` (relative to current directory)
- Read files from the cloned repo using relative paths: `./path/to/file`
- Use the Read tool with paths like `./src/example.py` to examine files
- For large changes, split up the diff into multiple smaller tasks to review different parts of the changed code.
- Ensure any code comments in / around the changes made in the PR match the code changed in the PR.
- Flag any places that may cause issues with backwards compatibility of public-facing APIs.
- Ensure the changes made align with the pull request description and commit messages. Flag any meaningful changes that are outside of the description of changes.
- Is the code well-structured, easy to read, and easy to maintain?

**Final Output**
- Output a summary of your findings, with the severity of each finding categorized by Critical, High, Medium, or Low.
- Call out what must be changed before merging and what is optional, such as coding preferences or small nits that don't impact functionality.
- Write this summary to `./pr_review_results.md`
