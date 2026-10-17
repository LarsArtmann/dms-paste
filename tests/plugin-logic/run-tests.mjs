#!/usr/bin/env node
// Runs the plugin's pure logic (SnippetsLogic.js, the exact file DMS
// loads) under node by stripping the QML-only ".pragma library"
// directive. Usage: run-tests.mjs <path-to-SnippetsLogic.js>
import { readFileSync } from "node:fs";
import vm from "node:vm";

const path = process.argv[2];
if (!path) {
  console.error("usage: run-tests.mjs <path-to-SnippetsLogic.js>");
  process.exit(2);
}
const source = readFileSync(path, "utf8").replace(/^\s*\.pragma\s+library\s*$/m, "");
const context = vm.createContext({});
vm.runInContext(
  source + "\n;globalThis.__exports = { slugify, score, parseScanRecords, recencyCompare, updatedRecents };",
  context,
);
const { slugify, score, parseScanRecords, recencyCompare, updatedRecents } = context.__exports;

let failures = 0;
function check(label, cond, detail) {
  if (cond) {
    console.log("PASS " + label);
  } else {
    failures++;
    console.log("FAIL " + label + (detail === undefined ? "" : " :: " + JSON.stringify(detail)));
  }
}
function eq(label, actual, expected) {
  check(label, JSON.stringify(actual) === JSON.stringify(expected), { actual, expected });
}

// --- score: relevance tiers and the token veto -------------------------
const snippet = (name, content) => ({ name, content });
eq("score: name prefix wins", score(snippet("Standup update", "body"), "stan", []), 100);
eq("score: name substring", score(snippet("My standup", "body"), "stan", []), 70);
eq("score: content substring", score(snippet("other", "standup text"), "stan", []), 40);
eq("score: miss", score(snippet("other", "body"), "zzz", []), 0);
eq("score: token veto beats a name-prefix hit", score(snippet("standup", "body"), "stan", ["miss"]), 0);
eq("score: all tokens present keeps the tier", score(snippet("standup", "monday body"), "stan", ["monday", "body"]), 100);

// --- slugify -------------------------------------------------------------
eq("slugify: lowercases and joins", slugify("Hello World"), "hello-world");
eq("slugify: collapses runs, strips edges", slugify("--a !! b--"), "a-b");
eq("slugify: non-ascii letters become separators", slugify("Ünïcödé!"), "n-c-d");
const fallback = slugify("日本語!");
check("slugify: no ascii alphanumerics falls back to timestamped slug", /^snippet-\d+$/.test(fallback), fallback);

// --- parseScanRecords: the framed round-trip -----------------------------
// Mirrors the shell: printf '\036%s\037' name; cat file  (plus \n per record)
const frame = (fileName, content) => "\x1e" + fileName + "\x1f" + content;
const scanText =
  frame("greet.txt", "hello world\n") +
  frame("multi.txt", "line one\nline two\n") +
  frame("big.txt", "\x01TOO_LARGE\x0165537\n") +
  frame("empty.txt", "") +
  frame("blank-first.txt", "\n\nbody");

const parsed = parseScanRecords(scanText);
eq("parse: record count (junk-free)", parsed.length, 5);

const greet = parsed[0];
eq("parse: name strips .txt", greet.name, "greet");
eq("parse: content round-trips with newline", greet.content, "hello world\n");
eq("parse: single-line preview, no suffix", greet.preview, "hello world");
eq("parse: not oversized", greet.oversized, false);

const multi = parsed[1];
eq("parse: multiline preview carries line count", multi.preview, "line one  ·  2 lines");
eq("parse: multiline content intact", multi.content, "line one\nline two\n");

const big = parsed[2];
eq("parse: oversized flag", big.oversized, true);
eq("parse: oversized content never loaded", big.content, "");
eq("parse: oversized preview with KB size", big.preview, "(too large: 64 KB — not listed; open the file directly)");

const empty = parsed[3];
eq("parse: empty file preview", empty.preview, "(empty)");

const blankFirst = parsed[4];
eq("parse: blank-first-line preview", blankFirst.preview, "(multiline)  ·  3 lines");

const longLine = parseScanRecords(frame("long.txt", "x".repeat(90) + "\n"))[0];
check("parse: preview truncates at 80 + ellipsis", longLine.preview.length === 81 && longLine.preview.endsWith("…"), longLine.preview.length);

// --- recencyCompare -------------------------------------------------------
const A = { fileName: "a.txt", name: "a" };
const B = { fileName: "b.txt", name: "b" };
const Z = { fileName: "z.txt", name: "z" };
const recents = ["b.txt", "a.txt"];
check("recency: both recent, index order wins", recencyCompare(B, A, recents) < 0 && recencyCompare(A, B, recents) > 0);
check("recency: recent sorts before never-used", recencyCompare(A, Z, recents) < 0 && recencyCompare(Z, A, recents) > 0);
check("recency: neither recent falls back to alpha", recencyCompare(Z, A, []) > 0 && recencyCompare(A, Z, []) < 0);

// --- updatedRecents -------------------------------------------------------
eq("recents: prepend", updatedRecents(["a.txt"], "b.txt"), ["b.txt", "a.txt"]);
eq("recents: re-use moves to front, deduped", updatedRecents(["a.txt", "b.txt"], "a.txt"), ["a.txt", "b.txt"]);
const ten = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];
const capped = updatedRecents(ten, "new");
eq("recents: capped at 10", capped.length, 10);
eq("recents: newest first", capped[0], "new");
eq("recents: oldest dropped", capped[9], "9");
const input = ["a"];
updatedRecents(input, "x");
eq("recents: input not mutated", input, ["a"]);

if (failures) {
  console.error(failures + " plugin-logic test(s) failed");
  process.exit(1);
}
console.log("plugin-logic: all tests passed");
