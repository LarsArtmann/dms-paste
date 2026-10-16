# Composable postInstall patcher for the DankMaterialShell package:
# clipboard-modal density + cleanliness (PasteBot-parity pass, 2026-10-15).
#
# Usage (compose with your own overrides):
#   dms-paste.lib.patchDms pkgs dankMaterialShell.packages.${system}.default
#
# Upstream ships a "Text" caption above EVERY plain-text row, one preview
# line, and a 650x550 modal. Changes, all verified by the grep guards below
# (build fails if upstream text drifts):
#   1. No per-row type caption for plain "text" entries (Image/Long Text
#      captions stay — they carry information).
#   2. Two preview lines instead of one (fits itemHeight 68: label 18 +
#      2x21 text + spacing = 64 <= 68).
#   3. Wider/taller modal: 650x550 -> 880x620 (more entries, longer
#      previews per line).
#   4. Denser rows: itemHeight 72 -> 68.
# Drop these patches if upstream grows settings keys for them.
pkgs: dms:
dms.overrideAttrs (prev: {
  # postInstall patches Clipboard QML with perl (multi-line edits);
  # the Go build env does not ship perl by default.
  nativeBuildInputs = (prev.nativeBuildInputs or [ ]) ++ [ pkgs.perl ];
  postInstall = (prev.postInstall or "") + ''
    clipDir="$out/share/quickshell/dms/Modals/Clipboard"
    test -f "$clipDir/ClipboardEntry.qml" && test -f "$clipDir/ClipboardConstants.qml"
    chmod -R u+w "$clipDir"
    entryQml="$clipDir/ClipboardEntry.qml"
    perl -0pi -e 's/(switch \(entryType\) \{.*?\n                \}\n)/$1                visible: entryType !== "text"\n/s' "$entryQml"
    sed -i \
      -e 's/maximumLineCount: entryType === "long_text" ? 3 : 1/maximumLineCount: 2/' \
      "$entryQml"
    grep -q 'visible: entryType !== "text"' "$entryQml"
    grep -q 'maximumLineCount: 2' "$entryQml"
    # Negative guard: "maximumLineCount: 2" alone is weak-positive
    # (upstream could carry it independently) — also assert the OLD
    # upstream expression is GONE, so a silently-skipped sed fails.
    if grep -q 'maximumLineCount: entryType === "long_text" ? 3 : 1' "$entryQml"; then
      echo "clipboard patch drift: sed target survived" >&2
      exit 1
    fi
    constQml="$clipDir/ClipboardConstants.qml"
    sed -i \
      -e 's/property int modalWidth: 650/property int modalWidth: 880/' \
      -e 's/property int modalHeight: 550/property int modalHeight: 620/' \
      -e 's/property int itemHeight: 72/property int itemHeight: 68/' \
      "$constQml"
    grep -q 'modalWidth: 880' "$constQml"
    grep -q 'modalHeight: 620' "$constQml"
    grep -q 'itemHeight: 68' "$constQml"
  '';
})
