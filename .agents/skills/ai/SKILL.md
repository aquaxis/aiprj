---
name: ai
description: Execute the current aiprj task phase. Reads .aiprj/instructions.md and works according to .aiprj/rules/exec_job.md, updating AI_PRJ_TASKS.md as task status changes. Use only when explicitly invoked for aiprj task execution in this repository.
---

Read the file `.aiprj/rules/exec_job.md` at the repository root and follow its contents strictly as if they were part of this instruction.

Notes for Codex:
- The `@path` references inside that rule file (for example `@.aiprj/AI_PRJ_TASKS.md`) mean "the file at this repository-relative path"; read the file instead of treating `@` as literal text.
- Apply the write-scope restrictions stated in the rule (e.g., task status updates must be written to `.aiprj/AI_PRJ_TASKS.md`).
- Work logs, when required, go to `.aiprj/AI_LOG/YYYY-MM-DD_NNN.md` (zero-padded `NNN` starting at `000`, never overwrite).