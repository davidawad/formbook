#!/bin/sh
# docx engine (docs/DOCX.md): the .docx for one sample, built by pandoc from the markdown contract with this
# folder's reference.docx and flmd-motion-brief.lua. Called by tools/render-docx.sh as: sh render.sh <court-dir> <sample.md> <out.docx>
# "~ " is an unnumbered paragraph in this contract, so pandoc's definition-list syntax (which also uses "~") is off.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in
  /*) ;;
  *) OUT=$(pwd)/$OUT ;;
esac
cd "$COURT"
pandoc --from markdown+smart-definition_lists --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/flmd-motion-brief.lua" "$SAMPLE" -o "$OUT"
