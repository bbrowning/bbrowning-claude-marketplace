# Reviewing Claude Skills

Comprehensive guide for reviewing skills for correctness, best practices, adherence to conventions, and effectiveness.

## Review Objectives

When reviewing a skill, assess:
1. **Correctness**: Instructions are accurate and achievable
2. **Discoverability**: Name and description enable Claude to find and use it appropriately
3. **Clarity**: Instructions are unambiguous and specific
4. **Efficiency**: Appropriate use of progressive disclosure and conciseness
5. **Effectiveness**: Skill actually helps Claude accomplish the intended task
6. **Maintainability**: Well-organized and easy to update

## Review Checklist

Use this checklist for systematic skill reviews:

### Frontmatter & Metadata

- [ ] **Name format**: Uses gerund form (verb + -ing)
- [ ] **Name specificity**: Specific and descriptive, not vague
- [ ] **Description length**: Under 1024 characters
- [ ] **Description clarity**: Third person, specific, includes key terms
- [ ] **Description discoverability**: Contains terms that match when skill should be used
- [ ] **Tool restrictions**: `allowed-tools` used appropriately (if needed)
- [ ] **No missing fields**: Required fields present (name, description)

### File Structure

- [ ] **SKILL.md exists**: Primary file is present
- [ ] **Line count**: SKILL.md under 500 lines (excluding reference files)
- [ ] **Reference files**: Used for extended documentation (if needed)
- [ ] **File organization**: Logical structure (reference/, scripts/, templates/)
- [ ] **File naming**: Consistent and clear naming conventions
- [ ] **Templates**: Provide good starting points (if included)
- [ ] **Scripts**: Well-documented with error handling (if included)

### Content Quality

- [ ] **Conciseness**: No obvious information Claude already knows
- [ ] **Specificity**: Clear examples and concrete instructions
- [ ] **Completeness**: All necessary information included
- [ ] **Progressive disclosure**: Details in reference files, essentials in SKILL.md
- [ ] **Examples**: Concrete, helpful examples provided
- [ ] **Validation steps**: How to verify success is documented
- [ ] **Error handling**: Common issues and solutions addressed
- [ ] **Terminology**: Consistent throughout all files

### Instructions

- [ ] **Clarity**: Unambiguous and specific
- [ ] **Actionability**: Each step is actionable
- [ ] **Appropriate freedom**: Right level of specificity for task type
- [ ] **Workflow**: Logical sequence of steps
- [ ] **Prerequisites**: Dependencies and requirements stated
- [ ] **Output format**: Expected outputs clearly defined
- [ ] **Validation**: Verification steps included

### Documentation

- [ ] **No time-sensitive info**: No version numbers or dates that become outdated
- [ ] **Model-focused**: Written for Claude, not humans
- [ ] **No redundancy**: Information not duplicated across files
- [ ] **Clear references**: References to other files are specific and helpful
- [ ] **Up-to-date**: Information is current and accurate

## Detailed Review Guidelines

### 1. Reviewing Name and Description

The name and description determine discoverability. Poor naming means the skill won't be used.

#### Name Review

**Check for gerund form**:
```yaml
# Good
name: Processing Invoice PDFs
name: Generating API Documentation
name: Analyzing Performance Metrics

# Bad (fix these)
name: Invoice Processor
name: API Docs
name: Performance
```

**Check for specificity**:
```yaml
# Good
name: Creating React Components
name: Managing Database Migrations

# Too vague (needs improvement)
name: Helper Functions
name: Utilities
name: Manager
```

**Action**: If name is vague, suggest specific alternative based on what the skill actually does.

#### Description Review

**Check for key terms**:
```yaml
# Good - includes specific technologies and outputs
description: Generates TypeScript React components following project conventions including component structure, PropTypes, styled-components, and comprehensive Jest tests with React Testing Library

# Bad - too vague, missing key terms
description: Helps create components

# Fix needed - add specific technologies and what it produces
```

