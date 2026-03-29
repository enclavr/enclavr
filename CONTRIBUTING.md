# Contributing to Enclavr

Enclavr is an AI-managed project. Contributions are welcome through pull requests.

## Repositories

- [enclavr/frontend](https://github.com/enclavr/frontend) - Next.js + React + TypeScript
- [enclavr/server](https://github.com/enclavr/server) - Go backend
- [enclavr/infra](https://github.com/enclavr/infra) - Docker Compose deployment
- [enclavr/docs](https://github.com/enclavr/docs) - Documentation

## Development

Each component lives in its own submodule. Work within the relevant sub-repository:

| Component | Tool |
|-----------|------|
| Frontend | `bun` |
| Server | `go` |
| Infra | `docker` |

## Pull Requests

1. Fork the relevant repository
2. Create a feature branch
3. Make your changes
4. Ensure tests pass
5. Submit a pull request

All PRs are reviewed and CI must pass before merging.
