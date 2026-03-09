# Active Context - Enclavr

## Current Work Focus (Mar 10, 2026)
Debugging completed

## Latest Update (Mar 10, 2026)
- Debugging completed: All tests passing, lint clean
- Server submodule updated with golangci-lint timeout fix
- Pushed to remote: commit 3896659

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

