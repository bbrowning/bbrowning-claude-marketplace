# Claude Code Plugin Marketplace

This is a personal Claude Code plugin marketplace for version control and sharing of custom plugins.

## About This Marketplace

This marketplace contains the **claude-builder** plugin with three specialized skills:
- **plugin-builder**: Comprehensive guide for creating Claude Code plugins
- **marketplace-builder**: Guide for creating and managing plugin marketplaces
- **skill-builder**: Guide for writing high-quality Claude Code skills

## Quick Command Reference

### Adding This Marketplace
```bash
/plugin marketplace add /path/to/bbrowning-claude-marketplace
```

### Installing Plugins
```bash
# Install the claude-builder plugin
/plugin install claude-builder@bbrowning-claude-marketplace

# Browse all available plugins interactively
/plugin
```

### Managing Installed Plugins
```bash
# Enable/disable plugins
/plugin enable plugin-name@marketplace-name
/plugin disable plugin-name@marketplace-name

# Uninstall a plugin
/plugin uninstall plugin-name@marketplace-name
```

### Development Workflow
```bash
# After modifying a plugin, reload it:
/plugin uninstall plugin-name@marketplace-name
/plugin install plugin-name@marketplace-name

# Or restart Claude Code to reload all plugins
```

### Debugging
```bash
# View detailed plugin loading information
claude --debug
```

## Creating Plugins and Marketplaces

For detailed guidance on creating plugins, marketplaces, or skills, use the appropriate skill from the claude-builder plugin:

- **Creating a plugin?** Use the `plugin-builder` skill
- **Creating a marketplace?** Use the `marketplace-builder` skill
- **Writing a skill?** Use the `skill-builder` skill

These skills provide comprehensive, step-by-step guidance without duplicating information.

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

For everything else, use the claude-builder skills.
