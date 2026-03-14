# Active Context - Root Monorepo

## Current Work Focus
Docker debugging and verification task.

## Latest Update (2026-03-14)
- Docker debugging: Verified all services running (coturn, frontend, postgres, redis, server)
- All services healthy with no current errors
- Historical transient DB connection errors from March 11-12 have recovered
- Release analysis: Checked all 5 repos
- Branch/tag maintenance: Verified all repos have only main branch, v2026.03.14 tag exists

## Release Analysis (2026-03-14)
- enclavr/root: 0 releases
- frontend: 2 releases (v2026.03.11, v2026.03.10)
- server: 2 releases (v2026.03.11, v2026.03.10)
- infra: 2 releases (v2026.03.11, v2026.03.10)
- docs: 1 release (v2026.03.10)

Total: 7 releases analyzed, no assets, no docs updates needed

## Latest Changes (2026-03-14)
- Fixed enclavr/enclavr issue #1: Clarified database environment variables in .env.example
  - Added clearer comments explaining POSTGRES_* (container init) vs DB_* (server connection)
  - Both variable sets are used for different purposes
- Updated frontend submodule to latest (37fc466)
- Committed as "chore: update submodules to latest"
- Branch/tag maintenance: Checked all 5 repos - all have only main branch, no stale branches
- All repos already have today's release tag v2026.03.14
- Verified GitHub labels across all 5 repositories - all required labels already exist

## Previous Changes (2026-03-14)
- Debugging completed
- Fixed issue #1: Added missing DB_NAME to root .env.example
