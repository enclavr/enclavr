# Active Context - Enclavr Root

## Current Work Focus
Sentry debugging completed - No issues found

## Latest Update (2026-03-16)
- Sentry debugging completed: All clear, no issues found
- Verified via Sentry MCP tools:
  - sentry_whoami: Authenticated as enclavr.dev@gmail.com
  - sentry_find_organizations: Found enclavr org (us.sentry.io)
  - sentry_find_projects: 3 projects (api, frontend, test-project)
  - sentry_search_issues: 0 unresolved errors, 0 crashes
  - sentry_search_events: 0 errors from last 24h

### Performance (via sentry_search_events)
- POST /api/auth/login: 60.8ms p75 (4 calls)
- POST /api/room/join: 6.7ms p75 (1 call)
- GET /api/rooms: 1.2ms p75 (11 calls)
- GET /api/room: 0.8ms p75 (1 call)
- GET /api/auth/oidc/config: 0.4ms p75 (36 calls)

All performance metrics within acceptable range.

### enclavr/frontend
- v2026.03.11 (2026-03-11) - Daily release
- v2026.03.10 (2026-03-10) - Daily release

### enclavr/server
- v2026.03.11 (2026-03-11) - Daily release
- v2026.03.10 (2026-03-10) - Daily release

### enclavr/infra
- v2026.03.11 (2026-03-11) - Fix CI robustness when .env.example doesn't exist
- v2026.03.10 (2026-03-10) - Daily release

### enclavr/docs
- v2026.03.10 (2026-03-10) - Daily release

### enclavr (root)
- No releases found

All repos using daily auto-release pattern with no assets. Infra release included CI fix.
