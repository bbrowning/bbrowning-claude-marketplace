Review the conversation history and:

1. Identify key learnings from this session$ARGUMENTS:
   - Technical patterns discovered
   - User corrections or guidance provided
   - Task-specific approaches that worked
   - Personal preferences or workflow patterns

2. Ask the user where to save this learning:

   **Global** (`~/.claude/CLAUDE.md`)
   - Personal coding preferences and style rules
   - General development patterns you prefer across all projects
   - Your workflow preferences
   - Cross-language, cross-project knowledge
   - **Applies to ALL repositories automatically**

   **Plugin Skill** (claude-builder plugin in this marketplace)
   - Domain-specific expertise (e.g., PR review patterns, testing strategies)
   - Shareable, reusable capabilities
   - Structured knowledge for specific problem domains
   - **Available wherever marketplace is installed**

   **Project-Local** (`.claude/CLAUDE.md` in current repo)
   - This specific codebase's architecture patterns
   - Project-specific conventions and decisions
   - **Only applies to this repository**

3. Based on the user's choice:

   **If Global:**
   - Read `~/.claude/CLAUDE.md`
   - Append the learning in a clear, concise format
   - Organize under relevant sections (create if needed)
   - Keep entries brief and actionable

   **If Plugin Skill:**
   - Use the skill-builder skill to either:
     - Update an existing skill if this relates to known domains
     - Create a new skill if this is a new capability area
   - Ensure the skill captures:
     - Clear trigger conditions (when to use this skill)
     - Specific technical details
     - What didn't work and why
     - The correct approach based on user feedback
   - Save in the claude-builder plugin's skills directory

   **If Project-Local:**
   - Read the project's `.claude/CLAUDE.md` (create if needed)
   - Append the learning in a format consistent with the file
   - Keep it specific to this codebase's patterns

4. Confirm where the learning was saved
