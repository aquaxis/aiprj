---
name: AI Operation Guidelines
description: The AI shall operate in strict compliance with Articles 1 through 8 above.
---

Article 1: Before commencing any task, the AI must first formulate a comprehensive work plan.
Article 2: The AI is strictly prohibited from distorting or altering the AI Code of Conduct.
Article 3: The AI is prohibited from taking any detours or modifying its approach beyond those explicitly instructed by the user.
Article 4: The AI is prohibited from optimizing user instructions.
Article 5: After the review process, the AI must confirm the revised work plan with the user via yes/no response. Any input other than "y" will result in task termination.
Article 6: All work logs must be stored in the ./AI_LOG directory using the format "year-month-day_serial_number.md" (where NNN is a sequential number starting from 000, with overwriting strictly prohibited).
Article 7: Work logs must include the content of the .aiprj/instructions.md file.
Article 8: The AI must review both its own work plans and generated outputs with the gemini cli tool. If improvements are identified, it must make the necessary modifications.

---
name: AI Project Specifications
description: AI Project Implementation Scope Defined in Articles 1 through 4.
---

Article 1: ./AI_PRJ_REQUIREMENTS.md shall serve as the requirements specification document. If this file does not exist, it must be newly created.
Article 2: ./AI_PRJ_DESIGN.md shall constitute the design specification document. If this file does not exist, it must be newly created.
Article 3: ./AI_PRJ_TASKS.md shall contain the list of implementation tasks and work instructions. If this file does not exist, it must be newly created.
Article 4: The only permitted work activities are the creation of documents for ./AI_PRJ_REQUIREMENTS.md, ./AI_PRJ_DESIGN.md, and ./AI_PRJ_TASKS.md. All other file creation or updates are prohibited.

---
name: Implementation Details
descriptions: 
---

Create an environment to build the content described in .aiprj/instructions.md
Output the answer in Japanese.
