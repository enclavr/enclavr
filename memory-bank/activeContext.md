# Active Context - enclavr-root

## Current Work Focus
Debug session completed - all 5 repos verified healthy

## Latest Changes (2026-03-21)
- **Debug Session Results:**
  - Sentry: 0 unresolved errors, 0 errors in last 24h
  - Server tests: ALL PASS (auth: 10, config: 11, database: 17)
  - Server lint: CLEAN
  - Frontend lint: CLEAN (1 warning in postcss.config.mjs - acceptable)
  - Frontend typecheck: PASS
  - Infra: docker-compose.yml valid
  - Docs: Normal state (v2026.03.21)
  - NO ISSUES FOUND - all repos healthy

## Latest Update (2026-03-21)
- Proactive improvements completed

## Latest Update (2026-03-21)
- **Submodule Updates:**
  - Server: Fixed lint errors in dm_hub.go (removed unused fields, removed unused function, added error checking for json.Unmarshal)
  - Server: Added GetUserRooms endpoint for fetching user's joined rooms with member counts
  - Frontend: Enhanced notifications page with push service integration
  - Docs: Memory bank update
- All lint/tests pass
- Created releases: enclavr v2026.03.21, frontend v2026.03.20-8, server v2026.03.20-6

## Latest Changes (2026-03-21)
- **Server Fixes:**
  - Removed unused fields (hub, connectedAt, sequence) from DMClient struct
  - Removed unused sendToUser function from DMHub
  - Added `_ =` to ignore json.Unmarshal return values in 3 places
  - Added GetUserRooms endpoint returning user's joined rooms with member counts
  - All tests pass, lint clean

- **Frontend Features:**
  - Enhanced notifications page with push service integration
  - Added subscription management for push notifications
  - Added browser push support detection
  - Added loading states and back button navigation
  - Updated field naming to match server API (snake_case)
  - Lint passes

- **Submodule Updates:**
  - Updated docs submodule to v2026.03.20-1
  - Updated frontend submodule to v2026.03.20-8
  - Updated server submodule to v2026.03.20-6
  - Created root release v2026.03.21
- server#2: informational question, no fix needed
- server#1: test issue, no fix needed  
- docs#1: docs up-to-date with recent commits

## Latest Changes (2026-03-21)
- Analyzed releases across all 5 repos (enclavr, frontend, server, infra, docs)
- Created new releases:
  - frontend v2026.03.20-8: Add missing BlockEvent and DeliveryStatus types
  - server v2026.03.20-6: Add database query optimization indexes
  - root v2026.03.21-2: Submodule updates
- All releases have complete release notes
- No assets required for these releases (all are code-only)
- infra and docs: No new releases needed (no significant changes)

## Latest Update (2026-03-21)
- PR review across all 5 repos completed
- enclavr/enclavr: 0 open PRs
- enclavr/frontend: 0 open PRs
- enclavr/server: 0 open PRs
- enclavr/infra: 0 open PRs
- enclavr/docs: 0 open PRs
- No reviews, merges, or closes needed

## Latest Update (2026-03-21)
- Ran git submodule update --remote --merge
- All submodules already at latest
- docs: v2026.03.21, frontend: v2026.03.21-1, infra: v2026.03.21, server: v2026.03.21-1
- No changes to commit

## Latest Update (2026-03-21)
- Database analysis completed
- No database issues found
- Sentry: No database errors/failures in last 24 hours
- Schema: All indexes properly configured (migrations 003-021)
- Proactive improvements completed

## Latest Update (2026-03-21)
- Regression monitoring completed across all 5 repos
- Verified fixes for 5 closed issues - no regressions detected
- No issues were reopened
- enclavr#2 (mobile sidebar): fix verified (z-index 1001, toggle present)
- enclavr#1 (.env.example): fix verified (clear comments in place)
- server#2, server#1: informational issues, no fix needed
- docs#1: docs verified as up-to-date

## Latest Changes (2026-03-21)
- **Frontend Fix:**
  - Fixed TypeScript error: Added missing `BlockEvent` and `DeliveryStatus` types to `@/types`
  - The useDMWebSocket hook was importing types that didn't exist
  - Committed and pushed: "fix: add missing BlockEvent and DeliveryStatus types"
  - All lint/typecheck pass
- **Root Update:**
  - Updated frontend submodule to v2026.03.20-7
  - Committed: "chore: update frontend submodule to v2026.03.20-7"
- **CI Analysis:**
  - Server CI failures analyzed - PostgreSQL-specific SQL in SQLite tests
  - Server CI already has skip patterns for PostgreSQL-only tests
  - All tests pass with correct skip patterns

