// Pure plugin logic shared between the QML launcher and the nix test
// harness (tests/plugin-logic). No Qt imports in here: everything is
// plain JavaScript over its arguments so it also runs under node.
// .pragma library keeps QML from leaking document scope into this file.
.pragma library

// Turn a display name into a snippet filename (sans extension).
// Falls back to a timestamped slug when nothing name-like remains.
function slugify(name) {
    let slug = name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "");
    if (slug.length === 0)
        slug = "snippet-" + Date.now();
    return slug;
}

// Relevance tiers: name prefix 100 > name substring 70 > content
// substring 40; every query token must also appear in name or content.
function score(snippet, lowerQuery, tokens) {
    const lowerName = snippet.name.toLowerCase();
    let score = 0;
    if (lowerName.startsWith(lowerQuery))
        score = 100;
    else if (lowerName.includes(lowerQuery))
        score = 70;
    else if (snippet.content.toLowerCase().includes(lowerQuery))
        score = 40;
    else
        return 0;
    for (let i = 0; i < tokens.length; i++) {
        if (!lowerName.includes(tokens[i]) && !snippet.content.toLowerCase().includes(tokens[i]))
            return 0;
    }
    return score;
}

// Parse the framed scan stream: records separated by \x1e, filename
// split from content by \x1f, so arbitrary multiline content round-trips
// safely. Oversized files arrive as "\x01TOO_LARGE\x01<size>" instead of
// content and are listed as inert hints (content never loaded into QML).
function parseScanRecords(text) {
    const parsed = [];
    const records = text.split("\x1e");
    for (let i = 0; i < records.length; i++) {
        const record = records[i];
        if (!record || record.length === 0)
            continue;
        const sep = record.indexOf("\x1f");
        if (sep < 0)
            continue;
        const fileName = record.slice(0, sep);
        const content = record.slice(sep + 1);
        const oversized = content.startsWith("\x01TOO_LARGE\x01");
        const oversizeBytes = oversized ? (parseInt(content.slice(11), 10) || 0) : 0;
        const name = fileName.replace(/\.txt$/i, "");
        const lineCount = oversized ? 1 : content.replace(/\n+$/, "").split("\n").length;
        let preview;
        if (!oversized) {
            let pv = content.split("\n")[0] || "";
            pv = pv.trim();
            if (pv.length > 80)
                pv = pv.slice(0, 80) + "…";
            if (pv.length === 0)
                pv = content.trim().length > 0 ? "(multiline)" : "(empty)";
            preview = pv;
        } else {
            preview = "(too large: " + Math.round(oversizeBytes / 1024) + " KB — not listed; open the file directly)";
        }
        if (lineCount > 1)
            preview = preview + "  ·  " + lineCount + " lines";
        parsed.push({
            fileName: fileName,
            name: name,
            content: oversized ? "" : content,
            oversized: oversized,
            preview: preview
        });
    }
    return parsed;
}

// Recency-first ordering; alphabetical among the never-used.
function recencyCompare(a, b, recentFiles) {
    const ra = recentFiles.indexOf(a.fileName);
    const rb = recentFiles.indexOf(b.fileName);
    if (ra !== -1 || rb !== -1)
        return (ra === -1 ? 1 : 0) - (rb === -1 ? 1 : 0) || ra - rb;
    return a.name.localeCompare(b.name);
}

// Most-recent-first, deduped, capped at 10.
function updatedRecents(recentFiles, fileName) {
    const next = recentFiles.filter(function (f) { return f !== fileName; });
    next.unshift(fileName);
    if (next.length > 10)
        next.length = 10;
    return next;
}
