#!/bin/bash

# Debugging task using AI agents

run_debug_task() {
    log "Running comprehensive debugging task..."

    local task="IMPORTANT: Before starting, read the memory bank files to understand current state. After completing work, update the memory bank with what was done.

Perform a comprehensive debugging session across ALL enclavr repositories:
1. Use sub-agents to spawn parallel debugging sessions for: enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra, enclavr/docs
2. For each repository, analyze and debug:
   - Server: Check for runtime errors, panics, database issues, API failures, WebSocket problems
   - Frontend: Check for React errors, TypeScript errors, console errors, render issues
   - Infra: Check Docker logs, container health, network issues, environment configuration
   - Root/Docs: Check for broken links, missing files, configuration issues

3. Use Sentry MCP tools for COMPREHENSIVE error monitoring - MUST RUN ALL OF THESE:
   a) sentry_whoami - verify authentication
   b) sentry_find_organizations - confirm enclavr org
   c) sentry_find_teams - list teams
   d) sentry_find_projects - verify frontend and api projects exist
   e) sentry_find_dsns with projectSlug 'frontend' - get frontend DSN
   f) sentry_find_dsns with projectSlug 'api' - get server DSN
   g) sentry_search_issues with naturalLanguageQuery='unresolved errors'
   h) sentry_search_events with naturalLanguageQuery='errors from the last 24 hours'
   i) sentry_search_events with naturalLanguageQuery='all events from the last week'
   j) For critical issues: sentry_get_issue_details, sentry_analyze_issue_with_seer, sentry_get_issue_tag_values
   k) sentry_search_events for performance issues (slow transactions, database failures)
   l) sentry_search_docs and sentry_get_doc for relevant documentation
   m) Verify SDK integration by checking Docker logs for 'Sentry initialized'

4. For each issue found:
   - Identify root cause using sentry_analyze_issue_with_seer
   - Implement fix
   - Test the fix
   - Use sentry_update_issue to mark as resolved
   - Push changes if needed

5. Check Docker services status and logs:
   - docker compose ps
   - docker compose logs --tail=50
   - Check for 'Sentry initialized' in server logs
   - Fix any failing services

6. Run application tests to verify everything works:
   - Server: golangci-lint and go test
   - Frontend: bun run lint and bun run test:run

7. Run Neon MCP tools for database debugging:
   - neon_list_projects
   - neon_describe_project
   - neon_get_database_tables
   - neon_list_slow_queries
   - neon_explain_sql_statement

Report comprehensive findings including Sentry analysis."

    run_kilo run --continue "$task"
    return $?
}

debug_docker_services() {
    log "Debugging Docker services..."

    local task="Debug Docker services:
1. Run 'docker compose ps' to check service status
2. Run 'docker compose logs --tail=100' for each service (frontend, server, postgres, redis, coturn)
3. Identify any failing or unhealthy containers
4. Check for errors in logs
5. Attempt to fix any issues found
6. Restart any failing services

Report which services had issues and what was fixed."

    run_kilo run --continue "$task"
    return $?
}

