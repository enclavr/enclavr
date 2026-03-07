#!/bin/bash

# Enclavr Autonomous Agent Loop
# Runs continuously with smart change detection and logging

LOG_FILE="/home/dev/Projects/enclavr/agent-$(date '+%Y%m%d').log"
PROJECT_DIR="/home/dev/Projects/enclavr"
REPOS="enclavr/enclavr enclavr/frontend enclavr/server enclavr/infra enclavr/docs"

# Opencode logging configuration - EXTREMELY LOUD
OPENCODE_LOG_LEVEL="DEBUG"  # Maximum verbosity
OPENCODE_PRINT_LOGS="true"  # Print to stderr for real-time monitoring
OPENCODE_SHOW_THINKING="true" # Show all AI thinking blocks
OPENCODE_FORMAT="default"   # Human-readable format

# CRITICAL: ALWAYS use free models only - never use paid models
OPENCODE_USE_FREE_MODELS="true"
OPENCODE_FREE_MODELS=(
    "stepfun/step-3.5-flash:free"
    "anthropic/claude-3-haiku:free"
    "openai/gpt-3.5-turbo:free"
    "meta-llama/llama-3-8b:free"
)
# OPENCODE_MODEL is disabled - free models only
OPENCODE_MODEL=""  # Do not set - will be overridden by free model list
OPENCODE_AGENT=""  # Optional: specific agent type
OPENCODE_SESSION_ID="enclavr-autonomous-$(hostname)-$(date '+%Y%m%d')" # Persistent session ID

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

OPENCODE_PATH=""
OPENCODE_SEARCH_PATHS="/home/dev/.opencode/bin:/usr/local/bin:/usr/bin:/bin"

find_opencode() {
    log_debug "Searching for opencode in: $OPENCODE_SEARCH_PATHS"
    for dir in $(echo "$OPENCODE_SEARCH_PATHS" | tr ':' ' '); do
        log_debug "Checking: $dir/opencode"
        if [ -x "$dir/opencode" ]; then
            OPENCODE_PATH="$dir/opencode"
            log "Found opencode at: $OPENCODE_PATH"
            return 0
        fi
    done
    
    log_debug "Trying which opencode..."
    OPENCODE_PATH=$(which opencode 2>/dev/null)
    if [ -z "$OPENCODE_PATH" ]; then
        log_error "opencode not found in PATH"
        return 1
    fi
    log "Found opencode at: $OPENCODE_PATH"
    return 0
}