**Check for third person**:
```yaml
# Good
description: Creates standardized changelog entries from git commits

# Bad (imperative, not third person)
description: Create standardized changelog entries from git commits
```

**Check length**:
```yaml
# If over 1024 characters, needs to be condensed
# Keep key terms, remove unnecessary words
```

**Action**: Rewrite vague descriptions to include:
- Specific action (what it does)
- Key technologies/tools involved
- Output format or result
- Important constraints or validation

### 2. Reviewing File Structure

Good file organization enables maintenance and progressive disclosure.

#### SKILL.md Length

**Check line count**:
```bash
wc -l SKILL.md
```

If over 500 lines:
- Identify content that could move to reference files
- Look for extended examples → `reference/examples.md`
- Look for API documentation → `reference/api-docs.md`
- Look for background information → separate reference file

#### Reference File Organization

**Good structure**:
```
my-skill/
├── SKILL.md                    # Under 500 lines, essential info
├── reference/
│   ├── detailed-guide.md       # Extended documentation
│   └── examples.md             # Many examples
├── scripts/
│   └── helper.py               # Well-documented scripts
└── templates/
    └── output.json             # Clear templates
```

**Issues to flag**:
```
my-skill/
├── SKILL.md                    # 800 lines - TOO LONG
├── stuff/                      # Vague directory name
│   └── things.md               # Vague file name
└── script.py                   # No documentation
```

**Action**: Recommend reorganization with specific suggestions for what to move where.

### 3. Reviewing Instructions

Instructions must be clear, actionable, and appropriately specific.

#### Clarity Check

**Look for ambiguity**:
```markdown
# Ambiguous
Process the files appropriately.

# Clear
Extract the date field from the first line of each file using format YYYY-MM-DD.
```

**Look for missing steps**:
```markdown
# Incomplete
1. Read the data
2. Output results

# Complete
1. Read the data from input.json
2. Validate required fields: id, name, email
3. Transform to output format (see examples below)
4. Write to output.json
5. Verify with validation script
```

#### Degrees of Freedom Check

**Too restrictive** (micromanaging):
```markdown
# Bad - over-specified
1. Open the file
2. Read line 1
3. Store in a variable called 'firstLine'
4. Parse the date from firstLine
5. Store in a variable called 'parsedDate'

# Better - appropriate specificity
Extract the date from the first line using format YYYY-MM-DD.
```

**Too loose** (for fragile operations):
```markdown
# Bad - too vague for database migration
Apply the database migration.

# Better - specific steps for fragile operation
1. Backup database: pg_dump db > backup_$(date +%Y%m%d).sql
2. Run migration: npm run migrate:up
3. Verify schema_version table updated
4. If verification fails, rollback: psql db < backup_TIMESTAMP.sql
```

**Action**: Identify whether freedom level matches task fragility and suggest adjustments.

#### Validation Review

Every skill should include validation steps.

**Missing validation** (needs improvement):
```markdown
## Workflow
1. Parse configuration
2. Apply settings
3. Restart service
```

**Includes validation** (good):
```markdown
## Workflow
1. Parse configuration
2. Validate required fields: host, port, api_key
3. Apply settings
4. Verify service started successfully (check port is listening)
```

**Action**: If validation is missing, suggest specific validation steps appropriate to the task.

### 4. Reviewing Examples

Examples should be concrete and helpful.

#### Example Quality

**Poor example** (too abstract):
```markdown
Extract the data appropriately.
```

**Good example** (concrete):
```markdown
Extract dates to ISO 8601 format:
- Input: "Jan 15, 2024" → Output: "2024-01-15"
- Input: "3/7/24" → Output: "2024-03-07"
- Input: "2024-12-25" → Output: "2024-12-25" (already correct)
```

#### Example Coverage

Check that examples cover:
- [ ] Basic/common case
- [ ] Edge cases (if applicable)
- [ ] Input → Output transformations
- [ ] Expected formats

