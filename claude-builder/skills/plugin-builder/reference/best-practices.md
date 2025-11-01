# Plugin Development Best Practices

Comprehensive guide to creating high-quality, maintainable Claude Code plugins.

## Development Workflow

### Starting a New Plugin

**Step 1: Plan Your Plugin**
- Define clear purpose and scope
- Decide what components you need
- Choose appropriate plugin pattern
- Identify target users and use cases

**Step 2: Create Basic Structure**
```bash
mkdir my-plugin
mkdir my-plugin/.claude-plugin
```

**Step 3: Create Minimal Manifest**
Start with only required fields:
```json
{
  "name": "my-plugin",
  "version": "0.1.0"
}
```

**Step 4: Add First Component**
Start with one component type, test it, then add more.

**Step 5: Test Locally**
```bash
/plugin install /path/to/my-plugin
```

**Step 6: Iterate**
- Test each component
- Refine based on usage
- Add documentation
- Increment version

### Local Development Setup

**Option 1: Standalone Plugin Directory**
```bash
mkdir ~/my-plugins
cd ~/my-plugins
mkdir my-plugin
# Develop plugin
/plugin install ~/my-plugins/my-plugin
```

**Option 2: Personal Marketplace**
```bash
mkdir ~/my-marketplace
cd ~/my-marketplace
mkdir .claude-plugin
# Create marketplace.json
mkdir my-plugin
# Develop plugin
/plugin marketplace add ~/my-marketplace
/plugin install my-plugin@my-marketplace
```

**Recommended:** Use personal marketplace for managing multiple plugins.

### Iterative Development

1. **Make changes** to plugin files
2. **Update** the plugin using one of these methods:
   - **Easiest**: Run `/plugin` and select the plugin to update (Claude Code will reload it)
   - **Manual**: `/plugin uninstall my-plugin@marketplace-name` then `/plugin install my-plugin@marketplace-name`
3. **Restart Claude Code** if prompted to apply changes
4. **Test** the changes
5. **Repeat** until satisfied

**Tips:**
- The `/plugin` menu command is the easiest way to update during development
- Restart Claude Code to reload all plugins without manual uninstall/reinstall
- For marketplaces, changes are picked up when reinstalling from the marketplace

## Versioning

### Semantic Versioning

Follow semantic versioning strictly: `MAJOR.MINOR.PATCH`

**MAJOR version** (e.g., 1.0.0 → 2.0.0)
- Breaking changes to existing functionality
- Removing components
- Changing component behavior in incompatible ways
- Renaming plugin

**MINOR version** (e.g., 1.0.0 → 1.1.0)
- New features added
- New components added
- Backward-compatible enhancements
- New optional parameters

**PATCH version** (e.g., 1.0.0 → 1.0.1)
- Bug fixes
- Documentation updates
- Performance improvements
- No functionality changes

### Version Examples

**Breaking change (MAJOR):**
```json
// Version 1.0.0
{
  "name": "data-processor",
  "version": "1.0.0",
  "skills": ["./skills"]
}

// Version 2.0.0 - Removed commands, renamed skills directory
{
  "name": "data-processor",
  "version": "2.0.0",
  "skills": ["./processors"]
}
```

**New feature (MINOR):**
```json
// Version 1.0.0
{
  "name": "toolkit",
  "version": "1.0.0",
  "skills": ["./skills"]
}

// Version 1.1.0 - Added commands
{
  "name": "toolkit",
  "version": "1.1.0",
  "skills": ["./skills"],
  "commands": ["./commands"]
}
```

**Bug fix (PATCH):**
```json
// Version 1.0.0 - Has a bug in skill logic
{
  "name": "analyzer",
  "version": "1.0.0",
  "skills": ["./skills"]
}

// Version 1.0.1 - Fixed skill logic, no API changes
{
  "name": "analyzer",
  "version": "1.0.1",
  "skills": ["./skills"]
}
```

### Pre-release Versions

For development and testing:
```json
{
  "version": "0.1.0"  // Initial development
}
{
  "version": "0.9.0"  // Feature complete, testing
}
{
  "version": "1.0.0"  // Stable release
}
```

