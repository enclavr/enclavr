#!/bin/bash

# Proactive improvements

init_proactive_cooldown() {
    if [ ! -f "$PROACTIVE_COOLDOWN_FILE" ]; then
        echo 0 > "$PROACTIVE_COOLDOWN_FILE"
        log_debug "Initialized proactive cooldown file"
    fi
}

can_run_proactive() {
    last_proactive=0
    if [ -f "$PROACTIVE_COOLDOWN_FILE" ]; then
        last_proactive=$(cat "$PROACTIVE_COOLDOWN_FILE")
    fi

    current_time=$(date +%s)
    time_since_proactive=$((current_time - last_proactive))

    if [ $time_since_proactive -lt $PROACTIVE_COOLDOWN ]; then
        remaining=$((PROACTIVE_COOLDOWN - time_since_proactive))
        log "[COOLDOWN] ${remaining}s remaining"
        return 1
    fi

    return 0
}

set_proactive_cooldown() {
    current_time=$(date +%s)
    echo "$current_time" > "$PROACTIVE_COOLDOWN_FILE
}

run_proactive() {
    log "Proactive improvements..."

    if ! check_rate_limit; then
        return 1
    fi

    set_proactive_cooldown

    local TASK=""
    if [ -d "server" ] && [ -d "frontend" ]; then
        case $((RANDOM % 4)) in
            0) TASK="Run proactive improvements: code review, test coverage, refactoring, documentation, dependency updates for server. Check for bugs, security issues, uncovered code. Target >30% test coverage." ;;
            1) TASK="Run proactive improvements: code review, TypeScript fixes, test coverage, refactoring, documentation for frontend. Eliminate any types, add tests for edge cases." ;;
            2) TASK="Run proactive improvements: review documentation, check for broken links, verify accuracy against codebase, update if needed." ;;
            3) TASK="Run proactive improvements: review infra configuration, check Docker setup, environment variables, deployment docs." ;;
        esac
    elif [ -d "server" ]; then
        TASK="Run proactive improvements for server: code review, test coverage, refactoring, documentation"
    elif [ -d "frontend" ]; then
        TASK="Run proactive improvements for frontend: code review, TypeScript fixes, test coverage, documentation"
    else
        TASK="Analyze project state and implement improvements per AGENTS.md"
    fi

    log_info "Proactive task selected: $TASK"
    run_kilo run --continue "$TASK"

    return $?
}
