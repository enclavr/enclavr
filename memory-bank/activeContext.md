# Active Context - Enclavr

## Current Work Focus
Infrastructure improvements and documentation fixes. Recent work includes:
- Enhanced Docker Compose configuration with restart policies and healthcheck fixes
- Updated environment variable documentation to be complete
- Fixed GitHub Pages deployment for docs repository
- Addressed CI billing limits handling (documented expected behavior)

## Latest Changes (Mar 7, 2026)

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
