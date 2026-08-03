---
name: refactor
description: Improve Flutter/Dart code quality without behavior change. Use for cleanup,
  extract, readability, dedupe. Not for business-logic changes (use feature-dev).
  Stop twice: after scope and after plan.
---

# Workflow: Refactor (Flutter / Money Manager)

```
Scope & Assessment → ✋ confirm
Refactor Plan      → ✋ confirm
Snapshot tests → Refactor → Verify → Document
```

**Invariant:** Behavior before/after identical (tests + analyze green).

## Phase 1 — Scope

Read: `.cursor/knowhow/know-how.md`, `coding-convention.md`, `lessons-learned.md`.  
Orient with `graphify query` / `path` before deep file reads.

Classify: extract | rename | dedupe | restructure | perf | types.  
Define in-scope / out-of-scope. **✋ stop for confirm.**

## Phase 2 — Plan

List concrete file-level steps. Note if `build_runner` / gen-l10n needed. **✋ stop.**

## Phase 3–5 — Execute

1. Ensure coverage for touched paths (`flutter test`); add characterization tests if missing  
2. Small sequential diffs  
3. `flutter analyze` + `flutter test`  
4. Escape: cannot fix failing tests in 3 tries → revert and report

## Phase 6 — Document

Update knowhow only if patterns/decisions changed. Run `graphify update .` after code edits.

## Money Manager constraints

- Do not change ledger append-only semantics  
- Do not convert money storage to `double`  
- Do not hand-edit `*.g.dart` / generated l10n
