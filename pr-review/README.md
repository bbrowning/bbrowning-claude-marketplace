# PR Review Plugin

Plugin for reviewing GitHub pull requests with repository-specific review workflows and best practices.

## Installation

### Via Marketplace

```bash
/plugin marketplace add https://github.com/bbrowning/bbrowning-claude-marketplace
/plugin install pr-review@bbrowning-marketplace
```

### Direct Installation

```bash
/plugin install https://github.com/bbrowning/bbrowning-claude-marketplace/pr-review
```

## Components

### Skills

- **Pull Request Review**: Comprehensive workflow for reviewing GitHub pull requests with support for repository-specific considerations

### Commands

- `/pr-review`: Review a pull request by providing a GitHub URL, org/repo#number format, or org/repo/pull/number format

## Usage

### Using the Command

```bash
# Review using full GitHub URL
/pr-review https://github.com/llamastack/llama-stack/pull/123

# Review using shorthand format
/pr-review llamastack/llama-stack#123

# Review using long format
/pr-review llamastack/llama-stack/pull/123
```

The command will:
1. Verify the pull request format
2. Confirm the PR to review with you
3. Invoke the Pull Request Review skill for detailed analysis

### Review Process

All PR reviews follow this standard workflow:

1. **Setup**
   - Define clone directory variable for consistent path handling
   - Verify CI status checks are green
   - Clone repository to dedicated directory

2. **Fetching Changes**
   - Update base branch using `git -C` (no directory changes)
   - Fetch PR diff for analysis
   - Security: Never run untrusted code from PRs

3. **Code Review**
   - Analyze PR diff using Read tool with absolute paths
   - Check comment accuracy
   - Flag backwards compatibility issues
   - Verify changes align with PR description
   - Assess code structure and maintainability
   - Split large changes into smaller review tasks

4. **Output**
   - Categorized findings (Critical, High, Medium, Low)
   - Clear distinction between required and optional changes
   - Summary written to `pr_review_results.md` in clone directory

## Requirements

- GitHub CLI (`gh`) tool must be installed and authenticated
- Git must be installed
- Sufficient disk space for cloning repositories

## Examples

### Example 1: Review a Pull Request

```
You: /pr-review llamastack/llama-stack#456

Claude: I'll review pull request #456 from the llamastack/llama-stack repository.
[Confirms PR details]
[Runs review workflow]
[Provides categorized findings]
```

### Example 2: Direct Skill Invocation

```
You: Can you review this PR: https://github.com/llamastack/llama-stack/pull/789

Claude: [Invokes pr-review skill]
[Performs comprehensive review]
```

## Customizing Repository-Specific Guidelines

To add review guidelines for specific repositories, edit the "Repository-Specific Considerations" section in `skills/pr-review/SKILL.md`:

1. Add a new subsection for your repository
2. Include architecture patterns, coding standards, testing requirements, etc.
3. Document common pitfalls or anti-patterns specific to that codebase

## License

Apache-2.0

## Author

Benjamin Browning
