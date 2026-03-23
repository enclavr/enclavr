#!/bin/bash

# Configuration for Enclavr Autonomous Agent

LOG_FILE="/home/dev/Projects/enclavr/agent-$(date '+%Y%m%d').log"
PROJECT_DIR="/home/dev/Projects/enclavr"
REPOS="enclavr/enclavr enclavr/frontend enclavr/server enclavr/infra enclavr/docs"

AGENT_LOG_LEVEL="WARN"
AGENT_PRINT_LOGS="false"
AGENT_SHOW_THINKING="false"
AGENT_FORMAT="default"

AGENT_SESSION_ID="enclavr-autonomous-$(hostname)-$(date '+%Y%m%d')"
AGENT_TYPE=""
AGENT_TIMEOUT=600

CURRENT_PROVIDER="kilo"
PROVIDER_COOLDOWN_FILE="$PROJECT_DIR/.provider_cooldown"

SHARED_STATE_FILE="/tmp/enclavr-shared-state"
PROACTIVE_COOLDOWN_FILE="/tmp/enclavr-proactive-cooldown"

KILO_SEARCH_PATHS="/home/dev/.kilo/bin:/usr/local/bin:/usr/bin:/bin"

GITHUB_CHECK_INTERVAL=300
CLOSED_ISSUES_INTERVAL=3600  # Check closed issues every hour for regressions
SUBMODULE_INTERVAL=1800
PROACTIVE_COOLDOWN=1800

# === TOKEN OPTIMIZATION ===

# Shared prompt prefix - sent once at session start
# This replaces repeated preambles in each task (~300 tokens saved per task)
PROMPT_PREFIX="Read memory-bank/*.md for context. Update memory-bank/activeContext.md after completion."

# Compact task templates - use placeholders instead of full instructions
TASK_TEMPLATE_ANALYZE="Analyze {repo} repo. Check {checks}. Report findings."
TASK_TEMPLATE_FIX="Debug and fix issues in {repo}. Run tests after fixes."
TASK_TEMPLATE_IMPROVE="Proactive improvements: {area}. Update memory-bank/progress.md when done."

# Cache memory bank content once per session
MEMORY_BANK_CACHE=""
cache_memory_bank() {
    if [ -d "$PROJECT_DIR/memory-bank" ]; then
        MEMORY_BANK_CACHE=$(cat "$PROJECT_DIR/memory-bank"/*.md 2>/dev/null | head -100)
    fi
}

# Get cached context or fallback to minimal
get_optimized_context() {
    if [ -n "$MEMORY_BANK_CACHE" ]; then
        echo "$MEMORY_BANK_CACHE"
    else
        cache_memory_bank
        echo "$MEMORY_BANK_CACHE"
    fi
}
