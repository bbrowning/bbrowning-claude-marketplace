# Plugin Directory Structure

Complete reference for organizing Claude Code plugin directories and files.

## Complete Structure Example

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # REQUIRED: Plugin manifest
├── commands/                 # Optional: Custom slash commands
│   ├── command-one.md
│   └── command-two.md
├── agents/                   # Optional: Custom agents
│   ├── agent-one.md
│   └── agent-two.md
├── skills/                   # Optional: Agent skills
│   ├── skill-one/
│   │   ├── SKILL.md
│   │   ├── reference/
│   │   │   └── details.md
│   │   └── templates/
│   │       └── template.md
│   └── skill-two/
│       └── SKILL.md
├── hooks/                    # Optional: Event handlers
│   └── hooks.json
├── .mcp.json                 # Optional: MCP server config
├── scripts/                  # Optional: Helper scripts
│   └── setup.sh
└── README.md                 # Optional: Documentation
```

## Required Files

### Plugin Manifest (.claude-plugin/plugin.json)

This is the ONLY required file. Every plugin must have this.

**Minimal example:**
```json
{
  "name": "my-plugin",
  "version": "1.0.0"
}
```

**Complete example:**
```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Brief description of plugin purpose",
  "author": {
    "name": "Your Name",
    "email": "email@example.com"
  },
  "homepage": "https://docs.example.com",
  "repository": "https://github.com/username/repo",
  "license": "MIT",
  "keywords": ["tag1", "tag2", "tag3"],
  "commands": ["./commands"],
  "agents": ["./agents"],
  "skills": ["./skills"],
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

### Field Definitions

**Required fields:**
- `name` (string): Unique plugin identifier in kebab-case
- `version` (string): Semantic version (MAJOR.MINOR.PATCH)

**Optional metadata:**
- `description` (string): Brief plugin purpose for discoverability
- `author` (object): Author information
  - `name` (string, required): Author's name
  - `email` (string, optional): Author's email
- `homepage` (string): URL to documentation
- `repository` (string): URL to source code
- `license` (string): Open source license identifier (e.g., "MIT", "Apache-2.0")
- `keywords` (array of strings): Tags for marketplace discovery

**Component paths:**
- `commands` (string or array): Path(s) to command directories
- `agents` (string or array): Path(s) to agent directories
- `skills` (string or array): Path(s) to skill directories
- `hooks` (string): Path to hooks.json file
- `mcpServers` (string): Path to .mcp.json file

## Path Resolution

### Path Rules

1. **Must be relative** to plugin root
2. **Should start with** `./`
3. **Can use variable** `${CLAUDE_PLUGIN_ROOT}` for flexibility
4. **Can be arrays** for multiple component directories

### Path Examples

**Single directory:**
```json
{
  "skills": "./skills"
}
```

**Multiple directories:**
```json
{
  "skills": ["./skills", "./shared-skills"]
}
```

**With variable (advanced):**
```json
{
  "skills": "${CLAUDE_PLUGIN_ROOT}/skills"
}
```

**File reference:**
```json
{
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

## Component Directories

### Commands Directory

Contains custom slash command definitions.

**Structure:**
```
commands/
├── my-command.md
├── another-command.md
└── nested/
    └── sub-command.md
```

**File format:**
Each command is a Markdown file with frontmatter:

```markdown
---
name: my-command
description: Command description
---

Command prompt content here.
```

**Usage:** Users invoke with `/my-command`

### Agents Directory

Contains custom agent definitions.

**Structure:**
```
agents/
├── my-agent.md
└── specialized-agent.md
```

**File format:**
Markdown files describing agent capabilities and behavior.

### Skills Directory

Contains agent skills (most common component type).

**Structure:**
```
skills/
├── skill-one/
│   ├── SKILL.md           # Required
│   ├── reference/         # Optional: detailed docs
│   │   └── details.md
│   └── templates/         # Optional: templates
│       └── output.json
└── skill-two/
    └── SKILL.md           # Minimal skill
