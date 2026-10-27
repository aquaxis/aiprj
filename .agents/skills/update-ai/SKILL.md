---
name: update-ai
description: Update the aiprj project documents (AI_PRJ_REQUIREMENTS.md, AI_PRJ_DESIGN.md, AI_PRJ_TASKS.md) to match the current .aiprj/instructions.md. Use only when explicitly invoked to refresh the project documents after instructions.md was edited.
---

Read the file `.aiprj/rules/update_project.md` at the repository root and follow its contents strictly as if they were part of this instruction.

Notes for Codex:
- The `@path` references inside that rule file mean "the file at this repository-relative path"; read the referenced files instead of treating `@` as literal text.
- Apply the write-scope restriction stated in the rule: only the three project documents (and work logs) may be written; source code must not be modified.