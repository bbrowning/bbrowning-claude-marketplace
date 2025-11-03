# Severity Classification Guide

Use this guide to consistently categorize findings during PR reviews. Each finding should be classified by severity to help prioritize fixes.

## Severity Levels

### Critical

**Definition**: Issues that MUST be fixed before merge. These pose immediate risks or cause serious problems.

**When to use**:
- Security vulnerabilities (SQL injection, XSS, exposed secrets)
- Data loss or corruption risks
- Breaking changes to public APIs without proper deprecation
- Code that will crash in production
- Severe performance issues (timeouts, memory leaks)
- Introduces legal/compliance violations

**Examples**:
- Hardcoded API key in source code
- SQL query vulnerable to injection
- Deleting data without transaction protection
- Breaking change to widely-used API
- Memory leak that grows unbounded
- Removing authentication check
- **GitHub Actions workflow using `pull_request_target` + checkout of untrusted code + `id-token: write`**
- **CI/CD workflow that exposes secrets or OIDC tokens to untrusted code**

**Characteristics**:
- Blocks merge
- Requires immediate fix
- Has production impact
- No workarounds available

### High

**Definition**: Significant issues that should be fixed before merge. These cause problems but may have temporary workarounds.

**When to use**:
- Logic bugs that affect core functionality
- Missing error handling for likely errors
- Incomplete implementations
- Missing critical tests
- Performance issues that impact user experience
- Incorrect algorithm or approach

**Examples**:
- Function returns wrong result for valid input
- No error handling for network call
- Feature incomplete (half-implemented)
- No tests for new API endpoint
- O(n²) algorithm where O(n) is possible
- Race condition in concurrent code

**Characteristics**:
- Should block merge
- Affects functionality
- May have workarounds
- Needs addressing before release

### Medium

**Definition**: Issues that should be addressed but don't block merge. These affect code quality, maintainability, or minor functionality.

**When to use**:
- Code quality issues
- Missing edge case handling
- Suboptimal implementations
- Insufficient test coverage
- Documentation gaps
- Minor design issues

**Examples**:
- Function is too complex and hard to read
- Doesn't handle empty array case
- Using map where set would be better
- No tests for error paths
- Missing docstring for public function
- Repeated code that should be extracted

**Characteristics**:
- Doesn't block merge
- Affects maintainability
- Should be addressed soon
- Follow-up PR acceptable

### Low

**Definition**: Suggestions and minor improvements. Nice to have but not required.

**When to use**:
- Style preferences
- Minor optimizations
- Suggestions for future improvements
- Naming suggestions
- Comment improvements
- Non-critical refactoring ideas

**Examples**:
- Variable could have more descriptive name
- Could use newer language feature
- Comment could be more detailed
- Alternative approach suggestion
- Formatting inconsistency
- Typo in comment

**Characteristics**:
- Doesn't block merge
- Optional improvements
- Personal preference
- Future enhancement ideas

## Classification Decision Tree

Use this flowchart to determine severity:

```
Does this create a security risk or data loss?
├─ YES → Critical
└─ NO ↓

Does this cause incorrect behavior or crashes?
├─ YES → High
└─ NO ↓

Does this impact code quality or maintainability significantly?
├─ YES → Medium
└─ NO ↓

Is this a suggestion or minor improvement?
└─ YES → Low
```

## Context Matters

The same issue can have different severities based on context:

### Example: Missing Error Handling

**Critical**: Payment processing endpoint
- Could lose money or charge incorrectly
- No recovery mechanism

**High**: User data fetch
- Core functionality broken
- Error affects user experience

**Medium**: Analytics tracking
- Non-critical feature
- Failure is acceptable

**Low**: Debug logging
- Optional feature
- No impact on users

### Example: Performance Issue

**Critical**: Database query on high-traffic endpoint
- Causes timeouts under load
- Affects all users

**High**: Slow algorithm in user-facing feature
- Noticeable delay (>1s)
- Frequent operation

**Medium**: Inefficient background job
- Runs occasionally
- Has time budget

**Low**: Inefficiency in dev tooling
- Rarely executed
- Minimal impact

## Borderline Cases

When a finding could fit multiple categories:

### Between Critical and High
Ask: Will this definitely cause production issues?
- Definitely → Critical
- Probably → High

### Between High and Medium
Ask: Does this affect core functionality?
- Yes → High
- No → Medium

### Between Medium and Low
Ask: Does this impact maintainability significantly?
- Yes → Medium
- No → Low

## Special Considerations

### Breaking Changes
- With migration path + deprecation → High
- Without migration path → Critical

### Test Issues
- No tests for new API → High
- Incomplete test coverage → Medium
- Test quality issues → Low

### Documentation
- Missing docs for public API → Medium
- Incomplete docs → Low
- Typos in docs → Low

### Dependencies
- Vulnerable dependency → Critical
- Unnecessary dependency → Medium
- Outdated but safe dependency → Low

## Communicating Severity

### Critical
- Start with "CRITICAL:" or use strong language
- Explain the immediate risk
- Mark as blocking

**Example**:
> CRITICAL: This SQL query is vulnerable to injection. An attacker could access all user data. Must use parameterized queries.

### High
- Clearly state it should block merge
- Explain the problem and impact
- Suggest fix

**Example**:
> This function will crash when users.length is 0 (see line 42). This should be fixed before merge. Suggest adding a length check or using optional chaining.

### Medium
- Explain why it matters
- Can be more conversational
- OK to suggest follow-up

**Example**:
> This function is quite complex and hard to follow. Consider extracting the validation logic into a separate function. Could be addressed in a follow-up PR if needed.

### Low
- Use softer language ("consider", "might", "could")
- Make it clear it's optional
- Can combine multiple low items

**Example**:
> Minor: Consider renaming `data` to `userData` for clarity. Also, the comment on line 15 has a typo.

## Repository-Specific Severity Adjustments

Some repositories may have custom severity criteria. Add repository-specific rules below:

### High-Security Projects
- Elevate any security issue to Critical
- Stricter criteria for code quality

### Fast-Moving Startups
- May accept more Medium issues
- Focus on Critical/High

### Library/Framework Projects
- Breaking changes are always Critical
- Backward compatibility very important
- Documentation gaps elevated

### Internal Tools
- Can be more lenient overall
- Security still Critical
- User experience less critical

## Review Your Classifications

Before finalizing, check:
- [ ] Each finding has appropriate severity
- [ ] Critical items are truly blocking
- [ ] Low items are clearly optional
- [ ] Severity is justified in the comment
- [ ] Context is considered

Remember: The goal is to help prioritize fixes, not to be overly critical. When in doubt, err on the side of being helpful rather than strict.
