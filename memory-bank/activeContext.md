# Active Context - Root Monorepo

## Current Work Focus
Submodule update check completed

## Latest Update (2026-03-14)
- Checked all submodules - already at latest commits
- No updates needed

## Latest Update (2026-03-14)
- Debugging completed

## Latest Update (2026-03-14)
- Reviewed all 5 repos for open PRs
- No open PRs found in any repository
- PRs reviewed:
  - enclavr/enclavr (root): 0 PRs
  - enclavr/frontend: 0 PRs
  - enclavr/server: 0 PRs
  - enclavr/infra: 0 PRs
  - enclavr/docs: 0 PRs

## Latest Update (2026-03-14)
- Analyzed all 5 repos for open issues
- Fixed enclavr/docs issue #1: Updated outdated documentation
  - Added presence-api.html for user presence status endpoints
  - Added push-api.html for push notification subscription management
  - Updated rooms-api.html and admin-api.html with latest endpoints
  - Updated sidebar with new API navigation links
  - Committed and pushed to docs repo (a42cc61)
  - Updated root repo to point to new docs commit (664e10b)

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
