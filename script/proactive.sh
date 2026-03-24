#!/bin/bash

# Proactive improvements - adding NEW FEATURES + maintaining/refactoring existing code

init_proactive_cooldown() {
    if [ ! -f "$PROACTIVE_COOLDOWN_FILE" ]; then
        echo 0 > "$PROACTIVE_COOLDOWN_FILE"
        log_debug "Initialized proactive cooldown file"
    fi
}

can_run_proactive() {
    last_proactive=0
    if [ -f "$PROACTIVE_COOLDOWN_FILE" ]; then
        last_proactive=$(cat "$PROACTIVE_COOLDOWN_FILE")
    fi

    current_time=$(date +%s)
    time_since_proactive=$((current_time - last_proactive))

    if [ $time_since_proactive -lt $PROACTIVE_COOLDOWN ]; then
        remaining=$((PROACTIVE_COOLDOWN - time_since_proactive))
        log "[COOLDOWN] ${remaining}s remaining"
        return 1
    fi

    return 0
}

set_proactive_cooldown() {
    current_time=$(date +%s)
    echo "$current_time" > "$PROACTIVE_COOLDOWN_FILE"
}

PROACTIVE_MCP_REFS="Use MCP tools. REQUIRED: You MUST use Chrome DevTools for ALL browser verification: chrome-devtools_list_pages, chrome-devtools_navigate_page --type url --url http://localhost:3000, chrome-devtools_take_snapshot, chrome-devtools_list_console_messages, chrome-devtools_list_network_requests. Also available: Sentry (sentry_search_issues, sentry_search_events, sentry_analyze_issue_with_seer, sentry_update_issue), Neon (neon_run_sql, neon_list_slow_queries, neon_explain_sql_statement, neon_get_database_tables), Context7 (context7_resolve-library-id, context7_query-docs), Git (mcp-server-git_git_status, mcp-server-git_git_diff)."

run_proactive() {
    log "Proactive improvements - adding new features + maintaining existing code..."

    if ! check_rate_limit; then
        return 1
    fi

    # Start Chrome for browser testing if doing frontend work
    if [ -d "frontend" ]; then
        if ! curl -s http://localhost:9222/json/version >/dev/null 2>&1; then
            log "Starting Chrome for browser testing..."
            google-chrome --headless=new --remote-debugging-port=9222 --no-sandbox --disable-gpu --disable-dev-shm-usage >/dev/null 2>&1 &
            sleep 2
        fi
    fi

    set_proactive_cooldown

    log_debug "$PROACTIVE_MCP_REFS"

    local TASK=""
    local MCP_REF="$PROACTIVE_MCP_REFS"
    if [ -d "server" ] && [ -d "frontend" ]; then
        case $((RANDOM % 8)) in
            0) TASK="$MCP_REF 1) MAINTENANCE: Run code review, fix bugs, add tests for uncovered code, refactor messy functions, update dependencies. 2) NEW FEATURE: Add a new API endpoint (e.g., user profile, settings, message reactions, room invites). Design, implement, test.

IMPORTANT: Before starting, create a GitHub issue:
1. Use 'gh issue create --title \"Proactive: [feature area]\" --body \"Task: [description]\" --repo enclavr/server' or 'enclavr/frontend'
2. Note the issue number
3. After completing, resolve with 'gh issue close <number> --repo <repo>' and add resolution comment" ;;
            1) TASK="$MCP_REF 1) MAINTENANCE: Fix TypeScript errors, add unit tests, improve component structure, clean up unused code. 2) NEW FEATURE: Add a new UI component/page (e.g., settings page, room wizard, profile modal). Design, implement, test.

BROWSER VERIFICATION REQUIRED: After changes, you MUST verify the frontend works in a browser:
1. Run 'cd frontend && bun run dev' to start dev server on port 3000
2. Use chrome-devtools_navigate_page --type url --url http://localhost:3000
3. Use chrome-devtools_take_snapshot to verify page renders
4. Use chrome-devtools_list_console_messages to check for errors
5. Use chrome-devtools_list_network_requests to verify API calls work

IMPORTANT: Before starting, create a GitHub issue:
1. Use 'gh issue create --title \"Proactive: [feature area]\" --body \"Task: [description]\" --repo enclavr/frontend'
2. Note the issue number
3. After completing, resolve with 'gh issue close <number> --repo enclavr/frontend' and add resolution comment" ;;
            2) TASK="$MCP_REF 1) MAINTENANCE: Review WebSocket handlers, fix edge cases, add connection error handling, improve logging. 2) NEW FEATURE: Add new WebSocket event (typing indicators, online users, room notifications). Design, implement, test.

IMPORTANT: Before starting, create a GitHub issue:
1. Use 'gh issue create --title \"Proactive: [feature area]\" --body \"Task: [description]\" --repo enclavr/server'
2. Note the issue number
3. After completing, resolve with 'gh issue close <number> --repo enclavr/server' and add resolution comment" ;;
            3) TASK="$MCP_REF 1) MAINTENANCE: Review database queries, add indexes, optimize slow queries, clean up migrations. 2) NEW FEATURE: Add new database model (audit logs, preferences, categories, attachments). Design, implement, add migrations.

