# Tech Context - Enclavr

## Technologies Used

### Backend
- **Language**: Go 1.25 (August 2025)
- **Web Framework**: Go net/http with gorilla/mux
- **Database**: PostgreSQL 18 (September 2025)
- **ORM**: GORM
- **Migrations**: golang-migrate
- **Authentication**: JWT + bcrypt + OIDC
- **Real-time**: WebSocket (gorilla/websocket) with Redis pub/sub
- **Testing**: Go built-in testing with SQLite in-memory

### Frontend
- **Framework**: Next.js 16.1.6 (App Router, Turbopack default)
- **Package Manager**: bun (strict - never npm/yarn/pnpm)
- **Language**: TypeScript 5.9.x (strict mode)
- **Styling**: Tailwind CSS 4.x
- **State Management**: Zustand 5.0.11
- **React**: 19.2.x (with CVE-2025-55182 security patches)
- **Testing**: Vitest (unit) + Playwright (E2E)

### Infrastructure
- **Container Runtime**: Docker
- **Orchestration**: Docker Compose v2
- **Database**: PostgreSQL 18 (Alpine) with PGDATA=/var/lib/postgresql/18/docker
- **Cache/PubSub**: Redis 8 (Alpine)
- **Voice**: Coturn (TURN server for WebRTC)
- **CI/CD**: GitHub Actions

### DevOps
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
