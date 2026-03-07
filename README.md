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
cd infra
cp .env.example .env
docker-compose up -d
```

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

## License

Open source - see individual repository licenses.
