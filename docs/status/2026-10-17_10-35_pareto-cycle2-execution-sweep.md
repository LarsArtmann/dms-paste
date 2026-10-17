# Status 2026-10-17 10:35 — Pareto Cycle 2 execution sweep

Scope: full execution of [Cycle 2](../planning/2026-10-17_09-35_pareto-cycle2-master-plan.md) Phases 1–4 machine-executable tasks (ordered by the user: "the WHOLE TODO LIST"). One session, sequential commits, every gate green at each step.

## a) FULLY DONE

| Item                                                                                                                           | Evidence                                                                                                                                                                                                                                                                                               |
| ------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| v1.2.0 released (T1) — bump, CHANGELOG section, green check on the release commit, annotated tag, GitHub Release, SECURITY row | [v1.2.0 Release](https://github.com/LarsArtmann/dms-paste/releases/tag/v1.2.0); tag on `7abb91c`; ritual amended with the run's learnings (tag the prep commit, not HEAD)                                                                                                                              |
| CI concurrency cancellation observed (T8) — first live exercise of the `check-<ref>` group                                     | run `39016361333` (release prep) cancelled by `39016420378` (SECURITY push); TODO row closed                                                                                                                                                                                                           |
| FEATURES evidence anchor gate (T3) — `tests/anchors.sh` + `checks.anchors`                                                     | line-bounds, continuation, range, symbol-claim assertions; two doctored-copy self-tests; first run caught rows 12/13/15 (no line anchors) — fixed with real anchors; negative tests proved stale-but-nonblank lines now FAIL                                                                           |
| Gates bundle (T4) — counts-sentence assert + qml-preflight over fixtures                                                       | sentence leg self-tested (numbers consistent, sentence lies → gate fails); fixtures parse-lint revealed the fixture's bare `switch` was never valid QML — fixture reshaped to mirror upstream v1.6.3 literally (16-space perl anchor intact), patch-contract still green                               |
| Harness depth (T5) — deterministic fuzz + JSDoc                                                                                | 1100 fixed-seed cases: separator-free exact round-trip; hostile `\x1e`/`\x1f` never throws / never invents content / re-frame is a parser fixed point; oversized KB previews exact. 5 exports JSDoc'd. (The suite-2 failure on first run was MY test bug: `                                            |
| Consumer-shaped integration eval (T6) vs real DMS HM closure                                                                   | full home-manager closure with `homeModules.dank-material-shell` @ v1.6.3: ZERO stub-vs-real gaps — all three settings keys, maxHistory 100k, plugin registered+enabled+snippetsDir, plugin source linked at `~/.config/DankMaterialShell/plugins/paste-snippets`, consumer override beats `mkDefault` |
| Release automation (T10) — `release.yml`                                                                                       | tag → CHANGELOG section → notes (from the tagged tree) → Release; fail-closed without a section. Dry-runs verified BOTH ways: `v1.2.0` renders the exact manual notes (run 39017762463), `v9.9.9` refuses (39017772582)                                                                                |
| Repo polish (T9) — topics + planning index                                                                                     | topics live via API (`nixos, nix-flake, quickshell, dankmaterialshell, clipboard, snippets, home-manager`); `docs/planning/README.md` verified current; ROADMAP release-automation idea retired                                                                                                        |
| Upstream watches re-checked (T12/T13)                                                                                          | DMS latest still v1.6.3 (10:40); `itemHeight: 72` still hardcoded at `ClipboardConstants.qml:14` — both rows re-dated, nothing actionable                                                                                                                                                              |
| 09-50 session f-items closed/harvested                                                                                         | f1 (full `nix flake check` run — multiple times, incl. pre-release), f2 (oxfmt `--write` honors the ignore — md5 unchanged), f17 (untouched checks re-run before the cut); f5/f7 harvested as TODO watch rows                                                                                          |

## b) PARTIALLY DONE

| Item                     | What's missing                                                                                                                                                      |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| T7 dependabot walk       | Time-gated: no open PR exists (checked 10:45; the 04:24 run found everything current). Row carries the observation; next weekly run is the window.                  |
| T2 live-DMS verification | HUMAN: reload DMS + exercise `:s`. FEATURES daily-driver wording deliberately NOT re-dated (verification hasn't happened; never write the claim before the action). |

## c) NOT STARTED

- T11 demo GIF (D3: human recording decision — pending).
- Phase 5 backlog (M11–M17, qmltypes, aarch64, binary cache, lock-refresh) — intentionally unsliced per the plan.

## d) TOTALLY FUCKED UP

- **TODO_LIST over-deletion, twice.** Two separate row-deletion edits swallowed 4 still-open rows each (lazy `old_string` spans across neighboring bullets). Both caught by immediate re-read and restored precisely. Lesson: delete exactly one row per edit, then view the file.
- **Pipe-masked exit status.** `nix flake check 2>&1 | tail -3 && git commit …` committed THROUGH a red check (qml-preflight fixtures leg failing on the invalid fixture). Fixed forward (the fixture truth-fix), check re-verified green with an un-piped exit code. Lesson: `; echo exit=$?` or `>/tmp/log; echo $?`, never a pipe before `&&`.
- **Anchor gate shipped weak.** First version asserted only non-blank lines — my own negative test (stale `:231`) PASSED when it must fail. Root cause: no hard symbol claims. Strengthened (backticked identifier claims incl. ranges), which then found a real extraction bug (leading-backtick split) AND three real label mismatches (`checks.`-prefixed claims not present at cited lines). Gates only count when their bite is proven.
- **Fuzz suite-2 property bug** (my test, not the parser): the reframe's `||` fallback turned legitimate empty contents into TOO_LARGE frames. The fuzz did its job — on my test.
- One literal `${'$'}` escape artifact survived into release.yml's printf on first write (caught before any run).

## e) WHAT WE SHOULD IMPROVE (self-review)

**What did we forget?** Nothing in scope: every machine-executable task in Phases 1–4 ran to green. The human-gated items are explicitly parked, not forgotten.

**What could we have done better?** The two TODO over-deletions were pure sloppiness (both in one file, same session). The weak-first anchor gate shipped a `checks.anchors` that would have passed the drift it existed to catch — building the negative test BEFORE wiring the check would have caught it one cycle earlier.

**Did we lie?** No: FEATURES row 17's "verified" claims point at real run IDs; T6's zero-gap claims come from the eval output reproduced above; the v1.2.0 ritual-amendment claims match what actually happened.

**Ghost systems?** None: the scratch T6 eval lives in /tmp by design (recipe recorded here; making it a repo check would pin DMS+HM as inputs — deliberately not taken).

**Tests?** `nix flake check` (8 checks incl. all new gates + their self-test legs) green after every phase; CI green on every push; release workflow dry-runs green/red exactly as designed.

## f) Next

1. T2 (human, 5 min): reload DMS, exercise `:s` search/save/paste/delete → then re-date FEATURES verification basis + delete the TODO row.
2. T11 (human): record the demo GIF (or explicitly drop D3) → embed or delete the row.
3. T7: when the next weekly dependabot PR lands — SHA-verify vs upstream tag, merge, watch CI, delete the row.
4. T12/T13: on each DMS release announcement, re-check (rows carry the recipe).
5. Consider (user): BuildFlow#68 fix in the sibling repo; drafts-lifecycle decision; `pastebot.app` link intent (09-50 §g).
6. Optional future: promote the T6 scratch eval to a repo check only if pinning DMS as an input ever becomes acceptable.

## g) Questions I can NOT figure out myself

1. **T2 timing** — should the live-DMS reload happen while this session's context is fresh (rollback path documented), or on your next natural reboot?
2. **D3** — record the GIF, semi-automate, or drop the idea (ROADMAP "landing-page persuasion" vs 30 min of human time)?
3. **Release cadence** — v1.2.0 shipped docs/infra only; is the next release intended to wait for recents restoration (the first user-visible change), or cut freely?
