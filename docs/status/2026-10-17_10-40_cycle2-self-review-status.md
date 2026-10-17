# Status 2026-10-17 10:40 — Cycle 2 self-review (what I forgot / did badly / should improve)

Scope: THIS session only — the full Pareto Cycle 2 execution ordered after the plan paste (v1.2.0 through final docs sync, commits `7abb91c`..`899a393`). Companion to the execution report [10-35](2026-10-17_10-35_pareto-cycle2-execution-sweep.md); this one answers the direct question: what did you forget, what could have been better, what still needs work.

## a) FULLY DONE

| Item                                                                                                                               | Evidence                                                                                                                                    |
| ---------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| Prior loose end: CI run `39014300041` on the plan commit verified green (session opener)                                           | `gh run list` at session start                                                                                                              |
| T1 — v1.2.0 cut end-to-end: bump, CHANGELOG section, green check ON the release commit, annotated tag, Release, SECURITY row       | [Release v1.2.0](https://github.com/LarsArtmann/dms-paste/releases/tag/v1.2.0); tag on `7abb91c`; ritual amended with the run's 3 learnings |
| T8 — concurrency cancellation observed live, first time ever                                                                       | run `39016361333` cancelled by `39016420378` (`check-<ref>` group)                                                                          |
| T3 — `checks.anchors` shipped strong: line/range/continuation/symbol-claim assertions + 2 doctored self-tests                      | first run caught 3 unanchored rows; negative tests prove stale-but-nonblank lines and bogus symbols FAIL                                    |
| T4 — counts-sentence assert (+ lying-sentence self-test) and qml-preflight over fixtures                                           | sentence leg doctors numbers-consistent/BROKEN-row and only the sentence can fail — it does; fixtures leg forced a truth-fix of the fixture |
| Fixture truth-fix — bare `switch` was never valid QML; now mirrors upstream v1.6.3 literally (16-space perl anchor intact)         | fetched real upstream `ClipboardEntry.qml@v1.6.3`; patch-contract green after reshaping                                                     |
| T5 — 1100-case deterministic fuzz (3 properties) + JSDoc on all 5 exports                                                          | `tests/plugin-logic/run-tests.mjs`; suite caught a bug in MY OWN test property (honest fuzz)                                                |
| T6 — consumer eval vs real DMS HM closure: ZERO stub-vs-real gaps (settings, clsettings, plugin_settings, source link, override)   | full homeManagerConfiguration eval output recorded in CHANGELOG + 10-35 report                                                              |
| T10 — `release.yml`: tag → section → notes → Release, from the tagged tree, fail-closed                                            | both dispatch legs: `v1.2.0` renders exact notes (run 39017762463), `v9.9.9` refuses (39017772582)                                          |
| T9 — topics set (7/7 via API), planning index verified, ROADMAP release-automation idea retired                                    | `gh api repos/.../topics`                                                                                                                   |
| T12/T13 — upstream watches re-checked and re-dated (still v1.6.3; `itemHeight: 72` still hardcoded at `ClipboardConstants.qml:14`) | TODO rows updated 10:40                                                                                                                     |
| 09-50 session leftovers: f1 (full check), f2 (oxfmt `--write` honors ignore, md5-proven), f17 closed; f5/f7 harvested              | TODO rows (lychee watch, BuildFlow#68 coupling)                                                                                             |
| Docs sync: FEATURES rows 16–17 + counts 17/16/1, AGENTS verification list + ritual, CHANGELOG Unreleased, 9 TODO rows closed       | gates green on every step; final CI green on `899a393`                                                                                      |

## b) PARTIALLY DONE

| Item                        | What's missing                                                                                                                                                                           |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| T2 live-DMS verification    | HUMAN 5 min: reload + exercise `:s`. Correctly did NOT re-date the FEATURES daily-driver claim (never write the claim before the action) — but the trust gap therefore still stands.     |
| T7 dependabot walk          | Checked 10:45-worth: no open PR exists (PR #1 closed-unmerged; the 04:24 run found everything current). The WALK itself cannot happen until a PR lands — time-gated, row carries status. |
| T11 demo GIF                | D3 decision never made (record/semi-automate/drop) — user-gated.                                                                                                                         |
| Anchor-gate symbol coverage | Hard symbol claims exist on ~9 of 17 rows; rows 1–7, 11 cite lines with prose labels only (non-blank asserted, symbol not). Drift inside those files' dense regions would still pass.    |
| Self-test coverage          | `checks.anchors` self-tests prove the bad-line and bad-symbol legs; the missing-file and no-anchor-per-row legs have NO doctored-copy proof.                                             |
| v1.2.0 dogfooding           | The consumer (SystemNix) has NOT been bumped to the `v1.2.0` tag — the release exists but nobody consumes it yet.                                                                        |

## c) NOT STARTED

- Phase 5 backlog (M11–M17, qmltypes stepping stone, aarch64 CI leg, binary cache, lock-refresh cadence) — intentionally unsliced per the plan; not session work.
- Open questions T15 (paste-only vs more plugins; BuildFlow adoption) — user decisions, untouched.
- Promoting the T6 scratch eval to a repo check — deliberately NOT taken (would pin DMS+HM as flake inputs); the recipe lives only in the 10-35 report + CHANGELOG bullet.
- Archiving the 09-35 plan / 09-50 report — both still have unresolved items (T2/T11, #68); correctly unarchived, listed here for completeness.
- `nix flake check --all-systems` — the aarch64 omission warning printed on EVERY run this session (≈6 times) and was never acted on or silenced with intent.

## d) TOTALLY FUCKED UP

- **TODO_LIST over-deletion, TWICE.** Two separate row deletions each swallowed 4 still-open rows (lazy multi-bullet `old_string` spans), the second one AFTER I had already made the identical mistake once. Both caught by immediate re-read + restore. Same mistake twice in one session is not a mistake anymore, it's a missing rule: one row per edit, view after every delete.
- **Committed through a red check.** `nix flake check 2>&1 | tail -3 && git commit …` — the pipe returns tail's exit code, so a FAILING check (the invalid fixture) let the commit through. Fixed forward, but the sequence commit-then-verify-then-fix should have been verify-then-commit. Rule: no pipe before `&&` after a gate; `>/tmp/log 2>&1; echo $?` or un-piped.
- **Shipped the anchor gate weak first.** Version 1 asserted only non-blank lines — my own stale-line negative test PASSED when it had to fail. Worse: my first negative-test batch included a vacuous test (stale line + prose paren, which the design never asserts — it "passed" and I briefly counted that as coverage). The gate that exists to kill anchor rot would have let the exact historic rot (`:227` vs `:231`) through. Prove-it-bites must precede wiring, not follow it.
- **claimIn debugging by misremembering.** I "fixed" a regex I had misremembered writing (`sub(/^\(/)` vs `sub(/^\(`/)`), the edit failed on exact-match, and only re-viewing the file showed the real bug was elsewhere (space between the anchor's closing backtick and the paren). Two round-trips that one`view` would have prevented.
- **Fuzz suite-2 property bug (my test, not the parser).** The reframe's `||` fallback silently turned legitimate empty contents into TOO_LARGE frames; the fuzz flagged MY test. Silver lining: that is exactly the job a fuzz suite is supposed to do.
- **`${'$'}` literal written into release.yml** (templating muscle-memory in a plain write) — caught before any run, but it would have shipped a broken how-to-consume block into every future release.
- **Future-dated report name.** Named the execution report `10-45` by estimating the clock instead of running `date` (actual time 10:35). Fixed this session via `git mv` + header/index rewrites; the sequencing error (write report → THEN user asks for date) is the real lesson: run `date` before naming anything.
- **Report inaccuracy caught post-ship:** the 10-35 report claimed "9 checks" — the flake has 8. Fixed in place this session. Small, but it is precisely the class of claim the anchors gate now exists to catch in FEATURES.

## e) WHAT WE SHOULD IMPROVE

- **Edit discipline for TODO_LIST:** one row per edit, `view` after every delete — the two over-deletions were both preventable by this one habit.
- **Gate-build discipline:** write the negative test FIRST; a gate whose bite is unproven is decoration. Extend the anchors self-tests to cover the missing-file and no-anchor legs (currently only 2 of 4 assertion classes are doctored-copy-proven).
- **Exit-code hygiene:** no pipes between a gate and `&&`. This bit once this session; the pattern `cmd >/tmp/log 2>&1; echo $?` was adopted only after the failure.
- **Re-view before edit:** never edit a file from memory of what I wrote — the claimIn round-trip.
- **Clock discipline:** `date` before naming timestamped artifacts; never estimate.
- **Symbol-claim coverage:** upgrade rows 1–7/11 parentheticals to backticked symbols so every row's anchor is a hard assertion, not just non-blank.
- **aarch64:** either add `--all-systems` locally once or silence the warning with a documented decision; six ignored warnings per session is normalization of deviance.
- **Consumer dogfooding:** bump SystemNix to `v1.2.0` after T2 passes so the release gets a real consumer.
- **Plan/report lifecycle:** once T2/T11 resolve, annotate + archive the 09-35 plan per the planning convention (it is the last plan carrying open items).

## f) Next (grounded in this session; ≤50, no quota)

Human-gated (yours):

1. T2: reload DMS, exercise `:s` search/save/paste/delete (5 min; rollback documented in the TODO row).
2. D3: GIF record / semi-automate / drop.
3. Dogfood decision: bump SystemNix to `github:LarsArtmann/dms-paste/v1.2.0` now or wait.

Machine (next session, any order):

4. Extend anchors symbol claims to rows 1–7/11 (backticked identifiers at the cited lines).
5. Add missing-file + no-anchor self-test legs to `checks.anchors`.
6. aarch64: local `nix flake check --all-systems` once, then decide CI leg vs documented deferral.
7. T7 walk when the weekly dependabot PR lands (SHA vs upstream tag → merge → watch CI).
8. When T2 passes: re-date FEATURES verification basis, delete the TODO row, CHANGELOG entry.
9. When D3 resolves: GIF embed (docs/assets/, <2 MB) or row deletion.
10. T12 on every DMS release announcement (recipe in the row).
11. T13 when DMS ships `itemHeight`/`previewLines`/`showTypeCaptions` keys.
12. lychee `pastebot.app` finding: decide known-flaky vs link fix (needs your intent answer).
13. BuildFlow#68: when it ships, delete the AGENTS cache caveat (row exists).
14. Consider contributing modal-density settings upstream (M11) now that the harness depth (T5) prerequisite is met.
15. Store the T6 scratch-eval recipe as `docs/` note if the /tmp copy is ever needed again (or drop intentionally).
16. Annotate + archive the 09-35 plan and the 09-50 report once their open items resolve.
17. Graduate a ROADMAP richness idea (M12 placeholders / M14 edit-in-place are the cheapest) when wanted — via TODO_LIST bounding, not direct slicing.
18. Release cadence decision feeds when to cut v1.3.0 (after recents restoration is the natural anchor).

## g) Questions I can NOT figure out myself

1. **T2 timing:** reload DMS NOW while this session's rollback context is fresh (revert SnippetsLauncher.qml to inline logic if `:s` breaks), or at your next natural compositor restart? I will not touch your running session unilaterally.
2. **Dogfooding:** should SystemNix be re-pointed at `v1.2.0` immediately (real consumer for the release), or does it ride the flake-rev until recents persistence ships and a v1.3.0 makes the bump worth a switch?
3. **pastebot.app intent** (09-50 §g3, still unanswered): is that link expected to be a live site today (transient TLS failure → keep and mark known-flaky) or aspirational marketing (→ drop or de-link)? It decides the lychee row's fix direction.
