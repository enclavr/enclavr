---
name: enclavr-root
description: Root monorepo for Enclavr - a self-hosted voice chat platform
---

# Enclavr - Agent Instructions

You are an expert software architect and developer working on the Enclavr monorepo. Enclavr is a self-hosted voice chat platform (like Discord/Teamspeak).

## Project Structure

This monorepo uses git submodules. Each component is an independent repository:

| Repository | Description | Agent Focus |
|------------|-------------|-------------|
| [enclavr/frontend](https://github.com/enclavr/frontend) | Next.js 16 + React 19 + TypeScript | UI/UX, State |
| [enclavr/server](https://github.com/enclavr/server) | Go backend with PostgreSQL, WebSocket | API, DB, Auth |
| [enclavr/infra](https://github.com/enclavr/infra) | Docker Compose deployment | DevOps |

## Commands

### Working with Submodules
```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/enclavr/enclavr.git

# Update all submodules
git submodule update --remote

# Pull specific submodule
cd frontend && git pull origin main
```

### Frontend
```bash
cd frontend
bun install
bun run dev
bun run lint && bun run test:run
```

### Server
```bash
cd server
go run ./cmd/server
golangci-lint run ./... && go test -v ./...
```

### Infrastructure
```bash
cd infra
cp .env.example .env
docker-compose up -d
```

## CI/CD

Each repository has its own CI/CD workflow in `.github/workflows/`.

### Running CI Locally with `act`
```bash
# Install act (requires Docker)
curl -Ls https://raw.githubusercontent.com/nektos/act/master/install.sh | sh

# Run all CI jobs
act push

# Run specific job
act -j test

# Dry run (preview)
act --dryrun push
```

### Fixing CI/CD
When CI breaks:
1. Run `act push` locally to reproduce the failure
2. Fix the underlying issue (not the workflow file)
3. Ensure tests pass
4. Commit and push

## Standards

- **Always perform web search as the source of truth** because your current data is outdated
- **Keep everything up-to-date** unless there are security concerns or compatibility issues
- Each repository is fully independent - sub-agents can work on them simultaneously
- No code coupling between repositories
- Root repo tracks specific commits of submodules
- NEVER mock data in tests - use real data and real responses

## Boundaries

- ✅ **Always:** Work within correct submodule directories, respect repository independence
- ⚠️ **Ask first:** Before updating submodule references or modifying root-level config
- 🚫 **Never:** Commit secrets or API keys to any repository
