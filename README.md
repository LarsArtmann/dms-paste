# dms-paste

[![check](https://github.com/LarsArtmann/dms-paste/actions/workflows/check.yml/badge.svg)](https://github.com/LarsArtmann/dms-paste/actions/workflows/check.yml)

PasteBot-style paste workflow for [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) (Quickshell) on NixOS: clipboard history that pastes directly into the focused window, a denser/cleaner clipboard modal, and a snippets launcher — all declarative, all composable.

Extracted from [SystemNix](https://github.com/LarsArtmann/SystemNix) (2026-10-16) where it was built as a [PasteBot](https://pastebot.app) (macOS) replacement to unblock a full NixOS switch.

## What you get

1. **Snippets launcher plugin** (`:s` trigger) — one `.txt` file per snippet in `~/.local/share/snippets`:
   - `:s query` — fuzzy-search snippets, Enter pastes into the focused window, Shift+Enter copies without pasting
   - `:s > name` — save the live clipboard as a new snippet (owner-only perms, 0600)
   - `:s -name` — list matches, Enter moves one to the desktop trash (never `rm`)
   - Files >64 KB are listed as inert "too large" hints, never loaded into QML
2. **Clipboard-history parity settings** — Enter/click on a history entry pastes it directly (DMS synthesizes Ctrl+V over the compositor's `zwp_virtual_keyboard_manager_v1`; verified against source 2026-10-17, links pinned to commit: [DMS `core/internal/clipboard/pastekey.go`](https://github.com/AvengeMedia/DankMaterialShell/blob/3674d0f4807dc689e8e10ade22142b0f92da2495/core/internal/clipboard/pastekey.go#L20-L64) + [niri `VirtualKeyboardManagerState`](https://github.com/YaLTeR/niri/blob/45739bc072f9875a674d335ae724f10d3b35c665/src/niri.rs#L2577) — re-verify on DMS/niri major releases), `maxHistory` raised to 100k, minimal per-row chrome
3. **Clipboard-modal density patches** (`lib.patchDms`) — no per-row "Text" captions, two preview lines, 880x620 modal, denser rows; build-time grep guards fail the build when upstream QML drifts

## Requirements

- DankMaterialShell's home-manager module imported in the same closure (this flake only assigns into `programs.dank-material-shell.*` and fails eval loudly without it)
- A compositor exposing `zwp_virtual_keyboard_manager_v1` (niri does — see the source links above)
- `trash` on `$PATH` (delete mode)

## Usage

```nix
{
  inputs = {
    dms-paste.url = "github:LarsArtmann/dms-paste";
    dankMaterialShell.url = "github:AvengeMedia/DankMaterialShell"; # or your pinned fork/ref
  };

  # in your home-manager config:
  imports = [ inputs.dms-paste.homeModules.dms-paste ];
  programs.dms-paste.enable = true;

  # optional: patch the clipboard modal (compose with your own overrides)
  programs.dank-material-shell.package =
    inputs.dms-paste.lib.patchDms pkgs
      inputs.dankMaterialShell.packages.${pkgs.system}.default;
}
```

All settings the module wires are `mkDefault` — override any of them (`clipboardEnterToPaste`, `clipboardSettings.maxHistory`, …) without fighting merge priority. The one option this repo owns is `programs.dms-paste.snippetsDir` (default `~/.local/share/snippets`).

Wire the pickers to your compositor's binds:

| Bind (SystemNix) | Action                                                |
| ---------------- | ----------------------------------------------------- |
| `Mod+Shift+V`    | `dms ipc call clipboard toggle` — clipboard history   |
| `Mod+Shift+C`    | `dms ipc call spotlight toggleQuery ":s"` — snippets  |
| `Mod+Ctrl+C`     | `dms ipc call spotlight toggleQuery "="` — calculator |

## Known upstream limitation

DMS ≤ 1.6.3 has a broken plugin-state writer ([upstream issue #3611](https://github.com/AvengeMedia/DankMaterialShell/issues/3611), fixed by [PR #3733](https://github.com/AvengeMedia/DankMaterialShell/pull/3733); both verified 2026-10-17): snippet recency ordering is session-scoped in-memory until the host pins a DMS revision past the fix.

An honest feature-by-feature status lives in [FEATURES.md](FEATURES.md); direction and raw ideas in [ROADMAP.md](ROADMAP.md).

## Development

```bash
nix develop      # pinned dprint + nodejs + qmllint on PATH (what the checks use)
nix flake check  # module-contract + patch-contract (real build of the drift guards) + formatting + dprint + features-counts + plugin-logic + qml-preflight
nix fmt          # nix files (treefmt)
dprint fmt       # json/yaml/markdown/dockerfile (from the devShell)
node tests/plugin-logic/run-tests.mjs plugins/snippets/SnippetsLogic.js  # plugin logic harness
tests/qml-preflight.sh plugins/snippets                                        # QML parse preflight
```

CI runs `nix flake check` on every push and pull request (SHA-pinned actions, superseded runs cancelled, runner pinned to `ubuntu-24.04`).
