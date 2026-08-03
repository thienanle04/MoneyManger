---
name: feature-dev
description: >-
  New Money Manager feature end-to-end. Detects FULL vs LIGHT scope; coordinates
  BA → UI → Tech Lead → data/UI implement → QA. Use for new capture/import/insights work.
---

# Feature Dev — Money Manager

## Scope detection

**LIGHT** if all true; else **FULL**:

1. No new Drift table/column  
2. No change to ledger append-only / event-type semantics  
3. ≤ 2 screens affected  
4. No new import/FX/NAV pipeline  

Announce: `SCOPE: FULL|LIGHT — <one-line why>`

## FULL

```
BA (business-analyst) → UI spec (ui-ux-design)
✋ confirm docs
Tech Lead (tech-lead)
✋ confirm tasks
Implement: flutter-data and/or flutter-ui → test-qa → update knowhow
```

Docs under `docs/ba/`, `docs/ui/`, `docs/tasks/` when FULL (create dirs if needed).

## LIGHT

Skip BA/UI docs unless user asks. Implement with `flutter-data` / `flutter-ui` → `test-qa`.

## Always

- Read `.cursor/knowhow/*` first; graphify before exploration  
- Money = minor units; ledger via `LedgerWriter`  
- Strings in ARB (`vi`+`en`)  
- Verify: `flutter analyze` && `flutter test`  
- `graphify update .` after code changes