**Convention:**
- `0.x.x` = Under development, breaking changes allowed
- `1.0.0` = First stable release
- `1.x.x+` = Maintain backward compatibility

## Naming Conventions

### Plugin Names

**Format:** kebab-case

**Good names:**
- `git-workflow` - Descriptive, clear purpose
- `data-analyzer` - Indicates functionality
- `react-toolkit` - Shows what it helps with
- `security-scanner` - Obvious use case

**Bad names:**
- `helpers` - Too vague
- `utils` - Doesn't indicate purpose
- `my_plugin` - Wrong case (use kebab-case)
- `MyPlugin` - Wrong case (use kebab-case)
- `stuff` - Not descriptive

**Guidelines:**
- Use 2-3 words typically
- Be specific about functionality
- Avoid generic terms (utils, helpers, tools)
- Make it discoverable by name alone

### Component Names

**Commands:** Action verbs
- `deploy-app.md`
- `run-tests.md`
- `generate-report.md`

**Skills:** Gerund form (verb + -ing)
- `processing-data/`
- `analyzing-code/`
- `generating-reports/`

**Agents:** Role-based
- `code-reviewer.md`
- `security-auditor.md`
- `test-generator.md`

## Documentation

### Plugin Description

Write descriptions that:
- Clearly state purpose
- Include key terms for discoverability
- Are concise (1-2 sentences)
- Help users understand when to use it

**Good examples:**
```json
{
  "description": "Tools for processing and analyzing CSV and JSON data files with validation and transformation capabilities"
}
```

```json
{
  "description": "Git workflow automation including branch management, PR creation, and commit formatting"
}
```

**Bad examples:**
```json
{
  "description": "Helpful stuff"  // Too vague
}
```

```json
{
  "description": "This plugin provides various utilities and tools that can help you with different tasks in your workflow and make things easier when working with data and files"  // Too verbose
}
```

### Keywords

Choose keywords that:
- Describe functionality
- Match user search terms
- Are specific and relevant
- Help with discovery

**Example:**
```json
{
  "name": "react-toolkit",
  "keywords": ["react", "components", "typescript", "testing", "hooks"]
}
```

**Guidelines:**
- Include 3-7 keywords
- Use specific terms, not generic ones
- Think about how users would search
- Include technology names when relevant

### README Files

Include README.md for complex plugins:

**Essential sections:**
1. **Overview**: What does the plugin do?
2. **Installation**: How to install it
3. **Components**: What's included
4. **Usage**: How to use each component
5. **Examples**: Real-world usage examples
6. **Requirements**: Any dependencies or prerequisites
7. **License**: Licensing information

**CRITICAL: Keep README synchronized with plugin contents**

When adding or removing components (especially skills), ALWAYS update the README to reflect the changes:

- **Adding a skill**: Add it to the Components section with a brief description
- **Removing a skill**: Remove it from the Components section
- **Updating a skill**: Update its description if purpose changed
- **Adding commands/agents**: Document them in the appropriate sections

This is easy to forget but critical for discoverability. Users read the README to understand what the plugin offers.

**Example README structure:**
```markdown
# My Plugin

Brief description of what the plugin does.

## Installation

```bash
/plugin marketplace add <marketplace-url>
/plugin install my-plugin@marketplace-name
```

## Components

### Skills
- **Processing Data**: Handles CSV and JSON files
- **Validating Input**: Validates data against schemas

### Commands
- `/process-data`: Process data files
- `/validate-schema`: Validate data schema

## Usage Examples

### Processing CSV Files
...

## Requirements

- Node.js 18+
- Python 3.9+ (for validation scripts)

## License

MIT
```

## Testing

### Local Testing Workflow

**1. Installation Test**
```bash
# Install plugin
/plugin install /path/to/my-plugin

# Verify installation
/plugin

# Check for errors
claude --debug
```

