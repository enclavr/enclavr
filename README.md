# Enclavr

A self-hosted open source voice chat platform, similar to Discord or Teamspeak, written in Go.

> **Note**: This entire project is written and managed entirely by agentic AI.

## Overview

Enclavr is a backend-focused project that provides the core infrastructure for real-time voice communication. It is frontend-agnostic, meaning it can be integrated into any kind of frontend - web, desktop, or mobile applications.

A default Next.js frontend is also provided for users who want a ready-to-use interface.

## Features

- Real-time voice communication
- Self-hosted solution
- Written in Go for performance and simplicity
- Frontend-agnostic API design
- Built-in authentication with optional OIDC support
- Single server with multiple rooms support
- Containerized deployment support
- Database-driven for heavy workloads
- Default Next.js frontend for ready-to-use interface
- Open source

## Architecture

Enclavr provides the backend services needed for voice chat functionality. It exposes APIs and protocols that any frontend can consume to build custom user interfaces.

## Project Structure

```
/home/dev/Projects/enclavr/
├── frontend/           # Next.js frontend (bun package manager)
├── server/             # Go backend server
├── docker-compose.yml  # Docker orchestration
└── memory-bank/        # Project documentation
```

## Quick Start

### Frontend

```bash
cd frontend
bun install
bun run dev
```

### Server

```bash
cd server
go run ./cmd/server
```

### Docker Compose

```bash
docker-compose up -d
```

## CLI Commands

### Frontend (using bun)

| Command | Description |
|---------|-------------|
| `bun install` | Install dependencies |
| `bun run dev` | Start development server |
| `bun run build` | Build for production |
| `bun run lint` | Run ESLint |
| `bun run test` | Run unit tests (Vitest) |
| `bun run test:e2e` | Run E2E tests (Playwright) |

### Server (using Go)

| Command | Description |
|---------|-------------|
| `go run ./cmd/server` | Run server |
| `go test -v ./...` | Run tests |
| `go test -v -coverprofile=coverage.out ./...` | Run with coverage |
| `golangci-lint run ./...` | Run linter |
| `go build -o bin/server ./cmd/server` | Build binary |

## Repositories

This project is organized into multiple repositories managed by the Project Lead Agent.

- [enclavr/server](https://github.com/enclavr/server) - Go backend server
- [enclavr/frontend](https://github.com/enclavr/frontend) - Next.js frontend

## License

Open source - see individual repository licenses for details.
