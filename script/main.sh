#!/bin/bash

# Enclavr Autonomous Agent Loop

# Sub-repository flags
ROOT_CHANGED=false
FRONTEND_CHANGED=false
SERVER_CHANGED=false
INFRA_CHANGED=false
DOCS_CHANGED=false

# Current active repo index (0=root, 1=frontend, 2=server, 3=infra, 4=docs)
CURRENT_REPO_INDEX=0

# Task type flags
ADD_NEW_FEATURES=false
TESTING_ONLY=false
DEBUGGING_ONLY=false
SECURITY_ONLY=false
GITHUB_FILES_ONLY=false

# Global task step counter - cycles through 7 steps with balanced distribution:
# Step 0: DEBUG  | Step 1: TEST  | Step 2: FEATURE | Step 3: DEBUG  | Step 4: FEATURE | Step 5: SECURITY | Step 6: GITHUB_FILES
# Ratio: 2 debug : 1 test : 2 feature : 1 security : 1 github_files
# DEBUG = fix/close GitHub issues | TEST = find bugs & create GitHub issues
# FEATURE = add new features | SECURITY = check dependabot, code scanning, secret scanning
# GITHUB_FILES = audit and update README, CONTRIBUTING, CODE_OF_CONDUCT, CHANGELOG, SECURITY, LICENSE, .github/ configs
TASK_STEP=0

# ============================================
# AI Prompt Templates
# ============================================

# Root - Debugging (Fix GitHub Issues)
PROMPT_ROOT_DEBUGGING="You are working on the Enclavr root monorepo at /home/dev/Projects/enclavr.
This is the monorepo orchestrator containing git submodules for frontend, server, infra, docs.

CONTEXT:
- Location: /home/dev/Projects/enclavr
- Repository: enclavr/enclavr
- This repo contains: AGENTS.md, README.md, SECURITY.md, script/, .gitmodules, .env.example
- Submodules: frontend, server, infra, docs

YOUR TASK: Fix as many GitHub issues as possible. Do NOT create new issues.

REQUIREMENTS:
1. List ALL open GitHub issues: gh issue list -R enclavr/enclavr --state open --limit 50
2. Sort by priority: fix critical/security bugs first, then high, then medium
3. For EACH issue you can fix in this session:
   - Read the issue details and understand what needs to be fixed
   - Analyze the code to find the root cause
   - Implement a fix for the issue
   - Verify submodule references are up to date: git submodule status
   - Close the issue with gh issue close <number> -c 'Fixed in <commit description>'
4. Fix AT LEAST 2 issues per session if that many are open
5. If no open issues exist, verify .gitmodules is correct, check AGENTS.md is up to date, verify script/main.sh runs without syntax errors
6. Commit and push your changes after fixing multiple issues

IMPORTANT: Debugging and testing sessions are equal. Fix issues aggressively.
Do NOT create new issues. If you find a bug while fixing, fix it immediately."

# Root - Testing Only
PROMPT_ROOT_TESTING="You are working on the Enclavr root monorepo at /home/dev/Projects/enclavr.
This is the monorepo orchestrator containing git submodules for frontend, server, infra, docs.

CONTEXT:
- Location: /home/dev/Projects/enclavr
- Repository: enclavr/enclavr
- This repo contains: AGENTS.md, README.md, SECURITY.md, script/, .gitmodules, .env.example

YOUR TASK: Testing - find HIGH PRIORITY issues only and create GitHub issues. DO NOT fix anything yourself.

REQUIREMENTS:
1. FIRST check existing open issues: gh issue list -R enclavr/enclavr --state open
   - Do NOT create duplicates of existing issues
2. Verify submodule integrity: git submodule status
3. Check .gitmodules for correct URLs and branch tracking
4. Verify AGENTS.md instructions are accurate
5. Check script/main.sh for syntax errors: bash -n script/main.sh
6. Verify .env.example has correct variables

IMPORTANT ISSUE CREATION RULES:
- ONLY create issues for HIGH priority problems:
  * Broken submodule references
  * Incorrect AGENTS.md instructions that could cause agent failures
  * Script syntax errors or logic bugs
  * Missing or incorrect .env.example variables
- DO NOT create issues for:
  * Minor wording improvements
  * Theoretical improvements without concrete bugs
  * Issues that already exist (check first!)
- MAXIMUM 2 issues per testing session
- For each issue: clear title, description, file paths, steps to reproduce

FALLBACK IF NO ISSUES FOUND: If everything looks clean, do proactive verification:
- Verify all submodule refs in .gitmodules match the latest remote: git ls-remote --refs origin for each submodule URL
- Check AGENTS.md for outdated version numbers (compare against actual package.json/go.mod in submodules)
- Verify .env.example has all variables referenced in AGENTS.md
- If you find anything outdated, create an issue for it

IMPORTANT: Be selective. Quality over quantity. Only report bugs that actually matter."

# Root - Security (Dependabot, Code Scanning, Secret Scanning)
PROMPT_ROOT_SECURITY="You are working on the Enclavr root monorepo at /home/dev/Projects/enclavr.
This is the monorepo orchestrator containing git submodules for frontend, server, infra, docs.

CONTEXT:
- Location: /home/dev/Projects/enclavr
- Repository: enclavr/enclavr

YOUR TASK: Check and fix GitHub security alerts. Check Dependabot, code scanning, and secret scanning.

REQUIREMENTS:
1. Check Dependabot alerts:
   gh api repos/enclavr/enclavr/dependabot/alerts -f state=open --jq '.[] | {number, state, severity, package: .security_advisory.summary, cve: .security_advisory.cve_id}'
2. Check code scanning alerts:
   gh api repos/enclavr/enclavr/code-scanning/alerts --jq '.[] | {number, state, rule: .rule.id, severity: .rule.severity}'
3. Check secret scanning alerts:
   gh api repos/enclavr/enclavr/secret-scanning/alerts
4. For each Dependabot alert:
   - If it is a GitHub Actions vulnerability, update the action version in .github/workflows/ci.yml
   - If no fix is available and vulnerability does not affect this project, dismiss: gh api -X PATCH repos/enclavr/enclavr/dependabot/alerts/NUMBER -f state=dismissed -f dismissed_reason=no_fix_available -f dismissed_comment='EXPLAIN WHY this does not affect the project'
5. For each code scanning alert:
   - Read the actual source code at the reported file:line to understand the context
   - If it is a real vulnerability, FIX IT. Do NOT dismiss after fixing — let CodeQL auto-resolve on next scan.
   - ONLY dismiss if you can prove it is a false positive by reading the code. You MUST provide a dismissal comment:
     gh api -X PATCH repos/enclavr/enclavr/code-scanning/alerts/NUMBER -f state=dismissed -f dismissed_reason='false positive' -f dismissed_comment='EXPLAIN YOUR REASONING (max 280 chars)'
   - NEVER fix AND dismiss the same alert in one session
   - NEVER dismiss more than 2 alerts per session without explicit user approval
6. For each secret scanning alert:
   - If a real secret was exposed, rotate it and mark resolved: gh api -X PATCH repos/enclavr/enclavr/secret-scanning/alerts/NUMBER -f state=resolved -f resolution=revoked
   - Only dismiss if confirmed false positive with comment
7. Verify no secrets in .env.example or AGENTS.md
8. Commit and push your changes

FALLBACK IF NO ALERTS EXIST: If all scanners report no open alerts, do proactive security hardening:
- Verify .github/workflows/ci.yml has 'permissions:' block with minimal required scopes
- Check that .env.example has no real secrets (only placeholders)
- Verify .gitignore covers all sensitive file patterns (.env, *.key, *.pem, credentials*)
- Verify the CI workflow uses pinned action versions (actions/checkout@SHA not @main)
- If you find hardening opportunities, implement them directly and commit

