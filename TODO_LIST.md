# TODO List

Short- and mid-term actionable tasks. Long-term ideas → README "Known upstream limitations" or a ROADMAP when one exists.

- [ ] [blocked:upstream] **Restore snippet recents persistence** — remove the in-memory `recentFiles` workaround in `SnippetsLauncher.qml` (re-add `savePluginState`) once a DMS release with PR #3733 (fix for issue #3611) is consumable; verify state lands in `~/.local/state/DankMaterialShell/plugins/paste-snippets_state.json`. **Source:** SystemNix docs/todo/upstream.md DMS-bump row (2026-10-16)
- [ ] [ready] **CI workflow** — `nix flake check` on push (offline-banner sibling predates CI; add when the repo sees its first external consumer). **Source:** extraction session 2026-10-16
- [ ] [watch] **Upstream modal-layout settings keys** — if DMS ships `itemHeight`/`previewLines`/`showTypeCaptions` settings, retire the corresponding `patch.nix` legs. **Source:** SystemNix docs/drafts/2026-10-16_dms-clipboard-modal-layout-settings.md
