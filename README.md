# Enclavr

A self-hosted voice chat platform.

> This project is written and managed entirely by agentic AI.

## Repositories

| Repository | Description |
|------------|-------------|
| [frontend](https://github.com/enclavr/frontend) | Next.js 16 + React 19 frontend |
| [server](https://github.com/enclavr/server) | Go backend with PostgreSQL |
| [infra](https://github.com/enclavr/infra) | Docker Compose deployment |
| [docs](https://github.com/enclavr/docs) | Documentation |

## Quick Start

### Development

```bash
git clone --recurse-submodules https://github.com/enclavr/enclavr.git
cd enclavr

# Frontend
cd frontend && bun install && bun run dev

# Server (separate terminal)
cd server && go run ./cmd/server
```

### Production

```bash
cd enclavr/infra
cp .env.example .env
# Edit .env and change all default passwords/secrets
docker compose up -d
```

**First Login:** First user to register becomes admin (or set `ADMIN_PASSWORD` in `infra/.env`).

## Features

- Real-time voice communication (WebRTC)
- Text chat with reactions, threads, polls
- Direct messages and presence
- Role-based permissions and OIDC authentication
- Self-hosted with Docker deployment

## Documentation

- **Live Docs**: https://enclavr.github.io/enclavr/docs/
- **Source**: `/docs` folder

## Error Monitoring

Sentry for production error tracking. See [AGENTS.md](./AGENTS.md) for MCP tools to search and analyze issues.

| Project | DSN Variable |
|---------|-------------|
| [frontend](https://sentry.io/organizations/enclavr/projects/frontend/) | `NEXT_PUBLIC_SENTRY_DSN` |
| [api](https://sentry.io/organizations/enclavr/projects/api/) | `SENTRY_DSN` |

## Autonomous Agent

`./script/main.sh` runs an AI agent loop that checks issues, reviews PRs, analyzes CI, and runs proactive improvements periodically.

See [AGENTS.md](./AGENTS.md) for agent instructions and MCP tool documentation.

## License

Public domain under [The Unlicense](LICENSE).

**Legal:** Self-hosted software - you are responsible for VoIP/telecom compliance, data protection, and export control in your jurisdiction.
