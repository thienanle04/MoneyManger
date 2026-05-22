# Money Manager

Personal finance app: fast capture, monthly leak insights, NAV, multi-currency (VND + USD), Vietnamese and English UI.

## Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable)
- Android or iOS toolchain for device builds

## Getting started

```bash
flutter pub get
flutter gen-l10n
flutter pub run build_runner build
flutter run
```

## Development

```bash
flutter analyze
flutter test
```

## Architecture

- **Drift** — local SQLite schema (ledger events, accounts, import staging, FX, NAV snapshots)
- **Riverpod** — app state and database providers
- **ARB l10n** — `lib/l10n/app_en.arb`, `app_vi.arb`

See [CLAUDE.md](CLAUDE.md) for agent-oriented notes.
