# Pull Request Review: [PR Title]

**PR**: [org/repo#number]
**Author**: [author]
**Reviewed**: [date]
**Reviewers**: Claude Code PR Review

---

## Executive Summary

[1-3 sentence summary of the PR and overall assessment]

**Recommendation**: [Approve / Request Changes / Needs Discussion]

**Statistics**:
- Files changed: [count]
- Lines added: [+count]
- Lines removed: [-count]
- Commits: [count]

---

## Unaddressed Comments

[If there are unaddressed review comments from other reviewers, list them here with context]

### Comment from [reviewer] on [file:line]
> [Quote the comment]

**Status**: Unaddressed - [No response / No code changes / Needs clarification]

[Repeat for each unaddressed comment]

[If no unaddressed comments: "No unaddressed comments from other reviewers."]

---

## Critical Findings

[Issues that MUST be fixed before merge]

### [Title of Issue]
**Location**: `[file:line]`
**Severity**: Critical

**Issue**:
[Clear description of what's wrong]

**Impact**:
[Why this is critical - security risk, data loss, breaking change, etc.]

**Recommendation**:
[How to fix it - be specific]

**Example**:
```[language]
[Show problematic code if helpful]
```

[Repeat for each critical finding]

[If no critical findings: "No critical issues found."]

---

## High Priority Findings

[Significant issues that should be fixed before merge]

### [Title of Issue]
**Location**: `[file:line]`
**Severity**: High

**Issue**:
[What's wrong]

**Impact**:
[Why this matters]

**Recommendation**:
[How to fix it]

[Repeat for each high priority finding]

[If no high priority findings: "No high priority issues found."]

---

## Medium Priority Findings

[Issues that should be addressed but don't block merge]

### [Title of Issue]
**Location**: `[file:line]`
**Severity**: Medium

**Issue**:
[What could be improved]

**Impact**:
[Why this matters for code quality/maintainability]

**Recommendation**:
[Suggested improvements]

[Repeat for each medium finding]

[If no medium findings: "No medium priority issues found."]

---

## Low Priority Findings

[Suggestions and minor improvements]

### [Title of Issue]
**Location**: `[file:line]`
**Severity**: Low

**Suggestion**:
[Optional improvement or style suggestion]

[Can group multiple low-severity items together]

[If no low findings: "No low priority suggestions."]

---

## Positive Observations

[Highlight what's done well - this is important for constructive reviews!]

- [Something done well]
- [Good pattern or approach]
- [Excellent test coverage]
- [Clear documentation]
- [etc.]

---

## Testing Assessment

**Test Coverage**: [Excellent / Good / Adequate / Insufficient / None]

**Findings**:
- [Assessment of test quality and coverage]
- [Are tests sufficient for the changes?]
- [Edge cases covered?]
- [Test quality adequate?]

---

## Documentation Assessment

**Documentation**: [Complete / Adequate / Incomplete / None]

**Findings**:
- [Are docs updated for user-facing changes?]
- [API documentation adequate?]
- [Code comments where needed?]
- [Breaking changes documented?]

---

## Backward Compatibility Assessment

**Compatibility**: [Fully Compatible / Compatible with Deprecation / Breaking Changes]

**Findings**:
- [API changes analysis]
- [Database migration safety]
- [Configuration compatibility]
- [Deprecation handling]

[If breaking changes:]
**Breaking Changes**:
- [List each breaking change]
- [Justification for breaking change]
- [Migration path provided?]

---

## Performance Considerations

**Performance Impact**: [Positive / Neutral / Negative / Needs Investigation]

**Findings**:
- [Any performance improvements or regressions]
- [Algorithm efficiency]
- [Database query optimization]
- [Resource usage]

---

## Security Assessment

**Security**: [No Issues / Minor Concerns / Significant Issues]

**Findings**:
- [Input validation adequate?]
- [Authentication/authorization correct?]
- [No exposed secrets?]
- [Dependencies safe?]

---

## Detailed Review Notes

[Optional section for additional context, questions, or detailed analysis]

### [File Name]

[Detailed notes about specific files if needed]

---

## Questions for Author

[Any clarifying questions about the implementation]

1. [Question about design choice]
2. [Question about edge case handling]
3. [etc.]

---

## Follow-up Items

[Issues that could be addressed in follow-up PRs]

- [ ] [Follow-up item 1]
- [ ] [Follow-up item 2]
- [ ] [etc.]

---

## Final Recommendation

**Decision**: [Approve / Request Changes / Needs Discussion]

**Rationale**:
[Explain the recommendation based on findings]

**Next Steps**:
[What should happen next - fixes needed, discussion required, etc.]

---

## Appendix

### Review Checklist Applied

[Optional: Note which checklist areas were reviewed]

- [x] Code Quality
- [x] Correctness
- [x] Testing
- [x] Security
- [x] Performance
- [x] Backward Compatibility
- [x] Documentation

### Files Reviewed

[List of all files examined during review]

- `[file path]`
- `[file path]`
- ...

---

*This review was conducted using the PR Review skill for Claude Code. For questions or to customize review criteria, edit the skill in `.claude/skills/pr-review/`.*
