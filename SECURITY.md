# Security Policy

Enclavr is a self-hosted voice chat platform. This document covers the security policy for the entire Enclavr project across all repositories.

## Reporting a Vulnerability

**Do NOT report security vulnerabilities through public GitHub issues.**

If you discover a security vulnerability, please report it responsibly:

- **GitHub Private Vulnerability Reporting:** Use the ["Report a vulnerability"](https://github.com/enclavr/enclavr/security/advisories/new) button in the Security tab of this repository.
- **Email:** Send details to `enclavr.dev@gmail.com`

### What to Include

- Description of the vulnerability
- Component affected (frontend, server, infrastructure, or cross-cutting)
- Steps to reproduce
- Potential impact assessment
- Suggested fix (if any)

### Response Timeline

| Stage | Timeline |
|-------|----------|
| Acknowledgement | Within 48 hours |
| Initial triage | Within 5 business days |
| Fix/patch target | 30 days (varies by severity) |

## Supported Versions

| Component | Supported |
|-----------|-----------|
| Latest release | Yes |
| Previous major | Security fixes only |
| Older releases | No |

Security updates are applied to the latest release. Users are encouraged to deploy updates promptly.

## Disclosure Policy

1. Report received and assigned a handler
2. Issue confirmed and affected components determined
3. Fix prepared on a private branch
4. CVE requested (if applicable)
5. Fix released and GitHub Security Advisory published
6. Reporter credited (unless anonymity requested)

We follow coordinated disclosure. Fixes are held privately until the embargo lifts, then released simultaneously with the advisory.

## Security Architecture

Enclavr implements defense-in-depth across all layers:

- **Authentication:** JWT with configurable expiry, bcrypt password hashing, TOTP 2FA with AES-256-GCM encrypted secrets, OIDC support
- **Authorization:** Per-user, per-IP, per-endpoint rate limiting with sliding window algorithm
- **Transport:** TLS via automatic HTTPS (Let's Encrypt), WebSocket over TLS
- **Container Security:** Least-privilege capabilities, non-root users, read-only filesystems, network isolation
- **Infrastructure:** Isolated Docker networks (frontend, backend, monitoring), Trivy vulnerability scanning in CI
- **Monitoring:** Sentry error tracking, Prometheus metrics, Grafana dashboards, Loki log aggregation

See individual repository security policies for component-specific details:

- [Frontend Security](frontend/SECURITY.md)
- [Server Security](server/SECURITY.md)
- [Infrastructure Security](infra/SECURITY.md)
- [Documentation Security](docs/SECURITY.md)

## Security Announcements

- Watch this repository's [Security Advisories](https://github.com/enclavr/enclavr/security/advisories) for updates
- Subscribe to release notifications for security patches

## Safe Harbor

We support safe harbor for security researchers who:

- Make good-faith efforts to avoid privacy violations and disruption of service
- Report vulnerabilities promptly and do not exploit them beyond what is necessary for demonstration
- Do not access, modify, or delete user data beyond what is needed to demonstrate the vulnerability
- Do not perform denial-of-service attacks or social engineering

We will not pursue legal action against researchers who follow these guidelines.