**Action**: If examples are missing or too abstract, suggest concrete examples based on the skill's purpose.

### 5. Reviewing Progressive Disclosure

Skills should start concise and reference detailed docs as needed.

#### Good Progressive Disclosure

```markdown
# SKILL.md (concise)
## Workflow
1. Extract API information from JSDoc comments
2. Generate OpenAPI 3.0 specification
3. Validate against schema

For detailed JSDoc patterns, see `reference/jsdoc-patterns.md`.
For complete OpenAPI specification reference, see `reference/openapi-spec.md`.

# reference/jsdoc-patterns.md (detailed)
[200+ lines of JSDoc patterns and examples]

# reference/openapi-spec.md (detailed)
[300+ lines of OpenAPI documentation]
```

#### Poor Progressive Disclosure

```markdown
# SKILL.md (monolithic - 800 lines)
[Everything crammed into one file]
[200 lines of background]
[300 lines of detailed API docs]
[300 lines of examples]
```

**Action**: Identify sections that should move to reference files and suggest the organization.

### 6. Reviewing Tool Restrictions

Tool restrictions should be intentional and appropriate.

#### When Tool Restrictions Are Appropriate

**Read-only analysis**:
```yaml
allowed-tools: [Read, Grep, Glob]
```
✅ Good for security audits, code analysis, reporting

**File operations without execution**:
```yaml
allowed-tools: [Read, Write, Edit, Glob, Grep]
```
✅ Good for file transformations, code generation

**Safety-critical workflows**:
```yaml
allowed-tools: [Read, Bash]  # Only run specific scripts
```
✅ Good for database migrations with pre-built scripts

#### Issues to Flag

**Over-restricted**:
```yaml
allowed-tools: [Read]
```
❌ Too restrictive - Claude can't be effective with only Read

**Unnecessary restrictions**:
```yaml
# For a component generator that needs to write files
allowed-tools: [Read, Grep]
```
❌ Missing necessary tools (Write, Edit)

**Action**: Verify tool restrictions match the skill's purpose and suggest adjustments.

### 7. Reviewing Scripts

Scripts should be well-documented and robust.

#### Script Documentation

**Poor documentation**:
```python
#!/usr/bin/env python3
import sys
import json

def main():
    data = json.load(open(sys.argv[1]))
    # ... processing ...
```

**Good documentation**:
```python
#!/usr/bin/env python3
"""
Validates invoice JSON output.

Usage:
    python validate-output.py invoice.json

Exit codes:
    0: Valid
    1: Validation errors
    2: File not found
"""
import sys
import json

def main():
    if len(sys.argv) != 2:
        print("Usage: validate-output.py invoice.json", file=sys.stderr)
        sys.exit(1)
    # ... processing with error handling ...
```

#### Script Error Handling

Check for:
- [ ] Argument validation
- [ ] Clear error messages
- [ ] Appropriate exit codes
- [ ] File handling errors
- [ ] Input validation

**Action**: Note missing error handling and documentation issues.

### 8. Reviewing Content Quality

#### Conciseness Check

**Over-explained** (Claude already knows this):
```markdown
The Read tool is a powerful capability that allows you to read files
from the filesystem. You should use it when you need to access file
contents. Files are stored on disk and contain data...
```

**Concise** (appropriate):
```markdown
Read the configuration file and extract database settings.
```

**Action**: Flag over-explained content that Claude already knows.

#### Time-Sensitive Information

**Avoid**:
```markdown
Use the new React hooks API introduced in version 16.8 (2019)
```

**Better**:
```markdown
Use React hooks for state management
```

**Action**: Flag time-sensitive references that will become outdated.

#### Terminology Consistency

**Inconsistent** (confusing):
```markdown
1. Parse the document
2. Extract data from the file
3. Process the input
4. Transform the content
```

