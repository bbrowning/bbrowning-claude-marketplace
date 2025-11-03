#!/usr/bin/env bash
#
# cleanup-pr-worktree.sh
#
# Cleans up a git worktree created for PR review.
# Removes the worktree directory and deletes the associated local branch.
#
# Usage: cleanup-pr-worktree.sh <pr_number>
#   pr_number: The pull request number (e.g., 4041)
#
# This script must be run from within the main repository worktree.
#
# Exit codes:
#   0 - Success (worktree and branch removed)
#   1 - Error (invalid arguments, not in git repo, worktree not found, etc.)

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Print functions
error() {
    echo -e "${RED}Error: $*${NC}" >&2
}

success() {
    echo -e "${GREEN}$*${NC}"
}

info() {
    echo -e "${YELLOW}$*${NC}"
}

# Check arguments
if [ $# -ne 1 ]; then
    error "Usage: $0 <pr_number>"
    error "Example: $0 4041"
    exit 1
fi

PR_NUMBER="$1"

# Validate PR number is numeric
if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
    error "PR number must be numeric: $PR_NUMBER"
    exit 1
fi

# Ensure we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    error "Not in a git repository"
    exit 1
fi

# Get the repository name (last component of the path)
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")

# Construct expected branch and worktree names
BRANCH_NAME="${REPO_NAME}-pr-${PR_NUMBER}"

# Get the main worktree path
MAIN_WORKTREE=$(git worktree list --porcelain | awk '/^worktree/ {print $2; exit}')

if [ -z "$MAIN_WORKTREE" ]; then
    error "Could not determine main worktree path"
    exit 1
fi

# Check if we're in the main worktree
CURRENT_WORKTREE=$(git rev-parse --show-toplevel 2>/dev/null)
if [ "$CURRENT_WORKTREE" != "$MAIN_WORKTREE" ]; then
    error "This script must be run from the main repository worktree"
    error "Current: $CURRENT_WORKTREE"
    error "Main: $MAIN_WORKTREE"
    exit 1
fi

# Check if worktree exists
WORKTREE_PATH="${MAIN_WORKTREE}-pr-${PR_NUMBER}"
if ! git worktree list | grep -q "$WORKTREE_PATH"; then
    error "Worktree not found: $WORKTREE_PATH"
    info "Available worktrees:"
    git worktree list
    exit 1
fi

info "Found worktree: $WORKTREE_PATH"

# Remove the worktree (force flag handles modified/untracked files)
info "Removing worktree..."
if git worktree remove --force "$WORKTREE_PATH" 2>/dev/null; then
    success "Removed worktree: $WORKTREE_PATH"
else
    # Try with just the directory name if full path didn't work
    WORKTREE_DIR="${REPO_NAME}-pr-${PR_NUMBER}"
    if git worktree remove --force "$WORKTREE_DIR" 2>/dev/null; then
        success "Removed worktree: $WORKTREE_DIR"
    else
        error "Failed to remove worktree"
        exit 1
    fi
fi

# Delete the local branch if it exists
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    info "Deleting branch: $BRANCH_NAME"
    if git branch -D "$BRANCH_NAME" >/dev/null 2>&1; then
        success "Deleted branch: $BRANCH_NAME"
    else
        error "Failed to delete branch: $BRANCH_NAME"
        exit 1
    fi
else
    info "Branch $BRANCH_NAME doesn't exist (may have been already deleted)"
fi

success "Cleanup complete for PR #${PR_NUMBER}"
