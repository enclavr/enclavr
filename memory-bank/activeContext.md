## Current Work Focus
Changes processed and improvements implemented

## Latest Update (Mar 07, 2026)

### Changes Made
- Changes processed and improvements implemented

## Current Work Focus
Changes processed and improvements implemented

## Latest Update (Mar 07, 2026)

### Changes Made
- Changes processed and improvements implemented

# Active Context - Enclavr

## Current Work Focus
Critical bug fixes and quality improvements across the monorepo. Recent work includes security enhancements, TypeScript error fixes, and test infrastructure improvements. All systems validated and deployed.

## Latest Changes (Mar 7, 2026)

### Frontend TypeScript Bug Fix
- Fixed critical TypeScript error in `src/hooks/useChat.ts`:
  - Added missing constants: `MAX_RECONNECT_ATTEMPTS`, `INITIAL_RECONNECT_DELAY`, `MAX_RECONNECT_DELAY`
  - These constants are used in WebSocket reconnection logic with exponential backoff
  - Without them, the hook would fail at runtime and during type checking
- All lint, typecheck, and tests now pass (549 tests)

### Frontend Test Infrastructure Improvement
- Enhanced `src/test/useChat.edge.test.ts`:
  - Removed unused `waitFor` import from test file
  - Improved WebSocket mocking by using direct assignment `globalThis.WebSocket = MockWebSocket` instead of `vi.stubGlobal`
  - More reliable test isolation and cleaner mocks
- All 38 tests in this file pass

### Server Security Enhancement
- Added non-root user for container security (commit 19a7a6f):
  - Create `enclavr` user (UID 1000) in Dockerfile
  - Switch to non-root user for runtime
  - Create uploads directory with proper permissions
  - Enhances security posture for production deployments
- Server tests pass (819+), lint passes, build succeeds

### Autonomous Agent Script Architecture Fix
- Refactored `script.sh` into proper infinite loop architecture:
  - Removed duplicate code blocks (lines 464-974 had two copies of main logic)
  - Restructured as `while true` loop with clear phases
  - Integrated GitHub management functions (issues, PRs, CI, releases, labels) as periodic checks every 5 minutes
  - Added periodic submodule sync every 30 minutes with tracking
  - Preserved change detection and proactive improvement cycles
  - Fixed path handling for docs submodule (`../docs`)
  - Maintained cooldown mechanism (30 minutes) and adaptive sleep (30s/60s)
- Script validated with `bash -n` (syntax OK)

## Previous Changes (Mar 7, 2026)

### MCP Tools Integration
- Added comprehensive MCP tools documentation to all AGENTS.md files:
  - Neon Database MCP: PostgreSQL operations, migrations, query tuning
  - Context7 MCP: Library documentation lookup (React, Next.js, Go, etc.)
  - Git MCP: Version control operations
  - Sentry MCP: Error tracking and monitoring
  - Web Search/Fetch: Current information and code examples
- Tested all MCP tools - all functional

### Sentry Projects Created
- Created Sentry project: **api** (DSN: https://bc4efb79c26f87983bdc64b05e8ed834@o4511001039011840.ingest.us.sentry.io/4511001064701952)
- Created Sentry project: **frontend** (DSN: https://6774674f354796de422f5d12c1be29f4@o4511001039011840.ingest.us.sentry.io/4511001065160704)

### Neon PostgreSQL 17 Integration
- Cleaned up Neon database (dropped test branch, cleared data)
- Created `server/.env.neon` with Neon PostgreSQL 17 connection configuration
- Updated `.env.example` with documentation for Neon vs self-hosted PostgreSQL
- No Neon SDK used - server uses standard GORM with PostgreSQL driver (works with any PostgreSQL)
- Neon free tier limits: 0.5GB storage, 1 project, 1 branch (suitable for testing)
- Server auto-creates tables via GORM migrations

### Infrastructure Improvements
- Added `restart: unless-stopped` to all services (postgres, redis, server, frontend, coturn) for production reliability
- Fixed PostgreSQL healthcheck to use `${POSTGRES_USER:-enclavr}` instead of hardcoded user
- Updated `.env.example` with previously missing configuration variables:
  - `ALLOWED_ORIGINS` for CORS configuration
  - `MAX_UPLOAD_SIZE_MB` and `UPLOAD_DIR` for file upload settings
  - `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`, `VAPID_SUBJECT` for push notifications
- All changes validated with `docker-compose config` (syntax valid)

### Documentation Deployment Fix
- Fixed docs repository GitHub Pages deployment
- Changed workflow to use `deploy_key` input (correct parameter name)
- Generated SSH deploy key with write access
- Made docs repository public (required for GitHub Pages)
- Docs now available at: https://enclavr.github.io/docs/

### CI Billing Limits Handling
- Documented expected behavior in AGENTS.md:
  - CI failures due to billing limits are expected and should be IGNORED
  - CI automatically resumes when billing cycle resets (start of month)
  - NEVER attempt to fix billing-limit-related CI failures
- Weekly schedule and path filtering already minimize usage (~85-90% reduction)

## Verification
✅ All lint passes (ESLint, golangci-lint)
✅ All tests pass (server: 819+, frontend: 549)
✅ Docker Compose configuration valid
✅ TypeScript type checking passes
✅ Submodules updated to latest commits
✅ Autonomous agent script syntax validated (bash -n)
✅ Server security enhancement deployed (non-root user)
✅ Frontend TypeScript errors resolved
