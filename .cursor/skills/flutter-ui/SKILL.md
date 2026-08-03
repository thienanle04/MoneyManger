---
name: flutter-ui
description: >-
  Implement Money Manager screens/widgets/l10n. Use Forui under lib/features/,
  Riverpod Consumer widgets, ARB strings.
---

# Flutter UI — Money Manager

## Do

1. Read UI spec / change request; graphify feature screen nodes  
2. Place code in `lib/features/<feature>/`  
3. Prefer **Forui**: `FScaffold` / `FHeader` / `FCard` / `FTile` / `FButton` / `FTextField` / `FLucideIcons`  
4. Use `AppLocalizations` — update `app_en.arb` + `app_vi.arb`, run `flutter gen-l10n`  
5. Prefer `ConsumerWidget` / `ConsumerStatefulWidget`  
6. Parse money input with `Money.parse`; display with Money formatters  
7. Keep widgets free of raw SQL / Drift inserts — call providers / `LedgerWriter`  
8. Match shell: `AppShell` (`FScaffold` + `FBottomNavigationBar`)

## Don't

- New Material-first screens when a Forui widget exists (Material OK via approximate theme for gaps)  
- Hardcoded user-facing strings  
- Store money as `double` in UI state long-term (convert ASAP to minor units)  
- Edit generated l10n Dart files by hand
