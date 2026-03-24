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

IMPORTANT: Before starting, create a GitHub issue:
1. Use 'gh issue create --title \"Debug: [timestamp]\" --body \"Task: [description]\" --repo enclavr/enclavr'
2. Note the issue number
3. After completing, resolve with 'gh issue close <number> --repo enclavr/enclavr' and add resolution comment

Report: issues found & fixed."

    run_kilo run "$task"
    return $?
}

debug_docker_services() {
    log "Debugging Docker services..."
    
    local infra_dir="$PROJECT_DIR/infra"
    local issues_found=0
    
    # Step 1: Check if docker compose is available
    if ! command -v docker &> /dev/null; then
        log_error "Docker not installed"
        return 1
    fi
    
    # Step 2: Check if .env file exists
    if [ ! -f "$infra_dir/.env" ]; then
        log_warn ".env file not found, copying from .env.example"
        cp "$infra_dir/.env.example" "$infra_dir/.env"
        issues_found=$((issues_found + 1))
    fi
    
    # Step 3: Validate docker compose config
    log "Validating docker-compose.yml..."
    if ! docker compose -f "$infra_dir/docker-compose.yml" config > /dev/null 2>&1; then
        log_error "docker-compose.yml validation failed"
        docker compose -f "$infra_dir/docker-compose.yml" config 2>&1 | head -20
        issues_found=$((issues_found + 1))
    fi
    
    # Step 4: Check running containers
    log "Checking container status..."
    docker compose -f "$infra_dir/docker-compose.yml" ps --format json 2>/dev/null | while read -r container; do
        local name=$(echo "$container" | jq -r '.Name' 2>/dev/null)
        local state=$(echo "$container" | jq -r '.State' 2>/dev/null)
        local health=$(echo "$container" | jq -r '.Health' 2>/dev/null)
        
        if [ "$state" != "running" ]; then
            log_error "Container $name is not running (state: $state)"
            issues_found=$((issues_found + 1))
        fi
        
        if [ "$health" = "unhealthy" ]; then
            log_error "Container $name is unhealthy"
            issues_found=$((issues_found + 1))
        fi
    done
    
    # Step 5: Check for failed containers
    local failed=$(docker compose -f "$infra_dir/docker-compose.yml" ps --filter "health=unhealthy" --format json 2>/dev/null | jq -r '.Name' 2>/dev/null)
    if [ -n "$failed" ]; then
        log_error "Unhealthy containers: $failed"
        issues_found=$((issues_found + 1))
    fi
    
    # Step 6: Check logs for errors in last 50 lines
    log "Checking logs for errors..."
    local error_count=0
    for service in postgres redis server frontend coturn; do
        local errors=$(docker compose -f "$infra_dir/docker-compose.yml" logs --tail=50 "$service" 2>&1 | grep -iE "(error|fatal|panic|failed|exception)" | wc -l)
        if [ "$errors" -gt 0 ]; then
            log_warn "Found $errors error lines in $service logs"
            docker compose -f "$infra_dir/docker-compose.yml" logs --tail=10 "$service" 2>&1 | grep -iE "(error|fatal|panic|failed|exception)" | tail -5
            error_count=$((error_count + errors))
            issues_found=$((issues_found + 1))
        fi
    done
    
    # Step 7: Check if services are reachable
    log "Checking service connectivity..."
    
    # PostgreSQL
    if docker compose -f "$infra_dir/docker-compose.yml" exec -T postgres pg_isready -U enclavr > /dev/null 2>&1; then
        log "PostgreSQL: OK"
    else
        log_error "PostgreSQL: NOT READY"
        issues_found=$((issues_found + 1))
    fi
    
    # Redis
    if docker compose -f "$infra_dir/docker-compose.yml" exec -T redis redis-cli ping > /dev/null 2>&1; then
        log "Redis: OK"
    else
        log_error "Redis: NOT READY"
        issues_found=$((issues_found + 1))
    fi
    
    # Server API
    if curl -sf http://localhost:8080/health > /dev/null 2>&1; then
        log "Server API: OK"
    else
        log_error "Server API: NOT REACHABLE"
        issues_found=$((issues_found + 1))
    fi
    
    # Frontend
    if curl -sf http://localhost:3000 > /dev/null 2>&1; then
        log "Frontend: OK"
    else
        log_error "Frontend: NOT REACHABLE"
        issues_found=$((issues_found + 1))
    fi
    
    # Step 8: Auto-restart failed services if any
    if [ $issues_found -gt 0 ]; then
        log "Attempting to restart failed services..."
        docker compose -f "$infra_dir/docker-compose.yml" restart
        sleep 10
        
        # Re-check after restart
        if curl -sf http://localhost:8080/health > /dev/null 2>&1; then
            log "Server API: OK after restart"
        fi
        if curl -sf http://localhost:3000 > /dev/null 2>&1; then
            log "Frontend: OK after restart"
        fi
    fi
    
    if [ $issues_found -eq 0 ]; then
        log "All Docker services are healthy"
    else
        log "Found $issues_found issues with Docker services"
    fi
    
    return 0
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

    # ACTUALLY check for errors instead of just delegating to AI
    log "Checking Sentry for recent errors..."
    
    # Use sentry_search_issues to find unresolved issues
    sentry_search_issues --organizationSlug "enclavr" --naturalLanguageQuery "unresolved errors" --limit 5
    
    # Use sentry_search_events to count recent errors
    sentry_search_events --organizationSlug "enclavr" --naturalLanguageQuery "errors from last hour" --limit 3
    
    # Run AI to analyze if there are critical issues
    if [ -n "$frontend_dsn" ] || [ -n "$server_dsn" ]; then
        local task="$PROMPT_PREFIX

Analyze any Sentry issues found above. For critical issues:
1. Use sentry_get_issue_details to get stack traces
2. Use sentry_analyze_issue_with_seer for root cause
3. Fix the issues in code
4. Use sentry_update_issue to mark as resolved

If no critical issues, just report 'No critical errors'."

        run_kilo run "$task"
    fi
    
    return 0
}

