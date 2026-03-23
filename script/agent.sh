#!/bin/bash

# Agent finding and execution functions

AGENT_PATH=""

find_agent() {
    local provider="$1"
    local search_paths=""
    
    if [ "$provider" = "kilo" ]; then
        search_paths="$KILO_SEARCH_PATHS"
    else
        search_paths="$OPENCODE_SEARCH_PATHS"
    fi

    for dir in $(echo "$search_paths" | tr ':' ' '); do
        if [ -x "$dir/$provider" ]; then
            AGENT_PATH="$dir/$provider"
            log "Found $provider at: $AGENT_PATH"
            return 0
        fi
    done

    AGENT_PATH=$(which "$provider" 2>/dev/null)
    if [ -z "$AGENT_PATH" ]; then
        log_error "$provider not found in PATH"
        return 1
    fi
    log "Found $provider at: $AGENT_PATH"
    return 0
}

get_next_provider() {
    echo "kilo"
}

get_shared_context() {
    if [ -f "$SHARED_STATE_FILE" ]; then
        local last_provider=""
        last_provider=$(grep -A2 "## Last Run" "$SHARED_STATE_FILE" | grep "Provider" | head -1 | sed 's/.*: //')
        if [ -n "$last_provider" ]; then
            context=$(head -35 "$SHARED_STATE_FILE")
            log_info "Found context from previous $last_provider session (truncated)"
            echo "$context"
        fi
    fi
}

run_agent() {
    CURRENT_PROVIDER=$(get_next_provider "$CURRENT_PROVIDER")
    
    if ! find_agent "$CURRENT_PROVIDER"; then
        local fallback=$(get_next_provider "$CURRENT_PROVIDER")
        log_warn "$CURRENT_PROVIDER not available, trying $fallback..."
        CURRENT_PROVIDER="$fallback"
        find_agent "$CURRENT_PROVIDER" || return 1
    fi

    local task_summary="${1:0:50}"

    local skip_context=false
    if grep -q "context length" "$SHARED_STATE_FILE" 2>/dev/null; then
        log_warn "Previous context overflow detected - skipping shared context"
        skip_context=true
    fi

    if [ "$skip_context" = "false" ]; then
        local shared_context=$(get_shared_context)
        if [ -n "$shared_context" ]; then
            log_info "Context from previous session:"
            echo "$shared_context" | head -3
        fi
    fi

    local cmd=("$AGENT_PATH" "run" "--title" "Enclavr Agent: $task_summary...")

    if [ "$AGENT_LOG_LEVEL" != "INFO" ]; then
        cmd+=("--log-level" "$AGENT_LOG_LEVEL")
    fi
    if [ "$AGENT_PRINT_LOGS" = "true" ]; then
        cmd+=("--print-logs")
    fi
    if [ "$AGENT_SHOW_THINKING" = "true" ]; then
        cmd+=("--thinking")
    fi
    if [ "$AGENT_FORMAT" = "json" ]; then
        cmd+=("--format" "json")
    fi
    if [ -n "$AGENT_TYPE" ]; then
        cmd+=("--agent" "$AGENT_TYPE")
    fi

    cmd+=("$@")

    log_info "Executing task with $CURRENT_PROVIDER... (timeout: ${AGENT_TIMEOUT}s)"
    local start_time=$(date +%s)

    local output_file=$(mktemp)
    local exit_code=124

    if command -v timeout &> /dev/null; then
        timeout "$AGENT_TIMEOUT" "${cmd[@]}" 2>&1 | tee -a "$LOG_FILE" | tee "$output_file"
        exit_code=${PIPESTATUS[0]}
    else
        log_warn "timeout command not available - running without timeout"
        "${cmd[@]}" 2>&1 | tee -a "$LOG_FILE" | tee "$output_file"
        exit_code=${PIPESTATUS[0]}
    fi

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [ $exit_code -eq 124 ]; then
        log_warn "Task timed out after ${AGENT_TIMEOUT}s"
        echo "Task timed out after ${AGENT_TIMEOUT}s" >> "$output_file"
    fi

    log_info "Task completed in ${duration}s (exit: $exit_code)"

    if [ $exit_code -eq 0 ]; then
        if grep -q "context length" "$SHARED_STATE_FILE" 2>/dev/null; then
            sed -i '/context length/d' "$SHARED_STATE_FILE"
            log_info "Cleared context overflow flag after successful run"
        fi
    fi

    local details=""
    if [ $exit_code -ne 0 ]; then
        details="- **Details**: $(tail -n 3 "$output_file" 2>/dev/null | tr '\n' ' ' | head -c 200)"
    fi
    write_shared_state "$CURRENT_PROVIDER" "$task_summary" "$exit_code" "$details"

    if [ $exit_code -ne 0 ]; then
        log_warn "Task failed. Last 5 lines:"
        tail -n 5 "$output_file" 2>/dev/null | while IFS= read -r line; do
            log_warn "  > $line"
        done
    fi

    rm -f "$output_file"
    return $exit_code
}

run_kilo() {
    run_agent "$@"
}
