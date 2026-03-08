# Active Context - Enclavr

## Current Work Focus (Mar 8, 2026)
Proactive improvements completed

## Latest Update (Mar 8, 2026)

### Changes Made
- Proactive improvements completed

## Previous Changes (Mar 8, 2026)

### Script.sh Provider Alternation
- Refactored script.sh to alternate between kilo and opencode
- Added `run_agent()` function that switches providers on each call
- Added `find_agent()` to locate both kilo and opencode binaries
- Changed variable prefix from `KILO_*` to `AGENT_*`

### Script.sh Shared State
- Added shared state via `memory-bank/shared-state.md`
- Both agents read previous session info before running
- Records: provider, task, status, exit code, error details
- Enables continuity between kilo and opencode sessions

### Script.sh AI Review for Commits
- Added two-step commit process: review then commit
- AI reviews changes for security issues, dangerous operations, broken code
- Must respond with APPROVE: or REJECT: format
- Only commits if approved

### Script.sh Full Kilo Integration
- All git operations now use Kilo: commit/push, submodule updates
- All GitHub operations now use Kilo: labels, repo sync
- Memory bank updates now use Kilo
- Rate limit checks remain as direct CLI (for flow control)

### Git History Rewrite
- Rewrote all commit history in all 5 repos (root, frontend, server, infra, docs)
- Changed author from various emails (ai@enclavr.dev, dev@enclavr.local) to enclavr.dev@gmail.com
- Changed author name to "Enclavr AI" across all commits
- Updated CI workflow to use new email address

### Documentation Navigation Fixes
- Fixed broken relative links in all 27 static HTML documentation pages
- Root docs/index.html: Fixed sidebar links from `docs/*.html` to `*.html`
- docs/template.html: Fixed relative paths for template
- All 26 files in docs/docs/*.html: Replaced `href=""` with `href="../index.html"`
- GitHub Pages now works correctly at https://enclavr.github.io/enclavr/docs/

### MCP Tools Documentation
- Analyzed all available MCP tools in the codebase
- Updated all AGENTS.md files with complete MCP tools coverage:
  - Root AGENTS.md: Added sequential_thinking, additional Neon tools, additional Sentry tools
  - frontend/AGENTS.md: Added Sentry tools, sequential thinking, Neon docs tools
  - server/AGENTS.md: Added sequential thinking tool
  - infra/AGENTS.md: Added Sentry MCP tools, sequential thinking
- Updated README.md to reference MCP tools
- Updated script.sh to reference MCP tools

### Playwright Testing
- Created comprehensive E2E tests for frontend (`/home/dev/Projects/enclavr/frontend/e2e/`):
  - rooms.spec.ts: 58 tests for rooms page with real data (users, rooms, categories, messages, presence)
  - voice.spec.ts: 36 tests for voice chat/WebRTC (ICE config, user states, controls)
- Created Playwright tests for static HTML docs (`/home/dev/Projects/enclavr/docs/e2e/`):
  - docs.spec.ts: 115 tests covering all 27 documentation pages
  - Tests: homepage, sidebar navigation, API docs, frontend docs, server docs, infra docs
  - Cross-references, responsive design, accessibility, performance, styling
- Created docs playwright.config.ts with file:// protocol support
- Created docs package.json with matching Playwright version

### Test Results
- Frontend sample tests: 9/9 passing
- Docs tests: 115/115 passing
- Frontend rooms/voice tests: Require authenticated server (expected)

## Previous Changes (Mar 8, 2026)

### Script.sh Provider Alternation
- Converted docs folder to proper git submodule
- Created new https://github.com/enclavr/docs repo
- Added .gitignore to docs repo (exclude node_modules, test-results)
- Created comprehensive LICENSE file with The Unlicense
- Added AI-Generated Code Notice and AI Training Prohibition
- Added Legal Compliance Disclaimer for export controls, data protection

### Autonomous Agent Script Improvements
- Added gh CLI validation (check_gh_cli function)
- Implemented timeout handling (KILO_TIMEOUT=600)
- Fixed submodule update logging

### Documentation Restructuring
- Converted Docusaurus docs to static HTML pages
- Created 27 HTML documentation pages with responsive CSS

### Infrastructure Docker Compose Fix
- Changed `cpu` to `cpus` in resource limits
- Docker Compose v2 validation passes

### Infrastructure Security Hardening
- Pin container images to specific versions
- Add health checks for all services
- Non-root user for containers

### Server Security Enhancement
- Added non-root user for container security
- All tests pass (819+), golangci-lint passes (0 issues)

(End of file - total 75 lines)
