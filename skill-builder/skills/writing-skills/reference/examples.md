# Skill Examples

Real-world examples of well-crafted skills demonstrating best practices.

## Example 1: Simple Focused Skill

A single-purpose skill with everything in SKILL.md.

### Directory Structure
```
changelog-generator/
└── SKILL.md
```

### SKILL.md
```markdown
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
   - **Deprecated**: Soon-to-be removed features
   - **Removed**: Removed features
   - **Fixed**: Bug fixes
   - **Security**: Security improvements
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

## Examples

### Input Commits
```
abc123 feat: Add user authentication
def456 fix: Resolve login timeout issue
ghi789 docs: Update README
```

### Output
```markdown
## [1.2.0] - 2024-01-15

### Added
- User authentication system [abc123]

### Fixed
- Login timeout issue [def456]
```

## Validation

Ensure:
- All commits are categorized
- Date is in YYYY-MM-DD format
- Version follows semantic versioning
- Each entry includes commit hash
```

**Why this works**:
- Focused on one task
- Clear categorization
- Specific format
- Concrete example
- Validation checklist

## Example 2: Skill with Reference Documentation

A skill using progressive disclosure for complex information.

### Directory Structure
```
api-doc-generator/
├── SKILL.md
└── reference/
    ├── jsdoc-patterns.md
    └── openapi-spec.md
```

### SKILL.md
```markdown
---
name: Generating API Documentation
description: Creates comprehensive API documentation from JSDoc comments including endpoints, parameters, responses, and examples in OpenAPI 3.0 format
---

# Generating API Documentation

Generates API documentation in OpenAPI 3.0 format from JSDoc-annotated code.

## Overview

Extracts API information from JSDoc comments and produces OpenAPI specification with:
- Endpoint descriptions
- Request/response schemas
- Authentication requirements
- Example payloads

## Workflow

1. Scan codebase for JSDoc-annotated API endpoints
2. Extract route, method, parameters, responses
3. Generate OpenAPI schema definitions
4. Create example requests/responses
5. Validate against OpenAPI 3.0 specification

## JSDoc Pattern

Expected JSDoc format:
\`\`\`javascript
/**
 * @api {get} /users/:id Get User
 * @apiParam {String} id User ID
 * @apiSuccess {Object} user User object
 * @apiSuccess {String} user.name User name
 */
\`\`\`

For detailed JSDoc patterns, see `reference/jsdoc-patterns.md`.

## Output Format

Generate OpenAPI 3.0 YAML. For complete specification reference, see `reference/openapi-spec.md`.

Basic structure:
\`\`\`yaml
openapi: 3.0.0
info:
  title: API Name
  version: 1.0.0
paths:
  /users/{id}:
    get:
      summary: Get User
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
\`\`\`

## Validation

1. Validate YAML syntax
2. Verify against OpenAPI 3.0 schema
3. Ensure all referenced schemas are defined
4. Check examples match schema definitions
```

### reference/jsdoc-patterns.md
```markdown
# JSDoc Patterns for API Documentation

Complete reference for supported JSDoc annotations.

## Basic Endpoint

\`\`\`javascript
/**
 * @api {method} /path Description
 * @apiName UniqueName
 * @apiGroup GroupName
 */
\`\`\`

## Parameters

[... detailed parameter documentation ...]

## Responses

[... detailed response documentation ...]

## Examples

[... 20+ examples of different patterns ...]
```

**Why this works**:
- Core workflow in SKILL.md
- Extended details in reference files
- Clear references to additional docs
- Progressive disclosure

## Example 3: Skill with Scripts

A skill using deterministic scripts for validation.

### Directory Structure
```
invoice-processor/
├── SKILL.md
├── scripts/
│   ├── extract-data.py
│   └── validate-output.py
└── templates/
    └── invoice-output.json
```

