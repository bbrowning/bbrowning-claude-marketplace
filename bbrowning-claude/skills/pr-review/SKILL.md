---
name: Reviewing Pull Requests
description: Use when user mentions reviewing PRs, provides GitHub PR URLs/numbers, or discusses code review. Provides structured analysis of code quality, backward compatibility, security issues, test coverage, and unaddressed comments with categorized findings (Critical/High/Medium/Low). Creates isolated git worktree for safe review, ensures comprehensive security analysis, and generates actionable recommendations. Invoke before analyzing any pull request changes.
allowed-tools: Read, Grep, Glob, Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr checks:*), Bash(gh pr checkout:*), Bash(git worktree:*), Bash(cd:*), Bash(pwd:*)
---

# Pull Request Review Workflow

This skill guides comprehensive PR reviews using the GitHub CLI and local code analysis.

## 1. Creating a Git Worktree for the PR

**Create a new worktree with the PR checked out:**

```bash
# Navigate to the repository (if not already there)
cd /path/to/<repo>

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

**Share .claude configuration across worktrees:**

After creating the worktree, set up `.claude/` configuration sharing:

```bash
cd ../<repo_name>-pr-<pr_number>

# Get main worktree path
MAIN_WORKTREE=$(git worktree list --porcelain | awk '/^worktree/ {print $2; exit}')

# If .claude exists in main worktree but is not committed to git, create symlink
if [ -d "$MAIN_WORKTREE/.claude" ] && ! (cd "$MAIN_WORKTREE" && git ls-files --error-unmatch .claude >/dev/null 2>&1); then
  echo "Creating .claude symlink to share configuration..."
  rm -rf .claude 2>/dev/null || true
  ln -s "$MAIN_WORKTREE/.claude" .claude
  echo ".claude" >> .git/info/exclude
  echo "Created symlink: .claude -> $MAIN_WORKTREE/.claude"
elif (cd "$MAIN_WORKTREE" && git ls-files --error-unmatch .claude >/dev/null 2>&1); then
  echo ".claude is committed to git - configuration shared automatically"
fi
```

This approach:
- Checks if `.claude/` directory exists in the main repository
- If `.claude/` is committed to git: Configuration is shared automatically via git
- If `.claude/` exists but not committed (OSS projects):
  - Creates a symlink from the worktree to the main worktree's `.claude/` directory
  - Adds `.claude` to `.git/info/exclude` to prevent accidental commits

**Why symlink .claude?**
- Ensures project-local configuration (review criteria, skills, commands) is available in the PR worktree
- Maintains consistency across all worktrees for the same repository
- Prevents configuration divergence between worktrees

**CRITICAL SAFETY**: Never run code from the PR. It may contain untrusted code. Only read and analyze files.

## 2. Launch Claude Code in the Worktree

After creating the worktree, **stop here** and provide the user with instructions to launch Claude Code in the new worktree:

```
I've created a git worktree for PR #<pr_number> at: <worktree_path>

To continue the review in an isolated environment:

1. Open a new terminal
2. Navigate to the worktree: cd <worktree_path>
3. Launch Claude Code: claude
4. In the new Claude Code session, invoke the pr-review skill to continue the review

This ensures we're reviewing the correct code in isolation.
```

**The remaining steps below are performed in the new Claude Code session within the worktree.**

**IMPORTANT**: Remember to clean up the worktree after completing the review (see section 9 below).

## 3. Gather PR Context

**Fetch PR details:**
```bash
gh pr view <pr_number> --json title,body,commits,comments,reviews,files
```

Extract and note:
- PR title and description
- Number of commits and commit messages
- Files changed
- Existing comments and reviews
- Any unaddressed review comments

**Identify unaddressed comments:**
Look for review comments that:
- Have no replies from the PR author
- Requested changes that weren't made
- Raised concerns not acknowledged
- Are marked as unresolved

Flag these prominently in your review.

## 4. Analyze Code Changes

**Get the diff:**
```bash
gh pr diff <pr_number> > pr_changes.diff
```

For large PRs (>500 lines changed), break the review into logical sections (e.g., by file, by functionality).

Reference the local pr_changes.diff as you need to find changes in the PR over repeated calls to `gh pr diff`. And remember that you are already in a directory that has the PR cloned and checked out, so you can also look at local files.

**Review each changed file systematically:**

Use Read, Grep, and Glob tools to examine:
- Changed files and surrounding context
- Related files that might be affected
- Test files for the changed code
- Documentation for updated features

**Apply review checklist:**

For comprehensive criteria, see `reference/review-checklist.md`. Key areas:

1. **Code Quality**
   - Readability and maintainability
   - Follows project conventions
   - Appropriate abstraction levels
   - Error handling

2. **Correctness**
   - Logic is sound
   - Edge cases handled
   - No obvious bugs
   - Changes align with PR description

3. **Testing**
   - Tests included for new functionality
   - Tests cover edge cases
   - Existing tests still pass
   - Test quality is adequate

4. **Security**
   - No security vulnerabilities
   - Input validation present
   - No exposed secrets or credentials
   - Safe handling of user data
   - **CRITICAL**: Check for `pull_request_target` + checkout of untrusted code pattern in workflows
   - CI/CD workflows don't expose secrets or OIDC tokens to untrusted code
   - **Authentication/Authorization**: For PRs involving JWT tokens or MCP servers, see:
     - `reference/jwt-security.md` for JWT implementation security
     - `reference/mcp-authorization.md` for MCP OAuth 2.1 compliance

5. **Performance**
   - No obvious performance issues
   - Efficient algorithms
   - No unnecessary operations
   - Database queries optimized

6. **Backward Compatibility**
   - Public API changes are compatible
   - Database migrations are safe
   - Configuration changes documented
   - Deprecation handled properly

7. **Documentation**
   - Code comments where needed
   - API docs updated
   - README updated if needed
   - Breaking changes documented

## 5. Cross-Cutting Concerns

**Check alignment with PR description:**
- All described changes are present
- No undescribed significant changes
- Commit messages match changes

**Verify comments match code:**
- Inline comments are accurate
- No outdated comments from refactoring
- Documentation reflects actual behavior

**Assess scope creep:**
- Changes are focused on stated goal
- No unrelated refactoring
- Separate concerns properly

## 6. Categorize Findings

Use the severity guide in `reference/severity-guide.md` to categorize each finding:

- **Critical**: Must fix before merge (security, data loss, breaking changes)
- **High**: Should fix before merge (bugs, significant issues)
- **Medium**: Should address but not blocking (code quality, minor issues)
- **Low**: Optional improvements (style, suggestions)

Be specific about:
- What the issue is
- Why it matters
- How to fix it (or suggest approaches)
- File and line references

## 7. Generate Review Report

Write findings to `./pr_review_results.md` using the template in `templates/review-report.md`.

**Report structure:**
1. Executive summary
2. Unaddressed comments from others
3. Findings by severity
4. Positive observations
5. Final recommendation (approve/request changes/needs discussion)

**Key principles:**
- Be constructive and specific
- Include code references (file:line)
- Distinguish blockers from suggestions
- Highlight what's done well
- Provide actionable guidance

## 8. Present to User

After writing `./pr_review_results.md`, present:
1. Summary of key findings
2. Number of issues by severity
3. Critical blockers if any
4. Any unaddressed comments from others
5. Overall recommendation

Ask if the user wants:
- Details on any specific finding
- To focus on particular aspects
- To leave review comments on GitHub

## 9. Clean Up the Worktree

**After completing the PR review**, return to the original terminal session where you created the worktree and clean up:

### Automated Cleanup (Recommended)

Clean up the worktree and branch:

```bash
# Return to the main repository (if not already there)
cd /path/to/<repo>

