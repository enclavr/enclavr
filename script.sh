#!/bin/bash

# Enclavr Autonomous Agent Loop
# Runs continuously with smart change detection and logging
#
# This script uses Kilo/Opencode with MCP (Model Context Protocol) tools:
# - Git MCP tools for version control
# - Neon MCP tools for database operations
# - Sentry MCP tools for error tracking
# - Context7 MCP tools for documentation lookup
# - Web tools for current information
# See AGENTS.md for full MCP tool documentation.

LOG_FILE="/home/dev/Projects/enclavr/agent-$(date '+%Y%m%d').log"
PROJECT_DIR="/home/dev/Projects/enclavr"
REPOS="enclavr/enclavr enclavr/frontend enclavr/server enclavr/infra"

# Agent logging configuration - reduced verbosity
AGENT_LOG_LEVEL="WARN"  # Only warnings and errors
AGENT_PRINT_LOGS="false"  # Don't print to stderr
AGENT_SHOW_THINKING="false" # Hide AI thinking blocks
AGENT_FORMAT="default"   # Human-readable format

# Session configuration
AGENT_SESSION_ID="enclavr-autonomous-$(hostname)-$(date '+%Y%m%d')" # Persistent session ID
AGENT_TYPE=""  # Optional: specific agent type
AGENT_TIMEOUT=600  # 10 minute timeout for agent runs

# Alternate between kilo and opencode
CURRENT_PROVIDER="kilo"  # Start with kilo
PROVIDER_COOLDOWN_FILE="$PROJECT_DIR/.provider_cooldown"

log() {
    local level="${2:-INFO}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $1" | tee -a "$LOG_FILE"
}

# Rotate log if larger than 10MB
if [ -f "$LOG_FILE" ]; then
    size=$(stat -c %s "$LOG_FILE" 2>/dev/null || echo 0)
    if [ "$size" -gt 10485760 ]; then
        mv "$LOG_FILE" "${LOG_FILE}.old"
        echo "Log rotated (was ${size} bytes)" > "$LOG_FILE"
    fi
fi

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

AGENT_PATH=""
KILO_SEARCH_PATHS="/home/dev/.kilo/bin:/usr/local/bin:/usr/bin:/bin"
OPENCODE_SEARCH_PATHS="/home/dev/.opencode/bin:/usr/local/bin:/usr/bin:/bin"

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

# ========== Shared State via Memory Bank ==========

SHARED_STATE_FILE="$PROJECT_DIR/memory-bank/shared-state.md"

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

    # Read existing state or create new
    local existing_state=""
    if [ -f "$SHARED_STATE_FILE" ]; then
        existing_state=$(cat "$SHARED_STATE_FILE")
    fi

    # Build new state entry
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

    # Keep last 3 entries only (was 10)
    local state_content="$new_entry$existing_state"
    local trimmed=$(echo "$state_content" | head -50)

    echo "$trimmed" > "$SHARED_STATE_FILE"
    log_info "Updated shared state: $provider - $task_summary - $status"
}

get_shared_context() {
    # Get context from the OTHER provider (for continuity)
    # ONLY pass last 3 entries to avoid context overflow
    if [ -f "$SHARED_STATE_FILE" ]; then
        local last_provider=""
        local context=""

        # Extract last provider from state
        last_provider=$(grep -A2 "## Last Run" "$SHARED_STATE_FILE" | grep "Provider" | head -1 | sed 's/.*: //')

        if [ -n "$last_provider" ]; then
            # Only pass last ~30 lines (2-3 entries) to stay under context limit
            context=$(head -35 "$SHARED_STATE_FILE")
            log_info "Found context from previous $last_provider session (truncated)"
            echo "$context"
        fi
    fi
}

get_next_provider() {
    local current="$1"
    
    if [ "$current" = "kilo" ]; then
        echo "opencode"
    else
        echo "kilo"
    fi
}

