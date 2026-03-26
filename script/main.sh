#!/bin/bash

# Enclavr Autonomous Agent Loop

# Sub-repository flags
FRONTEND_CHANGED=false
SERVER_CHANGED=false
INFRA_CHANGED=false
DOCS_CHANGED=false

# Current active repo index (0=frontend, 1=server, 2=infra, 3=docs)
CURRENT_REPO_INDEX=0

# Task type flags
ADD_NEW_FEATURES=false
TESTING_ONLY=false
DEBUGGING_ONLY=false

# Task type indices for each repo (0=add features, 1=testing, 2=debugging)
FRONTEND_TASK_INDEX=0
SERVER_TASK_INDEX=0
INFRA_TASK_INDEX=0
DOCS_TASK_INDEX=0

# ============================================
# AI Prompt Templates
# ============================================

# Frontend - Add New Features
PROMPT_FRONTEND_FEATURES="You are working on the Enclavr frontend repository.
The project is a Next.js 16 + React 19 + TypeScript voice chat platform with Tailwind CSS 4.

CONTEXT:
- Tech Stack: Next.js 16.1.6, React 19.2.x, TypeScript 5.9.x, Tailwind CSS 4, Zustand 5.0.11, Bun
- Location: /home/dev/Projects/enclavr/frontend
- Design System: Apple Liquid Glass aesthetic (frosted glass, blur effects, translucency)
- Memory bank at: frontend/memory-bank/

YOUR TASK: Add NEW features to the frontend.

REQUIREMENTS:
1. Check frontend/memory-bank/activeContext.md and progress.md to understand current state
2. Check AGENTS.md in the frontend repo for coding standards and patterns
3. Implement a new feature - consider:
   - New UI components in src/components/ui/
   - New pages in src/app/
   - New React hooks in src/hooks/
   - New utilities in src/lib/
   - New types in src/types/
4. Follow the Apple Liquid Glass design system
5. Use bun for package management
6. Test your changes with: bun run test:run && bun run lint && bun run typecheck
7. For any frontend work, MUST use Chrome DevTools MCP to verify:
   - chrome-devtools_navigate_page to test the app
   - chrome-devtools_take_snapshot to verify rendering
   - chrome-devtools_list_console_messages to check for errors
8. Commit and push your changes

IMPORTANT: First analyze the codebase to find gaps or missing features. Build something useful that fits the voice chat platform."

# Frontend - Testing Only
PROMPT_FRONTEND_TESTING="You are working on the Enclavr frontend repository.
The project is a Next.js 16 + React 19 + TypeScript voice chat platform with Tailwind CSS 4.

CONTEXT:
- Tech Stack: Next.js 16.1.6, React 19.2.x, TypeScript 5.9.x, Tailwind CSS 4, Zustand 5.0.11, Bun
- Location: /home/dev/Projects/enclavr/frontend
- Design System: Apple Liquid Glass aesthetic
- Memory bank at: frontend/memory-bank/

YOUR TASK: Testing ONLY - find issues and create GitHub issues. DO NOT fix anything yourself.

REQUIREMENTS:
1. Check frontend/memory-bank/activeContext.md and progress.md to understand current state
2. Run existing tests: bun run test:run
3. Run linting: bun run lint
4. Run type checking: bun run typecheck
5. Analyze any test failures or lint errors
6. Check for console errors using Chrome DevTools MCP:
   - chrome-devtools_navigate_page --type url --url http://localhost:3000
   - chrome-devtools_list_console_messages
7. Look for potential bugs in the codebase:
   - Check src/components/ for issues
   - Check src/hooks/ for edge cases
   - Check src/lib/ for errors
8. For EACH issue found, create a GitHub issue with:
   - Clear title describing the bug
   - Detailed description with steps to reproduce
   - Expected vs actual behavior
   - Relevant code snippets and file paths
9. DO NOT attempt to fix any issues - only document them

IMPORTANT: Run all tests and checks, then create GitHub issues for everything you find. Never modify code to fix bugs."