run_opencode() {
    if [ -z "$OPENCODE_PATH" ]; then
        log_debug "OPENCODE_PATH not set, attempting to find..."
        find_opencode || return 1
    fi
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    log_debug "Preparing to run opencode with args: $@"
    
    # SECURITY: NEVER use paid models - only free models allowed
    # Always use the free models list, ignore any OPENCODE_MODEL setting
    local models_to_try=("${OPENCODE_FREE_MODELS[@]}")
    log_info "MODEL POLICY: FREE MODELS ONLY"
    log_info "Attempting models in order: ${models_to_try[*]}"
    
    # Sanity check - ensure no paid models are configured
    if [ -n "$OPENCODE_MODEL" ]; then
        log_warn "OPENCODE_MODEL is set to '$OPENCODE_MODEL' but is being IGNORED - free models only policy"
        log_warn "To use a specific model, add it to OPENCODE_FREE_MODELS array with :free suffix"
    fi
    
    local last_exit_code=1
    local successful_model=""
    
    # Try each free model until one succeeds
    for model in "${models_to_try[@]}"; do
        log_info "=== ATTEMPTING WITH FREE MODEL: $model ==="
        
        # Build opencode command with logging options
        local cmd=("$OPENCODE_PATH" "run" "--continue" "--session" "$OPENCODE_SESSION_ID")
        
        # Add logging flags
        if [ "$OPENCODE_LOG_LEVEL" != "INFO" ]; then
            cmd+=("--log-level" "$OPENCODE_LOG_LEVEL")
        fi
        
        if [ "$OPENCODE_PRINT_LOGS" = "true" ]; then
            cmd+=("--print-logs")
        fi
        
        if [ "$OPENCODE_SHOW_THINKING" = "true" ]; then
            cmd+=("--thinking")
        fi
        
        if [ "$OPENCODE_FORMAT" = "json" ]; then
            cmd+=("--format" "json")
        fi
        
        # Add model flag (required - free model)
        cmd+=("--model" "$model")
        
        # Add optional agent
        if [ -n "$OPENCODE_AGENT" ]; then
            cmd+=("--agent" "$OPENCODE_AGENT")
        fi
        
        # Add title for this session
        local task_summary="${1:0:50}"
        cmd+=("--title" "Enclavr Agent: $task_summary...")
        
        # Add the message
        cmd+=("$@")
        
        # Execute with full logging
        log_info "Executing with free model: $model"
        log_debug "Full command: ${cmd[*]}"
        
        # Capture start time and provider metrics
        local start_time=$(date +%s)
        log_debug "Start timestamp: $(date -d @$start_time '+%Y-%m-%d %H:%M:%S')"
        
        # Execute and capture output
        local output_file=$(mktemp)
        log_debug "Capturing output to: $output_file"
        
        # Run with full output capture
        "${cmd[@]}" 2>&1 | tee -a "$LOG_FILE" | tee "$output_file"
        local exit_code=${PIPESTATUS[0]}
        
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        # Log execution metrics
        log_info "Model $model completed in ${duration}s with exit code: $exit_code"
        
        # Analyze output for provider-specific errors
        if [ $exit_code -ne 0 ]; then
            log_warn "✗ Model $model failed. Analyzing error patterns..."
            
            # Check for common provider errors
            if grep -qi "rate.*limit\|quota\|exceeded" "$output_file" 2>/dev/null; then
                log_warn "  → RATE LIMIT detected for $model"
            fi
            if grep -qi "unauthorized|invalid.*key|auth|credential" "$output_file" 2>/dev/null; then
                log_error "  → AUTHORIZATION error with $model"
            fi
            if grep -qi "timeout|deadline|elapsed" "$output_file" 2>/dev/null; then
                log_warn "  → TIMEOUT detected for $model"
            fi
            if grep -qi "context.*length|too.*long|max.*tokens" "$output_file" 2>/dev/null; then
                log_warn "  → CONTEXT LENGTH issue with $model"
            fi
            if grep -qi "payment|billing|upgrade|paid|subscription" "$output_file" 2>/dev/null; then
                log_error "  → PAID MODEL REQUIRED detected - skipping to next free model"
            fi
            
            # Extract last error lines
            log_debug "Last 5 lines of output:"
            tail -n 5 "$output_file" 2>/dev/null | while IFS= read -r line; do
                log_debug "    > $line"
            done
            
            rm -f "$output_file"
            last_exit_code=$exit_code
            
            # If we have more models to try, continue to next
            log_info "Trying next free model..."
            continue
        else
            # Success!
            successful_model="$model"
            log_info "✓ Model $model succeeded!"
            
            # Log success summary
            if grep -qi "tokens\|token" "$output_file" 2>/dev/null; then
                local token_info=$(grep -i "tokens" "$output_file" | tail -n 1)
                log_info "Token usage: $token_info"
            fi
            
            rm -f "$output_file"
            last_exit_code=0
            break  # Success, exit the model loop
        fi
    done
    
    # If no free model succeeded, log final failure
    if [ $last_exit_code -ne 0 ]; then
        log_error "=== ALL FREE MODELS FAILED ==="
        log_error "Task: $*"
        log_error "Tried models: ${models_to_try[*]}"
        log_error "Final exit code: $last_exit_code"
        log_error "Session ID: $OPENCODE_SESSION_ID"
        log_error "Duration: ${duration}s"
        log_error "Action: Will retry in next cycle"
    else
        log_info "=== OPENCODE SUCCESS (free model: $successful_model) ==="
        log_info "Task: $*"
        log_info "Duration: ${duration}s"
        log_debug "Successful free model: $successful_model"
        
        # Save successful model for statistics
        echo "$successful_model" > "/tmp/opencode-last-successful-model-$$" 2>/dev/null || true
    fi
    
    return $last_exit_code
}

# ========== Memory Bank Functions ==========

