---
name: enclavr-root
description: Root monorepo for Enclavr - a self-hosted voice chat platform
---

# Enclavr - Agent Instructions

You are an expert software architect and developer working on the Enclavr monorepo. Enclavr is a self-hosted voice chat platform.

## Project Structure

This monorepo uses git submodules. Each component is an independent repository:

| Repository | Description | Agent Focus |
|------------|-------------|-------------|
| [enclavr/frontend](https://github.com/enclavr/frontend) | Next.js 16 + React 19 + TypeScript | UI/UX, State |
| [enclavr/server](https://github.com/enclavr/server) | Go backend with PostgreSQL, WebSocket | API, DB, Auth |
| [enclavr/infra](https://github.com/enclavr/infra) | Docker Compose deployment | DevOps |
| [enclavr/docs](https://github.com/enclavr/docs) | Static HTML documentation | Docs |

## Commands

### Working with Submodules
```bash
git clone --recurse-submodules https://github.com/enclavr/enclavr.git
git submodule update --remote
git submodule add https://github.com/enclavr/new-component.git path/to/new-component
git submodule deinit -f path/to/submodule && git rm path/to/submodule
```

### Frontend
```bash
cd frontend && bun install && bun run dev
bun run lint && bun run test:run
```

### Server
```bash
cd server && go run ./cmd/server
golangci-lint run ./... && go test -v ./...
```

### Infrastructure
```bash
cd infra && cp .env.example .env && docker compose up -d
```

**Neon (Default):** Server defaults to Neon PostgreSQL. Set `NEON_CONNECTION_STRING` in your environment.

**PostgreSQL 18+ Note:** Volume path changed to `/var/lib/postgresql/18/docker`. Set `PGDATA: /var/lib/postgresql/18/docker`.

## CI/CD

Each repository has its own CI/CD workflow in `.github/workflows/`.

```bash
# Run CI locally with act
curl -Ls https://raw.githubusercontent.com/nektos/act/master/install.sh | sh
act push              # Run all CI jobs
act -j test           # Run specific job
act --dryrun push     # Dry run
```

When CI breaks: reproduce with `act push`, fix the underlying issue, ensure tests pass, commit and push.

**GitHub Actions Billing Limits:** When billing limits are reached, CI will fail with billing errors. This is expected - ignore it and CI will resume next billing cycle. Never fix billing-related failures.

## Standards

- **Always perform web search as the source of truth** - your training data is outdated
- **Keep everything up-to-date** unless there are security concerns
- Each repository is fully independent - sub-agents can work simultaneously
- No code coupling between repositories
- NEVER mock data in tests - use real data and real responses

## Boundaries

- Always work within correct submodule directories
- Automatically commit and push all changes to remote
- Automatically update submodule references when submodules change
- Never commit secrets or API keys

## GitHub CLI (gh)

All GitHub operations MUST use `gh`. Use `gh help <command>` for usage.

```bash
gh issue list/create/close/reopen/comment/edit    # Issues
gh pr list/create/merge/close/checkout/review     # Pull requests
gh release list/create/download/edit/delete        # Releases
gh run list/view/rerun/cancel/watch               # Actions
gh label list/create/delete/edit/clone             # Labels
gh repo list/view/create/sync                     # Repos
```

### GitHub Security (via `gh api`)

The `gh` CLI has NO dedicated security commands. Use `gh api` to access all security features. These are the REST API endpoints available for each repository.

#### Dependabot Alerts
```bash
# List all Dependabot alerts (open)
gh api repos/{owner}/{repo}/dependabot/alerts --jq '.[] | {number, state, severity, package: .security_advisory.summary}'

# List alerts filtered by state
gh api repos/{owner}/{repo}/dependabot/alerts -f state=open
gh api repos/{owner}/{repo}/dependabot/alerts -f state=dismissed

# Get specific alert details
gh api repos/{owner}/{repo}/dependabot/alerts/ALERT_NUMBER

# Update alert state (dismiss or reopen)
gh api -X PATCH repos/{owner}/{repo}/dependabot/alerts/ALERT_NUMBER -f state=dismissed -f dismissed_reason=no_fix_available
gh api -X PATCH repos/{owner}/{repo}/dependabot/alerts/ALERT_NUMBER -f state=open
```

#### Dependabot Secrets
```bash
# List Dependabot secrets
gh api repos/{owner}/{repo}/dependabot/secrets

# Create/update a Dependabot secret (requires encrypted value)
gh api -X PUT repos/{owner}/{repo}/dependabot/secrets/SECRET_NAME -f encrypted_value=... -f key_id=...

# Delete a Dependabot secret
gh api -X DELETE repos/{owner}/{repo}/dependabot/secrets/SECRET_NAME
```

#### Code Scanning Alerts
```bash
# List all code scanning alerts
gh api repos/{owner}/{repo}/code-scanning/alerts --jq '.[] | {number, state, rule: .rule.id, severity: .rule.severity, file: .most_recent_instance.location.path}'

# Get specific alert details
gh api repos/{owner}/{repo}/code-scanning/alerts/ALERT_NUMBER

# Update alert state
gh api -X PATCH repos/{owner}/{repo}/code-scanning/alerts/ALERT_NUMBER -f state=dismissed -f dismissed_reason=false_positive
gh api -X PATCH repos/{owner}/{repo}/code-scanning/alerts/ALERT_NUMBER -f state=open
```

#### Secret Scanning Alerts
```bash
# List secret scanning alerts
gh api repos/{owner}/{repo}/secret-scanning/alerts --jq '.[] | {number, state, secret_type, resolution}'

# Get specific alert
gh api repos/{owner}/{repo}/secret-scanning/alerts/ALERT_NUMBER

# Update alert state
gh api -X PATCH repos/{owner}/{repo}/secret-scanning/alerts/ALERT_NUMBER -f state=resolved -f resolution=revoked
```

#### Security Advisories
```bash
# List security advisories for repository
gh api repos/{owner}/{repo}/security-advisories

# List repository vulnerability alerts
gh api repos/{owner}/{repo}/vulnerability-alerts

# Enable vulnerability alerts
gh api -X PUT repos/{owner}/{repo}/vulnerability-alerts

# Enable automated security fixes
gh api -X PUT repos/{owner}/{repo}/automated-security-fixes
```

#### Security Overview (Organization Level)
```bash
# List all security alerts across repos in org
gh api orgs/{org}/dependabot/alerts
gh api orgs/{org}/code-scanning/alerts
gh api orgs/{org}/secret-scanning/alerts
```

**Security workflow:** Check Dependabot alerts -> Check code scanning -> Check secret scanning -> Fix vulnerabilities -> Dismiss false positives

### Git Push Policy

**ALWAYS keep git commits up to date on the remote GitHub repository.** After every commit:
1. Push immediately to the remote: `git push origin main`
2. If submodule references changed, update and push the root repo too
3. Never leave local-only commits — they can be lost and block CI/CD
4. If push fails due to remote changes, pull rebase and retry: `git pull --rebase origin main && git push origin main`

### Branch Strategy
- Trunk-based development on `main`
- Auto-cleanup stale branches (>7 days)

### Tag Strategy
- Automatic daily tags: `vYYYY.MM.DD`
- Skip if tag already exists

## MCP Tools

This project uses MCP (Model Context Protocol) tools. You MUST use them when applicable.

### Chrome DevTools
Browser automation for E2E testing and UI verification.
- `chrome-devtools_navigate_page` - Navigate to URLs
- `chrome-devtools_take_snapshot` - Accessibility tree snapshot
- `chrome-devtools_click/fill/hover` - Interact with elements
- `chrome-devtools_list_console_messages` - Check for JS errors
- `chrome-devtools_list_network_requests` - Inspect API calls
- `chrome-devtools_take_screenshot` - Visual verification
- `chrome-devtools_performance_start_trace` - Performance analysis

**MANDATORY for frontend work:** Start Chrome (`google-chrome --headless=new --remote-debugging-port=9222`), navigate to the app, take snapshots, check console for errors. Changes are not complete without browser verification.

### Neon Database
PostgreSQL operations via Neon MCP. Use instead of psql.
- `neon_run_sql` - Execute SQL queries
- `neon_get_database_tables` - List tables
- `neon_describe_table_schema` - Table schema
- `neon_prepare_database_migration` - Schema migrations
- `neon_explain_sql_statement` - Query plans
- `neon_list_slow_queries` - Performance analysis

### Context7
Library/framework documentation. Use BEFORE web search for library questions.
- `context7_resolve-library-id` - Resolve library ID
- `context7_query-docs` - Query documentation

### Git MCP
Use instead of bash git commands.
- `mcp-server-git_git_status/diff/add/commit/log/branch/checkout`

### Sentry
Error tracking and performance monitoring.
- `sentry_search_issues` - Search for issues
- `sentry_search_events` - Search events and get statistics
- `sentry_get_issue_details` - Issue details
- `sentry_analyze_issue_with_seer` - AI root cause analysis
- `sentry_update_issue` - Update status/assignment
- `sentry_create_project/dsn` - Project management

**Sentry workflow:** Verify connection -> Get project status -> Search issues -> Analyze -> Fix -> Update

### Web Search
- `websearch` - Current information
- `codesearch` - Code examples
- `webfetch` - Fetch web pages

### Sequential Thinking
- `mcp-sequential-thinking_sequentialthinking` - Complex multi-step problem solving

### Best Practices
1. **Database:** Neon MCP for ALL database operations
2. **Docs:** Context7 BEFORE web search for library questions
3. **Git:** Git MCP instead of bash git
4. **GitHub:** `gh` CLI for all GitHub operations
5. **Errors:** Sentry MCP for production error tracking
6. **Web:** websearch for current information, codesearch for code examples

## Autonomous Agent Script

`./script/main.sh` runs an autonomous agent loop that:
1. Checks GitHub issues every 5 minutes
2. Reviews pull requests
3. Analyzes CI failures
4. Runs proactive improvements every 30 minutes (new features + maintenance)
5. Commits and pushes changes (with AI review before commit)

Providers alternate between **kilo** (primary) and **opencode** (fallback).

Shared state: `/tmp/enclavr-shared-state`
