#!/bin/bash

# Enclavr Autonomous Agent Loop
# Runs continuously with smart change detection and logging

LOG_FILE="/home/dev/Projects/enclavr/agent-$(date '+%Y%m%d').log"
PROJECT_DIR="/home/dev/Projects/enclavr"
REPOS="enclavr/enclavr enclavr/frontend enclavr/server enclavr/infra enclavr/docs"

# Kilo logging configuration - reduced verbosity
KILO_LOG_LEVEL="WARN"  # Only warnings and errors
KILO_PRINT_LOGS="false"  # Don't print to stderr
KILO_SHOW_THINKING="false" # Hide AI thinking blocks
KILO_FORMAT="default"   # Human-readable format

# Session configuration
KILO_SESSION_ID="enclavr-autonomous-$(hostname)-$(date '+%Y%m%d')" # Persistent session ID
KILO_AGENT=""  # Optional: specific agent type

log() {
    local level="${2:-INFO}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $1" | tee -a "$LOG_FILE"
}

log_debug() {
    log "[DEBUG] $1" "DEBUG"
}

log_info() {
    log "[INFO] $1" "INFO"
}

log_warn() {
    log "[WARN] $1" "WARN" >&2
}

log_error() {
    log "[ERROR] $1" "ERROR" >&2
}

KILO_PATH=""
KILO_SEARCH_PATHS="/home/dev/.kilo/bin:/usr/local/bin:/usr/bin:/bin"

find_kilo() {
    KILO_SEARCH_PATHS="/home/dev/.kilo/bin:/usr/local/bin:/usr/bin:/bin"

    for dir in $(echo "$KILO_SEARCH_PATHS" | tr ':' ' '); do
        if [ -x "$dir/kilo" ]; then
            KILO_PATH="$dir/kilo"
            log "Found kilo at: $KILO_PATH"
            return 0
        fi
    done

    KILO_PATH=$(which kilo 2>/dev/null)
    if [ -z "$KILO_PATH" ]; then
        log_error "kilo not found in PATH"
        return 1
    fi
    log "Found kilo at: $KILO_PATH"
    return 0
}

run_kilo() {
    if [ -z "$KILO_PATH" ]; then
        find_kilo || return 1
    fi

    local task_summary="${1:0:50}"

    # Build kilo command with minimal logging options
    local cmd=("$KILO_PATH" "run" "--continue" "--session" "$KILO_SESSION_ID" "--title" "Enclavr Agent: $task_summary...")

    # Add logging flags (already configured via env vars)
    if [ "$KILO_LOG_LEVEL" != "INFO" ]; then
        cmd+=("--log-level" "$KILO_LOG_LEVEL")
    fi
    if [ "$KILO_PRINT_LOGS" = "true" ]; then
        cmd+=("--print-logs")
    fi
    if [ "$KILO_SHOW_THINKING" = "true" ]; then
        cmd+=("--thinking")
    fi
    if [ "$KILO_FORMAT" = "json" ]; then
        cmd+=("--format" "json")
    fi
    if [ -n "$KILO_AGENT" ]; then
        cmd+=("--agent" "$KILO_AGENT")
    fi

    # Add the message
    cmd+=("$@")

    log_info "Executing task..."
    local start_time=$(date +%s)

    # Execute and capture output
    local output_file=$(mktemp)
    "${cmd[@]}" 2>&1 | tee -a "$LOG_FILE" | tee "$output_file"
    local exit_code=${PIPESTATUS[0]}

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    log_info "Task completed in ${duration}s (exit: $exit_code)"

    if [ $exit_code -ne 0 ]; then
        log_warn "Task failed. Last 5 lines:"
        tail -n 5 "$output_file" 2>/dev/null | while IFS= read -r line; do
            log_warn "  > $line"
        done
    fi

    rm -f "$output_file"
    return $exit_code
}

# ========== Memory Bank Functions ==========

