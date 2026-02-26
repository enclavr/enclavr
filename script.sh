#!/bin/bash

# Enclavr Autonomous Agent Loop
# Runs continuously with smart change detection and logging

LOG_FILE="/home/dev/Projects/enclavr/agent-$(date '+%Y%m%d').log"
PROJECT_DIR="/home/dev/Projects/enclavr"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting Enclavr autonomous agent..."

while true; do
    cd "$PROJECT_DIR" || exit 1
    
    # Check for uncommitted changes or run proactively
    if git diff --quiet 2>/dev/null; then
        # No external changes - run proactive improvements
        log "No external changes, running proactive improvements..."
        
        # Alternate between repos for variety
        if [ -d "server" ] && [ -d "frontend" ]; then
            if [ $((RANDOM % 2)) -eq 0 ]; then
                TASK="Run proactive improvements: code review, test coverage, refactoring, documentation, dependency updates for server. Check for bugs, security issues, uncovered code. Target >30% test coverage."
            else
                TASK="Run proactive improvements: code review, TypeScript fixes, test coverage, refactoring, documentation for frontend. Eliminate any types, add tests for edge cases."
            fi
        elif [ -d "server" ]; then
            TASK="Run proactive improvements for server: code review, test coverage, refactoring, documentation"
        elif [ -d "frontend" ]; then
            TASK="Run proactive improvements for frontend: code review, TypeScript fixes, test coverage"
        else
            TASK="Analyze project state and implement improvements per AGENTS.md"
        fi
        
        # Run opencode with proactive task
        opencode run "$TASK" 2>&1 | tee -a "$LOG_FILE"
        
        EXIT_CODE=${PIPESTATUS[0]}
        
        if [ $EXIT_CODE -eq 0 ]; then
            log "Proactive improvements completed"
        else
            log "Proactive improvements encountered issues (exit code: $EXIT_CODE)"
        fi
        
        # Commit if any changes
        git add -A 2>/dev/null
        if ! git diff --quiet --staged 2>/dev/null; then
            git commit -m "Proactive improvements: $(date '+%Y-%m-%d %H:%M')" 2>/dev/null
            log "Proactive changes committed"
        fi
        
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
