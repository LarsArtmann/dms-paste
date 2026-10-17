# Status Report — docs-health AUDIT (full pass)

**Date:** 2026-10-17 02:05 CEST
**Scope:** This session only — execution of the `docs-health` skill (BUILD + HARVEST + VERIFY + cross-file consistency) over all living docs of dms-paste. No unrelated research.
**Repo state at write time:** branch `master`, working tree clean except this report; `nix flake check` green; dprint + treefmt clean.
**Session health verdict (as-found, first audit — no baseline):** Accuracy 7.0/10, Fitness 5.5/10. All findings fixed in-audit.

---

## a) FULLY DONE

1. **Full docs-health AUDIT executed** — every project file read (all QML, all nix, fixtures, plugin.json, dprint.json, .gitignore, .config/metadata.yaml, git log/tags/status). No file skipped.
2. **FEATURES.md built from code** — 12 rows, one per user-visible feature, dedicated Evidence column with `file:line` for every claim, honest verification-basis preamble (nix checks are contractual; QML status rests on SystemNix daily-driver provenance). Counts computed 2026-10-17: 10 FULLY_FUNCTIONAL, 1 PARTIALLY_FUNCTIONAL, 1 PLANNED.
3. **ROADMAP.md built** — 3 themes (upstream convergence, snippet richness, verification depth), 1 open question, 4 explicit non-goals encoding the hard rules as direction. Zero bounded tasks (vision only).
4. **docs/DOMAIN_LANGUAGE.md built** — 14-term glossary (snippet, trigger, save/delete mode, recents, paste synthesis, framed scan, drift guard, patch anchor, `mkDefault` baseline, …), each term mapped to where it lives in code.
5. **README.md fixed** — the usage snippet previously referenced `inputs.dankMaterialShell` without declaring it (failed verbatim on a clean machine); now declares both inputs and runs as written. Also: documents the repo's one owned option (`programs.dms-paste.snippetsDir`), links FEATURES/ROADMAP.
6. **External upstream claims verified by live fetch (2026-10-17)** — issue #3611 ("Plugin state: first save after reload fails on FileView.loaded.connect") and PR #3733 ("plugins: write the first state save after a reload") both exist and match the docs' claims; hyperlinks + verify date added to README, FEATURES, TODO_LIST.
7. **AGENTS.md fixed** — "Open items" section (TODO content leak, drift risk) replaced with pointers-only "Current work"; drift-guard mechanics described precisely (positive `grep -q` on every leg, negative guard only where a match alone is weak); dprint formatting path added; file is a lean 2.1 KB.
8. **TODO_LIST.md fixed** — header now points at the existing ROADMAP; every item carries `file:line` evidence and upstream links. All 3 items verified genuinely open against code.
9. **CHANGELOG.md fixed** — Keep-a-Changelog `### Added` structure; the no-git-tags state documented explicitly (versions continue SystemNix numbering; flake consumed by revision).
10. **Cross-file consistency pass** — status triangle consistent (FEATURES #5 PARTIALLY ↔ README limitation ↔ TODO item 1; FEATURES #12 PLANNED ↔ TODO item 2); no TODO/CHANGELOG duplication; every internal link resolves (checked mechanically).
11. **Quality gate** — baseline `nix flake check` green before edits, green after; `nix fmt` (treefmt) 0 changes; dprint formatted 4 files.
12. **Inline health report delivered** with visible math per the skill's format.

## b) PARTIALLY DONE

~~1. **Claim verification** — internal claims: fully verified against code. External claims: #3611/#3733 verified by fetch; the `zwp_virtual_keyboard_manager_v1` protocol name and "works on niri" remain provenance-corroborated only (DMS-side behavior, not checkable from this repo's code).~~ done at `a52a7d0`
~~2. **Formatting enforcement** — docs were formatted once (dprint + treefmt), but nothing _gates_ non-nix formatting afterwards: `nix flake check` runs treefmt (nixfmt + statix) only; dprint is not wired into any check and not even pinned (invoked via `nix run nixpkgs#dprint`).~~ done at `a52a7d0`
~~3. **Doc-number freshness** — FEATURES counts are hand-computed with a date stamp; no standing gate re-derives them (the docs-health principle "standing gate beats hand-maintained counts" is honored in spirit, not in mechanism).~~ done at `a52a7d0`, `5fb5080`
~~4. **Docs loop closure** — this report's section (f) items are being routed to TODO_LIST/ROADMAP (see harvest note below), but three routing decisions are user-gated (see questions).~~ done at `782b857`, `57e2168`

## c) NOT STARTED (known, deliberately)

~~1. CI workflow (`.github/` does not exist — verified).~~ done at `782b857`
~~2. Git tag for v1.1.0 (release action, user's call).~~ done at `782b857`
~~3. Standing gates for non-nix formatting and doc counts.~~ done at `a52a7d0`
~~4. QML pure-function test harness (ROADMAP: verification depth).~~ done at `9d7b9d5`
5. Upstream contributions (modal-density settings PR; plugin into DMS bundled collection). **→ ROADMAP (upstream convergence theme)**
6. Snippet richness features (placeholders, categories, edit-in-place, profiles). **→ ROADMAP (snippet richness theme)**
~~7. docs/status/ index convention (this is report #1 in this repo).~~ done at `57e2168`

## d) TOTALLY FUCKED UP

Nothing permanently damaged. Honest defects, all self-inflicted and all caught in-session:

1. **I introduced a TODO/ROADMAP split-brain mid-BUILD** — the ROADMAP "Upstream convergence" theme restated TODO item 1 (restore recents persistence) as a theme bullet. My own cross-file pass caught it; removed before finishing. The check worked, but I authored the defect in the same pass that was supposed to prevent it.
2. **Scope creep via formatter** — repo-wide `dprint fmt` reindented `plugins/snippets/plugin.json` (4-space → 2-space), a runtime artifact outside the doc-task scope. Semantically identical (JSON is indent-insensitive) and canonical per dprint.json, but unflagged at the time. The auto-commit daemon then committed it inside `de73957`.
3. **Typo shipped then fixed** — wrote "hand-curaten" into AGENTS.md; caught and fixed same session.
4. **Wasted tool calls chasing a phantom** — queried `git diff plugins/snippets/plugin.json` three times with empty output because the auto-commit daemon committed mid-inspection; should have re-checked `git status`/`git log` after the first empty diff instead of retrying with pager variants.

## e) WHAT WE SHOULD IMPROVE

~~1. **Formatting gate asymmetry** — markdown/json/yaml have a config (dprint.json) but no enforcement; nix has enforcement (treefmt via flake check). One shape, two standards.~~ done at `a52a7d0`
~~2. **No devShell** — the flake exposes packages/checks/formatter but no dev shell; contributors get no pinned dprint/nix toolchain.~~ done at `a52a7d0`
~~3. **Standing gates over hand counts** — FEATURES.md's "12 features — 10/1/1" line will rot at the first feature addition.~~ done at `a52a7d0`, `5fb5080`
~~4. **External-claim cadence** — README says "verified 2026-10-17" but states no re-verify cadence; upstream DMS releases will silently age these claims.~~ done at `a52a7d0`
~~5. **AGENTS.md "Current work" pointers section** — defensible, but the strictest reading of the docs-health ownership matrix says even pointer sections drift; candidate for removal at next audit.~~ **Won't implement — removal rejected — the pointers section is the endorsed High-Value References pattern.**
6. **QML behavior is provenance-dependent** — FULLY_FUNCTIONAL statuses rest on SystemNix daily use; no in-repo way to re-exercise the plugin (the ROADMAP verification-depth theme is the fix). **→ ROADMAP (verification depth) + TODO_LIST (live-DMS row)**
~~7. **Untagged version** — CHANGELOG 1.1.0 matches plugin.json 1.1.0 but no git tag exists; the version is aspirational until tagged.~~ done at `782b857`
~~8. **Unindexed status reports** — docs/status/ now exists with one file; at ~3 reports an index becomes necessary (mechanically gated in sibling repos, manual here).~~ done at `57e2168`

## f) Next things to get done (22, ranked by impact; routing state marked)

| #                                           | Task                                                                                                                     | Routed                            |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | --------------------------------- |
| ~~1~~ done at `782b857`                     | ~~Decide + execute tag policy for v1.1.0 (user decision)~~                                                               | ~~question g1~~                   |
| ~~2~~ done at `782b857`                     | ~~Decide CI timing: now vs first-external-consumer convention (user decision)~~                                          | ~~question g2~~                   |
| ~~3~~ done at `57e2168`                     | ~~Decide DOMAIN_LANGUAGE.md keep/drop (user decision)~~                                                                  | ~~question g3~~                   |
| ~~4~~ done at `a52a7d0`                     | ~~Wire a dprint formatting check into `flake.checks` (close the non-nix gate gap)~~                                      | ~~TODO (new)~~                    |
| ~~5~~ done at `782b857`                     | ~~CI workflow: `nix flake check` on push, incl. `--all-systems` for aarch64~~                                            | ~~TODO (existing)~~               |
| 6 **→ TODO_LIST (recents persistence row)** | Restore recents persistence once DMS past PR #3733 is consumable                                                         | TODO (existing, blocked upstream) |
| 7 **→ TODO_LIST (modal-layout watch row)**  | Watch upstream `itemHeight`/`previewLines`/`showTypeCaptions` keys; retire patch legs per-key                            | TODO (existing)                   |
| ~~8~~ done at `a52a7d0`                     | ~~Add a devShell with pinned formatters (dprint via nix)~~                                                               | ~~TODO (new)~~                    |
| ~~9~~ done at `a52a7d0`                     | ~~Verify `zwp_virtual_keyboard_manager_v1` + niri claim against DMS source; add cadence note~~                           | ~~TODO (new)~~                    |
| 10 **→ TODO_LIST (demo asset row)**         | README demo asset (GIF/screenshot of `:s` flow)                                                                          | TODO (new)                        |
| ~~11~~ done at `a52a7d0`                    | ~~Mechanize FEATURES.md counts (tiny check leg) or drop the count line~~                                                 | ~~TODO (new)~~                    |
| ~~12~~ done at `9d7b9d5`                    | ~~QML pure-function test harness (scoring, slugify, framing round-trip)~~                                                | ~~ROADMAP~~                       |
| 13 **→ ROADMAP (upstream convergence)**     | Upstream PR: modal-density settings for DMS                                                                              | ROADMAP                           |
| 14 **→ ROADMAP (bundled-collection idea)**  | Propose snippets plugin for DMS bundled collection                                                                       | ROADMAP                           |
| 15 **→ ROADMAP (placeholders)**             | Placeholders in snippet bodies (`{clipboard}`, `{date}`)                                                                 | ROADMAP                           |
| 16 **→ ROADMAP (categories)**               | Categories via subdirectories / filename conventions                                                                     | ROADMAP                           |
| 17 **→ ROADMAP (edit-in-place)**            | Edit-in-place via `$EDITOR` + rescan                                                                                     | ROADMAP                           |
| 18 **→ ROADMAP (profiles)**                 | Multiple snippet directories / profiles                                                                                  | ROADMAP                           |
| 19 **→ ROADMAP (trigger option)**           | Expose `trigger` as a module option (idea)                                                                               | ROADMAP (new fuel)                |
| ~~20~~ done at `57e2168`                    | ~~docs/status/ README index once ≥3 reports~~                                                                            | ~~deferred~~                      |
| ~~21~~ done at `1197c32`                    | ~~Review daemon commit `497f1f9` (scaffolding commit message/hash changed from `676a97c` mid-session — history amend?)~~ | ~~observation~~                   |
| ~~22~~ done at `5fb5080`                    | ~~Re-audit docs after next feature lands (Accuracy/Fitness baseline now exists)~~                                        | ~~deferred~~                      |

## g) Questions I can NOT figure out myself

~~1. **Tag v1.1.0 now?** No git tags exist; CHANGELOG + plugin.json both say 1.1.0 and the flake is consumed by revision. Tagging is a release action I won't take unilaterally — should I tag, and is 1.1.0 the right number to start tags from?~~ done at `782b857`
~~2. **CI now or later?** TODO says "add when the repo sees its first external consumer" (sibling convention). You are the only consumer today — do you want the workflow now anyway (cheap, catches drift early) or hold the convention?~~ done at `782b857`
~~3. **Keep docs/DOMAIN_LANGUAGE.md?** I judged yes (domain-heavy vocabulary: framed scan, drift guards, paste synthesis) and scored Fitness accordingly. It is 5.8 KB of maintenance surface on a 1-day-old repo — drop it if you want maximal leanness, and I'll re-point AGENTS.md.~~ done at `57e2168`

---

**Harvest note:** items 4, 8–11 of section (f) are new bounded tasks routed into TODO_LIST.md by this same session (the status-report skill's loop-closure rule); 1–3 are user-gated; 12–19 were already routed or are routed into ROADMAP.md as raw ideas. Future sessions: harvest from THIS file only if TODO_LIST/ROADMAP lack an item — check first, most are routed.
