# Claude Code Plugin Marketplace

This marketplace contains the **bbrowning-claude** plugin - a curated collection of skills and commands for development, code review, and best practices.

## Available Skills

When working with this codebase, use these skills for guidance:

### Development & Documentation
- **plugin-builder**: Guide for creating Claude Code plugins
- **marketplace-builder**: Guide for creating and managing plugin marketplaces
- **skill-builder**: Guide for writing high-quality Claude Code skills
- **cross-repo-config**: Guide for organizing configuration across multiple repositories
- **version-control-config**: Guide for version controlling ~/.claude directory

### Code Review
- **pr-review**: Structured pull request review with security analysis and actionable recommendations

## Key Technical Details

- **Marketplace manifest**: Must be at `.claude-plugin/marketplace.json` (not root)
- **Plugin manifest**: Must be at `.claude-plugin/plugin.json` (not root)
- **Paths**: Always use relative paths starting with `./`
- **Versioning**: Follow semantic versioning (MAJOR.MINOR.PATCH)

For user-facing documentation, see README.md.
