---
name: next-ai
description: Move on to the next pending task in the aiprj task list (AI_PRJ_TASKS.md) within the current session. Use only when explicitly invoked to continue with the next job.
---

Continue working on the next "未着手 / pending" task listed in `.aiprj/AI_PRJ_TASKS.md`, in the same manner as the previously executed `.aiprj/rules/exec_job.md` rule in this session.
Complete all tasks one by one.
Read the incomplete tasks from @.aiprj/AI_PRJ_TASKS.md that were left unfinished, and continue working on them until all tasks are completed. Do not stop until every item is complete.

Notes for Codex:
- Keep following the AI Operation Guidelines already loaded in this session.
- Update the "状態 / status" column of `.aiprj/AI_PRJ_TASKS.md` whenever a task status changes.