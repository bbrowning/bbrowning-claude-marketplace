# Claude Code Plugins Reference

This project is a personal Claude Code plugin marketplace for version control and sharing of custom plugins.

## What are Claude Code Plugins?

Plugins extend Claude Code with custom functionality that can be shared across projects and teams. They can add:
- Custom slash commands
- Custom agents
- Agent skills
- Event hooks
- MCP (Model Context Protocol) servers

Plugins are easily discoverable and installable through plugin marketplaces, supporting team-wide workflows.

## Plugin Directory Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata (REQUIRED)
├── commands/                 # Custom slash commands (optional)
│   └── my-command.md
├── agents/                   # Custom agents (optional)
│   └── my-agent.md
├── skills/                   # Agent skills (optional)
│   └── my-skill/
│       └── SKILL.md
├── hooks/                    # Event handlers (optional)
│   └── hooks.json
├── .mcp.json                 # MCP server configuration (optional)
└── scripts/                  # Helper scripts (optional)
```

## Plugin Manifest (plugin.json)

Location: `.claude-plugin/plugin.json`

### Required Fields

```json
{
  "name": "my-plugin-name",
  "version": "1.0.0"
}
```

- `name`: Unique identifier in kebab-case
- `version`: Semantic versioning (MAJOR.MINOR.PATCH)

### Optional Metadata Fields

```json
{
  "name": "my-plugin-name",
  "version": "1.0.0",
  "description": "Brief description of plugin purpose",
  "author": {
    "name": "Your Name",
    "email": "email@example.com"
  },
  "homepage": "https://docs.example.com",
  "repository": "https://github.com/username/repo",
  "license": "MIT",
  "keywords": ["tag1", "tag2", "tag3"]
}
```

- `description`: Brief plugin purpose
- `author`: Author information object with `name` (required) and `email` (optional)
- `homepage`: Documentation URL
- `repository`: Source code link
- `license`: Open source license identifier
- `keywords`: Discovery tags for marketplace

## Component Types

### 1. Commands

Custom slash commands that users can invoke.

- **Location**: `commands/` directory
- **Format**: Markdown files with frontmatter
- **Path Resolution**: Use relative paths starting with `./`

### 2. Agents

Custom agents with specialized capabilities.

- **Location**: `agents/` directory
- **Format**: Markdown files describing agent capabilities
- **Purpose**: Define specialized agent behaviors

### 3. Skills

Reusable capabilities that can be invoked by agents.

- **Location**: `skills/` directory
- **Format**: Directories containing `SKILL.md`
- **Purpose**: Modular functionality that agents can use

### 4. Hooks

Event handlers that trigger on specific events.

- **Location**: `hooks/hooks.json`
- **Supported Events**:
  - `PreToolUse`: Before a tool is used
  - `PostToolUse`: After a tool is used
  - `UserPromptSubmit`: When user submits a prompt
- **Purpose**: React to events in Claude Code workflow

### 5. MCP Servers

External tool integrations via Model Context Protocol.

- **Location**: `.mcp.json` in plugin root
- **Purpose**: Configure external tool integrations
- **Capabilities**: Extend Claude with external data sources and tools

## Configuration Principles

### Path Resolution

- All paths must be relative to plugin root
- Paths should start with `./`
- Use `${CLAUDE_PLUGIN_ROOT}` variable for flexible path resolution
- Supports multiple component paths via arrays

Example:
```json
{
  "commands": ["./commands"],
  "agents": ["./agents"]
}
```

## Creating a Plugin

### Quickstart Steps

1. **Create marketplace directory** (if not exists)
2. **Create plugin directory** with your plugin name
3. **Create plugin manifest** at `.claude-plugin/plugin.json`
4. **Add custom components** (commands, agents, skills, etc.)
5. **Create marketplace manifest** at `.claude-plugin/marketplace.json` (if managing multiple plugins)
6. **Add marketplace to Claude Code**
7. **Install and test** the plugin

### Installation Methods

#### Adding a Marketplace

First, add your marketplace to Claude Code:

```bash
# Add local marketplace
/plugin marketplace add /path/to/your/marketplace

# Or use interactive menu
/plugin
```

#### Installing Plugins

Once marketplace is added:

```bash
# Install specific plugin
/plugin install plugin-name@marketplace-name

# Or browse interactively
/plugin
```

Then select "Browse Plugins" to see all available plugins.

#### Direct Installation

You can also install directly without adding a marketplace:

```bash
/plugin install /path/to/plugin/directory
```

#### Managing Plugins

```bash
# Enable a plugin
/plugin enable plugin-name@marketplace-name

# Disable a plugin
/plugin disable plugin-name@marketplace-name