```

**Requirements:**
- Each skill is a directory
- Must contain `SKILL.md` with YAML frontmatter
- Can include supporting files (reference docs, templates, scripts)

### Hooks Directory

Contains event handler configuration.

**Structure:**
```
hooks/
└── hooks.json
```

**hooks.json format:**
```json
{
  "hooks": [
    {
      "event": "PreToolUse",
      "command": "./scripts/pre-tool.sh"
    },
    {
      "event": "PostToolUse",
      "command": "./scripts/post-tool.sh"
    },
    {
      "event": "UserPromptSubmit",
      "command": "./scripts/on-submit.sh"
    }
  ]
}
```

**Supported events:**
- `PreToolUse`: Before tool execution
- `PostToolUse`: After tool execution
- `UserPromptSubmit`: When user submits prompt

### MCP Servers Configuration

Model Context Protocol server integration.

**File location:** `.mcp.json` in plugin root

**Format:**
```json
{
  "mcpServers": {
    "server-name": {
      "command": "node",
      "args": ["./path/to/server.js"],
      "env": {
        "API_KEY": "value"
      }
    }
  }
}
```

## Common Plugin Patterns

### Pattern 1: Skills-Only Plugin (Most Common)

Simplest and most common plugin pattern.

```
my-skills-plugin/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    ├── skill-one/
    │   └── SKILL.md
    └── skill-two/
        └── SKILL.md
```

**plugin.json:**
```json
{
  "name": "my-skills-plugin",
  "version": "1.0.0",
  "description": "Collection of helpful skills",
  "skills": ["./skills"]
}
```

**Use when:** You want to share reusable capabilities that agents can invoke.

### Pattern 2: Commands-Only Plugin

For user-invoked custom commands.

```
my-commands-plugin/
├── .claude-plugin/
│   └── plugin.json
└── commands/
    ├── deploy.md
    └── test.md
```

**plugin.json:**
```json
{
  "name": "my-commands-plugin",
  "version": "1.0.0",
  "description": "Custom deployment and testing commands",
  "commands": ["./commands"]
}
```

**Use when:** You want custom slash commands for specific workflows.

### Pattern 3: Agent-Focused Plugin

For specialized agent behaviors.

```
my-agent-plugin/
├── .claude-plugin/
│   └── plugin.json
└── agents/
    └── code-reviewer.md
```

**plugin.json:**
```json
{
  "name": "my-agent-plugin",
  "version": "1.0.0",
  "description": "Specialized code review agent",
  "agents": ["./agents"]
}
```

**Use when:** You need specialized agent behaviors.

### Pattern 4: MCP Integration Plugin

For external tool integrations.

```
mcp-integration-plugin/
├── .claude-plugin/
│   └── plugin.json
├── .mcp.json
└── servers/
    └── custom-server.js
```

**plugin.json:**
```json
{
  "name": "mcp-integration",
  "version": "1.0.0",
  "description": "Custom MCP server integration",
  "mcpServers": "./.mcp.json"
}
```

**Use when:** Integrating external data sources or tools.

### Pattern 5: Workflow Plugin (Multi-Component)

Combines multiple component types for complete workflow.

```
workflow-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── start-workflow.md
├── skills/
│   ├── process-data/
│   │   └── SKILL.md
│   └── generate-report/
│       └── SKILL.md
└── hooks/
    └── hooks.json
