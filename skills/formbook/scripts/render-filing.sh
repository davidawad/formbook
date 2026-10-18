#!/bin/sh
# render-filing.sh: render a markdown file that lives OUTSIDE the court folder.
# Usage (from the repo root): sh skills/formbook/scripts/render-filing.sh <doctype-dir> <filing.md> [out.pdf]
# tools/render.sh reads the sample relative to the doc-type folder (typst --root), so this wrapper stages
# a temporary copy at <doctype-dir>/.staged-<pid>.md (outside usage/, so `fb lint paths` never sees it), calls tools/render.sh (vendored fonts, warnings fail), moves the
# PDF to out.pdf (default: next to filing.md), and removes the staged copy. Nothing is left in the repo.
set -eu
[ $# -ge 2 ] || { echo "usage: sh skills/formbook/scripts/render-filing.sh <doctype-dir> <filing.md> [out.pdf]" >&2; exit 2; }
DIR=$1
SRC=$(cd "$(dirname "$2")" && pwd)/$(basename "$2")
OUT=${3:-${SRC%.md}.pdf}
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
[ -f "$DIR/typst/main.typ" ] || { echo "render-filing.sh: $DIR has no typst/main.typ" >&2; exit 2; }
STAGE=$DIR/.staged-$$.md
trap 'rm -f "$STAGE"' EXIT INT TERM
cp "$SRC" "$STAGE"
sh tools/render.sh "$DIR" ".staged-$$.md" "$OUT"
