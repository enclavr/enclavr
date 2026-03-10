#!/bin/bash

# Memory bank functions

read_memory_bank() {
    if [ -f "$PROJECT_DIR/memory-bank/activeContext.md" ]; then
        log_info "Loaded root memory bank"
    fi

    local submodules_count=0
    for submodule in frontend server infra docs; do
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

    run_kilo run "$task"
    return $?
}

update_memory_bank() {
    local repo="$1"
    local change_summary="$2"

    log "Updating memory bank for $repo..."
    update_memory_bank_via_kilo "$repo" "$change_summary"
}

update_all_memory_banks() {
    local change_summary="$1"
    
    if [ -d "server" ]; then
        update_memory_bank "server" "$change_summary"
    fi
    if [ -d "frontend" ]; then
        update_memory_bank "frontend" "$change_summary"
    fi
    if [ -d "infra" ]; then
        update_memory_bank "infra" "$change_summary"
    fi
    if [ -d "docs" ]; then
        update_memory_bank "docs" "$change_summary"
    fi
    update_memory_bank "root" "$change_summary"
}
