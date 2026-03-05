#!/bin/bash

# Enclavr Autonomous Agent Loop
# Runs continuously with smart change detection and logging

LOG_FILE="/home/dev/Projects/enclavr/agent-$(date '+%Y%m%d').log"
PROJECT_DIR="/home/dev/Projects/enclavr"
REPOS="enclavr/enclavr enclavr/frontend enclavr/server enclavr/infra"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# ========== Memory Bank Functions ==========

read_memory_bank() {
    log "Reading memory banks for context..."
    
    # Read root memory bank
    if [ -f "$PROJECT_DIR/memory-bank/activeContext.md" ]; then
        ROOT_CONTEXT=$(cat "$PROJECT_DIR/memory-bank/activeContext.md")
        log "  Root active context loaded"
    fi
    
    # Read submodules memory banks
    for submodule in frontend server infra; do
        if [ -d "$PROJECT_DIR/$submodule/memory-bank" ]; then
            if [ -f "$PROJECT_DIR/$submodule/memory-bank/activeContext.md" ]; then
                log "  $submodule active context loaded"
            fi
        fi
    done
    
    log "Memory banks read complete"
}

update_memory_bank() {
    local repo="$1"
    local change_summary="$2"
    
    log "Updating memory bank for $repo..."
    
    local mem_bank_path=""
    case "$repo" in
        frontend) mem_bank_path="$PROJECT_DIR/frontend/memory-bank" ;;
        server)   mem_bank_path="$PROJECT_DIR/server/memory-bank" ;;
        infra)    mem_bank_path="$PROJECT_DIR/infra/memory-bank" ;;
        *)        mem_bank_path="$PROJECT_DIR/memory-bank" ;;
    esac
    
    if [ -f "$mem_bank_path/activeContext.md" ]; then
        local timestamp=$(date '+%b %d, %Y')
        
        # Read current file, prepend new entry
        local current_content=$(cat "$mem_bank_path/activeContext.md")
        
        # Find the "Current Work Focus" section and update it
        if echo "$current_content" | grep -q "## Current Work Focus"; then
            # Replace current work focus with new one
            local new_focus="## Current Work Focus
$change_summary

## Latest Update ($timestamp)

### Changes Made
- $change_summary"
            
            # Rebuild file with new content at top
            echo "$new_focus" > "$mem_bank_path/activeContext.md"
            echo "" >> "$mem_bank_path/activeContext.md"
            echo "$current_content" >> "$mem_bank_path/activeContext.md"
            
            log "  Updated $repo memory bank"
        fi
    fi
}

# ========== GitHub CLI Management Functions ==========

# Security: Detect dangerous patterns in issue bodies
is_safe_issue() {
    local body="$1"
    # Check for prompt injection patterns
    local danger_patterns="ignore.*previous|forget.*above|you are now|emergency|urgent|critical.*now|just do|don't tell|eval\(|exec\(|subprocess|rm -rf|curl.*sh|wget.*sh|base64|decoded|backdoor|reverse shell"
    echo "$body" | grep -Ei "$danger_patterns" >/dev/null 2>&1
    return $?
}

check_issues() {
    log "Checking GitHub issues..."
    for r in $REPOS; do
        ISSUES=$(gh api repos/$r/issues 2>/dev/null | jq -r '.[] | "\(.number) \(.title)"' 2>/dev/null)
        if [ -n "$ISSUES" ]; then
            log "Found issues in $r:"
            echo "$ISSUES" | while read num title; do
                log "  - #$num: $title"
                
                # Get issue body for safety analysis
                BODY=$(gh api repos/$r/issues/$num 2>/dev/null | jq -r '.body // ""')
                
                # Skip suspicious issues for safety
                if [ -n "$BODY" ] && is_safe_issue "$BODY"; then
                    log "  WARNING: Issue #$num contains suspicious patterns - skipping"
                    continue
                fi
                
                # Use opencode to analyze and handle the issue (non-interactive)
                opencode run --continue "Analyze GitHub issue #$num in $r. Title: '$title'. Body: '$BODY'. Assess the issue, research if needed, and implement a fix or provide a detailed solution. Do not close the issue - implement the solution." 2>&1 | tee -a "$LOG_FILE"
                
                log "  Processed #$num with opencode"
            done
        fi
    done
}

check_pulls() {
    log "Checking GitHub pull requests..."
    for r in $REPOS; do
        PRS=$(gh api repos/$r/pulls 2>/dev/null | jq -r '.[] | "\(.number) \(.title) \(.state)"' 2>/dev/null)
        if [ -n "$PRS" ]; then
            log "Found PRs in $r:"
            echo "$PRS" | while read num title state; do
                log "  - #$num: $title ($state)"
                # Use opencode to review and handle the PR (non-interactive)
                opencode run --continue "Review GitHub pull request #$num in $r. Title: '$title'. Analyze the changes, run tests if applicable, and provide a code review. If CI passes and changes look good, approve the PR with a review comment. Do NOT merge - just approve and leave a review." 2>&1 | tee -a "$LOG_FILE"
                
                log "  Reviewed #$num with opencode"
            done
        fi
    done
}

check_ci() {
    log "Checking GitHub Actions CI status..."
    for r in $REPOS; do
        FAILED=$(gh api repos/$r/actions/runs 2>/dev/null | jq -r '.workflow_runs[] | select(.conclusion == "failure") | "\(.id) \(.name)"' 2>/dev/null)
        if [ -n "$FAILED" ]; then
            log "Found failed runs in $r:"
            echo "$FAILED" | while read id name; do
                log "  - Run $id: $name"
                
                # Use opencode to analyze and fix the CI failure
                opencode run --continue "Analyze GitHub Actions CI failure in $r. Run ID: $id, Workflow: '$name'. Check the failure logs, identify the root cause, and implement a fix. Push the fix if needed." 2>&1 | tee -a "$LOG_FILE"
                
                log "  Analyzed and fixed CI failure with opencode"
            done
        fi
    done
}

