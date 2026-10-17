Item {
    // Fixture mirroring the upstream ClipboardEntry.qml (v1.6.3) shapes the
    // patcher targets: the caption `text: { switch (entryType) { ... } }`
    // binding whose closing brace sits at the upstream 16-space indent, and
    // the long-text-conditional maximumLineCount expression. The literal
    // indentation matters — the perl leg anchors on the 16-space closing
    // brace — so preserve it when editing. The qml-preflight check
    // parse-lints this fixture, so it must stay valid QML (a bare switch
    // statement in object scope is not).
    Column {
        Row {
            StyledText {
                text: {
                    switch (entryType) {
                    case "image":
                        return "Image";
                    case "long_text":
                        return "Long Text";
                    default:
                        return "Text";
                    }
                }
                maximumLineCount: entryType === "long_text" ? 3 : 1
            }
        }
    }
}
