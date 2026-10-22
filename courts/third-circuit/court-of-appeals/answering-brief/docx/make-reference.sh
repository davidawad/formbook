#!/usr/bin/env bash
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): TeX Gyre Schola 14 pt (the typst template's font); Body Text and List Item in
# 31.8 pt line boxes (typst pitch-double, FRAP 32(a)(4)) with a half-inch indent; quotations, footnotes and the heading
# styles in 20.4 pt boxes (typst pitch-single), quotations 14 pt above and below, 7 pt after each footnote (ca3.lua sets
# every heading's own spacing; the styles give the outline levels). Page setup and footers come from ca3.lua's sections
# and fb render. One style is added: Body Text Noted, Body Text without widow control, for a paragraph that holds a
# footnote (typst moves the line with the reference to the next page with its note, even when that leaves a widow).
# Usage: bash docx/make-reference.sh   (needs pandoc, perl, unzip, zip, xmllint)
set -euo pipefail
D=$(cd "$(dirname "$0")"; pwd)
OUT="$D/reference.docx"
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$OUT" \
  font="TeX Gyre Schola" size=28 body=636 single=408 indent=720 quote=280 note_after=140 > /dev/null
# The added style goes into word/styles.xml in place: the part is taken out into a scratch folder beside this script,
# edited and put back (zip replaces that entry), and the scratch folder is emptied and removed file by file.
W="$D/.reference-build"
mkdir "$W" "$W/word"
trap 'rm -f "$W/word/styles.xml"; rmdir "$W/word" "$W"' EXIT
unzip -p "$OUT" word/styles.xml > "$W/word/styles.xml"
perl -0pi -e 's{(<w:style [^>]*w:styleId="BlockText")}{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyTextNoted"><w:name w:val="Body Text Noted"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:widowControl w:val="0"/></w:pPr></w:style>$1}s or die "BodyTextNoted"' "$W/word/styles.xml"
xmllint --noout "$W/word/styles.xml"
cd "$W"
zip -X -q "$OUT" word/styles.xml
echo "$OUT"
