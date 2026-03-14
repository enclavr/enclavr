# Active Context - enclavr-root

## Current Work Focus
Docker debug - verified all services healthy

## Latest Update (2026-03-14)
- Checked docker compose ps - all 5 services healthy (coturn, frontend, postgres, redis, server)
- Checked docker compose logs - all services running without errors
- Historical errors from March 12th (database connection failures during restart) - services recovered automatically
- No fixes needed - all services operational

## Latest Changes (2026-03-14)
- Fixed issue #1: Corrected admin password documentation in root README (was incorrectly stating "default: admin123", actually defaults to empty with first-user-becomes-admin behavior)
- Added admin configuration variables (ADMIN_USERNAME, ADMIN_PASSWORD, ADMIN_EMAIL, FIRST_USER_IS_ADMIN) to infra/.env.example
- All fixes pushed to remote
- Ran branch/tag maintenance across all 5 repos (enclavr, frontend, server, infra, docs) - all have only main branch and v2026.03.14 tag already exists
