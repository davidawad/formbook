#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference: EB Garamond 14 point, double spacing,
# black headings, US Letter with 1 inch margins. Run once (needs pandoc, unzip, zip); the result is committed.
# Usage: sh docx/make-reference.sh   (from the doc-type folder)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref0.docx" --print-default-data-file reference.docx
unzip -q "$W/ref0.docx" -d "$W/x"
S="$W/x/word/styles.xml"
sed -i \
  -e 's#<w:rFonts [^>]*/>#<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />#g' \
  -e 's#<w:sz w:val="[0-9]*" />#<w:sz w:val="28" />#g' \
  -e 's#<w:szCs w:val="[0-9]*" />#<w:szCs w:val="28" />#g' \
  -e 's#<w:spacing w:after="200" />#<w:spacing w:after="0" w:line="480" w:lineRule="auto" />#' \
  -e 's#<w:color w:val="[0-9A-Fa-f]*"[^/]*/>#<w:color w:val="000000" />#g' \
  "$S"
DOC="$W/x/word/document.xml"
sed -i 's#</w:footnotePr>#</w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />#' "$DOC"
rm -f "$D/reference.docx"
(cd "$W/x" && zip -q -X -r "$D/reference.docx" .)
echo "$D/reference.docx"
