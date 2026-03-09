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

check_issues() {
    log "Checking GitHub issues..."

    local task="IMPORTANT: Before starting, read the memory bank files to understand current state. After completing work, update the memory bank with what was done. Use sub-agents to analyze issues in ALL repositories in PARALLEL. Spawn separate sub-agents for enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra, enclavr/docs. For each repository:
1. Get all open issues using 'gh api repos/<repo>/issues'
2. For each issue, analyze the title and body
3. Assess each issue, research if needed, and implement a fix or provide a detailed solution
4. Do NOT close issues - implement the solution

Use sub-agents to process multiple repositories concurrently. Report what issues were addressed in each repository."

    run_kilo run --continue "$task"
}

check_pulls() {
    log "Checking GitHub pull requests..."

    local task="IMPORTANT: Before starting, read the memory bank files to understand current state. After completing work, update the memory bank with what was done. Use sub-agents to review PRs in ALL repositories in PARALLEL. Spawn sub-agents for enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra, enclavr/docs. For each repository:
1. Get all open pull requests using 'gh api repos/<repo>/pulls'
2. For each PR, analyze the changes using 'gh pr view <num>'
3. Run tests if applicable
4. Provide a code review - if CI passes and changes look good, approve the PR with a review comment
5. Do NOT merge - just approve and leave a review

Use sub-agents to process multiple repositories concurrently. Report which PRs were reviewed in each repository."

    run_kilo run --continue "$task"
}

check_ci() {
    log "Checking GitHub Actions CI..."

    local task="IMPORTANT: Before starting, read the memory bank files to understand current state. After completing work, update the memory bank with what was done. Use sub-agents to analyze CI failures in ALL repositories in PARALLEL. Spawn sub-agents for enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra, enclavr/docs. For each repository:
1. Get all failed CI runs from the last 24 hours using 'gh api repos/<repo>/actions/runs'
2. Filter for runs with conclusion 'failure'
3. For each failed run, check the failure logs using 'gh api repos/<repo>/actions/runs/<run_id>/logs'
4. Identify the root cause of the failure
5. Implement a fix and push if needed

Use sub-agents to process multiple repositories concurrently. Report which CI failures were analyzed and fixed in each repository."

    run_kilo run --continue "$task"
}

check_releases() {
    log "Checking GitHub releases..."

    local task="IMPORTANT: Before starting, read the memory bank files to understand current state. After completing work, update the memory bank with what was done. Use sub-agents to analyze releases in ALL repositories in PARALLEL. Spawn sub-agents for enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra, enclavr/docs. For each repository:
1. Get recent releases using 'gh api repos/<repo>//releases'
2. For each release, review the release notes and assets
3. Check for any issues or problems with the release
4. Update documentation if needed

Use sub-agents to process multiple repositories concurrently. Report which releases were analyzed in each repository."

    run_kilo run --continue "$task"
}

sync_repos_via_kilo() {
    log "Syncing repositories via Kilo..."

    local task="IMPORTANT: Before starting, read the memory bank files to understand current state. After completing work, update the memory bank with what was done. Use sub-agents to sync ALL 5 repositories in PARALLEL. Sync all enclavr repositories with their remote counterparts:
- enclavr/enclavr (root monorepo)
- enclavr/frontend
- enclavr/server
- enclavr/infra
- enclavr/docs

Use 'gh repo sync -R <repo>' to sync each repository. This fetches the latest commits from remote. Report which repos were synced."

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
