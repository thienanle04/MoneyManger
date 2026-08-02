# Cursor agents & skills — Money Manager

```
.cursor/
├── AGENTS.md          ← this file
├── agents/            ← custom agents (workflows with stop points)
├── knowhow/           ← project knowledge (read before implement)
├── rules/             ← always-on Cursor rules (.mdc)
└── skills/            ← Agent Skills (SKILL.md)
```

## Agents (`.cursor/agents/`)

| Agent | When to use |
|-------|-------------|
| `refactor` | Cleanup / extract / readability — **no behavior change** |

## Skills (`.cursor/skills/`)

| Skill | When to use |
|-------|-------------|
| `feature-dev` | New feature end-to-end |
| `change-request` | Change existing feature |
| `bugfix` | Bug / regression |
| `business-analyst` | Requirements / BA analysis |
| `ui-ux-design` | Mobile UI spec from BA |
| `tech-lead` | Task breakdown |
| `flutter-ui` | Screens / widgets / l10n |
| `flutter-data` | Drift schema, ledger, Riverpod providers |
| `test-qa` | Tests / verify (`flutter test`, analyze) |
| `perf-review` | Jank / slow queries / rebuilds |
| `drift-query` | Drift/SQLite query efficiency |
| `user-guide` | End-user help copy |

## Knowhow (`.cursor/knowhow/`)

Read before implement. Rules under `.cursor/rules/` point here.

## Notes

- Source of truth for stack/layout: `.cursor/rules/money-manager.mdc`
- Before exploring code: use `graphify` (`graphify-out/`) — see `rules/graphify.mdc`
- After code changes: `graphify update .`
