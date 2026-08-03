---
name: drift-query
description: >-
  Optimize or review Drift/SQLite queries for Money Manager (ledger, accounts,
  FX, import staging).
---

# Drift Query — Money Manager

## Guidelines

- Select only needed columns when tables grow  
- Filter early (`occurredAt`, `accountId`, `eventType`)  
- Prefer indexed columns for hot paths (add indexes in table defs when proven)  
- Avoid N+1: join or batch load accounts/categories for list UIs  
- Balance projection: stream/query aggregates thoughtfully; consider cached snapshot later  
- Use transactions for multi-row import commits  

## Process

1. Graphify related tables/writers  
2. Show current query + explain cost concern  
3. Propose rewrite; implement only when asked  
4. Add test covering result correctness
