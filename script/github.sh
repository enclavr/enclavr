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

# Enhanced issue handling - read comments, interact with users, close when fixed
check_issues() {
    log "Checking GitHub issues with full interaction..."

    local task="$PROMPT_PREFIX

You are an autonomous agent managing GitHub issues for the Enclavr project.

For EACH of these 5 repos (enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra, enclavr/docs):

STEP 1 - GET ISSUES WITH COMMENTS:
Run: gh api repos/<owner>/<repo>/issues --state open --jq '.[] | {number: .number, title: .title, author: .user.login, body: .body, comments: .comments, created_at: .created_at, updated_at: .updated_at}'

For each issue with comments (>0), fetch them:
Run: gh api repos/<owner>/<repo>/issues/<number>/comments --jq '.[] | {author: .user.login, body: .body, created_at: .created_at}'

STEP 2 - ANALYZE AND RESPOND:
For each issue:
- Read the issue description and ALL comments
- If user asks questions -> Answer their questions with helpful details
- If user provides feedback -> Acknowledge and respond appropriately  
- If user reports a bug -> Investigate, find root cause, implement fix
- If issue is vague -> Ask clarifying questions via comment
- If issue is feature request -> Evaluate, implement if feasible, discuss approach

STEP 3 - CLOSE ISSUES WHEN FIXED:
After implementing a fix:
1. Run tests to verify fix works
2. Commit the fix with descriptive message
3. Comment on issue: 'Fixed in commit $(git rev-parse --short HEAD)'
4. Close the issue: gh issue close <number> --repo <owner>/<repo>

STEP 4 - HANDLE ISSUE LIFECYCLE:
- If issue was resolved -> Close it with 'Resolved' state
- If issue is duplicate -> Comment 'Duplicate of #<original>' and close
- If issue is invalid -> Comment reason and close
- If issue needs more info -> Ask via comment, don't close yet
- If issue is wontfix -> Discuss with author, close if agreed

IMPORTANT: Actually interact with users by posting comments. Don't just fix silently.

Report format per repo:
| Repo | Issues | Responses | Fixes | Closures |
|------|--------|-----------|-------|----------|"

    run_kilo run "$task"
}

# Enhanced PR handling - review, test, and merge when ready
check_pulls() {
    log "Checking GitHub pull requests..."

    local task="$PROMPT_PREFIX

You are an autonomous agent managing pull requests for the Enclavr project.

For EACH of these 5 repos (enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra, enclavr/docs):

STEP 1 - GET OPEN PRS:
Run: gh api repos/<owner>/<repo>/pulls --state open --jq '.[] | {number: .number, title: .title, author: .user.login, state: .state, base: .base.ref, head: .head.ref, draft: .draft, merged: .merged_at}'

STEP 2 - REVIEW AND TEST:
For each PR:
- Get diff: gh pr diff <number> --repo <owner>/<repo>
- Get changed files: gh pr view <number> --json files --repo <owner>/<repo>
- Run appropriate tests (lint, typecheck, unit tests)
- Check CI status: gh api repos/<owner>/<repo>/actions/runs?event=pull_request&head=<branch>

STEP 3 - INTERACT WITH AUTHORS:
- If tests fail -> Comment: 'Tests failed. Please address the failures.'
- If lint fails -> Comment with specific issues
- If changes look good but needs review -> Approve: gh pr review <number> --approve --repo <owner>/<repo>
- If needs changes -> Request changes with detailed feedback

STEP 4 - MERGE WHEN READY:
When PR is approved and CI passes:
- Ensure branch is up to date with main
- Merge PR: gh pr merge <number> --admin --repo <owner>/<repo>
- Or squash merge: gh pr merge <number> --squash --repo <owner>/<repo>
- Delete branch: gh pr checkout <number> && git push origin --delete <branch> --repo <owner>/<repo>

STEP 5 - HANDLE CI FAILURES:
If CI fails:
- Analyze failure logs
- Comment with root cause
- If it's a test flakiness, re-run: gh run rerun <run_id> --repo <owner>/<repo>
- If it's a real bug -> Request changes

IMPORTANT: Actively engage with PR authors through comments.

Report format per repo:
| Repo | Open PRs | Reviewed | Merged | Closed |
|------|----------|----------|--------|--------|"

    run_kilo run "$task"
}