# Frontend - Debugging (Fix GitHub Issues)
PROMPT_FRONTEND_DEBUGGING="You are working on the Enclavr frontend repository.
The project is a Next.js 16 + React 19 + TypeScript voice chat platform with Tailwind CSS 4.

CONTEXT:
- Tech Stack: Next.js 16.1.6, React 19.2.x, TypeScript 5.9.x, Tailwind CSS 4, Zustand 5.0.11, Bun
- Location: /home/dev/Projects/enclavr/frontend
- Design System: Apple Liquid Glass aesthetic
- Memory bank at: frontend/memory-bank/

YOUR TASK: Debugging - go through GitHub issues and FIX them. Do NOT create new issues.

REQUIREMENTS:
1. Check frontend/memory-bank/activeContext.md and progress.md to understand current state
2. List open GitHub issues in the frontend repository: gh issue list -R enclavr/frontend
3. For each open issue:
   - Read the issue details and understand what needs to be fixed
   - Analyze the code to find the root cause
   - Implement a fix for the issue
4. Run tests to verify your fixes: bun run test:run && bun run lint && bun run typecheck
5. Use Chrome DevTools MCP to verify frontend changes work correctly
6. Close each issue after fixing with a comment explaining the fix
7. Commit and push your changes

IMPORTANT: Focus on fixing existing GitHub issues. Do not create new issues. If an issue is unclear, ask for clarification in a comment."

# Server - Add New Features
PROMPT_SERVER_FEATURES="You are working on the Enclavr server repository.
The project is a Go backend with PostgreSQL and WebSocket for real-time voice chat.

CONTEXT:
- Tech Stack: Go 1.25, GORM, PostgreSQL (Neon), gorilla/websocket, Redis pub/sub
- Location: /home/dev/Projects/enclavr/server
- Auth: JWT, bcrypt, OIDC, WebAuthn
- Memory bank at: server/memory-bank/

YOUR TASK: Add NEW features to the server.

REQUIREMENTS:
1. Check server/memory-bank/activeContext.md and progress.md to understand current state
2. Check AGENTS.md in the server repo for coding standards
3. Implement a new feature - consider:
   - New API endpoints in internal/handlers/
   - New database models in internal/models/
   - New services in internal/services/
   - New WebSocket handlers in internal/websocket/
   - New middleware in pkg/middleware/
4. Follow Go best practices: go fmt, golangci-lint, tests
5. Run tests: go test -v ./...
6. Ensure backward compatibility with existing APIs
7. Use proper error handling and logging
8. Commit and push your changes

IMPORTANT: First analyze the codebase to find gaps or missing features. Build something useful for the voice chat backend."

# Server - Testing Only
PROMPT_SERVER_TESTING="You are working on the Enclavr server repository.
The project is a Go backend with PostgreSQL and WebSocket for real-time voice chat.

CONTEXT:
- Tech Stack: Go 1.25, GORM, PostgreSQL (Neon), gorilla/websocket, Redis pub/sub
- Location: /home/dev/Projects/enclavr/server
- Auth: JWT, bcrypt, OIDC, WebAuthn
- Memory bank at: server/memory-bank/

YOUR TASK: Testing ONLY - find issues and create GitHub issues. DO NOT fix anything yourself.

REQUIREMENTS:
1. Check server/memory-bank/activeContext.md and progress.md to understand current state
2. Run tests: go test -v ./...
3. Run linting: golangci-lint run ./...
4. Check go vet for issues
5. Analyze any test failures
6. Look for potential bugs:
   - Check internal/handlers/ for edge cases
   - Check internal/websocket/ for race conditions
   - Check internal/services/ for error handling
   - Check internal/models/ for validation
7. Check database migrations in migrations/
8. For EACH issue found, create a GitHub issue with:
   - Clear title describing the bug
   - Detailed description with steps to reproduce
   - Expected vs actual behavior
   - Relevant code snippets and file paths
9. DO NOT attempt to fix any issues - only document them

IMPORTANT: Run all tests and checks, then create GitHub issues for everything you find. Never modify code to fix bugs."

# Server - Debugging (Fix GitHub Issues)
PROMPT_SERVER_DEBUGGING="You are working on the Enclavr server repository.
The project is a Go backend with PostgreSQL and WebSocket for real-time voice chat.

