# Coding Conventions — Money Manager (Dart / Flutter)

## Naming

```dart
// Files: snake_case
ledger_writer.dart
capture_screen.dart

// Types: PascalCase
class LedgerWriter {}
enum LedgerEventType { expense, income }

// Members: camelCase; private with _
final int amountMinor;
String get storageKey => name;

// Constants: lowerCamel or SCREAMING_SNAKE for true consts
const uuid = Uuid();
```

## Money

```dart
// ✅ integer minor units
final money = Money(minorUnits: 1050, currencyCode: 'USD'); // $10.50

// ❌ never store balances as double
final bad = 10.50;
```

- Resolve metadata via `Currencies.resolve(code)`
- Same-currency arithmetic only (`Money +` / `-` asserts)

## Ledger writes

```dart
// ✅
await ledgerWriter.append(
  type: LedgerEventType.expense,
  occurredAt: DateTime.now(),
  currencyCode: 'VND',
  amountMinor: 50000,
  accountId: accountId,
  categoryId: categoryId,
  clientRequestId: idempotencyKey,
);

// ❌ raw update/delete on ledger_events for “edits”
```

## Drift

- Table classes in `lib/data/database/tables/`
- Register in `@DriftDatabase(tables: [...])`
- On schema change: increment `schemaVersion`, add `MigrationStrategy.onUpgrade`, then `build_runner`
- Test DB: `AppDatabase.forTesting(executor)`

## Riverpod / Forui UI

- Feature screens under `lib/features/<name>/`
- Prefer Forui widgets; `context.theme` for `FThemeData`
- Prefer `ConsumerWidget` when reading providers
- No user-visible English/Vietnamese literals in widgets — use ARB keys
- Keep widgets thin; put persistence in data layer (`LedgerWriter`, DAOs/queries)

## Imports

```dart
// dart: → package: → relative
import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
```

## Comments

Explain **why** (ledger append-only, FX as-of date), not what the next line does.

## Git commits (Conventional)

```
feat(capture): add expense form with account picker
fix(ledger): dedupe on clientRequestId
refactor(money): clarify parse edge cases
test(ledger): cover correction events
chore: bump drift
```

## Verify before done

```bash
flutter analyze
flutter test
```