### SKILL.md
```markdown
---
name: Processing Invoice PDFs
description: Extracts structured data from invoice PDFs including vendor, date, line items, and totals with validation against expected schema
---

# Processing Invoice PDFs

Extracts and validates invoice data from PDF files.

## Workflow

1. Use `scripts/extract-data.py` to extract text from PDF
2. Parse extracted text for key fields:
   - Vendor name
   - Invoice number
   - Date (YYYY-MM-DD)
   - Line items (description, quantity, unit price, total)
   - Subtotal, tax, total
3. Structure as JSON matching `templates/invoice-output.json`
4. Validate using `scripts/validate-output.py`

## Extraction Script

\`\`\`bash
python scripts/extract-data.py input.pdf output.txt
\`\`\`

Outputs raw text from PDF for parsing.

## Output Format

Follow the schema in `templates/invoice-output.json`:

\`\`\`json
{
  "vendor": "Company Name",
  "invoice_number": "INV-001",
  "date": "2024-01-15",
  "line_items": [
    {
      "description": "Item description",
      "quantity": 2,
      "unit_price": 50.00,
      "total": 100.00
    }
  ],
  "subtotal": 100.00,
  "tax": 8.00,
  "total": 108.00
}
\`\`\`

## Validation

Run validation script:
\`\`\`bash
python scripts/validate-output.py output.json
\`\`\`

Validates:
- All required fields present
- Date format is YYYY-MM-DD
- Calculations are correct (line totals, subtotal, tax, total)
- Numbers are properly formatted

Exit code 0 = valid, 1 = validation errors (prints details).

## Error Handling

If extraction fails:
1. Check PDF is not password-protected
2. Verify PDF contains text (not scanned image)
3. Review raw extracted text for parsing issues
```

### scripts/validate-output.py
```python
#!/usr/bin/env python3
"""
Validates invoice JSON output.

Usage:
    python validate-output.py invoice.json

Exit codes:
    0: Valid
    1: Validation errors
"""
import sys
import json
from datetime import datetime

def validate_invoice(data):
    errors = []

    # Required fields
    required = ['vendor', 'invoice_number', 'date', 'line_items', 'total']
    for field in required:
        if field not in data:
            errors.append(f"Missing required field: {field}")

    # Date format
    try:
        datetime.strptime(data['date'], '%Y-%m-%d')
    except ValueError:
        errors.append(f"Invalid date format: {data['date']}")

    # Calculate totals
    calculated_total = sum(item['total'] for item in data['line_items'])
    if abs(calculated_total - data['subtotal']) > 0.01:
        errors.append(f"Subtotal mismatch: {data['subtotal']} != {calculated_total}")

    return errors

def main():
    if len(sys.argv) != 2:
        print("Usage: validate-output.py invoice.json", file=sys.stderr)
        sys.exit(1)

    with open(sys.argv[1]) as f:
        data = json.load(f)

    errors = validate_invoice(data)

    if errors:
        print("Validation errors:", file=sys.stderr)
        for error in errors:
            print(f"  - {error}", file=sys.stderr)
        sys.exit(1)

    print("Validation successful")
    sys.exit(0)

if __name__ == "__main__":
    main()
```

**Why this works**:
- Scripts handle deterministic operations
- Clear script usage documentation
- Template provides expected format
- Validation ensures correctness
- Error handling guidance

## Example 4: Tool-Restricted Skill

A skill with restricted tool access for safety.

### Directory Structure
```
security-audit/
└── SKILL.md
```

### SKILL.md
```markdown
---
name: Auditing Security Configurations
description: Reviews configuration files for security vulnerabilities including exposed secrets, weak permissions, and insecure defaults without modifying any files
allowed-tools: [Read, Grep, Glob]
---

# Auditing Security Configurations

Performs read-only security audit of configuration files.

## Tool Restrictions

This skill is read-only. Only these tools are available:
- Read: Read files
- Grep: Search for patterns
- Glob: Find files

This ensures no accidental modifications during security audit.

## Audit Checklist

### 1. Secrets Exposure
Search for potential secrets:
\`\`\`bash
grep -r "api_key\|password\|secret\|token" .
\`\`\`

Check for:
- Hardcoded passwords
- API keys in code
- Exposed tokens
- Committed .env files

### 2. File Permissions
Review files that should have restricted permissions:
- Private keys (.pem, .key)
- Configuration files with secrets
- Database credentials

### 3. Insecure Defaults
Check configurations for:
- Debug mode enabled in production
- CORS set to allow all origins
- Disabled authentication
- Exposed admin interfaces

## Output Format

Generate markdown report:

\`\`\`markdown
# Security Audit Report

## Critical Issues
- [Issue description] - [File:Line]

## Warnings
- [Issue description] - [File:Line]

## Recommendations
1. [Recommendation]
2. [Recommendation]
\`\`\`

## Examples

### Finding: Exposed Secret
\`\`\`
## Critical Issues
- Hardcoded API key in source code - config/api.js:12
  \`\`\`
  const API_KEY = "sk_live_abc123xyz"
  \`\`\`
  Recommendation: Move to environment variable
```

