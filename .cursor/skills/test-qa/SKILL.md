---
name: test-qa
description: >-
  Verify Money Manager changes with flutter analyze and flutter test. Add
  unit/widget tests for money, ledger, and UI regressions.
---

# Test / QA — Money Manager

## Checklist

```bash
flutter analyze
flutter test
```

## Patterns

- **Money / currency:** `test/core/`  
- **Ledger:** `test/data/ledger_writer_test.dart` — use `AppDatabase.forTesting`  
- **Widget:** `test/widget_test.dart` or feature-focused widget tests  

## After feature work

- Cover happy path + one failure/edge (dedupe id, bad money parse, missing account)  
- Confirm both locales still generate (`flutter gen-l10n`) if ARB changed  
- Report: commands run, pass/fail, gaps
