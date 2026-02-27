# Enclavr - Agent Instructions

## Project Overview

Enclavr is a self-hosted voice chat platform (like Discord/Teamspeak) with:
- **Server**: Go backend with PostgreSQL, WebSocket hub, WebRTC signaling
- **Frontend**: Next.js 16 + React 19 + TypeScript + Zustand + Tailwind CSS v4

## Build Commands

### Frontend
```bash
cd frontend
bun install
bun run dev
bun run build
bun run lint
bun run test:run
bun run test:e2e
```

### Server
```bash
cd server
go run ./cmd/server
go test -v ./...
golangci-lint run ./...
go build -o bin/server ./cmd/server
```

### Docker
```bash
docker-compose up -d
```

## Code Style

### TypeScript / React
- Explicit types for all function parameters and return types
- Never use `any` - use `unknown` if needed
- Use `interface` for objects, `type` for unions
- Functional components with hooks
- Use `useCallback`, `useMemo`, `React.memo` for performance
- Zustand for state management

### Go
- Use `go fmt` before committing
- Use `golangci-lint` to catch issues
- Keep functions under 50 lines
- Use meaningful variable names
- Group imports: stdlib → external → internal

### General
- **NEVER mock data in tests** - use real data and real responses
- Keep files under 300 lines (frontend) / 500 lines (server)
- Use barrel files (`index.ts` / `index.go`) for clean imports

## Testing Requirements

- All tests must pass before committing
- Run frontend: `bun run lint && bun run test:run`
- Run server: `golangci-lint run ./... && go test -v ./...`
- Test with real data, never mock database or external services

## Project Structure

```
/home/dev/Projects/enclavr/
├── frontend/          # Next.js frontend (use bun, NOT npm)
├── server/           # Go backend
├── docker-compose.yml # Full stack deployment
└── .github/workflows/ # CI/CD pipelines
```

## Environment

- Bun is required for frontend (NEVER use npm/yarn/pnpm)
- Go 1.25.7 for backend
- PostgreSQL database
- Redis for pub/sub (optional, for scaling)

## Important Notes

- This is a monorepo with two independent projects
- Frontend and server can run independently for development
- Both are pushed to separate GitHub repositories:
  - `enclavr/server` - Go backend
  - `enclavr/frontend` - Next.js frontend
