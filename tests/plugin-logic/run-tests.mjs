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
  source +
    "\n;globalThis.__exports = { slugify, score, parseScanRecords, recencyCompare, updatedRecents };",
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
eq(
  "score: token veto beats a name-prefix hit",
  score(snippet("standup", "body"), "stan", ["miss"]),
  0,
);
eq(
  "score: all tokens present keeps the tier",
  score(snippet("standup", "monday body"), "stan", ["monday", "body"]),
  100,
);

// --- slugify -------------------------------------------------------------
eq("slugify: lowercases and joins", slugify("Hello World"), "hello-world");
eq("slugify: collapses runs, strips edges", slugify("--a !! b--"), "a-b");
eq("slugify: non-ascii letters become separators", slugify("Ünïcödé!"), "n-c-d");
const fallback = slugify("日本語!");
check(
  "slugify: no ascii alphanumerics falls back to timestamped slug",
  /^snippet-\d+$/.test(fallback),
  fallback,
);

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
eq(
  "parse: oversized preview with KB size",
  big.preview,
  "(too large: 64 KB — not listed; open the file directly)",
);

const empty = parsed[3];
eq("parse: empty file preview", empty.preview, "(empty)");

const blankFirst = parsed[4];
eq("parse: blank-first-line preview", blankFirst.preview, "(multiline)  ·  3 lines");

const longLine = parseScanRecords(frame("long.txt", "x".repeat(90) + "\n"))[0];
check(
  "parse: preview truncates at 80 + ellipsis",
  longLine.preview.length === 81 && longLine.preview.endsWith("…"),
  longLine.preview.length,
);

// --- recencyCompare -------------------------------------------------------
const A = { fileName: "a.txt", name: "a" };
const B = { fileName: "b.txt", name: "b" };
const Z = { fileName: "z.txt", name: "z" };
const recents = ["b.txt", "a.txt"];
check(
  "recency: both recent, index order wins",
  recencyCompare(B, A, recents) < 0 && recencyCompare(A, B, recents) > 0,
);
check(
  "recency: recent sorts before never-used",
  recencyCompare(A, Z, recents) < 0 && recencyCompare(Z, A, recents) > 0,
);
check(
  "recency: neither recent falls back to alpha",
  recencyCompare(Z, A, []) > 0 && recencyCompare(A, Z, []) < 0,
);

// --- updatedRecents -------------------------------------------------------
eq("recents: prepend", updatedRecents(["a.txt"], "b.txt"), ["b.txt", "a.txt"]);
eq("recents: re-use moves to front, deduped", updatedRecents(["a.txt", "b.txt"], "a.txt"), [
  "a.txt",
  "b.txt",
]);
const ten = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];
const capped = updatedRecents(ten, "new");
eq("recents: capped at 10", capped.length, 10);
eq("recents: newest first", capped[0], "new");
eq("recents: oldest dropped", capped[9], "9");
const input = ["a"];
updatedRecents(input, "x");
eq("recents: input not mutated", input, ["a"]);

// --- fuzz: parseScanRecords under deterministic randomness ----------------
// Mulberry-style LCG with a fixed seed: every CI run explores the exact
// same random space, so a failure is always reproducible locally.
let fuzzState = 0x4a56d170;
const rnd = () => {
  fuzzState = (Math.imul(fuzzState, 1664525) + 1013904223) >>> 0;
  return fuzzState / 4294967296;
};
const pick = (arr) => arr[Math.floor(rnd() * arr.length) % arr.length];
const randName = () => {
  const alphabet = "abcdefghijklmnopqrstuvwxyz0123456789-._";
  let out = "";
  const len = 1 + Math.floor(rnd() * 12);
  for (let i = 0; i < len; i++) out += alphabet[Math.floor(rnd() * alphabet.length)];
  return out + ".txt";
};
const randContent = (hostile) => {
  const safe = "abcXYZ 019\n\t.,;:!?/*-+_()[]{}#'\"\\|<>~^`$%@=&\r";
  const pool = hostile ? safe + "\x1e\x1f" : safe;
  let out = "";
  const len = Math.floor(rnd() * 300);
  for (let i = 0; i < len; i++) out += pool[Math.floor(rnd() * pool.length)];
  return out;
};

// Suite 1: separator-free content must round-trip exactly.
let fuzz1Bad = 0;
for (let iter = 0; iter < 500; iter++) {
  const records = [];
  const n = 1 + Math.floor(rnd() * 8);
  for (let i = 0; i < n; i++)
    records.push({ fileName: randName(), content: randContent(false) });
  const stream = records.map((r) => "\x1e" + r.fileName + "\x1f" + r.content).join("");
  const parsed = parseScanRecords(stream);
  if (parsed.length !== records.length) fuzz1Bad++;
  else
    for (let i = 0; i < records.length; i++) {
      const want = records[i];
      const got = parsed[i];
      if (
        got.fileName !== want.fileName ||
        got.name !== want.fileName.replace(/\.txt$/i, "") ||
        got.content !== want.content ||
        got.oversized !== false
      ) {
        fuzz1Bad++;
        break;
      }
    }
}
eq("fuzz: 500 separator-free random frames round-trip exactly", fuzz1Bad, 0);

// Suite 2: separator-hostile content must never throw, never invent content
// (every parsed content is a substring of the stream), and re-framing the
// parse output must be a fixed point of the parser.
let fuzz2Bad = 0;
for (let iter = 0; iter < 500; iter++) {
  const records = [];
  const n = 1 + Math.floor(rnd() * 8);
  for (let i = 0; i < n; i++)
    records.push({ fileName: randName(), content: randContent(true) });
  const stream = records.map((r) => "\x1e" + r.fileName + "\x1f" + r.content).join("");
  let parsed;
  try {
    parsed = parseScanRecords(stream);
  } catch {
    fuzz2Bad++;
    continue;
  }
  for (const rec of parsed) if (!stream.includes(rec.content)) fuzz2Bad++;
  const reframed = parsed
    .map((r) => "\x1e" + r.fileName + "\x1f" + (r.content || "\x01TOO_LARGE\x010"))
    .join("");
  if (JSON.stringify(parseScanRecords(reframed)) !== JSON.stringify(parsed)) fuzz2Bad++;
}
eq("fuzz: 500 separator-hostile frames stay total and reparse-stable", fuzz2Bad, 0);

// Suite 3: oversized framing at random sizes keeps its contract.
let fuzz3Bad = 0;
for (let iter = 0; iter < 100; iter++) {
  const bytes = 1 + Math.floor(rnd() * 300000);
  const got = parseScanRecords("\x1ebig.txt\x1f\x01TOO_LARGE\x01" + bytes + "\n")[0];
  const kb = Math.round(bytes / 1024);
  if (
    !got.oversized ||
    got.content !== "" ||
    got.preview !== "(too large: " + kb + " KB — not listed; open the file directly)"
  )
    fuzz3Bad++;
}
eq("fuzz: 100 random oversized frames carry flag, no content, exact KB preview", fuzz3Bad, 0);

if (failures) {
  console.error(failures + " plugin-logic test(s) failed");
  process.exit(1);
}
console.log("plugin-logic: all tests passed");
