#!/usr/bin/env bash
# FEATURES.md counts gate: re-derives the per-status row counts from the
# feature table and fails when the "Counts (...)" summary line disagrees.
# Usage: features-counts.sh FEATURES.md
set -euo pipefail
file=${1:?usage: features-counts.sh FEATURES.md}

awk '
  /^\|[[:space:]]*[0-9]+[[:space:]]*\|/ {
    status = $4
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", status)
    split(status, words, /[[:space:]]+/)
    actual[words[1]]++
    rows++
  }
  /^Counts \([^)]*\): / {
    line = $0
    sub(/^Counts \([^)]*\): /, "", line)
    if (match(line, /^[0-9]+/))
      declared_total = substr(line, 1, RLENGTH) + 0
    while (match(line, /[0-9]+[[:space:]]+[A-Z_]+/)) {
      pair = substr(line, RSTART, RLENGTH)
      split(pair, parts, /[[:space:]]+/)
      declared[parts[2]] = parts[1] + 0
      line = substr(line, RSTART + RLENGTH)
    }
  }
  END {
    fail = 0
    if (rows != declared_total) {
      printf "counts gate: table has %d rows but the summary says %d\n", rows, declared_total
      fail = 1
    }
    for (st in actual)
      if (actual[st] != declared[st] + 0) {
        printf "counts gate: %s — table has %d, summary declares %d\n", st, actual[st], declared[st] + 0
        fail = 1
      }
    for (st in declared)
      if (!(st in actual) && declared[st] != 0) {
        printf "counts gate: %s — table has 0, summary declares %d\n", st, declared[st]
        fail = 1
      }
    if (fail)
      print "counts gate: fix FEATURES.md so the summary matches the table (never round a status up)"
    exit fail
  }
' "$file"
