# Tech Context - Enclavr

## Technologies Used

### Backend
- **Language**: Go 1.25.7
- **Web Framework**: Gin
- **Database**: PostgreSQL
- **ORM**: GORM
- **Authentication**: JWT + OIDC (optional)
- **Real-time**: WebSocket (gorilla/websocket)
- **Testing**: Go built-in testing with SQLite in-memory

### Frontend
- **Framework**: Next.js 16.1.6 (with Turbopack)
- **Package Manager**: bun (strict - never npm/yarn/pnpm)
- **Language**: TypeScript
- **Styling**: Tailwind CSS v4
- **State Management**: Zustand 5.x
- **React**: React 19
- **Testing**: Vitest (unit) + Playwright (E2E)

### DevOps
- **Containerization**: Docker
- **Orchestration**: Docker Compose
- **Linting**: golangci-lint (Go), ESLint v9 (JS)
- **Testing**: Go testing, Vitest, Playwright

## Development Setup

### Frontend
```bash
cd frontend
bun install
bun run dev
bun run test      # Unit tests
bun run test:e2e # E2E tests
bun run lint
```

### Server
```bash
cd server
go run ./cmd/server
go test -v ./...
golangci-lint run ./...
```

## Technical Constraints
- Must support multiple concurrent voice users
- Low latency audio streaming
- Horizontal scaling capability
- Cross-platform deployment
