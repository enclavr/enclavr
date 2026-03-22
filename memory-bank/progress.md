# Progress - enclavr-root

## What Works
- All 5 repos operational
- CI/CD workflows in place
- Monorepo structure with git submodules

## Latest Additions (2026-03-22)
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