**Consistent** (clear):
```markdown
1. Parse the document
2. Extract data from the document
3. Validate the document
4. Transform the document
```

**Action**: Note terminology inconsistencies and suggest consistent terms.

## Common Review Findings

### Critical Issues (Must Fix)

1. **Missing or vague description**: Skill won't be discovered
2. **No validation steps**: No way to verify success
3. **Ambiguous instructions**: Claude won't know what to do
4. **Over 500 lines in SKILL.md**: Needs progressive disclosure
5. **Broken references**: References to non-existent files
6. **Scripts without error handling**: Will fail ungracefully

### Important Issues (Should Fix)

1. **Vague examples**: Replace with concrete examples
2. **Inappropriate freedom level**: Too restrictive or too loose
3. **Missing edge cases**: Common issues not addressed
4. **Poor file organization**: Unclear structure
5. **Time-sensitive information**: Will become outdated
6. **Inconsistent terminology**: Confusing

### Minor Issues (Nice to Fix)

1. **Could be more concise**: Some unnecessary verbosity
2. **Could use better examples**: Examples work but could be clearer
3. **Minor naming improvements**: Name is okay but could be more specific
4. **Documentation could be clearer**: Functional but could improve

## Review Process

### Step-by-Step Review

1. **Initial scan**
   - Read frontmatter
   - Check file structure
   - Note line count

2. **Name & description review**
   - Check gerund form
   - Assess specificity
   - Verify key terms present
   - Test mental model: "Would Claude find this when needed?"

3. **Structure review**
   - Check SKILL.md length
   - Review file organization
   - Assess progressive disclosure
   - Verify references are valid

4. **Content review**
   - Read through instructions
   - Check for clarity and specificity
   - Verify examples are concrete
   - Assess degrees of freedom
   - Look for validation steps

5. **Technical review**
   - Review tool restrictions (if any)
   - Check scripts (if any)
   - Verify templates (if any)
   - Test any examples

6. **Quality review**
   - Check for over-explanation
   - Look for time-sensitive info
   - Verify terminology consistency
   - Assess overall effectiveness

### Writing Review Feedback

Structure feedback as:

```markdown
## Skill Review: [Skill Name]

### Critical Issues
- [Issue 1 with specific location]
- [Issue 2 with specific location]

### Important Issues
- [Issue 1 with suggestion]
- [Issue 2 with suggestion]

### Suggestions
- [Optional improvement 1]
- [Optional improvement 2]

### Strengths
- [What works well]
- [Good patterns to maintain]

### Overall Assessment
[Brief summary and recommendation: Approve / Needs revision / Major rework needed]
```

## Example Reviews

### Example 1: Skill with Issues

**SKILL.md**:
```yaml
---
name: Helper
description: Helps with stuff
---

# Helper

This skill helps you process things.

## Instructions

1. Read the files
2. Do the processing
3. Output results
```

**Review**:
```markdown
## Skill Review: Helper

### Critical Issues
- **Vague name**: "Helper" doesn't indicate what the skill does. Change to gerund form describing the specific task (e.g., "Processing Invoice Data", "Generating Reports")
- **Non-descriptive description**: "Helps with stuff" provides no discoverability. Should specify what is being processed, input format, output format, and key technologies
- **Ambiguous instructions**: Steps 1-3 are too vague. What files? What processing? What output format?

### Important Issues
- **No validation**: No way to verify the output is correct
- **No examples**: No concrete examples of input → output
- **Missing specifics**: No file formats, no output structure, no error handling

### Suggestions
- Add concrete examples showing expected inputs and outputs
- Define specific file formats and output structure
- Include validation steps
- Consider what Claude doesn't already know and focus on that

### Overall Assessment
Major rework needed. The skill needs a complete rewrite with specific name, detailed description, clear instructions, and concrete examples.
```

### Example 2: Good Skill

