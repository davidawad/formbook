#!/bin/sh
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh): Times New Roman 14 pt (CAVC-FORM-004; the family the typst template names);
# Body Text and List Item in 29.4 pt line boxes (typst pitch-double, CAVC-FORM-003) with a half-inch indent;
# quotations and footnotes in 17 pt boxes (typst pitch-single); the heading styles in 20 pt boxes (cavc.lua sets
# every heading's own spacing; the styles give the outline levels).
# One change to the recipe: a footnote may run over to the next page (Footnote Text without keepLines), as typst
# sets a note that does not fit: the recipe keeps a note whole, which moves it off its reference's page.
# Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$OUT" \
  font="Times New Roman" size=28 body=588 single=340 indent=720 heading=400 >/dev/null
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
(cd "$T" && unzip -q "$OUT")
perl -0pi -e 's{(<w:style [^>]*w:styleId="FootnoteText".*?<w:pPr>)\s*<w:keepLines/>}{$1}s or die "FootnoteText"' "$T/word/styles.xml"
xmllint --noout "$T/word/styles.xml"
rm -f "$OUT"
(cd "$T" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
