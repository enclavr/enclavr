# Progress - enclavr-root

## What Works
- All 5 repos operational
- CI/CD workflows in place
- Monorepo structure with git submodules

## Latest Additions (2026-03-23)
- **Frontend Tabs Component:**
  - Added Tabs, TabsList, TabsTrigger, TabsContent components
  - Follows Apple Liquid Glass design pattern
  - Supports keyboard navigation and ARIA attributes
  - Includes disabled state support
  - Lint passes, typecheck passes
  - Pushed to remote: enclavr/frontend@1558332

- **Frontend ES Module & Test Improvements:**
  - Added 'type': 'module' to package.json for ES modules
  - Converted next.config.js to ES module syntax
  - Updated postcss.config.mjs to use const/export pattern
  - Added createMockResponse helper for API error handling tests
  - Fixed type tests to expect null instead of undefined for expires_at
  - All lint pass, typecheck pass
  - Pushed: enclavr/frontend@13c2e24

- **Server ImportPrivacySettings:**
  - Added ImportPrivacySettings handler to privacy.go
  - Matches ImportPreferences functionality for complete CRUD
  - Validates string settings (everyone, friends, none) before applying
  - Tests pass, lint clean
  - Pushed to remote: enclavr/server@2d4be63

- **Infra Monitoring Stack:**
  - Added Prometheus for metrics collection (port 9090)
  - Added Grafana with system overview dashboard (port 3030)
  - Added node-exporter for system metrics (port 9100)
  - Added postgres-exporter for database metrics (port 9187)
  - Added redis-exporter for cache metrics (port 9121)
  - Updated coturn to 4.9.0-alpine (security update)
  - Config validated, pushed to remote: enclavr/infra@7ca4dfe

- **Frontend Select Component**:
  - Added Select dropdown component with Apple Liquid Glass design
  - Uses useMemo for computed selected label (React 19 compatible)
  - Supports options with disabled states, labels, and values
  - Follows glass-input styling with backdrop blur
  - Lint passes, typecheck passes
  - Pushed to remote: enclavr/frontend@3040845

## Latest Additions (2026-03-22)
- **Frontend Sentry Fix & Skeleton Components**:
  - Fixed beforeSend handler to properly handle non-Error objects
  - Added try-catch to prevent TypeError on invalid error objects
  - Filter out expected 409 conflict errors from Sentry reporting
  - Added Skeleton, SkeletonCard, SkeletonList, SkeletonAvatar components
  - Added Badge and Toast components (recreated)
  - All components follow Apple Liquid Glass design pattern
  - Lint passes, typecheck passes
  - Pushed to remote: enclavr/frontend@decd630

- **Frontend Badge & Toast Components**:
  - Added Badge component with variants (default, success, warning, error, info, outline)
  - Added NotificationBadge component for notification counts
  - Added Toast notification system with toast(), removeToast(), useToast(), ToastContainer
  - Uses useSyncExternalStore for optimal React 19 performance
  - Follows Apple Liquid Glass design pattern
  - Tests: 12 passing, typecheck passes, lint passes
  - Pushed to remote: enclavr/frontend@74b2ec1

- **Server hub.go Refactoring**:
  - Extracted types/constants from hub.go (5927 lines) to meet <500 line guideline
  - presence.go (352 lines): PresenceState, RoomState, Notification types, User types, Payloads
  - websocket.go (349 lines): Message.encode/decode, messageBufferPool
  - hub.go now 5251 lines (11.4% reduction)
  - Build/Tests/Lint: All pass
  - Note: Further extraction requires significant architectural changes

## Additions (2026-03-20)
- **Frontend**: useKeyboardShortcuts, useAudioLevel hooks, appearance page
- **Server**: ENCRYPTION_KEY config, SearchRooms endpoint, typing throttle
- **Infra**: CI workflow improvements

## CI Status (2026-03-20)
### Known Issues (Not Code Related)
- **Frontend CI**: Runner shutdown signals - GitHub Actions infrastructure/billing issue. IGNORE per AGENTS.md guidelines.
- **Root Pages Deploy**: GitHub Pages may not be configured (404 errors)
- **Docs Trigger Deploy**: Permission issue with repository dispatch event

### Fixed
- **Server TestRefreshToken**: Fixed by commit 5416d5c (Auth config now set in test setup)

## What's Left to Build
- [ ] Monitor for new issues
- [ ] Implement proactive improvements on schedule