CRITICAL DISMISSAL RULES:
- ALWAYS read the source code before dismissing ANY alert
- ALWAYS include a -f dismissed_comment explaining your reasoning
- NEVER fix and dismiss the same alert in one session
- NEVER bulk dismiss — max 2 dismissals per session
- Use 'false positive' (with space) as dismissed_reason, NOT 'false_positive'
- If you fixed a vulnerability, leave the alert for CodeQL to auto-resolve"

# Root - GitHub Files
PROMPT_ROOT_GITHUB_FILES="You are working on the Enclavr root monorepo at /home/dev/Projects/enclavr.
This is the monorepo orchestrator containing git submodules for frontend, server, infra, docs.

CONTEXT:
- Location: /home/dev/Projects/enclavr
- Repository: enclavr/enclavr

YOUR TASK: Audit and update ALL GitHub community/config files to match the current codebase state.

FILES TO AUDIT AND UPDATE:
1. README.md - Must accurately describe: monorepo structure, submodule repos, quick start commands, features, license
2. AGENTS.md - Must accurately describe: project structure, commands, CI/CD, MCP tools, agent instructions
3. CONTRIBUTING.md - Must reference correct repos, tools, and PR process
4. CODE_OF_CONDUCT.md - Verify enforcement contact email is correct
5. CHANGELOG.md - Add entries for recent changes, verify dates match git log
6. SECURITY.md - Verify all security claims match actual code across submodules
7. LICENSE - Verify it is correct (The Unlicense)
8. .github/CODEOWNERS - Verify correct owner (@enclavr)
9. .github/dependabot.yml - Verify ecosystems match actual files in root (github-actions)
10. .github/workflows/ci.yml - Verify CI steps are functional
11. .github/ISSUE_TEMPLATE/ - Verify fields are relevant
12. .github/PULL_REQUEST_TEMPLATE/ - Verify checklist is appropriate
13. .github/FUNDING.yml - Verify GitHub Sponsors username is correct

REQUIREMENTS:
1. Read the actual codebase as the source of truth
2. For EACH file listed above:
   - Read the file
   - Cross-reference every claim against the actual code
   - If something is wrong or outdated, fix it
   - If something is missing, add it
3. Verify submodule references in README match .gitmodules
4. Verify AGENTS.md references correct file paths and commands
5. Verify SECURITY.md claims match actual submodule implementations
6. Check for placeholder text that was never filled in
7. Verify script/main.sh syntax: bash -n script/main.sh
8. Commit and push your changes

IMPORTANT: Every claim in these files must match the actual codebase. Fix all mismatches."

# Frontend - Add New Features
PROMPT_FRONTEND_FEATURES="You are working on the Enclavr frontend repository.
The project is a Next.js 16 + React 19 + TypeScript voice chat platform with Tailwind CSS 4.

CONTEXT:
- Tech Stack: Next.js 16.1.6, React 19.2.x, TypeScript 5.9.x, Tailwind CSS 4, Zustand 5.0.11, Bun
- Location: /home/dev/Projects/enclavr/frontend
- Design System: Apple Liquid Glass aesthetic (frosted glass, blur effects, translucency)
YOUR TASK: Add NEW features to the frontend.

REQUIREMENTS:
1. Check AGENTS.md in the frontend repo for coding standards and patterns
2. Implement a new feature - consider:
   - New UI components in src/components/ui/
   - New pages in src/app/
   - New React hooks in src/hooks/
   - New utilities in src/lib/
   - New types in src/types/
4. Follow the Apple Liquid Glass design system
5. Use bun for package management
6. Test your changes with: bun run test:run && bun run lint && bun run typecheck
7. For any frontend work, MUST use Chrome DevTools MCP to verify:
   - First start Chrome: google-chrome --headless=new --remote-debugging-port=9222 --no-sandbox --disable-gpu http://localhost:3000 &
   - Wait 3 seconds for Chrome to start
   - chrome-devtools_navigate_page to test the app
   - chrome-devtools_take_snapshot to verify rendering
   - chrome-devtools_list_console_messages to check for errors
   - If Chrome DevTools MCP is unavailable or fails, skip browser checks — rely on test/lint/typecheck results only
8. Commit and push your changes

IMPORTANT: First analyze the codebase to find gaps or missing features. Build something useful that fits the voice chat platform."

# Frontend - Testing Only
PROMPT_FRONTEND_TESTING="You are working on the Enclavr frontend repository.
The project is a Next.js 16 + React 19 + TypeScript voice chat platform with Tailwind CSS 4.

CONTEXT:
- Tech Stack: Next.js 16.1.6, React 19.2.x, TypeScript 5.9.x, Tailwind CSS 4, Zustand 5.0.11, Bun
- Location: /home/dev/Projects/enclavr/frontend
- Design System: Apple Liquid Glass aesthetic

YOUR TASK: Testing - find HIGH PRIORITY issues only and create GitHub issues. DO NOT fix anything yourself.

REQUIREMENTS:
1. FIRST check existing open issues: gh issue list -R enclavr/frontend --state open
   - Do NOT create duplicates of existing issues
2. Run existing tests: bun run test:run
3. Run linting: bun run lint
4. Run type checking: bun run typecheck
5. Analyze any test failures or lint errors
6. Check for console errors using Chrome DevTools MCP:
   - First start Chrome: google-chrome --headless=new --remote-debugging-port=9222 --no-sandbox --disable-gpu http://localhost:3000 &
   - Wait 3 seconds, then: chrome-devtools_navigate_page --type url --url http://localhost:3000
   - chrome-devtools_list_console_messages
   - If Chrome DevTools MCP is unavailable or fails, skip browser checks — rely on test/lint results only

IMPORTANT ISSUE CREATION RULES:
- ONLY create issues for HIGH priority problems:
  * Security vulnerabilities (XSS, auth bypass, data leaks)
  * Crashes or unhandled errors
  * Data loss or corruption bugs
  * Broken core functionality (login, chat, voice)
- DO NOT create issues for:
  * Cosmetic/styling tweaks
  * Minor lint warnings
  * Theoretical improvements without concrete bugs
  * Issues that already exist (check first!)
- MAXIMUM 3 issues per testing session
- For each issue: clear title, description, file paths, steps to reproduce

FALLBACK IF NO ISSUES FOUND: If tests pass, lint is clean, and no open issues exist, do proactive analysis:
- Check for unused exports in src/components/ui/index.ts
- Look for TODO/FIXME/HACK comments in src/ and create issues for critical ones
- Verify all hooks in src/hooks/ have corresponding test files
- If you find gaps, create issues (max 2)

IMPORTANT: Be selective. Quality over quantity. Only report bugs that actually matter."

# Frontend - Debugging (Fix GitHub Issues)
PROMPT_FRONTEND_DEBUGGING="You are working on the Enclavr frontend repository.
The project is a Next.js 16 + React 19 + TypeScript voice chat platform with Tailwind CSS 4.

CONTEXT:
- Tech Stack: Next.js 16.1.6, React 19.2.x, TypeScript 5.9.x, Tailwind CSS 4, Zustand 5.0.11, Bun
- Location: /home/dev/Projects/enclavr/frontend
- Design System: Apple Liquid Glass aesthetic

YOUR TASK: Fix as many GitHub issues as possible. Do NOT create new issues.

