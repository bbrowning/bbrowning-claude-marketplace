# Marketplace Best Practices

Comprehensive guide to organizing, versioning, distributing, and collaborating on Claude Code plugin marketplaces.

## Organization

### Group Related Plugins

Keep plugins with related functionality together in your marketplace. This improves discoverability and makes the marketplace purpose clear.

**Good organization**:
```
team-productivity/
├── code-review-helper/
├── pr-templates/
└── testing-utils/
```

**Poor organization**:
```
random-stuff/
├── unrelated-plugin-1/
├── totally-different-plugin-2/
└── another-random-thing/
```

### Clear Naming

Use descriptive, kebab-case names for both the marketplace and plugins.

**Good names**:
- `data-science-tools`
- `web-dev-utilities`
- `team-workflows`

**Avoid**:
- `stuff`
- `utils`
- `my-plugins`

### Documentation

Include a README.md explaining the marketplace purpose, available plugins, and installation instructions.

**Essential README sections**:
- Marketplace description and purpose
- List of plugins with brief descriptions
- Installation instructions
- Usage examples
- Contribution guidelines (if accepting contributions)

### Consistent Structure

Maintain similar directory structure across plugins in your marketplace.

**Example consistent structure**:
```
marketplace/
├── plugin-one/
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── skills/
│   └── commands/
├── plugin-two/
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── skills/
│   └── commands/
```

## Versioning

### Marketplace Versioning

Track the marketplace version in marketplace.json to help users understand when significant changes occur.

```json
{
  "name": "my-marketplace",
  "version": "1.2.0",
  "owner": {
    "name": "Your Name"
  }
}
```

**Version increments**:
- **MAJOR**: Breaking changes (plugin removed, structure changed)
- **MINOR**: New plugins added, significant updates
- **PATCH**: Bug fixes, documentation updates

### Plugin Versioning

Each plugin maintains its own semantic version in its plugin.json.

```json
{
  "name": "my-plugin",
  "version": "2.1.0"
}
```

Plugins version independently from the marketplace version.

### Git Tags

Use git tags to mark marketplace releases, making it easy to reference specific versions.

```bash
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin v1.2.0
```

Users can then install specific versions:
```bash
/plugin marketplace add https://github.com/user/marketplace.git#v1.2.0
```

### Changelog

Document changes in CHANGELOG.md following the Keep a Changelog format.

**Example CHANGELOG.md**:
```markdown
# Changelog

## [1.2.0] - 2024-01-15

### Added
- New testing-utils plugin
- Documentation for all plugins

### Changed
- Updated code-review-helper to v2.0.0

### Fixed
- Fixed plugin paths in marketplace.json
```

## Distribution

### Public vs Private Repositories

Choose repository visibility based on your needs:

**Public repositories**:
- Open-source plugins for community use
- Sharing tools across teams in different organizations
- Building a plugin ecosystem

**Private repositories**:
- Internal team tools with proprietary logic
- Company-specific workflows
- Sensitive configurations or integrations

### Access Control

Use repository permissions to control marketplace access:

**GitHub/GitLab permissions**:
- Public repos: Anyone can clone and use
- Private repos: Only authorized users can access
- Organization repos: Team-based access control

### Documentation

Provide clear installation instructions in README.md:

```markdown
## Installation

1. Add the marketplace:
   ```bash
   /plugin marketplace add https://github.com/team/marketplace.git
   ```

2. Browse available plugins:
   ```bash
   /plugin
   ```

3. Install a plugin:
   ```bash
   /plugin install plugin-name@marketplace-name
   ```
```

### Examples

Include example usage in README or individual plugin docs:

```markdown
## Example Usage

After installing the code-review-helper plugin:

1. Open a pull request
2. Run `/review` to analyze changes
3. Review the generated feedback
```

## Collaboration

### Team Marketplaces

Create shared marketplaces for standardized team workflows:

**Benefits**:
- Consistent tooling across team members
- Shared best practices encoded in plugins
- Easy onboarding for new team members
- Centralized maintenance

**Example team structure**:
```
team-engineering/
├── .claude-plugin/
│   └── marketplace.json
├── code-standards/
├── deployment-tools/
└── review-helpers/
```

