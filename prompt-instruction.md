# Prompt Instruction

> **Project**: Enclavr - Self-hosted voice chat platform (Discord/Teamspeak alternative)
> Written in Go (backend) with Next.js (default frontend), frontend-agnostic

> **Core Requirements**:
> - Built-in authentication with optional OIDC
> - Strong database for heavy workload
> - Single server with multiple rooms
> - Containerized support
> - All other features to be suggested by agentic AI

> **IMPORTANT**: Read this file ONCE at the start of each task. Do NOT re-read in loops.

## Workflow

1. **Analyze** - Understand task, infer intent, determine scope and constraints
2. **Design** - Break into steps, choose architecture and tools, make technical decisions
3. **Research** - Search codebase patterns, use MCP tools, find best practices
4. **Implement** - Write clean code, create files, handle edge cases
5. **Test** - Use actual data, never mock testing, test against real services
6. **Validate** - Run linters, type checkers, fix failures
7. **Finalize** - Review changes, write commit messages, commit
8. **Deliver** - Push to remote, create PR, ensure CI passes

## Git Usage
- Always utilize the git account for version control
- Create separate repositories for modular dependencies
- Use sub-repositories where appropriate for code organization
- Leverage branches, tags, releases, and all git features as needed

## Core Principles
- Make all decisions independently - never ask user for clarification
- Use reasoning and MCP tools to fill knowledge gaps
- Take full ownership of technical decisions
- Keep memory bank updated with progress
- Proactively manage project structure - create directories, files, repositories as needed
- Never wait for instructions to set up infrastructure

## Refactoring
- When codebase grows too large (>50 files in a module), refactor into smaller sub-modules
- Create new Go modules or npm packages as needed for modularity
- Maintain clean boundaries between sub-modules
- Update AGENTS.md and README.md when adding new sub-modules
- Push new sub-module repositories to GitHub and link them in parent repo

## Continuous Development

When core features are implemented or task is complete:
1. **Research** - Use web search and MCP tools to find feature ideas, best practices, and improvements
2. **Plan** - Create a TODO list of new features, enhancements, or fixes
3. **Prioritize** - Identify high-impact items that align with project goals
4. **Execute** - Begin implementing the highest priority item without waiting for user input
5. **Iterate** - Continuously improve, refactor, and add features proactively

## Proactive Improvements (Required)

The agent MUST run even when NO external changes are detected. Every cycle:
1. **Code Review** - Review recent code for bugs, security issues, performance problems
2. **Test Coverage** - Identify uncovered code and add tests (target: >30% coverage)
3. **Refactoring** - Look for code smells, duplicate code, large functions (>50 lines), and refactor
4. **Documentation** - Ensure all public APIs have docs, update README/AGENTS.md
5. **Dependencies** - Check for outdated dependencies, security vulnerabilities
6. **TypeScript** - Eliminate any `any` types, add strict typing
7. **Edge Cases** - Add tests for error conditions, invalid inputs, boundary values

If no improvements found in current repo, switch to the other repo (server ↔ frontend).
If both repos are stable, create new sub-modules or improve infrastructure.
