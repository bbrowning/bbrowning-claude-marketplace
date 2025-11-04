# bbrowning-claude Marketplace

Personal Claude Code plugin marketplace containing curated skills and commands for development, code review, and best practices.

## About This Marketplace

This marketplace contains the **bbrowning-claude** plugin, a consolidated collection of:

### Development Skills
- **plugin-builder**: Comprehensive guide for creating Claude Code plugins
- **marketplace-builder**: Guide for creating and managing plugin marketplaces
- **skill-builder**: Guide for writing high-quality Claude Code skills
- **cross-repo-config**: Guide for organizing configuration across multiple repositories using three-tier architecture
- **version-control-config**: Guide for version controlling ~/.claude directory with proper .gitignore setup

### Code Review Skills
- **pr-review**: Structured pull request review with security analysis, backward compatibility checks, test coverage verification, and categorized findings

### Commands
- **/learn**: Capture learnings from sessions and save to appropriate configuration tier (global, plugin, or project-local)
- **/pr-review**: Review GitHub pull requests with automated analysis and actionable recommendations

## Quick Start

### Adding This Marketplace
```bash
/plugin marketplace add /path/to/bbrowning-claude-marketplace
```

### Installing the Plugin
```bash
# Install the bbrowning-claude plugin
/plugin install bbrowning-claude@bbrowning-marketplace

# Browse all available plugins interactively
/plugin
```

## Using the Plugin

Once installed, all skills and commands are available:

### Skills
Skills are automatically invoked by Claude Code when relevant to your task:
- Creating plugins? The `plugin-builder` skill provides guidance
- Creating marketplaces? The `marketplace-builder` skill helps
- Writing skills? The `skill-builder` skill offers best practices
- Managing configuration? The `cross-repo-config` skill shows the way
- Reviewing PRs? The `pr-review` skill structures the analysis

### Commands
Execute commands directly:
```bash
# Review a pull request
/pr-review <pr-number>

# Capture learnings from this session
/learn
```

## Managing the Plugin

```bash
# Enable/disable the plugin
/plugin enable bbrowning-claude@bbrowning-marketplace
/plugin disable bbrowning-claude@bbrowning-marketplace

# Uninstall the plugin
/plugin uninstall bbrowning-claude@bbrowning-marketplace
```

### Development Workflow
```bash
# After modifying the plugin, reload it:
/plugin uninstall bbrowning-claude@bbrowning-marketplace
/plugin install bbrowning-claude@bbrowning-marketplace

# Or restart Claude Code to reload all plugins
```

### Debugging
```bash
# View detailed plugin loading information
claude --debug
```

## Creating Plugins and Marketplaces

For detailed guidance on creating plugins, marketplaces, or skills, the bbrowning-claude plugin provides specialized skills:

- **Creating a plugin?** The `plugin-builder` skill provides comprehensive guidance
- **Creating a marketplace?** The `marketplace-builder` skill walks you through it
- **Writing a skill?** The `skill-builder` skill offers best practices and templates

These skills provide step-by-step guidance with progressive context reveal.

## Essential Quick Reference

### Minimum Plugin Structure
```
my-plugin/
└── .claude-plugin/
    └── plugin.json          # Only required file
```

### Minimum plugin.json
```json
{
  "name": "my-plugin",
  "version": "1.0.0"
}
```

### Minimum Marketplace Structure
```
my-marketplace/
└── .claude-plugin/
    └── marketplace.json     # Only required file
```

### Minimum marketplace.json
```json
{
  "name": "my-marketplace",
  "owner": {
    "name": "Your Name"
  },
  "plugins": []
}
```

## Key Principles

1. **Plugins**: Extend Claude Code with commands, agents, skills, hooks, or MCP servers
2. **Marketplace manifest**: Must be at `.claude-plugin/marketplace.json` (not root)
3. **Plugin manifest**: Must be at `.claude-plugin/plugin.json` (not root)
4. **Paths**: Always use relative paths starting with `./`
5. **Versioning**: Follow semantic versioning (MAJOR.MINOR.PATCH)

For everything else, use the skills included in the bbrowning-claude plugin.
