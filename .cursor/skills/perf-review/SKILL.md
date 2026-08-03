---
name: perf-review
description: >-
  Investigate Flutter jank, excessive rebuilds, or slow Drift queries in Money
  Manager.
---

# Perf Review — Money Manager

1. Reproduce: screen, scroll, capture submit, large ledger  
2. Suspects:  
   - Widget rebuild scope (split consumers; avoid watching huge providers)  
   - Unindexed Drift filters on `ledger_events`  
   - Recomputing balances by full table scan every frame  
3. Prefer projecting balances / NAV snapshots over repeated full scans  
4. Measure before/after (timeline / simple stopwatch in tests)  
5. Document findings; only change code if user wants the fix
