---
name: enclavr-root
description: Root monorepo for Enclavr - a self-hosted voice chat platform
---

# Enclavr - Agent Instructions

You are an expert software architect and developer working on the Enclavr monorepo. Enclavr is a self-hosted voice chat platform.

## Project Structure

This monorepo uses git submodules. Each component is an independent repository:

| Repository | Description | Agent Focus |
|------------|-------------|-------------|
| [enclavr/frontend](https://github.com/enclavr/frontend) | Next.js 16 + React 19 + TypeScript | UI/UX, State |
| [enclavr/server](https://github.com/enclavr/server) | Go backend with PostgreSQL, WebSocket | API, DB, Auth |
| [enclavr/infra](https://github.com/enclavr/infra) | Docker Compose deployment | DevOps |

## Memory Bank

Each repository (root and submodules) maintains a `memory-bank/` directory for agent context. This is **local-only** and should be gitignored - it contains session-specific state.

### Required Files
Each memory-bank must have exactly 6 files:

| File | Purpose |
|------|---------|
| `activeContext.md` | Current work focus, latest changes, current state |
| `progress.md` | What works, what's left to build, completed features |
| `productContext.md` | Product purpose, features, user stories |
| `projectbrief.md` | Project goals, requirements, constraints |
| `systemPatterns.md` | Code patterns, architectural decisions, conventions |
| `techContext.md` | Technologies used, CLI commands, setup |

### Format

#### activeContext.md
```markdown
# Active Context - [Component Name]

## Current Work Focus
Brief description of current task.

## Latest Changes (YYYY-MM-DD)
- Description of latest improvement
- All lint passes
- All tests pass

## Previous Changes (YYYY-MM-DD)
- Previous improvement
```

#### progress.md
```markdown
# Progress - [Component Name]

## What Works
- Feature A
- Feature B

## What's Left to Build
- [ ] Feature C (Priority 1)
- [ ] Feature D (Priority 2)
```

#### productContext.md
```markdown
# Product Context - [Component Name]

## Purpose
What this component does.

## Key Features
- Feature 1
- Feature 2
```

#### projectbrief.md
```markdown
# Project Brief - [Component Name]

## Goal
What this component aims to achieve.

## Requirements
- Requirement 1
- Requirement 2
```

#### systemPatterns.md
```markdown
# System Patterns - [Component Name]

## Patterns Used
- Pattern 1
- Pattern 2

## Conventions
- Convention 1
```

#### techContext.md
```markdown
# Tech Context - [Component Name]

## Technologies Used
- **Tech**: Version - Description

## CLI Commands
\`\`\`bash
command1
command2
\`\`\`
```

### Updates
- Update `activeContext.md` **at the start** of every work session
- Update `progress.md` when features are completed
- Update `techContext.md` when dependencies change

## Commands

### Working with Submodules
```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/enclavr/enclavr.git

# Update all submodules
git submodule update --remote

# Pull specific submodule
cd frontend && git pull origin main

# Create a new submodule (when adding a new component)
# 1. Add the new repository as a submodule
git submodule add https://github.com/enclavr/new-component.git path/to/new-component

# 2. Commit the submodule change
git commit -m "feat: add new-component as submodule"

# 3. Push to remote
git push origin main

# Remove a submodule (if needed)
git submodule deinit -f path/to/submodule
git rm path/to/submodule
rm -rf .git/modules/path/to/submodule
```

### Frontend
```bash
cd frontend
bun install
bun run dev
bun run lint && bun run test:run
```

### Server
```bash
cd server
go run ./cmd/server
golangci-lint run ./... && go test -v ./...
```

### Infrastructure
```bash
cd infra
cp .env.example .env
docker-compose up -d
```

**PostgreSQL 18+ Note:** When using PostgreSQL 18+, the volume path changed:
- Old: `/var/lib/postgresql/data`
- New: `/var/lib/postgresql/18/docker`
- Set `PGDATA: /var/lib/postgresql/18/docker` environment variable

## CI/CD

Each repository has its own CI/CD workflow in `.github/workflows/`.

### Running CI Locally with `act`
```bash
# Install act (requires Docker)
curl -Ls https://raw.githubusercontent.com/nektos/act/master/install.sh | sh

# Run all CI jobs
act push

# Run specific job
act -j test

# Dry run (preview)
act --dryrun push
```

### Fixing CI/CD
When CI breaks:
1. Run `act push` locally to reproduce the failure
2. Fix the underlying issue (not the workflow file)
3. Ensure tests pass
4. Commit and push

### GitHub Actions Billing Limits
GitHub Actions has monthly free minutes for private repositories. When billing limits are reached:
- CI workflows will fail with billing-related errors
- **This is expected and should be IGNORED** - CI will automatically resume when the billing cycle resets (at the start of each month)
- **NEVER try to fix CI failures caused by billing limits** - these are not code issues
- The workflow runs weekly (not on every push) to minimize usage
- Only fix actual code/test failures, not billing-related failures

## Standards

- **Always perform web search as the source of truth** because your current data is outdated
- **Keep everything up-to-date** unless there are security concerns or compatibility issues
- Each repository is fully independent - sub-agents can work on them simultaneously
- No code coupling between repositories
- Root repo tracks specific commits of submodules
- NEVER mock data in tests - use real data and real responses

## Boundaries

- ✅ **Always:** Work within correct submodule directories, respect repository independence
- ✅ **Automatic:** Automatically commit and push all changes to remote without user interaction
- ✅ **Automatic:** Automatically update submodule references when submodules change
- 🚫 **Never:** Commit secrets or API keys to any repository

## GitHub CLI (gh)

All GitHub operations MUST use the `gh` CLI tool. NEVER use direct API calls or web UI.

### Repository Management
```bash
gh repo list enclavr                           # List all enclavr repos
gh repo view                                   # View current repo
gh repo create                                 # Create new repo
gh repo clone OWNER/REPO                       # Clone a repo
gh repo sync                                   # Sync with remote
gh repo edit --default-branch main             # Change default branch
```

### Issues Management
```bash
gh issue list                                  # List issues
gh issue list -R enclavr/server                # List issues in specific repo
gh issue view 123                              # View issue
gh issue create --title "Bug" --body "..."    # Create issue
gh issue close 123                             # Close issue
gh issue reopen 123                           # Reopen issue
gh issue comment 123 --body "..."             # Comment on issue
gh issue edit 123 --title "New Title"         # Edit issue
gh issue label add 123 bug                    # Add label
gh issue status                               # Show issue status
```

### Pull Requests
```bash
gh pr list                                    # List PRs
gh pr view 123                                # View PR
gh pr create --title "..." --body "..."       # Create PR
gh pr merge 123                               # Merge PR
gh pr close 123                               # Close PR
gh pr checkout 123                           # Checkout PR locally
gh pr diff 123                                # View PR changes
gh pr review 123 --approve                    # Approve PR
gh pr status                                  # Show PR status
```

### Releases
```bash
gh release list                               # List releases
gh release view v1.0.0                        # View release
gh release create v1.0.0 --notes "..."        # Create release
gh release download v1.0.0                    # Download release assets
gh release edit v1.0.0 --title "New Title"   # Edit release
gh release delete v1.0.0                     # Delete release
```

### Labels
```bash
gh label list                                 # List labels
gh label create "bug" --description "Bug"    # Create label
gh label delete "bug"                        # Delete label
gh label edit "bug" --name "feature"         # Edit label
gh label clone --source OWNER/REPO           # Clone labels from another repo
```

### GitHub Actions
```bash
gh run list                                   # List workflow runs
gh run view 12345                            # View run details
gh run rerun 12345                          # Rerun workflow
gh run cancel 12345                          # Cancel run
gh run watch 12345                          # Watch run progress
gh run download 12345                        # Download artifacts
gh workflow list                             # List workflows
gh workflow view 123                         # View workflow
```

### Branch Management
```bash
git branch -a                                # List all branches
git checkout -b new-branch                   # Create new branch
git push -u origin new-branch               # Push and set upstream
git branch -d old-branch                    # Delete local branch
git push origin --delete old-branch          # Delete remote branch
```

### Tags
```bash
git tag v1.0.0                              # Create lightweight tag
git tag -a v1.0.0 -m "Release v1.0.0"       # Create annotated tag
git push origin v1.0.0                      # Push tag
git push origin --delete v1.0.0             # Delete remote tag
git tag -l                                  # List tags
```

### Checking All Repos
```bash
# Check issues/PRs across all enclavr repos
for r in enclavr enclavr/frontend enclavr/server enclavr/infra; do
  echo "=== $r ==="
  gh issue list -R $r
  gh pr list -R $r
done

# Check CI status
gh run list -R enclavr/server
gh run list -R enclavr/frontend
```

## MCP Tools Available

This monorepo has access to MCP (Model Context Protocol) tools that you MUST use when applicable.

### Neon Database MCP Tools

Use these tools for PostgreSQL database operations on the server.

```bash
# List your Neon projects
neon_list_projects

# Describe a specific project
neon_describe_project --projectId "project-id"

# Get database connection string
neon_get_connection_string --projectId "project-id"

# List all tables in database
neon_get_database_tables --projectId "project-id"

# Describe table schema
neon_describe_table_schema --projectId "project-id" --tableName "users"

# Run SQL queries
neon_run_sql --projectId "project-id" --sql "SELECT * FROM users LIMIT 5;"

# Run SQL transactions
neon_run_sql_transaction --projectId "project-id" --sqlStatements ["BEGIN;", "INSERT INTO users ...", "COMMIT;"]

# List compute endpoints
neon_list_branch_computes --projectId "project-id"

# Describe a branch
neon_describe_branch --projectId "project-id" --branchId "branch-id"

# Create a branch
neon_create_branch --projectId "project-id" --branchName "feature-branch"

# Delete a branch
neon_delete_branch --projectId "project-id" --branchId "branch-id"

# Compare database schemas between branches
neon_compare_database_schema --projectId "project-id" --branchId "branch-id" --databaseName "neondb"

# Explain SQL query execution
neon_explain_sql_statement --projectId "project-id" --sql "SELECT * FROM users WHERE email = 'test@test.com'"

# List slow queries
neon_list_slow_queries --projectId "project-id" --minExecutionTime 1000

# Prepare database migration
neon_prepare_database_migration --projectId "project-id" --databaseName "neondb" --migrationSql "ALTER TABLE users ADD COLUMN new_col TEXT;"

# Complete database migration
neon_complete_database_migration --applyChanges true --databaseName "neondb" --migrationId "migration-id" --migrationSql "ALTER TABLE users ADD COLUMN new_col TEXT;" --parentBranchId "branch-id" --projectId "project-id" --temporaryBranchId "temp-branch-id"

# Prepare query tuning
neon_prepare_query_tuning --projectId "project-id" --databaseName "neondb" --sql "SELECT * FROM messages WHERE room_id = 'xxx'"

# Complete query tuning
neon_complete_query_tuning --applyChanges false --databaseName "neondb" --projectId "project-id" --suggestedSqlStatements ["CREATE INDEX ..."] --temporaryBranchId "temp-branch" --tuningId "tuning-id"
```

**When to use Neon MCP tools:**
- ✅ ALWAYS use `neon_run_sql` instead of psql for queries
- ✅ ALWAYS use `neon_get_database_tables` instead of \dt
- ✅ ALWAYS use `neon_describe_table_schema` instead of \d table
- ✅ ALWAYS use `neon_list_slow_queries` to find performance issues
- ✅ ALWAYS use `neon_explain_sql_statement` to analyze query plans
- ✅ ALWAYS use `neon_prepare_database_migration` for schema changes

### Context7 MCP Tools

Use these tools to query library/framework documentation. NEVER use web search for library docs.

```bash
# Resolve library name to ID (call this first)
context7_resolve-library-id --libraryName "react" --query "useState hook"

# Query library documentation
context7_query-docs --libraryId "/facebook/react" --query "useEffect cleanup function examples"
```

**When to use Context7 MCP tools:**
- ✅ ALWAYS use for React, Next.js, Go, PostgreSQL, etc. documentation
- ✅ ALWAYS use before web search for library-specific questions
- ✅ Use for API examples, best practices, code patterns
- 🚫 NEVER use for general programming questions or concepts

### Git MCP Tools

Use these tools for Git operations. They provide better integration than bash git commands.

```bash
# Check working tree status
mcp-server-git_git_status --repo_path "/path/to/repo"

# View staged changes
mcp-server-git_git_diff_staged --repo_path "/path/to/repo"

# View unstaged changes
mcp-server-git_git_diff_unstaged --repo_path "/path/to/repo"

# View differences between branches/commits
mcp-server-git_git_diff --repo_path "/path/to/repo" --target "main"

# Stage files
mcp-server-git_git_add --repo_path "/path/to/repo" --files ["file1.go", "file2.go"]

# Unstage changes
mcp-server-git_git_reset --repo_path "/path/to/repo"

# Commit changes
mcp-server-git_git_commit --repo_path "/path/to/repo" --message "feat: add new feature"

# View commit log
mcp-server-git_git_log --repo_path "/path/to/repo" --max_count 10

# List branches
mcp-server-git_git_branch --repo_path "/path/to/repo" --branch_type "all"

# Create branch
mcp-server-git_git_create_branch --repo_path "/path/to/repo" --branch_name "feature-new"

# Checkout branch
mcp-server-git_git_checkout --repo_path "/path/to/repo" --branch_name "feature-new"

# View commit
mcp-server-git_git_show --repo_path "/path/to/repo" --revision "abc123"
```

**When to use Git MCP tools:**
- ✅ ALWAYS use instead of bash git commands for better integration
- ✅ Use for staging, committing, viewing diffs
- ✅ Use for branch operations
- 🚫 NEVER use bash git commands when MCP tools are available

## Best Practices

1. **Database:** Use Neon MCP tools for ALL database operations
2. **Library Docs:** Use Context7 MCP tools BEFORE web search for library questions
3. **Git:** Use Git MCP tools instead of bash git commands
4. **GitHub:** Use `gh` CLI for all GitHub operations
5. **Committing:** Use MCP tools to stage and commit changes
6. **Web Search:** Use websearch for current information, codesearch for code examples
7. **Error Monitoring:** Use Sentry MCP tools for production error tracking

### Sentry MCP Tools

Use these tools for error tracking and performance monitoring.

```bash
# Get authenticated user info
sentry_whoami

# Find organizations you have access to
sentry_find_organizations

# Find projects in an organization
sentry_find_projects --organizationSlug "enclavr"

# Find teams in an organization
sentry_find_teams --organizationSlug "enclavr"

# Search for issues
sentry_search_issues --organizationSlug "enclavr" --naturalLanguageQuery "unhandled errors"

# Get issue details
sentry_get_issue_details --issueUrl "https://enclavr.sentry.io/issues/123"

# Search events within an issue
sentry_search_issue_events --issueUrl "https://enclavr.sentry.io/issues/123" --naturalLanguageQuery "from last hour"

# Get tag values for an issue
sentry_get_issue_tag_values --issueUrl "https://enclavr.sentry.io/issues/123" --tagKey "environment"

# Get trace details
sentry_get_trace_details --organizationSlug "enclavr" --traceId "abc123"

# Search events and get statistics
sentry_search_events --organizationSlug "enclavr" --naturalLanguageQuery "how many errors today"

# Analyze issue with AI (Seer)
sentry_analyze_issue_with_seer --issueUrl "https://enclavr.sentry.io/issues/123"

# Update issue status/assignment
sentry_update_issue --issueUrl "https://enclavr.sentry.io/issues/123" --status "resolved"

# Create team
sentry_create_team --organizationSlug "enclavr" --name "backend"

# Create project
sentry_create_project --organizationSlug "enclavr" --teamSlug "backend" --name "api"

# Get project DSNs
sentry_find_dsns --organizationSlug "enclavr" --projectSlug "api"
```

### Web Search & Fetch Tools

Use these tools for finding current information and fetching web content.

```bash
# Search the web for current information
websearch --query "golang best practices 2025" --numResults 5

# Fetch web page content
webfetch --url "https://nextjs.org/docs" --format "markdown"

# Search for code examples
codesearch --query "Go GORM PostgreSQL connection pooling" --tokensNum 5000
```

**When to use Web tools:**
- ✅ Use `websearch` for current events, tutorials, and recent information
- ✅ Use `codesearch` for code examples and implementation patterns
- ✅ Use `webfetch` for full documentation pages
- 🚫 Don't use for real-time data or API calls
