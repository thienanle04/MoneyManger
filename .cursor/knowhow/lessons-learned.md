---
description: Lessons learned for Money Manager — avoid repeating mistakes
---

# Lessons Learned — Money Manager

<!-- Newest entries on top -->

## Anti-patterns

### 1. Do not hand-edit generated files

`*.g.dart`, `app_localizations*.dart` are codegen output. Change sources (tables, ARB) and re-run builders.

### 2. Do not “edit” ledger rows

User corrections → new `correction` / `reversal` events. Updating/deleting `ledger_events` breaks audit and balance projection assumptions.

### 3. Do not use `double` for money storage

Parse UI strings into `Money.minorUnits`. Display via formatters; compute in integers.

### 4. Explore with graphify first

Before broad Grep/Read, run `graphify query` / `path` / `explain` so Drift/UI edges are visible. After edits: `graphify update .`.

### 5. Schema change without migration

Bump `schemaVersion` and write `onUpgrade` before shipping; otherwise existing installs crash or wipe unexpectedly.

## Setup checklist after clone

```bash
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```
