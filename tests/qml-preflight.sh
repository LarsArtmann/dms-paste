#!/usr/bin/env bash
# QML syntax preflight: parse-checks every plugin .qml with qmllint.
# Type resolution is intentionally disabled (Quickshell/QtQuick types are
# not resolvable outside a live DMS shell), so this gate catches syntax
# errors only — a parse-broken plugin cannot ship, a semantic quirk still
# needs the daily driver. Usage: qml-preflight.sh <plugin-dir>
set -euo pipefail
dir=${1:?usage: qml-preflight.sh <plugin-dir>}
command -v qmllint >/dev/null || {
	echo "qml-preflight: qmllint not found (nix develop puts it on PATH)" >&2
	exit 1
}

shopt -s nullglob
files=("$dir"/*.qml)
[ ${#files[@]} -gt 0 ] || {
	echo "qml-preflight: no .qml files under $dir" >&2
	exit 1
}

qmllint \
	--ignore-settings \
	--import disable \
	--missing-type disable \
	--missing-property disable \
	--unqualified disable \
	--unresolved-type disable \
	"${files[@]}" && echo "qml-preflight: ${#files[@]} file(s) parse clean"