CONTEXT:
- Tech Stack: Go 1.25, GORM, PostgreSQL (Neon), gorilla/websocket, Redis pub/sub
- Location: /home/dev/Projects/enclavr/server
- Auth: JWT, bcrypt, OIDC, WebAuthn
- Memory bank at: server/memory-bank/

YOUR TASK: Debugging - go through GitHub issues and FIX them. Do NOT create new issues.

REQUIREMENTS:
1. Check server/memory-bank/activeContext.md and progress.md to understand current state
2. List open GitHub issues in the server repository: gh issue list -R enclavr/server
3. For each open issue:
   - Read the issue details and understand what needs to be fixed
   - Analyze the code to find the root cause
   - Implement a fix for the issue
4. Run tests to verify your fixes: go test -v ./... && golangci-lint run ./...
5. Close each issue after fixing with a comment explaining the fix
6. Commit and push your changes

IMPORTANT: Focus on fixing existing GitHub issues. Do not create new issues. If an issue is unclear, ask for clarification in a comment."

# Infra - Add New Features
PROMPT_INFRA_FEATURES="You are working on the Enclavr infrastructure repository.
The project uses Docker Compose for deployment.

CONTEXT:
- Location: /home/dev/Projects/enclavr/infra
- Docker Compose for PostgreSQL, Redis, server, frontend
- Environment configuration via .env

YOUR TASK: Add NEW infrastructure features.

REQUIREMENTS:
1. Analyze current Docker Compose setup
2. Consider adding:
   - New services (monitoring, logging, caching)
   - Better health checks
   - Improved networking
   - Volume management
   - Security hardening
3. Check .env.example for configuration options
4. Test with: docker compose config
5. Ensure services can start properly
6. Commit and push your changes"

# Infra - Testing Only
PROMPT_INFRA_TESTING="You are working on the Enclavr infrastructure repository.
The project uses Docker Compose for deployment.

CONTEXT:
- Location: /home/dev/Projects/enclavr/infra
- Docker Compose for PostgreSQL, Redis, server, frontend

YOUR TASK: Testing ONLY - find issues and create GitHub issues. DO NOT fix anything yourself.

REQUIREMENTS:
1. Validate Docker Compose: docker compose config
2. Check for issues in docker-compose.yml
3. Test service health checks
4. Verify environment variables in .env.example
5. Check networking between services
6. Look for security issues in Docker configuration
7. For EACH issue found, create a GitHub issue with:
   - Clear title describing the issue
   - Detailed description with steps to reproduce
   - Expected vs actual behavior
8. DO NOT attempt to fix any issues - only document them

IMPORTANT: Run all checks, then create GitHub issues for everything you find. Never modify Docker configuration to fix issues."

# Infra - Debugging (Fix GitHub Issues)
PROMPT_INFRA_DEBUGGING="You are working on the Enclavr infrastructure repository.
The project uses Docker Compose for deployment.

CONTEXT:
- Location: /home/dev/Projects/enclavr/infra
- Docker Compose for PostgreSQL, Redis, server, frontend

YOUR TASK: Debugging - go through GitHub issues and FIX them. Do NOT create new issues.

REQUIREMENTS:
1. List open GitHub issues in the infra repository: gh issue list -R enclavr/infra
2. For each open issue:
   - Read the issue details and understand what needs to be fixed
   - Analyze the Docker configuration to find the root cause
   - Implement a fix for the issue
3. Test with: docker compose config
4. Ensure services can start properly
5. Close each issue after fixing with a comment explaining the fix
6. Commit and push your changes

IMPORTANT: Focus on fixing existing GitHub issues. Do not create new issues. If an issue is unclear, ask for clarification in a comment."

# Docs - Add New Features
PROMPT_DOCS_FEATURES="You are working on the Enclavr documentation repository.
This docs repository MUST reflect 100% of the features from the other repositories.

CONTEXT:
- Location: /home/dev/Projects/enclavr/docs
- Static HTML documentation generated from codebase
- Docs must stay in sync with: frontend, server, infra repositories

