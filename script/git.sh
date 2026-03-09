#!/bin/bash

# Git operations

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

commit_and_push() {
    local commit_message="$1"
    local timeout="${2:-120}"

    log_info "Checking for changes to commit..."

    if [ "$(has_changes)" = "false" ]; then
        log "No changes to commit"
        return 0
    fi

    log_info "Reviewing changes before commit..."

    local review_task="Analyze the current uncommitted/unstaged changes in this repository:
1. First, run 'git status' to see all changed files
2. Run 'git diff' to see the actual changes
3. Carefully review each changed file for:
   - Security issues (hardcoded secrets, API keys, passwords, tokens)
   - Dangerous operations (rm -rf, eval, exec, subprocess with shell=True)
   - Broken code or syntax errors
   - Intentional malicious code or backdoors
   - Credential leaks or sensitive data exposure
   - Infrastructure changes that could cause downtime
   - Changes that don't match the intended task

Respond with EXACTLY ONE of these formats (no other text):
- APPROVE: <brief reason> - if changes are safe and good to commit
- REJECT: <detailed reason why> - if changes are dangerous, broken, or problematic"

    log_info "Running AI review of changes (timeout: 90s)"

    local review_output=$(mktemp)
    local review_exit=0

    run_agent "$review_task" 2>&1 | tee -a "$LOG_FILE" | tee "$review_output"
    review_exit=${PIPESTATUS[0]}

    local decision=$(grep -E "^(APPROVE|REJECT):" "$review_output" | head -1 | tr -d '\n' | xargs)
    rm -f "$review_output"

    if [ $review_exit -eq 124 ]; then
        log_warn "Review timed out - proceeding with caution"
        decision="APPROVE: review timeout - proceeding"
    elif [ -z "$decision" ]; then
        log_warn "Could not determine review decision - rejecting for safety"
        decision="REJECT: no clear decision from review"
    fi

    if echo "$decision" | grep -q "^REJECT:"; then
        local reason=$(echo "$decision" | sed 's/^REJECT: //')
        log_error "CHANGES REJECTED: $reason"
        log_error "NOT committing or pushing changes"
        return 1
    fi

    local approval_reason=$(echo "$decision" | sed 's/^APPROVE: //')
    log_info "Review APPROVED: $approval_reason"

    log_info "Committing and pushing changes via agent..."

    local commit_task="Stage all changes using 'git add -A', create a commit with message: '$commit_message', then push to the remote. Use conventional commit format. If there are no changes to stage, acknowledge that."

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

update_submodules_via_kilo() {
    log "Updating submodules via Kilo..."

    local task="IMPORTANT: Before starting, read the memory bank files to understand current state. After completing work, update the memory bank with what was done. Use sub-agents to update submodules in PARALLEL if possible. Update git submodules to their latest remote versions:
1. Run 'git submodule status' to see current submodule states
2. Run 'git submodule update --remote --merge' to fetch and merge latest
3. Review any changes that occurred
4. If there are changes, stage and commit them with message 'chore: update submodules to latest'

Report what submodules were updated, if any."

    run_kilo run --continue "$task"
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
