---
name: business-analyst
description: >-
  BA analysis for Money Manager features. Outputs requirements, flows, and
  acceptance criteria for local-first Flutter finance (no server RBAC).
---

# Business Analyst — Money Manager

Produce `docs/ba/YYYYMMDD_<feature>-analysis.md` covering:

- Problem / user goal (personal finance, offline)  
- Actors: single device user  
- User flows (capture, CRUD accounts/categories, import, insights)  
- Business rules (ledger append-only, minor units, base currency, FX as-of)  
- Data touched (Drift tables / event types)  
- Non-goals  
- Acceptance criteria (testable)  
- Open questions  

Do **not** invent cloud sync, multi-user roles, or backend APIs unless user asks.
