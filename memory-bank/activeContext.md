# Active Context - Enclavr Root

## Current Work Focus
Submodule maintenance check

## Latest Update (2026-03-16)
- Submodule update: all submodules already at latest
- No commit needed

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
