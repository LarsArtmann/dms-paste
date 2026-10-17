# Status Report — Execution Sweep + Self-Review

**Date:** 2026-10-17 06:05 CEST
**Session:** Full execution of the Pareto master plan (P1–P4) from `docs/planning/2026-10-17_02-09_pareto-master-plan.md`, followed by this self-critical review.
**End state:** `nix flake check` exit 0 locally; CI green on the final pushed commit `bd33755`; master pushed; tag `v1.1.0` on remote.
**Format note:** `.md` at the user's explicit demand (status-report skill default is HTML; user instruction wins).

Commits this session: `782b857` (CI workflow + badge, manual) → tag `v1.1.0` → `a52a7d0`/`9d7b9d5`/`57e2168` (daemon auto-commits carrying most of the sweep) → `bd33755` (final gate fix, manual).

---

## a) FULLY DONE

| #  | Item                                            | Evidence                                                                                                                                                                                                                                                                                                                                                               |
| -- | ----------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1  | **M2 — CI workflow**                            | `.github/workflows/check.yml` (nix-installer-action v23, push+PR, x86_64-linux, 30-min timeout, `permissions: {}`); two green runs: `38999703334` (on `782b857`), `39000821623` (on `bd33755`); badge in README                                                                                                                                                        |
| 2  | **M1 — tag v1.1.0**                             | Annotated tag from CHANGELOG 1.1.0, pushed, verified via `git ls-remote --tags`; CHANGELOG "no git tags yet" preamble rewritten                                                                                                                                                                                                                                        |
| 3  | **M3 — dprint gate** (`checks.dprint`)          | Hermetic: plugin URLs from `dprint.json` swapped for `fetchurl` store paths (4 hashes pinned in `flake.nix` `dprintCheck`); generated config self-formatting issue found and fixed; green in `nix flake check`                                                                                                                                                         |
| 4  | **M4 — devShell**                               | `devShells.default` with pinned dprint 0.61.1; verified `nix develop -c dprint --version` and idempotent `dprint check`; README Development section documents the full suite                                                                                                                                                                                           |
| 5  | **M5 — zwp claim verified**                     | DMS: `core/internal/clipboard/pastekey.go` + `core/internal/proto/virtual_keyboard/virtual_keyboard.go` (`zwp_virtual_keyboard_manager_v1` const). niri: shallow-cloned, `VirtualKeyboardManagerState::new` at `src/niri.rs:2576-2577`. README carries links + re-verify cadence note. Temp clones trashed (never `rm`)                                                |
| 6  | **M6 — counts gate** (`checks.features-counts`) | Re-derives FEATURES counts from the table; derivation self-tests by rejecting a doctored copy; sed leg updated for the new counts line                                                                                                                                                                                                                                 |
| 7  | **M9 — plugin-logic harness**                   | `plugins/snippets/SnippetsLogic.js` (slugify, score, parseScanRecords, recencyCompare, updatedRecents — moved verbatim); `SnippetsLauncher.qml` rewired to `import "SnippetsLogic.js" as Logic` (7 call sites, extraction verified by grep); `tests/plugin-logic/run-tests.mjs` — **32 assertions**, all passing; wired as `checks.plugin-logic`, green in flake check |
| 8  | **M10 — status index**                          | `docs/status/README.md` (this report adds itself as row 2)                                                                                                                                                                                                                                                                                                             |
| 9  | **M20 — daemon commit review**                  | Reflog: `497f1f9` is `commit (amend)` of `676a97c` 2 min later — identical tree `2bccab9`, message rewritten + re-signed. Benign self-amend; history trustworthy                                                                                                                                                                                                       |
| 10 | **M18 — D3 executed (keep)**                    | Decision recorded in `docs/DOMAIN_LANGUAGE.md` header                                                                                                                                                                                                                                                                                                                  |
| 11 | **Docs sync**                                   | TODO_LIST 8→3 rows; FEATURES 12→13 rows with counts line + re-anchored `file:line` evidence for the shifted QML lines; CHANGELOG `## Unreleased`; AGENTS Verification + Layout sections; README badge/dev/verified-claims                                                                                                                                              |

## b) PARTIALLY DONE

