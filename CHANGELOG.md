# Changelog

All notable changes to this project are documented here.
This project adheres to [Keep a Changelog](https://keepachangelog.com/); versions continue the SystemNix snippets-plugin numbering. Tagged in git since `v1.1.0` (2026-10-17, on the first CI-verified commit); earlier revisions were consumed by flake revision only.

## Unreleased

### Added

- `checks.anchors`: the FEATURES.md Evidence column is mechanically verified — every `path:line` citation (incl. `:line` continuations and `a`-`b` ranges) must resolve to an existing file and a non-blank line, backticked symbol claims must occur within ±5 lines of the cite, and every feature row must carry at least one line anchor (`tests/anchors.sh`). Two doctored-copy self-tests prove the line-bounds and symbol legs both bite; the first run caught rows 12/13/15 citing files without line anchors (now anchored). Doc-anchor rot can no longer ship silently.

### Changed

- Tagged `v1.2.0` (2026-10-17) on the release-prep commit; published the GitHub Release for [`v1.2.0`](https://github.com/LarsArtmann/dms-paste/releases/tag/v1.2.0) (notes from the CHANGELOG section plus a tag-pinned how-to-consume block). AGENTS release ritual amended with what the run taught (tag the release-prep commit, not HEAD; green check on exactly that commit).
- CI concurrency cancellation verified live for the first time: pushing the SECURITY-row commit while the release-prep run (`39016361333`) was in-progress cancelled it via the `check-<ref>` group — observed, no longer assumed.

## 1.2.0 (2026-10-17)

### Added

- CI: `nix flake check` on every push and PR (`.github/workflows/check.yml`, x86_64-linux; aarch64 deferred — the checks are eval/text contracts, not architecture-dependent). First run green 2026-10-17.
- `checks.dprint`: hermetic dprint formatting gate for json/yaml/markdown/dockerfile — the plugin URLs in `dprint.json` are swapped for `fetchurl` store paths inside the check, so no network is needed; add new plugin hashes in `flake.nix` (`dprintCheck`) when bumping.
- `devShells.default` with the pinned dprint (`nix develop`).
- `checks.plugin-logic`: node test harness over `plugins/snippets/SnippetsLogic.js` (scoring tiers, slugify edge cases, the `\x1e`/`\x1f` framed-scan round-trip incl. TOO_LARGE, recency ordering). The launcher QML imports this exact file — logic moved, behavior unchanged.
- `checks.features-counts`: the FEATURES.md summary counts are re-derived from the table, and the gate proves it bites by rejecting a doctored copy.
- `checks.qml-preflight`: qmllint parse gate over every plugin `.qml` (type resolution disabled — Quickshell types only resolve in a live shell), with a self-test leg proving a parse-broken file fails the build. A QML syntax error can no longer ship.
- `docs/status/README.md` index of status reports.
- Dependabot for the GitHub Actions dependency graph (weekly, grouped update PRs; `.github/dependabot.yml`) — first grouped PR bumped `actions/checkout` to the pinned v7.0.1.
- Release ritual documented in AGENTS.md (version bump, annotated tag, GitHub Release cut from the CHANGELOG section with a "how to consume" line, SECURITY.md supported-versions row).
- Scores-history table in `docs/status/README.md` (docs-health Accuracy/Fitness datapoints) plus the add-your-own-row index convention.

### Changed

- SECURITY.md: the "no dedicated dependency/security scanner" claim corrected — Dependabot covers the Actions dependency graph; the nix surface (nixpkgs-unstable via flake.lock) stays scanner-less on deliberate bumps.
- Docs-health AUDIT #3 (as-found Accuracy 8.25 / Fitness 9.25): every status/planning snapshot fully annotated (each item resolved or routed inline) and moved to `docs/status/archived/` + `docs/planning/archived/` with manifests; six never-routed items from the 06-05 report harvested into TODO_LIST/ROADMAP.
- README: the `zwp_virtual_keyboard_manager_v1` and niri claims are now verified against DMS and niri source (2026-10-17) with links and a re-verify cadence note; CI badge added; Development section documents the devShell and the full check suite.
- Tagged `v1.1.0` (2026-10-17) on the first CI-verified commit; published the GitHub Release for [`v1.1.0`](https://github.com/LarsArtmann/dms-paste/releases/tag/v1.1.0) (notes from this changelog).
- CI workflow hardened: actions pinned to commit SHAs (`actions/checkout` v7.0.1, `nix-installer-action` v23 — both verified against the upstream tag objects), cancel-in-progress concurrency group, runner pinned to `ubuntu-24.04` ahead of the announced ubuntu-latest → Ubuntu 26.04 migration (2026-10-19).
- `checks.features-counts`: the prove-it-bites self-test now doctors the declared total via awk arithmetic instead of a literal-text sed — changing FEATURES.md counts no longer requires a matching flake.nix edit.
- README source-evidence links are now commit-SHA permalinks with line anchors (DMS `3674d0f4` `pastekey.go#L20-L64`, niri `45739bc0` `niri.rs#L2577`), immune to upstream `main` drift.
- devShell: nodejs (run the plugin-logic harness locally) and qtdeclarative (qmllint for the preflight) added alongside dprint.
- SECURITY.md: replaced aspirational practices ("automated security scanning runs in CI", "code-reviewed before merge") with what the repo actually does.
- ROADMAP: the shipped pure-logic harness idea graduated out; the aarch64 CI idea now reflects that CI exists.

## 1.1.0 (2026-10-16)

### Added

- Extraction from SystemNix (`pkgs/dms-plugins/systemnix-snippets` + the clipboard-parity settings + the DMS clipboard-modal patches) into this standalone composable flake. Plugin id renamed `systemnix-snippets` → `paste-snippets` (free: the DMS state writer is broken upstream, so no persisted state existed under the old id).
- `:s -name` delete mode (`trash`, empty-name guarded) and the >64 KB scan cap (framed `TOO_LARGE` markers, content never loaded into QML) — both shipped in the SystemNix tree 2026-10-16 before extraction.
- Save flow chmods snippets to 0600 (clipboard content can carry secrets).
- `flake.lib.patchDms`, `homeModules.dms-paste`, `checks.module-contract`, `checks.patch-contract` (build-time harness for the drift guards — previously they only fired at consumer deploy time).
