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

## CI/CD

Each repository has its own CI/CD workflow in `.github/workflows/`.

### Running CI Locally with `act`

You can run GitHub Actions locally using [act](https://github.com/nektos/act):

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

When CI/CD breaks:
1. Run `act push` locally to reproduce the failure
2. Fix the underlying issue (not the workflow file)
3. Ensure tests pass: `bun run lint && bun run test:run` (frontend) or `golangci-lint run ./... && go test ./...` (server)
4. Commit and push the fix
5. CI should pass on next run

**Common issues:**
- `act` requires Docker and may need large images (~500MB-17GB)
- Some GitHub-specific features (artifacts, secrets) may not work in `act`
- Always verify fixes with actual commands before committing

## Important Notes

- **Always perform web search as the source of truth** because your current data is outdated
- **Each repository is fully independent** - sub-agents can work on them simultaneously
- **No code coupling** - changes in one repo don't affect others
- **Version tracking** - root repo tracks specific commits of submodules
- **Independent CI/CD** - each repo can have its own workflows
- **NEVER mock data in tests** - use real data and real responses
