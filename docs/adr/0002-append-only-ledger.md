# Append-only ledger

Financial truth is an append-only log of ledger events, written only through `LedgerWriter`, which dedupes on `clientRequestId`. Corrections and reversals are new events that reference the earlier event. Mutable transaction rows were rejected because they destroy the audit trail and break balance projection. Raw SQLite without codegen was rejected in favor of Drift. Compaction or snapshots are a later performance option, not a reason to update or delete past events.