**Why this works**:
- Tool restrictions prevent modifications
- Clear audit methodology
- Structured output format
- Safety-critical workflow

## Example 5: Complex Multi-File Skill

A comprehensive skill with full progressive disclosure.

### Directory Structure
```
react-component-generator/
├── SKILL.md
├── reference/
│   ├── typescript-patterns.md
│   ├── testing-guide.md
│   └── styling-conventions.md
├── scripts/
│   └── validate-component.sh
└── templates/
    ├── component.tsx
    ├── component.test.tsx
    └── component.styles.ts
```

### SKILL.md
```markdown
---
name: Creating React Components
description: Generates TypeScript React components following project conventions including component structure, PropTypes, styled-components, and comprehensive Jest tests with React Testing Library
---

# Creating React Components

Generates production-ready React components with TypeScript, tests, and styles.

## Overview

Creates a complete React component with:
- TypeScript component file
- Styled-components styling
- Jest + React Testing Library tests
- Prop validation
- JSDoc documentation

## Workflow

1. Create component file using `templates/component.tsx` as base
2. Define TypeScript interface for props
3. Implement component logic
4. Create styled-components in `templates/component.styles.ts` pattern
5. Write tests following `templates/component.test.tsx`
6. Validate with `scripts/validate-component.sh`

## Component Structure

See `templates/component.tsx` for complete structure. Key elements:

\`\`\`typescript
interface ComponentProps {
  // Props with JSDoc
}

export const Component: React.FC<ComponentProps> = ({ props }) => {
  // Implementation
}
\`\`\`

## TypeScript Patterns

For TypeScript best practices, see `reference/typescript-patterns.md`.

Key patterns:
- Use interfaces for props
- Avoid 'any' type
- Leverage union types for variants
- Use generics for reusable components

## Styling

Follow styled-components patterns in `reference/styling-conventions.md`.

Basic pattern from `templates/component.styles.ts`:
\`\`\`typescript
import styled from 'styled-components'

export const Container = styled.div\`
  // Styles
\`
\`\`\`

## Testing

Follow testing guide in `reference/testing-guide.md`.

Use template from `templates/component.test.tsx`:
- Test rendering
- Test interactions
- Test edge cases
- Test accessibility

## Validation

Run validation:
\`\`\`bash
./scripts/validate-component.sh src/components/MyComponent
\`\`\`

Checks:
- TypeScript compiles
- Tests pass
- Linting passes
- No console errors

## File Naming

\`\`\`
src/components/MyComponent/
├── MyComponent.tsx
├── MyComponent.test.tsx
├── MyComponent.styles.ts
└── index.ts
\`\`\`
```

### reference/typescript-patterns.md
```markdown
# TypeScript Patterns for React Components

[Detailed TypeScript patterns, 200+ lines]
```

### reference/testing-guide.md
```markdown
# Testing Guide for React Components

[Comprehensive testing patterns, 300+ lines]
```

### reference/styling-conventions.md
```markdown
# Styling Conventions with styled-components

[Detailed styling patterns, 150+ lines]
```

### templates/component.tsx
```typescript
import React from 'react'
import { Container } from './ComponentName.styles'

interface ComponentNameProps {
  /**
   * Description of prop
   */
  propName: string
}

/**
 * ComponentName description
 *
 * @example
 * <ComponentName propName="value" />
 */
export const ComponentName: React.FC<ComponentNameProps> = ({
  propName
}) => {
  return (
    <Container>
      {propName}
    </Container>
  )
}
```

**Why this works**:
- Concise SKILL.md (under 500 lines)
- Progressive disclosure to reference docs
- Templates provide starting points
- Validation script ensures quality
- Clear file organization

