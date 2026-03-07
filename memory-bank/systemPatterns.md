# System Patterns - Enclavr

## Architecture

### Backend (Go)
- Clean Architecture with dependency injection
- Repository pattern for database access
- Service layer for business logic
- REST API with OpenAPI documentation
- WebSocket for real-time communication

### Frontend (Next.js)
- App Router structure
- Server-side rendering
- Type-safe API client
- Responsive design with Tailwind CSS

### Database
- PostgreSQL with proper indexing
- Migrations for schema changes
- Connection pooling for heavy workload

### Voice Communication
- WebRTC for peer-to-peer audio
- TURN/STUN server support
- Room-based audio routing

## Design Patterns
- Repository Pattern
- Service Layer Pattern
- Dependency Injection
- RESTful API design
- JWT Authentication with refresh tokens

## Development Workflow (MCP Tools)

### Database Operations
- Use Neon MCP tools for PostgreSQL operations
- Never use psql directly - use neon_run_sql

### Documentation
- Use Context7 MCP for library docs (React, Next.js, Go, etc.)
- Use websearch/webfetch for current information

### Version Control
- Use Git MCP tools instead of bash git commands

### Error Monitoring
- Sentry MCP for production error tracking
- Create projects via sentry_create_project
