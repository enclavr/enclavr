# Active Context - enclavr-root

## Current Work Focus
Debug Docker services - all services running healthy

## Latest Update (2026-03-14)
- Debugged Docker services: all 5 services (coturn, frontend, postgres, redis, server) running healthy
- No fixes needed - services are operational

## Latest Changes (2026-03-14)
- Fixed issue #1: Corrected admin password documentation in root README (was incorrectly stating "default: admin123", actually defaults to empty with first-user-becomes-admin behavior)
- Added admin configuration variables (ADMIN_USERNAME, ADMIN_PASSWORD, ADMIN_EMAIL, FIRST_USER_IS_ADMIN) to infra/.env.example
- All fixes pushed to remote
- Ran branch/tag maintenance across all 5 repos (enclavr, frontend, server, infra, docs) - all have only main branch and v2026.03.14 tag already exists