## Example 6: Workflow-Driven Skill

A skill focused on a multi-step workflow with validation.

### Directory Structure
```
database-migration/
└── SKILL.md
```

### SKILL.md
```markdown
---
name: Managing Database Migrations
description: Creates and applies database migrations with automated backup, validation, and rollback capabilities for PostgreSQL using Prisma
allowed-tools: [Read, Write, Bash, Grep, Glob]
---

# Managing Database Migrations

Safe database migration workflow with backup and rollback.

## Prerequisites

- Prisma CLI installed
- Database connection configured
- Write access to database

## Migration Workflow

### Creating a Migration

1. **Backup current schema**
   \`\`\`bash
   pg_dump -s database_name > backups/schema_$(date +%Y%m%d_%H%M%S).sql
   \`\`\`

2. **Create migration**
   \`\`\`bash
   npx prisma migrate dev --name migration_name
   \`\`\`

3. **Review generated SQL**
   - Check migration file in `prisma/migrations/`
   - Verify no unexpected changes
   - Ensure data integrity preserved

4. **Validate migration**
   - Test on local database first
   - Verify data not corrupted
   - Check application still works

### Applying to Production

1. **Create production backup**
   \`\`\`bash
   pg_dump database_name > backups/prod_backup_$(date +%Y%m%d_%H%M%S).sql
   \`\`\`

2. **Run migration**
   \`\`\`bash
   npx prisma migrate deploy
   \`\`\`

3. **Verify migration applied**
   \`\`\`bash
   npx prisma migrate status
   \`\`\`

4. **Validate data integrity**
   - Run integrity checks
   - Verify critical queries still work
   - Check row counts match expectations

### Rollback Procedure

If migration fails:

1. **Stop application** (prevent writes)

2. **Restore from backup**
   \`\`\`bash
   psql database_name < backups/prod_backup_TIMESTAMP.sql
   \`\`\`

3. **Verify restoration**
   - Check row counts
   - Run test queries
   - Verify application works

4. **Investigate failure**
   - Review migration SQL
   - Check error logs
   - Fix issue before retrying

## Safety Checklist

Before applying migration:
- [ ] Local backup created
- [ ] Migration tested on development database
- [ ] Migration SQL reviewed
- [ ] Production backup created
- [ ] Rollback procedure documented
- [ ] Maintenance window scheduled (if needed)

## Validation Queries

After migration, verify:

\`\`\`sql
-- Check table exists
SELECT EXISTS (
  SELECT FROM information_schema.tables
  WHERE table_name = 'table_name'
);

-- Verify row counts
SELECT COUNT(*) FROM critical_table;

-- Test critical queries
SELECT * FROM users WHERE id = 1;
\`\`\`

## Common Issues

### Issue: Migration fails mid-apply
**Solution**: Restore from backup, fix migration, retry

### Issue: Data type mismatch
**Solution**: Add explicit type conversion in migration

### Issue: Foreign key constraint violation
**Solution**: Ensure related data exists or use ON DELETE CASCADE

## Examples

### Example 1: Adding a Column
\`\`\`sql
ALTER TABLE users ADD COLUMN email_verified BOOLEAN DEFAULT false;
\`\`\`

### Example 2: Creating a Table
\`\`\`sql
CREATE TABLE audit_logs (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  action VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW()
);
\`\`\`
```

**Why this works**:
- Clear step-by-step workflow
- Safety measures at each step
- Validation checkpoints
- Rollback procedure
- Tool restrictions for safety
- Common issues documented

## Key Takeaways from Examples

1. **Simple skills**: Everything in SKILL.md, focused on one task
2. **Reference-based skills**: Core in SKILL.md, details in reference/
3. **Scripted skills**: Use scripts for deterministic operations
4. **Tool-restricted skills**: Limit tools for safety-critical tasks
5. **Complex skills**: Full progressive disclosure with templates
6. **Workflow skills**: Step-by-step with validation and rollback

Each example demonstrates:
- Clear, specific descriptions
- Concrete examples
- Validation steps
- Appropriate level of detail
- Progressive disclosure when needed
- Focused purpose

Use these patterns as starting points for your own skills.
