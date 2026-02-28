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
- migrations for schema changes
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
