# Active Context - enclavr-root

## Current Work Focus
Submodule maintenance completed

## Latest Changes (2026-03-20)
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

## Previous Changes (2026-03-20)
- Regression Monitoring Completed - no regressions detected
- GitHub PR review completed - no open PRs across all repos
- Branch/Tag management completed

