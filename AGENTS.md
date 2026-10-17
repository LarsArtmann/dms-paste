# dms-paste: Agent Guide

PasteBot-style paste workflow for DankMaterialShell (Quickshell): snippets launcher plugin (`:s`), clipboard-parity settings, and the DMS clipboard-modal patcher. Extracted from SystemNix 2026-10-16 (provenance: `docs/status/2026-10-16_02-15_pastebot-parity-clipboard-snippets-status.html` there).

## Hard rules

- **The plugin is QML running inside DMS** — never introduce wtype/ydotool/uinput; paste synthesis goes through `dms cl copy` + `dms cl send-paste` (the compositor's virtual-keyboard protocol).
- **`trash`, never `rm`** — delete mode must stay recoverable; keep the empty-name guard.
- **Every patch anchor is grep-guarded** — each `patch.nix` leg ends in a `grep -q` positive assertion (plus a negative guard where a match alone is weak evidence); if upstream DMS text drifts, the build FAILS by design. Fix the anchors, never delete a guard.
- **Settings are `mkDefault`** — the module encodes a baseline, not a mandate. Consumers override.
- **`snippet content may carry secrets`** — the save flow chmods 600; never relax that.

## Layout

- `plugins/snippets/` — the DMS launcher plugin (contract: `getItems` / `executeItem` / `getPasteArgs`; storage: one `.txt` per snippet; `\x1e`/`\x1f`-framed async scan via `Quickshell.Io`)
- `plugins/snippets/SnippetsLogic.js` — the plugin's pure logic (scoring/slugify/framing/recency), imported by the QML and executed under node by `checks.plugin-logic`; keep it Qt-free and argument-pure
- `module.nix` — HM module, parameterized over `pluginSrc` (imported via `homeModules.dms-paste`)
- `patch.nix` — `lib.patchDms pkgs dms` (composable `overrideAttrs`)
- `tests/fixtures/` — upstream-shaped Clipboard QML the `patch-contract` check builds against
- `tests/plugin-logic/`, `tests/features-counts.sh`, `tests/qml-preflight.sh` — the node harness, the FEATURES counts gate, and the QML parse preflight (all wired as flake checks)

## Verification

CI runs `nix flake check` on every push/PR (`.github/workflows/check.yml`, x86_64-linux; actions pinned to commit SHAs, superseded runs cancelled, runner pinned to `ubuntu-24.04` ahead of the ubuntu-latest → Ubuntu 26.04 rollout). Dependabot opens weekly grouped PRs bumping those SHAs — verify a new SHA against the upstream tag object (`gh api /repos/<owner>/<repo>/git/ref/tags/<tag>`) before merging. Locally the same: `nix flake check` — `module-contract` (eval), `patch-contract` (real build exercising every drift guard), `formatting` (treefmt/nix), `dprint` (json/yaml/markdown/dockerfile, hermetic via store-path plugins), `features-counts`, `plugin-logic` (node), `qml-preflight` (qmllint parse gate). Nix files: this repo's own treefmt (`nix fmt`), never ad-hoc nixfmt/statix/alejandra. JSON/YAML/Markdown/Dockerfile: `dprint` (pinned in the devShell — `nix develop` — and in the check; plugin hashes live in `flake.nix` `dprintCheck`, add one there when bumping a plugin in `dprint.json`). `dprint.json` is auto-generated config — don't hand-curate it.

nixpkgs rides `nixpkgs-unstable` via flake.lock, and with it the qmllint (qt6.qtdeclarative) and nodejs the checks use: a qt major can change qmllint categories/exit codes (CI catches that) — bump flake.lock deliberately, never in passing.

## Release ritual

1. Bump `plugins/snippets/plugin.json` `version` and cut the matching CHANGELOG section in one commit (numbering continues the SystemNix sequence — see the CHANGELOG header).
2. Annotated tag `vX.Y.Z` from that section, push it.
3. GitHub Release with `--verify-tag`; notes = the CHANGELOG section plus the README usage block (a "how to consume" line for first-time visitors).
4. Move the SECURITY.md Supported Versions row to the new tag.

## Current work

Open tasks: TODO_LIST.md. Long-term direction and raw ideas: ROADMAP.md. Feature inventory with honest statuses: FEATURES.md. Domain vocabulary: docs/DOMAIN_LANGUAGE.md.