# Remove the worktree (--force handles modified/untracked files)
git worktree remove --force <repo_name>-pr-<pr_number>

# Delete the local branch
git branch -D <repo_name>-pr-<pr_number>
```

**Example for vLLM PR #12345:**
```bash
cd ~/src/vllm
git worktree remove --force vllm-pr-12345
git branch -D vllm-pr-12345
```

This will:
- Remove the worktree directory (including any modified/untracked files)
- Delete the local branch
- Clean up git metadata

### Manual Cleanup

Alternative approach with verification step:

```bash
# Navigate to the main repository
cd /path/to/<repo>

# List worktrees to verify the one to remove
git worktree list

# Remove the worktree (--force handles modified/untracked files)
git worktree remove --force <repo_name>-pr-<pr_number>

# Delete the local branch
git branch -D <repo_name>-pr-<pr_number>
```

**Why cleanup matters:**
- Prevents orphaned worktrees consuming disk space
- Avoids confusion about which worktree to use
- Keeps the repository clean and organized

**Safety note:** The worktree removal is safe because:
- PR review results should have been saved to the main worktree or submitted to GitHub
- The worktree was for review only (no development work)
- The PR branch still exists on GitHub

## Repository-Specific Customization

This skill supports repository-specific review criteria. When reviewing PRs, check if custom guidelines exist for the repository.

### Adding Custom Guidelines

To add repository-specific rules:

1. Identify the repository pattern (org/repo)
2. Add a section below with specific criteria
3. Include architecture patterns, conventions, or requirements

### Example: Custom Repository Rules

**For llamastack/llama-stack:**
- Verify API changes maintain backward compatibility
- Check distributed system considerations (race conditions, eventual consistency)
- Ensure proper error propagation across component boundaries
- Validate integration points follow established patterns
- Confirm performance impact is acceptable for distributed workloads

**For your-org/your-repo:**
- Add your specific criteria here
- Architecture patterns to verify
- Testing requirements
- Documentation standards
- Performance benchmarks

## Common Pitfalls to Avoid

- **Don't guess**: If you can't determine something from the code, note it as a question
- **Don't run code**: Security risk - only read and analyze
- **Don't be vague**: "This looks wrong" → "This function doesn't handle null inputs (see line 42)"
- **Don't forget context**: Read surrounding code to understand intent
- **Don't ignore tests**: Test quality matters as much as code quality

## Validation Checklist

Before completing the review, ensure:
- [ ] PR context gathered (description, comments, reviews)
- [ ] All changed files examined
- [ ] Unaddressed comments identified
- [ ] All review checklist areas covered
- [ ] Findings categorized by severity
- [ ] Review report written to `./pr_review_results.md`
- [ ] Specific file:line references included
- [ ] Actionable recommendations provided
- [ ] Positive aspects noted
- [ ] Final recommendation clear
- [ ] User reminded to clean up worktree after review (section 9)

## Extending This Skill

This skill is designed to be customized:

1. **Add review criteria**: Edit `reference/review-checklist.md`
2. **Adjust severity definitions**: Modify `reference/severity-guide.md`
3. **Customize report format**: Update `templates/review-report.md`
4. **Add repository rules**: Add sections to this file or create repository-specific reference files
5. **Security guidelines**: Specialized security references available:
   - `reference/jwt-security.md` - JWT token handling and common vulnerabilities
   - `reference/mcp-authorization.md` - MCP server OAuth 2.1 implementation

The goal is a thorough, actionable review that helps maintain code quality while being respectful and constructive.