read_memory_bank() {
    # Read root memory bank
    if [ -f "$PROJECT_DIR/memory-bank/activeContext.md" ]; then
        ROOT_CONTEXT=$(cat "$PROJECT_DIR/memory-bank/activeContext.md")
        log_info "Loaded root memory bank"
    fi

    # Read submodules memory banks
    local submodules_count=0
    for submodule in frontend server infra docs; do
        if [ -d "$PROJECT_DIR/$submodule/memory-bank" ]; then
            if [ -f "$PROJECT_DIR/$submodule/memory-bank/activeContext.md" ]; then
                submodules_count=$((submodules_count + 1))
            fi
        fi
    done

    log_info "Memory banks loaded (${submodules_count} submodules)"
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
        docs)     mem_bank_path="$PROJECT_DIR/docs/memory-bank" ;;
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
            local count=$(echo "$ISSUES" | wc -l)
            log_info "Found $count issues in $r"
            echo "$ISSUES" | while read num title; do
                # Get issue body for safety analysis
                BODY=$(gh api repos/$r/issues/$num 2>/dev/null | jq -r '.body // ""')

                # Skip suspicious issues for safety
                if [ -n "$BODY" ] && is_safe_issue "$BODY"; then
                    log_warn "Issue #$num contains suspicious patterns - SKIPPING"
                    continue
                fi

                # Rate limit check before kilo call
                RATE_REMAINING=$(gh api rate_limit 2>/dev/null | jq -r '.rate.remaining')
                if [ "$RATE_REMAINING" -lt 10 ]; then
                    log_warn "Low API rate limit ($RATE_REMAINING), waiting 60s..."
                    sleep 60
                    RATE_REMAINING=$(gh api rate_limit 2>/dev/null | jq -r '.rate.remaining')
                fi

                log_info "Processing issue #$num: $title"
                run_kilo run --continue "Analyze GitHub issue #$num in $r. Title: '$title'. Body: '$BODY'. Assess the issue, research if needed, and implement a fix or provide a detailed solution. Do not close the issue - implement the solution."

                local kilo_exit=$?
                if [ $kilo_exit -ne 0 ]; then
                    log_error "Failed processing issue #$num (exit $kilo_exit)"
                    sleep 30
                    run_kilo run --continue "Analyze GitHub issue #$num in $r. Title: '$title'. Body: '$BODY'. Assess the issue, research if needed, and implement a fix or provide a detailed solution. Do not close the issue - implement the solution."
                    kilo_exit=$?
                    if [ $kilo_exit -ne 0 ]; then
                        log_error "Retry FAILED for issue #$num - SKIPPING"
                    fi
                fi
            done
        fi
    done
}

check_pulls() {
    log "Checking GitHub pull requests..."
    for r in $REPOS; do
        PRS=$(gh api repos/$r/pulls 2>/dev/null | jq -r '.[] | "\(.number) \(.title) \(.state)"' 2>/dev/null)
        if [ -n "$PRS" ]; then
            local count=$(echo "$PRS" | wc -l)
            log_info "Found $count PRs in $r"
            echo "$PRS" | while read num title state; do
                # Rate limit check
                RATE_REMAINING=$(gh api rate_limit 2>/dev/null | jq -r '.rate.remaining')
                if [ "$RATE_REMAINING" -lt 10 ]; then
                    log_warn "Low API rate limit ($RATE_REMAINING), waiting 60s..."
                    sleep 60
                    RATE_REMAINING=$(gh api rate_limit 2>/dev/null | jq -r '.rate.remaining')
                fi

                log_info "Reviewing PR #$num: $title"
                run_kilo run --continue "Review GitHub pull request #$num in $r. Title: '$title'. Analyze the changes, run tests if applicable, and provide a code review. If CI passes and changes look good, approve the PR with a review comment. Do NOT merge - just approve and leave a review."

                local kilo_exit=$?
                if [ $kilo_exit -ne 0 ]; then
                    log_error "Failed PR review #$num (exit $kilo_exit)"
                fi
            done
        fi
    done
}

