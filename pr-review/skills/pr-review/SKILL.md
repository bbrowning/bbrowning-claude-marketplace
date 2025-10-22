---
name: Pull Request Review
description: Review GitHub pull requests with structured workflow providing categorized findings (Critical/High/Medium/Low), backward compatibility checks, and repository-specific guidelines. Use when analyzing code changes in pull requests.
allowed-tools: Read, Grep, Glob, Bash(gh pr view*), Bash(gh repo clone*), Bash(gh pr diff*), Bash(git pull), Bash(pwd)
---

# Pull Request Review Process

Follow this standard process for reviewing pull requests:

## Prerequisites

- Use the `gh` CLI tool for all GitHub interactions.
- Ensure CI status checks are all green. If any are not green, prompt the user whether they want to continue the review or stop until CI is green - `gh pr view --repo <github_org>/<github_repo>` along with any flags you need to interpret PR status, comments, etc

## Clone and Navigate to Repository

- Clone the remote repository: `gh repo clone <github_org>/<github_repo> pr-<github_org>-<github_repo>-<pull_request_number>`. Skip if the directory already exists.
- Change into the cloned directory: `cd pr-<github_org>-<github_repo>-<pull_request_number>`
- All subsequent file operations and git commands will use relative paths from this directory

## Fetching Changes

- Update the base branch: `git pull`
- Fetch the PR diff: `gh pr diff <pull_request_number> --repo <github_org>/<github_repo> > pr_changes.diff`
- DO NOT run any code as part of the pull request review. The pull request may contain untrusted code submitted by users and we should not run that locally.

## Reviewing Code

- Read the PR diff from `./pr_changes.diff`
- Read files from the cloned repo using relative paths like `./src/example.py`
- For large changes, split up the diff into multiple smaller tasks to review different parts of the changed code.
- Ensure any code comments in / around the changes made in the PR match the code changed in the PR.
- Flag any places that may cause issues with backwards compatibility of public-facing APIs.
- Ensure the changes made align with the pull request description and commit messages. Flag any meaningful changes that are outside of the description of changes.
- Is the code well-structured, easy to read, and easy to maintain?

## Final Output

- Output a summary of your findings, with the severity of each finding categorized by Critical, High, Medium, or Low.
- Call out what must be changed before merging and what is optional, such as coding preferences or small nits that don't impact functionality.
- Write this summary to `./pr_review_results.md` in the cloned repository directory

## Repository-Specific Considerations

When reviewing pull requests for specific repositories, consider adding custom guidelines here:

### Llama Stack (llamastack/llama-stack)

When reviewing PRs for the Llama Stack repository, consider:
- Architecture patterns specific to Llama Stack
- API design conventions and backward compatibility
- Testing requirements and coverage expectations
- Documentation standards
- Performance considerations for distributed systems
- Integration points between components
- Common pitfalls or anti-patterns in the codebase

### Other Repositories

Add repository-specific guidelines as needed by editing this section.
