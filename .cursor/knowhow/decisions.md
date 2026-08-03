---
description: Architecture decisions for Money Manager — do not contradict without re-evaluating
---

# Decisions — Money Manager

## How to use

Tags: `[architecture]` `[database]` `[money]` `[flutter]` `[i18n]`

Add new entries at the **top**. Include **Revisit when**.

---

## Entries

### [architecture] Local-first Flutter — no backend

- **Date:** 2026-05
- **Decision:** Single Flutter app + on-device SQLite (Drift). No REST API, no auth server.
- **Why:** Personal finance cockpit; privacy and offline-first; simpler MVP.
- **Rejected:** Firebase / sync backend (premature).
- **Revisit when:** Multi-device sync or shared household budgets are required.

### [database] Drift + append-only ledger

- **Date:** 2026-05
- **Decision:** Drift ORM; financial truth in `LedgerEvents` append-only; `LedgerWriter` sole write API with `clientRequestId` dedupe.
- **Why:** Auditability; safe retries; corrections as new events (`correction` / `reversal`).
- **Rejected:** Mutable transaction rows; raw `sqflite` without codegen.
- **Revisit when:** Need event compaction / snapshots for performance on huge histories.

### [money] Integer minor units

- **Date:** 2026-05
- **Decision:** All stored amounts are `int` minor units; `Money` + `Currencies` registry (decimal digits per ISO code).
- **Why:** Avoid float rounding; VND (0 decimals) and USD (2) share one model.
- **Rejected:** `double` balances; Decimal package (extra weight for MVP).
- **Revisit when:** Need arbitrary-precision or crypto subunits.

### [flutter] Forui for UI kit

- **Date:** 2026-08
- **Decision:** Use `forui` (`FTheme.neutral`, `FScaffold`, `FBottomNavigationBar`, `FCard`, `FTile`, Lucide icons) with `toApproximateMaterialTheme()` for residual Material widgets.
- **Why:** Consistent minimal UI; gradual Material interop; matches mobile touch themes.
- **Rejected:** Pure Material 3 only.
- **Revisit when:** Custom brand theme needed (`dart run forui theme create`).

### [flutter] Riverpod for DI / state

- **Date:** 2026-05
- **Decision:** `flutter_riverpod` for `AppDatabase` and feature state.
- **Why:** Testable providers; fits Flutter; no Bloc boilerplate for MVP.
- **Revisit when:** Complex ephemeral UI state needs a clearer pattern per feature.

### [i18n] ARB vi/en

- **Date:** 2026-05
- **Decision:** Flutter gen-l10n; `app_en.arb` + `app_vi.arb`.
- **Why:** First-class Flutter i18n; matches product requirement.
- **Revisit when:** Adding more locales or ICU-heavy plural rules.

### [ui] Feature folders + AppShell tabs

- **Date:** 2026-05
- **Decision:** `lib/features/{home,capture,insights,settings,shell}`; bottom `NavigationBar` + `IndexedStack`.
- **Why:** Clear ownership; keep tab state alive.
- **Revisit when:** Deep linking / go_router becomes necessary.
