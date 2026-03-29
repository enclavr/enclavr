# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.1.0] - 2026-03-29

### Added

- Initial release of Enclavr monorepo
- Autonomous agent loop (`script/main.sh`) with 5-repo rotation and 7-step task cycle
- GitHub Security audit step (Dependabot, code scanning, secret scanning)
- GitHub Files audit step for community/config file maintenance
- GITHUB_FILES_ONLY task flag for dedicated documentation maintenance
- Neon PostgreSQL as default database provider
- NEON_CONNECTION_STRING configuration in `.env.example`
- Push-to-talk (PTT) voice feature in frontend

### Fixed

- CI workflow permissions block to resolve code scanning alerts
- Root repo inclusion in autonomous agent loop (was only cycling 4 repos)
- False-positive dismissal behavior in autonomous agent security prompts
- CODEOWNERS reverted to `@enclavr` user account
- Absolute URL for frontend submodule reference
- WebAuthn claim removed from documentation (not yet implemented)
- Placeholder CI workflow replaced with functional validation steps
- CODE_OF_CONDUCT enforcement email filled in

### Changed

- Autonomous agent prompts refactored for all 5 repos with per-repo security and GitHub Files prompts
- SECURITY.md updated with verified architecture claims across all submodules
- AGENTS.md expanded with GitHub Security API docs, Git Push Policy, and tag strategy
