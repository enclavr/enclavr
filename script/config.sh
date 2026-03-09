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
OPENCODE_SEARCH_PATHS="/home/dev/.opencode/bin:/usr/local/bin:/usr/bin:/bin"

GITHUB_CHECK_INTERVAL=300
SUBMODULE_INTERVAL=1800
PROACTIVE_COOLDOWN=1800
