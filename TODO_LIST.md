# TODO List

Short- and mid-term actionable tasks. Long-term ideas and raw concepts → [ROADMAP.md](ROADMAP.md).

- [ ] [blocked:upstream] **Restore snippet recents persistence** — remove the in-memory `recentFiles` workaround (`plugins/snippets/SnippetsLauncher.qml:36`, no `savePluginState` at `:131`) once a DMS release with [PR #3733](https://github.com/AvengeMedia/DankMaterialShell/pull/3733) (fix for [issue #3611](https://github.com/AvengeMedia/DankMaterialShell/issues/3611)) is consumable; verify state lands in `~/.local/state/DankMaterialShell/plugins/paste-snippets_state.json`. **Source:** SystemNix docs/todo/upstream.md DMS-bump row (2026-10-16)
- [ ] [ready] **CI workflow** — `nix flake check` on push; no `.github/` exists in the repo yet (verified 2026-10-17). Add when the repo sees its first external consumer (matches the offline-banner sibling convention). **Source:** extraction session 2026-10-16
- [ ] [watch] **Upstream modal-layout settings keys** — if DMS ships `itemHeight`/`previewLines`/`showTypeCaptions` settings, retire the corresponding `patch.nix` legs (`patch.nix:28`–`49`). **Source:** SystemNix docs/drafts/2026-10-16_dms-clipboard-modal-layout-settings.md
