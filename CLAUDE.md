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

## gstack (REQUIRED — global install)

**Before doing ANY work, verify gstack is installed:**

```bash
test -d ~/.claude/skills/gstack/bin && echo "GSTACK_OK" || echo "GSTACK_MISSING"
```

If GSTACK_MISSING: STOP. Do not proceed. Tell the user:

> gstack is required for all AI-assisted work in this repo.
> Install it:
> ```bash
> git clone --depth 1 https://github.com/garrytan/gstack.git ~/.claude/skills/gstack
> cd ~/.claude/skills/gstack && ./setup --team
> ```
> Then restart your AI coding tool.

Do not skip skills, ignore gstack errors, or work around missing gstack.

Using gstack skills: After install, skills like /qa, /ship, /review, /investigate,
and /browse are available. Use /browse for all web browsing.
Use ~/.claude/skills/gstack/... for gstack file paths (the global path).

For Cursor, skills are also installed under `~/.cursor/skills/gstack-*`
(e.g. `gstack-qa`, `gstack-ship`, `gstack-review`, `gstack-office-hours`).
