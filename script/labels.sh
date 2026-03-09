#!/bin/bash

# GitHub labels management

manage_labels_via_kilo() {
    log "Managing GitHub labels via Kilo..."

    local task="IMPORTANT: Before starting, read the memory bank files to understand current state. After completing work, update the memory bank with what was done. Use sub-agents to create labels in ALL 5 repositories in PARALLEL. Ensure the following labels exist in all enclavr repositories (enclavr/enclavr, enclavr/frontend, enclavr/server, enclavr/infra, enclavr/docs):
- bug:Issue bug (color: ee0701)
- feature:Issue feature (color: 008672)
- enhancement:Issue enhancement (color: 84b6eb)
- documentation:Issue documentation (color: d4c5f9)
- security:Issue security (color: ee0701)

Use 'gh label create' to create any missing labels. Report which labels were created."

    run_kilo run --continue "$task"
    return $?
}

manage_labels() {
    log "Ensuring common labels exist via Kilo..."
    manage_labels_via_kilo
}
