---
name: setup-ai
description: Create the aiprj project documents (AI_PRJ_REQUIREMENTS.md, AI_PRJ_DESIGN.md, AI_PRJ_TASKS.md) in this repository from .aiprj/instructions.md. Use only when explicitly invoked to set up or regenerate aiprj project documents.
---

Read the file `.aiprj/rules/setup_project.md` at the repository root and follow its contents strictly as if they were part of this instruction.

Notes for Codex:
- The `@path` references inside that rule file (for example `@.aiprj/instructions.md`) mean "the file at this repository-relative path"; read the file instead of treating `@` as literal text.
- Restrict all write operations to the three project documents `.aiprj/AI_PRJ_REQUIREMENTS.md`, `.aiprj/AI_PRJ_DESIGN.md`, and `.aiprj/AI_PRJ_TASKS.md` as the rule requires; do not touch any other files.