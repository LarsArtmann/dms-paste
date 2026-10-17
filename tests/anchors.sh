#!/usr/bin/env bash
# FEATURES.md evidence anchor gate: every line-bearing citation in the
# Evidence column must resolve — `path:line` cites an existing file and a
# non-blank line, a bare `:line` continues the previous file in the same
# cell, and `a`-`b` ranges keep both endpoints in-bounds and non-blank. A
# backticked symbol claim directly after an anchor (` (`symbol`)`) must
# occur within ±5 lines of the cite, and every feature row must carry at
# least one line anchor. Hand-anchoring failed silently twice — this gate
# makes that drift class mechanical. Usage: anchors.sh FEATURES.md <repo-root>
set -euo pipefail
file=${1:?usage: anchors.sh FEATURES.md <repo-root>}
root=${2:?usage: anchors.sh FEATURES.md <repo-root>}
cd "$root"

awk '
  BEGIN { FS = "|" }
  function fail(row, msg) {
    printf "anchors gate: row %s — %s\n", row, msg
    bad = 1
  }
  function filelines(path,  n, l) {
    if (path in LC) return LC[path]
    n = 0
    while ((getline l < path) > 0) n++
    close(path)
    LC[path] = n
    return n
  }
  function lineAt(path, want,  i, l) {
    i = 0
    while ((getline l < path) > 0) {
      i++
      if (i == want) { close(path); return l }
    }
    close(path)
    return ""
  }
  function nonblank(path, n) {
    if (n < 1) return 0
    return lineAt(path, n) ~ /[^[:space:]]/ ? 1 : 0
  }
  function symbolNear(path, line, sym,  i, hit) {
    for (i = line - 5; i <= line + 5; i++) {
      if (i < 1) continue
      if (index(lineAt(path, i), sym) > 0) { hit = 1; break }
    }
    return hit ? 1 : 0
  }
  /^\|[[:space:]]*[0-9]+[[:space:]]*\|/ {
    row = $2
    gsub(/[[:space:]]/, "", row)
    cell = $5
    # ASCII-normalize dashes so range detection is locale-independent.
    gsub(/–/, "-", cell)
    gsub(/—/, "-", cell)
    cur = ""
    cited = 0
    work = cell
    while (match(work, /[A-Za-z0-9_.\/-]+\.[A-Za-z0-9]+:[0-9]+|:[0-9]+/)) {
      tok = substr(work, RSTART, RLENGTH)
      c = index(tok, ":")
      path = c > 1 ? substr(tok, 1, c - 1) : ""
      line = substr(tok, c + 1) + 0
      after = substr(work, RSTART + RLENGTH)
      if (path != "") {
        cur = path
        if (filelines(cur) == 0) { fail(row, "cited file does not exist: " cur); work = after; continue }
      } else if (cur == "") {
        fail(row, "continuation anchor with no file context: " tok)
        work = after
        continue
      }
      cited++
      if (!nonblank(cur, line))
        fail(row, cur ":" line " does not cite a non-blank line (file has " filelines(cur) " lines)")
      # Optional range end: `a`-`b` (the dash may sit between backticks).
      if (match(after, /^`?[[:space:]]*-[[:space:]]*`?[0-9]+/)) {
        rng = substr(after, 1, RLENGTH)
        gsub(/[^0-9]/, "", rng)
        end = rng + 0
        if (end < line) fail(row, cur " range " line "-" end " is inverted")
        if (!nonblank(cur, end))
          fail(row, cur " range end " end " is blank or out of bounds (file has " filelines(cur) " lines)")
      } else if (match(after, /^`?[[:space:]]*\(`[A-Za-z_][A-Za-z0-9_]*`\)/)) {
        sym = substr(after, 1, RLENGTH)
        gsub(/[^A-Za-z0-9_]/, "", sym)
        if (!symbolNear(cur, line, sym))
          fail(row, "symbol `" sym "` not found within ±5 lines of " cur ":" line)
      }
      work = after
    }
    if (cited == 0)
      fail(row, "no line-bearing anchor in Evidence — every row must cite at least one")
  }
  END {
    if (bad) print "anchors gate: fix FEATURES.md so every citation resolves"
    exit bad ? 1 : 0
  }
' "$file"
