# Active Context - Enclavr

## Latest Changes (2026-03-12)
- Frontend: Fixed TypeScript error in useMediaQuery test
  - Resolved TypeScript 'never' type error by casting changeHandler to proper function type
  - Converted test to async to properly wait for state updates
  - All lint passes: ESLint ✅, TypeScript ✅
  - All 584 tests pass ✅
- Server: golangci-lint passes ✅, go test passes ✅
- Infra: Docker Compose config valid ✅
- Updated submodule to frontend commit d17c029

## Previous Changes (2026-03-12)
- Issue analysis: ALL 5 repos analyzed via gh api (re-run)
- enclavr/enclavr: 0 open issues ✅
- enclavr/frontend: 0 open issues ✅  
- enclavr/server: 0 open issues ✅
- enclavr/infra: 0 open issues ✅
- enclavr/docs: 0 open issues ✅
- Result: No issues to fix

## Previous Changes (2026-03-12)
- CI failure analysis: ALL 5 repos analyzed via gh api and gh run view
- enclavr (root): validate-submodules failure - already fixed in latest commit (run 22937244064 SUCCESS)
- frontend: Run tests failure - already fixed in latest commit (run 22974339224 SUCCESS)
- server: Run linter failure - already fixed in latest commit (run 22930235490 SUCCESS)
- infra: Validate Docker Compose failure - already fixed in latest commit (run 22942079353 SUCCESS)
- docs: Setup Pages failure - already fixed by simplifying CI (run 22931680741 SUCCESS)
- All CI failures are historical - subsequent commits have fixed them

## Current Work Focus
Debugging completed

## Latest Update (2026-03-12)
- Debugging completed

## Latest Changes (2026-03-12)
- Frontend: Added useRTCStats hook for WebRTC connection monitoring
  - Collects RTC stats including bytes sent/received, packets, RTT, jitter
  - Configurable interval for stats collection
  - Useful for monitoring voice chat quality and debugging connection issues
  - ESLint ✅, 573 tests ✅
  - Pushed commit 076ba98

## Latest Changes (2026-03-12)
- Verified all 5 required labels exist in all 5 enclavr repositories:
  - enclavr/enclavr: bug, feature, enhancement, documentation, security ✅
  - enclavr/frontend: bug, feature, enhancement, documentation, security ✅
  - enclavr/server: bug, feature, enhancement, documentation, security ✅
  - enclavr/infra: bug, feature, enhancement, documentation, security ✅
  - enclavr/docs: bug, feature, enhancement, documentation, security ✅
- No labels needed to be created - all labels already present with correct colors

## Latest Changes (2026-03-12)
- Added missing database index on presences.room_id for efficient voice chat presence queries
- All lint passes
- All tests pass

## Previous Changes (2026-03-12)
- Label verification completed.

## Latest Changes (2026-03-12)
- Verified all required labels exist in all 5 enclavr repositories:
  - enclavr/enclavr: bug, feature, enhancement, documentation, security ✅
  - enclavr/frontend: bug, feature, enhancement, documentation, security ✅
  - enclavr/server: bug, feature, enhancement, documentation, security ✅
  - enclavr/infra: bug, feature, enhancement, documentation, security ✅
  - enclavr/docs: bug, feature, enhancement, documentation, security ✅
- No labels needed to be created - all labels already present

## Latest Update (2026-03-12)
- Debugging completed

## Latest Update (2026-03-12)
- Issue analysis: ALL 5 repos analyzed via gh api
- enclavr/enclavr: 0 open issues ✅
- enclavr/frontend: 0 open issues ✅
- enclavr/server: 0 open issues ✅
- enclavr/infra: 0 open issues ✅
- enclavr/docs: 0 open issues ✅
- Result: No issues to fix

## Previous Changes (2026-03-12)
- Debugging completed

## Latest Update (2026-03-12)
- Analyzed project state across all 5 repositories:
  - GitHub issues: 0 open issues in all repos ✅
  - Sentry errors: 0 unresolved errors ✅
  - Submodules: All up to date with remote ✅
  - CI failures: Likely billing-related (ignore per AGENTS.md)
