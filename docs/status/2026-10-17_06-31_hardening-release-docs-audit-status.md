# Status Report: CI Hardening, QML Preflight, v1.1.0 Release, M19 Docs Re-audit

**Session:** 2026-10-17 ~06:05–06:31 CEST · **Head at report time:** `5fb5080` (pushed, CI green run `39002353858`)
**Scope of this report:** this session's execution sweep only — what was done, what went wrong in-flight, what was noticed. No new research beyond it.
**Prior report in series:** [2026-10-17 06-05 execution-sweep self-review](2026-10-17_06-05_execution-sweep-self-review.md) — its three open questions are re-asked in §g (still unanswered).

---

## a) FULLY DONE

1. **CI hardening** (TODO row "CI hardening", done) — `actions/checkout` and `nix-installer-action` pinned to commit SHAs _verified against the upstream tag objects via `gh api /git/ref/tags`_ (checkout v7.0.1 = `3d3c42e5…`, nix-installer v23 = `3138316d…`); cancel-in-progress concurrency group `check-${{ github.ref }}`; runner pinned `ubuntu-24.04` ahead of the announced ubuntu-latest → Ubuntu 26.04 migration (2026-10-19) with the rationale as a workflow comment. The checkout bump appeared as an unexplained working-tree change at session start — it was verified genuine rather than reverted. Evidence: `.github/workflows/check.yml`, CI run `39002353858` success.
2. **QML syntax preflight** (TODO row "QML syntax preflight", done) — `tests/qml-preflight.sh` + `checks.qml-preflight`: qmllint over every `plugins/snippets/*.qml` with type resolution disabled (`--import/--missing-type/--missing-property/--unqualified/--unresolved-type disable` — Quickshell types only resolve in a live shell). Flag recipe validated empirically _before_ wiring: clean files exit 0, injected syntax error exits 255, minimal QtQuick file exits 0. The check carries a prove-it-bites self-test leg (doctored `Broken.qml` must fail), mirroring the features-counts gate design. Evidence: both plugin QML files parse clean in `nix flake check`; FEATURES row 14 added.
3. **Counts-gate decoupling** (TODO row "gate/doc hygiene", ⅓) — the `features-counts` self-test no longer seds literal counts text; it off-by-ones the declared total via awk arithmetic. Validated against the real FEATURES.md (doctored copy fails, clean copy passes) before the flake edit. Changing FEATURES counts no longer requires a matching flake edit.
4. **README evidence permalinks** (hygiene ⅓) — source links now commit-SHA line anchors: DMS `3674d0f4` `pastekey.go#L20-L64`, niri `45739bc0` `niri.rs#L2577`. Both files were downloaded at those exact SHAs and grep-matched (zwp manager check, `VirtualKeyboardManagerState::new`) — immune to upstream `main` drift.
5. **devShell** (hygiene ⅓) — nodejs (run the plugin-logic harness locally) and qtdeclarative (qmllint) added alongside the pinned dprint.
6. **GitHub Release v1.1.0** (TODO row, done) — published from the CHANGELOG 1.1.0 section with `--verify-tag`; tag resolves to `782b857` (first CI-verified commit); not a draft, not a prerelease. Notes state explicitly that the gate/harness sweep is unreleased and lands in the next tag.
7. **M19 docs re-audit** (TODO row, done) — full docs-health AUDIT (skill loaded; report printed inline per skill). As-found: **Accuracy 6.5/10, Fitness 10/10** (vs baseline 7.0/5.5). 8 findings, all fixed in-audit at `5fb5080`: 3 stale FEATURES `flake.nix` anchors (rows 8–10 pointed at pre-edit lines), 2 false SECURITY.md claims ("automated security scanning runs in CI", "code-reviewed before merge" — replaced with what the repo actually does), 1 README Development section understating the check suite (4 of 6 then-existing checks), 2 ROADMAP items (shipped harness idea lingering, "once CI exists" premise stale). Every FEATURES evidence anchor was re-verified line-by-line against the actual files (QML/JS/module/patch anchors all confirmed; only the flake.nix ones had drifted).
8. **Doc sync** — TODO_LIST: 5 completed rows deleted (now 4 rows, all externally blocked); CHANGELOG Unreleased gained 8 entries; AGENTS Layout+Verification updated (qml-preflight, nodejs/qmllint, CI hardening facts); FEATURES counts 13→14 features (13 FULLY_FUNCTIONAL) with the gate green.
9. **Verification posture** — `nix flake check` exit 0 with **7 checks** (module-contract, patch-contract, formatting, dprint, features-counts, plugin-logic, qml-preflight); format-first-then-check order; CI green on the pushed head.

