# Best Practices for Writing Claude Skills

Comprehensive guide to creating effective, maintainable, and discoverable skills.

## Core Principles

### 1. Be Concise

**Why**: Skills extend Claude's knowledge. Claude already has extensive capabilities - only add what's truly new.

**How**:
- Challenge every sentence: "Does Claude really need this?"
- Remove obvious information
- Keep SKILL.md under 500 lines
- Move extensive details to reference files

**Examples**:

```markdown
# Too verbose
## Processing Files
When you need to process files, first you should read them using the Read tool.
The Read tool is a built-in capability that allows you to access file contents.
After reading, analyze the content carefully.

# Concise (Claude knows this)
## Processing Files
Extract key metrics from each file and aggregate results.
```

### 2. Set Appropriate Degrees of Freedom

**Why**: Match specificity to task complexity and fragility.

**High Freedom**: For flexible, creative tasks where Claude can adapt
```markdown
Analyze the codebase and suggest architectural improvements.
```

**Low Freedom**: For fragile, sequence-critical, or safety-critical operations
```markdown
1. Backup database to `backups/db_YYYYMMDD.sql`
2. Run migration: `npm run migrate:up`
3. Verify migration: check `schema_version` table
4. If verification fails, rollback: `npm run migrate:down`
```

**Balance**:
```markdown
# Too restrictive (micro-managing)
1. Open the file
2. Read line 1
3. Parse the date
4. Store in variable called 'date'

# Appropriate
Extract the date from the first line using format YYYY-MM-DD.
Validate it's a valid date before proceeding.
```

### 3. Clear Naming

**Skill Names** (in frontmatter):
- Use gerund form (verb + -ing)
- Be specific and descriptive
- Avoid vague terms

```yaml
# Good
name: Analyzing Performance Metrics
name: Generating API Documentation
name: Processing Invoice PDFs

# Avoid
name: Helper
name: Utils
name: Manager
name: Processor
```

**Directory Names**:
```
# Good
performance-analyzer/
api-doc-generator/
invoice-processor/

# Avoid
helper/
utils/
thing/
```

### 4. Specific Descriptions

**Why**: The description determines when Claude chooses to use your skill.

**Formula**: [Action] [specific task] [key context/constraints]

```yaml
# Excellent
description: Analyzes React components for performance anti-patterns including unnecessary re-renders, missing memoization, and inefficient hooks usage

# Good
description: Processes invoice PDFs to extract vendor, date, items, and total with validation

# Too vague (Claude won't know when to use it)
description: Helps with documents
description: A useful utility
```

**Include key terms**:
```yaml
# Include technology names
description: Creates TypeScript React components with styled-components and Jest tests

# Include output formats
description: Converts CSV data to validated JSON following schema.org format

# Include constraints
description: Generates API documentation from JSDoc comments preserving examples and types
```

## Writing Effective Instructions

### Structure Your Instructions

```markdown
# Good structure
## Overview
Brief 1-2 sentence summary

## Prerequisites
What must exist or be true before starting

## Workflow
1. Step one with specifics
2. Step two with validation
3. Step three with output format

## Validation
How to verify success

## Examples
Concrete examples
```

### Be Specific About Outputs

```markdown
# Vague
Generate a report.

# Specific
Generate a report in markdown with:
- Summary section with key findings
- Metrics table with columns: metric, value, threshold, status
- Recommendations list ordered by priority
```

### Include Validation Steps

```markdown
# Without validation
1. Parse the configuration
2. Apply settings
3. Restart service

# With validation
1. Parse the configuration
2. Validate required fields exist: host, port, api_key
3. Apply settings
4. Verify service starts successfully (check port is listening)
```

### Provide Context for Decisions

```markdown
# No context
Use the fast algorithm.

# With context
Use the fast algorithm for files under 10MB.
For larger files, use the streaming algorithm to avoid memory issues.
```

## Progressive Disclosure

### When to Use Reference Files

Use reference files when:
- Background information exceeds 100 lines
- API documentation is comprehensive
- Multiple detailed examples are needed
- Content is optional/advanced

### Self-Contained Skills

**IMPORTANT**: Skills must be completely self-contained within their own directory.

**DO:**
- Reference files within the skill directory: `reference/api-docs.md`
- Include all necessary content within the skill structure
- Duplicate information if needed across multiple skills

**DON'T:**
- Reference files outside the skill directory (e.g., `../../CLAUDE.md`)
- Reference project files (e.g., `../other-skill/reference.md`)
- Depend on external documentation not in the skill directory