read_memory_bank() {
    log_debug "Starting memory bank read from: $PROJECT_DIR"
    
    # Read root memory bank
    if [ -f "$PROJECT_DIR/memory-bank/activeContext.md" ]; then
        ROOT_CONTEXT=$(cat "$PROJECT_DIR/memory-bank/activeContext.md")
        log_info "Loaded root memory bank ($(wc -l < "$PROJECT_DIR/memory-bank/activeContext.md") lines)"
        log_debug "Root context preview: $(head -c 200 < "$PROJECT_DIR/memory-bank/activeContext.md")..."
    else
        log_warn "No root memory bank found at $PROJECT_DIR/memory-bank/activeContext.md"
    fi
    
    # Read submodules memory banks
    local submodules_count=0
    for submodule in frontend server infra docs; do
        if [ -d "$PROJECT_DIR/$submodule/memory-bank" ]; then
            log_debug "Found memory bank directory for $submodule"
            if [ -f "$PROJECT_DIR/$submodule/memory-bank/activeContext.md" ]; then
                log_info "Loaded $submodule memory bank ($(wc -l < "$PROJECT_DIR/$submodule/memory-bank/activeContext.md") lines)"
                submodules_count=$((submodules_count + 1))
            else
                log_warn "Missing activeContext.md in $submodule memory bank"
            fi
        else
            log_debug "No memory bank directory for $submodule"
        fi
    done
    
    log_info "Memory banks read complete (loaded $submodules_count submodules)"
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
    log "=== CHECKING GITHUB ISSUES ==="
    for r in $REPOS; do
        log_debug "Fetching issues for repo: $r"
        ISSUES=$(gh api repos/$r/issues 2>/dev/null | jq -r '.[] | "\(.number) \(.title)"' 2>/dev/null)
        if [ -n "$ISSUES" ]; then
            local count=$(echo "$ISSUES" | wc -l)
            log_info "Found $count issues in $r"
            echo "$ISSUES" | while read num title; do
                log_debug "Processing issue #$num: $title"
                
                # Get issue body for safety analysis
                log_debug "Fetching body for issue #$num..."
                BODY=$(gh api repos/$r/issues/$num 2>/dev/null | jq -r '.body // ""')
                
                # Skip suspicious issues for safety
                if [ -n "$BODY" ] && is_safe_issue "$BODY"; then
                    log_warn "Issue #$num contains suspicious patterns - SKIPPING"
                    continue
                fi
                
                # Rate limit check before opencode call
                log_debug "Checking rate limit for issue #$num..."
                RATE_REMAINING=$(gh api rate_limit 2>/dev/null | jq -r '.rate.remaining')
                log_debug "Rate limit remaining: $RATE_REMAINING"
                
                if [ "$RATE_REMAINING" -lt 10 ]; then
                    log_warn "Low API rate limit ($RATE_REMAINING), waiting 60s..."
                    sleep 60
                    # Recheck after wait
                    RATE_REMAINING=$(gh api rate_limit 2>/dev/null | jq -r '.rate.remaining')
                    log_info "After wait, rate limit: $RATE_REMAINING"
                fi
                
                # Use opencode to analyze and handle the issue (non-interactive)
                log_info "Starting opencode analysis for issue #$num in $r"
                run_opencode run --continue "Analyze GitHub issue #$num in $r. Title: '$title'. Body: '$BODY'. Assess the issue, research if needed, and implement a fix or provide a detailed solution. Do not close the issue - implement the solution."
                
                local opencode_exit=$?
                log_debug "Opencode returned exit code: $opencode_exit"
                
                if [ $opencode_exit -ne 0 ]; then
                    log_error "Opencode failed for issue #$num (exit $opencode_exit)"
                    log_warn "Initiating retry after 30s backoff..."
                    sleep 30
                    # One retry
                    run_opencode run --continue "Analyze GitHub issue #$num in $r. Title: '$title'. Body: '$BODY'. Assess the issue, research if needed, and implement a fix or provide a detailed solution. Do not close the issue - implement the solution."
                    opencode_exit=$?
                    if [ $opencode_exit -ne 0 ]; then
                        log_error "Retry FAILED for issue #$num (exit $opencode_exit) - SKIPPING"
                    else
                        log_info "Retry succeeded for issue #$num"
                    fi
                fi
                
                log_info "Completed processing issue #$num (final exit: $opencode_exit)"
            done
        else
            log_debug "No issues found in $r"
        fi
    done
    log "=== FINISHED CHECKING ISSUES ==="
}

