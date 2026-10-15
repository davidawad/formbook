#!/bin/sh
# Build one sample of the opening-brief LaTeX template. Owns the whole build (docs/EVAL-LOOP.md, "Engines"):
#   sh latex/render.sh <court-dir> <sample.md> <out.pdf>
# pandoc reads the markdown with cadc.lua and writes LaTeX through template.tex; tectonic compiles it. The table of
# contents and the table of authorities are written to the aux and toc files and read back in the next pass, so
# tectonic runs again until both files stop changing: the page numbers in them are then the pages of this PDF.
set -eu
L=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$L/../../../../.." && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$(cd "$(dirname "$3")" && pwd)/$(basename "$3")
# A fixed date makes the PDF bytes depend only on the markdown and the template (the review records a sha256).
export SOURCE_DATE_EPOCH=${SOURCE_DATE_EPOCH:-1767225600}
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
(cd "$COURT" && pandoc --from markdown+smart --to latex --standalone --template="$L/template.tex" \
  -V "fontdir=$ROOT/fonts/" --lua-filter="$L/cadc.lua" "$SAMPLE" -o "$WORK/doc.tex") || exit 1
cd "$WORK"
prev=""
for pass in 1 2 3 4 5; do
  tectonic -X compile --keep-intermediates --keep-logs doc.tex > build.log 2>&1 || {
    cat build.log >&2
    exit 1
  }
  cur=$(cat doc.aux doc.toc 2>/dev/null | cksum)
  if [ "$cur" = "$prev" ]; then
    cp doc.pdf "$OUT"
    exit 0
  fi
  prev=$cur
done
echo "render.sh: the aux and toc files did not settle in 5 passes" >&2
exit 1
