---
name: flutter-data
description: >-
  Drift schema, LedgerWriter, Riverpod database providers for Money Manager.
  Use for tables, migrations, queries, append-only ledger writes.
---

# Flutter Data — Money Manager

## Do

1. Graphify `AppDatabase` / table / `LedgerWriter` before edits  
2. Tables in `lib/data/database/tables/`; register on `AppDatabase`  
3. Schema changes: bump `schemaVersion` + `onUpgrade`; then  
   `dart run build_runner build --delete-conflicting-outputs`  
4. Financial writes: `LedgerWriter.append` only; set `clientRequestId` when idempotent  
5. Amounts: `int` minor units; currencies via `Currencies`  
6. Expose DB/services through Riverpod in `lib/data/providers/`  
7. Add/extend tests under `test/` (see `ledger_writer_test.dart` pattern with `AppDatabase.forTesting`)

## Don't

- UPDATE/DELETE ledger rows for user edits  
- Hand-edit `app_database.g.dart`  
- Bypass `LedgerWriter` for ad-hoc inserts (except migrations/seeds with clear reason)
