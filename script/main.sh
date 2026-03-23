#!/bin/bash

# Enclavr Autonomous Agent Loop
# Main entry point

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/logging.sh"
source "$SCRIPT_DIR/shared-state.sh"
source "$SCRIPT_DIR/agent.sh"
source "$SCRIPT_DIR/github.sh"
source "$SCRIPT_DIR/git.sh"
source "$SCRIPT_DIR/memory-bank.sh"
source "$SCRIPT_DIR/labels.sh"
source "$SCRIPT_DIR/branches.sh"
source "$SCRIPT_DIR/proactive.sh"
source "$SCRIPT_DIR/debug.sh"
source "$SCRIPT_DIR/selfhost-debug.sh"

init_logging

log "Starting Enclavr Autonomous Agent"
log "Configuration:"
log "  Log File: $LOG_FILE"
log "  Session: $AGENT_SESSION_ID"
log "  Log Level: $AGENT_LOG_LEVEL"
log "  Timeout: ${AGENT_TIMEOUT}s"
log "  Starting Provider: $CURRENT_PROVIDER"
log "==================================="

check_gh_cli || exit 1

find_agent "kilo" || log_warn "kilo not found"

# OPTIMIZE: Cache memory bank once at startup (~500 tokens saved per loop)
cache_memory_bank
log_debug "Memory bank cached for session"

init_proactive_cooldown

loop_count=0
proactive_runs=0
last_github_check=0
last_closed_issues_check=0
last_submodule_update=0
last_debug_run=0
last_proactive_run=0

DEBUG_INTERVAL=1800
PROACTIVE_INTERVAL=1800
CLOSED_ISSUES_INTERVAL=3600

while true; do
    loop_start=$(date +%s)
    loop_count=$((loop_count + 1))

    log "Loop #$loop_count"

    # === Debugging Task (every 30 minutes) ===
    if [ $((loop_start - last_debug_run)) -ge $DEBUG_INTERVAL ]; then
        log "Running debugging task..."
        
        # Alternate between different debug types
        case $((loop_count % 4)) in
            0) run_debug_task ;;
            1) debug_docker_services ;;
            2) debug_sentry_errors ;;
            3) debug_database ;;
        esac
        
        DEBUG_EXIT=$?
        
        if [ $DEBUG_EXIT -eq 0 ]; then
            log "✓ Debugging completed successfully"
        else
            log_error "✗ Debugging FAILED (exit code: $DEBUG_EXIT)"
        fi
        
        # Commit any changes from debugging
        if [ "$(has_changes)" = "true" ]; then
            commit_and_push "Debug: $(date '+%Y-%m-%d %H:%M')" 120
            update_all_memory_banks "Debugging completed"
        fi
        
        last_debug_run=$loop_start
    fi

    # === Git Submodule Operations (periodic) ===
    if [ $((loop_start - last_submodule_update)) -ge $SUBMODULE_INTERVAL ]; then
        log "Updating submodules via Kilo..."
        update_submodules_via_kilo
        commit_and_push "chore: update submodules to latest" 120
        last_submodule_update=$loop_start
    fi

    # === GitHub Management (periodic) ===
    if [ $((loop_start - last_github_check)) -ge $GITHUB_CHECK_INTERVAL ]; then
        check_issues           # Read comments, interact, close when fixed
        check_pulls           # Review, test, merge when ready
        check_ci              # Analyze failures, fix, re-run
        check_releases        # Analyze, update, create
        manage_labels
        manage_branches
        last_github_check=$loop_start
    fi

    # === Check closed issues for regressions (hourly) ===
    if [ $((loop_start - last_closed_issues_check)) -ge $CLOSED_ISSUES_INTERVAL ]; then
        check_closed_issues    # Monitor for regressions
        last_closed_issues_check=$loop_start
    fi

    # === Proactive Improvements (every 30 minutes regardless of changes) ===
    if [ $((loop_start - last_proactive_run)) -ge $PROACTIVE_INTERVAL ]; then
        if can_run_proactive; then
            log "Running proactive improvements..."
            run_proactive
            EXIT_CODE=$?
            proactive_runs=$((proactive_runs + 1))

            if [ $EXIT_CODE -eq 0 ]; then
                log "✓ Proactive improvements completed successfully"
            else
                log_error "✗ Proactive improvements FAILED (exit code: $EXIT_CODE)"
                log_warn "Initiating backoff: waiting 60s after failed proactive run..."
                sleep 60
            fi

            if [ "$(has_changes)" = "true" ]; then
                commit_and_push "Proactive improvements: $(date '+%Y-%m-%d %H:%M')" 120
                update_all_memory_banks "Proactive improvements completed"
            else
                log "No changes to commit after proactive run"
            fi

            last_proactive_run=$loop_start
        fi
    fi

    # === Check for local changes ===
    # Note: Proactive improvements now run on timer (see above), not just when no changes

    # === Changes detected ===
    log "Changes detected"

    CHANGED_FILES=$(get_changed_files)

    if echo "$CHANGED_FILES" | grep -q "server/"; then
        TARGET_REPO="server"
        TASK="Analyze server changes and run tests, lint, then implement improvements"
    elif echo "$CHANGED_FILES" | grep -q "frontend/"; then
        TARGET_REPO="frontend"
        TASK="For frontend changes:
1. Run tests: bun run test:run
2. Run lint: bun run lint
3. Run typecheck: bun run typecheck
4. Start dev server: cd frontend && bun run dev &
5. Wait for server to start
6. USE Chrome DevTools MCP to verify:
   - chrome-devtools_navigate_page to http://localhost:3000
   - chrome-devtools_take_snapshot to check page renders
   - chrome-devtools_list_console_messages for errors
7. Fix any visual or console issues found
8. Commit changes"
    elif echo "$CHANGED_FILES" | grep -q "infra/"; then
        TARGET_REPO="infra"
        TASK="Analyze infra changes, verify Docker configuration"
    else
        TARGET_REPO="root"
        TASK="Analyze project state and implement improvements per AGENTS.md"
    fi

    log_info "Target repository: $TARGET_REPO"
    log_info "Task: $TASK"

    run_kilo run "$TASK"

    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        log "✓ Agent completed successfully"
    else
        log_error "✗ Agent FAILED with exit code $EXIT_CODE"
    fi

    if [ "$(has_changes)" = "true" ]; then
        commit_and_push "Autonomous agent: $(date '+%Y-%m-%d %H:%M')" 120
    else
        log "No changes to commit"
    fi

    loop_duration=$(( $(date +%s) - loop_start ))
    log "Loop complete (${loop_duration}s)"

    sleep_time=30
    if [ $EXIT_CODE -ne 0 ]; then
        sleep_time=60
        log_warn "Backoff: sleeping ${sleep_time}s after failure"
    fi

    sleep $sleep_time
done