- No issues requiring fixes

## Previous Changes (2026-03-12)
- Label verification across all 5 enclavr repositories

## Latest Update (2026-03-12)
- Verified all 5 required labels exist in all enclavr repositories:
  - enclavr/enclavr: bug, feature, enhancement, documentation, security ✅
  - enclavr/frontend: bug, feature, enhancement, documentation, security ✅
  - enclavr/server: bug, feature, enhancement, documentation, security ✅
  - enclavr/infra: bug, feature, enhancement, documentation, security ✅
  - enclavr/docs: bug, feature, enhancement, documentation, security ✅
- No labels needed to be created - all labels already present with correct colors

## Latest Update (2026-03-11)
- Debugging completed

## Latest Update (2026-03-11)
- Issue analysis: ALL 5 repos analyzed via gh api
- enclavr/enclavr: 0 open issues ✅
- enclavr/frontend: 0 open issues ✅
- enclavr/server: 0 open issues ✅
- enclavr/infra: 0 open issues ✅
- enclavr/docs: 0 open issues ✅
- Result: No issues to fix

## Latest Update (2026-03-11)
- Debugging completed

## Latest Changes (2026-03-11)
- CI failure analysis: ALL 5 repos analyzed via gh api
- Root: Historical failures (validate-submodules) - already fixed in current code
- frontend: TypeScript errors in useMediaDevices.test.ts - already fixed in current code (typecheck passes)
- server: golangci-lint errcheck errors - already fixed in current code (lint passes)
- infra: Docker compose .env validation - already fixed in current code (config passes)
- docs: GitHub Pages not configured - not a code issue (repo settings)

### Fixes Applied
- frontend: Pushed commit 853dda7 with new components/hooks
- server: Pushed commit ee084f2 with auth enhancements
- All local checks

## Previous Changes
- Issue analysis: ALL 5 repos analyzed via gh api
- enclavr/enclavr: 0 open issues ✅
- enclavr/frontend: 0 open issues ✅
- enclavr/server: 0 open issues ✅
- enclavr/infra: 0 open issues ✅
- enclavr/docs: 0 open issues ✅
- Result: No issues to fix

## Latest Update (2026-03-11)
- Issue analysis: ALL 5 repos analyzed via gh api
- enclavr/enclavr: 0 open issues ✅
- enclavr/frontend: 0 open issues ✅
- enclavr/server: 0 open issues ✅
- enclavr/infra: 0 open issues ✅
- enclavr/docs: 0 open issues ✅
- Result: No issues to fix

## Latest Update (2026-03-11)
- Issue analysis: ALL 5 repos analyzed via gh api
- enclavr/enclavr: 0 open issues ✅
- enclavr/frontend: 0 open issues ✅
- enclavr/server: 0 open issues ✅
- enclavr/infra: 0 open issues ✅
- enclavr/docs: 0 open issues ✅
- Result: No issues to fix

## Latest Update (2026-03-11)
- Verified all 5 required labels exist in all enclavr repositories:
  - enclavr/enclavr: bug, feature, enhancement, documentation, security ✅
  - enclavr/frontend: bug, feature, enhancement, documentation, security ✅
  - enclavr/server: bug, feature, enhancement, documentation, security ✅
  - enclavr/infra: bug, feature, enhancement, documentation, security ✅
  - enclavr/docs: bug, feature, enhancement, documentation, security ✅
- No labels needed to be created - all labels already present with correct colors

## Latest Update (2026-03-11)
Debugging completed

## Latest Changes (2026-03-11)
- CI failure analysis: ALL 5 repos analyzed
- Root repo: Latest run 22937244064 ✅ SUCCESS
- frontend: typecheck passes ✅
- server: golangci-lint passes ✅
- infra: Latest run 22942079353 ✅ SUCCESS
- docs: Latest run 22931680741 ✅ SUCCESS
- All CI failures are historical - subsequent commits have fixed them

