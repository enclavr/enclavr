# System Patterns - enclavr-root

## Patterns Used
- Trunk-based development for AI agents
- Daily release tags (vYYYY.MM.DD format)
- Autonomous agent loop via script/main.sh
- Shared state via /tmp/enclavr-shared-state

## Conventions
- Use gh CLI for all GitHub operations
- Use MCP tools for Neon, Sentry, Chrome DevTools
- Auto-commit and push all changes
- Update memory bank at start of each session
