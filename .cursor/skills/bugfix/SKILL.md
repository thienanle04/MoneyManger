---
name: bugfix
description: >-
  Diagnose and fix Money Manager bugs/regressions. Prefer failing test first;
  respect ledger append-only and Money minor units.
---

# Bugfix — Money Manager

1. Reproduce: steps, expected vs actual, platform (Android/iOS/emulator)  
2. Graphify + read suspects (`LedgerWriter`, feature screen, Drift query)  
3. Write/adjust failing `flutter test` that captures the bug  
4. Fix minimal root cause — no drive-by refactors  
5. Confirm analyze + full relevant tests pass  
6. Add entry to `.cursor/knowhow/lessons-learned.md` if non-obvious  
7. `graphify update .` if code changed

## Watchouts

- Idempotency / `clientRequestId` dedupe  
- Currency mismatch in `Money` ops  
- Stale generated files (re-run `build_runner` / `gen-l10n`)  
- Schema version mismatch on device
