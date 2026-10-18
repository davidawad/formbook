#!/usr/bin/env bash
# Render one sample to PDF with the doc folder's typst template (default) or another engine.
# Usage: tools/render.sh [--engine typst|latex|docx] <doc-dir> <usage/INPUT-<id>.md, relative to the doc dir> [out.pdf]
# Default out: <doc-dir>/usage/OUTPUT-<id>.typst.pdf (INPUT and OUTPUT share <id> = <doctype>[-<n>])
#   latex -> tools/render-latex.sh (OUTPUT-<id>.latex.pdf)
#   docx  -> tools/render-docx.sh  (OUTPUT-<id>.docx and .docx.pdf; the PDF is the LibreOffice conversion)
# Typst: fonts are the vendored ones only (--ignore-system-fonts): a missing font is an error,
# never a silent fallback. Any typst warning is treated as a failure.
# Strict mode. pipefail only where the shell has it (bash, macOS sh); Debian's dash lacks it.
# shellcheck shell=sh disable=SC3040
set -e -u; (set -o pipefail) 2> /dev/null && set -o pipefail
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
# pinned Times New Roman dirs (macOS, Linux), as fb render pins them; typst skips the absent one
LOG=$(mktemp) || exit 1
trap 'rm -f "$LOG"' EXIT
typst compile --root "$COURT" \
  --font-path "$ROOT/fonts" --ignore-system-fonts \
  --font-path /System/Library/Fonts/Supplemental --font-path /usr/share/fonts/truetype/msttcorefonts \
  --package-cache-path "$ROOT/vendor/typst-packages" \
  --input "sample=$SAMPLE" "$COURT/typst/main.typ" "$OUT" 2> "$LOG" ||
  {
    cat "$LOG" >&2
    exit 1
  }
if [ -s "$LOG" ]; then
  cat "$LOG" >&2
  echo "render.sh: typst emitted warnings; treating as failure" >&2
  exit 1
fi
echo "$OUT"
