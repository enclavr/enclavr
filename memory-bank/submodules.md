# Sub-Module Architecture

## Overview

Enclavr uses a **modular repository structure** with independent git repositories.

## Current Structure

```
enclavr/ (root - git submodule references)
├── frontend/     # Next.js frontend (independent repo)
├── server/       # Go backend (independent repo)
├── infra/        # Docker deployment (independent repo)
└── memory-bank/  # Main project documentation
```

## Repositories

| Repository | GitHub | Description | Tests |
|------------|--------|-------------|-------|
| **frontend** | [enclavr/frontend](https://github.com/enclavr/frontend) | Next.js 16 + React 19 | 393 unit + 37 E2E |
| **server** | [enclavr/server](https://github.com/enclavr/server) | Go backend + PostgreSQL | 819+ tests |
| **infra** | [enclavr/infra](https://github.com/enclavr/infra) | Docker Compose | N/A |

## Submodule Management

The root repository uses **git submodules** to reference independent repos:

```bash
# Clone with all submodules
git clone --recurse-submodules https://github.com/enclavr/enclavr.git

# Update submodules to latest
git submodule update --remote

# Work on a specific submodule independently
cd frontend && git checkout -b feature/my-feature
```

## Architecture

### Server (Go Backend)

| Module | Location | Description |
|--------|----------|-------------|
| **auth** | `internal/auth/` | JWT authentication, OIDC |
| **handlers** | `internal/handlers/` | 30+ HTTP handlers |
| **voice** | `internal/websocket/` | WebSocket hub, WebRTC |
| **messaging** | `internal/handlers/` | Message, thread, reaction, poll |
| **users** | `internal/handlers/` | User, role, ban, report |
| **rooms** | `internal/handlers/` | Room, category, invite, presence |

### Frontend (Next.js)

| Module | Location | Description |
|--------|----------|-------------|
| **auth-ui** | `src/app/login/`, `src/app/register/` | Login/Register |
| **chat-ui** | `src/components/Chat.tsx` | Text chat |
| **voice-ui** | `src/components/VoiceChat.tsx` | Voice/Video |
| **dm-ui** | `src/app/dm/` | Direct messages |
| **rooms-ui** | `src/app/rooms/` | Room management |

### Infrastructure

| Module | Description |
|--------|-------------|
| **postgres** | PostgreSQL database |
| **redis** | Redis for pub/sub |
| **coturn** | TURN server for WebRTC |
| **server** | Go backend container |
| **frontend** | Next.js container |

## Independent Development

Each repository can be worked on by **separate sub-agents** independently:

- **Sub-agent 1**: Works on `frontend/` - no coupling with server
- **Sub-agent 2**: Works on `server/` - no coupling with frontend
- **Sub-agent 3**: Works on `infra/` - deployment only

Changes in one repo don't affect others - only the root tracks submodule versions.
