#!/bin/bash

# Branch and tag management

manage_branches_via_kilo() {
    log "Managing branches and tags via Kilo..."

    local task="IMPORTANT: Before starting, read the memory bank files to understand current state. After completing work, update the memory bank with what was done. Use sub-agents to manage branches/tags in ALL 5 repositories in PARALLEL. Spawn sub-agents for enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra, enclavr/docs. For each repository:
1. Check for branches using 'git branch -a' or GitHub API
2. Identify stale branches (branches not merged to main for 7+ days, or branches with no recent commits)
3. Delete any stale branches using 'git push origin --delete <branch>' or GitHub API
4. Check if today's release tag (format: vYYYY.MM.DD) exists in each repo
5. If no tag exists today, create one pointing to the latest main commit using 'git tag -a vYYYY.MM.DD -m \"Release vYYYY-MM-DD\"' and 'git push origin vYYYY.MM.DD'

Use sub-agents to process multiple repositories concurrently. Report which branches were deleted and which tags were created in each repository."

    run_kilo run "$task"
    return $?
}

manage_branches() {
    log "Managing branches and tags..."
    manage_branches_via_kilo
}
