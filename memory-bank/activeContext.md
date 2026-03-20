# Active Context - enclavr-root

## Current Work Focus
Debugging completed

## Latest Update (2026-03-20)
- Submodule update checked - all submodules already at latest remote versions
- Debugging completed
- Analyzed Sentry issues across enclavr organization
- No critical errors, unresolved issues, or crashes detected
- All repos operational

## Latest Changes (2026-03-20)
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
- **Submodules updated:** server, frontend, docs
- **Previous:** Regression monitoring completed

## Previous Changes (2026-03-20)
- Regression Monitoring Completed - no regressions detected
- GitHub PR review completed - no open PRs across all repos
- Branch/Tag management completed

