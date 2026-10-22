#!/usr/bin/env bash
# Builds docx/reference.docx with the shared style recipe of the cross-engine layout model
# (lib/docx/xengine-reference.sh; docs/EVAL-LOOP.md, "Cross-engine gate"): Times New Roman 12 pt (RCFC 5.5(c)(2));
# Body Text in exact 27.6 pt line boxes (RCFC 5.5(c)(4), double spaced; typst pitch-double) with a half-inch
# first-line indent; headings, footnotes and quotations in 13.8 pt boxes (typst pitch-single), a heading 27.6 pt
# below the text before it and 13.8 pt above the text after it; letter page with 1-inch margins (RCFC 5.5(c)(1)(A),
# (c)(3)) and a centred page-number footer (RCFC 5.5(c)(6)). Twips = 20 x the typst points.
# The caption, signature, certificate and prayer paragraphs carry their own spacing (docx/uscfc-complaint.lua).
# Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -euo pipefail
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$OUT" font="Times New Roman" size=24 body=552 single=276 \
  indent=720 heading=276 heading_before=552 heading_after=276 quote=276 note_after=120 >/dev/null
# One style of this template's own: "Body Text Note", Body Text without widow control, for a paragraph that anchors a
# footnote. typst moves the line that holds a footnote mark to the next page with its note when the note does not
# fit, even if that leaves the line alone there; Word would move the whole paragraph (docx/uscfc-complaint.lua).
T=$(mktemp -d) || exit 1
# safe_rmdir <dir>: delete a directory made by mktemp -d (or one inside it), and nothing else
safe_rmdir() {
  t=${TMPDIR:-/tmp}
  case "${1:?}" in
    "${t%/}"/tmp.* | /tmp/tmp.*) find "$1" -depth -delete ;;
    *) return 1 ;;
  esac
}
trap 'safe_rmdir "$T"' EXIT
(cd "$T" && unzip -q "$OUT")
perl -0pi -e 's{</w:styles>}{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyTextNote"><w:name w:val="Body Text Note"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:widowControl w:val="0"/></w:pPr></w:style></w:styles>}s or die "styles"' "$T/word/styles.xml"
xmllint --noout "$T/word/styles.xml"
rm -f "$OUT"
(cd "$T" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
