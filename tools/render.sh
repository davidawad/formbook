#!/bin/sh
# Render one sample to PDF with the court's typst template.
# Usage: tools/render.sh <court-dir> <sample.md, relative to the court dir> [out.pdf]
# Fonts are the vendored ones only (--ignore-system-fonts): a missing font is an error,
# never a silent fallback. Any typst warning is treated as a failure.
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=${3:-$COURT/samples/$(basename "$SAMPLE" .md).pdf}
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
