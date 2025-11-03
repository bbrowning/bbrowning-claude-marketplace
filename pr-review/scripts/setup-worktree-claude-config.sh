#!/usr/bin/env bash
#
# setup-worktree-claude-config.sh
#
# Sets up .claude configuration sharing for a git worktree.
# This script checks if .claude exists in the main worktree and, if it's not
# committed to git, creates a symlink to share configuration across worktrees.
#
# Usage: setup-worktree-claude-config.sh
# Must be run from within a git worktree directory.
#
# Exit codes:
#   0 - Success (symlink created or not needed)
#   1 - Error (not in a git repo, etc.)

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

# Ensure we're in a git repository
if ! git rev-parse --git-dir >/dev/null 2>&1; then
    error "Not in a git repository"
    exit 1
fi

# Get the current worktree path
CURRENT_WORKTREE=$(git rev-parse --show-toplevel 2>/dev/null)

if [ -z "$CURRENT_WORKTREE" ]; then
    error "Could not determine current worktree path"
    exit 1
fi

# Get the main worktree path (first entry in git worktree list)
MAIN_WORKTREE=$(git worktree list --porcelain | awk '/^worktree/ {print $2; exit}')

if [ -z "$MAIN_WORKTREE" ]; then
    error "Could not determine main worktree path"
    exit 1
fi

# Check if we're already in the main worktree
if [ "$CURRENT_WORKTREE" = "$MAIN_WORKTREE" ]; then
    info "Already in main worktree - no symlink needed"
    exit 0
fi

# Check if .claude directory exists in main worktree
if [ ! -d "$MAIN_WORKTREE/.claude" ]; then
    info "No .claude directory found in main worktree - skipping configuration sharing"
    exit 0
fi

# Check if .claude is committed to git (in main worktree)
if (cd "$MAIN_WORKTREE" && git ls-files --error-unmatch .claude >/dev/null 2>&1); then
    success ".claude is committed to git - configuration will be shared automatically via git"
    exit 0
fi

# .claude exists but not committed (OSS project) - create symlink
info ".claude directory found in main worktree but not committed to git"
info "Creating symlink to share configuration across worktrees..."

# Remove existing .claude if present
if [ -e ".claude" ]; then
    if [ -L ".claude" ]; then
        info "Removing existing .claude symlink"
    else
        info "Removing existing .claude directory/file"
    fi
    rm -rf .claude
fi

# Create symlink
if ln -s "$MAIN_WORKTREE/.claude" .claude; then
    success "Created symlink: .claude -> $MAIN_WORKTREE/.claude"
else
    error "Failed to create symlink"
    exit 1
fi

# Add to git exclude to prevent accidental commits
EXCLUDE_FILE=".git/info/exclude"
if [ -f "$EXCLUDE_FILE" ]; then
    # Check if .claude is already in exclude file
    if grep -q "^\.claude$" "$EXCLUDE_FILE" 2>/dev/null; then
        info ".claude already in $EXCLUDE_FILE"
    else
        echo ".claude" >> "$EXCLUDE_FILE"
        success "Added .claude to $EXCLUDE_FILE"
    fi
else
    # Create exclude file if it doesn't exist
    mkdir -p "$(dirname "$EXCLUDE_FILE")"
    echo ".claude" > "$EXCLUDE_FILE"
    success "Created $EXCLUDE_FILE with .claude entry"
fi

success "Configuration sharing setup complete!"
