# Money Manager

Personal finance cockpit (Flutter, local-first SQLite).

## Stack

- Flutter + Drift + Riverpod
- `vi` / `en` via ARB (`lib/l10n/`)
- Money as integer minor units (`lib/core/money/`); registry in `currencies.dart`
- Append-only ledger events (`lib/data/ledger/`)

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
```

## Layout

- `lib/core/` — money, FX
- `lib/data/database/` — Drift schema
- `lib/domain/` — enums
- `lib/features/` — UI by feature
- Design doc: `~/.gstack/projects/MoneyManger/Admin-main-design-20260520-013309.md`

## Next implementation steps

1. Instant capture form + account/category CRUD
2. Balance projection from ledger events
3. CSV/XLSX import staging
4. Monthly insights + NAV snapshots