1. **M7 — recents persistence**: collapsed to watch-mode, correctly. PR #3733 merged upstream 2026-10-09 but latest release v1.6.3 (2026-10-07) predates it; TODO row now carries the merge/release facts + re-check cadence. Restoration itself NOT done (externally gated). **→ TODO_LIST (recents persistence row)**
2. **M8 — demo GIF**: deferred `[blocked:human]` with concrete recording steps in TODO_LIST. No asset exists. **→ TODO_LIST (demo asset row)**
   ~~3. **M19 — docs re-audit**: plan gates it on "next feature ship"; the harness arguably qualifies. Only an implicit light consistency pass happened (during doc sync), not a formal re-audit against the 7.0/5.5 baseline.~~ done at `5fb5080`
3. **QML rewiring runtime verification**: the logic is node-tested, but `import "SnippetsLogic.js" as Logic` inside DMS's plugin loader has never executed in a live session. Static review + grep only. This is the session's **highest-risk unverified change** — it touches the daily driver. **→ TODO_LIST (live-DMS verification row)**

## c) NOT STARTED

- P5 backlog (all plan-gated): M11 upstream modal-density PR, M12 placeholders, M13 categories, M14 edit-in-place, M15 profiles, M16 trigger option, M17 DMS-collection proposal **→ routed — ROADMAP (upstream convergence + snippet richness themes)**
- ROADMAP open question 5.9 (paste-only vs more plugins) — user decision **→ routed — ROADMAP (Open questions)**
- aarch64 CI leg (deferred with an inline note in the workflow) **→ routed — ROADMAP (verification depth)**
- ~~GitHub Release object for v1.1.0 (tag only; no Release with rendered notes)~~ done at `5fb5080`

## d) TOTALLY FUCKED UP!

1. **Masked verification, twice.** I "verified" the counts gate with `nix build … | tail -2 && echo "GREEN"` — the pipe masks nix's exit code, my echo is unconditional, and the output showed **no store path** (the tell I missed). The gate was actually RED: the awk script never set `FS="|"`, so statuses were parsed from the feature column. A broken gate passed my verification twice before a direct `bash tests/features-counts.sh` exposed it. Same class struck again with the sandbox shebang (exit 126, `/usr/bin/env` absent) and once more with a `PIPESTATUS`-after-`grep` echo. Three instances of one sloppiness: **I trusted ceremony over exit codes.**
2. **False precision in my summary.** I claimed "33 node tests"; the actual count is **32**. Small, but it is exactly the unverified-claim class this repo's docs philosophy forbids.
3. **Daemon swallowed the milestone commits.** The enforcement trio + harness landed in three `chore: auto-commit N changed file(s) (heuristic)` commits; only CI and the final fix got real messages. I had commit authorization for plan execution and didn't use it per-milestone — history readability paid for it.
4. **No runtime check exists for the QML import.** Not a defect yet — but shipping a daily-driver plugin change with zero static QML validation (no qmllint preflight anywhere) is a process failure I noticed only after the fact.

## e) WHAT WE SHOULD IMPROVE

- **Verification discipline:** never `cmd | tail && echo VERDICT`; redirect to a file, read `$?` directly. (Adopted from the third failure onward this session; make it permanent.)
- **Milestone commits before daemon sweeps** — explicit messages per logical unit.
- **README evidence links:** use line-anchored permalinks to commit SHAs, not `blob/main` (rot-prone; the cadence note mitigates but permalinks are strictly better). — ~~done at `5fb5080`~~
- **Counts self-test coupling:** the flake sed leg hardcodes the literal counts text (`— 12 FULLY_FUNCTIONAL`); every future counts change must touch `flake.nix` too, and forgetting it yields a confusing failure. Make the doctoring regex-based. — ~~done at `5fb5080`~~
- **CI hardening:** pin actions to commit SHAs, add a cancel-in-progress concurrency group, decide the runner pin before GitHub's ubuntu-latest → Ubuntu 26 migration (2026-10-19). — ~~done at `8b2c10d`~~
- **QML static validation:** a qmllint/syntax preflight (devShell or CI) would de-risk every future plugin edit. — ~~done at `8b2c10d`~~
- **Ghost systems:** none found — every new check is wired into `flake check`; nothing dead was created.
- **Split brains found (small, guarded):** dprint plugin URLs (dprint.json) vs hashes (flake.nix) — guarded by loud eval failure; counts sed vs counts line — see above; plan snapshot vs living TODO — by design.

## f) Next up to 50 (30 real ones, sorted by impact)