YOUR TASK: Update documentation to reflect all features from other repositories.

REQUIREMENTS:
1. Check the other repositories to understand what features exist:
   - Frontend: /home/dev/Projects/enclavr/frontend (Next.js, React, components, hooks)
   - Server: /home/dev/Projects/enclavr/server (Go, API endpoints, WebSocket, auth)
   - Infra: /home/dev/Projects/enclavr/infra (Docker, deployment)
2. For each feature in the other repos, ensure documentation exists:
   - API documentation (all endpoints)
   - Component documentation (UI components)
   - Setup guides (installation, configuration)
   - Usage examples
   - Architecture docs
3. Check docs/memory-bank/activeContext.md for current state
4. Run playwright tests to verify docs render: npx playwright test
5. Look at GitHub issues for what needs to be documented
6. Update existing docs to match current code
7. Commit and push your changes

IMPORTANT: The docs MUST be 100% in sync with actual features. If code has a feature, docs must document it."

# Docs - Testing Only
PROMPT_DOCS_TESTING="You are working on the Enclavr documentation repository.
This docs repository MUST reflect 100% of the features from the other repositories.

CONTEXT:
- Location: /home/dev/Projects/enclavr/docs
- Static HTML documentation
- Docs must stay in sync with: frontend, server, infra repositories

YOUR TASK: Testing ONLY - verify docs match reality and create GitHub issues for gaps. DO NOT fix anything yourself.

REQUIREMENTS:
1. Check each feature in the other repos against the docs:
   - Frontend: /home/dev/Projects/enclavr/frontend (check src/components, src/hooks, src/lib)
   - Server: /home/dev/Projects/enclavr/server (check internal/handlers, internal/services)
   - Infra: /home/dev/Projects/enclavr/infra (check docker-compose.yml)
2. For EACH feature missing documentation, create a GitHub issue:
   - Title: Missing docs: [feature name]
   - Body: List the feature that exists in code but is not documented
   - Include file paths where the feature is implemented
3. Check for broken links: npx playwright test or manual check
4. Check for typos, grammar issues
5. Verify code examples in docs match actual code
6. Check docs/memory-bank/activeContext.md for current state

IMPORTANT: Find gaps between code and docs. Create issues for EVERYTHING missing. DO NOT fix anything."

# Docs - Debugging (Fix GitHub Issues)
PROMPT_DOCS_DEBUGGING="You are working on the Enclavr documentation repository.
This docs repository MUST reflect 100% of the features from the other repositories.

CONTEXT:
- Location: /home/dev/Projects/enclavr/docs
- Static HTML documentation
- Docs must stay in sync with: frontend, server, infra repositories

YOUR TASK: Debugging - go through GitHub issues and FIX them. Do NOT create new issues.

REQUIREMENTS:
1. List open GitHub issues in the docs repository: gh issue list -R enclavr/docs
2. For each issue:
   - Read the issue details
   - If it is about missing docs: check the other repos and add the documentation
   - If it is about broken links/typos: fix them directly
   - If it is about code examples: verify against actual code and fix
3. Verify fixes by running: npx playwright test
4. Run tests to ensure docs still render correctly
5. Close each issue after fixing with a comment
6. Commit and push your changes

IMPORTANT: Fix existing issues. The goal is 100% docs coverage of all features from other repos."

# ============================================
# Main Loop
# ============================================