check_ci() {
    log "Checking GitHub Actions CI..."

    # Cache file for already-analyzed CI runs
    local cache_file="$PROJECT_DIR/.ci_failure_cache"
    local current_time=$(date +%s)
    local cache_age=0

    if [ -f "$cache_file" ]; then
        cache_age=$((current_time - $(stat -c %Y "$cache_file" 2>/dev/null || echo "$current_time")))
    fi

    # Refresh cache if older than 1 hour
    if [ $cache_age -gt 3600 ]; then
        > "$cache_file"
    fi

    SINCE=$(date -u -d '24 hours ago' '+%Y-%m-%dT%H:%M:%SZ')

    for r in $REPOS; do
        # Get all failed runs
        FAILED=$(gh api repos/$r/actions/runs 2>/dev/null | jq --arg since "$SINCE" -r '.workflow_runs[] | select(.conclusion == "failure") | select(.created_at > $since) | "\(.id) \(.name) \(.created_at)"' 2>/dev/null)

        if [ -n "$FAILED" ]; then
            local count=$(echo "$FAILED" | wc -l)
            log_warn "Found $count failed CI runs in $r (last 24h)"
            echo "$FAILED" | while read id name created; do
                # Check if already analyzed in this cache period
                if [ -f "$cache_file" ] && grep -q "^${r}:${id}$" "$cache_file" 2>/dev/null; then
                    continue
                fi

                # Rate limit check
                RATE_REMAINING=$(gh api rate_limit 2>/dev/null | jq -r '.rate.remaining')
                if [ "$RATE_REMAINING" -lt 10 ]; then
                    log_warn "Low API rate limit ($RATE_REMAINING), waiting 60s..."
                    sleep 60
                    RATE_REMAINING=$(gh api rate_limit 2>/dev/null | jq -r '.rate.remaining')
                fi

                # Add to cache immediately to prevent duplicate analysis
                echo "${r}:${id}" >> "$cache_file"

                log_info "Analyzing CI failure (Run $id, Workflow: $name)"
                run_kilo run --continue "Analyze GitHub Actions CI failure in $r. Run ID: $id, Workflow: '$name'. Check the failure logs, identify the root cause, and implement a fix. Push the fix if needed."

                local kilo_exit=$?
                if [ $kilo_exit -ne 0 ]; then
                    log_error "Failed CI analysis (Run $id)"
                    sleep 30
                    run_kilo run --continue "Analyze GitHub Actions CI failure in $r. Run ID: $id, Workflow: '$name'. Check the failure logs, identify the root cause, and implement a fix. Push the fix if needed."
                    kilo_exit=$?
                fi
            done
        fi
    done
}

check_releases() {
    log "Checking GitHub releases..."
    for r in $REPOS; do
        RELEASES=$(gh api repos/$r/releases 2>/dev/null | jq -r '.[] | "\(.tag_name) \(.name)"' 2>/dev/null)
        if [ -n "$RELEASES" ]; then
            echo "$RELEASES" | while read tag name; do
                log "Release in $r: $tag - $name"
                run_kilo run --continue "Analyze release '$tag' in $r: '$name'. Review the release, check for any issues, and update documentation if needed."
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
        gh repo sync -R "$r" 2>/dev/null && echo "  Synced $r"
    done
}

# ========== Main Loop ==========

log "Starting Enclavr Autonomous Agent"
log "Configuration:"
log "  Log File: $LOG_FILE"
log "  Session: $KILO_SESSION_ID"
log "  Log Level: $KILO_LOG_LEVEL"
log "==================================="

find_kilo

# Initialize cooldown file if not exists
proactive_cooldown_file="$PROJECT_DIR/.proactive_cooldown"
if [ ! -f "$proactive_cooldown_file" ]; then
    echo 0 > "$proactive_cooldown_file"
    log_debug "Initialized proactive cooldown file"
fi

# Statistics tracking
loop_count=0
issues_processed=0
prs_processed=0
ci_fixed=0
proactive_runs=0
last_github_check=0
github_check_interval=300  # Check GitHub every 5 minutes (300s)

# Track last submodule update
last_submodule_update=0
submodule_interval=1800  # Update submodules every 30 minutes

