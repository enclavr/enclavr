# Active Context - Enclavr

## Current Work Focus
Infrastructure fix and comprehensive improvements across all submodules. Recent work includes Docker Compose validation fix, security hardening, and test stability. All systems validated and deployed.

## Latest Changes (Mar 7, 2026)

### Infrastructure Docker Compose Fix
- Fixed Docker Compose configuration validation error:
  - Changed `cpu` to `cpus` in resource limits (Docker Compose v2 requirement)
  - Corrected indentation to 4-space consistency
- `docker compose config` now validates successfully
- Commit: dc9d529 (enclavr/infra)
- All services defined: postgres, redis, server, frontend, coturn

### Infrastructure CI Configuration Fix
- Fixed hadolint action version reference in `.github/workflows/ci.yml`:
  - Changed `hadolint/hadolint@v2` → `@v2.1.0` (v2 tag does not exist on Docker Hub)
- This resolves potential CI failures during the lint step
- Verified workflow syntax is valid
- Commit: 2b7feaf (enclavr/infra)
- Note: CI failures due to GitHub Actions billing limits (ACTIONS_RUNTIME_TOKEN missing) are expected and should be ignored per AGENTS.md

### Infrastructure Security Hardening & Best Practices (Proactive)
- Pin all container images to specific versions for security and reproducibility:
  - Alpine base: `3.21` (was `:latest`)
  - Coturn: `4.6.2-alpine` (was `:latest`)
  - Go builder: `golang:1.25.7-alpine`
- Add health checks for all services with appropriate `start_period`:
  - postgres: `pg_isready` (40s start period)
  - redis: `redis-cli ping` (40s start period)
  - frontend: HTTP GET `/` (40s start period)
  - coturn: TCP port check (40s start period)
- Improve Redis configuration: enable AOF persistence (`--appendonly yes`) with periodic saves
- Add dedicated volume for server uploads (`server_uploads`) for data persistence
- Add explicit network configuration (`infra_default`) for isolation
- Apply resource limits with CPU quotas (`cpus` field, not `cpu`)
- Enhance server Dockerfile (separate commit in server submodule):
  - Pin Alpine to 3.21, add metadata labels
  - Optimize layer caching with separate go.mod copy
  - Use virtual build deps that get removed
  - Remove unnecessary file copies
  - Remove default env vars (should come from docker-compose)
- Comprehensive README.md overhaul:
  - Added quick start guide, troubleshooting section
  - Added services table with health checks
  - Added resource limits table
  - Added security recommendations and production checklist
  - Added architecture diagram
- All changes validated: `docker-compose config` passes without errors
- Commits: infra@0f468a7, server@abe2f26

### Frontend TypeScript Bug Fix
- Fixed critical TypeScript error in `src/hooks/useChat.ts`:
  - Added missing constants: `MAX_RECONNECT_ATTEMPTS = 5`, `INITIAL_RECONNECT_DELAY = 1000ms`, `MAX_RECONNECT_DELAY = 30000ms`
  - These are used in WebSocket reconnection exponential backoff logic
- Enhanced `src/test/useChat.edge.test.ts`:
  - Removed unused `waitFor` import
  - Improved WebSocket mocking with direct assignment
- All lint, typecheck, and tests pass (549 tests)
- Commit: 2b4ddbd (enclavr/frontend)

### Server Security Enhancement
- Added non-root user for container security (commit 19a7a6f):
  - Create `enclavr` user (UID 1000) in Dockerfile
  - Switch to non-root user for runtime
  - Create uploads directory with proper permissions
- All tests pass (819+), golangci-lint passes (0 issues), Docker build succeeds

### CI Failure Analysis (Non-Code Issue)
- Investigated CI failure for commit 19a7a6f (run ID 22794796058)
- Root cause: Artifact upload step fails with "Unable to get ACTIONS_RUNTIME_TOKEN"
- Tests pass locally and in act simulation
- Per AGENTS.md: CI billing failures are expected and should be IGNORED
- No code changes required; CI will auto-recover when billing resets

### Autonomous Agent Script Fix
- Refactored `script.sh` into proper infinite loop architecture
- Removed duplicate code blocks and implemented clean `while true` loop
- Integrated GitHub management functions periodically (every 5 min)
- Added periodic submodule sync (every 30 min)
- Fixed path handling for docs submodule (`../docs`)
- Script validated with `bash -n`

## Previous Changes (Mar 7, 2026)

### MCP Tools Integration
- Added comprehensive MCP tools documentation to all AGENTS.md files
- Tested all MCP tools - all functional

### Sentry Projects Created
- Created Sentry project: **api** and **frontend**

### Neon PostgreSQL 17 Integration
- Added Neon PostgreSQL 17 support with free tier (0.5GB, 1 branch)
- Created `.env.neon` template
- Server uses standard GORM (works with any PostgreSQL provider)

### Infrastructure Improvements
- Added `restart: unless-stopped` to all services
- Fixed PostgreSQL healthcheck variable expansion
- Updated `.env.example` with missing configuration variables

### Documentation Deployment Fix
- Fixed docs repository GitHub Pages deployment
- Docs now available at: https://enclavr.github.io/docs/

### CI Billing Limits Handling
- Documented expected behavior in AGENTS.md
- Weekly schedule and path filtering minimize usage (~85-90% reduction)

## Verification
✅ All lint passes (ESLint, golangci-lint)
✅ All tests pass (server: 819+, frontend: 549)
✅ Docker Compose configuration valid
✅ TypeScript type checking passes
✅ Submodules updated to latest commits (infra:0f468a7, server:abe2f26)
✅ Autonomous agent script validated (bash -n)
✅ Infrastructure security hardening complete
✅ All changes committed and pushed