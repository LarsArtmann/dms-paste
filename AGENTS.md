# dms-paste: Agent Guide

PasteBot-style paste workflow for DankMaterialShell (Quickshell): snippets launcher plugin (`:s`), clipboard-parity settings, and the DMS clipboard-modal patcher. Extracted from SystemNix 2026-10-16 (provenance: `docs/status/2026-10-16_02-15_pastebot-parity-clipboard-snippets-status.html` there).

## Hard rules

- **The plugin is QML running inside DMS** — never introduce wtype/ydotool/uinput; paste synthesis goes through `dms cl copy` + `dms cl send-paste` (the compositor's virtual-keyboard protocol).
- **`trash`, never `rm`** — delete mode must stay recoverable; keep the empty-name guard.
- **Every patch anchor is grep-guarded** — `patch.nix` sed/perl legs carry inline `grep -q` + negative guards; if upstream DMS text drifts, the build FAILS by design. Fix the anchors, never delete a guard.
- **Settings are `mkDefault`** — the module encodes a baseline, not a mandate. Consumers override.
- **`snippet content may carry secrets`** — the save flow chmods 600; never relax that.

## Layout

- `plugins/snippets/` — the DMS launcher plugin (contract: `getItems` / `executeItem` / `getPasteArgs`; storage: one `.txt` per snippet; `\x1e`/`\x1f`-framed async scan via `Quickshell.Io`)
- `module.nix` — HM module, parameterized over `pluginSrc` (imported via `homeModules.dms-paste`)
- `patch.nix` — `lib.patchDms pkgs dms` (composable `overrideAttrs`)
- `tests/fixtures/` — upstream-shaped Clipboard QML the `patch-contract` check builds against

## Verification

`nix flake check` — `module-contract` (eval), `patch-contract` (real build exercising every drift guard), `formatting`. Formatter: this repo's own treefmt (`nix fmt`), never ad-hoc alejandra/statix.

## Open items

See TODO_LIST.md — notably: restore `savePluginState` recents persistence once the consumer pins DMS past PR #3733; CI workflow not yet added (matches offline-banner sibling convention).