### Pull Request Workflow

Use PRs for plugin additions and updates:

**Workflow**:
1. Create feature branch for new plugin or update
2. Add/modify plugin in the marketplace
3. Update marketplace.json
4. Test locally
5. Submit PR with description of changes
6. Review and merge

**PR template**:
```markdown
## Change Description
[New plugin / Plugin update / Bug fix]

## Plugin Name
plugin-name

## Testing
- [ ] Installed locally and tested
- [ ] All commands/skills work as expected
- [ ] Documentation is complete

## Checklist
- [ ] marketplace.json updated
- [ ] Plugin version incremented (if update)
- [ ] CHANGELOG.md updated
```

### Code Review

Review plugin changes before merging:

**Review checklist**:
- [ ] Plugin manifest is valid
- [ ] Plugin name matches marketplace.json entry
- [ ] Documentation is clear and complete
- [ ] Skills/commands work as intended
- [ ] No sensitive information in code
- [ ] Follows team conventions

### Testing

Test plugin installations before publishing updates:

**Testing steps**:
1. Clean environment test:
   ```bash
   # Uninstall existing version
   /plugin uninstall plugin-name@marketplace-name

   # Pull latest changes
   git pull

   # Reinstall
   /plugin install plugin-name@marketplace-name
   ```

2. Verify functionality:
   - Test all commands
   - Verify all skills load
   - Check for errors with `claude --debug`

3. Test on multiple platforms (if applicable):
   - macOS
   - Linux
   - Windows

## Common Patterns

### Personal Marketplace

Organize personal tools and utilities:

```
my-tools/
├── .claude-plugin/
│   └── marketplace.json
├── productivity/
│   └── .claude-plugin/
│       └── plugin.json
├── development/
│   └── .claude-plugin/
│       └── plugin.json
└── utilities/
    └── .claude-plugin/
        └── plugin.json
```

**Use cases**:
- Personal productivity tools
- Custom development helpers
- Workflow automation
- Learning and experimentation

### Team Marketplace

Shared tools for engineering teams:

```
team-marketplace/
├── .claude-plugin/
│   └── marketplace.json
├── code-standards/
│   └── .claude-plugin/
│       └── plugin.json
├── deployment-tools/
│   └── .claude-plugin/
│       └── plugin.json
└── review-helpers/
    └── .claude-plugin/
        └── plugin.json
```

**Use cases**:
- Standardized code review processes
- Deployment automation
- Code generation templates
- Team-specific workflows

### Community Marketplace

Public collection of domain-specific plugins:

```
community-plugins/
├── .claude-plugin/
│   └── marketplace.json
├── data-science/
│   └── .claude-plugin/
│       └── plugin.json
├── web-dev/
│   └── .claude-plugin/
│       └── plugin.json
└── devops/
    └── .claude-plugin/
        └── plugin.json
```

**Use cases**:
- Domain-specific tool collections
- Community-contributed plugins
- Open-source plugin ecosystem
- Educational resources

### Hybrid Marketplace

Mix local and remote plugins:

```json
{
  "name": "hybrid-marketplace",
  "plugins": [
    {
      "name": "internal-tool",
      "source": "./internal-tool",
      "description": "Company-specific internal tool"
    },
    {
      "name": "community-plugin",
      "source": "github:community/awesome-plugin",
      "description": "Popular community plugin"
    },
    {
      "name": "team-plugin",
      "source": "https://gitlab.company.com/team/plugin.git",
      "description": "Team plugin from GitLab"
    }
  ]
}
```

**Use cases**:
- Combining internal and external tools
- Curating best-of-breed plugins
- Gradual migration from monolithic to distributed
- Mixed public/private plugin collections

## Key Takeaways

1. **Organization**: Group related plugins, use clear naming, document well
2. **Versioning**: Use semantic versioning for both marketplace and plugins
3. **Distribution**: Choose appropriate visibility, provide clear docs
4. **Collaboration**: Use PR workflow, review changes, test thoroughly
5. **Patterns**: Choose structure that matches your use case