check_releases() {
    log "Checking GitHub releases..."
    for r in $REPOS; do
        RELEASES=$(gh api repos/$r/releases 2>/dev/null | jq -r '.[] | "\(.tag_name) \(.name)"' 2>/dev/null)
        if [ -n "$RELEASES" ]; then
            log "Releases in $r:"
            echo "$RELEASES" | while read tag name; do
                log "  - $tag: $name"
                
                # Use opencode to analyze and potentially create release notes
                opencode run --continue "Analyze release '$tag' in $r: '$name'. Review the release, check for any issues, and update documentation if needed." 2>&1 | tee -a "$LOG_FILE"
            done
        fi
    done
}

manage_labels() {
    log "Ensuring common labels exist..."
    LABELS="bug:Issue bug,feature:Issue feature,enhancement:Issue enhancement,documentation:Issue documentation,security:Issue security"
    for r in $REPOS; do
        for label in $LABELS; do
            name="${label%%:*}"
            color="${label##*:}"
            gh label create "$name" -R "$r" --description "$name" 2>/dev/null || true
        done
    done
}

sync_repos() {
    log "Syncing repositories..."
    for r in $REPOS; do
        gh repo sync -R "$r" 2>/dev/null && log "  Synced $r"
    done
}

# ========== Main Loop ==========

log "Starting Enclavr autonomous agent..."

while true; do
    cd "$PROJECT_DIR" || exit 1
    
    # === Read Memory Banks for Context ===
    read_memory_bank
    
    # === GitHub Operations (using gh CLI) ===
    check_issues
    check_pulls
    check_ci
    check_releases
    manage_labels
    sync_repos
    
    # === Git Submodule Operations ===
    git submodule update --remote --merge 2>/dev/null
    git add -A 2>/dev/null
    if ! git diff --quiet --staged 2>/dev/null; then
        git commit -m "chore: update submodules to latest" 2>/dev/null
        git push 2>/dev/null
        log "Submodules updated"
    fi
    
    # === Check for local changes ===
    if git diff --quiet 2>/dev/null; then
        # No external changes - run proactive improvements
        log "No external changes, running proactive improvements..."
        
        # Alternate between repos
        if [ -d "server" ] && [ -d "frontend" ]; then
            if [ $((RANDOM % 2)) -eq 0 ]; then
                TASK="Run proactive improvements: code review, test coverage, refactoring, documentation, dependency updates for server. Check for bugs, security issues, uncovered code. Target >30% test coverage."
            else
                TASK="Run proactive improvements: code review, TypeScript fixes, test coverage, refactoring, documentation for frontend. Eliminate any types, add tests for edge cases."
            fi
        elif [ -d "server" ]; then
            TASK="Run proactive improvements for server: code review, test coverage, refactoring, documentation"
        elif [ -d "frontend" ]; then
            TASK="Run proactive improvements for frontend: code review, TypeScript fixes, test coverage"
        else
            TASK="Analyze project state and implement improvements per AGENTS.md"
        fi
        
        opencode run --continue "$TASK" 2>&1 | tee -a "$LOG_FILE"
        
        EXIT_CODE=${PIPESTATUS[0]}
        
        [ $EXIT_CODE -eq 0 ] && log "Proactive improvements completed" || log "Proactive improvements encountered issues (exit code: $EXIT_CODE)"
        
        # Commit and push
        git add -A 2>/dev/null
        if ! git diff --quiet --staged 2>/dev/null; then
            git commit -m "Proactive improvements: $(date '+%Y-%m-%d %H:%M')" 2>/dev/null
            git push 2>/dev/null
            log "Proactive changes committed and pushed"
            
            # Update memory banks after changes
            if [ -d "server" ]; then
                update_memory_bank "server" "Proactive improvements completed"
            fi
            if [ -d "frontend" ]; then
                update_memory_bank "frontend" "Proactive improvements completed"
            fi
            if [ -d "infra" ]; then
                update_memory_bank "infra" "Proactive improvements completed"
            fi
            update_memory_bank "root" "Proactive improvements completed"
        fi
        
        sleep 60
        continue
    fi
    
    # === Changes detected ===
    log "Changes detected, running agent..."
    
    git add -A 2>/dev/null
    
    CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null | head -5)
    
    if echo "$CHANGED_FILES" | grep -q "server/"; then
        TARGET_REPO="server"
        TASK="Analyze server changes and run tests, lint, then implement improvements"
    elif echo "$CHANGED_FILES" | grep -q "frontend/"; then
        TARGET_REPO="frontend"
        TASK="Analyze frontend changes and run tests, lint, then implement improvements"
    else
        TARGET_REPO="root"
        TASK="Analyze project state and implement improvements per AGENTS.md"
    fi
    
    opencode run --continue "$TASK" 2>&1 | tee -a "$LOG_FILE"
    
    EXIT_CODE=${PIPESTATUS[0]}
    
    [ $EXIT_CODE -eq 0 ] && log "Agent completed successfully" || log "Agent encountered issues (exit code: $EXIT_CODE)"
    
    # Commit and push
    if ! git diff --quiet --staged 2>/dev/null; then
        git commit -m "Autonomous agent: $(date '+%Y-%m-%d %H:%M')" 2>/dev/null
        git push 2>/dev/null
        log "Changes committed and pushed"
        
        # Update memory banks after changes
        update_memory_bank "$TARGET_REPO" "Changes processed and improvements implemented"
    fi
    
    sleep 30
done
