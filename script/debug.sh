#!/bin/bash

# Debugging task using AI agents
# OPTIMIZED: ~60% token reduction via template reuse

# Shared debug preamble - reference MCP tools once
DEBUG_MCP_REFS="Use Sentry MCP: sentry_search_issues, sentry_search_events, sentry_analyze_issue_with_seer, sentry_update_issue. Use Neon MCP: neon_list_slow_queries, neon_explain_sql_statement."

run_debug_task() {
    log "Running comprehensive debugging task..."

    # OPTIMIZED: ~250 tokens vs ~800 before
    local task="$PROMPT_PREFIX

Debug ALL 5 repos PARALLEL:
- enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra, enclavr/docs
- Server: runtime errors, panics, DB issues, API failures
- Frontend: React errors, TypeScript, console errors
- Infra: Docker logs, container health, env config

$DEBUG_MCP_REFS

Run tests: server='go test', frontend='bun run test:run'

Report: issues found & fixed."

    run_kilo run "$task"
    return $?
}

debug_docker_services() {
    log "Debugging Docker services..."

    local task="$PROMPT_PREFIX

Debug Docker:
1. docker compose ps - check status
2. docker compose logs --tail=50 - check errors
3. Fix failing services, restart if needed

Report: services fixed."

    run_kilo run "$task"
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
        log_warn "Sentry not configured. Add DSN to frontend/.env and server/.env"
        return 0
    fi

    log "Sentry: frontend=$([ -n "$frontend_dsn" ] && echo 'yes' || echo 'no'), server=$([ -n "$server_dsn" ] && echo 'yes' || echo 'no')"

    # OPTIMIZED: Compact - references MCP tools inline
    local task="$PROMPT_PREFIX

Debug via Sentry MCP:
1. sentry_whoami + sentry_find_organizations
2. sentry_find_projects + sentry_find_dsns
3. sentry_search_issues: 'unresolved errors', 'crashes'
4. sentry_search_events: 'errors from last 24h', 'slow transactions'
5. For critical: sentry_get_issue_details + sentry_analyze_issue_with_seer
6. Fix issues, use sentry_update_issue status=resolved

Report: issues analyzed & resolved."

    run_kilo run "$task"
    return $?
}

debug_database() {
    log "Debugging database issues..."

    local task="$PROMPT_PREFIX

Debug via Neon MCP:
1. neon_list_projects + neon_describe_project
2. neon_get_database_tables - list tables
3. neon_list_slow_queries minExecutionTime=1000
4. For slow queries: neon_explain_sql_statement
5. Fix schema/performance issues

Report: DB issues fixed."

    run_kilo run "$task"
    return $?
}

debug_ci_failures() {
    log "Debugging CI failures..."

    local task="$PROMPT_PREFIX

Debug CI:
1. gh run list -R enclavr/server --failed
2. Analyze logs per failed run
3. Identify root cause, implement fix
4. Push to trigger new CI

Report: CI failures debugged."

    run_kilo run "$task"
    return $?
}