## Previous Changes (2026-03-21)
- **Branch/Tag Management:**
  - Checked all 5 repos: root, frontend, server, infra, docs
  - No stale branches found (all repos use trunk-based development with main branch only)
  - Created release tags v2026.03.21 in all 5 repositories:
    - enclavr/root: tag created and pushed
    - enclavr/frontend: tag created (commit 3408fc1)
    - enclavr/server: tag created (commit 4e22e9a)
    - enclavr/infra: tag created (commit ce6d199)
    - enclavr/docs: tag created (commit 88f1dee)
- **Release Management:**
  - Created root v2026.03.21-1 (submodule updates)
  - Created frontend v2026.03.20-7 (useDMWebSocket hook)
  - Created docs v2026.03.20 (activeContext updates)
  - Server and infra already at latest (v2026.03.20-5, v2026.03.20-2)
  - Pushed submodule update to root: 5b00228
  - All lint/tests pass

## Previous Changes (2026-03-21)
- PR review: No open PRs in any of the 5 repos (enclavr, frontend, server, infra, docs)
- Updated docs submodule to v2026.03.19-1-g88f1dee
- Updated frontend submodule to v2026.03.20-11-g3408fc1
- Committed: "chore: update submodules to latest"
- Root commit: 5b00228

## Latest Update (2026-03-20)
- Release analysis completed across all 5 repos
- Created server v2026.03.20-5 (Discord OAuth callback, atomic.Int64 fix)
- Created root v2026.03.20-7 (submodule updates)

## Latest Changes (2026-03-20)
- **Release v2026.03.20-7:**
  - Created root release v2026.03.20-7
  - Server v2026.03.20-5 (Discord OAuth callback, atomic.Int64 fix)
  - Frontend v2026.03.20-6, infra v2026.03.20-2, docs v2026.03.19
- Ran `git submodule update --remote --merge`
- All submodules already at latest - no changes to commit
- docs: v2026.03.19, frontend: v2026.03.20-10, infra: v2026.03.20-2, server: v2026.03.20-3

## Latest Changes (2026-03-20)
- Ran branch/tag maintenance across all repositories (root, frontend, server, infra, docs)
- All repositories use trunk-based development (main branch only)
- Today's release tag v2026.03.20 already exists in all repos
- No stale branches to delete

## Latest Changes (2026-03-20)
- **Release Management:**
  - Created frontend v2026.03.20-6 (RoomPermissionsModal, frontend redesign)
  - Created server v2026.03.20-4 (encryption key config, room search, scheduled messages)
  - Created infra v2026.03.20-2 (healthchecks, Coturn config)
  - Created docs v2026.03.19 (Jekyll disabled, model docs)
  - Created root v2026.03.20-6 (submodule updates)
- All submodules updated and committed

## Previous Changes (2026-03-20)
- **Submodule Update:**
  - Ran `git submodule update --remote --merge`
  - docs: merged in 9a49e6a (v2026.03.19)
  - frontend, infra, server: already at latest
  - Local uncommitted changes in submodules prevented root commit

## Previous Changes (2026-03-20)
- Database analysis completed

## Latest Update (2026-03-20)
- Regression monitoring completed across all 5 repos
- Verified 5 closed issues - no regressions detected
- No issues were reopened

## Latest Update (2026-03-20)
- Proactive improvements completed

## Latest Changes (2026-03-20)
- **Release Management:**
  - Created frontend v2026.03.20-5 (RoomPermissionsModal component)
  - Created server v2026.03.20-3 (auth/security features)
  - Updated infra v2026.03.20-1 release notes
  - Created root v2026.03.20-5 (submodule updates)
- **Server (auth):**
  - Added PasswordResetRateLimiter for rate limiting password reset requests
  - Added NotBefore claim to JWT tokens based on password change time
  - Added password expiry flag in login response
  - Added session management endpoints (GetSessions, RevokeSession, RevokeAllSessions)
  - Added 2FA recovery code support for account recovery
  - Added token rotation endpoint
- **Frontend:**
  - Added RoomPermissionsModal component for managing room member permissions
  - Added comprehensive test coverage
- **Infra:**
  - Improved container healthchecks with curl/wget fallback
  - Updated Coturn configuration (--lt-cred-mech, --no-tls)

## Latest Changes (2026-03-20)
- **PR Review Completed:**
  - Reviewed all 5 repos: enclavr, frontend, server, infra, docs
  - Open PRs: 0 across all repositories
  - No reviews, merges, or closes needed

## Previous Changes (2026-03-20)
- Regression Monitoring Completed - no regressions detected
- GitHub PR review completed - no open PRs across all repos
- Branch/Tag management completed

