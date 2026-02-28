# Enclavr - Agent Instructions

## Project Overview

Enclavr is a self-hosted voice chat platform (like Discord/Teamspeak) with a **modular repository structure**. Each component is an independent repository that can be worked on by separate sub-agents.

## Repository Structure

| Repository | Description | Agent Focus |
|------------|-------------|-------------|
| [enclavr/frontend](https://github.com/enclavr/frontend) | Next.js 16 + React 19 + TypeScript | UI/UX, State |
| [enclavr/server](https://github.com/enclavr/server) | Go backend with PostgreSQL, WebSocket | API, DB, Auth |
| [enclavr/infra](https://github.com/enclavr/infra) | Docker Compose deployment | DevOps |

## Working with Submodules

This root repository uses **git submodules**. Each submodule is an independent git repository.

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/enclavr/enclavr.git

# Update all submodules
git submodule update --remote

# Pull specific submodule
cd frontend && git pull origin main
```

## Development Commands

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

## Important Notes

- **Each repository is fully independent** - sub-agents can work on them simultaneously
- **No code coupling** - changes in one repo don't affect others
- **Version tracking** - root repo tracks specific commits of submodules
- **Independent CI/CD** - each repo can have its own workflows
- ** NEVER mock data in tests** - use real data and real responses
