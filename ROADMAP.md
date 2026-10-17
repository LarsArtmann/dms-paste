# Roadmap

Long-term direction and raw ideas. Unrefined by design — items graduate to
[TODO_LIST.md](TODO_LIST.md) only once they become bounded and actionable.
No status indicators here; this is vision, not inventory.

## Themes

### Upstream convergence

The patch surface (`patch.nix`) and the recents workaround exist because
upstream DMS lacks the knobs. Direction: shrink this repo as DMS grows them.

- Contribute modal-density settings (`itemHeight`, `previewLines`,
  `showTypeCaptions`, modal size) upstream so the sed/perl legs can retire
  one by one.
- Raw idea: if the snippets plugin stabilizes, propose it for DMS's bundled
  plugin collection — this repo then shrinks to settings + patches.

### Snippet richness

PasteBot-parity is the floor, not the ceiling. Ideas in rough fidelity order:

- Placeholders in snippet bodies (`{clipboard}`, `{date}`, cursor position)
  expanded at paste time.
- Organization: categories via subdirectories or filename conventions,
  rendered as launcher categories.
- Edit-in-place: an action that opens the snippet file in `$EDITOR` and
  rescans on close.
- Multiple snippet directories / profiles (work vs. personal).
- Raw idea: expose the launcher `trigger` (`:s`) as a module option instead
  of a plugin.json constant.

### Verification depth

- A QML-level harness that loads the plugin in a real Quickshell context
  (beyond the current node + parse-level checks) — needs fixture shell
  plumbing that does not exist yet. Stepping stone: generate/import
  Quickshell qmltypes so qmllint can do real type checking instead of
  parse-only.
- Cross-arch (`aarch64-linux`) check runs in CI — deferred while every
  check is an eval/text contract; revisit the moment an
  architecture-dependent check appears.

### Repo infrastructure

- Release automation: a tag-push workflow that cuts the GitHub Release from
  the CHANGELOG section.
- CI binary cache (attic or similar) if run times ever grow past trivial.
- Scheduled flake.lock refresh cadence (monthly?) with a green-check gate.

## Open questions

- Should this repo ever carry more DMS plugins, or is it strictly the
  paste workflow (name says paste)?

## Non-goals

- **No synthetic input tools** — never wtype/ydotool/uinput; paste synthesis
  stays on DMS's clipboard daemon + the compositor's virtual-keyboard
  protocol (hard rule, see AGENTS.md).
- **Not a clipboard manager** — DMS owns history; this repo only wires
  parity settings and the snippets plugin.
- **Nix-only consumption** — the flake + HM module is the single install
  path; no Homebrew, no manual copy instructions.
- **No servers, no cloud** — local files in `snippetsDir` are the storage
  model; no sync, no sharing.
