# Status 2026-10-17 09:50 — oxfmt `.pragma` fix + BuildFlow cache gap (single-session report)

Scope: this session only — the `oxfmt` BuildFlow failure in dms-paste, its fix, the
upstream loop closure, and the self-review. Not a fresh project audit.

Context: `buildflow` failed with `oxfmt: Unexpected token` at
`plugins/snippets/SnippetsLogic.js:5` — the deliberate QML `.pragma library` line
(a repo hard rule; the node harness strips it before eval at
`tests/plugin-logic/run-tests.mjs:13`). Standard JS parsers cannot read it.

## a) FULLY DONE

| Item                                                                                          | Evidence                                                                                                                                                                                                                                                                                            |
| --------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Root-caused the oxfmt failure                                                                 | `.pragma library` is QML-only syntax; file is intentionally dual-syntax (QML import + node-executed logic)                                                                                                                                                                                          |
| `.oxfmtrc.json` created with surgical `ignorePatterns: ["plugins/snippets/SnippetsLogic.js"]` | oxfmt-native mechanism; `run-tests.mjs` still formatted — live run showed `on 1 files`, not a zero-scan pass                                                                                                                                                                                        |
| oxfmt step green                                                                              | `buildflow -s oxfmt` exit 0; exec line verified: `oxfmt --check plugins/snippets/SnippetsLogic.js tests/plugin-logic/run-tests.mjs` → "All matched files use the correct format"                                                                                                                    |
| Full buildflow green                                                                          | exit 0, 27 success / 0 failed (oxlint, dprint, nix steps all pass)                                                                                                                                                                                                                                  |
| Flake dprint check green                                                                      | `nix build .#checks.x86_64-linux.dprint` exit 0 — covers `.oxfmtrc.json`, AGENTS.md, draft markdown                                                                                                                                                                                                 |
| Stale result-cache replay diagnosed at source level                                           | BuildFlow `NewOxfmtProvider` (`tools/providers/formatter_args_1.go:158`, HEAD `5e7830313e92`) declares no `WithConfigFiles`; `.oxfmtrc.json` edits don't invalidate the cached verdict — observed live (config added, cached run still failed at 1 ms detect; `BUILDFLOW_NO_RESULT_CACHE=1` passed) |
| Upstream issue filed                                                                          | [LarsArtmann/BuildFlow#68](https://github.com/LarsArtmann/BuildFlow/issues/68) — voice-checked (`check-draft` 0 FAIL), unsolicited banner shipped unchecked, verified landed (3030-char body intact)                                                                                                |
| AGENTS.md documented                                                                          | Ignore rationale + cache caveat + #68 pin, in the Verification section                                                                                                                                                                                                                              |
| Filing draft preserved                                                                        | `docs/drafts/2026-10-17_buildflow-oxfmt-configfiles-issue.md` (not `/tmp`)                                                                                                                                                                                                                          |

## b) PARTIALLY DONE

| Item                       | What's missing                                                                                                                                                                  |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| End-to-end verification    | Full `nix flake check` NOT run this session (patch-contract builds real DMS; reasoned unaffected — no nix/QML/test-source changes — and CI gates on push, but unproven locally) |
| oxfmt ignore coverage      | Verified in `--check` mode only; the `--fix`/repair path (`oxfmt --write`) untested with the ignore in place                                                                    |
| BuildFlow#68 banner review | Checkbox intentionally unchecked — awaits Lars's manual review of the filing                                                                                                    |
| AGENTS.md workaround       | The `BUILDFLOW_NO_RESULT_CACHE=1` caveat must be removed once #68 ships — pending upstream                                                                                      |

## c) NOT STARTED

- The BuildFlow#68 fix itself (`WithConfigFiles` on oxfmt + audit-ratchet wording + `.gitignore`/`.prettierignore` key-material decision).
- vtsls/TS-server noise: `SnippetsLogic.js:5` shows 2 persistent LSP parse errors in the editor (same `.pragma` cause; cosmetic, no gate failure).
- lychee finding triage: `README.md:7` → `https://pastebot.app/` network error (fatal TLS alert; warning-level).
- TODO_LIST.md harvest of this report's section f (docs-health HARVEST input).

## d) TOTALLY FUCKED UP

Nothing unrecoverable; nothing broke. Honest near-misses:

- **`rg -rn` flag misuse, twice.** `-r` is `--replace`; my greps silently rewrote matches ("oxfmt" → "ln") and could have produced a wrong diagnosis. Caught both times only because outputs looked garbled.
- **One wasted diagnostic round.** After the config landed, the cached run still failed and I initially treated it as "fix didn't work" before recognizing the result-cache replay the BuildFlow triage table explicitly lists. Cache-first should have been the reflex.
- **Transient past-tense lie in AGENTS.md.** The first edit said "upstream issue filed" minutes BEFORE the issue existed (final state pins #68 and is accurate). Lesson: never write a completed-action claim ahead of the action.
- End-of-session `git status` not verified until this report (the daemon had committed everything — clean — but that was luck, not checking).

## e) WHAT WE SHOULD IMPROVE (self-review)

**What did I forget?** Full `nix flake check`; the `--fix` path; surfacing the vtsls editor noise; verifying commit state at the end. All minor, all listed above.

**What could I have done better?** Cache-suspect ordering (above); tool hygiene with `rg` flags; offering the direct BuildFlow fix as an option instead of only filing — it is Lars's own repo and the fix is one `WithConfigFiles` line plus BuildFlow's own verification loop.

**What could I still improve?** Everything in section f; notably the AGENTS.md ↔ #68 coupling (the workaround line and the issue will drift if either closes without the other).

**Did I lie?** No final-state lies; every claim in the fix summary carried evidence. One transient inaccuracy, disclosed in d).

**Ghost systems?** None created — `.oxfmtrc.json` is read on every oxfmt run (proven by the "on 1 files" output). Nothing pre-existing noticed.

**Split brains?** No true ones. Two deliberate near-duplications to watch: (1) ignore rationale lives in AGENTS.md and in #68's body — different audiences, acceptable; (2) the cache workaround lives in AGENTS.md and in the BuildFlow skill's failure-triage reference — the project-level note must die when #68 ships.

**Tests?** Repo-appropriate: buildflow steps + flake checks are the test surface for a config/docs change. oxfmt step, full buildflow, and the flake dprint check were run; the remaining flake checks (patch-contract, features-counts, plugin-logic, qml-preflight) had unchanged inputs and were skipped with reasoning — run them once next time anything in their lanes moves.

## f) Next (grounded in this session; "up to 50" read as ceiling, not quota)

dms-paste:

1. Run full `nix flake check` once to close the end-to-end gap from this change.
2. Verify `oxfmt --write` (repair path) also honors the ignore — one manual command.
3. Decide the draft lifecycle: keep `docs/drafts/` as record vs delete after #68 resolves.
4. Add an editor/LSP exclusion for `SnippetsLogic.js` if the vtsls errors annoy.
5. Watch the lychee `pastebot.app` finding; if persistent, mark known-flaky or fix the link.
6. If a second QML-flavored `.js` lands under `plugins/`, extend `ignorePatterns` (or decide `plugins/**/*.js` scope then).
7. When BuildFlow#68 ships: remove the `BUILDFLOW_NO_RESULT_CACHE` line from AGENTS.md.
8. Harvest durable f-items into TODO_LIST.md (docs-health HARVEST).

BuildFlow (upstream, via #68):

9. Add `WithConfigFiles` to `NewOxfmtProvider` (`.oxfmtrc.json` + cheap `-c` variants).
10. Decide `.gitignore`/`.prettierignore` key-material treatment (they also filter explicitly passed files).
11. Widen the audit-ratchet rule from "passes `--config`" to "reads a config, explicit or auto-discovered".
12. Rebuild/reinstall the buildflow binary — doctor warns every run that 7baef1c < HEAD `5e78303`.
13. SV8 foreign lint red in `execution/result_cache_configfiles_test.go` (noticed in BuildFlow's TODO_LIST).

Process:

14. Habit: when a fix doesn't change a tool's verdict, suspect the result cache before re-diagnosing.
15. Habit: never write past-tense claims ("filed", "shipped") before the action completes.
16. Tool hygiene: stop passing `-r` to rg unintentionally; sanity-check grep output for mangled identifiers.
17. Belt-and-braces: re-run the untouched flake checks once before the next release cut.

## g) Questions I can NOT figure out myself

1. **BuildFlow#68 — fix it myself?** May I implement the one-line `WithConfigFiles` fix in the BuildFlow repo (sibling scope, with its full verification loop), or does filing suffice and you want to triage?
2. **Draft home.** Is `docs/drafts/` in dms-paste the right permanent convention for GitHub filing drafts, or should drafts be deleted once the issue is live (the body lives on GitHub anyway)?
3. **`pastebot.app` link intent.** README.md:7 links it and lychee gets a TLS InternalError — is that site expected to be live today (transient/external), or is the link aspirational and should be marked known-flaky?