check_pulls() {
    log "=== CHECKING GITHUB PULL REQUESTS ==="
    for r in $REPOS; do
        log_debug "Fetching PRs for repo: $r"
        PRS=$(gh api repos/$r/pulls 2>/dev/null | jq -r '.[] | "\(.number) \(.title) \(.state)"' 2>/dev/null)
        if [ -n "$PRS" ]; then
            local count=$(echo "$PRS" | wc -l)
            log_info "Found $count PRs in $r"
            echo "$PRS" | while read num title state; do
                log_debug "Processing PR #$num: $title ($state)"
                
                log_debug "Checking rate limit for PR #$num..."
                RATE_REMAINING=$(gh api rate_limit 2>/dev/null | jq -r '.rate.remaining')
                log_debug "Rate limit remaining: $RATE_REMAINING"
                
                if [ "$RATE_REMAINING" -lt 10 ]; then
                    log_warn "Low API rate limit ($RATE_REMAINING), waiting 60s..."
                    sleep 60
                    RATE_REMAINING=$(gh api rate_limit 2>/dev/null | jq -r '.rate.remaining')
                    log_info "After wait, rate limit: $RATE_REMAINING"
                fi
                
                # Use opencode to review and handle the PR (non-interactive)
                log_info "Starting opencode review for PR #$num in $r"
                run_opencode run --continue "Review GitHub pull request #$num in $r. Title: '$title'. Analyze the changes, run tests if applicable, and provide a code review. If CI passes and changes look good, approve the PR with a review comment. Do NOT merge - just approve and leave a review."
                
                local opencode_exit=$?
                log_debug "Opencode returned exit code: $opencode_exit"
                
                if [ $opencode_exit -ne 0 ]; then
                    log_error "Opencode failed for PR #$num (exit $opencode_exit)"
                    log_warn "Initiating retry after 30s backoff..."
                    sleep 30
                fi
                
                log_info "Completed PR #$num review (exit: $opencode_exit)"
            done
        else
            log_debug "No PRs found in $r"
        fi
    done
    log "=== FINISHED CHECKING PRs ==="
}