1. **Reload DMS on the daily driver and confirm `:s` loads + pastes** (rollback: revert the SnippetsLauncher.qml rewiring to inline logic) **→ TODO_LIST (live-DMS verification row)**
2. M7: recheck DMS releases on the next announcement; when a post-#3733 cut ships: bump pin, re-add `savePluginState`, verify the state file lands **→ TODO_LIST (recents persistence row)**
   ~~3. Pin GitHub Actions to commit SHAs (checkout, nix-installer)~~ done at `8b2c10d`
   ~~4. Add CI concurrency group (cancel-in-progress on master pushes)~~ done at `8b2c10d`
   ~~5. Decide runner strategy before 2026-10-19 (pin `ubuntu-24.04` or accept migration)~~ done at `8b2c10d`
3. Add aarch64 eval leg to CI **→ ROADMAP (aarch64)**
   ~~7. M19: formal docs re-audit vs the 7.0/5.5 baseline~~ done at `5fb5080`
   ~~8. Create a GitHub Release for v1.1.0 (rendered tag notes)~~ done at `5fb5080`
   ~~9. qmllint/QML-syntax preflight for `plugins/snippets/*.qml`~~ done at `8b2c10d`
   ~~10. Decouple the counts self-test from literal counts text~~ done at `5fb5080`
   ~~11. Permalink + line-anchor the README source-evidence links~~ done at `5fb5080`
   ~~12. Verify the CI badge URL returns 200 (one fetch)~~ done — badge URL returns 200 "passing" (fetched 2026-10-17)
   ~~13. Add nodejs to the devShell (harness iteration without `nix build`)~~ done at `8b2c10d`
4. Fuzz `parseScanRecords` round-trip with random content incl. separator bytes **→ TODO_LIST (fuzz parseScanRecords row)**
5. M8: record the demo GIF (human) — or decide to drop the idea **→ TODO_LIST (demo asset row)**
6. M11: upstream modal-density settings PR **→ ROADMAP (modal-density PR)**
7. M12: snippet placeholders (`{clipboard}`, `{date}`) **→ ROADMAP (placeholders)**
8. M13: categories via subdirectories **→ ROADMAP (categories)**
9. M16: trigger as a module option (`:s` configurable) **→ ROADMAP (trigger option)**
10. M14: edit-in-place via `$EDITOR` + rescan **→ ROADMAP (edit-in-place)**
11. M15: multiple snippet directories / profiles **→ ROADMAP (profiles)**
12. M17: propose the plugin for the DMS bundled collection **→ ROADMAP (bundled-collection idea)**
13. Upstream watch: `itemHeight`/`previewLines`/`showTypeCaptions` settings keys (retire patch legs) **→ TODO_LIST (modal-layout watch row)**
14. ROADMAP 5.9: stay paste-only or grow more plugins? (user) **→ ROADMAP (open questions — paste-only?)**
15. Counts gate: also assert the "No BROKEN, no DISABLED" sentence matches zero counts **→ TODO_LIST (counts-gate sentence row)**
    ~~26. Define the version-bump ritual for `plugin.json` + CHANGELOG on the next release~~ done — version-bump ritual defined in AGENTS.md "Release ritual" (2026-10-17)
16. Cover the thin `trackRecent` QML wrapper (it delegates to tested logic, but the wiring itself is untested) **→ ROADMAP (verification depth — trackRecent instance)**
    ~~28. Make status-index upkeep explicit (each new report adds its own row — I did it manually here)~~ done — convention line added to docs/status/README.md (2026-10-17)
17. Decide on buildflow/pre-commit coverage for this repo (currently daemon-only) **→ ROADMAP (open questions — BuildFlow adoption)**
18. JSDoc the SnippetsLogic.js exports (in-QML editor ergonomics) **→ TODO_LIST (JSDoc row)**

## g) Questions I cannot answer myself

1. **Did the plugin survive the extraction?** Will you reload DMS (or rebuild/switch) and confirm `:s` still searches, saves, pastes? I cannot exercise a live compositor session from the repo — and this is the one change that touches your daily workflow. **→ TODO_LIST (live-DMS verification row)**
   ~~2. **CI hardening: now or minimal-until-consumer?** Pin SHAs + concurrency + runner pin this week, or keep the workflow minimal until the first external consumer appears (the same convention that originally deferred CI itself)?~~ done at `8b2c10d`
2. **M8 demo GIF: record, semi-automate, or drop?** Record it yourself (~10 min), have me prepare a scripted capture sequence (grim + `dms ipc` calls) for you to run in-session, or drop the asset idea? **→ TODO_LIST (demo asset row)**

---

_Report basis: this session's work only (per instruction). Living state: TODO_LIST.md (3 open + harvested rows), FEATURES.md (13, gate-enforced), CHANGELOG.md (Unreleased)._
