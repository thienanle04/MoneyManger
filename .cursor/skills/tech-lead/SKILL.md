---
name: tech-lead
description: >-
  Break BA + UI specs into implementable tasks for Money Manager (Drift,
  Riverpod, Flutter UI, tests).
---

# Tech Lead — Money Manager

Output `docs/tasks/YYYYMMDD_<feature>-tasks.md`:

Ordered tasks with:

- Layer: `domain` | `data` (Drift/ledger) | `providers` | `ui` | `l10n` | `test`  
- Files likely touched  
- Dependencies between tasks  
- Schema migration needed? (`schemaVersion`)  
- Test plan (`flutter test` cases)  

Prefer vertical slices (data + UI + test) over big-bang layers.
