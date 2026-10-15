#!/bin/sh
# docx engine for the motion brief: tools/render-docx.sh hands the .docx to this script (docs/DOCX.md).
# pandoc builds the .docx from the sample with docx/iasd-motion-brief.lua and docx/reference.docx. The filter writes the
# front matter's section footer as a placeholder (rIdFooterFront); pandoc renumbers relationship IDs, so the placeholder
# is pointed at the footer part pandoc wrote. Then the package is zipped again.
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$(cd "$(dirname "$3")" && pwd)/$(basename "$3")
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/iasd-motion-brief.lua" "$SAMPLE" -o "$T/pandoc.docx") || exit 1
mkdir "$T/x"
(cd "$T/x" && unzip -q "$T/pandoc.docx")
RID=$(sed 's/></>\n</g' "$T/x/word/_rels/document.xml.rels" | grep 'relationships/footer"' | head -n 1 | grep -o 'Id="[^"]*"' | cut -d'"' -f2)
[ -n "$RID" ] || {
  echo "render.sh: pandoc wrote no footer part" >&2
  exit 1
}
perl -pi -e "s/rIdFooterFront/$RID/g" "$T/x/word/document.xml"
rm -f "$OUT"
(cd "$T/x" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
