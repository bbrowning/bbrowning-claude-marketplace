# Plugin Review Checklist

This comprehensive checklist helps ensure plugins follow best practices before being shared or added to marketplaces.

## Detailed Review Checklist

### 1. Manifest Validation
- [ ] `plugin.json` exists at `.claude-plugin/plugin.json` (not at root)
- [ ] `name` field is present and uses kebab-case
- [ ] `version` field follows semantic versioning (MAJOR.MINOR.PATCH)
- [ ] `description` is clear and concise (if present)
- [ ] `author.name` is specified (if author field exists)
- [ ] `keywords` are relevant for discoverability (if present)
- [ ] JSON syntax is valid (no trailing commas, proper quotes)

### 2. Path Validation
- [ ] All component paths are relative (start with `./`)
- [ ] No absolute paths in plugin.json
- [ ] Component paths reference directories/files that actually exist
- [ ] No use of `../` to reference files outside plugin directory
- [ ] Paths use forward slashes (not backslashes)
- [ ] `${CLAUDE_PLUGIN_ROOT}` variable is used correctly if present

### 3. Structure and Organization
- [ ] Plugin follows a clear structural pattern (single-purpose, skills-focused, or full-featured)
- [ ] Related functionality is grouped together
- [ ] Directory names are descriptive and consistent
- [ ] No unnecessary files or directories
- [ ] Plugin has single, cohesive purpose (not a catch-all)

### 4. Component Quality

**For Skills:**
- [ ] Each skill has `SKILL.md` in its directory
- [ ] Skill frontmatter includes `name` and `description`
- [ ] Skill descriptions clearly indicate when to use the skill
- [ ] Skills provide actionable guidance, not just information dumps
- [ ] Skills use progressive disclosure (start simple, reveal detail as needed)

**For Commands:**
- [ ] Command files use `.md` extension
- [ ] Command names are descriptive and follow naming conventions
- [ ] Commands include usage examples
- [ ] Commands document required vs optional parameters

**For Agents:**
- [ ] Agent files clearly describe agent purpose and capabilities
- [ ] Agent tools and behaviors are well-defined
- [ ] Agent use cases are documented

**For Hooks:**
- [ ] `hooks.json` has valid structure
- [ ] Hook events are valid (PreToolUse, PostToolUse, UserPromptSubmit)
- [ ] Hook scripts/commands are tested

**For MCP Servers:**
- [ ] `.mcp.json` configuration is valid
- [ ] Server dependencies are documented
- [ ] Installation instructions are provided

### 5. Documentation
- [ ] README.md exists and explains plugin purpose
- [ ] Installation instructions are clear
- [ ] Usage examples are provided
- [ ] Requirements and dependencies are documented
- [ ] License is specified (in plugin.json or LICENSE file)
- [ ] Each component has adequate documentation

### 6. Naming Conventions
- [ ] Plugin name is descriptive and indicates purpose
- [ ] Plugin name doesn't conflict with common/existing plugins
- [ ] Avoid generic names like `utils`, `helpers`, `misc`
- [ ] Skill names clearly indicate their purpose
- [ ] Command names are intuitive and follow slash-command conventions

### 7. Versioning
- [ ] Version number is appropriate for current state
- [ ] Breaking changes increment MAJOR version
- [ ] New features increment MINOR version
- [ ] Bug fixes increment PATCH version
- [ ] Version matches expected maturity (1.0.0+ for production-ready)

### 8. Security and Safety
- [ ] No hardcoded credentials or API keys
- [ ] No references to private/internal systems in public plugins
- [ ] Hook commands don't execute unsafe operations
- [ ] MCP servers use secure connection methods
- [ ] No malicious or obfuscated code

## Common Issues to Flag

### Critical Issues (must fix before sharing)
- Missing or malformed plugin.json
- Invalid JSON syntax
- Absolute paths instead of relative paths
- Missing required component files
- Security vulnerabilities (hardcoded secrets, unsafe code)
- Invalid semantic versioning

### Important Issues (should fix)
- Missing or inadequate description
- Poor or generic naming
- Missing documentation
- Untested components
- Paths that don't start with `./`
- No version or author information

### Minor Issues (nice to fix)
- Missing keywords for discoverability
- No homepage or repository link
- Could benefit from more examples
- Documentation could be clearer
- Directory structure could be more intuitive

## Review Decision Criteria

### Ready to Share
Plugin is ready to share if:
- All critical issues resolved
- Plugin installs and works correctly
- Documentation is adequate
- Follows best practices
- Has clear, single purpose

### Needs Revision
Plugin needs revision if:
- Any critical issues present
- Important issues significantly impact usability
- Testing reveals functionality problems
- Documentation is insufficient

### Reject
Plugin should be rejected if:
- Security vulnerabilities present
- Malicious or deceptive functionality
- Violates plugin system requirements
- Cannot be fixed to meet minimum standards
