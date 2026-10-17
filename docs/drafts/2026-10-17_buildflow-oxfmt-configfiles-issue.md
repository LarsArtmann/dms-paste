> [!NOTE]
> This filing was drafted by GLM-5.3 via Crush from an AI-run investigation, not at my request. When the failure traces to an external report, that source is linked in the body.
>
> - [ ] MANUALLY REVIEWED by `@Lars Artmann` at `[<date-time>]`

## Symptom

Found while fixing a dms-paste build failure (buildflow 7baef1c, oxfmt 0.68.0). A QML plugin ships `SnippetsLogic.js` with a `.pragma library` line — valid QML JS, unparseable for oxfmt — so the repo added a root `.oxfmtrc.json` with `"ignorePatterns": ["plugins/snippets/SnippetsLogic.js"]`. The next `buildflow -s oxfmt -v` still failed with the old finding, detect step 1 ms (cache hit). `BUILDFLOW_NO_RESULT_CACHE=1 buildflow -s oxfmt -v` ran for real and passed:

```
exec: oxfmt --check plugins/snippets/SnippetsLogic.js tests/plugin-logic/run-tests.mjs
oxfmt> All matched files use the correct format.
oxfmt> Finished in 17ms on 1 files
```

Note the config filtered an explicitly passed file ("on 1 files"), so the cached verdict was computed under different ignore rules than a fresh run would use.

## Root cause (source)

`NewOxfmtProvider` declares no `WithConfigFiles`, so `.oxfmtrc.json` is not result-cache key material (`tools/providers/formatter_args_1.go:158`, quoted at repo HEAD `5e7830313e9236c7410ce8d6fc28229a299bc8c0`):

```go
func NewOxfmtProvider(runner Runner) *dtool.Tool {
	return NewFormatterProvider(
		config.ToolOxfmt, "oxfmt", nil, ".", runner,
		WithPatterns(webFilePatterns...),
		WithLanguage(dtool.AnyLanguage()),
		WithCheckFlags("--check"),
		WithNotRequires(repoToolchainDeferPatterns...),
	)
}
```

dprint (`**/dprint.json`, `tools/providers/dprint_provider.go:94`), oxlint (`tools/providers/js_providers.go:153`) and eslint declare theirs; oxfmt does not. The gotcha #47 rule — "any provider that passes `--config <file>` must declare that file" — does not catch this because oxfmt never gets a flag: it auto-discovers `.oxfmtrc.json` from the working directory (`oxfmt --help`: `-c` / config discovery), and its ignore defaults also read `.gitignore` and `.prettierignore`. Same stale-verdict class as #47, but entered through implicit config discovery instead of an explicit flag.

## Automation steps (repo)

- [ ] Add `WithConfigFiles` to `NewOxfmtProvider` covering `.oxfmtrc.json` (plus the `-c`-style variants only if cheap: `.oxfmtrc.jsonc/.ts/.js`)
- [ ] Decide whether the default ignore files (`.gitignore`, `.prettierignore`) are key material too — they also change which of the explicitly passed files oxfmt judges
- [ ] Widen the audit-ratchet rule wording from "passes `--config <file>`" to "reads a config, explicit or auto-discovered"

## To verify

Repro before the fix: repo with a JS file oxfmt fails on + `.oxfmtrc.json` ignoring it → first run caches the failure, config edit does not invalidate it, cached run keeps failing while `BUILDFLOW_NO_RESULT_CACHE=1` passes. After the fix, editing `.oxfmtrc.json` must flip the next cached run to a fresh verdict.

💘 Generated with Crush
