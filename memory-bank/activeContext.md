# Active Context - Enclavr

## Current Work Focus
Documentation restructuring complete - moved static HTML docs into main repo. All systems validated and working.

## Latest Changes (Mar 7, 2026)

### Documentation Restructuring
- Converted Docusaurus docs to static HTML pages
- Moved docs from separate repository into `/docs` folder in main repo
- Created 27 HTML documentation pages with responsive CSS sidebar navigation
- Updated GitHub Pages workflow to deploy from `/docs` folder
- All paths fixed for relative navigation
- Docs accessible at: https://enclavr.github.io/enclavr/docs/ (when GitHub Pages enabled)

### Files Changed
- README.md: Added docs section and GitHub Pages info
- AGENTS.md: Added docs repository to project structure table
- script.sh: Already handles docs in REPOS list (no changes needed)
- Created docs/index.html - Home page
- Created docs/docs/*.html - 26 documentation pages
- Created docs/css/style.css - Responsive styling
- Created docs/img/ - Assets folder

## Previous Changes (Mar 7, 2026)

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

### Infrastructure Security Hardening & Best Practices
- Pin all container images to specific versions for security and reproducibility
- Add health checks for all services with appropriate `start_period`
- Improve Redis configuration: enable AOF persistence
- Add dedicated volume for server uploads
- Add explicit network configuration for isolation
- Apply resource limits with CPU quotas
- Enhance server Dockerfile with non-root user

### Frontend TypeScript Bug Fix
- Fixed critical TypeScript error in `src/hooks/useChat.ts`:
  - Added missing constants: `MAX_RECONNECT_ATTEMPTS = 5`, `INITIAL_RECONNECT_DELAY = 1000ms`, `MAX_RECONNECT_DELAY = 30000ms`
- Enhanced `src/test/useChat.edge.test.ts`:
  - Removed unused `waitFor` import
  - Improved WebSocket mocking
- All lint, typecheck, and tests pass (549 tests)
- Commit: 2b4ddbd (enclavr/frontend)

### Server Security Enhancement
- Added non-root user for container security
- All tests pass (819+), golangci-lint passes (0 issues)

### Autonomous Agent Script Fix
- Refactored `script.sh` into proper infinite loop architecture
- Integrated GitHub management functions periodically
- Added periodic submodule sync
- Fixed path handling for docs

## Verification
✅ README.md updated with docs section
✅ AGENTS.md updated with docs repository
✅ script.sh handles docs as folder (not submodule)
✅ All documentation pages created in docs/ folder
✅ GitHub Pages ready - deploy from /docs folder
