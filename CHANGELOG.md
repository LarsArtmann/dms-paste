# Changelog

All notable changes to this project are documented here.
This project adheres to [Keep a Changelog](https://keepachangelog.com/); versions continue the SystemNix snippets-plugin numbering. Tagged in git since `v1.1.0` (2026-10-17, on the first CI-verified commit); earlier revisions were consumed by flake revision only.

## Unreleased

### Added

- CI: `nix flake check` on every push and PR (`.github/workflows/check.yml`, x86_64-linux; aarch64 deferred — the checks are eval/text contracts, not architecture-dependent). First run green 2026-10-17.
- `checks.dprint`: hermetic dprint formatting gate for json/yaml/markdown/dockerfile — the plugin URLs in `dprint.json` are swapped for `fetchurl` store paths inside the check, so no network is needed; add new plugin hashes in `flake.nix` (`dprintCheck`) when bumping.
- `devShells.default` with the pinned dprint (`nix develop`).
- `checks.plugin-logic`: node test harness over `plugins/snippets/SnippetsLogic.js` (scoring tiers, slugify edge cases, the `\x1e`/`\x1f` framed-scan round-trip incl. TOO_LARGE, recency ordering). The launcher QML imports this exact file — logic moved, behavior unchanged.
- `checks.features-counts`: the FEATURES.md summary counts are re-derived from the table, and the gate proves it bites by rejecting a doctored copy.
- `docs/status/README.md` index of status reports.

### Changed

- README: the `zwp_virtual_keyboard_manager_v1` and niri claims are now verified against DMS and niri source (2026-10-17) with links and a re-verify cadence note; CI badge added; Development section documents the devShell and the full check suite.
- Tagged `v1.1.0` (2026-10-17) on the first CI-verified commit.

## 1.1.0 (2026-10-16)

### Added

- Extraction from SystemNix (`pkgs/dms-plugins/systemnix-snippets` + the clipboard-parity settings + the DMS clipboard-modal patches) into this standalone composable flake. Plugin id renamed `systemnix-snippets` → `paste-snippets` (free: the DMS state writer is broken upstream, so no persisted state existed under the old id).
- `:s -name` delete mode (`trash`, empty-name guarded) and the >64 KB scan cap (framed `TOO_LARGE` markers, content never loaded into QML) — both shipped in the SystemNix tree 2026-10-16 before extraction.
- Save flow chmods snippets to 0600 (clipboard content can carry secrets).
- `flake.lib.patchDms`, `homeModules.dms-paste`, `checks.module-contract`, `checks.patch-contract` (build-time harness for the drift guards — previously they only fired at consumer deploy time).
