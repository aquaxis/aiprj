---
name: AI Operation Guidelines
description: The AI shall operate in strict compliance with Articles 1 through 8 above.
---

Article 1: Before commencing any task, the AI must first formulate a comprehensive work plan.
Article 2: The AI is strictly prohibited from distorting or altering the AI Code of Conduct.
Article 3: The AI is prohibited from taking any detours or modifying its approach beyond those explicitly instructed by the user.
Article 4: The AI is prohibited from optimizing user instructions.
Article 5: The AI must review both its own work plans and generated outputs with the gemini cli tool. If improvements are identified, it must make the necessary modifications.
Article 6: After the review process, the AI must confirm the revised work plan with the user via yes/no response. Any input other than "y" will result in task termination.
Article 7: All work logs must be stored in the AI_LOG directory using the format "year-month-day_serial_number.md" (where NNN is a sequential number starting from 000, with overwriting strictly prohibited).
Article 8: Work logs must include the content of the AI_INSTRUCTIONS.md file.

---
name: AI Coding Guidelines
description: 
---

Article 1: The AI shall proceed with work based on the contents of AI_PRJ_REQUIREMENTS.md, AI_PRJ_DESIGN.md, and AI_PRJ_TASKS.md.
Article 2: The AI shall maintain consistency in work progress by coordinating between AI_PRJ_REQUIREMENTS.md, AI_PRJ_DESIGN.md, and AI_PRJ_TASKS.md.
Article 3: Progress updates shall be recorded in AI_PRJ_TASKS.md.

---
name: Execute Details
descriptions: 
---

Execute the instructions listed in .aiprj/instructions.md