while true; do
    loop_start=$(date +%s)
    loop_count=$((loop_count + 1))

    log "Loop #$loop_count"

    # === Git Submodule Operations (periodic) ===
    if [ $((loop_start - last_submodule_update)) -ge $submodule_interval ]; then
        git submodule update --remote --merge 2>&1 >/dev/null
        git add -A 2>/dev/null
        if ! git diff --quiet --staged 2>/dev/null; then
            git commit -m "chore: update submodules to latest" 2>/dev/null
            git push 2>/dev/null
            log "  Submodules updated"
        fi
        last_submodule_update=$loop_start
    fi

    # === GitHub Management (periodic) ===
    if [ $((loop_start - last_github_check)) -ge $github_check_interval ]; then
        check_issues
        check_pulls
        check_ci
        check_releases
        manage_labels
        last_github_check=$loop_start
    fi

    # === Check for local changes ===
    if git diff --quiet 2>/dev/null; then

        # Check cooldown for proactive improvements
        last_proactive=0
        if [ -f "$proactive_cooldown_file" ]; then
            last_proactive=$(cat "$proactive_cooldown_file")
        fi

        current_time=$(date +%s)
        time_since_proactive=$((current_time - last_proactive))
        cooldown_seconds=1800  # 30 minutes between proactive runs

        if [ $time_since_proactive -lt $cooldown_seconds ]; then
            remaining=$((cooldown_seconds - time_since_proactive))
            log "[COOLDOWN] ${remaining}s remaining"
            sleep 30
            continue
        fi

        # No external changes - run proactive improvements
        log "Proactive improvements..."

        # Update cooldown timestamp BEFORE running (prevent multiple concurrent runs)
        echo "$current_time" > "$proactive_cooldown_file"

        # Rate limit check before proactive run
        RATE_REMAINING=$(gh api rate_limit 2>/dev/null | jq -r '.rate.remaining')
        if [ "$RATE_REMAINING" -lt 20 ]; then
            log_warn "Low GitHub API rate limit ($RATE_REMAINING), skipping"
            sleep 60
            continue
        fi

        # Alternate between repos
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
        elif [ -d "docs" ]; then
            TASK="Run proactive improvements for documentation: review docs, check for broken links, verify accuracy"
        else
            TASK="Analyze project state and implement improvements per AGENTS.md"
        fi

        log_info "Proactive task selected: $TASK"
        run_kilo run --continue "$TASK"

        EXIT_CODE=$?
        proactive_runs=$((proactive_runs + 1))

        if [ $EXIT_CODE -eq 0 ]; then
            log "✓ Proactive improvements completed successfully"
        else
            log_error "✗ Proactive improvements FAILED (exit code: $EXIT_CODE)"
            log_warn "Initiating backoff: waiting 60s after failed proactive run..."
            sleep 60
        fi

        # Commit and push
        git add -A 2>/dev/null
        if ! git diff --quiet --staged 2>/dev/null; then
            log_info "Proactive changes detected, committing..."
            git commit -m "Proactive improvements: $(date '+%Y-%m-%d %H:%M')" 2>/dev/null
            git push 2>/dev/null
            log "✓ Proactive changes committed and pushed"

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
            if [ -d "docs" ]; then
                update_memory_bank "docs" "Proactive improvements completed"
            fi
            update_memory_bank "root" "Proactive improvements completed"
        fi

        log "Proactive cycle complete"
        sleep 30
        continue
    fi

     # Changes detected
    log "Changes detected"

    git add -A 2>/dev/null

    CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null | head -5)

    if echo "$CHANGED_FILES" | grep -q "server/"; then
        TARGET_REPO="server"
        TASK="Analyze server changes and run tests, lint, then implement improvements"
    elif echo "$CHANGED_FILES" | grep -q "frontend/"; then
        TARGET_REPO="frontend"
        TASK="Analyze frontend changes and run tests, lint, then implement improvements"
    elif echo "$CHANGED_FILES" | grep -q "docs/"; then
        TARGET_REPO="docs"
        TASK="Analyze documentation changes, verify accuracy, run build test"
    elif echo "$CHANGED_FILES" | grep -q "infra/"; then
        TARGET_REPO="infra"
        TASK="Analyze infra changes, verify Docker configuration"
    else
        TARGET_REPO="root"
        TASK="Analyze project state and implement improvements per AGENTS.md"
    fi

    log_info "Target repository: $TARGET_REPO"
    log_info "Task: $TASK"

    run_kilo run --continue "$TASK"

    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        log "✓ Agent completed successfully"
    else
        log_error "✗ Agent FAILED with exit code $EXIT_CODE"
    fi

    # Commit and push
    if ! git diff --quiet --staged 2>/dev/null; then
        log_info "Agent produced changes, committing..."
        git commit -m "Autonomous agent: $(date '+%Y-%m-%d %H:%M')" 2>/dev/null
        git push 2>/dev/null
        log "✓ Changes committed and pushed"

        # Update memory banks after changes
        update_memory_bank "$TARGET_REPO" "Changes processed and improvements implemented"
    fi

    loop_duration=$(( $(date +%s) - loop_start ))
    log "Loop complete (${loop_duration}s)"

    # Adaptive sleep based on activity
    sleep_time=30
    if [ $EXIT_CODE -ne 0 ]; then
        sleep_time=60
        log_warn "Backoff: sleeping ${sleep_time}s after failure"
    fi

    sleep $sleep_time
done