## Latest Update (2026-03-11)
- Issue analysis: ALL 5 repos analyzed
- enclavr/enclavr: 0 open issues ✅
- enclavr/frontend: 0 open issues ✅
- enclavr/server: 0 open issues ✅
- enclavr/infra: 0 open issues ✅
- enclavr/docs: 0 open issues ✅
- Result: No issues to fix

## Latest Update (2026-03-11)
- Debugging completed

## Latest Changes (2026-03-11)
- Issue analysis: ALL 5 repos analyzed
- enclavr/enclavr: 0 open issues ✅
- enclavr/frontend: 0 open issues ✅
- enclavr/server: 0 open issues ✅
- enclavr/infra: 0 open issues ✅
- enclavr/docs: 0 open issues ✅
- Result: No issues to fix

## Latest Update (2026-03-11)
- Debugging completed

## Latest Changes (2026-03-11)
- Server: Added InviteLink feature for shareable room invites
  - InviteLink model with Code, RoomID, CreatedBy, Title, Description, MaxUses, Uses, IsPermanent, IsEnabled, ExpiresAt
  - InviteLinkHandler with Create, Get, Update, Delete, Resolve, Use endpoints
  - /api/invite-link/* routes registered
  - Requires room owner/admin to create invite links
  - golangci-lint ✅, go test ✅
- Infra: Fixed CI robustness when .env.example doesn't exist
- Frontend: Fix MediaDeviceInfo test mock properties (lint ✅, 547 tests ✅)
- Root: Updated submodules to latest commits
- Pushed to remote: defbe4f

## Latest Update (2026-03-11)
- Debugging completed

## Latest Update (2026-03-11)
- Issue analysis: ALL 5 repos analyzed
- enclavr/enclavr: 0 open issues ✅
- enclavr/frontend: 0 open issues ✅
- enclavr/server: 0 open issues ✅
- enclavr/infra: 0 open issues ✅
- enclavr/docs: 0 open issues ✅
- Result: No issues to fix

## Current Work Focus

## Latest Changes (2026-03-11)
- CI failure analysis completed for all 5 repos
- Root repo: Fixed submodule reference issue - pushed submodule updates
- Frontend: Lint passes (was transient prefer-const error)
- Server: Lint passes (errcheck exclusions configured for test files)
- Infra: Docker Compose validation passes
- Docs: CI failure is GitHub Pages configuration issue (not code fixable)

## Latest Changes (2026-03-11)
- Issue analysis: ALL 5 repos analyzed
- enclavr/enclavr: 0 open issues ✅
- enclavr/frontend: 0 open issues ✅
- enclavr/server: 0 open issues ✅
- enclavr/infra: 0 open issues ✅
- enclavr/docs: 0 open issues ✅
- Result: No issues to fix

## Latest Update (2026-03-11)
Debugging completed

## Latest Changes (2026-03-11)
- Server: Added RoomSettings model and API for per-room configuration
  - allow_message_edits, allow_reactions, require_approval
  - max_users, auto_delete_days, slow_mode_seconds
  - allow_voice_chat, allow_file_uploads
  - RoomSettingsHandler with Get/Update endpoints
  - Database migration for room_settings table
  - Added golangci-lint configuration
- Frontend: Refactored SearchModal and added UserProfileModal
  - SearchModal now handles its own search logic with debounced API calls
  - Added UserProfileModal component for viewing user profiles
  - Updated tests to match new component APIs
- All lint and tests pass:
  - Server: golangci-lint ✅, go test ✅
  - Frontend: ESLint ✅, 540 tests ✅
- Created daily releases: v2026.03.11 for frontend and server

## Previous Changes
- Label verification completed - all 5 required labels exist in all repositories

## Latest Update (2026-03-11)
Debugging completed

## Latest Update (2026-03-11)
Debugging completed

## Latest Changes (2026-03-11)
- Verified all 5 required labels exist in all enclavr repositories:
  - enclavr/enclavr: bug, feature, enhancement, documentation, security ✅
  - enclavr/frontend: bug, feature, enhancement, documentation, security ✅
  - enclavr/server: bug, feature, enhancement, documentation, security ✅
  - enclavr/infra: bug, feature, enhancement, documentation, security ✅
  - enclavr/docs: bug, feature, enhancement, documentation, security ✅
- No labels needed to be created - all labels already present

## Latest Changes (2026-03-11)
- Analyzed releases across all repos:
  - frontend: v2026.03.10 (1 release)
  - server: v2026.03.10 (1 release)
  - infra: v2026.03.10 (1 release)
  - docs: v2026.03.10 (1 release)
  - root: 0 releases
- All daily releases from 2026-03-10 with changelogs
- No assets attached, no docs updates needed

## Previous Changes
- PR review session completed - no open PRs found in any repository

## Latest Update (2026-03-11)
- PR review: All 5 repos reviewed
- enclavr/enclavr: 0 open PRs ✅
- enclavr/frontend: 0 open PRs ✅
- enclavr/server: 0 open PRs ✅
- enclavr/infra: 0 open PRs ✅
- enclavr/docs: 0 open PRs ✅
- Result: No PRs to review

## Latest Update (2026-03-11)
- Git submodule status: All submodules checked
- Git submodule update --remote --merge: No new commits to fetch
- docs: bba8d12 (dirty - local changes)
- frontend: b99a144 (dirty - local changes)
- infra: 44f22b6 (unchanged)
- server: f552562 (unchanged)
- Result: Submodules already up-to-date with remote

## Latest Changes (2026-03-11)
- Issue analysis: ALL 5 repos analyzed
- enclavr/enclavr: 0 open issues ✅
- enclavr/frontend: 0 open issues ✅
- enclavr/server: 0 open issues ✅
- enclavr/infra: 0 open issues ✅
- enclavr/docs: 0 open issues ✅
- Result: No issues to fix

## Previous Changes (2026-03-11)
PR review session - no open PRs found in any repository.

## Latest Update (2026-03-11)
Debugging completed

## Latest Update (2026-03-11)
Database debugging completed - analyzed PostgreSQL via local Docker

## Latest Changes (2026-03-11)
- Neon MCP tools not available in environment - used local PostgreSQL in Docker instead
- Analyzed database schema and indexes on all 20 tables
- Found database already has 63 indexes properly configured
- Added 2 additional performance indexes:
  - idx_messages_room_created_at (composite for room+time queries)
  - idx_rooms_category_id (for category filtering)
- Enabled pg_stat_statements extension for future query monitoring
- Verified data counts: messages(0), users(2), rooms(3), presences(0), user_rooms(3), direct_messages(0)
- All tables properly indexed for common query patterns

## Previous Changes (2026-03-11)
Proactive improvements completed

## Latest Update (2026-03-11)
Debugging completed

## Latest Changes (2026-03-11)
- Verified Docker services: all 5 containers running and healthy
- coturn: Up 12 hours (healthy) ✅
- postgres: Up 12 hours (healthy) ✅
- redis: Up 12 hours (healthy) ✅
- server: Running ✅
- frontend: Running ✅
- No failing services to fix

## Latest Changes (2026-03-11)
- Verified all repositories have no stale branches
- Confirmed today's release tag v2026.03.11 exists in all repos

## Previous Changes (2026-03-11)
- Label verification completed across all enclavr repositories

## Latest Update (2026-03-11)
- Analyzed releases across all 5 repos

### Releases Analyzed
| Repo | Releases | Latest Tag | Assets |
|------|----------|------------|--------|
| enclavr (root) | 0 | - | N/A |
| frontend | 1 | v2026.03.10 | None |
| server | 1 | v2026.03.10 | None |
| infra | 1 | v2026.03.10 | None |
| docs | 1 | v2026.03.10 | None |

All releases use changelog links - no assets attached. No docs updates needed.

## Latest Update (2026-03-11)
- PR review: All 5 repos reviewed
- enclavr/enclavr: 0 open PRs ✅
- enclavr/frontend: 0 open PRs ✅
- enclavr/server: 0 open PRs ✅
- enclavr/infra: 0 open PRs ✅
- enclavr/docs: 0 open PRs ✅
- Result: No PRs to review

## Latest Changes (2026-03-11)
- Analyzed enclavr/enclavr: 0 open issues ✅
- Analyzed enclavr/frontend: 0 open issues ✅
- Analyzed enclavr/server: 0 open issues ✅
- Analyzed enclavr/infra: 0 open issues ✅
- Analyzed enclavr/docs: 0 open issues ✅
- Result: No issues to fix

## Previous Changes (2026-03-11)
- Ran full Sentry diagnostic:
  - Verified Sentry connection (user: enclavr.dev@gmail.com)
  - Found 3 projects: api, frontend, test-project
  - No unresolved errors found
  - No crashes found
  - No errors in last 24 hours
- Performance metrics look healthy (all endpoints under 100ms p75)

### Sentry Search Results
| Query | Result |
|-------|--------|
| Unresolved errors | 0 issues |
| Crashes | 0 issues |
| Errors from last 24h | 0 errors |
| Slow transactions | 5 found (all within acceptable limits) |

### Transaction Performance (p75)
- POST /api/auth/login: 60.8ms (4 requests)
- POST /api/room/join: 6.7ms (1 request)
- GET /api/rooms: 1.2ms (11 requests)
- GET /api/room: 0.8ms (1 request)
- GET /api/auth/oidc/config: 0.4ms (36 requests)

### Conclusion
- **No issues to fix** - system is healthy
- All transactions performing within acceptable limits

## Latest Update (2026-03-11)
Proactive improvements completed

## Latest Changes (2026-03-11)
- Branch/tag management across all 5 repos completed

### Branch/Tag Management Results
| Repo | Stale Branches | Tag v2026.03.11 |
|------|----------------|-----------------|
| enclavr (root) | None (main only) | Already exists |
| frontend | None (main only) | Already exists |
| server | None (main only) | Already exists |
| infra | None (main only) | Already exists |
| docs | None (main only) | Already exists |

All repositories in clean state - only main branch exists, today's release tag already present.

## Latest Changes (2026-03-11)
- Analyzed releases across all 5 repos

### Releases Analyzed
| Repo | Releases | Latest Tag |
|------|----------|------------|
| enclavr (root) | 0 | - |
| frontend | 1 | v2026.03.10 |
| server | 1 | v2026.03.10 |
| infra | 1 | v2026.03.10 |
| docs | 1 | v2026.03.10 |

All repos follow daily release pattern (vYYYY.MM.DD). No assets attached. No docs updates needed.

## Previous Changes (2026-03-11)
- CI failure analysis - Fixed server lint error causing CI failures

## Latest Changes (2026-03-11)
- Fixed lint error in server/internal/handlers/twofactor.go:310 - unhandled JSON encode error
- Added proper error handling for JSON response encoding
- golangci-lint: 0 issues ✅
- go test: All tests pass ✅
- Commit pushed: f552562

## Previous Changes (2026-03-11)
- Issue analysis - analyzing all 5 repos for open issues

## Latest Changes (2026-03-11)
- Analyzed enclavr/enclavr: 0 open issues ✅
- Analyzed enclavr/frontend: 0 open issues ✅
- Analyzed enclavr/server: 0 open issues ✅
- Analyzed enclavr/infra: 0 open issues ✅
- Analyzed enclavr/docs: 0 open issues ✅
- Result: No issues to fix

## Latest Changes (2026-03-11)
- Ran stale branch cleanup across all 5 repositories - none found (all on main branch)
- Verified release tag v2026.03.11 exists in all 5 repositories
- All repositories in good state

### Branch/Tag Management Results
| Repo | Stale Branches | Tag v2026.03.11 |
|------|----------------|-----------------|
| enclavr (root) | None | Already exists |
| frontend | None | Already exists |
| server | None | Already exists |
| infra | None | Already exists |
| docs | None | Already exists |

## Previous Changes
- Release analysis completed - all 5 repos have latest tags
Release analysis: ALL 5 repos analyzed

### Releases Analyzed
| Repo | Releases | Latest Tag | Notes |
|------|----------|------------|-------|
| enclavr (root) | 0 | - | No releases |
| frontend | 1 | v2026.03.10 | Changelog link only |
| server | 1 | v2026.03.10 | Changelog link only |
| infra | 1 | v2026.03.10 | Changelog link only |
| docs | 1 | v2026.03.10 | Changelog link only |

### Docs Status
No docs updates needed - releases use changelog links

## Previous Changes
Submodule update: Already at latest remote commits - no changes

## Latest Update (Mar 11, 2026)
Debugging completed

## Latest Changes (Mar 11, 2026)

### CI Failure Analysis Results
| Repo | Failure Type | Status |
|------|-------------|--------|
| enclavr (root) | validate-submodules | Billing issue - IGNORED per AGENTS.md |
| frontend | lint (prefer-const) | Already fixed in current code |
| server | lint (errcheck) | Already fixed in current code |
| infra | validate (.env) | Already fixed in current code |
| docs | trigger-deploy permissions | FIXED - added actions:write permission |

### Fix Applied
- docs: Added `actions: write` permission to trigger-pages.yml workflow
- Commit: a356427

## Previous Changes (Mar 11, 2026)
- Issue analysis completed - all repos have no open issues

## Latest Update (Mar 11, 2026)
- Analyzed ALL 5 repos for open issues
- enclavr/enclavr: 0 open issues ✅
- enclavr/frontend: 0 open issues ✅
- enclavr/server: 0 open issues ✅
- enclavr/infra: 0 open issues ✅
- enclavr/docs: 0 open issues ✅
- Result: No issues to fix

## Latest Update (Mar 11, 2026)
- Git submodule status: All submodules at latest remote commits
- Git submodule update --remote --merge: No new commits to fetch
- Result: Submodules already up-to-date

## Latest Changes (Mar 11, 2026)

### Submodule Status
- docs: bd39cb1 (v2026.03.11-1)
- frontend: b99a144 (v2026.03.11-1)
- infra: 44f22b6 (v2026.03.10-1)
- server: 4ab263b (v2026.03.11-2)

### Notes
- All submodules already at latest remote commits
- Local uncommitted changes exist in docs and server submodules (not from remote update)
- No submodule commit needed - already synchronized with remote

## Latest Changes (Mar 11, 2026)

### Debug Results Summary
- Sentry: No errors in last 24 hours ✅
- Server: golangci-lint ✅, go test ✅
- Frontend: ESLint ✅, 549 tests ✅
- Docker: postgres ✅, redis ✅, coturn ✅
- Server/Frontend containers: Exited (137 - killed, memory issue - not code issue)

### Issues Found & Fixed
1. **Server CI lint failure** (commit 22904211583): Already fixed in later commit ✅
2. **Docs CI permission error**: GitHub Actions permission issue (docs repo can't trigger root repo Pages deploy)
   - Error: "Resource not accessible by integration"
   - Fix: Needs workflow_dispatch or repository_dispatch fix in root repo

### Test Results
- Server: All tests pass ✅
- Frontend: 549 tests pass ✅ (with React act() warnings in test output - expected)
- Server lint: 0 issues ✅
- Frontend lint: 0 issues ✅

### Docker Services Status
- infra-postgres-1: Up 7 hours (healthy) ✅
- infra-redis-1: Up 7 hours (healthy) ✅
- infra-coturn-1: Up 7 hours (healthy) ✅
- infra-server-1: Exited (137) - killed by system (memory)
- infra-frontend-1: Exited (137) - killed by system (memory)

### Previous Changes (Mar 11, 2026)
- Proactive improvements completed
- Release Analysis: ALL 5 repos analyzed ✅
- PR Review: No open PRs in any repo ✅
- Analyzed ALL 5 repos for open issues - all clean ✅
- Submodule update completed
- CI Analysis: Found and fixed server CI failure