check_ci() {
    log "=== CHECKING GITHUB ACTIONS CI ==="
    
    # Cache file for already-analyzed CI runs
    local cache_file="$PROJECT_DIR/.ci_failure_cache"
    local current_time=$(date +%s)
    local cache_age=0
    
    if [ -f "$cache_file" ]; then
        cache_age=$((current_time - $(stat -c %Y "$cache_file" 2>/dev/null || echo "$current_time")))
        log_debug "CI cache age: ${cache_age}s"
    fi
    
    # Refresh cache if older than 1 hour
    if [ $cache_age -gt 3600 ]; then
        log_info "CI cache expired (${cache_age}s), clearing..."
        > "$cache_file"
    fi
    
    SINCE=$(date -u -d '24 hours ago' '+%Y-%m-%dT%H:%M:%SZ')
    log_debug "Checking CI failures since: $SINCE"
    
    for r in $REPOS; do
        log_debug "Fetching CI runs for $r..."
        # Get all failed runs
        FAILED=$(gh api repos/$r/actions/runs 2>/dev/null | jq --arg since "$SINCE" -r '.workflow_runs[] | select(.conclusion == "failure") | select(.created_at > $since) | "\(.id) \(.name) \(.created_at)"' 2>/dev/null)
        
        if [ -n "$FAILED" ]; then
            local count=$(echo "$FAILED" | wc -l)
            log_warn "Found $count failed CI runs in $r (last 24h)"
            echo "$FAILED" | while read id name created; do
                log_debug "Analyzing CI failure: Run $id, Workflow: '$name', Created: $created"
                
                # Check if already analyzed in this cache period
                if [ -f "$cache_file" ]; then
                    if grep -q "^${r}:${id}$" "$cache_file" 2>/dev/null; then
                        log_debug "CI run $id already analyzed, SKIPPING"
                        continue
                    fi
                fi
                
                # Rate limit check
                log_debug "Checking rate limit for CI run $id..."
                RATE_REMAINING=$(gh api rate_limit 2>/dev/null | jq -r '.rate.remaining')
                log_debug "Rate limit remaining: $RATE_REMAINING"
                
                if [ "$RATE_REMAINING" -lt 10 ]; then
                    log_warn "Low API rate limit ($RATE_REMAINING), waiting 60s..."
                    sleep 60
                    RATE_REMAINING=$(gh api rate_limit 2>/dev/null | jq -r '.rate.remaining')
                    log_info "After wait, rate limit: $RATE_REMAINING"
                fi
                
                # Add to cache immediately to prevent duplicate analysis
                echo "${r}:${id}" >> "$cache_file"
                log_debug "Added $r:$id to CI cache"
                
                log_info "Starting opencode analysis for CI failure (Run $id)"
                run_opencode run --continue "Analyze GitHub Actions CI failure in $r. Run ID: $id, Workflow: '$name'. Check the failure logs, identify the root cause, and implement a fix. Push the fix if needed."
                
                local opencode_exit=$?
                log_debug "Opencode returned exit code: $opencode_exit"
                
                if [ $opencode_exit -ne 0 ]; then
                    log_error "Opencode failed for CI run $id (exit $opencode_exit)"
                    log_warn "Initiating retry after 30s backoff..."
                    sleep 30
                    
                    run_opencode run --continue "Analyze GitHub Actions CI failure in $r. Run ID: $id, Workflow: '$name'. Check the failure logs, identify the root cause, and implement a fix. Push the fix if needed."
                    opencode_exit=$?
                    
                    if [ $opencode_exit -ne 0 ]; then
                        log_error "Retry FAILED for CI run $id (exit $opencode_exit) - SKIPPING"
                    else
                        log_info "Retry succeeded for CI run $id"
                    fi
                fi
                
                log_info "Completed CI analysis for run $id (exit: $opencode_exit)"
            done
        else
            log_info "No failed CI runs in $r"
        fi
    done
    log "=== FINISHED CHECKING CI ==="
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
                run_opencode run --continue "Analyze release '$tag' in $r: '$name'. Review the release, check for any issues, and update documentation if needed."
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

log "=== STARTING ENCLAVR AUTONOMOUS AGENT ==="
log "Configuration:"
log "  Project Dir: $PROJECT_DIR"
log "  Repos: $REPOS"
log "  Log File: $LOG_FILE"
log "  OpenCode Session: $OPENCODE_SESSION_ID"
log "  Free Models: $OPENCODE_USE_FREE_MODELS"
if [ "$OPENCODE_USE_FREE_MODELS" = "true" ]; then
    log "  Free Model List: ${OPENCODE_FREE_MODELS[*]}"
fi
log "  Log Level: $OPENCODE_LOG_LEVEL"
log "  Show Thinking: $OPENCODE_SHOW_THINKING"
log "==================================="

find_opencode

# Initialize cooldown file if not exists
proactive_cooldown_file="$PROJECT_DIR/.proactive_cooldown"
if [ ! -f "$proactive_cooldown_file" ]; then
    echo 0 > "$proactive_cooldown_file"
    log_debug "Initialized proactive cooldown file"
fi

# Statistics tracking - global variables (not local, outside functions)
loop_count=0
issues_processed=0
prs_processed=0
ci_fixed=0
proactive_runs=0

while true; do
    loop_count=$((loop_count + 1))
    local loop_start=$(date +%s)
    
    log "==================================="
    log "LOOP #$loop_count STARTED"
    log "Current time: $(date '+%Y-%m-%d %H:%M:%S')"
    log "Uptime: $((loop_start / 3600))h $(((loop_start % 3600) / 60))m"
    log "Stats: Issues: $issues_processed, PRs: $prs_processed, CI Fixed: $ci_fixed, Proactive: $proactive_runs"
    log "-----------------------------------"
    
    cd "$PROJECT_DIR" || {
        log_error "Failed to cd to $PROJECT_DIR"
        exit 1
    }
    
    log_debug "Current directory: $(pwd)"
    log_debug "Git status: $(git status --short 2>/dev/null | head -n 10 || echo 'no changes')"
    
    # === Read Memory Banks for Context ===
    log_debug "=== PHASE: Memory Bank Loading ==="
    read_memory_bank
    
    # === GitHub Operations (using gh CLI) ===
    log_debug "=== PHASE: GitHub Operations ==="
    
    # Check gh authentication
    log_debug "Verifying gh CLI authentication..."
    gh auth status 2>&1 | head -n 3 | while IFS= read -r line; do
        log_debug "  gh: $line"
    done
    
    check_issues
    new_issues=$(grep -c "Completed processing issue" "$LOG_FILE" 2>/dev/null || echo 0)
    issues_processed=$((issues_processed + new_issues))
    
    check_pulls
    new_prs=$(grep -c "Completed PR" "$LOG_FILE" 2>/dev/null || echo 0)
    prs_processed=$((prs_processed + new_prs))
    
    check_ci
    new_ci=$(grep -c "Completed CI analysis" "$LOG_FILE" 2>/dev/null || echo 0)
    ci_fixed=$((ci_fixed + new_ci))
    
    check_releases
    manage_labels
    sync_repos
    
    # === Git Submodule Operations ===
    log_debug "=== PHASE: Git Submodule Operations ==="
    log_debug "Checking submodule status..."
    git submodule status 2>/dev/null | head -n 5 | while IFS= read -r line; do
        log_debug "  submodule: $line"
    done
    
    log_debug "Updating submodules..."
    git submodule update --remote --merge 2>&1 | while IFS= read -r line; do
        log_debug "  submodule update: $line"
    done
    
    git add -A 2>/dev/null
    if ! git diff --quiet --staged 2>/dev/null; then
        log_info "Submodule changes detected, committing..."
        git commit -m "chore: update submodules to latest" 2>/dev/null
        git push 2>/dev/null
        log "Submodules updated and pushed"
    else
        log_debug "No submodule changes"
    fi
    
    # === Check for local changes ===
    log_debug "=== PHASE: Change Detection ==="
    if git diff --quiet 2>/dev/null; then
        log_debug "No git changes detected"
        
        # Check cooldown for proactive improvements
        proactive_cooldown_file="$PROJECT_DIR/.proactive_cooldown"
        last_proactive=0
        
        if [ -f "$proactive_cooldown_file" ]; then
            last_proactive=$(cat "$proactive_cooldown_file")
        fi
        
        current_time=$(date +%s)
        time_since_proactive=$((current_time - last_proactive))
        cooldown_seconds=1800  # 30 minutes between proactive runs
        
        if [ $time_since_proactive -lt $cooldown_seconds ]; then
            remaining=$((cooldown_seconds - time_since_proactive))
            log "[COOLDOWN] Skipping proactive improvements - $((remaining / 60))m $(remaining % 60)s remaining (last: $((time_since_proactive / 60))m ago, min: $((cooldown_seconds / 60))m)"
            
            # Log memory and system stats during cooldown
            log_debug "System stats during cooldown:"
            if command -v free &> /dev/null; then
                free -h | head -n 2 | while IFS= read -r line; do
                    log_debug "  $line"
                done
            fi
            if command -v df &> /dev/null; then
                df -h "$PROJECT_DIR" | tail -n 1 | while IFS= read -r line; do
                    log_debug "  disk: $line"
                done
            fi
            
            sleep 30
            continue
        fi
        
        # No external changes - run proactive improvements
        log ">>> NO CHANGES - STARTING PROACTIVE IMPROVEMENTS <<<"
        
        # Update cooldown timestamp BEFORE running (prevent multiple concurrent runs)
        echo "$current_time" > "$proactive_cooldown_file"
        log_debug "Set proactive cooldown timestamp to $current_time ($(date -d @$current_time))"
        
        # Rate limit check before proactive run
        log_debug "Checking GitHub API rate limit..."
        RATE_REMAINING=$(gh api rate_limit 2>/dev/null | jq -r '.rate.remaining')
        log_info "GitHub API rate limit remaining: $RATE_REMAINING"
        
        if [ "$RATE_REMAINING" -lt 20 ]; then
            log_warn "Low GitHub API rate limit ($RATE_REMAINING), skipping proactive improvements..."
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
        elif [ -d "../docs" ]; then
            TASK="Run proactive improvements for documentation: review docs, check for broken links, verify accuracy"
        else
            TASK="Analyze project state and implement improvements per AGENTS.md"
        fi
        
        log_info "Proactive task selected: $TASK"
        run_opencode run --continue "$TASK"
        
        EXIT_CODE=$?
        proactive_runs=$((proactive_runs + 1))
        
        if [ $EXIT_CODE -eq 0 ]; then
            log "✓ Proactive improvements completed successfully"
        else
            log_error "✗ Proactive improvements FAILED (exit code: $EXIT_CODE)"
            # Add backoff on failure
            log_warn "Initiating backoff: waiting 60s after failed proactive run..."
            sleep 60
        fi
        
        # Commit and push
        log_debug "Checking for changes to commit..."
        git add -A 2>/dev/null
        if ! git diff --quiet --staged 2>/dev/null; then
            log_info "Proactive changes detected, committing..."
            git diff --cached --stat 2>/dev/null | head -n 20 | while IFS= read -r line; do
                log_debug "  change: $line"
            done
            
            git commit -m "Proactive improvements: $(date '+%Y-%m-%d %H:%M')" 2>/dev/null
            log_debug "Committing to git..."
            
            git push 2>/dev/null
            log "✓ Proactive changes committed and pushed"
            
            # Show what changed in memory banks
            log_debug "Memory bank updates:"
            if [ -d "server/memory-bank" ]; then
                log_debug "  server/memory-bank/activeContext.md updated"
            fi
            if [ -d "frontend/memory-bank" ]; then
                log_debug "  frontend/memory-bank/activeContext.md updated"
            fi
            if [ -d "infra/memory-bank" ]; then
                log_debug "  infra/memory-bank/activeContext.md updated"
            fi
            
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
            if [ -d "../docs" ]; then
                update_memory_bank "docs" "Proactive improvements completed"
            fi
            update_memory_bank "root" "Proactive improvements completed"
        else
            log_debug "No changes to commit from proactive run"
        fi
        
        loop_duration=$(( $(date +%s) - loop_start ))
        log "PROACTIVE CYCLE COMPLETE (duration: ${loop_duration}s)"
        log "-----------------------------------"
        sleep 60
        continue
    fi
    
    # === Changes detected ===
    log ">>> CHANGES DETECTED - STARTING AGENT <<<"
    
    git add -A 2>/dev/null
    
    CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null | head -5)
    log_info "Changed files (top 5):"
    echo "$CHANGED_FILES" | while IFS= read -r file; do
        log_debug "  modified: $file"
    done
    
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
    
    run_opencode run --continue "$TASK"
    
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        log "✓ Agent completed successfully"
    else
        log_error "✗ Agent FAILED with exit code $EXIT_CODE"
    fi
    
    # Commit and push
    if ! git diff --quiet --staged 2>/dev/null; then
        log_info "Agent produced changes, committing..."
        git diff --cached --stat 2>/dev/null | head -n 20 | while IFS= read -r line; do
            log_debug "  change: $line"
        done
        
        git commit -m "Autonomous agent: $(date '+%Y-%m-%d %H:%M')" 2>/dev/null
        log_debug "Committing to git..."
        
        git push 2>/dev/null
        log "✓ Changes committed and pushed"
        
        # Show recent commit
        latest_commit=$(git log -1 --oneline 2>/dev/null)
        log_debug "Latest commit: $latest_commit"
        
        # Update memory banks after changes
        update_memory_bank "$TARGET_REPO" "Changes processed and improvements implemented"
    else
        log_debug "No changes to commit from agent run"
    fi
    
    local loop_duration=$(( $(date +%s) - loop_start ))
    log "LOOP #$loop_count COMPLETE (duration: ${loop_duration}s)"
    log "==================================="
    
    # Adaptive sleep based on activity
    local sleep_time=30
    if [ $EXIT_CODE -ne 0 ]; then
        sleep_time=60  # Longer sleep after failure
        log_warn "Backoff: sleeping ${sleep_time}s after failure"
    else
        log_debug "Normal cycle: sleeping ${sleep_time}s"
    fi
    
    sleep $sleep_time
done
