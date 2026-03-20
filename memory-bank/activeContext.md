# Active Context - enclavr-root

## Current Work Focus
Regression monitoring completed - no issues found

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

