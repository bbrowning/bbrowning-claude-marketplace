# bbrowning-claude Plugin

Personal curated collection of Claude Code skills and commands for development, code review, and best practices.

## What's Included

### Skills

#### Development & Documentation
- **plugin-builder**: Comprehensive guide for creating Claude Code plugins with manifest configuration, component organization, versioning, and best practices
- **marketplace-builder**: Expert guidance on marketplace structure, manifest configuration, plugin organization, versioning, and distribution workflows
- **skill-builder**: Guide for writing high-quality Claude Code skills with proper structure, descriptions, progressive context reveal, and best practices
- **cross-repo-config**: Guide for organizing Claude Code configuration across multiple repositories using the three-tier architecture (global, plugin, project-local)
- **version-control-config**: Guide for setting up git version control for ~/.claude directory with proper .gitignore configuration

#### Code Review
- **pr-review**: Structured pull request review with code quality analysis, backward compatibility checks, security verification, test coverage assessment, and categorized findings (Critical/High/Medium/Low)

### Commands

- **/learn**: Review conversation history, identify key learnings, and save them to the appropriate configuration tier (global `~/.claude/CLAUDE.md`, plugin skill, or project-local `.claude/CLAUDE.md`)
- **/pr-review**: Review GitHub pull requests with automated analysis and actionable recommendations

## Installation

This plugin is distributed via the bbrowning-claude marketplace:

```bash
# Add the marketplace
/plugin marketplace add https://github.com/bbrowning/bbrowning-claude-marketplace

# Install this plugin
/plugin install bbrowning-claude@bbrowning-marketplace
```

## Usage

### Skills
Skills are automatically invoked by Claude Code based on your task and the skill descriptions. Just work naturally and the relevant skills will be applied when appropriate.

### Commands
Execute commands directly in Claude Code:

```bash
# Review a pull request
/pr-review <pr-number>

# Capture learnings from your session
/learn
```

## Version

Current version: 1.0.0

## License

Apache-2.0

## Author

Benjamin Browning