debug_database() {
    log "Debugging database issues..."

    # First check if Neon MCP is available by listing projects
    log "Checking Neon database..."
    
    local neon_projects
    neon_projects=$(neon_list_projects 2>&1)
    
    if echo "$neon_projects" | grep -q "error\|Error\|unauthorized"; then
        log_warn "Neon MCP not available or not authenticated"
        # Check local PostgreSQL instead
        log "Checking local PostgreSQL..."
        
        if docker compose -f "$PROJECT_DIR/infra/docker-compose.yml" exec -T postgres pg_isready -U enclavr > /dev/null 2>&1; then
            log "PostgreSQL is ready"
            
            # Check for connections
            local connections=$(docker compose -f "$PROJECT_DIR/infra/docker-compose.yml" exec -T postgres psql -U enclavr -d enclavr -t -c "SELECT count(*) FROM pg_stat_activity WHERE datname='enclavr';" 2>/dev/null)
            log "Active connections: $connections"
        else
            log_error "PostgreSQL is not ready"
        fi
    else
        # Neon is available - use it
        log "Using Neon MCP for database debugging..."
        
        local project_id=$(echo "$neon_projects" | jq -r '.[0].id' 2>/dev/null)
        
        if [ -n "$project_id" ] && [ "$project_id" != "null" ]; then
            # List slow queries
            log "Checking for slow queries..."
            neon_list_slow_queries --projectId "$project_id" --minExecutionTime 100 --limit 5
            
            # Get database tables
            log "Checking database tables..."
            neon_get_database_tables --projectId "$project_id"
        fi
    fi
    
    # Run AI to analyze if there are performance issues
    local task="$PROMPT_PREFIX

Analyze any database issues found above:
1. For slow queries: use neon_explain_sql_statement to analyze
2. Check for missing indexes
3. Fix schema/performance issues

If no issues, just report 'No database issues found'."

    run_kilo run "$task"
    
    return 0
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
