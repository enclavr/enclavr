#!/bin/bash

# Shared state management for inter-agent communication

read_shared_state() {
    if [ -f "$SHARED_STATE_FILE" ]; then
        log_info "Reading shared state from previous session..."
        cat "$SHARED_STATE_FILE"
    else
        echo "# Shared State\n\nNo previous state."
    fi
}

write_shared_state() {
    local provider="$1"
    local task_summary="$2"
    local exit_code="$3"
    local details="$4"

    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    local existing_state=""
    if [ -f "$SHARED_STATE_FILE" ]; then
        existing_state=$(cat "$SHARED_STATE_FILE")
    fi

    local status="SUCCESS"
    if [ "$exit_code" -ne 0 ]; then
        status="FAILED"
    fi

    local new_entry="## Last Run ($timestamp)
- **Provider**: $provider
- **Task**: $task_summary
- **Status**: $status
- **Exit Code**: $exit_code
$details

---

"

    local state_content="$new_entry$existing_state"
    local trimmed=$(echo "$state_content" | head -50)

    echo "$trimmed" > "$SHARED_STATE_FILE"
    log_info "Updated shared state: $provider - $task_summary - $status"
}