debug_sentry_errors() {
    log "Debugging Sentry errors..."

    local frontend_dsn=""
    local server_dsn=""

    if [ -f "frontend/.env" ]; then
        frontend_dsn=$(grep -E "^NEXT_PUBLIC_SENTRY_DSN=" frontend/.env 2>/dev/null | cut -d'=' -f2)
    fi

    if [ -f "server/.env" ]; then
        server_dsn=$(grep -E "^SENTRY_DSN=" server/.env 2>/dev/null | cut -d'=' -f2)
    fi

    if [ -z "$frontend_dsn" ] && [ -z "$server_dsn" ]; then
        log_warn "Sentry is not configured. To enable:"
        log_warn "  1. Get DSN from https://enclavr.sentry.io/settings/frontend/keys/"
        log_warn "  2. Add NEXT_PUBLIC_SENTRY_DSN to frontend/.env"
        log_warn "  3. Add SENTRY_DSN to server/.env"
        return 0
    fi

    log "Sentry configured: frontend=$([ -n "$frontend_dsn" ] && echo 'yes' || echo 'no'), server=$([ -n "$server_dsn" ] && echo 'yes' || echo 'no')"

    local task="Debug production errors using Sentry MCP tools - perform COMPREHENSIVE testing:

=== STEP 1: Verify Sentry Connection ===
1. Run 'sentry_whoami' to verify authentication
2. Run 'sentry_find_organizations' to confirm enclavr org exists
3. Run 'sentry_find_teams' to list all teams
4. Run 'sentry_find_projects' to verify frontend and api projects exist

=== STEP 2: Get Project Details ===
1. Run 'sentry_find_dsns' for projectSlug 'frontend' to get DSN details
2. Run 'sentry_find_dsns' for projectSlug 'api' to get DSN details
3. Verify DSNs match the ones in .env files

=== STEP 3: Search for Issues and Events ===
1. Run 'sentry_search_issues' with naturalLanguageQuery='unresolved errors' - list all unhandled errors
2. Run 'sentry_search_issues' with naturalLanguageQuery='crashes' - list any crashes
3. Run 'sentry_search_events' with naturalLanguageQuery='errors from the last 24 hours' - count recent errors
4. Run 'sentry_search_events' with naturalLanguageQuery='all events from the last week' - comprehensive event search

=== STEP 4: Analyze Critical Issues ===
1. For each issue found, use 'sentry_get_issue_details' to get full details
2. Run 'sentry_analyze_issue_with_seer' on any critical issues for AI-powered root cause analysis
3. Get tag values using 'sentry_get_issue_tag_values' with tagKey='environment' to see error distribution
4. Get trace details with 'sentry_get_trace_details' if trace IDs are available

=== STEP 5: Check Performance ===
1. Run 'sentry_search_events' with naturalLanguageQuery='slow transactions' to find performance issues
2. Run 'sentry_search_events' with naturalLanguageQuery='database failures' to find DB issues

=== STEP 6: Update Issue Status ===
1. For each identified issue, use 'sentry_update_issue' to set status='resolved' after fixing
2. Use 'sentry_update_issue' to assign issues to team members

=== STEP 7: Verify SDK Integration ===
1. Check Docker logs for 'Sentry initialized' to verify SDK is loaded
2. Test by triggering a sample error (if test endpoints exist)
3. Verify errors appear in Sentry dashboard within 5 minutes

=== STEP 8: Documentation ===
1. Run 'sentry_search_docs' to find relevant documentation for any issues found
2. Run 'sentry_get_doc' to fetch specific setup guides if needed

Report comprehensive findings:
- Total issues found and their severity
- Root causes identified
- Fixes implemented
- Any SDK integration issues discovered
- Recommendations for improving error monitoring"

    run_kilo run --continue "$task"
    return $?
}

debug_database() {
    log "Debugging database issues..."

    local task="Debug database using Neon MCP tools:
1. List your Neon projects using 'neon_list_projects'
2. Describe the project using 'neon_describe_project'
3. List all tables using 'neon_get_database_tables'
4. Check for slow queries using 'neon_list_slow_queries' (minExecutionTime: 1000)
5. Use 'neon_explain_sql_statement' to analyze query plans for any slow queries
6. Check for database connection issues
7. Identify and fix any schema issues

Report which database issues were found and fixed."

    run_kilo run --continue "$task"
    return $?
}

debug_ci_failures() {
    log "Debugging CI failures..."

    local task="Debug CI failures using GitHub CLI:
1. Get all failed CI runs from the last 7 days: 'gh run list -R enclavr/server --failed'
2. For each failed run, download and analyze logs
3. Identify the root cause of each failure
4. Implement fixes for the issues
5. Push changes to trigger new CI runs
6. Verify the fixes work

Report which CI failures were debugged and fixed."

    run_kilo run --continue "$task"
    return $?
}
