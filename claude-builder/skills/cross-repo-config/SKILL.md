---
name: Managing Cross-Repository Configuration
description: Guide for organizing Claude Code configuration, skills, and learnings across multiple repositories. Covers the three-tier architecture (global, plugin, project-local) and decision criteria for where to store different types of configuration and knowledge.
---

# Managing Cross-Repository Configuration

When working across multiple repositories (e.g., your marketplace repo, vLLM, llama stack, etc.), you need a clear strategy for where to store configurations, learnings, and skills to ensure consistency without duplication.

## Three-Tier Architecture

Claude Code supports three tiers of configuration, each with specific use cases:

### 1. Global Configuration (`~/.claude/CLAUDE.md`)

**Use for:**
- Personal coding style preferences
- General development patterns you prefer across all projects
- Your personal workflow preferences
- Cross-language, cross-project knowledge
- Tool usage preferences
- Communication style preferences

**Benefits:**
- Automatically available in ALL repositories
- No installation or setup needed
- Single source of truth for personal preferences
- Simplest approach for most user preferences

**Example content:**
```markdown
# Python code style
- Always put imports at the top of the file, not within methods
- Use descriptive variable names over comments

# General preferences
- Prefer Edit tool over Write for existing files
- Keep commit messages concise and action-oriented
```

### 2. Plugin Skills (in marketplace/plugin repos)

**Use for:**
- Domain-specific expertise (e.g., PR review patterns, testing strategies)
- Shareable, reusable capabilities
- Structured knowledge for specific problem domains
- Workflow patterns others might benefit from

**Benefits:**
- Versioned and organized by domain
- Shareable across teams
- Available wherever marketplace is installed
- Can be distributed and maintained separately

**When to use:**
- Creating reusable capabilities for specific domains
- Knowledge that should be version-controlled
- Patterns that could benefit others
- Structured workflows with multiple steps

### 3. Project-Local Configuration (`.claude/CLAUDE.md` in project)

**Use for:**
- This specific codebase's architecture patterns
- Project-specific conventions and decisions
- Team agreements for this repository
- Codebase-specific context

**Benefits:**
- Only applies to this repository
- Can be committed to version control
- Shared across team members
- Won't interfere with other projects

**Example content:**
```markdown
# This Project's Patterns

- Authentication uses JWT tokens stored in httpOnly cookies
- All API routes go through middleware/auth.ts
- Database migrations use Prisma in prisma/migrations/
```

## Decision Framework

When deciding where to store configuration or learnings, ask:

**Is this personal preference?** → Global (`~/.claude/CLAUDE.md`)
- Coding style you prefer
- Your workflow patterns
- How you like tools to be used

**Is this shareable domain knowledge?** → Plugin Skill
- PR review techniques
- Testing strategies
- Deployment patterns
- General best practices

**Is this specific to one codebase?** → Project-Local (`.claude/CLAUDE.md`)
- Where files are located in this repo
- This project's architecture decisions
- Team conventions for this codebase

## Cross-Repository Consistency

To ensure consistency across all repositories:

### For Personal Preferences
Use `~/.claude/CLAUDE.md` exclusively. This automatically applies everywhere you use Claude Code.

### For Domain Knowledge
Create plugin skills in a marketplace repository:
1. Develop skills in your marketplace source repo
2. Version and commit skills
3. Install marketplace globally or per-project
4. Skills available wherever marketplace is installed
5. Update skills in source repo, push changes
6. Other repos get updates when they reload

### For Project-Specific Patterns
Use project-local `.claude/CLAUDE.md` committed to that repository's version control.

## Implementation Pattern: The `/learn` Command

A well-designed `/learn` command should:

1. **Identify the learning type** from the conversation
2. **Ask the user** which tier is appropriate:
   - Global: Personal preferences
   - Plugin Skill: Domain expertise
   - Project-Local: This codebase's patterns
3. **Save accordingly**:
   - Global: Append to `~/.claude/CLAUDE.md`
   - Plugin: Use skill-builder to create/update skill
   - Project: Append to `.claude/CLAUDE.md` in current repo
4. **Confirm** where the learning was saved

This ensures learnings are:
- Scoped appropriately
- Discoverable where needed
- Not duplicated across tiers

## Common Anti-Patterns

**DON'T:**
- Store personal preferences in project-local files (won't follow you)
- Store project-specific patterns globally (pollutes other projects)
- Create plugin skills for one-off project patterns
- Duplicate the same guidance across multiple tiers

**DO:**
- Use the simplest tier that meets your needs
- Default to global for personal preferences
- Use plugins for reusable, shareable knowledge
- Keep project-local truly project-specific

## Validation

To verify your configuration architecture:

1. **Test global application**: Check that `~/.claude/CLAUDE.md` preferences apply in a new, unrelated repository
2. **Test plugin availability**: Verify plugin skills work in projects where the marketplace is installed
3. **Test isolation**: Confirm project-local settings don't leak to other repositories
4. **Check for duplication**: Ensure the same guidance doesn't exist in multiple tiers

## Example Scenario

**Situation:** You learn a better way to write commit messages while working on vLLM.

**Decision process:**
- Is this how YOU prefer all commit messages? → Global
- Is this a general best practice for commit messages? → Plugin Skill
- Is this how vLLM specifically wants commits? → Project-Local

Most likely: **Global** (`~/.claude/CLAUDE.md`) because commit message style is typically a personal preference that should apply everywhere you work.

## Tips for Success

1. **Start with global**: Most personal preferences belong in `~/.claude/CLAUDE.md`
2. **Plugin skills for patterns**: Use when you'd answer "others could benefit from this"
3. **Project-local is rare**: Only truly project-specific architecture belongs here
4. **Review periodically**: Check if project-local settings should be elevated to global
5. **Keep it simple**: Don't over-engineer the tier structure