while true; do
    echo "Loop running..."
    
    # Reset all flags
    FRONTEND_CHANGED=false
    SERVER_CHANGED=false
    INFRA_CHANGED=false
    DOCS_CHANGED=false
    ADD_NEW_FEATURES=false
    TESTING_ONLY=false
    DEBUGGING_ONLY=false
    
    # Set the current repo flag based on index
    case $CURRENT_REPO_INDEX in
        0) FRONTEND_CHANGED=true ;;
        1) SERVER_CHANGED=true ;;
        2) INFRA_CHANGED=true ;;
        3) DOCS_CHANGED=true ;;
    esac
    
    # Get the task index for the current repo and set task type flag
    case $CURRENT_REPO_INDEX in
        0)
            case $FRONTEND_TASK_INDEX in
                0) ADD_NEW_FEATURES=true ;;
                1) TESTING_ONLY=true ;;
                2) DEBUGGING_ONLY=true ;;
            esac
            ;;
        1)
            case $SERVER_TASK_INDEX in
                0) ADD_NEW_FEATURES=true ;;
                1) TESTING_ONLY=true ;;
                2) DEBUGGING_ONLY=true ;;
            esac
            ;;
        2)
            case $INFRA_TASK_INDEX in
                0) ADD_NEW_FEATURES=true ;;
                1) TESTING_ONLY=true ;;
                2) DEBUGGING_ONLY=true ;;
            esac
            ;;
        3)
            case $DOCS_TASK_INDEX in
                0) ADD_NEW_FEATURES=true ;;
                1) TESTING_ONLY=true ;;
                2) DEBUGGING_ONLY=true ;;
            esac
            ;;
    esac
    
    # Build the AI prompt based on current flags
    if [ "$FRONTEND_CHANGED" = true ]; then
        if [ "$ADD_NEW_FEATURES" = true ]; then
            AI_PROMPT="$PROMPT_FRONTEND_FEATURES"
        elif [ "$TESTING_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_FRONTEND_TESTING"
        else
            AI_PROMPT="$PROMPT_FRONTEND_DEBUGGING"
        fi
    elif [ "$SERVER_CHANGED" = true ]; then
        if [ "$ADD_NEW_FEATURES" = true ]; then
            AI_PROMPT="$PROMPT_SERVER_FEATURES"
        elif [ "$TESTING_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_SERVER_TESTING"
        else
            AI_PROMPT="$PROMPT_SERVER_DEBUGGING"
        fi
    elif [ "$INFRA_CHANGED" = true ]; then
        if [ "$ADD_NEW_FEATURES" = true ]; then
            AI_PROMPT="$PROMPT_INFRA_FEATURES"
        elif [ "$TESTING_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_INFRA_TESTING"
        else
            AI_PROMPT="$PROMPT_INFRA_DEBUGGING"
        fi
    elif [ "$DOCS_CHANGED" = true ]; then
        if [ "$ADD_NEW_FEATURES" = true ]; then
            AI_PROMPT="$PROMPT_DOCS_FEATURES"
        elif [ "$TESTING_ONLY" = true ]; then
            AI_PROMPT="$PROMPT_DOCS_TESTING"
        else
            AI_PROMPT="$PROMPT_DOCS_DEBUGGING"
        fi
    fi
    
    echo "Active repo: $CURRENT_REPO_INDEX (frontend=$FRONTEND_CHANGED, server=$SERVER_CHANGED, infra=$INFRA_CHANGED, docs=$DOCS_CHANGED)"
    echo "Task type: (add_features=$ADD_NEW_FEATURES, testing=$TESTING_ONLY, debugging=$DEBUGGING_ONLY)"
    echo "AI Prompt length: ${#AI_PROMPT} chars"
    
    # Run the AI agent with the prompt
    kilo run "$AI_PROMPT"
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -eq 0 ]; then
        echo "AI agent completed successfully"
    else
        echo "AI agent FAILED with exit code $EXIT_CODE"
    fi
    
    # Alternate to next repo for next iteration
    CURRENT_REPO_INDEX=$(( (CURRENT_REPO_INDEX + 1) % 4 ))
    
    # Alternate task type for the CURRENT repo (for next time we visit it)
    # Now cycles through 3 states: 0=features, 1=testing, 2=debugging
    case $CURRENT_REPO_INDEX in
        0) FRONTEND_TASK_INDEX=$(( (FRONTEND_TASK_INDEX + 1) % 3 )) ;;
        1) SERVER_TASK_INDEX=$(( (SERVER_TASK_INDEX + 1) % 3 )) ;;
        2) INFRA_TASK_INDEX=$(( (INFRA_TASK_INDEX + 1) % 3 )) ;;
        3) DOCS_TASK_INDEX=$(( (DOCS_TASK_INDEX + 1) % 3 )) ;;
    esac
    
    sleep 60
done