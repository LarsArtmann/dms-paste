Item {
    // Fixture mirroring the upstream ClipboardEntry.qml shapes the
    // patcher targets: the `switch (entryType) { ... }` block with its
    // closing brace at the upstream 16-space indent, and the
    // long-text-conditional maximumLineCount expression.
    Loader {
        switch (entryType) {
                case "text":
                case "long_text":
                case "image":
                    break;
                }

        Text {
            maximumLineCount: entryType === "long_text" ? 3 : 1
        }
    }
}
