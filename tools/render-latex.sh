#!/bin/sh
# Render one sample to PDF with the court's LaTeX template (engine "latex").
# Usage: tools/render-latex.sh <court-dir> <sample.md, relative to the court dir> [out.pdf]
# Default out: <court>/samples/<id>.latex.pdf
#
# Contract (docs/EVAL-LOOP.md, "Engines"):
#   <court>/latex/render.sh     if present, it owns the build: sh render.sh <court-dir> <sample.md> <out.pdf>
#   <court>/latex/template.tex  otherwise: pandoc --to latex --template, plus every <court>/latex/*.lua as a
#                               filter, then tectonic (default) or xelatex (LATEX_ENGINE=xelatex).
# The template must load fonts from the vendored directory, passed to it as the pandoc variable `fontdir`
# (trailing slash), e.g. \setmainfont{EBGaramond-Regular}[Path=$fontdir$, Extension=.ttf]. Gate 1 asserts the
# embedded font names, so a silent fallback fails the check.
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=${3:-$COURT/samples/$(basename "$SAMPLE" .md).latex.pdf}
L="$COURT/latex"
if [ -f "$L/render.sh" ]; then
  sh "$L/render.sh" "$COURT" "$SAMPLE" "$OUT" >&2 || exit 1
  [ -f "$OUT" ] || {
    echo "render-latex.sh: $L/render.sh did not write $OUT" >&2
    exit 1
  }
  echo "$OUT"
  exit 0
fi
[ -f "$L/template.tex" ] || {
  echo "render-latex.sh: no latex template ($L/template.tex or $L/render.sh)" >&2
  exit 1
}
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
filters=""
for f in "$L"/*.lua; do [ -e "$f" ] && filters="$filters --lua-filter=$f"; done
# shellcheck disable=SC2086
(cd "$COURT" && pandoc --from markdown+smart --to latex --standalone --template="$L/template.tex" \
  -V "fontdir=$ROOT/fonts/" $filters "$SAMPLE" -o "$WORK/doc.tex") || exit 1
case ${LATEX_ENGINE:-tectonic} in
  tectonic) (cd "$WORK" && tectonic -X compile --keep-logs doc.tex > build.log 2>&1) || {
    cat "$WORK/build.log" >&2
    exit 1
  } ;;
  xelatex) (cd "$WORK" && xelatex -interaction=nonstopmode -halt-on-error doc.tex > build.log 2>&1 &&
    xelatex -interaction=nonstopmode -halt-on-error doc.tex >> build.log 2>&1) || {
    tail -40 "$WORK/build.log" >&2
    exit 1
  } ;;
  *)
    echo "render-latex.sh: unknown LATEX_ENGINE" >&2
    exit 2
    ;;
esac
cp "$WORK/doc.pdf" "$OUT"
echo "$OUT"
