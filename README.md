# Enclavr

A self-hosted voice chat platform.

> **Note**: This project is written and managed entirely by agentic AI.

## Autonomous Agent

This project uses an autonomous AI agent (`script.sh`) that monitors GitHub for issues, pull requests, and CI failures continuously, then implements fixes automatically.

### MCP Tools

The agent uses Model Context Protocol (MCP) tools for:

- **Database:** Neon MCP tools for PostgreSQL operations
- **Documentation:** Context7 MCP tools for library/framework docs
- **Git:** Git MCP tools for version control
- **Error Tracking:** Sentry MCP tools for production monitoring
- **Web:** websearch, webfetch, codesearch for current information

See [AGENTS.md](./AGENTS.md) for detailed MCP tool documentation.

## Repositories

This project is organized into multiple independent repositories:

| Repository | Description |
|------------|-------------|
| [frontend](https://github.com/enclavr/frontend) | Next.js 16 + React 19 frontend |
| [server](https://github.com/enclavr/server) | Go backend with PostgreSQL |
| [infra](https://github.com/enclavr/infra) | Docker Compose deployment |
| [docs](https://github.com/enclavr/docs) | Documentation (see /docs folder) |

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
git clone --recurse-submodules https://github.com/enclavr/enclavr.git
cd enclavr/infra

# Configure environment
cp .env.example .env
# Edit .env and change all default passwords and secrets

# Start all services
docker compose up -d
```

**First Login:**
- Username: `admin`
- Password: Set `ADMIN_PASSWORD` in `.env` (default: admin123)

## Documentation

The documentation is located in the `/docs` folder and is deployed via GitHub Pages.

- **Live Docs**: https://enclavr.github.io/enclavr/docs/
- **Source**: `/docs` folder in this repository

### Building Docs Locally

The docs are static HTML files. Edit directly in the `docs/` folder:

```bash
# Edit documentation
docs/index.html          # Home page
docs/docs/*.html        # All documentation pages
docs/css/style.css      # Styles
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

## Error Monitoring

This project uses **Sentry** for production error tracking and performance monitoring.

### Sentry Projects

| Project | Description | DSN Environment Variable |
|---------|-------------|-------------------------|
| [frontend](https://sentry.io/organizations/enclavr/projects/frontend/) | Next.js web UI | `NEXT_PUBLIC_SENTRY_DSN` |
| [api](https://sentry.io/organizations/enclavr/projects/api/) | Go backend API | `SENTRY_DSN` |

### Viewing Errors

1. **Frontend Issues**: https://enclavr.sentry.io/projects/frontend/
2. **API Issues**: https://enclavr.sentry.io/projects/api/

### Debugging Errors

Use the Sentry MCP tools to search and analyze issues:

```bash
# Search for issues
sentry_search_issues --organizationSlug "enclavr" --naturalLanguageQuery "unresolved errors"

# Get event details
sentry_get_issue_details --issueUrl "https://enclavr.sentry.io/issues/123"

# Analyze with AI
sentry_analyze_issue_with_seer --issueUrl "https://enclavr.sentry.io/issues/123"
```

## Development Setup

### Hybrid Setup (Recommended for Development)

Run infrastructure in Docker, application on host:

```bash
# Start only infrastructure services (PostgreSQL, Redis, Coturn)
cd infra
docker compose -f docker-compose.services.yml up -d

# Configure environment for local development
# Edit infra/.env and ensure DB_HOST=localhost, REDIS_HOST=localhost

# Start Go server on host
cd server
go run ./cmd/server

# Start frontend on host (in another terminal)
cd frontend
bun run dev
```

### Full Docker Setup

```bash
cd infra
docker compose up -d
```

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

## License

This project is released into the public domain under [The Unlicense](LICENSE).
See the LICENSE file for full terms and conditions, including important
disclaimers about AI-generated code, the prohibition on using this
codebase for AI training, and legal compliance requirements.

---

## Legal Notice

This is self-hosted software. **You** (not the authors) are responsible for:
- Compliance with local VoIP/telecommunications regulations
- Data protection and privacy laws in your jurisdiction
- Export control compliance in your jurisdiction
- Any required licenses or registrations for voice services

See LICENSE for full disclaimers.