# Uninstall a plugin
/plugin uninstall plugin-name@marketplace-name
```

## Best Practices

### Organization

- Organize complex plugins by functionality
- Use clear, descriptive naming for components
- Keep related functionality together

### Documentation

- Add comprehensive descriptions in plugin.json
- Document each command, agent, and skill
- Include usage examples
- Provide clear parameter descriptions

### Versioning

- Use semantic versioning strictly
- Increment MAJOR for breaking changes
- Increment MINOR for new features
- Increment PATCH for bug fixes

### Testing

- Test each component individually
- Verify plugin loads correctly with `claude --debug`
- Test in clean environment before publishing
- Validate all paths are relative and correct

### Code Quality

- Follow consistent markdown formatting
- Use clear, concise language in prompts
- Test with various inputs and edge cases
- Consider error handling in hooks

## Debugging

Use debug mode to view plugin loading details:

```bash
claude --debug
```

This shows:
- Plugin loading status
- Manifest validity
- Command registration
- Agent registration
- Any errors or warnings

## Local Development Workflow

### Creating and Testing a Plugin

1. **Create plugin directory**:
   ```bash
   mkdir my-plugin
   mkdir my-plugin/.claude-plugin
   ```

2. **Create plugin.json**:
   ```json
   {
     "name": "my-plugin",
     "version": "1.0.0",
     "description": "My plugin description"
   }
   ```

3. **Add components** (skills, commands, etc.)

4. **Add to marketplace.json**:
   ```json
   {
     "plugins": [
       {
         "name": "my-plugin",
         "source": "./my-plugin",
         "description": "My plugin description"
       }
     ]
   }
   ```

5. **Add marketplace to Claude Code**:
   ```bash
   /plugin marketplace add /path/to/my-marketplace
   ```

6. **Install and test**:
   ```bash
   /plugin install my-plugin@my-marketplace
   ```

7. **Verify installation**:
   - Check `/help` for new commands
   - Skills should be automatically available
   - Use `/plugin` to see installed plugins

### Updating During Development

When you modify a plugin:

1. **Uninstall old version**:
   ```bash
   /plugin uninstall my-plugin@my-marketplace
   ```

2. **Reinstall updated version**:
   ```bash
   /plugin install my-plugin@my-marketplace
   ```

Or restart Claude Code to reload plugins.

### Testing Checklist

Before sharing your plugin:

- [ ] plugin.json has required fields (name, version)
- [ ] All paths in plugin.json are relative and start with `./`
- [ ] Skills have proper YAML frontmatter with name and description
- [ ] Commands have proper frontmatter
- [ ] Plugin installs without errors
- [ ] Components work as expected
- [ ] Tested with `claude --debug` for any warnings
- [ ] Documentation is clear and complete
- [ ] Version number follows semantic versioning

## Distribution and Marketplaces

For detailed information on creating and managing plugin marketplaces, see the **marketplace-builder** skill in the claude-builder plugin (`claude-builder/skills/marketplace-builder/SKILL.md`).

### Quick Reference: Marketplace Setup

A marketplace is a collection of plugins that can be shared. Basic structure:

```
my-marketplace/
├── .claude-plugin/
│   └── marketplace.json      # REQUIRED: Marketplace manifest
├── plugin-one/
│   └── .claude-plugin/
│       └── plugin.json
└── plugin-two/
    └── .claude-plugin/
        └── plugin.json
```

**Essential marketplace.json:**
```json
{
  "name": "my-marketplace",
  "owner": {
    "name": "Your Name"
  },
  "plugins": [
    {
      "name": "plugin-name",
      "source": "./plugin-directory",
      "description": "Brief description"
    }
  ]
}
```

**Plugin sources** can be local paths (`./plugin`), GitHub (`github:user/repo`), or Git URLs.

**Sharing workflow:**
1. Create marketplace with `.claude-plugin/marketplace.json`
2. Add plugins to the marketplace directory
3. Push to git repository
4. Users add: `/plugin marketplace add <url-or-path>`
5. Users install: `/plugin install plugin-name@marketplace-name`

For comprehensive guidance, invoke the `marketplace-builder` skill.

## Common Patterns

### Command Plugin

Minimal plugin with just commands:
```
my-command-plugin/
├── .claude-plugin/
│   └── plugin.json
└── commands/
    └── my-command.md
```

### Agent Plugin

Plugin focused on custom agents:
```
my-agent-plugin/
├── .claude-plugin/
│   └── plugin.json
└── agents/
    └── my-agent.md
```

### Full-Featured Plugin

Comprehensive plugin with all components:
```
enterprise-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
├── agents/
├── skills/
├── hooks/
│   └── hooks.json
├── .mcp.json
└── scripts/
```

## Key Takeaways

### Plugins
1. Plugins extend Claude Code with shareable functionality
2. Plugin manifest (`.claude-plugin/plugin.json`) is the only required file
3. Components are optional - add only what you need
4. Use relative paths starting with `./` for all component references
5. Semantic versioning is essential for compatibility

### Marketplaces
1. Marketplace manifest must be at `.claude-plugin/marketplace.json` (not root)
2. Each plugin entry needs `name`, `source`, and optionally `description`
3. Plugin sources can be local paths, GitHub repos, or Git URLs
4. Add marketplace once: `/plugin marketplace add <path>`
5. Install plugins: `/plugin install plugin-name@marketplace-name`
6. For detailed marketplace creation, use the `marketplace-builder` skill

### Development
1. Test plugins locally before sharing
2. Use `/plugin uninstall` and `/plugin install` to reload during development
3. Use `claude --debug` to troubleshoot loading issues
4. Verify with `/help` that commands are registered
5. Skills are automatically available when plugin is installed

### Best Practices
1. Document each plugin thoroughly
2. Follow semantic versioning strictly
3. Test in clean environment before publishing
4. Keep component paths relative and consistent
5. Use descriptive names and descriptions for discoverability
