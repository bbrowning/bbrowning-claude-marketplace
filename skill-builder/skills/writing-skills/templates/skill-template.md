---
name: [Gerund Form: "Processing", "Analyzing", "Creating"]
description: [Third person, specific description with key terms - max 1024 chars]
# Optional: Restrict which tools Claude can use
# allowed-tools: [Read, Write, Edit, Bash, Grep, Glob]
---

# [Skill Name]

[1-2 sentence overview of what this skill does and when to use it]

## Overview

[Brief explanation of the skill's purpose and capabilities]

## Prerequisites

[Optional: List what must exist or be true before using this skill]
- Prerequisite 1
- Prerequisite 2

## Workflow

[Step-by-step instructions for accomplishing the task]

1. **[Step name]**
   [Description of what to do]

   ```bash
   # Example command if applicable
   ```

2. **[Step name]**
   [Description of what to do]
   - Sub-step if needed
   - Another sub-step

3. **[Step name with validation]**
   [Description]

   Verify:
   - Expected outcome 1
   - Expected outcome 2

## Expected Output

[Describe or show the expected output format]

```[language]
# Example output
{
  "field": "value"
}
```

## Validation

[How to verify the task was completed successfully]

- [ ] Validation checkpoint 1
- [ ] Validation checkpoint 2

## Examples

### Example 1: [Scenario Name]

**Input:**
```
[Example input]
```

**Process:**
[What to do with this input]

**Output:**
```
[Expected output]
```

### Example 2: [Edge Case or Variation]

[Another concrete example demonstrating usage]

## Common Issues

### Issue: [Problem Description]
**Solution**: [How to resolve]

### Issue: [Another Problem]
**Solution**: [How to resolve]

## Error Handling

[How to handle errors or unexpected situations]

If [error condition]:
1. [Recovery step]
2. [Verification step]

## Advanced Usage

[Optional: Advanced patterns or variations]

### Pattern 1: [Advanced Pattern Name]
[Description and example]

### Pattern 2: [Another Pattern]
[Description and example]

## References

[Optional: Link to supporting documentation]
- `reference/detailed-docs.md`: [What's there]
- `scripts/helper.py`: [What it does]
- `templates/output-format.json`: [What it shows]

---

## Template Usage Notes

**Remove this section before using**

### Naming Guidelines
- **Skill name**: Use gerund (verb + -ing)
  - Good: "Processing Invoice PDFs", "Analyzing Logs"
  - Avoid: "Invoice Helper", "Log Utils"

### Description Guidelines
- Write in third person
- Include key technology names
- Specify the output or outcome
- Maximum 1024 characters
- Good: "Processes invoice PDFs extracting vendor, date, and line items with validation"
- Avoid: "Helps with invoices"

### Content Guidelines
1. **Be concise**: Only include what Claude doesn't already know
2. **Be specific**: Provide concrete examples and formats
3. **Include validation**: Add verification steps
4. **Progressive disclosure**: For complex topics, reference additional files
5. **Keep under 500 lines**: Move extensive details to reference/ files

### Tool Restrictions (optional)
Uncomment and customize `allowed-tools` if you need to restrict which tools Claude can use:
- Read-only analysis: `[Read, Grep, Glob]`
- File operations: `[Read, Write, Edit, Glob, Grep]`
- Development: `[Read, Write, Edit, Bash, Glob, Grep]`

### Sections to Customize
Required:
- [ ] name (frontmatter)
- [ ] description (frontmatter)
- [ ] Overview
- [ ] Workflow or Instructions
- [ ] At least one Example

Optional (remove if not needed):
- [ ] Prerequisites
- [ ] Expected Output
- [ ] Validation
- [ ] Common Issues
- [ ] Error Handling
- [ ] Advanced Usage
- [ ] References

### File Organization
Simple skill:
```
my-skill/
└── SKILL.md
```

With reference docs:
```
my-skill/
├── SKILL.md
└── reference/
    └── detailed-guide.md
```

With scripts:
```
my-skill/
├── SKILL.md
└── scripts/
    └── helper.py
```

Complete:
```
my-skill/
├── SKILL.md
├── reference/
│   └── docs.md
├── scripts/
│   └── helper.py
└── templates/
    └── output.json
```

### Quick Checklist
Before finalizing:
- [ ] Name uses gerund form
- [ ] Description is specific with key terms
- [ ] Examples are concrete and helpful
- [ ] Validation steps included
- [ ] Under 500 lines
- [ ] No obvious information Claude already knows
- [ ] Tested with real scenario
- [ ] Template notes removed