# Enhanced CI handling - analyze failures, interact, and fix
check_ci() {
    log "Checking GitHub Actions CI..."

    local task="$PROMPT_PREFIX

You are an autonomous agent debugging CI failures for the Enclavr project.

For EACH of these 5 repos (enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra, enclavr/docs):

STEP 1 - GET FAILED RUNS:
Run: gh api repos/<owner>/<repo>/actions/runs?status=failure --jq '.workflow_runs[] | {id: .id, name: .name, head_branch: .head_branch, conclusion: .conclusion, created_at: .created_at, html_url: .html_url}'

STEP 2 - ANALYZE FAILURE:
For each failed run:
- Get jobs: gh api repos/<owner>/<repo>/actions/runs/<id>/jobs --jq '.jobs[] | {name: .name, conclusion: .conclusion}'
- Get logs for failed job: gh api repos/<owner>/<repo>/actions/jobs/<job_id>/logs (raw)
- Or use: gh run view <id> --repo <owner>/<repo> --log

STEP 3 - IDENTIFY ROOT CAUSE:
- Parse error messages
- Check if it's a test failure, lint error, build error, or infrastructure issue
- Look for patterns in recent commits

STEP 4 - IMPLEMENT FIX:
- If test failure -> Fix the test or code
- If lint error -> Fix linting issues
- If build error -> Fix build configuration
- If infrastructure (OOM, timeout) -> Adjust CI config
- If dependency issue -> Update dependencies

STEP 5 - RE-RUN AND VERIFY:
After fix:
- Commit changes
- Re-run workflow: gh run rerun <id> --repo <owner>/<repo>
- Or push new commit to trigger CI again

STEP 6 - REPORT:
If failure was due to billing limits (not code issue):
- Note in report but don't try to fix

Report format per repo:
| Repo | Failures | Fixed | Re-runs | Notes |
|------|----------|-------|---------|-------|"

    run_kilo run "$task"
}

# Enhanced releases - analyze and interact
check_releases() {
    log "Checking GitHub releases..."

    local task="$PROMPT_PREFIX

You are an autonomous agent managing releases for the Enclavr project.

For EACH of these 5 repos (enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra, enclavr/docs):

STEP 1 - GET RECENT RELEASES:
Run: gh api repos/<owner>/<repo>/releases --jq '.[] | {id: .id, tag: .tag_name, name: .name, draft: .draft, prerelease: .prerelease, created_at: .created_at, published_at: .published_at}'

STEP 2 - ANALYZE EACH RELEASE:
- Check release notes completeness
- Verify all expected assets are present
- Compare with recent commits since last release

STEP 3 - UPDATE IF NEEDED:
- If release notes are incomplete -> Update them
- If missing assets -> Note in report
- If it's a new release -> Verify changelog

STEP 4 - CREATE RELEASE IF NEEDED:
- Check commits since last release
- If significant changes -> Consider creating release
- Use: gh release create <tag> --title <title> --notes <notes> --repo <owner>/<repo>

STEP 5 - UPDATE DOCUMENTATION:
- If new release -> Update docs with version info
- Check if docs need updating for new features

Report format per repo:
| Repo | Releases | Analyzed | Updated | Notes |
|------|----------|----------|---------|-------|"

    run_kilo run "$task"
}

sync_repos_via_kilo() {
    log "Syncing repositories via Kilo..."

    local task="$PROMPT_PREFIX

Sync ALL 5 repos PARALLEL via 'gh repo sync -R <repo>':
- enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra, enclavr/docs

Report: repos synced."

    run_kilo run "$task"
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

# Check recently closed issues for regressions
check_closed_issues() {
    log "Checking recently closed issues for regressions..."

    local task="$PROMPT_PREFIX

You are an autonomous agent monitoring recently closed issues for regressions.

For EACH of these 5 repos (enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra, enclavr/docs):

STEP 1 - GET RECENTLY CLOSED ISSUES:
Run: gh api repos/<owner>/<repo>/issues?state=closed\&sort=updated\&direction=desc --jq '.[] | select(.state_reason == "completed" or .state_reason == "not_planned") | {number: .number, title: .title, author: .user.login, closed_at: .closed_at, state_reason: .state_reason}' | head -20

STEP 2 - CHECK FOR REGRESSIONS:
For each recently closed issue:
- Read the issue description to understand what was fixed
- Check if the fix is still working (run tests, verify code)
- Look for any new commits that might have reverted the fix

STEP 3 - MONITOR FOR REOPENING:
- Check if issue was reopened: gh issue view <number> --repo <owner>/<repo>
- If reopened -> Investigate why, re-fix, and close again

STEP 4 - RESPOND TO ISSUE AUTHOR:
If you find a regression:
- Comment on the issue: 'Detected regression. Investigating...'
- Fix the issue
- Comment: 'Regression fixed in commit <sha>'
- Close again

STEP 5 - VERIFY CLOSURE:
- Ensure closed issues stay closed
- Check for any new related issues that might indicate unfixed problems

IMPORTANT: Be proactive about preventing regressions.

Report format per repo:
| Repo | Closed | Verified | Reopened | Fixes |
|------|--------|----------|----------|-------|"

    run_kilo run "$task"
}