run_agent() {
    # Switch provider for each call to balance load/rate limits
    CURRENT_PROVIDER=$(get_next_provider "$CURRENT_PROVIDER")
    
    if ! find_agent "$CURRENT_PROVIDER"; then
        # Fall back to the other provider if one fails
        local fallback=$(get_next_provider "$CURRENT_PROVIDER")
        log_warn "$CURRENT_PROVIDER not available, trying $fallback..."
        CURRENT_PROVIDER="$fallback"
        find_agent "$CURRENT_PROVIDER" || return 1
    fi

    local task_summary="${1:0:50}"

    # === Read shared state from previous agent (TRUNCATED) ===
    # Skip if previous runs had context overflow issues
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

    # Build agent command with minimal logging options
    local cmd=("$AGENT_PATH" "run" "--continue" "--session" "$AGENT_SESSION_ID" "--title" "Enclavr Agent: $task_summary...")

    # Add logging flags (already configured via env vars)
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

    # Add the message
    cmd+=("$@")

    log_info "Executing task with $CURRENT_PROVIDER... (timeout: ${AGENT_TIMEOUT}s)"
    local start_time=$(date +%s)

    # Execute with timeout
    local output_file=$(mktemp)
    local exit_code=124  # Default to timeout

    if command -v timeout &> /dev/null; then
        timeout "$AGENT_TIMEOUT" "${cmd[@]}" 2>&1 | tee -a "$LOG_FILE" | tee "$output_file"
        exit_code=${PIPESTATUS[0]}
    else
        # Fallback: run without timeout but log warning
        log_warn "timeout command not available - running without timeout"
        "${cmd[@]}" 2>&1 | tee -a "$LOG_FILE" | tee "$output_file"
        exit_code=${PIPESTATUS[0]}
    fi

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Handle timeout specifically
    if [ $exit_code -eq 124 ]; then
        log_warn "Task timed out after ${AGENT_TIMEOUT}s"
        echo "Task timed out after ${AGENT_TIMEOUT}s" >> "$output_file"
    fi

    log_info "Task completed in ${duration}s (exit: $exit_code)"

    # Clear context overflow flag on success
    if [ $exit_code -eq 0 ]; then
        # Remove any context overflow markers from shared state
        if grep -q "context length" "$SHARED_STATE_FILE" 2>/dev/null; then
            sed -i '/context length/d' "$SHARED_STATE_FILE"
            log_info "Cleared context overflow flag after successful run"
        fi
    fi

    # === Write shared state for next agent ===
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

# Alias for backward compatibility
run_kilo() {
    run_agent "$@"
}

check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is not installed"
        log_error "Install via: https://github.com/cli/cli#installation"
        return 1
    fi

    # Check gh is authenticated
    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI is not authenticated"
        log_error "Run: gh auth login"
        return 1
    fi

    log_debug "gh CLI found and authenticated"
    return 0
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
    for submodule in frontend server infra; do
        if [ -d "$PROJECT_DIR/$submodule/memory-bank" ]; then
            if [ -f "$PROJECT_DIR/$submodule/memory-bank/activeContext.md" ]; then
                submodules_count=$((submodules_count + 1))
            fi
        fi
    done

    log_info "Memory banks loaded (${submodules_count} submodules)"
}

update_memory_bank_via_kilo() {
    local repo="$1"
    local change_summary="$2"

    log "Updating memory bank for $repo via Kilo..."

    local task="Update the memory bank for repository '$repo':
1. Read the current activeContext.md file at '$PROJECT_DIR/$repo/memory-bank/activeContext.md' (or '$PROJECT_DIR/memory-bank/activeContext.md' for root)
2. Update the 'Current Work Focus' section with: '$change_summary'
3. Add a new 'Latest Update' section with today's date and describe: '$change_summary'

Use proper markdown formatting and preserve existing content. Report what you updated."

    run_kilo run --continue "$task"
    return $?
}

update_memory_bank() {
    local repo="$1"
    local change_summary="$2"

    log "Updating memory bank for $repo..."
    update_memory_bank_via_kilo "$repo" "$change_summary"
}

# ========== Git Commit/Push via Kilo ==========

