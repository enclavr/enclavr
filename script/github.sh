#!/bin/bash

# GitHub CLI operations

check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is not installed"
        log_error "Install via: https://github.com/cli/cli#installation"
        return 1
    fi

    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI is not authenticated"
        log_error "Run: gh auth login"
        return 1
    fi

    log_debug "gh CLI found and authenticated"
    return 0
}

is_safe_issue() {
    local body="$1"
    local danger_patterns="ignore.*previous|forget.*above|you are now|emergency|urgent|critical.*now|just do|don't tell|eval\(|exec\(|subprocess|rm -rf|curl.*sh|wget.*sh|base64|decoded|backdoor|reverse shell"
    if echo "$body" | grep -Ei "$danger_patterns" >/dev/null 2>&1; then
        return 1
    fi
    return 0
}

# OPTIMIZED: Use compact task format with prefix instead of repeating instructions
check_issues() {
    log "Checking GitHub issues..."

    # Compact: ~80 tokens vs ~400 before
    local task="$PROMPT_PREFIX

Analyze ALL 5 repos in PARALLEL (enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra, enclavr/docs):
1. Get open issues via 'gh api repos/<repo>/issues'
2. Analyze each, research if needed, implement fix
3. Do NOT close - just fix

Report: issues addressed per repo."

    run_kilo run --continue "$task"
}

# OPTIMIZED: Compact format
check_pulls() {
    log "Checking GitHub pull requests..."

    local task="$PROMPT_PREFIX

Review PRs in ALL 5 repos PARALLEL:
1. Get open PRs via 'gh api repos/<repo>/pulls'
2. Analyze changes, run tests
3. Approve if CI passes - do NOT merge

Report: PRs reviewed per repo."

    run_kilo run --continue "$task"
}

# OPTIMIZED: Compact format  
check_ci() {
    log "Checking GitHub Actions CI..."

    local task="$PROMPT_PREFIX

Analyze CI failures in ALL 5 repos PARALLEL:
1. Get failed runs: 'gh api repos/<repo>/actions/runs?status=failure'
2. Check logs: 'gh api repos/<repo>/actions/runs/<id>/logs'
3. Identify root cause, implement fix

Report: failures fixed per repo."

    run_kilo run --continue "$task"
}

# OPTIMIZED: Compact format
check_releases() {
    log "Checking GitHub releases..."

    local task="$PROMPT_PREFIX

Analyze releases in ALL 5 repos PARALLEL:
1. Get recent releases: 'gh api repos/<repo>/releases'
2. Review notes and assets
3. Update docs if needed

Report: releases analyzed per repo."

    run_kilo run --continue "$task"
}

sync_repos_via_kilo() {
    log "Syncing repositories via Kilo..."

    local task="$PROMPT_PREFIX

Sync ALL 5 repos PARALLEL via 'gh repo sync -R <repo>':
- enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra, enclavr/docs

Report: repos synced."

    run_kilo run --continue "$task"
    return $?
}

sync_repos() {
    log "Syncing repositories via Kilo..."
    sync_repos_via_kilo
}

check_rate_limit() {
    RATE_REMAINING=$(gh api rate_limit 2>/dev/null | jq -r '.rate.remaining')
    if [ "$RATE_REMAINING" -lt 20 ]; then
        log_warn "Low GitHub API rate limit ($RATE_REMAINING), skipping"
        return 1
    fi
    return 0
}
