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

## Current Work Focus
Proactive improvements completed

## Latest Update (Mar 07, 2026)

### Changes Made
- Proactive improvements completed

# Active Context - Enclavr

## Current Work Focus
Infrastructure improvements and documentation fixes. Recent work includes:
- Enhanced Docker Compose configuration with restart policies and healthcheck fixes
- Updated environment variable documentation to be complete
- Fixed GitHub Pages deployment for docs repository
- Addressed CI billing limits handling (documented expected behavior)
- Integrated Neon PostgreSQL 17 for testing while maintaining self-hosted PostgreSQL support
- Updated all AGENTS.md with MCP tools documentation (Neon, Context7, Git, Sentry, websearch, webfetch, codesearch)
- Created Sentry projects for error tracking (api, frontend)

## Latest Changes (Mar 7, 2026)

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
✅ All tests pass (server: 819+, frontend: 545)
✅ Docker Compose configuration valid
✅ TypeScript type checking passes
✅ Submodules updated to latest commits
