# Active Context - enclavr-root

## Latest Changes (2026-03-23)
- **Release Management Completed:**
  | Repo | Releases | Latest | Commits Since |
  |------|----------|--------|---------------|
  | enclavr/enclavr | 23 | v2026.03.23 | 16 |
  | enclavr/frontend | 19 | v2026.03.23 | 6 |
  | enclavr/server | 18 | v2026.03.23 | 4 |
  | enclavr/infra | 10 | v2026.03.22 | 1 |
  | enclavr/docs | 8 | v2026.03.23 | 0 |

- **Key Changes by Repo:**
  - Root: Submodule updates, proactive improvements
  - Frontend: Sentry fix, Select/Tabs/Dialog components, test improvements
  - Server: Preferences handler fix, ImportPrivacySettings, block tests
  - Infra: Monitoring stack (Prometheus/Grafana)
  - Docs: Synced with other repos

- **Release v2026.03.23 created** for enclavr, frontend, server, docs
- **Release v2026.03.22 created** for infra

## Previous Changes (2026-03-23)
- **CI Failure Analysis Completed:**
  | Repo | Failures | Type | Action |
  |------|----------|------|--------|
  | enclavr/enclavr | ~25 | Infrastructure (GitHub Pages, billing) | IGNORE |
  | enclavr/frontend | ~30+ | Infrastructure (runner shutdown signal) | IGNORE |
  | enclavr/server | ~30 | Infrastructure (Redis not available in CI) | IGNORE |
  | enclavr/infra | ~19 | Infrastructure (missing .env in CI) | IGNORE |
  | enclavr/docs | ~4 | Infrastructure (deployment config) | IGNORE |

## Current Work Focus
Proactive improvements completed

## Latest Update (2026-03-23)
Proactive improvements completed

## Regression Monitoring (2026-03-23)
| Repo | Closed | Verified | Reopened | Fixes |
|------|--------|----------|----------|-------|
| enclavr/enclavr | 2 | 2 | 0 | All OK |
| enclavr/frontend | 2 | 2 | 0 | All OK |
| enclavr/server | 1 | 1 | 0 | All OK |
| enclavr/infra | 0 | - | - | None |
| enclavr/docs | 1 | 1 | 0 | All OK |

**Summary:** No regressions detected. All fixes verified:
- Mobile sidebar CSS (enclavr) - deployed
- Duplicate .env vars (enclavr/infra) - commit 895bd64
- TypeScript mock types (frontend) - typecheck passes
- Sentry beforeSend (frontend) - try-catch in place
- TableName functions (server) - commit f282351
- Docs version (docs) - no repro, closed not_planned