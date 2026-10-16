# Changelog

All notable changes to this project are documented here.

## 1.1.0 (2026-10-16)

- Extracted from SystemNix (`pkgs/dms-plugins/systemnix-snippets` + the clipboard-parity settings + the DMS clipboard-modal patches) into this standalone composable flake. Plugin id renamed `systemnix-snippets` → `paste-snippets` (free: the DMS state writer is broken upstream, so no persisted state existed under the old id).
- Added `:s -name` delete mode (`trash`, empty-name guarded) and the >64 KB scan cap (framed `TOO_LARGE` markers, content never loaded into QML) — both shipped in the SystemNix tree 2026-10-16 before extraction.
- Save flow chmods snippets to 0600 (clipboard content can carry secrets).
- `flake.lib.patchDms`, `homeModules.dms-paste`, `checks.module-contract`, `checks.patch-contract` (build-time harness for the drift guards — previously they only fired at consumer deploy time).
