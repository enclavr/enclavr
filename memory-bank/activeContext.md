# Active Context - enclavr-root

## Current Work Focus
Debug session completed - infrastructure health checks fixed

## Latest Update (2026-03-20)
Debug all repos - fixed container health issues

## Latest Changes (2026-03-20)
- **Debug Session Results:**
  - Sentry: No errors found (clean)
  - Server: All tests passing
  - Frontend tests: Running (partial timeout)
  - PostgreSQL: Healthy, indexes properly configured
  - Redis: Healthy with all modules loaded

- **Infra Fixes (committed ce6d199):**
  - Frontend healthcheck: Fixed to use curl/wget fallback (nginx:alpine edge case)
  - Coturn: Added explicit --lt-cred-mech flag
  - Coturn: Disabled TLS warnings (--no-tls) since no certs configured
  - All 5 containers now showing healthy status

- Frontend proactive improvements (fdabcd0):
  - Added useKeyboardShortcuts hook
  - Added useAudioLevel hook  
  - Added appearance settings page
  - Added tests for new features

- Server proactive improvements (c1991a4):
  - Added ENCRYPTION_KEY to .env.example
  - Added SearchRooms API endpoint
  - Added typing throttle (2s) for WebSocket