## b) PARTIALLY DONE

1. **Docs drift prevention** — the drift is fixed, the _mechanism that allows it_ is not: FEATURES `file:line` evidence remains hand-maintained, and this session proved twice (the stale anchors I fixed, and the fresh `:227`→`:231` miss I committed myself, see d2) that edits+formatting shift lines silently. A standing anchor gate would close this; not built. Effort: M.
2. **QML verification depth** — parse-level only. qmllint with Quickshell qmltypes (real type checking) not attempted; runtime behavior still rests on the human-blocked live-DMS check. Effort: M/L for qmltypes.
3. **Concurrency cancellation** — the group is defined and syntactically valid, but this session's push carried both commits at once, so no run was ever superseded. The behavior is plausible-but-unobserved. Effort: S (verify next multi-push).

## c) NOT STARTED

1. aarch64 CI eval leg — documented-deferred (checks are eval/text contracts; comment in the workflow explains).
2. CI binary caching — no attic/magic-nix-cache; runs are currently fast enough that this wasn't worth complexity.
3. Release automation — tag-push → release-from-CHANGELOG workflow.
4. FEATURES anchor gate — see b1; designed in passing, zero code.
5. v1.2.0 cut — Unreleased is accumulating (CI, dprint, devShell, plugin-logic, features-counts, qml-preflight, hardening, doc fixes); no tag decision taken (question g2).
6. Quickshell qmltypes generation/integration for typed linting.

## d) TOTALLY FUCKED UP

_Nothing shipped broken — the product and all gates are green. This section is the honest inventory of in-flight process failures, all caught and corrected within the session:_

1. **CHANGELOG multiedit dropped two entries and duplicated a heading** — my edit replaced the old `### Changed` block wholesale, silently deleting the "README zwp verification" and "Tagged v1.1.0" entries while creating a second `### Added` section. Caught by immediate re-view, repaired one step later. Root cause: replacement-style edit without enumerating what the old_string carried — a direct violation of the "a replace that silently deletes memory is a loss" rule in my own global AGENTS.md. Severity if uncaught: release-history lie (v1.1.0 tagging entry gone from Unreleased).
2. **I committed the exact bug class the audit was fixing** — wrote `flake.nix:227` as the qml-preflight evidence anchor _before_ confirming the line (actual `:231`), in the same edit batch that fixed three stale anchors. Root cause: anchor derived from a pre-`nix fmt` grep; formatting shifted lines between grep and write. Fixed immediately; lesson encoded below (e1).
3. **`gh api -I` blunder** — used curl's `-I` grammar on gh (doesn't exist), dumped a wall of CLI help, then papered over it with "verified by construction" reasoning (which was true — the files had been downloaded and grepped at those SHAs — but the correct move was either a proper check or no check, not a failed one plus a rationalization).
4. **Audit grouping under-documented** — counted the FEATURES anchor drift as 3 separate Medium findings without recording the same-root-cause collapse consideration in the report; a reader cannot see why it wasn't 1 finding. Method transparency gap, not a scoring error.
5. **Near-overclaim on concurrency** — internal narration called the pending push "the first live test" of cancellation; the push shape made that false. The final message avoided repeating it, but also never stated cancellation remains unobserved — corrected here (b3).

## e) WHAT WE SHOULD IMPROVE