**2. Component Testing**
```bash
# Verify commands appear
/help

# Test slash command
/my-command

# Test skill (use it in conversation)
# Skills are auto-discovered and invoked

# Verify agents registered
# Agents appear in specialized workflows
```

**3. Path Testing**
- Verify all component paths are relative
- Check paths start with `./`
- Ensure directories/files exist
- Test that components load correctly

**4. Manifest Validation**
```bash
# Validate JSON syntax
cat .claude-plugin/plugin.json | python -m json.tool

# Check required fields
# - name (present and kebab-case)
# - version (semantic versioning format)
```

**5. Clean Environment Testing**
Before sharing:
- Uninstall plugin
- Restart Claude Code
- Reinstall and test fresh

### Testing Checklist

Before releasing:
- [ ] Plugin installs without errors
- [ ] All components load correctly
- [ ] Commands appear in `/help`
- [ ] Skills are discoverable
- [ ] Agents work as expected
- [ ] Hooks trigger correctly
- [ ] No errors in `claude --debug`
- [ ] Documentation is accurate
- [ ] Version number is correct
- [ ] Tested in clean environment

## Code Quality

### Manifest Quality

**Required fields present:**
```json
{
  "name": "my-plugin",      // ✓ Required
  "version": "1.0.0"        // ✓ Required
}
```

**Metadata complete:**
```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "...",     // ✓ Recommended
  "author": {
    "name": "..."          // ✓ Recommended
  },
  "keywords": [...]         // ✓ Recommended
}
```

**Paths correct:**
```json
{
  "skills": ["./skills"],            // ✓ Relative path
  "commands": ["./commands"],        // ✓ Starts with ./
  "hooks": "./hooks/hooks.json"      // ✓ File reference
}
```

### Component Quality

**Skills:**
- Have clear SKILL.md with frontmatter
- Include name and description in frontmatter
- Keep SKILL.md under 500 lines
- Use reference files for details

**Commands:**
- Have frontmatter with name and description
- Clear, concise command prompts
- Include usage examples
- Document parameters

**Agents:**
- Clear agent descriptions
- Specific capabilities listed
- Tool restrictions if needed

**Hooks:**
- Valid hooks.json format
- Scripts exist at specified paths
- Proper permissions on scripts
- Error handling in scripts

### Error Handling

**In scripts:**
```bash
#!/bin/bash
set -e  # Exit on error

# Validate inputs
if [ -z "$1" ]; then
  echo "Error: Missing required parameter"
  exit 1
fi

# Main logic here
```

**In MCP servers:**
```javascript
try {
  // Server logic
} catch (error) {
  console.error('Error:', error.message);
  process.exit(1);
}
```

## Organization

### Single Responsibility

Each plugin should have ONE clear purpose.

**Good: Focused plugins**
- `git-workflow` - Git operations only
- `data-analyzer` - Data analysis only
- `react-toolkit` - React development only

**Bad: Catch-all plugins**
- `my-utils` - Vague, does everything
- `helpers` - No clear purpose
- `tools` - Too generic

### Component Organization

**By functionality:**
```
my-plugin/
├── skills/
│   ├── core-processing/     # Core functionality
│   ├── validation/          # Validation features
│   └── reporting/           # Reporting features
```

**By category:**
```
data-plugin/
├── skills/
│   ├── csv/                 # CSV-specific
│   ├── json/                # JSON-specific
│   └── xml/                 # XML-specific
```

**Flat structure (simple plugins):**
```
simple-plugin/
├── skills/
│   ├── skill-one/
│   └── skill-two/
```

### File Organization

**Supporting files:**
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── my-skill/
│       ├── SKILL.md
│       ├── reference/       # Detailed docs
│       ├── templates/       # Templates
│       └── scripts/         # Helper scripts
├── scripts/                 # Plugin-level scripts
├── docs/                    # Additional documentation
├── tests/                   # Test files (if applicable)
├── README.md
└── LICENSE
```

## Distribution

### Via Marketplace

**Best for:**
- Sharing with teams
- Publishing to community
- Managing multiple plugins
- Versioning and updates

**Steps:**
1. Create/add to marketplace
2. Add entry to marketplace.json
3. Share marketplace URL
4. Users add marketplace once
5. Users install/update plugins easily

**Example marketplace.json entry:**
```json
{
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./my-plugin",
      "description": "Plugin description"
    }
  ]
}
```

### Direct Installation

**Best for:**
- Quick testing
- Private plugins
- One-off sharing

**Methods:**
```bash
# Local path
/plugin install /path/to/plugin

