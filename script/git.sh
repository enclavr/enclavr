#!/bin/bash

# Git operations
# OPTIMIZED: ~40% token reduction

has_changes() {
    local has_local=false
    if ! git diff --quiet 2>/dev/null || ! git diff --quiet --staged 2>/dev/null; then
        has_local=true
    fi
    
    if [ -f "$PROJECT_DIR/.gitmodules" ]; then
        if git submodule status 2>/dev/null | grep -q "^+"; then
            has_local=true
        fi
    fi
    
    echo "$has_local"
}

# OPTIMIZED: Compact review task
commit_and_push() {
    local commit_message="$1"
    local timeout="${2:-120}"

    log_info "Checking for changes to commit..."

    if [ "$(has_changes)" = "false" ]; then
        log "No changes to commit"
        return 0
    fi

    log_info "Reviewing changes before commit..."

    # OPTIMIZED: ~100 tokens vs ~250 before
    local review_task="Review uncommitted changes:
1. git status + git diff
2. Check for: secrets, dangerous ops (rm -rf/eval/exec), broken code, malicious code
3. Respond EXACTLY: 'APPROVE: <reason>' or 'REJECT: <reason>'"

    log_info "Running AI review of changes (timeout: 90s)"

    local review_output=$(mktemp)
    local review_exit=0

    run_agent "$review_task" 2>&1 | tee -a "$LOG_FILE" | tee "$review_output"
    review_exit=${PIPESTATUS[0]}

    local decision=$(grep -E "^(APPROVE|REJECT):" "$review_output" | head -1 | tr -d '\n' | xargs)
    rm -f "$review_output"

    if [ $review_exit -eq 124 ]; then
        log_warn "Review timed out - proceeding with caution"
        decision="APPROVE: review timeout"
    elif [ -z "$decision" ]; then
        log_warn "No review decision - rejecting for safety"
        decision="REJECT: no clear decision"
    fi

    if echo "$decision" | grep -q "^REJECT:"; then
        local reason=$(echo "$decision" | sed 's/^REJECT: //')
        log_error "CHANGES REJECTED: $reason"
        return 1
    fi

    local approval_reason=$(echo "$decision" | sed 's/^APPROVE: //')
    log_info "Review APPROVED: $approval_reason"

    log_info "Committing and pushing..."

    # OPTIMIZED: Compact commit task
    local commit_task="git add -A, commit '$commit_message', git push. Acknowledge if no changes."

    local commit_output=$(mktemp)
    local commit_exit=124

    run_agent "$commit_task" 2>&1 | tee -a "$LOG_FILE" | tee "$commit_output"
    commit_exit=${PIPESTATUS[0]}

    if [ $commit_exit -eq 124 ]; then
        log_warn "Commit/push timed out after ${timeout}s"
    elif [ $commit_exit -ne 0 ]; then
        log_warn "Commit/push failed (exit: $commit_exit)"
        tail -n 5 "$commit_output" 2>/dev/null | while IFS= read -r line; do
            log_warn "  > $line"
        done
    else
        log "✓ Changes committed and pushed"
    fi

    rm -f "$commit_output"
    return $commit_exit
}

# OPTIMIZED: Compact submodule task
update_submodules_via_kilo() {
    log "Updating submodules via Kilo..."

    # First check if there are actually submodule updates needed
    local needs_update=false
    if [ -f "$PROJECT_DIR/.gitmodules" ]; then
        if git submodule status 2>/dev/null | grep -q "^+"; then
            needs_update=true
        fi
    fi

    if [ "$needs_update" = "false" ]; then
        log "Submodules already at latest - skipping update"
        return 0
    fi

    local task="$PROMPT_PREFIX

Update submodules:
1. git submodule status
2. git submodule update --remote --merge
3. Stage+commit 'chore: update submodules to latest' if changed

IMPORTANT: Only create a GitHub issue if you find actual problems during the update (e.g., merge conflicts, build failures). Do NOT create issues for successful routine updates."

    run_kilo run "$task"
    return $?
}

get_changed_files() {
    local files=$(git diff --name-only HEAD 2>/dev/null | head -5)
    
    if [ -f "$PROJECT_DIR/.gitmodules" ]; then
        local submodule_changes=$(git submodule status 2>/dev/null | grep "^+" | awk '{print $2}')
        if [ -n "$submodule_changes" ]; then
            files="${files}
${submodule_changes}"
        fi
    fi
    
    echo "$files"
}
