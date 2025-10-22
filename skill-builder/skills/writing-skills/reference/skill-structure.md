# Skill Structure Reference

Complete guide to organizing and structuring Claude Code skills for maximum effectiveness.

## Directory Locations

Skills can be placed in three locations:

### Personal Skills
- **Location**: `~/.claude/skills/`
- **Scope**: Available across all projects for the user
- **Use case**: Personal utilities, workflows, preferences

### Project Skills
- **Location**: `.claude/skills/`
- **Scope**: Project-specific, shared via version control
- **Use case**: Team workflows, project conventions, tooling

### Plugin Skills
- **Location**: Within plugin `skills/` directory
- **Scope**: Bundled with plugin, shareable via plugin marketplace
- **Use case**: Reusable capabilities for distribution

## Required Structure

### Minimum Viable Skill

```
my-skill/
└── SKILL.md
```

The only required file is `SKILL.md` with YAML frontmatter:

```yaml
---
name: Skill Name
description: One-line description of what this skill does
---

# Skill content and instructions
```

### Frontmatter Fields

#### Required
- `name`: Human-readable name (max 64 characters)
  - Use gerund form: "Processing", "Analyzing", "Creating"
  - Be specific, avoid vague terms

- `description`: One-line explanation (max 1024 characters)
  - Third person: "Guides...", "Helps...", "Provides..."
  - Include key terms for discoverability
  - Specify when to use this skill

#### Optional
- `allowed-tools`: Array of tool names to restrict access
  ```yaml
  allowed-tools: [Read, Grep, Glob, Bash]
  ```
  - Use for safety-critical operations
  - Use for read-only analysis
  - Omit to allow all tools

## Progressive Disclosure Structure

For complex skills, organize supporting materials:

```
my-skill/
├── SKILL.md              # Entry point (concise)
├── reference/            # Detailed documentation
│   ├── concepts.md       # Background information
│   ├── api-reference.md  # API/interface details
│   └── examples.md       # Extended examples
├── scripts/              # Utility scripts
│   ├── validator.py      # Validation logic
│   └── formatter.sh      # Formatting helper
└── templates/            # Starter templates
    ├── output.json       # Expected output format
    └── config.yaml       # Configuration template
```

### When to Use Each Directory

#### `reference/`
Use for detailed documentation that supports SKILL.md:
- Comprehensive API documentation
- Extended conceptual explanations
- Additional examples and use cases
- Specification documents
- Background context

**Pattern**: Reference from SKILL.md with phrases like:
- "For detailed API documentation, see `reference/api-reference.md`"
- "See `reference/examples.md` for more examples"

#### `scripts/`
Use for executable utilities that perform deterministic operations:
- Data validation
- Format conversion
- File processing
- API calls
- System operations

**Best practices**:
- Handle errors explicitly
- Provide clear output/error messages
- Make scripts idempotent when possible
- Document script usage in SKILL.md or reference files

#### `templates/`
Use for starter files and examples:
- Output format examples
- Configuration templates
- Code scaffolding
- Document structures

**Pattern**: Reference in instructions:
- "Use `templates/output.json` as the output format"
- "Start with `templates/component.tsx` structure"

## File Organization Patterns

### Pattern 1: Simple Focused Skill
Best for single-purpose, straightforward skills:

```
focused-skill/
└── SKILL.md
```

All instructions in one concise file.

### Pattern 2: Documented Skill
For skills needing additional context:

```
documented-skill/
├── SKILL.md
└── reference/
    └── details.md
```

Core instructions in SKILL.md, extended details in reference.

### Pattern 3: Scripted Skill
For skills with deterministic operations:

```
scripted-skill/
├── SKILL.md
└── scripts/
    ├── process.py
    └── validate.sh
```

Instructions in SKILL.md, automation in scripts.

### Pattern 4: Complete Skill
For comprehensive, production-ready skills:

```
complete-skill/
├── SKILL.md
├── reference/
│   ├── concepts.md
│   ├── api-docs.md
│   └── examples.md
├── scripts/
│   ├── validator.py
│   └── helper.sh
└── templates/
    └── output.json
```

Full progressive disclosure with all supporting materials.

## Content Organization in SKILL.md

### Recommended Structure

```markdown
---
name: Skill Name
description: Clear, specific description
---

# Skill Name

Brief introduction explaining what this skill does.

## Core Concepts
Essential background (if needed, otherwise move to reference/)

## Instructions
Step-by-step guidance or workflow

## Examples
2-3 concrete examples showing usage

## Validation
How to verify success or check results

## References
- `reference/file.md`: Description of what's there
- `scripts/script.py`: What the script does
```

### Content Guidelines