```

**plugin.json:**
```json
{
  "name": "workflow-plugin",
  "version": "1.0.0",
  "description": "Complete data processing workflow",
  "commands": ["./commands"],
  "skills": ["./skills"],
  "hooks": "./hooks/hooks.json"
}
```

**Use when:** Building complete workflows with commands, skills, and hooks.

### Pattern 6: Enterprise Plugin (Full-Featured)

Comprehensive plugin with all component types.

```
enterprise-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── deploy.md
│   └── rollback.md
├── agents/
│   └── security-scanner.md
├── skills/
│   ├── compliance-check/
│   │   └── SKILL.md
│   └── audit-log/
│       └── SKILL.md
├── hooks/
│   └── hooks.json
├── .mcp.json
├── scripts/
│   ├── pre-deploy.sh
│   └── post-deploy.sh
└── README.md
```

**plugin.json:**
```json
{
  "name": "enterprise-plugin",
  "version": "2.1.0",
  "description": "Enterprise deployment and compliance toolkit",
  "author": {
    "name": "Enterprise Team",
    "email": "team@enterprise.com"
  },
  "homepage": "https://docs.enterprise.com/plugin",
  "repository": "https://github.com/enterprise/plugin",
  "license": "MIT",
  "keywords": ["enterprise", "deployment", "compliance", "security"],
  "commands": ["./commands"],
  "agents": ["./agents"],
  "skills": ["./skills"],
  "hooks": "./hooks/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

**Use when:** Building comprehensive tooling for enterprise workflows.

## Multi-Directory Support

You can specify multiple directories for component types.

**Example:**
```json
{
  "name": "multi-source-plugin",
  "version": "1.0.0",
  "skills": ["./skills", "./shared-skills", "./experimental-skills"],
  "commands": ["./commands", "./admin-commands"]
}
```

**Directory structure:**
```
multi-source-plugin/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── core-skill/
│       └── SKILL.md
├── shared-skills/
│   └── shared-skill/
│       └── SKILL.md
├── experimental-skills/
│   └── experimental-skill/
│       └── SKILL.md
├── commands/
│   └── user-command.md
└── admin-commands/
    └── admin-command.md
```

**Use when:**
- Organizing components by category
- Separating stable from experimental features
- Sharing components across multiple plugins

## Supporting Files

### Scripts Directory

Optional directory for helper scripts.

```
scripts/
├── setup.sh
├── validate.py
└── hooks/
    ├── pre-tool.sh
    └── post-tool.sh
```

**Use for:**
- Installation scripts
- Validation scripts
- Hook implementations
- Utility scripts

### Documentation Files

Optional documentation in plugin root.

```
my-plugin/
├── .claude-plugin/
├── README.md          # Main documentation
├── CHANGELOG.md       # Version history
└── LICENSE            # License file
```

**Recommended:**
- README.md: Installation, usage, examples
- CHANGELOG.md: Version history and changes
- LICENSE: License text for open source plugins

## Best Practices

### Organization
- Group related components together
- Use clear, descriptive directory names
- Keep supporting files in logical locations
- Don't mix component types in same directory

### File Naming
- Use kebab-case for file names
- Be descriptive: `generate-report.md` not `gen.md`
- Match component names to file names when possible

### Component Placement
- Commands: User-facing, workflow-oriented
- Skills: Agent-invoked, reusable capabilities
- Agents: Specialized behaviors
- Hooks: Event-driven actions
- MCP: External integrations

### Path Management
- Always use relative paths
- Start paths with `./`
- Test all paths after creating manifest
- Verify paths work after installation

### Documentation
- Include README.md for complex plugins
- Document each component's purpose
- Provide usage examples
- List any requirements or dependencies

## Troubleshooting

### Plugin Not Found
**Symptom:** Plugin doesn't appear after installation
**Check:**
- `.claude-plugin/plugin.json` exists
- JSON is valid (use linter)
- Plugin directory is in correct location

### Components Not Loaded
**Symptom:** Commands/skills don't appear after install
**Check:**
- Paths in plugin.json are relative and correct
- Paths start with `./`
- Component files have correct format (frontmatter, etc.)
- Use `claude --debug` to see loading details

### Invalid Manifest
**Symptom:** Error when installing plugin
**Check:**
- Required fields present (name, version)
- Version follows semantic versioning (x.y.z)
- JSON syntax is valid
- Paths exist and are relative

### Path Resolution Issues
**Symptom:** Components not found
**Check:**
- Paths are relative, not absolute
- Paths start with `./`
- Directories/files exist at specified paths
- No typos in path strings

## Validation Checklist

Before sharing your plugin:

- [ ] `.claude-plugin/plugin.json` exists and is valid JSON
- [ ] Required fields present: `name`, `version`
- [ ] Version follows semantic versioning (x.y.z)
- [ ] All paths are relative and start with `./`
- [ ] All referenced paths exist
- [ ] Component files have correct format
- [ ] Plugin installs without errors
- [ ] Components appear and work correctly
- [ ] Tested with `claude --debug`
- [ ] Documentation is clear and complete

## Summary

**Key Takeaways:**
1. Only `.claude-plugin/plugin.json` is required
2. All other components are optional
3. Use relative paths starting with `./`
4. Choose patterns that match your needs
5. Start simple, add complexity as needed
6. Test thoroughly before sharing
