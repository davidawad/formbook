#!/bin/sh
# Build one sample of the cafc opening-brief LaTeX template. Owns the whole build (docs/EVAL-LOOP.md, "Engines"):
#   sh latex/render.sh <court-dir> <sample.md> <out.pdf>
# pandoc reads the markdown with cafc.lua and writes LaTeX through template.tex; tectonic compiles it. The contents
# and the table of authorities are written to the .aux file and read back in the next pass, so the build runs
# tectonic again until the .aux file stops changing: the page numbers in them are then the pages of this PDF.
# body_pitch is the body baseline pitch of the typst template for this brief (0.94em leading: 31.43 bp).
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
  -V "fontdir=$ROOT/fonts/" -V body_pitch=31.43bp --lua-filter="$L/cafc.lua" "$SAMPLE" -o "$WORK/doc.tex") || exit 1
cd "$WORK"
prev=""
for pass in 1 2 3 4 5; do
  tectonic -X compile --keep-intermediates --keep-logs doc.tex > build.log 2>&1 || {
    cat build.log >&2
    exit 1
  }
  cur=$(cksum < doc.aux)
  if [ "$cur" = "$prev" ]; then
    cp doc.pdf "$OUT"
    exit 0
  fi
  prev=$cur
done
echo "render.sh: the .aux file did not settle in 5 passes" >&2
exit 1
