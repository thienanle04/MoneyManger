---
description: Money Manager product flows, screens, and ledger semantics
---

# System Features — Money Manager

## Product goals

1. **Instant capture** — log expense/income quickly (account + category + amount)
2. **Multi-currency** — 30+ ISO codes with correct minor units; base currency in settings (default VND)
3. **Append-only ledger** — balances derived from events; corrections via new events
4. **Import** — stage CSV/XLSX then commit as ledger events
5. **Insights + NAV** — monthly leak insights; NAV snapshots with FX context

## Ledger semantics

- **Write path:** only `LedgerWriter.append` (or future batch commit that uses it)
- **Dedupe:** if `clientRequestId` already exists, return existing event id (idempotent retries)
- **Corrections:** `LedgerEventType.correction` / `reversal` referencing `correctedEventId` — do **not** mutate old rows
- **Amounts:** always `amountMinor` (int); currency on the event row

### Event types (`LedgerEventType`)

| Type | Intent |
|------|--------|
| expense / income | Spending / earning |
| transfer | Between accounts |
| lend / borrow | Debt with a person |
| debtRepayment / loanRepaymentReceived | Pay / receive repayments |
| subscriptionPayment / subscriptionAdjustment | Recurring |
| assetValueUpdate | Mark-to-market |
| importCommit | Import batch finalized |
| correction / reversal | Fix prior event |

## UI shell

`AppShell` — `IndexedStack` + `NavigationBar`: Home → Capture → Insights → Settings.

All labels via `AppLocalizations` (ARB).

## Feature status (roadmap)

| Feature | Status |
|---------|--------|
| Money + currency registry | Done (`lib/core/money/`) |
| FX converter helpers | Done (`lib/core/fx/`) |
| Drift schema v1 | Done |
| LedgerWriter + tests | Done |
| Capture form + account/category CRUD | **Next** |
| Balance projection from ledger | Planned |
| CSV/XLSX import staging UI | Planned |
| Monthly insights + NAV snapshots | Planned |

## Non-goals (for now)

- Cloud sync / multi-device accounts
- Server API / auth
- Web or desktop-first UX (mobile Flutter first)