1. **Anchor discipline (process)** — write `file:line` evidence only after the final formatting pass (`nix fmt` + dprint) of the files being cited; never from a pre-format grep. This session's d2 failure mode is fully preventable by ordering.
2. **Standing anchor gate (mechanism)** — a check that greps the claimed symbol at every cited FEATURES evidence line (parse the Evidence column, assert the line contains the claimed token or a nearby symbol). Twice now (previous sweep's rows 8–10, my `:227`) hand-anchoring failed silently; gates > discipline.
3. **Changelog edit hygiene** — insert into sections, never replace whole sections; always re-view after multiedit on append-only files. (d1.)
4. **Tool grammar verification** — confirm flags exist for the tool actually invoked (gh ≠ curl). One wasted call, but the pattern "confident wrong invocation" is the expensive kind.
5. **Moving-target pins documentation** — qmllint (qt6.qtdeclarative) and nodejs ride `nixpkgs-unstable` via flake.lock. dprint gets hashes + a documented procedure; the qmllint/nodejs bump story ("a qt major may change lint categories/exit codes; CI will catch it — bump deliberately") deserves one AGENTS sentence.
6. **Release-notes polish** — v1.1.0 notes assume flake literacy; one "how to consume" line (the README usage block) costs nothing and serves first-time visitors.
7. **Scores history** — the status index says "compare against the baseline"; with three audit datapoints existing soon (02-05 baseline 7.0/5.5, this session 6.5/10 as-found), a tiny history table in `docs/status/README.md` makes the convention mechanical.

## f) Next tasks (22 real items — padded to 50 would manufacture noise; routing below into TODO_LIST/ROADMAP)

| #  | Task                                                                                         | Impact   | Effort    | Category      |
| -- | -------------------------------------------------------------------------------------------- | -------- | --------- | ------------- |
| 1  | Live-DMS reload verification of `:s` after SnippetsLogic extraction (rollback documented)    | Critical | S (human) | Verification  |
| 2  | Recheck DMS releases for a version past PR #3733 → restore recents persistence               | High     | S         | Feature       |
| 3  | Build the FEATURES evidence anchor gate (parse Evidence column, assert symbol at cited line) | High     | M         | Quality       |
| 4  | Document the nixpkgs/qt/node bump procedure in AGENTS (qmllint behavior moves with unstable) | Medium   | S         | Documentation |
| 5  | Verify concurrency cancellation on the next multi-commit push                                | Medium   | S         | Quality       |
| 6  | Consumer-shaped integration eval: module-contract against the real DMS HM module closure     | Medium   | M         | Quality       |
| 7  | Extend qml-preflight over `tests/fixtures/*.qml`                                             | Low      | S         | Quality       |
| 8  | Scores-history table in `docs/status/README.md`                                              | Low      | S         | Documentation |
| 9  | GitHub repo metadata polish (About description/topics)                                       | Low      | S         | Polish        |
| 10 | Decide + cut v1.2.0 (blocked on g2)                                                          | Medium   | S         | Release       |
| 11 | Demo GIF for README (blocked on g3)                                                          | Medium   | S (human) | Documentation |
| 12 | Modal-layout settings keys watch (retire patch legs if DMS ships them)                       | Medium   | S         | Watch         |
| 13 | After live-DMS verification: refresh FEATURES verification-basis wording                     | Medium   | S         | Documentation |
| 14 | Quickshell qmltypes + typed qmllint pass                                                     | Medium   | M/L       | Quality       |
| 15 | Release automation workflow (tag push → release from CHANGELOG)                              | Low      | M         | Infra         |
| 16 | Scheduled flake.lock refresh + green-check cadence                                           | Low      | S         | Infra         |
| 17 | aarch64 CI leg (only when an arch-dependent check appears)                                   | Low      | M         | Infra         |
| 18 | CI binary cache (only if run times grow)                                                     | Low      | S         | Infra         |
| 19 | Release-notes "how to consume" line for future releases                                      | Low      | S         | Polish        |
| 20 | SECURITY.md supported-versions row update on each release (note in release checklist)        | Low      | S         | Documentation |
| 21 | Tag convention note (semver vs continued SystemNix numbering)                                | Low      | S         | Documentation |
| 22 | `plugin.json` trigger (`:s`) as a module option (graduate from ROADMAP when wanted)          | Low      | M         | Feature       |

## g) Questions I cannot answer myself

1. **Did the plugin survive the live reload?** `:s` search/save/paste on your daily driver after the SnippetsLogic extraction — qmllint proves parse-clean and node proves the logic, but the QML `import "SnippetsLogic.js" as Logic` line has still never executed in a live Quickshell session. If it broke: reverting `SnippetsLauncher.qml` to inline logic is the documented rollback. Everything else this session sits behind this unverified runtime boundary.
2. **Cut v1.2.0 now or hold?** Unreleased carries six new checks + hardening + doc truth-fixes — real consumer value, zero user-facing behavior change. Tag now, or wait until something visible (e.g. recents restoration) ships?
3. **The GIF: record or drop?** It needs your compositor session; I cannot produce it. Record ~10 s (`Mod+Shift+C` → `:s > demo` → `:s dem` → Enter), or delete the TODO row and let the README stand text-first?

---

_Format note: `.md` at the user's explicit path/format demand, overriding this skill's HTML-canonical default (standing precedent from the 06-05 report). Section (f) routes to TODO_LIST/ROADMAP via docs-health HARVEST in the same session._