# Git repository
/plugin install https://github.com/user/plugin

# GitHub shorthand
/plugin install github:user/plugin
```

## Common Pitfalls

### Absolute Paths
**Problem:**
```json
{
  "skills": "/Users/me/plugins/my-plugin/skills"  // ✗ Absolute
}
```

**Solution:**
```json
{
  "skills": ["./skills"]  // ✓ Relative
}
```

### Missing Plugin Directory
**Problem:**
```
my-plugin/
└── plugin.json  // ✗ Wrong location
```

**Solution:**
```
my-plugin/
└── .claude-plugin/
    └── plugin.json  // ✓ Correct location
```

### Invalid Version Format
**Problem:**
```json
{
  "version": "1"       // ✗ Invalid
}
{
  "version": "v1.0.0"  // ✗ Don't include 'v'
}
```

**Solution:**
```json
{
  "version": "1.0.0"   // ✓ Semantic versioning
}
```

### Overly Generic Names
**Problem:**
```json
{
  "name": "utils"      // ✗ Too vague
}
```

**Solution:**
```json
{
  "name": "data-utils" // ✓ More specific
}
```

### Missing Component Files
**Problem:**
```json
{
  "skills": ["./skills"]
}
// But no skills/ directory exists
```

**Solution:**
- Create directory before referencing
- Or remove reference from plugin.json

### Wrong Component Format
**Problem:**
```markdown
# My Skill

Content without frontmatter
```

**Solution:**
```markdown
---
name: My Skill
description: Skill description
---

# My Skill

Content
```

## Maintenance

### Keeping Plugins Updated

**Regular maintenance:**
- Fix bugs promptly
- Update documentation
- Respond to user feedback
- Test with new Claude Code versions

**Version updates:**
- Follow semantic versioning
- Document changes in CHANGELOG.md
- Test before releasing
- Update marketplace.json

### Deprecation Strategy

When removing features:

**1. Announce deprecation** (MINOR version)
```json
{
  "version": "1.5.0",
  "description": "Note: feature X deprecated, will be removed in 2.0.0"
}
```

**2. Remove feature** (MAJOR version)
```json
{
  "version": "2.0.0",
  "description": "Breaking: feature X removed"
}
```

**3. Document migration** in README

### Backward Compatibility

**Maintain in MINOR versions:**
- Keep existing component paths
- Don't remove components
- Don't break existing functionality
- Add, don't replace

**Break only in MAJOR versions:**
- Remove components
- Change component behavior
- Rename paths
- Require new dependencies

## Security Considerations

### Script Safety
- Validate all inputs
- Use proper permissions
- Avoid executing untrusted code
- Document security requirements

### Sensitive Data
- Don't hardcode credentials
- Use environment variables
- Document required secrets
- Provide examples, not real values

### MCP Server Security
- Validate external inputs
- Use HTTPS for remote connections
- Handle errors gracefully
- Log security-relevant events

## Summary

**Key Best Practices:**

1. **Plan before building** - Clear purpose, right components
2. **Start minimal** - plugin.json only, add as needed
3. **Use relative paths** - Always start with `./`
4. **Follow semantic versioning** - MAJOR.MINOR.PATCH strictly
5. **Test thoroughly** - Install, test, debug before sharing
6. **Document well** - Clear descriptions, examples, README
7. **Organize logically** - Single responsibility, clear structure
8. **Maintain actively** - Fix bugs, respond to feedback
9. **Version carefully** - Don't break backward compatibility
10. **Secure by default** - Validate inputs, protect secrets

Follow these practices to create high-quality, maintainable plugins that users will trust and enjoy using.
