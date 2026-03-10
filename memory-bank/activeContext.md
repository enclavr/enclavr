# Active Context - Enclavr

## Current Work Focus (Mar 10, 2026)
Debugging completed

## Latest Update (Mar 10, 2026)
- Branch/Tag Management: All 5 repos checked
  - Branches: Only main in all repos (trunk-based) ✅
  - Tags: v2026.03.10 exists in all repos ✅
- Release Analysis: Created GitHub Releases for v2026.03.10
  - frontend: https://github.com/enclavr/frontend/releases/tag/v2026.03.10 ✅
  - server: https://github.com/enclavr/server/releases/tag/v2026.03.10 ✅
  - infra: https://github.com/enclavr/infra/releases/tag/v2026.03.10 ✅
  - docs: https://github.com/enclavr/docs/releases/tag/v2026.03.10 ✅
- PR Review: No open PRs in any repo
- Proactive improvements completed
  - Sentry verified: 3 projects (api, frontend, test-project)
  - No Sentry errors in last 24 hours ✅
  - All CI failures already fixed in previous commits
  - Labels verified in all 5 repos ✅
  - Release tags created (v2026.03.10)
- CI Failure Analysis: All 5 repos analyzed
  - root: 6 failures (docs submodule stale ref - already fixed)
  - frontend: 0 failures ✅
  - server: 1 failure (golangci-lint timeout - already fixed)
  - infra: 0 failures ✅
  - docs: 2 failures (workflow_dispatch - already fixed)
- Submodule update: infra updated to latest (44f22b6)
- Pushed to remote: commit 7e4f1dd
- Docker services verified: all healthy (frontend, server, postgres, redis, coturn)
- Sentry initialized in server logs ✅

## Latest Changes (Mar 10, 2026)
- ✅ Integrated Sentry SDK (@sentry/nextjs@10.42.0, sentry-go@v0.30.0)
- ✅ Added Sentry config to frontend (sentry.client/server/edge.config.ts)
- ✅ Added Sentry config to server (middleware, config, init in main.go)
- ✅ Added Sentry env vars to docker-compose.yml and .env.example
- ✅ Verified Sentry MCP tools - all working (14/15 tools tested)
- ✅ Fixed database migration indexes (presence → presences)
- ✅ Fixed JWT middleware on /api/auth/me endpoint
- ✅ Fixed context key type mismatch in auth handler
- All lint passes: Server ✅, Frontend ✅
- All tests pass: Server ✅, Frontend 549 ✅
- Docker services verified: frontend ✅, server ✅, postgres ✅, redis ✅, coturn ✅

## Previous Changes (Mar 9, 2026)

### Script.sh Memory Bank Instructions
- Added memory bank read/update instructions to all AI tasks
- Added sub-agent parallelization instructions to GitHub operations

### Script.sh Critical Fixes
- Fixed is_safe_issue logic inversion (dangerous issues were being processed)
- Moved CI cache to /tmp/enclavr-ci-cache
- Moved shared state to /tmp/enclavr-shared-state
- Moved proactive cooldown to /tmp/enclavr-proactive-cooldown
- Memory bank updates now conditional on actual changes

### Gitignore Fix
- Added agent-*.log, .ci_failure_cache, .proactive_cooldown, shared-state.md to .gitignore
- Removed tracked files from git