**Keep in SKILL.md**:
- Essential instructions
- Core workflow steps
- Key examples
- Critical constraints
- References to additional files

**Move to reference files**:
- Extensive background
- Comprehensive API docs
- Many examples
- Edge cases and variations
- Historical context

## Tool Restrictions

Control which tools Claude can use within the skill:

### Syntax
```yaml
---
name: Skill Name
description: Description here
allowed-tools: [ToolName1, ToolName2]
---
```

### Common Tool Sets

#### Read-Only Analysis
```yaml
allowed-tools: [Read, Grep, Glob]
```

#### File Operations
```yaml
allowed-tools: [Read, Write, Edit, Glob, Grep]
```

#### Development Tasks
```yaml
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
```

#### Script Execution Only
```yaml
allowed-tools: [Bash]
```

### When to Restrict Tools

Restrict tools when:
- Safety is critical (prevent unintended changes)
- Skill is analysis-only (no modifications needed)
- Enforcing specific workflow (must use provided scripts)
- Testing or validation (read-only verification)

## Naming Conventions

### Skill Directory Names
- Use kebab-case: `my-skill-name`
- Be descriptive: `react-component-generator` not `helper`
- Indicate purpose: `pdf-invoice-processor`

### File Naming
- SKILL.md: Always uppercase, always this name
- Reference files: Descriptive, kebab-case: `api-reference.md`
- Scripts: Descriptive, indicate function: `validate-output.py`
- Templates: Indicate what they template: `component-template.tsx`

### Name Field (in frontmatter)
- Use gerund form: "Processing PDFs"
- Title case: "Creating React Components"
- Specific and descriptive

## Size Guidelines

### SKILL.md
- Target: 200-400 lines
- Maximum: 500 lines
- If approaching max, move content to reference files

### Reference Files
- Keep focused on one topic per file
- Split large references into multiple files
- No hard limit, but stay organized

### Scripts
- One responsibility per script
- Document usage at top of file
- Keep maintainable

## Version Control

### What to Include
- All skill files (SKILL.md, reference, scripts, templates)
- README.md explaining the skill (optional but helpful)
- Tests for scripts (if applicable)

### What to Exclude
- Generated outputs
- User-specific configurations
- Temporary files
- Cache files

### Git Best Practices
```gitignore
# In skill directory
*.pyc
__pycache__/
.DS_Store
*.tmp
cache/
```

## Testing Your Structure

Verify your skill structure:

1. **Completeness**: SKILL.md exists with required frontmatter
2. **Clarity**: Name and description are specific
3. **Organization**: Supporting files are logically organized
4. **References**: All file references in SKILL.md are valid
5. **Scripts**: All scripts are executable and documented
6. **Size**: SKILL.md is under 500 lines

## Migration Patterns

### From Monolithic to Progressive

If SKILL.md is too large:

1. Identify sections that could be separate files
2. Create reference directory
3. Move sections to focused reference files
4. Update SKILL.md with references
5. Keep core workflow in SKILL.md

Example:
```markdown
# Before (in SKILL.md)
## API Documentation
[50 lines of API details]

# After (in SKILL.md)
## API Documentation
See `reference/api-reference.md` for complete API documentation.
```

### From Simple to Scripted

Adding automation:

1. Identify deterministic operations
2. Create scripts directory
3. Implement operations in scripts
4. Update SKILL.md to reference scripts
5. Add error handling to scripts

Example:
```markdown
# Before
Validate the output format matches the expected schema.

# After
Run `scripts/validate-output.py` to verify the output format.
```

## Advanced Patterns

### Multi-Language Scripts
```
skill/
├── SKILL.md
└── scripts/
    ├── process.py      # Python for data processing
    ├── validate.sh     # Bash for quick checks
    └── analyze.js      # Node for JSON operations
```

### Conditional References
```markdown
For basic usage, follow the instructions above.

For advanced scenarios, see:
- `reference/advanced-patterns.md`: Complex workflows
- `reference/error-handling.md`: Troubleshooting guide
```

### Shared Resources
```
skills/
├── skill-one/
│   └── SKILL.md
├── skill-two/
│   └── SKILL.md
└── shared/
    ├── common-scripts/
    └── common-templates/
```

Reference shared resources with relative paths:
```markdown
Use `../shared/common-templates/output.json` as the format.
```

## Key Takeaways

1. Only SKILL.md is required
2. Use progressive disclosure for complex skills
3. Keep SKILL.md under 500 lines
4. Organize supporting files logically
5. Reference additional files clearly
6. Use scripts for deterministic operations
7. Restrict tools when appropriate
8. Follow naming conventions consistently
9. Test structure before distributing
10. Evolve structure as skill complexity grows
