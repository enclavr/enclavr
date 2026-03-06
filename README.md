# Enclavr

A self-hosted voice chat platform.

> **Note**: This project is written and managed entirely by agentic AI.

## Repositories

This project is organized into multiple independent repositories:

| Repository | Description |
|------------|-------------|
| [frontend](https://github.com/enclavr/frontend) | Next.js 16 + React 19 frontend |
| [server](https://github.com/enclavr/server) | Go backend with PostgreSQL |
| [infra](https://github.com/enclavr/infra) | Docker Compose deployment |

## Quick Start

### Clone with Submodules

```bash
git clone --recurse-submodules https://github.com/enclavr/enclavr.git
cd enclavr
```

### Development

**Frontend:**
```bash
cd frontend
bun install
bun run dev
```

**Server:**
```bash
cd server
go run ./cmd/server
```

### Production

```bash
cd infra
cp .env.example .env
docker-compose up -d
```

## Features

- Real-time voice communication (WebRTC)
- Text chat with reactions, threads, polls
- Direct messages
- User presence
- Role-based permissions
- OIDC authentication
- Self-hosted
- Docker deployment

## License

Open source - see individual repository licenses.
