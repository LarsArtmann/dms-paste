# Security Policy

## Supported Versions

| Version | Supported  |
| ------- | ---------- |
| v1.1.0  | ✅ Current |

Only the latest release receives security fixes. Please update to the latest
version before reporting issues found in older releases.

## Reporting a Vulnerability

Please do **not** open public issues for security problems. Report privately instead:

- **GitHub Security Advisory**: https://github.com/LarsArtmann/dms-paste/security/advisories/new

### What to include

- Vulnerability type and severity
- Steps to reproduce
- Potential impact
- Proof of concept (if available)

### Response commitments

| Phase            | Timeline                    |
| ---------------- | --------------------------- |
| Initial response | Within 48 hours             |
| Triage           | Within 72 hours             |
| Disclosure       | Coordinated, within 90 days |

## Security Practices

- Every push and PR must pass the full check suite (`nix flake check`) in CI (SHA-pinned actions) before it counts as green
- Snippet files are written chmod 0600 (clipboard content can carry secrets)
- Single-maintainer repo: no PR review requirement; CI is the merge gate
- Dependabot watches the GitHub Actions dependency graph (weekly, grouped update
  PRs — `.github/dependabot.yml`); the nix dependency surface (nixpkgs-unstable
  via flake.lock) has no automated vulnerability scanner — it moves on
  deliberate flake.lock bumps

---

_Maintained with [securitymd](https://github.com/LarsArtmann/securitymd). Last updated: 2026-10-17._
