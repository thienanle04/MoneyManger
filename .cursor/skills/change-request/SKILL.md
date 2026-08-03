---
name: change-request
description: >-
  Change an existing Money Manager feature without full greenfield BA unless
  scope expands. Use for tweaks to screens, queries, or ledger write paths.
---

# Change Request — Money Manager

1. **Clarify** target behavior vs current (max 2 questions if unclear)  
2. **Orient** — `graphify query` / knowhow / read current feature files  
3. **Impact** — schema? l10n? tests? ledger semantics?  
4. **Plan** short step list; if schema or ledger rules change, treat as FULL `feature-dev`  
5. **Implement** via `flutter-data` / `flutter-ui` as needed  
6. **Verify** `flutter analyze` + `flutter test`  
7. **Update** knowhow + `graphify update .` if structure/behavior docs drifted
