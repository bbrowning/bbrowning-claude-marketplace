---
name: Reviewing Pull Requests
description: Use when user mentions reviewing PRs, provides GitHub PR URLs/numbers, or discusses code review. Provides structured analysis of code quality, backward compatibility, security issues, test coverage, and unaddressed comments with categorized findings (Critical/High/Medium/Low). Creates isolated git worktree for safe review, ensures comprehensive security analysis, and generates actionable recommendations. Invoke before analyzing any pull request changes.
allowed-tools: Read, Grep, Glob, Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr checks:*), Bash(gh pr checkout:*), Bash(git worktree:*), Bash(cd:*), Bash(pwd:*)
---

# Pull Request Review Workflow

This skill guides comprehensive PR reviews using the GitHub CLI and local code analysis.

## 0. Parse PR Reference (Skip if already in worktree)

**If the user provides a PR reference** (URL, org/repo#number, etc.), parse it to extract:
- GitHub organization
- Repository name
- PR number

**Supported formats:**
- `<github_org>/<github_repo>/pull/<pull_request_number>`
- `<github_org>/<github_repo>#<pull_request_number>`
- Full github.com URL pointing to a specific pull request

**Confirm with the user** before proceeding:
```
PR to Review: <github_org>/<github_repo>#<pr_number>

I'll create an isolated git worktree for this review. Proceed?
```

**If already in a worktree** (user mentions "already in worktree" or "skip to step 3"), skip directly to step 3 (Gather PR Context).

## 1. Creating a Git Worktree for the PR

**Determine the repository location:**

First, check if the repository exists locally on this machine:
- Look in common source code locations (~/src/, ~/repos/, etc.)
- Use the user's machine-specific path configuration if available
- If the repository doesn't exist locally, ask the user if they want to clone it first or provide the path

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

After creating the worktree, set up `.claude/` configuration sharing if needed:

```bash
cd ../<repo_name>-pr-<pr_number>

# Check if .claude already exists (from git or previous setup)
if [ ! -e .claude ]; then
  # Get main worktree path
  MAIN_WORKTREE=$(git worktree list --porcelain | awk '/^worktree/ {print $2; exit}')

  # If .claude exists in main worktree, create symlink
  if [ -d "$MAIN_WORKTREE/.claude" ]; then
    ln -s "$MAIN_WORKTREE/.claude" .claude
    echo "Created .claude symlink to share configuration"
  fi
fi
```

**Why symlink .claude?**
- Ensures project-local configuration (review criteria, skills, commands) is available in the PR worktree
- Maintains consistency across all worktrees for the same repository
- If `.claude/` is committed to git, it's already available; if not, the symlink shares it

**CRITICAL SAFETY**: Never run code from the PR. It may contain untrusted code. Only read and analyze files.

## 2. Launch Claude Code in the Worktree

After creating the worktree, **stop here** and provide the user with instructions to launch Claude Code in the new worktree.

**CRITICAL**: Include ALL relevant skills that were loaded in the current session in the handoff prompt. This ensures the new Claude Code session has the full context needed for the review.

### Determining Relevant Skills

Before providing handoff instructions, identify which skills were loaded for this review:

1. **pr-review skill**: Always relevant (this skill)
2. **Repository-specific skills**: Any skills matching the repository being reviewed (e.g., llama-stack, vllm)
3. **Domain-specific skills**: Any skills relevant to the PR content (e.g., auth-security for authentication/authorization code)

**Example**: For a llama-stack PR, both `pr-review` and `llama-stack` skills would be relevant.

### Handoff Instruction Template

```
I've created a git worktree for PR #<pr_number> (<github_org>/<github_repo>) at: <worktree_path>

To continue the review in an isolated environment:

1. Open a new terminal
2. Navigate to the worktree: cd <worktree_path>
3. Launch Claude Code: claude
4. In the new Claude Code session, provide this prompt:

   > Review PR #<pr_number> for <github_org>/<github_repo>. I'm already in a git worktree with the PR checked out. Use [list ALL relevant skills: pr-review, <repo-specific>, <domain-specific>] and skip directly to step 3 (Gather PR Context) since the worktree is already set up.

This ensures we're reviewing the correct code in isolation with all necessary context.
```

**Why this matters:**
- Repository-specific skills contain critical domain knowledge (e.g., llama-stack's recordings/ handling, distributed systems concerns)
- Domain-specific skills provide specialized security or technical guidance
- Without all skills, the review loses important context and may miss critical issues

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
   - **Authentication/Authorization**: For PRs involving JWT tokens, MCP servers, or other authentication/authorization code, invoke the `auth-security` skill for comprehensive security guidance on JWT validation, token exchange, OAuth 2.1 compliance, and MCP authorization patterns

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

## Repository-Specific Skills

**IMPORTANT**: After gathering PR context and determining which repository is being reviewed, check for repository-specific skills that provide specialized review guidance.

### Discovering Repository-Specific Skills

1. **Identify the repository** from the PR context (e.g., `llamastack/llama-stack`, `vllm-project/vllm`)
2. **Search for matching skills** using common repository identifiers:
   - Repository name (e.g., "llama-stack", "vllm")
   - Organization name (e.g., "llamastack")
   - Project name variations
3. **Invoke repository-specific skill** if found, using the Skill tool
4. **Apply specialized guidance** from the skill throughout your review

### Example: Reviewing a Llama Stack PR

```
1. Gather PR context → Determine repository is "llamastack/llama-stack"
2. Check for skills → Find "Reviewing Llama Stack Code" skill
3. Invoke skill → Use Skill tool with "bbrowning-claude:llama-stack"
4. Apply guidance → Use Llama Stack-specific patterns in review
```

### Benefits of Repository-Specific Skills

- **Specialized knowledge**: Project-specific architecture patterns and conventions
- **Critical gotchas**: Common mistakes specific to that codebase
- **Review focus**: What matters most for that particular project
- **Efficiency**: Pre-encoded knowledge from previous reviews

### When No Repository-Specific Skill Exists

If no specialized skill is found:
- Proceed with general code review criteria
- Consider creating a repository-specific skill if you identify recurring patterns
- Document project-specific observations for future reference

## Common Pitfalls to Avoid

- **Don't guess**: If you can't determine something from the code, note it as a question
- **Don't run code**: Security risk - only read and analyze
- **Don't be vague**: "This looks wrong" → "This function doesn't handle null inputs (see line 42)"
- **Don't forget context**: Read surrounding code to understand intent
- **Don't ignore tests**: Test quality matters as much as code quality

## Validation Checklist

Before completing the review, ensure:
- [ ] PR context gathered (description, comments, reviews)
- [ ] Repository identified and repository-specific skill invoked if available
- [ ] All changed files examined
- [ ] Unaddressed comments identified
- [ ] All review checklist areas covered
- [ ] Repository-specific patterns validated (if applicable)
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
4. **Add repository-specific guidance**: Create new repository-specific skills (e.g., `llama-stack`, `vllm`) rather than modifying this skill
5. **Security guidelines**: For authentication and authorization security, use the `auth-security` skill

### Creating Repository-Specific Skills

For repositories you frequently review, create dedicated skills:

1. Use the `skill-builder` skill for guidance on creating skills
2. Name the skill after the repository (e.g., "Reviewing Llama Stack Code")
3. Include in the description: repository name, common variations, and "PR review" or "code review"
4. Document architecture patterns, testing conventions, and critical gotchas
5. The pr-review skill will automatically discover and invoke it

The goal is a thorough, actionable review that helps maintain code quality while being respectful and constructive.
