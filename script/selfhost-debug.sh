#!/bin/bash

# Self-Host Testing & Debugging - Tests the entire app as a self-hosting admin
# Uses MCP tools to thoroughly test and debug, creates GitHub issues for bugs found

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/logging.sh"
source "$SCRIPT_DIR/agent.sh"
source "$SCRIPT_DIR/github.sh"

run_selfhost_debug() {
    log "Running self-host testing and debugging..."

    if ! check_rate_limit; then
        return 1
    fi

    local task="$PROMPT_PREFIX

You are an AI agent testing the Enclavr self-hosted application as a system administrator would.

Use ALL available MCP tools to thoroughly test and debug:

## MCP Tools Available:
- Chrome DevTools: chrome-devtools_list_pages, chrome-devtools_navigate_page, chrome-devtools_take_snapshot, chrome-devtools_click, chrome-devtools_fill, chrome-devtools_list_network_requests, chrome-devtools_list_console_messages, chrome-devtools_evaluate_script
- Neon Database: neon_run_sql, neon_list_slow_queries, neon_explain_sql_statement, neon_get_database_tables, neon_describe_table_schema
- Sentry: sentry_search_issues, sentry_search_events, sentry_get_issue_details, sentry_analyze_issue_with_seer
- Context7: context7_resolve-library-id, context7_query-docs
- Git: mcp-server-git_git_status, mcp-server-git_git_diff, mcp-server-git_git_log

## Testing Steps:

### 1. Docker & Service Health
Check each service:
- Run: docker compose -f /home/dev/Projects/enclavr/infra/docker-compose.yml ps
- Verify: postgres, redis, server, frontend, coturn are running
- Check: curl http://localhost:8080/health
- Check: curl http://localhost:3000

### 2. Container Logs
Check for errors:
- docker compose -f /home/dev/Projects/enclavr/infra/docker-compose.yml logs --tail=50 postgres
- docker compose -f /home/dev/Projects/enclavr/infra/docker-compose.yml logs --tail=50 server
- docker compose -f /home/dev/Projects/enclavr/infra/docker-compose.yml logs --tail=50 frontend

### 3. Server Tests
- cd /home/dev/Projects/enclavr/server && go build ./cmd/server
- cd /home/dev/Projects/enclavr/server && go test ./...

### 4. Frontend Tests
- cd /home/dev/Projects/enclavr/frontend && bun run typecheck
- cd /home/dev/Projects/enclavr/frontend && bun run lint

### 5. Chrome DevTools Browser Testing
- chrome-devtools_list_pages
- chrome-devtools_navigate_page --type url --url http://localhost:3000
- Wait 3 seconds
- chrome-devtools_take_snapshot
- chrome-devtools_list_console_messages
- chrome-devtools_list_network_requests
Test login flow and room joining.

### 6. Sentry Error Check
- sentry_search_issues --organizationSlug enclavr --naturalLanguageQuery 'unresolved errors'
- sentry_search_events --organizationSlug enclavr --naturalLanguageQuery 'errors from last 24 hours'

### 7. Database Check
- neon_list_projects (if available)
- neon_get_database_tables --projectId YOUR_PROJECT_ID
- neon_list_slow_queries --projectId YOUR_PROJECT_ID --minExecutionTime 100

## Issue Creation:

When you find a bug, create a GitHub issue using:

For each issue found:
gh issue create --repo enclavr/REPO --title 'Self-host: BUG_TITLE' --body 'ISSUE_BODY' --label 'bug,self-host,SEVERITY'

Issue body must include:
1. Problem: What failed and how to reproduce
2. Self-Host Testing Context: This was detected by an AI agent while testing self-hosted deployment
3. Expected Behavior: What should work
4. Environment: Docker Compose self-host on $(hostname)
5. Severity: critical/high/medium/low

IMPORTANT: Always use run_kilo to execute the actual MCP tool commands.
IMPORTANT: Test all major features: login, rooms, messages, DM, etc.
IMPORTANT: If no issues found, report 'All self-host tests passed'.

Report format:
| Component | Status | Issues Found |
|-----------|--------|--------------|
| Docker Services | OK/Failed | List |
| Server Build | OK/Failed | List |
| Server Tests | OK/Failed | List |
| Frontend Typecheck | OK/Failed | List |
| Frontend Lint | OK/Failed | List |
| Browser Tests | OK/Failed | List |
| Sentry Errors | OK/Failed | List |
| Database | OK/Failed | List |

Total Issues: X"

    run_kilo run "$task"
    return $?
}