**SKILL.md**:
```yaml
---
name: Generating Changelog Entries
description: Creates standardized changelog entries from git commits following Keep a Changelog format with semantic versioning categories
---

# Generating Changelog Entries

Creates changelog entries in Keep a Changelog format from git commit history.

## Workflow

1. Review git commits since last release
2. Categorize commits:
   - **Added**: New features
   - **Changed**: Changes to existing functionality
   - **Fixed**: Bug fixes
3. Format as markdown under appropriate headings
4. Include commit hashes as references

## Output Format

\`\`\`markdown
## [Version] - YYYY-MM-DD

### Added
- New feature description [abc123]

### Fixed
- Bug fix description [def456]
\`\`\`

## Validation

Ensure:
- All commits are categorized
- Date is in YYYY-MM-DD format
- Version follows semantic versioning
- Each entry includes commit hash
```

**Review**:
```markdown
## Skill Review: Generating Changelog Entries

### Strengths
- **Clear name**: Gerund form, specific task
- **Excellent description**: Specific format (Keep a Changelog), includes key terms (semantic versioning, categories)
- **Concrete workflow**: Clear categorization with examples
- **Output format**: Specific format with example
- **Validation included**: Clear checklist for verification
- **Appropriate length**: Concise, focused, under 500 lines

### Suggestions
- Consider adding an example section showing sample commits → output transformation
- Could mention how to handle commits that don't fit standard categories (e.g., docs, chores)

### Overall Assessment
Excellent skill. Follows all best practices. Ready to use. The minor suggestions are optional enhancements.
```

## Reviewing Your Own Skills

Self-review checklist:

1. **Wait before reviewing**: Review skills after a break, not immediately after writing
2. **Test with Claude**: Actually use the skill and see if it works as intended
3. **Check against checklist**: Use the complete review checklist above
4. **Read aloud**: Unclear writing becomes obvious when read aloud
5. **Compare to examples**: Does it match the quality of the example skills?
6. **Ask key questions**:
   - Would Claude find this skill when needed?
   - Are the instructions clear enough to follow?
   - Is there enough information but not too much?
   - Can success be verified?

## Review Anti-Patterns

Avoid these when reviewing:

### Anti-Pattern 1: Accepting Vague Descriptions

```yaml
# Don't accept this
description: Utility for processing data

# Require this level of specificity
description: Transforms CSV sales data to quarterly JSON reports with revenue calculations and trend analysis
```

### Anti-Pattern 2: Overlooking Missing Validation

Every skill needs validation steps. Don't approve skills without them.

### Anti-Pattern 3: Accepting Monolithic Skills

Skills over 500 lines need progressive disclosure. Don't accept:
```
skill/
└── SKILL.md (800 lines)
```

Require:
```
skill/
├── SKILL.md (200 lines)
└── reference/
    └── detailed-guide.md (600 lines)
```

### Anti-Pattern 4: Ignoring Ambiguity

Don't overlook vague instructions like "Process appropriately" or "Handle correctly". Require specificity.

### Anti-Pattern 5: Skipping Real-World Testing

Don't approve skills based only on reading. Test them with Claude on actual tasks.

## Quick Review Reference

Use this quick reference during reviews:

**Name**: Gerund form? Specific? ✓
**Description**: Under 1024 chars? Key terms? Third person? ✓
**Length**: SKILL.md under 500 lines? ✓
**Examples**: Concrete? Helpful? ✓
**Validation**: Steps included? ✓
**Clarity**: Unambiguous? Actionable? ✓
**Freedom**: Appropriate for task type? ✓
**Organization**: Logical structure? ✓
**Scripts**: Documented? Error handling? ✓
**References**: Valid? Clear purpose? ✓

## Conclusion

Effective skill review ensures:
- Skills are discoverable when needed
- Instructions are clear and actionable
- Examples are concrete and helpful
- Validation steps ensure correctness
- Organization supports maintainability
- Content is concise and focused

Use this guide systematically to review skills and provide constructive, specific feedback that improves skill quality.
