#!/bin/bash

# Enclavr Autonomous Agent Loop
# Runs continuously with smart change detection and logging

LOG_FILE="/home/dev/Projects/enclavr/agent.log"
PROJECT_DIR="/home/dev/Projects/enclavr"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting Enclavr autonomous agent..."

while true; do
    cd "$PROJECT_DIR" || exit 1
    
    # Check for uncommitted changes
    if git diff --quiet 2>/dev/null; then
        # No changes, wait longer
        sleep 60
        continue
    fi
    
    # Changes detected - run agent
    log "Changes detected, running agent..."
    
    # Save current state
    git add -A 2>/dev/null
    
    # Run opencode with specific task based on what changed
    CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null | head -5)
    
    if echo "$CHANGED_FILES" | grep -q "server/"; then
        TASK="Analyze server changes and run tests, lint, then implement improvements"
    elif echo "$CHANGED_FILES" | grep -q "frontend/"; then
        TASK="Analyze frontend changes and run tests, lint, then implement improvements"
    else
        TASK="Analyze project state and implement improvements per AGENTS.md"
    fi
    
    # Run the agent (non-interactive)
    opencode run "$TASK" 2>&1 | tee -a "$LOG_FILE"
    
    EXIT_CODE=${PIPESTATUS[0]}
    
    if [ $EXIT_CODE -eq 0 ]; then
        log "Agent completed successfully"
    else
        log "Agent encountered issues (exit code: $EXIT_CODE)"
    fi
    
    # Commit changes if any
    if ! git diff --quiet --staged 2>/dev/null; then
        git commit -m "Autonomous agent: $(date '+%Y-%m-%d %H:%M')" 2>/dev/null
        log "Changes committed"
    fi
    
    # Wait before next cycle
    sleep 30
done
