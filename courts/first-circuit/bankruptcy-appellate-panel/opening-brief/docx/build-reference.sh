#!/usr/bin/env bash
# Builds docx/reference.docx: the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): the typst template's face at 14 pt, Body Text and List Item in 31.4 pt line boxes
# with a half-inch indent (typst pitch-double, BAP-FORM-004), Block Text and footnotes in 20 pt boxes (pitch-single),
# exact line spacing; plus one style of its own, "BAP First": a body paragraph that does not follow another
# paragraph (after a heading, a list or a quotation), which typst does not indent. bap1.lua writes the cover,
# headings, tables, signature blocks and statements as paragraphs with their own spacing; fb render
# (tools/fb/src/docxpass.rs) writes the sections' footers. The same file is in each doc-type folder.
# Usage: bash docx/build-reference.sh    (needs pandoc, unzip, zip, perl, xmllint)
set -euo pipefail
FONT="Times New Roman"   # the typst template's font-family (its first face)
D=$(cd "$(dirname "$0")"; pwd)
OUT="$D/reference.docx"
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$OUT" font="$FONT" size=28 body=628 single=400 indent=720 \
  > /dev/null
# The added style goes into word/styles.xml in place: the part is taken out into a scratch folder beside this script,
# edited and put back (zip replaces that entry), and the scratch folder is emptied and removed file by file.
W="$D/.reference-build"
mkdir "$W" "$W/word"
trap 'rm -f "$W/word/styles.xml"; rmdir "$W/word" "$W"' EXIT
unzip -p "$OUT" word/styles.xml > "$W/word/styles.xml"
perl -0pi -e 's{</w:styles>}{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BAPFirst"><w:name w:val="BAP First"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style></w:styles>} or die "styles"' "$W/word/styles.xml"
xmllint --noout "$W/word/styles.xml"
cd "$W"
zip -X -q "$OUT" word/styles.xml
echo "$OUT"