commit_and_push() {
    local commit_message="$1"
    local timeout="${2:-120}"

    log_info "Checking for changes to commit..."

    # First, check if there are any changes to commit
    if git diff --quiet 2>/dev/null && git diff --quiet --staged 2>/dev/null; then
        log "No changes to commit"
        return 0
    fi

    # === STEP 1: Review changes ===
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

    # Use run_agent which handles provider switching
    run_agent "$review_task" 2>&1 | tee -a "$LOG_FILE" | tee "$review_output"
    review_exit=${PIPESTATUS[0]}

    # Check if review approved or rejected
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

    # === STEP 2: Commit and push ===
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

# ========== GitHub CLI Management via Kilo ==========

# Security: Detect dangerous patterns in issue bodies
is_safe_issue() {
    local body="$1"
    # Check for prompt injection patterns
    local danger_patterns="ignore.*previous|forget.*above|you are now|emergency|urgent|critical.*now|just do|don't tell|eval\(|exec\(|subprocess|rm -rf|curl.*sh|wget.*sh|base64|decoded|backdoor|reverse shell"
    echo "$body" | grep -Ei "$danger_patterns" >/dev/null 2>&1
    return $?
}

# ========== Kilo-based GitHub Operations ==========

update_submodules_via_kilo() {
    log "Updating submodules via Kilo..."

    local task="Update git submodules to their latest remote versions:
1. Run 'git submodule status' to see current submodule states
2. Run 'git submodule update --remote --merge' to fetch and merge latest
3. Review any changes that occurred
4. If there are changes, stage and commit them with message 'chore: update submodules to latest'

Report what submodules were updated, if any."

    run_kilo run --continue "$task"
    return $?
}

manage_labels_via_kilo() {
    log "Managing GitHub labels via Kilo..."

    local task="Ensure the following labels exist in all enclavr repositories (enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra):
- bug:Issue bug (color: ee0701)
- feature:Issue feature (color: 008672)
- enhancement:Issue enhancement (color: 84b6eb)
- documentation:Issue documentation (color: d4c5f9)
- security:Issue security (color: ee0701)

Use 'gh label create' to create any missing labels. Report which labels were created."

    run_kilo run --continue "$task"
    return $?
}

sync_repos_via_kilo() {
    log "Syncing repositories via Kilo..."

    local task="Sync all enclavr repositories with their remote counterparts:
- enclavr/enclavr (root monorepo)
- enclavr/frontend
- enclavr/server
- enclavr/infra

Use 'gh repo sync -R <repo>' to sync each repository. This fetches the latest commits from remote. Report which repos were synced."

    run_kilo run --continue "$task"
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
    log "Ensuring common labels exist via Kilo..."
    manage_labels_via_kilo
}

sync_repos() {
    log "Syncing repositories via Kilo..."
    sync_repos_via_kilo
}

# ========== Branch Management ==========

cleanup_stale_branches() {
    log "Checking for stale branches..."

    local stale_days=7
    local cutoff_date=$(date -u -d "$stale_days days ago" '+%Y-%m-%dT%H:%M:%SZ')

    for r in $REPOS; do
        # Get branches merged to main more than $stale_days ago
        local merged_branches=$(gh api repos/$r/git/commits/main --jq '.sha' 2>/dev/null)
        if [ -z "$merged_branches" ]; then
            continue
        fi

        # List branches (excluding main)
        local branches=$(gh api repos/$r/git/refs/heads --jq '.[].ref' 2>/dev/null | grep -v '^main$')

        for branch in $branches; do
            # Get branch commit date
            local branch_date=$(gh api repos/$r/git/commits/$branch --jq '.commit.author.date' 2>/dev/null)
            if [ -z "$branch_date" ]; then
                continue
            fi

            # Check if older than cutoff
            if [[ "$branch_date" < "$cutoff_date" ]]; then
                log "Deleting stale branch: $branch in $r"
                gh api -X DELETE repos/$r/git/refs/heads/$branch 2>/dev/null && \
                    log "Deleted stale branch $branch in $r" || \
                    log_warn "Failed to delete branch $branch in $r"
            fi
        done
    done

    # Also check root repo for stale branches
    cd "$PROJECT_DIR" || return
    local local_branches=$(git branch --format='%(refname:short)' 2>/dev/null | grep -v '^main$')
    for branch in $local_branches; do
        local last_commit_date=$(git log -1 --format=%ci $branch 2>/dev/null)
        if [ -n "$last_commit_date" ]; then
            local commit_timestamp=$(date -d "$last_commit_date" +%s 2>/dev/null)
            local cutoff_timestamp=$(date -d "$stale_days days ago" +%s 2>/dev/null)
            if [ "$commit_timestamp" -lt "$cutoff_timestamp" ]; then
                log "Deleting stale local branch: $branch"
                git branch -D $branch 2>/dev/null && \
                    git push origin --delete $branch 2>/dev/null && \
                    log "Deleted stale branch $branch" || \
                    log_warn "Failed to delete branch $branch"
            fi
        fi
    done
}

create_release_tag() {
    local repo="$1"
    local tag_name="v$(date +'%Y.%m.%d')"

    # Check if tag already exists today
    local existing_tag=$(gh api repos/$repo/tags --jq '.[].name' 2>/dev/null | grep "^${tag_name}$")
    if [ -n "$existing_tag" ]; then
        log "Tag $tag_name already exists in $repo"
        return 0
    fi

    # Get main branch SHA
    local main_sha=$(gh api repos/$repo/git/refs/heads/main --jq '.object.sha' 2>/dev/null)
    if [ -z "$main_sha" ]; then
        log_warn "Could not get main SHA for $repo"
        return 1
    fi

    # Create annotated tag
    local tag_message="Automated release $(date +'%Y-%m-%d')"
    gh api repos/$repo/git/tags -f tag="refs/tags/$tag_name" \
        -f message="$tag_message" \
        -f object="$main_sha" \
        -f type=commit 2>/dev/null

    # Create reference
    gh api repos/$repo/git/refs -f ref="refs/tags/$tag_name" -f sha="$main_sha" 2>/dev/null

    log "Created release tag $tag_name in $repo"
}

manage_branches() {
    log "Managing branches and tags..."
    cleanup_stale_branches
}

# ========== Main Loop ==========

log "Starting Enclavr Autonomous Agent"
log "Configuration:"
log "  Log File: $LOG_FILE"
log "  Session: $AGENT_SESSION_ID"
log "  Log Level: $AGENT_LOG_LEVEL"
log "  Timeout: ${AGENT_TIMEOUT}s"
log "  Starting Provider: $CURRENT_PROVIDER"
log "==================================="

# Verify prerequisites
check_gh_cli || exit 1

# Initialize both providers
find_agent "kilo" || log_warn "kilo not found"
find_agent "opencode" || log_warn "opencode not found"

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
        log "Updating submodules via Kilo..."
        update_submodules_via_kilo
        commit_and_push "chore: update submodules to latest" 120
        last_submodule_update=$loop_start
    fi

    # === GitHub Management (periodic) ===
    if [ $((loop_start - last_github_check)) -ge $github_check_interval ]; then
        check_issues
        check_pulls
        check_ci
        check_releases
        manage_labels
        manage_branches
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

        # Commit and push via Kilo
        commit_and_push "Proactive improvements: $(date '+%Y-%m-%d %H:%M')" 120

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

        log "Proactive cycle complete"
        sleep 30
        continue
    fi

     # Changes detected
    log "Changes detected"

    CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null | head -5)

    if echo "$CHANGED_FILES" | grep -q "server/"; then
        TARGET_REPO="server"
        TASK="Analyze server changes and run tests, lint, then implement improvements"
    elif echo "$CHANGED_FILES" | grep -q "frontend/"; then
        TARGET_REPO="frontend"
        TASK="Analyze frontend changes and run tests, lint, then implement improvements"
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

    # Commit and push via Kilo
    commit_and_push "Autonomous agent: $(date '+%Y-%m-%d %H:%M')" 120

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
