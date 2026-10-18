#!/bin/sh
# Render one sample to PDF with the doc folder's typst template (default) or another engine.
# Usage: tools/render.sh [--engine typst|latex|docx] <doc-dir> <usage/INPUT-<stem>-<id>.md, relative to the doc dir> [out.pdf]
# Default out: <doc-dir>/usage/OUTPUT-<stem>-<id>.typst.pdf (INPUT and OUTPUT share <stem>-<id>)
#   latex -> tools/render-latex.sh (OUTPUT-<stem>-<id>.latex.pdf)
#   docx  -> tools/render-docx.sh  (OUTPUT-<stem>-<id>.docx and .docx.pdf; the PDF is the LibreOffice conversion)
# Typst: fonts are the vendored ones only (--ignore-system-fonts): a missing font is an error,
# never a silent fallback. Any typst warning is treated as a failure.
set -eu
ENGINE=typst
if [ "${1:-}" = --engine ]; then
  ENGINE=$2
  shift 2
fi
ROOT=$(cd "$(dirname "$0")/.." && pwd)
case $ENGINE in
  typst) ;;
  latex) exec sh "$ROOT/tools/render-latex.sh" "$@" ;;
  docx) exec sh "$ROOT/tools/render-docx.sh" "$@" ;;
  *)
    echo "render.sh: unknown engine $ENGINE" >&2
    exit 2
    ;;
esac
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=${3:-$COURT/usage/$(basename "$SAMPLE" .md | sed 's/^INPUT-/OUTPUT-/').typst.pdf}
LOG=$(mktemp)
typst compile --root "$COURT" \
  --font-path "$ROOT/fonts" --ignore-system-fonts \
  --package-cache-path "$ROOT/vendor/typst-packages" \
  --input "sample=$SAMPLE" "$COURT/typst/main.typ" "$OUT" 2> "$LOG" ||
  {
    cat "$LOG" >&2
    rm -f "$LOG"
    exit 1
  }
if [ -s "$LOG" ]; then
  cat "$LOG" >&2
  rm -f "$LOG"
  echo "render.sh: typst emitted warnings; treating as failure" >&2
  exit 1
fi
rm -f "$LOG"
echo "$OUT"
