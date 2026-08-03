---
name: ui-ux-design
description: >-
  Mobile Flutter UI spec for Money Manager from BA. Material 3, bottom nav shell,
  vi/en copy keys — not web marketing layouts.
---

# UI/UX Design — Money Manager

Output `docs/ui/YYYYMMDD_<feature>-ui-spec.md`:

- Screens & navigation (fit `AppShell` tabs or push routes)  
- Layout wire description (lists, forms, sheets) — mobile-first  
- Components: Forui (`FScaffold`, `FHeader`, `FCard`, `FTile`, `FButton`, `FTextField`)  
- Empty / loading / error states  
- Accessibility (tap targets, semantics)  
- **l10n:** list ARB keys for `en` + `vi` (no hardcoded copy)  
- Money input: major-unit typing → parse to minor units  

Avoid web-dashboard clutter (stat strips, multi-column marketing heroes).
