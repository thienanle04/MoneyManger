---
description: Money Manager structure, Drift schema, providers, commands
---

# Money Manager — Technical Knowhow

## Overview

- **Product:** Personal finance cockpit — fast capture, multi-currency, local-first
- **Platform:** Flutter (Android / iOS)
- **Storage:** SQLite via Drift (no backend API)
- **State:** Riverpod
- **UI:** Forui (`FTheme`, `FScaffold`, `FCard`, `FTile`, …)
- **i18n:** ARB `vi` / `en` + Forui `FLocalizations`

## Layout

```
lib/
├── main.dart / app.dart
├── core/
│   ├── money/          # Money, Currency, Currencies registry
│   └── fx/             # FxConverter / rates lookup
├── data/
│   ├── database/       # AppDatabase, connection, tables/, *.g.dart
│   ├── ledger/         # LedgerWriter (append-only)
│   └── providers/      # databaseProvider etc.
├── domain/enums/       # LedgerEventType
├── features/
│   ├── shell/          # AppShell + bottom nav
│   ├── home/
│   ├── capture/
│   ├── insights/
│   └── settings/
└── l10n/               # generated + ARB sources
```

## Drift tables (`AppDatabase`, schemaVersion = 1)

| Table | Role |
|-------|------|
| `Accounts` | Cash/bank/asset accounts (`balanceMinor`, `currencyCode`, `includeInNav`) |
| `Categories` | Income/expense categories (`isIncome`, optional `parentId`) |
| `People` | Counterparties for lend/borrow |
| `LedgerEvents` | Append-only event log (`amountMinor`, `eventType`, optional FKs, `clientRequestId`) |
| `ExchangeRates` | FX rates (`fromCurrency`/`toCurrency`, `isManual`) |
| `ImportBatches` / `ImportRowStaging` | CSV/XLSX import pipeline (staging) |
| `NavSnapshots` | Point-in-time NAV (`breakdownJson`, `fxContextJson`) |
| `AppSettings` | Key/value (seed: `base_currency` = `VND`) |

IDs are text (UUID). Money columns are integer minor units.

## Key types

- `Money` — `minorUnits` + `currencyCode`; parse/format via `Money.parse` / display helpers
- `LedgerWriter.append` — inserts `LedgerEvents`; dedupes on `clientRequestId`
- `LedgerEventType` — expense, income, transfer, lend/borrow, repayments, subscription*, assetValueUpdate, importCommit, correction, reversal

## Providers

- `lib/data/providers/database_provider.dart` — exposes `AppDatabase` via Riverpod

## Commands

```bash
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
```

## Screens (shell)

| Tab | Widget | Status |
|-----|--------|--------|
| Home | `HomeScreen` | Placeholder / early |
| Capture | `CaptureScreen` | Placeholder — next: instant capture form |
| Insights | `InsightsScreen` | Placeholder |
| Settings | `SettingsScreen` | Placeholder |