Why: Skills may be used in different contexts (personal, project, plugin) and must work independently without external dependencies.

### How to Reference

```markdown
# Good: Clear purpose, internal reference
For complete API reference, see `reference/api-docs.md`
See `reference/examples.md` for 10+ real-world examples

# Bad: External reference
See the project CLAUDE.md for more details
Refer to ../../docs/guide.md

# Too vague
More info in reference folder
```

### What Stays in SKILL.md

Keep in SKILL.md:
- Core workflow (the "what" and "how")
- Essential constraints
- 1-2 key examples
- Validation steps
- References to detailed docs (within skill directory)

Move to reference files:
- Extended background ("why" and history)
- Comprehensive API documentation
- Many examples
- Edge cases
- Troubleshooting guides

## Documentation Patterns

### Avoid Time-Sensitive Information

```markdown
# Avoid (will become outdated)
Use the new React hooks API introduced in version 16.8

# Better (timeless)
Use React hooks for state management
```

### Use Consistent Terminology

Pick terms and stick with them:

```markdown
# Inconsistent
1. Parse the document
2. Extract data from the file
3. Process the input

# Consistent
1. Parse the document
2. Extract data from the document
3. Process the document
```

### Write for the Model

Remember: Skills are for Claude, not humans.

```markdown
# Too human-centric
This is a really helpful tool that makes your life easier!
Everyone loves this workflow because it's so intuitive.

# Model-focused
Extract structured data from unstructured logs using these patterns.
```

### Provide Concrete Examples

```markdown
# Abstract
Process dates correctly.

# Concrete
Convert dates to ISO 8601 format:
- Input: "Jan 15, 2024" → Output: "2024-01-15"
- Input: "3/7/24" → Output: "2024-03-07"
```

## Tool Restrictions

### When to Restrict

Restrict tools (`allowed-tools`) when:

1. **Safety-critical operations**: Prevent unintended modifications
```yaml
allowed-tools: [Read, Grep, Glob]  # Read-only analysis
```

2. **Enforcing workflow**: Must use specific tools in order
```yaml
allowed-tools: [Bash]  # Only run provided scripts
```

3. **Compliance**: Must not modify certain files
```yaml
allowed-tools: [Read, Grep]  # Audit mode
```

### Common Patterns

```yaml
# Analysis only
allowed-tools: [Read, Grep, Glob]

# File operations
allowed-tools: [Read, Write, Edit, Glob, Grep]

# Development
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]

# Script execution
allowed-tools: [Bash, Read]
```

### Don't Over-Restrict

```yaml
# Too restrictive (Claude can't be effective)
allowed-tools: [Read]

# Better (if editing is needed)
allowed-tools: [Read, Edit, Grep, Glob]
```

## Script Best Practices

### When to Use Scripts

Use scripts for:
- Deterministic operations (same input → same output)
- Complex calculations
- API calls
- System operations
- Validation logic

Don't use scripts for:
- What Claude can do better (analysis, decision-making)
- Simple operations
- One-off tasks

### Script Structure

```python
#!/usr/bin/env python3
"""
Brief description of what this script does.

Usage:
    python script.py input.json output.json

Exit codes:
    0: Success
    1: Validation error
    2: File error
"""

import sys
import json

def main():
    # Clear error handling
    if len(sys.argv) != 3:
        print("Usage: script.py input.json output.json", file=sys.stderr)
        sys.exit(1)

    # Validate inputs
    # Process data
    # Output results

if __name__ == "__main__":
    main()
```

### Script Documentation

In SKILL.md:
```markdown
## Validation

Run `scripts/validate.py` to verify output format:

\`\`\`bash
python scripts/validate.py output.json
\`\`\`

Returns exit code 0 on success, 1 on validation errors.
```

## Testing Skills

### Create Test Scenarios

Before writing extensive documentation:

```markdown
# Test scenarios
1. Input: Simple case
   Expected: Standard output

2. Input: Edge case (empty file)
   Expected: Handle gracefully

3. Input: Invalid data
   Expected: Clear error message
```

### Iterative Development

1. Start with minimal SKILL.md
2. Test with Claude on real task
3. Note what Claude struggles with
4. Add specific guidance for those areas
5. Repeat until effective

### Evaluation Questions

- Does Claude discover the skill appropriately?
- Does Claude understand when NOT to use it?
- Are outputs consistent and correct?
- Does Claude handle edge cases?
- Is the skill too restrictive or too loose?