IMPORTANT: Before starting, create a GitHub issue:
1. Use 'gh issue create --title \"Proactive: [feature area]\" --body \"Task: [description]\" --repo enclavr/server'
2. Note the issue number
3. After completing, resolve with 'gh issue close <number> --repo enclavr/server' and add resolution comment" ;;
            4) TASK="$MCP_REF 1) MAINTENANCE: Fix lint errors, improve test coverage, refactor hooks, add error boundaries. 2) NEW FEATURE: Add new React hook or utility (useMediaQuery, useDebounce, useLocalStorage). Design, implement, test.

BROWSER VERIFICATION REQUIRED: After changes, you MUST verify the frontend works in a browser:
1. Run 'cd frontend && bun run dev' to start dev server on port 3000
2. Use chrome-devtools_navigate_page --type url --url http://localhost:3000
3. Use chrome-devtools_take_snapshot to verify page renders
4. Use chrome-devtools_list_console_messages to check for errors

IMPORTANT: Before starting, create a GitHub issue:
1. Use 'gh issue create --title \"Proactive: [feature area]\" --body \"Task: [description]\" --repo enclavr/frontend'
2. Note the issue number
3. After completing, resolve with 'gh issue close <number> --repo enclavr/frontend' and add resolution comment" ;;
            5) TASK="$MCP_REF 1) MAINTENANCE: Review middleware, add rate limiting, improve error handling, enhance logging. 2) NEW FEATURE: Add new service (caching, notifications, webhooks). Design, implement, test.

IMPORTANT: Before starting, create a GitHub issue:
1. Use 'gh issue create --title \"Proactive: [feature area]\" --body \"Task: [description]\" --repo enclavr/server'
2. Note the issue number
3. After completing, resolve with 'gh issue close <number> --repo enclavr/server' and add resolution comment" ;;
            6) TASK="$MCP_REF 1) MAINTENANCE: Security audit, fix vulnerabilities, update auth flows, improve token handling. 2) NEW FEATURE: Add authentication feature (OAuth, 2FA, password reset). Design, implement, test.

IMPORTANT: Before starting, create a GitHub issue:
1. Use 'gh issue create --title \"Proactive: [feature area]\" --body \"Task: [description]\" --repo enclavr/server'
2. Note the issue number
3. After completing, resolve with 'gh issue close <number> --repo enclavr/server' and add resolution comment" ;;
            7) TASK="$MCP_REF 1) MAINTENANCE: Improve real-time code, handle reconnection, add message validation, clean up. 2) NEW FEATURE: Add real-time feature (read receipts, editing, threading, blocking). Design, implement, test.

IMPORTANT: Before starting, create a GitHub issue:
1. Use 'gh issue create --title \"Proactive: [feature area]\" --body \"Task: [description]\" --repo enclavr/server'
2. Note the issue number
3. After completing, resolve with 'gh issue close <number> --repo enclavr/server' and add resolution comment" ;;
        esac
    elif [ -d "server" ]; then
        TASK="$MCP_REF 1) MAINTENANCE: Code review, bug fixes, test coverage, refactoring, dependency updates. 2) NEW FEATURE: Add new API endpoint, database model, middleware, or service. Design, implement, test, document.

IMPORTANT: Before starting, create a GitHub issue:
1. Use 'gh issue create --title \"Proactive: [feature area]\" --body \"Task: [description]\" --repo enclavr/server'
2. Note the issue number
3. After completing, resolve with 'gh issue close <number> --repo enclavr/server' and add resolution comment"
    elif [ -d "frontend" ]; then
        TASK="$MCP_REF 1) MAINTENANCE: TypeScript fixes, test coverage, component refactoring, lint cleanup. 2) NEW FEATURE: Add new UI component, page, React hook, or utility. Design, implement, test.

BROWSER VERIFICATION REQUIRED: After changes, you MUST verify the frontend works in a browser:
1. Run 'cd frontend && bun run dev' to start dev server on port 3000
2. Use chrome-devtools_navigate_page --type url --url http://localhost:3000
3. Use chrome-devtools_take_snapshot to verify page renders
4. Use chrome-devtools_list_console_messages to check for errors

IMPORTANT: Before starting, create a GitHub issue:
1. Use 'gh issue create --title \"Proactive: [feature area]\" --body \"Task: [description]\" --repo enclavr/frontend'
2. Note the issue number
3. After completing, resolve with 'gh issue close <number> --repo enclavr/frontend' and add resolution comment"
    else
        TASK="$MCP_REF 1) MAINTENANCE: Analyze project, fix issues, improve structure, update docs. 2) NEW FEATURE: Implement a missing feature. Check existing features first, then add something new.

IMPORTANT: Before starting, create a GitHub issue:
1. Use 'gh issue create --title \"Proactive: [description]\" --body \"Task: [description]\" --repo enclavr/enclavr'
2. Note the issue number
3. After completing, resolve with 'gh issue close <number> --repo enclavr/enclavr' and add resolution comment"
    fi

    log_info "Proactive task selected: $TASK"
    run_kilo run "$TASK"

    return $?
}
