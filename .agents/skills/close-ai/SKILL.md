---
name: close-ai
description: Save the aiprj work log to .aiprj/AI_LOG/ and finish the session. Use only when explicitly invoked to end the aiprj work session.
---

Read the file `.aiprj/rules/close_ai.md` at the repository root and follow its contents strictly as if they were part of this instruction.

Notes for Codex:
- The `@path` references inside that rule file mean "the file at this repository-relative path"; read the referenced files instead of treating `@` as literal text.
- Save the work log to `.aiprj/AI_LOG/YYYY-MM-DD_NNN.md` (zero-padded `NNN` starting at `000`, never overwrite), including the full content of `.aiprj/instructions.md` at execution time.
- The Claude Code version of this command ends with `exit`; in Codex this skill finishes after writing the log — tell the user the session can be closed with `/exit` (or exit the CLI interactively). Codex must not kill its own process.