## Common Mistakes

### Mistake 1: Over-Explaining

```markdown
# Bad
The Read tool is a powerful capability that allows you to read files.
You should use it when you need to access file contents. Files are
stored on disk and contain data...

# Good
Read the configuration file and extract the database settings.
```

### Mistake 2: Vague Descriptions

```yaml
# Bad
description: Helps with things

# Good
description: Converts CSV sales data to quarterly revenue reports with charts
```

### Mistake 3: Missing Examples

```markdown
# Bad
Format the output appropriately.

# Good
Format output as JSON:
{
  "metric": "response_time",
  "value": 245,
  "unit": "ms"
}
```

### Mistake 4: No Validation

```markdown
# Bad
1. Parse config
2. Apply changes
3. Done

# Good
1. Parse config
2. Validate required fields: api_key, endpoint, timeout
3. Apply changes
4. Verify: curl endpoint returns 200
```

### Mistake 5: Monolithic SKILL.md

```markdown
# Bad: Everything in SKILL.md (800 lines)
[200 lines of background]
[300 lines of API docs]
[300 lines of examples]

# Good: Progressive disclosure
# SKILL.md (200 lines)
- Core workflow
- Key example
- Reference to `reference/api-docs.md`
- Reference to `reference/examples.md`
```

## Skill Maintenance

### Versioning

If distributing via plugin:
- Increment plugin version in `plugin.json`
- Document changes in plugin changelog
- Test with current Claude model

### Evolution

As skills mature:
1. Monitor usage patterns
2. Refine based on real usage
3. Add missing edge cases
4. Remove unnecessary verbosity
5. Update examples

### Deprecation

When deprecating:
1. Update description: "DEPRECATED: Use skill-name-v2 instead"
2. Keep functional for transition period
3. Document migration path
4. Remove after transition

## Performance Optimization

### Reduce Token Usage

```markdown
# Higher token usage
Detailed explanation of every step with comprehensive background
information that Claude likely already knows from pre-training.

# Optimized
[Concise instructions referencing detailed docs in reference/ as needed]
```

### Faster Discovery

Make skills discoverable with specific descriptions:

```yaml
# Faster discovery (specific terms)
description: Processes Stripe webhook events for payment.succeeded and payment.failed

# Slower discovery (vague)
description: Handles webhooks
```

## Collaboration

### Team Skills

When creating skills for teams:
- Document project-specific conventions
- Include team workflow patterns
- Reference team tools and systems
- Use consistent terminology across team skills

### Skill Libraries

Organize related skills:
```
.claude/skills/
├── data-processing/
│   ├── csv-processor/
│   ├── json-transformer/
│   └── xml-parser/
└── code-generation/
    ├── react-components/
    └── api-endpoints/
```

## Advanced Patterns

### Skill Composition

Reference other skills:
```markdown
This skill builds on the "Processing CSVs" skill.
First use that skill to parse the data, then apply the transformations below.
```

### Conditional Workflows

```markdown
If dataset < 1000 rows:
  Process in-memory using standard algorithm

If dataset >= 1000 rows:
  1. Split into chunks of 1000 rows
  2. Process each chunk
  3. Aggregate results
```

### Feedback Loops

```markdown
1. Generate initial output
2. Validate against schema
3. If validation fails:
   - Review error messages
   - Adjust output
   - Re-validate
4. Repeat until valid
```

## Checklist for High-Quality Skills

Before finalizing a skill:

- [ ] Name uses gerund form and is specific
- [ ] Description is clear, specific, includes key terms
- [ ] SKILL.md is under 500 lines
- [ ] Examples are concrete and helpful
- [ ] Validation steps are included
- [ ] Tool restrictions are appropriate (if any)
- [ ] Scripts have error handling and documentation
- [ ] Reference files are well-organized
- [ ] Tested with real scenarios
- [ ] No time-sensitive information
- [ ] Consistent terminology throughout
- [ ] Clear when to use / when not to use

## Key Principles Summary

1. **Be concise**: Only what Claude doesn't know
2. **Be specific**: Clear names, descriptions, examples
3. **Be practical**: Test with real scenarios
4. **Be progressive**: Start simple, add detail as needed
5. **Be consistent**: Terminology, formatting, style
6. **Be validated**: Include verification steps
7. **Be discovered**: Specific descriptions with key terms
8. **Be maintained**: Update based on usage

Remember: Skills are extensions of Claude's capabilities. Make them focused, discoverable, and effective by following these practices.
