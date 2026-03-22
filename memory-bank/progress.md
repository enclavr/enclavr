# Progress - enclavr-root

## What Works
- All 5 repos operational
- CI/CD workflows in place
- Monorepo structure with git submodules

## Latest Additions (2026-03-23)
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
