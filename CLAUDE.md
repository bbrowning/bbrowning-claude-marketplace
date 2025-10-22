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
  "author": "Your Name <email@example.com>",
  "homepage": "https://docs.example.com",
  "repository": "https://github.com/username/repo",
  "license": "MIT",
  "keywords": ["tag1", "tag2", "tag3"]
}
```

- `description`: Brief plugin purpose
- `author`: Contact information
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
5. **Create marketplace manifest** (if managing multiple plugins)
6. **Install and test** the plugin

### Installation Methods

- **Interactive menu**: Recommended for discovery
  ```bash
  claude install
  ```
- **Direct CLI**: For specific plugins
  ```bash
  claude install <plugin-name>
  ```
- **Repository-level configuration**: For team-wide plugins

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

## Distribution

### Marketplace Structure

A marketplace is a collection of plugins that can be shared:

```
my-marketplace/
├── plugin-one/
│   └── .claude-plugin/
│       └── plugin.json
├── plugin-two/
│   └── .claude-plugin/
│       └── plugin.json
└── marketplace.json (optional)
```

### Sharing Plugins

1. Version control with git
2. Share repository URL
3. Users can clone and install
4. Consider publishing to community marketplaces

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

1. Plugins extend Claude Code with shareable functionality
2. Plugin manifest (plugin.json) is the only required file
3. Components are optional - add only what you need
4. Use relative paths for all component references
5. Semantic versioning is essential for compatibility
6. Test thoroughly before sharing
7. Documentation improves plugin adoption
8. Debug mode is your friend for troubleshooting
