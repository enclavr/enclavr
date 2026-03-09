# Tech Context - Enclavr

## Technologies Used

### Backend
- **Language**: Go 1.25 (August 2025)
- **Web Framework**: Go net/http with gorilla/mux
- **Database**: PostgreSQL 17 (Neon) / PostgreSQL 18 (self-hosted)
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
- **Database**: PostgreSQL 17 (Neon - free tier) or PostgreSQL 18 (self-hosted)
- **Cache/PubSub**: Redis 8 (Alpine)
- **Voice**: Coturn (TURN server for WebRTC)
- **CI/CD**: GitHub Actions

### Documentation
- **Format**: Static HTML (no build step needed)
- **Location**: `/docs` folder in main repo
- **Deployment**: GitHub Pages (deploy from /docs folder)
- **URL**: https://enclavr.github.io/enclavr/docs/
- **Styling**: Custom CSS with responsive sidebar navigation

### DevOps
- **Linting**: golangci-lint (Go), ESLint v9 (JS)
- **Testing**: Go testing, Vitest, Playwright

### CI/CD Optimization (Mar 2026)
- **Schedule**: Weekly (Sunday midnight UTC) - manual trigger available
- **Concurrency**: Cancels in-progress runs on new commits
- **Path filtering**: Only runs on critical file changes
- **Jobs**: Parallel execution where possible
- **Result**: ~85-90% reduction in free tier minutes

## MCP Tools Available

This project has access to MCP (Model Context Protocol) tools.

### Neon Database (Server)
- PostgreSQL operations via Neon MCP (no SDK - standard GORM)
- Database: ~30MB / 512MB free tier (6%)

### Sentry Error Monitoring (Comprehensive Testing)
Projects: **api**, **frontend**
Region: **us.sentry.io**

#### Quick Status Check
```bash
sentry_whoami                                    # Verify authentication
sentry_find_organizations                        # Confirm enclavr org
sentry_find_teams                                # List teams
sentry_find_projects                             # Verify frontend + api
```

#### Get DSNs (Verify SDK Configuration)
```bash
sentry_find_dsns --organizationSlug "enclavr" --projectSlug "frontend"
sentry_find_dsns --organizationSlug "enclavr" --projectSlug "api"
```

#### Search Issues & Events
```bash
sentry_search_issues --organizationSlug "enclavr" --naturalLanguageQuery "unresolved errors"
sentry_search_issues --organizationSlug "enclavr" --naturalLanguageQuery "crashes"
sentry_search_events --organizationSlug "enclavr" --naturalLanguageQuery "errors from the last 24 hours"
sentry_search_events --organizationSlug "enclavr" --naturalLanguageQuery "slow transactions"
sentry_search_events --organizationSlug "enclavr" --naturalLanguageQuery "database failures"
```

#### Analyze Issues
```bash
sentry_get_issue_details --issueUrl "https://enclavr.sentry.io/issues/123"
sentry_analyze_issue_with_seer --issueUrl "https://enclavr.sentry.io/issues/123"
sentry_get_issue_tag_values --issueUrl "https://enclavr.sentry.io/issues/123" --tagKey "environment"
sentry_get_trace_details --organizationSlug "enclavr" --traceId "abc123"
```

#### Update Issues
```bash
sentry_update_issue --issueUrl "https://enclavr.sentry.io/issues/123" --status "resolved"
sentry_update_issue --issueUrl "https://enclavr.sentry.io/issues/123" --assignedTo "user:123456"
```

#### Create Resources
```bash
sentry_create_team --organizationSlug "enclavr" --name "backend"
sentry_create_project --organizationSlug "enclavr" --teamSlug "backend" --name "api"
sentry_create_dsn --organizationSlug "enclavr" --projectSlug "api" --name "Production"
```

#### Documentation
```bash
sentry_get_doc --path "/platforms/javascript/guides/nextjs.md"
```

#### Comprehensive Testing Workflow (ALWAYS RUN IN ORDER)
1. `sentry_whoami` - Verify authentication
2. `sentry_find_organizations` - Confirm enclavr org exists
3. `sentry_find_teams` - List all teams
4. `sentry_find_projects` - Verify frontend and api projects exist
5. `sentry_find_dsns` for both projects - Verify DSNs match .env files
6. `sentry_search_issues` with "unresolved errors" - List all issues
7. `sentry_search_events` with "errors from the last 24 hours" - Count recent errors
8. `sentry_get_issue_details` on each critical issue
9. `sentry_analyze_issue_with_seer` for root cause analysis
10. `sentry_update_issue` to mark as resolved after fixing

### Other MCP Tools
- Context7: Library documentation
- Git MCP: Version control
- Web Search/Fetch: Current information
- codesearch: Code examples

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

### Database Options

#### Option 1: Docker Compose (Recommended for production-like testing)
```bash
cd infra
docker-compose up -d postgres redis
# Uses PostgreSQL 18
```

#### Option 2: Neon PostgreSQL 17 (Free tier - for CI/testing)
```bash
# Copy the Neon environment file
cp server/.env.neon server/.env

# Sign up at https://neon.tech (free: 0.5GB storage, 1 branch)
# Update server/.env with your Neon connection details

# Run migrations
go run ./cmd/server  # migrations run automatically
```
- Neon free tier: 0.5GB storage, 1 project, 1 branch
- Uses connection pooling (lower latency)
- Requires SSL (sslmode=require)

## Technical Constraints
- Must support multiple concurrent voice users
- Low latency audio streaming
- Horizontal scaling capability
- Cross-platform deployment

## Autonomous Agent (script.sh)

The script runs continuously to manage the project:

### Running
```bash
cd /home/dev/Projects/enclavr
./script.sh
```

### Configuration
- **Timeout**: 600s (10 min) per task
- **Providers**: Alternates between kilo and opencode
- **Rate Limiting**: GitHub API rate limits checked before operations

### Shared State
- **File**: `memory-bank/shared-state.md`
- **Purpose**: Enables continuity between kilo/opencode sessions
- **Contents**: Last provider, task, status, exit code

### Operations
1. Checks issues/PRs/CI every 5 minutes
2. Updates submodules every 30 minutes
3. Runs proactive improvements (30 min cooldown)
4. AI reviews all changes before commit (APPROVE/REJECT)
5. Commits and pushes via Kilo