REQUIREMENTS:
1. List ALL open GitHub issues: gh issue list -R enclavr/frontend --state open --limit 50
2. Sort by priority: fix critical/security bugs first, then high, then medium
3. For EACH issue you can fix in this session:
   - Read the issue details and understand what needs to be fixed
   - Analyze the code to find the root cause
   - Implement a fix for the issue
   - Run tests to verify: bun run test:run && bun run lint && bun run typecheck
   - Use Chrome DevTools MCP to verify frontend changes (start Chrome first: google-chrome --headless=new --remote-debugging-port=9222 --no-sandbox --disable-gpu http://localhost:3000 &). If Chrome MCP unavailable, skip browser checks.
   - Close the issue with gh issue close <number> -c 'Fixed in <commit description>'
5. Fix AT LEAST 3 issues per session if that many are open
6. If no open issues exist, do proactive improvement:
   - Run bun run lint and fix any warnings (not just errors)
   - Check for React anti-patterns: missing keys, direct state mutation, memory leaks in useEffect
   - Look for opportunities to extract reusable logic into hooks
   - If you find improvements, implement them directly (do not create issues)
7. Commit and push your changes after fixing multiple issues

IMPORTANT: Debugging and testing sessions are equal. Fix issues aggressively.
Do NOT create new issues. If you find a bug while fixing, fix it immediately and close any related issue."

# Server - Add New Features
PROMPT_SERVER_FEATURES="You are working on the Enclavr server repository.
The project is a Go backend with PostgreSQL and WebSocket for real-time voice chat.

CONTEXT:
- Tech Stack: Go 1.25, GORM, PostgreSQL (Neon), gorilla/websocket, Redis pub/sub
- Location: /home/dev/Projects/enclavr/server
- Auth: JWT, bcrypt, OIDC, WebAuthn

YOUR TASK: Add NEW features to the server.

REQUIREMENTS:
1. Check AGENTS.md in the server repo for coding standards
2. Implement a new feature - consider:
   - New API endpoints in internal/handlers/
   - New database models in internal/models/
   - New services in internal/services/
   - New WebSocket handlers in internal/websocket/
   - New middleware in pkg/middleware/
4. Follow Go best practices: go fmt, golangci-lint, tests
5. Run tests: go test -v ./...
6. Ensure backward compatibility with existing APIs
7. Use proper error handling and logging
8. Commit and push your changes

IMPORTANT: First analyze the codebase to find gaps or missing features. Build something useful for the voice chat backend."

# Server - Testing Only
PROMPT_SERVER_TESTING="You are working on the Enclavr server repository.
The project is a Go backend with PostgreSQL and WebSocket for real-time voice chat.

CONTEXT:
- Tech Stack: Go 1.25, GORM, PostgreSQL (Neon), gorilla/websocket, Redis pub/sub
- Location: /home/dev/Projects/enclavr/server
- Auth: JWT, bcrypt, OIDC, WebAuthn
- IMPORTANT: Tests requiring DB will fail without NEON_CONNECTION_STRING. If you see 'hostname resolving error: lookup invalid-host', use non-DB tests: go test -v -short ./...
- IMPORTANT: .golangci.yml uses 'disable-all: true' with explicit 'enable' list. Do NOT add --enable-all flag. If lint fails, fall back to: go vet ./...

YOUR TASK: Testing - find HIGH PRIORITY issues only and create GitHub issues. DO NOT fix anything yourself.

REQUIREMENTS:
1. FIRST check existing open issues: gh issue list -R enclavr/server --state open
   - Do NOT create duplicates of existing issues
2. Run tests (use -short flag if DB unavailable): go test -v -short ./...
3. Run linting: golangci-lint run ./... (or go vet ./... if lint config fails)
4. Check go vet for issues: go vet ./...
5. Analyze any test failures

IMPORTANT ISSUE CREATION RULES:
- ONLY create issues for HIGH priority problems:
  * Security vulnerabilities (SQL injection, auth bypass, data leaks)
  * Crashes, panics, or unhandled errors
  * Data corruption or race conditions
  * Broken core functionality (auth, rooms, messages, voice)
- DO NOT create issues for:
  * Code style preferences
  * Theoretical improvements without concrete bugs
  * Issues that already exist (check first!)
- MAXIMUM 3 issues per testing session
- For each issue: clear title, description, file paths, steps to reproduce

FALLBACK IF NO ISSUES FOUND: If tests pass, lint is clean, and no open issues exist, do proactive analysis:
- Check for unchecked error returns: grep -rn 'err != nil' --include='*.go' internal/ | wc -l
- Look for SQL injection risks: grep -rn 'fmt.Sprintf.*SELECT\|fmt.Sprintf.*INSERT' internal/
- Verify all handlers have proper authentication middleware in cmd/server/main.go routes
- If you find gaps, create issues (max 2)

IMPORTANT: Be selective. Quality over quantity. Only report bugs that actually matter."

# Server - Debugging (Fix GitHub Issues)
PROMPT_SERVER_DEBUGGING="You are working on the Enclavr server repository.
The project is a Go backend with PostgreSQL and WebSocket for real-time voice chat.

CONTEXT:
- Tech Stack: Go 1.25, GORM, PostgreSQL (Neon), gorilla/websocket, Redis pub/sub
- Location: /home/dev/Projects/enclavr/server
- Auth: JWT, bcrypt, OIDC, WebAuthn

YOUR TASK: Fix as many GitHub issues as possible. Do NOT create new issues.

REQUIREMENTS:
1. List ALL open GitHub issues: gh issue list -R enclavr/server --state open --limit 50
2. Sort by priority: fix critical/security bugs first, then high, then medium
3. For EACH issue you can fix in this session:
   - Read the issue details and understand what needs to be fixed
   - Analyze the code to find the root cause
   - Implement a fix for the issue
   - Run tests to verify: go test -v -short ./... && golangci-lint run ./... (or go vet if lint config fails)
   - Close the issue with gh issue close <number> -c 'Fixed in <commit description>'
4. Fix AT LEAST 3 issues per session if that many are open
5. If no open issues exist, do proactive improvement:
   - Run go vet ./... and fix any warnings
   - Check for missing error handling: grep -rn '_ =' internal/ | head -20
   - If you find improvements, implement them directly (do not create issues)
6. Commit and push your changes after fixing multiple issues

IMPORTANT: Debugging and testing sessions are equal. Fix issues aggressively.
Do NOT create new issues. If you find a bug while fixing, fix it immediately."

# Infra - Add New Features
PROMPT_INFRA_FEATURES="You are working on the Enclavr infrastructure repository.
The project uses Docker Compose for deployment.

CONTEXT:
- Location: /home/dev/Projects/enclavr/infra
- Docker Compose for PostgreSQL, Redis, server, frontend, Caddy reverse proxy
- Monitoring stack: Prometheus, Grafana, Node Exporter, Postgres Exporter, cAdvisor
- Optional profiles: --profile debugging (Redis Commander), --profile monitoring (Uptime Kuma), --profile migration (DB migrations)
- Environment configuration via .env

YOUR TASK: Add NEW infrastructure features.

REQUIREMENTS:
1. Check open issues first: gh issue list -R enclavr/infra --state open
2. Analyze current Docker Compose setup: docker compose config
3. Consider adding (pick ONE that fills the biggest gap):
   - Log aggregation (Loki + Promtail for centralized logging)
   - Backup automation (scheduled pg_dump with S3 upload)
   - Container resource alerts in Prometheus (CPU > 80%, memory > 90%)
   - Network segmentation improvements
   - Graceful shutdown handling (stop_timeout, health check dependencies)
4. Check .env.example for configuration options
5. Test with: docker compose config
6. Update .env.example and Makefile if applicable
7. Commit and push your changes

IMPORTANT: Focus on ONE substantial improvement per session. Each must solve a real operational need."

# Infra - Testing Only
PROMPT_INFRA_TESTING="You are working on the Enclavr infrastructure repository.
The project uses Docker Compose for deployment.

CONTEXT:
- Location: /home/dev/Projects/enclavr/infra
- Docker Compose for PostgreSQL, Redis, server, frontend, Caddy, monitoring stack
- Profiles: default, debugging, monitoring, migration

YOUR TASK: Testing - find HIGH PRIORITY issues only and create GitHub issues. DO NOT fix anything yourself.

REQUIREMENTS:
1. FIRST check existing open issues: gh issue list -R enclavr/infra --state open
   - Do NOT create duplicates of existing issues
2. Validate Docker Compose: docker compose config
3. Check for critical issues in docker-compose.yml
4. Test service health checks
5. Verify environment variables in .env.example

IMPORTANT ISSUE CREATION RULES:
- ONLY create issues for HIGH priority problems:
  * Security misconfigurations (exposed ports, weak credentials)
  * Services that cannot start or crash
  * Missing health checks for critical services
  * Data loss risks (missing volumes, no backups)
- DO NOT create issues for:
  * Minor config preferences
  * Theoretical improvements
  * Issues that already exist (check first!)
- MAXIMUM 2 issues per testing session
- For each issue: clear title, description, impact assessment

FALLBACK IF NO ISSUES FOUND: If docker compose config passes and no open issues exist, do proactive checks:
- Verify all services have resource limits
- Check for services missing restart policies
- Verify no ports are exposed to 0.0.0.0 unnecessarily
- Verify Prometheus scrape targets match actual service names
- If you find gaps, create issues (max 2)

IMPORTANT: Be selective. Quality over quantity. Only report issues that actually matter."

# Infra - Debugging (Fix GitHub Issues)
PROMPT_INFRA_DEBUGGING="You are working on the Enclavr infrastructure repository.
The project uses Docker Compose for deployment.

CONTEXT:
- Location: /home/dev/Projects/enclavr/infra
- Docker Compose for PostgreSQL, Redis, server, frontend

YOUR TASK: Fix as many GitHub issues as possible. Do NOT create new issues.

REQUIREMENTS:
1. List ALL open GitHub issues: gh issue list -R enclavr/infra --state open --limit 50
2. Sort by priority: fix critical/security issues first
3. For EACH issue you can fix in this session:
   - Read the issue details and understand what needs to be fixed
   - Analyze the Docker configuration to find the root cause
   - Implement a fix for the issue
   - Test with: docker compose config
   - Close the issue with gh issue close <number> -c 'Fixed in <commit description>'
4. Fix AT LEAST 2 issues per session if that many are open
5. If no open issues exist, do proactive improvement:
   - Run docker compose config and fix any warnings
   - Check for outdated Docker image tags (compare against latest releases)
   - Look for opportunities to add security headers in Caddyfile
   - If you find improvements, implement them directly (do not create issues)
6. Commit and push your changes after fixing multiple issues

IMPORTANT: Debugging and testing sessions are equal. Fix issues aggressively.
Do NOT create new issues."

# Docs - Add New Features
PROMPT_DOCS_FEATURES="You are working on the Enclavr documentation repository.
This docs repository MUST reflect 100% of the features from the other repositories.

CONTEXT:
- Location: /home/dev/Projects/enclavr/docs
- Static HTML documentation generated from codebase
- Docs must stay in sync with: frontend, server, infra repositories

YOUR TASK: Update documentation to reflect all features from other repositories.

REQUIREMENTS:
1. Check the other repositories to understand what features exist:
   - Frontend: /home/dev/Projects/enclavr/frontend (Next.js, React, components, hooks)
   - Server: /home/dev/Projects/enclavr/server (Go, API endpoints, WebSocket, auth)
   - Infra: /home/dev/Projects/enclavr/infra (Docker, deployment)
2. For each feature in the other repos, ensure documentation exists:
   - API documentation (all endpoints)
   - Component documentation (UI components)
   - Setup guides (installation, configuration)
   - Usage examples
   - Architecture docs
3. Run playwright tests to verify docs render: npx playwright test
4. Look at GitHub issues for what needs to be documented
5. Update existing docs to match current code
6. Commit and push your changes

IMPORTANT: The docs MUST be 100% in sync with actual features. If code has a feature, docs must document it."

# Docs - Testing Only
PROMPT_DOCS_TESTING="You are working on the Enclavr documentation repository.
This docs repository MUST reflect 100% of the features from the other repositories.

CONTEXT:
- Location: /home/dev/Projects/enclavr/docs
- Static HTML documentation
- Docs must stay in sync with: frontend, server, infra repositories

YOUR TASK: Testing - find HIGH PRIORITY doc gaps and create GitHub issues. DO NOT fix anything yourself.

REQUIREMENTS:
1. FIRST check existing open issues: gh issue list -R enclavr/docs --state open
   - Do NOT create duplicates of existing issues
2. Check the most critical features in other repos against docs:
   - Server: /home/dev/Projects/enclavr/server (check for new API endpoints)
   - Frontend: /home/dev/Projects/enclavr/frontend (check for new components)
3. Run playwright tests: npx playwright test
4. Check for broken links or rendering issues

IMPORTANT ISSUE CREATION RULES:
- ONLY create issues for significant gaps:
  * Entirely undocumented new features
  * Broken documentation pages
  * Incorrect API documentation (wrong endpoints, parameters)
- DO NOT create issues for:
  * Minor wording improvements
  * Missing code examples (unless the entire page is empty)
  * Issues that already exist (check first!)
- MAXIMUM 2 issues per testing session
- Title format: 'Missing docs: [feature name]' or 'Fix docs: [description]'

IMPORTANT: Be selective. Focus on docs gaps that affect users the most."

# Docs - Debugging (Fix GitHub Issues)
PROMPT_DOCS_DEBUGGING="You are working on the Enclavr documentation repository.
This docs repository MUST reflect 100% of the features from the other repositories.

CONTEXT:
- Location: /home/dev/Projects/enclavr/docs
- Static HTML documentation
- Docs must stay in sync with: frontend, server, infra repositories

YOUR TASK: Fix as many GitHub issues as possible. Do NOT create new issues.

REQUIREMENTS:
1. List ALL open GitHub issues: gh issue list -R enclavr/docs --state open --limit 50
2. For EACH issue you can fix in this session:
   - Read the issue details
   - If it is about missing docs: check the other repos and add the documentation
   - If it is about broken links/typos: fix them directly
   - If it is about code examples: verify against actual code and fix
   - Verify fixes by running: npx playwright test
   - Close the issue with gh issue close <number> -c 'Fixed in <commit description>'
3. Fix AT LEAST 3 issues per session if that many are open
4. If no open issues exist, run playwright tests and fix any failures directly
5. Commit and push your changes after fixing multiple issues

IMPORTANT: Fix existing issues aggressively. The goal is 100% docs coverage of all features."

# Frontend - Security (Dependabot, Code Scanning, Secret Scanning)
PROMPT_FRONTEND_SECURITY="You are working on the Enclavr frontend repository.
The project is a Next.js 16 + React 19 + TypeScript voice chat platform.

CONTEXT:
- Location: /home/dev/Projects/enclavr/frontend
- Repository: enclavr/frontend

YOUR TASK: Check and fix GitHub security alerts. Check Dependabot, code scanning, and secret scanning.

REQUIREMENTS:
1. Check Dependabot alerts:
   gh api repos/enclavr/frontend/dependabot/alerts -f state=open --jq '.[] | {number, state, severity, package: .security_advisory.summary, cve: .security_advisory.cve_id, vulnerable_range: .security_vulnerability.vulnerable_version_range, first_patched: .security_vulnerability.first_patched_version.identifier}'
2. Check code scanning alerts:
   gh api repos/enclavr/frontend/code-scanning/alerts --jq '.[] | {number, state, rule: .rule.id, severity: .rule.severity, file: .most_recent_instance.location.path, line: .most_recent_instance.location.start_line}'
3. Check secret scanning alerts:
   gh api repos/enclavr/frontend/secret-scanning/alerts
4. For each Dependabot alert:
   - If a patch exists, update the dependency: bun update <package>
   - If no patch exists, evaluate if the vulnerability affects this project
   - If it does not affect the project, dismiss: gh api -X PATCH repos/enclavr/frontend/dependabot/alerts/NUMBER -f state=dismissed -f dismissed_reason=no_fix_available -f dismissed_comment='EXPLAIN WHY this does not affect the project'
5. For each code scanning alert:
   - Read the actual source code at the reported file:line to understand the context
   - If it is a real vulnerability, FIX IT. Do NOT dismiss after fixing — let CodeQL auto-resolve on next scan.
   - ONLY dismiss if you can prove it is a false positive by reading the code. You MUST provide a dismissal comment:
     gh api -X PATCH repos/enclavr/frontend/code-scanning/alerts/NUMBER -f state=dismissed -f dismissed_reason='false positive' -f dismissed_comment='EXPLAIN YOUR REASONING (max 280 chars)'
   - NEVER fix AND dismiss the same alert in one session
   - NEVER dismiss more than 2 alerts per session without explicit user approval
6. For each secret scanning alert:
   - If a real secret was exposed, rotate it and mark resolved
   - Only dismiss if confirmed false positive with comment
7. Run tests after fixes: bun run lint && bun run typecheck && bun run test:run
8. Commit and push your changes

FALLBACK IF NO ALERTS EXIST: If all scanners report no open alerts, do proactive security hardening:
- Check for dangerouslySetInnerHTML usage without sanitization
- Verify no sensitive data in client-side localStorage
- Check that NEXT_PUBLIC_ env vars don't leak secrets
- If you find hardening opportunities, implement them directly and commit

CRITICAL DISMISSAL RULES:
- ALWAYS read the source code before dismissing ANY alert
- ALWAYS include a -f dismissed_comment explaining your reasoning
- NEVER fix and dismiss the same alert in one session
- NEVER bulk dismiss — max 2 dismissals per session
- Use 'false positive' (with space) as dismissed_reason, NOT 'false_positive'
- If you fixed a vulnerability, leave the alert for CodeQL to auto-resolve"

# Server - Security (Dependabot, Code Scanning, Secret Scanning)
PROMPT_SERVER_SECURITY="You are working on the Enclavr server repository.
The project is a Go backend with PostgreSQL and WebSocket for real-time voice chat.

CONTEXT:
- Location: /home/dev/Projects/enclavr/server
- Repository: enclavr/server
- Tech Stack: Go 1.25, GORM, PostgreSQL, gorilla/websocket, Redis

YOUR TASK: Check and fix GitHub security alerts. Check Dependabot, code scanning, and secret scanning.

REQUIREMENTS:
1. Check Dependabot alerts:
   gh api repos/enclavr/server/dependabot/alerts -f state=open --jq '.[] | {number, state, severity, package: .security_advisory.summary, cve: .security_advisory.cve_id, vulnerable_range: .security_vulnerability.vulnerable_version_range, first_patched: .security_vulnerability.first_patched_version.identifier}'
2. Check code scanning alerts:
   gh api repos/enclavr/server/code-scanning/alerts --jq '.[] | {number, state, rule: .rule.id, severity: .rule.severity, description: .most_recent_instance.message.text, file: .most_recent_instance.location.path, line: .most_recent_instance.location.start_line}'
3. Check secret scanning alerts:
   gh api repos/enclavr/server/secret-scanning/alerts
4. For each Dependabot alert:
   - If a patch exists, update the dependency: go get <package>@latest && go mod tidy
   - If no patch exists, evaluate if the vulnerability affects this project
   - If it does not affect the project, dismiss: gh api -X PATCH repos/enclavr/server/dependabot/alerts/NUMBER -f state=dismissed -f dismissed_reason=no_fix_available -f dismissed_comment='EXPLAIN WHY this does not affect the project'
5. For each code scanning alert:
   - Read the actual source code at the reported file:line to understand the context BEFORE taking action
   - Common rules and when they are REAL vs FALSE POSITIVE:
     * go/email-injection: REAL if user input flows into email without escaping. FALSE POSITIVE if content is already sanitized.
     * go/clear-text-logging: REAL if passwords/keys are logged. FALSE POSITIVE if only non-sensitive headers are logged.
     * go/path-injection: REAL if user input used in file paths without validation. FALSE POSITIVE if filepath.Clean + base dir check exists.
     * go/cookie-secure-not-set: REAL if cookies lack Secure/HttpOnly flags. Fix by adding flags.
     * go/weak-sensitive-data-hashing: REAL if SHA256 is used on passwords — use bcrypt. FALSE POSITIVE if SHA256 hashes non-password data (IPs, keys) for cache keys.
     * actions/missing-workflow-permissions: REAL if workflow has no permissions block. Fix by adding permissions.
   - If it is a real vulnerability, FIX IT. Do NOT dismiss after fixing — let CodeQL auto-resolve on next scan.
   - ONLY dismiss if you can prove it is a false positive by reading the code. You MUST provide a dismissal comment:
     gh api -X PATCH repos/enclavr/server/code-scanning/alerts/NUMBER -f state=dismissed -f dismissed_reason='false positive' -f dismissed_comment='EXPLAIN YOUR REASONING (max 280 chars)'
   - NEVER fix AND dismiss the same alert in one session
   - NEVER dismiss more than 2 alerts per session without explicit user approval
6. For each secret scanning alert:
   - If a real secret was exposed, rotate it and mark resolved
   - Only dismiss if confirmed false positive with comment
7. Run tests after fixes: go test -v ./... && golangci-lint run ./...
8. Commit and push your changes

FALLBACK IF NO ALERTS EXIST: If all scanners report no open alerts, do proactive security hardening:
- Check for SQL injection risks: grep for string concatenation in SQL queries
- Verify JWT tokens have appropriate expiration times
- Verify rate limiting is applied to all authentication endpoints
- Check that error responses don't leak internal details
- If you find hardening opportunities, implement them directly and commit

CRITICAL DISMISSAL RULES:
- ALWAYS read the source code before dismissing ANY alert
- ALWAYS include a -f dismissed_comment explaining your reasoning
- NEVER fix and dismiss the same alert in one session
- NEVER bulk dismiss — max 2 dismissals per session
- Use 'false positive' (with space) as dismissed_reason, NOT 'false_positive'
- If you fixed a vulnerability, leave the alert for CodeQL to auto-resolve"

# Infra - Security (Dependabot, Code Scanning, Secret Scanning)
PROMPT_INFRA_SECURITY="You are working on the Enclavr infrastructure repository.
The project uses Docker Compose for deployment.

CONTEXT:
- Location: /home/dev/Projects/enclavr/infra
- Repository: enclavr/infra

YOUR TASK: Check and fix GitHub security alerts. Check Dependabot, code scanning, and secret scanning.

REQUIREMENTS:
1. Check Dependabot alerts:
   gh api repos/enclavr/infra/dependabot/alerts -f state=open --jq '.[] | {number, state, severity, package: .security_advisory.summary, cve: .security_advisory.cve_id}'
2. Check code scanning alerts (Trivy):
   gh api repos/enclavr/infra/code-scanning/alerts --jq '.[] | {number, state, rule: .rule.id, severity: .rule.severity}'
3. Check secret scanning alerts:
   gh api repos/enclavr/infra/secret-scanning/alerts
4. For each Dependabot alert:
   - If it is a Docker image vulnerability, update the image tag in docker-compose.yml
   - If it is a GitHub Actions vulnerability, update the action version
   - If no fix is available and vulnerability does not affect this project, dismiss: gh api -X PATCH repos/enclavr/infra/dependabot/alerts/NUMBER -f state=dismissed -f dismissed_reason=no_fix_available -f dismissed_comment='EXPLAIN WHY this does not affect the project'
5. For each code scanning alert (Trivy):
   - Read the actual Dockerfile or docker-compose.yml at the reported location
   - If it is a real misconfiguration, FIX IT. Do NOT dismiss after fixing — let Trivy auto-resolve on next scan.
   - ONLY dismiss if you can prove it is a false positive by reading the code. You MUST provide a dismissal comment:
     gh api -X PATCH repos/enclavr/infra/code-scanning/alerts/NUMBER -f state=dismissed -f dismissed_reason='false positive' -f dismissed_comment='EXPLAIN YOUR REASONING (max 280 chars)'
   - NEVER fix AND dismiss the same alert in one session
   - NEVER dismiss more than 2 alerts per session without explicit user approval
6. For each secret scanning alert:
   - If a real secret was exposed, rotate it and mark resolved
   - Only dismiss if confirmed false positive with comment
7. Test after fixes: docker compose config
8. Commit and push your changes

FALLBACK IF NO ALERTS EXIST: If all scanners report no open alerts, do proactive security hardening:
- Verify Docker images use specific version tags (not :latest)
- Check for services running as root
- Verify no sensitive data in docker-compose.yml environment section
- Verify network isolation between services
- If you find hardening opportunities, implement them directly and commit

CRITICAL DISMISSAL RULES:
- ALWAYS read the source code before dismissing ANY alert
- ALWAYS include a -f dismissed_comment explaining your reasoning
- NEVER fix and dismiss the same alert in one session
- NEVER bulk dismiss — max 2 dismissals per session
- Use 'false positive' (with space) as dismissed_reason, NOT 'false_positive'
- If you fixed a vulnerability, leave the alert for scanner to auto-resolve"

# Docs - Security (Dependabot, Code Scanning, Secret Scanning)
PROMPT_DOCS_SECURITY="You are working on the Enclavr documentation repository.
Static HTML documentation for the Enclavr voice chat platform.

CONTEXT:
- Location: /home/dev/Projects/enclavr/docs
- Repository: enclavr/docs

YOUR TASK: Check and fix GitHub security alerts. Check Dependabot, code scanning, and secret scanning.

REQUIREMENTS:
1. Check Dependabot alerts:
   gh api repos/enclavr/docs/dependabot/alerts -f state=open --jq '.[] | {number, state, severity, package: .security_advisory.summary, cve: .security_advisory.cve_id}'
2. Check code scanning alerts:
   gh api repos/enclavr/docs/code-scanning/alerts
3. Check secret scanning alerts:
   gh api repos/enclavr/docs/secret-scanning/alerts
4. For each Dependabot alert:
   - If a patch exists, update the dependency: npm update <package>
   - If no patch exists, evaluate if the vulnerability affects this project
   - If it does not affect the project, dismiss: gh api -X PATCH repos/enclavr/docs/dependabot/alerts/NUMBER -f state=dismissed -f dismissed_reason=no_fix_available -f dismissed_comment='EXPLAIN WHY this does not affect the project'
5. For each code scanning alert:
   - Read the actual source code at the reported location
   - If it is a real vulnerability, FIX IT. Do NOT dismiss after fixing — let scanner auto-resolve on next scan.
   - ONLY dismiss if you can prove it is a false positive by reading the code. You MUST provide a dismissal comment:
     gh api -X PATCH repos/enclavr/docs/code-scanning/alerts/NUMBER -f state=dismissed -f dismissed_reason='false positive' -f dismissed_comment='EXPLAIN YOUR REASONING (max 280 chars)'
   - NEVER fix AND dismiss the same alert in one session
   - NEVER dismiss more than 2 alerts per session without explicit user approval
6. For each secret scanning alert:
   - If a real secret was exposed, rotate it and mark resolved
   - Only dismiss if confirmed false positive with comment
7. Run tests after fixes: npx playwright test
8. Commit and push your changes

FALLBACK IF NO ALERTS EXIST: If all scanners report no open alerts, do proactive security checks:
- Verify no API keys, tokens, or passwords are embedded in HTML files
- Check that documentation doesn't include internal IP addresses
- Verify that example .env snippets use placeholder values, not real credentials
- If you find issues, fix them directly and commit

CRITICAL DISMISSAL RULES:
- ALWAYS read the source code before dismissing ANY alert
- ALWAYS include a -f dismissed_comment explaining your reasoning
- NEVER fix and dismiss the same alert in one session
- NEVER bulk dismiss — max 2 dismissals per session
- Use 'false positive' (with space) as dismissed_reason, NOT 'false_positive'
- If you fixed a vulnerability, leave the alert for scanner to auto-resolve"

# Frontend - GitHub Files (README, CONTRIBUTING, CODE_OF_CONDUCT, CHANGELOG, SECURITY, LICENSE, .github/)
PROMPT_FRONTEND_GITHUB_FILES="You are working on the Enclavr frontend repository.
The project is a Next.js 16 + React 19 + TypeScript voice chat platform with Tailwind CSS 4.

CONTEXT:
- Location: /home/dev/Projects/enclavr/frontend
- Repository: enclavr/frontend

YOUR TASK: Audit and update ALL GitHub community/config files to match the current codebase state.

FILES TO AUDIT AND UPDATE:
1. README.md - Must accurately describe: tech stack (check package.json), commands (check package.json scripts), features, env vars, file structure
2. CONTRIBUTING.md - Must reference correct commands, tools, and PR process
3. CODE_OF_CONDUCT.md - Verify enforcement contact email is correct
4. CHANGELOG.md - Add entries for recent changes, verify dates match git log
5. SECURITY.md - Verify all security claims match actual code (JWT, CSP, HSTS, etc.)
6. LICENSE - Verify it matches the root repo license
7. .github/CODEOWNERS - Verify correct owner
8. .github/dependabot.yml - Verify ecosystems match actual dependency files (package.json, Dockerfile)
9. .github/workflows/ci.yml - Verify CI steps match actual build/test setup
10. .github/ISSUE_TEMPLATE/ - Verify fields are relevant and accurate
11. .github/PULL_REQUEST_TEMPLATE/ - Verify checklist commands actually exist
12. .github/FUNDING.yml - Verify GitHub Sponsors username is correct

REQUIREMENTS:
1. Read the actual codebase (package.json, tsconfig.json, src/ structure, Dockerfile) as the source of truth
2. For EACH file listed above:
   - Read the file
   - Cross-reference every claim against the actual code
   - If something is wrong or outdated, fix it
   - If something is missing, add it
3. Verify commands in CONTRIBUTING.md and PR template match package.json scripts
4. Verify tech stack versions match package.json
5. Verify file paths referenced actually exist
6. Check for placeholder text that was never filled in
7. Run tests after changes: bun run lint && bun run typecheck
8. Commit and push your changes

IMPORTANT: Every claim in these files must match the actual codebase. Fix all mismatches."

# Server - GitHub Files (README, CONTRIBUTING, CODE_OF_CONDUCT, CHANGELOG, SECURITY, LICENSE, .github/)
PROMPT_SERVER_GITHUB_FILES="You are working on the Enclavr server repository.
The project is a Go backend with PostgreSQL and WebSocket for real-time voice chat.

CONTEXT:
- Location: /home/dev/Projects/enclavr/server
- Repository: enclavr/server

YOUR TASK: Audit and update ALL GitHub community/config files to match the current codebase state.

FILES TO AUDIT AND UPDATE:
1. README.md - Must accurately describe: framework (check go.mod and cmd/), commands, API endpoints, env vars (check .env.example and config.go)
2. AGENTS.md - Must accurately describe: framework, API patterns, handler counts, project structure
3. CONTRIBUTING.md - Must reference correct commands (golangci-lint, go test)
4. CODE_OF_CONDUCT.md - Verify enforcement contact email is correct
5. CHANGELOG.md - Add entries for recent changes, verify dates match git log
6. SECURITY.md - Verify all security claims match actual code (JWT, bcrypt, GORM, rate limiting, etc.)
7. LICENSE - Verify it matches the root repo license. Check Dockerfile labels match LICENSE type.
8. .github/CODEOWNERS - Verify correct owner
9. .github/dependabot.yml - Verify ecosystems match actual dependency files (go.mod, Dockerfile)
10. .github/workflows/ci.yml - Verify CI steps match actual build/test setup
11. .github/ISSUE_TEMPLATE/ - Verify fields are relevant (Go version placeholder should match go.mod)
12. .github/PULL_REQUEST_TEMPLATE/ - Verify checklist commands actually exist

REQUIREMENTS:
1. Read the actual codebase (go.mod, cmd/server/main.go, internal/ structure, Dockerfile, .env.example) as the source of truth
2. For EACH file listed above:
   - Read the file
   - Cross-reference every claim against the actual code
   - If something is wrong or outdated, fix it
   - If something is missing, add it
3. Verify Go version references match go.mod
4. Verify framework claims match actual imports in production code (not test files)
5. Verify API URL patterns match actual route registrations in cmd/server/main.go
6. Verify env vars table in README matches .env.example and config.go
7. Check for placeholder text that was never filled in
8. Run tests after changes: go test -v ./... && golangci-lint run ./...
9. Commit and push your changes

IMPORTANT: Every claim in these files must match the actual codebase. Fix all mismatches."

# Infra - GitHub Files (README, CONTRIBUTING, CODE_OF_CONDUCT, CHANGELOG, SECURITY, LICENSE, .github/)
PROMPT_INFRA_GITHUB_FILES="You are working on the Enclavr infrastructure repository.
The project uses Docker Compose for deployment.

CONTEXT:
- Location: /home/dev/Projects/enclavr/infra
- Repository: enclavr/infra

YOUR TASK: Audit and update ALL GitHub community/config files to match the current codebase state.

FILES TO AUDIT AND UPDATE:
1. README.md - Must accurately describe: services (check docker-compose.yml), ports, volumes, resource limits, security features
2. CONTRIBUTING.md - Must reference correct commands (docker compose config)
3. CODE_OF_CONDUCT.md - Verify enforcement contact email is correct
4. CHANGELOG.md - Add entries for recent changes, verify dates match git log
5. SECURITY.md - Verify ALL security claims match docker-compose.yml:
   - Read-only filesystems (check which services actually have read_only: true)
   - Network isolation (check which services span multiple networks)
   - Backup encryption (check backup.sh for actual encryption)
   - Default ports vs profile-gated ports (check which services need --profile)
6. LICENSE - Verify it matches the root repo license
7. .github/CODEOWNERS - Verify correct owner
8. .github/dependabot.yml - Verify ecosystems match actual files (docker-compose.yml, Dockerfiles). Verify image patterns cover all images used.
9. .github/workflows/ci.yml - Verify CI steps are accurate (Hadolint, Trivy, etc.)
10. .github/ISSUE_TEMPLATE/ - Verify fields are relevant (Docker version, compose logs)
11. .github/PULL_REQUEST_TEMPLATE/ - Verify checklist commands actually exist

REQUIREMENTS:
1. Read docker-compose.yml, Dockerfiles, backup.sh, .env.example, Makefile as the source of truth
2. For EACH file listed above:
   - Read the file
   - Cross-reference every claim against the actual docker-compose.yml
   - Verify which features are default vs optional profiles
   - If something is wrong or outdated, fix it
   - If something is missing, add it
3. Verify volumes listed in README actually exist in docker-compose.yml
4. Verify file path references (like LICENSE links) are correct
5. Verify dependabot patterns cover all Docker images used
6. Check for placeholder text that was never filled in
7. Test after changes: docker compose config
8. Commit and push your changes

IMPORTANT: Every claim in these files must match the actual docker-compose.yml. Fix all mismatches."

# Docs - GitHub Files (README, CONTRIBUTING, CODE_OF_CONDUCT, CHANGELOG, SECURITY, LICENSE, .github/)
PROMPT_DOCS_GITHUB_FILES="You are working on the Enclavr documentation repository.
Static HTML documentation for the Enclavr voice chat platform.

CONTEXT:
- Location: /home/dev/Projects/enclavr/docs
- Repository: enclavr/docs

YOUR TASK: Audit and update ALL GitHub community/config files to match the current codebase state.

FILES TO AUDIT AND UPDATE:
1. README.md - Must accurately describe: deployment URL, testing commands, project structure
2. CONTRIBUTING.md - Must reference correct commands (npx playwright test)
3. CODE_OF_CONDUCT.md - Verify enforcement contact email is correct
4. CHANGELOG.md - Verify dates match actual git tags (run: git tag -l). Fix false 'Initial release' claims.
5. SECURITY.md - Verify all claims match actual codebase
6. LICENSE - Verify it matches the root repo license
7. .github/CODEOWNERS - Verify correct owner
8. .github/dependabot.yml - Verify ecosystems match actual dependency files (package.json)
9. .github/workflows/ci.yml - Verify CI steps are correct
10. .github/workflows/deploy.yml - Verify deployment config is correct. Check artifact upload doesn't include unnecessary files.
11. .github/ISSUE_TEMPLATE/ - Verify placeholder URLs are correct (GitHub Pages URL pattern)
12. .github/PULL_REQUEST_TEMPLATE/ - Verify checklist commands actually exist

REQUIREMENTS:
1. Read the actual codebase (package.json, HTML files, templates, workflows) as the source of truth
2. For EACH file listed above:
   - Read the file
   - Cross-reference every claim against the actual code
   - If something is wrong or outdated, fix it
   - If something is missing, add it
3. Verify GitHub Pages URL is correct for the repo (check remote URL)
4. Verify git tag dates match CHANGELOG entries
5. Verify deploy workflow doesn't upload unnecessary files
6. Check for placeholder text that was never filled in
7. Run tests after changes: npx playwright test
8. Commit and push your changes

IMPORTANT: Every claim in these files must match the actual codebase. Fix all mismatches."

# ============================================
# Main Loop
# ============================================

# Track consecutive failures for circuit breaker
CONSECUTIVE_FAILURES=0
MAX_CONSECUTIVE_FAILURES=5

while true; do
    echo "Loop running..."
    
    # Reset all flags
    ROOT_CHANGED=false
    FRONTEND_CHANGED=false
    SERVER_CHANGED=false
    INFRA_CHANGED=false
    DOCS_CHANGED=false
    ADD_NEW_FEATURES=false
    TESTING_ONLY=false
    DEBUGGING_ONLY=false
    SECURITY_ONLY=false
    GITHUB_FILES_ONLY=false
    
    # Set the current repo flag based on index
    case $CURRENT_REPO_INDEX in
        0) ROOT_CHANGED=true ;;
        1) FRONTEND_CHANGED=true ;;
        2) SERVER_CHANGED=true ;;
        3) INFRA_CHANGED=true ;;
        4) DOCS_CHANGED=true ;;
    esac
    
    # Set task type based on global step counter (2:1:2:1:1 debug:test:feature:security:github_files ratio)
    # Steps 0,3 = debug (fix issues) | Step 1 = test (create issues) | Steps 2,4 = feature | Step 5 = security | Step 6 = github_files
    case $TASK_STEP in
        0|3) DEBUGGING_ONLY=true ;;
        1)   TESTING_ONLY=true ;;
        2|4) ADD_NEW_FEATURES=true ;;
        5)   SECURITY_ONLY=true ;;
        6)   GITHUB_FILES_ONLY=true ;;
    esac
    
    # Build the AI prompt based on current flags
    if [ "$ROOT_CHANGED" = true ]; then
        if [ "$TESTING_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_ROOT_TESTING"
        elif [ "$SECURITY_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_ROOT_SECURITY"
        elif [ "$GITHUB_FILES_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_ROOT_GITHUB_FILES"
        else
            AI_PROMPT="$PROMPT_ROOT_DEBUGGING"
        fi
    elif [ "$FRONTEND_CHANGED" = true ]; then
        if [ "$ADD_NEW_FEATURES" = true ]; then
            AI_PROMPT="$PROMPT_FRONTEND_FEATURES"
        elif [ "$TESTING_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_FRONTEND_TESTING"
        elif [ "$SECURITY_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_FRONTEND_SECURITY"
        elif [ "$GITHUB_FILES_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_FRONTEND_GITHUB_FILES"
        else
            AI_PROMPT="$PROMPT_FRONTEND_DEBUGGING"
        fi
    elif [ "$SERVER_CHANGED" = true ]; then
        if [ "$ADD_NEW_FEATURES" = true ]; then
            AI_PROMPT="$PROMPT_SERVER_FEATURES"
        elif [ "$TESTING_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_SERVER_TESTING"
        elif [ "$SECURITY_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_SERVER_SECURITY"
        elif [ "$GITHUB_FILES_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_SERVER_GITHUB_FILES"
        else
            AI_PROMPT="$PROMPT_SERVER_DEBUGGING"
        fi
    elif [ "$INFRA_CHANGED" = true ]; then
        if [ "$ADD_NEW_FEATURES" = true ]; then
            AI_PROMPT="$PROMPT_INFRA_FEATURES"
        elif [ "$TESTING_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_INFRA_TESTING"
        elif [ "$SECURITY_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_INFRA_SECURITY"
        elif [ "$GITHUB_FILES_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_INFRA_GITHUB_FILES"
        else
            AI_PROMPT="$PROMPT_INFRA_DEBUGGING"
        fi
    elif [ "$DOCS_CHANGED" = true ]; then
        if [ "$ADD_NEW_FEATURES" = true ]; then
            AI_PROMPT="$PROMPT_DOCS_FEATURES"
        elif [ "$TESTING_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_DOCS_TESTING"
        elif [ "$SECURITY_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_DOCS_SECURITY"
        elif [ "$GITHUB_FILES_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_DOCS_GITHUB_FILES"
        else
            AI_PROMPT="$PROMPT_DOCS_DEBUGGING"
        fi
    fi
    
    echo "Active repo: $CURRENT_REPO_INDEX (root=$ROOT_CHANGED, frontend=$FRONTEND_CHANGED, server=$SERVER_CHANGED, infra=$INFRA_CHANGED, docs=$DOCS_CHANGED)"
    echo "Task step: $TASK_STEP/6 | Type: (add_features=$ADD_NEW_FEATURES, testing=$TESTING_ONLY, debugging=$DEBUGGING_ONLY, security=$SECURITY_ONLY, github_files=$GITHUB_FILES_ONLY)"
    echo "AI Prompt length: ${#AI_PROMPT} chars"
    
    # Determine working directory based on active repo
    case $CURRENT_REPO_INDEX in
        0) WORK_DIR="/home/dev/Projects/enclavr" ;;
        1) WORK_DIR="/home/dev/Projects/enclavr/frontend" ;;
        2) WORK_DIR="/home/dev/Projects/enclavr/server" ;;
        3) WORK_DIR="/home/dev/Projects/enclavr/infra" ;;
        4) WORK_DIR="/home/dev/Projects/enclavr/docs" ;;
    esac
    echo "Working directory: $WORK_DIR"
    
    # Run the AI agent with the prompt from the correct working directory
    cd "$WORK_DIR" || { echo "ERROR: Cannot cd to $WORK_DIR"; sleep 60; continue; }
    /home/dev/.bun/bin/kilo run "$AI_PROMPT"
    EXIT_CODE=$?
    cd /home/dev/Projects/enclavr || true
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo "AI agent completed successfully"
        CONSECUTIVE_FAILURES=0
    else
        echo "AI agent FAILED with exit code $EXIT_CODE"
        CONSECUTIVE_FAILURES=$((CONSECUTIVE_FAILURES + 1))
        
        # Circuit breaker: if too many consecutive failures, wait longer
        if [ $CONSECUTIVE_FAILURES -ge $MAX_CONSECUTIVE_FAILURES ]; then
            echo "CIRCUIT BREAKER: $MAX_CONSECUTIVE_FAILURES consecutive failures. Waiting 10 minutes before retry."
            CONSECUTIVE_FAILURES=0
            sleep 600
            continue
        fi
    fi
    
    # Post-agent git verification: ensure all changes are committed and pushed
    cd "$WORK_DIR" || { echo "POST-AGENT ERROR: Cannot cd to $WORK_DIR"; sleep 60; continue; }
    
    # For root repo, update submodule refs before checking status
    if [ "$ROOT_CHANGED" = true ]; then
        echo "POST-AGENT: Updating submodule refs..."
        git submodule update --remote 2>&1 || echo "POST-AGENT: Submodule update had warnings"
    fi
    
    # Check for uncommitted changes
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        echo "POST-AGENT: Uncommitted changes detected in $WORK_DIR"
        git status --short
        echo "POST-AGENT: Auto-committing..."
        git add -A
        TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
        git commit -m "chore: auto-commit leftover changes from agent session [$TIMESTAMP]" --no-verify
        COMMIT_EXIT=$?
        if [ $COMMIT_EXIT -eq 0 ]; then
            echo "POST-AGENT: Committed. Pushing to remote..."
            PUSH_OUTPUT=$(git push origin main 2>&1) || PUSH_OUTPUT=$(git push origin master 2>&1)
            PUSH_EXIT=$?
            if [ $PUSH_EXIT -ne 0 ]; then
                echo "POST-AGENT: Push failed: $PUSH_OUTPUT"
                echo "POST-AGENT: Attempting pull --rebase and retry..."
                # Abort any stuck rebase first
                git rebase --abort 2>/dev/null || true
                PULL_OUTPUT=$(git pull --rebase origin main 2>&1) || PULL_OUTPUT=$(git pull --rebase origin master 2>&1)
                PULL_EXIT=$?
                if [ $PULL_EXIT -ne 0 ]; then
                    echo "POST-AGENT: Pull --rebase failed: $PULL_OUTPUT"
                    echo "POST-AGENT: Aborting rebase and skipping push for this cycle"
                    git rebase --abort 2>/dev/null || true
                else
                    PUSH_OUTPUT=$(git push origin main 2>&1) || PUSH_OUTPUT=$(git push origin master 2>&1)
                    if [ $? -ne 0 ]; then
                        echo "POST-AGENT: Retry push also failed: $PUSH_OUTPUT"
                    else
                        echo "POST-AGENT: Push succeeded after rebase"
                    fi
                fi
            else
                echo "POST-AGENT: Push succeeded"
            fi
        else
            echo "POST-AGENT: Commit failed (exit $COMMIT_EXIT)"
        fi
    else
        echo "POST-AGENT: Working tree clean in $WORK_DIR"
    fi
    
    cd /home/dev/Projects/enclavr || true
    
    # Alternate to next repo for next iteration (5 repos: root, frontend, server, infra, docs)
    CURRENT_REPO_INDEX=$(( (CURRENT_REPO_INDEX + 1) % 5 ))
    
    # Advance global task step (cycles through 7 steps: D,T,D,T,F,S,G)
    TASK_STEP=$(( (TASK_STEP + 1) % 7 ))
    
    echo "Next task step: $TASK_STEP"
    
    sleep 60
done
