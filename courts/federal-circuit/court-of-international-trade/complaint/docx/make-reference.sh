#!/usr/bin/env bash
# Build docx/reference.docx for the CIT complaint on the shared cross-engine style recipe
# (lib/docx/xengine-reference.sh; docs/EVAL-LOOP.md, "Cross-engine gate"): Times New Roman 12 pt, Body Text at the
# 24 pt body pitch with a 0.5 in first-line indent, single lines at 14 pt, letter paper, 1 in margins, a centered page
# number in a 14 pt line. Same numbers as typst/cit-complaint.typ (pitch, pitch-single, para-indent); every paragraph
# the filter writes carries its own spacing and indents. The footer sits where typst puts it: its 14 pt line box
# 1.2 in + 0.3 x 1 in below the top of the bottom margin, i.e. 36.4 pt (728 twips) above the page edge.
# Usage: sh make-reference.sh <out.docx>   (needs pandoc, perl, unzip, zip, xmllint)
set -euo pipefail
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
W=$(mktemp -d) || exit 1
# safe_rmdir <dir>: delete a directory made by mktemp -d (or one inside it), and nothing else
safe_rmdir() {
  t=${TMPDIR:-/tmp}
  case "${1:?}" in
    "${t%/}"/tmp.* | /tmp/tmp.*) find "$1" -depth -delete ;;
    *) return 1 ;;
  esac
}
trap 'safe_rmdir "$W"' EXIT
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$W/ref.docx" font="Times New Roman" size=24 body=480 \
  single=280 indent=720 list=576 heading=480 heading_before=240 heading_after=0 footer=728 >/dev/null
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx
# the page number in a single-pitch line box (typst: text(..edges(pitch-single)))
perl -0pi -e 's{<w:pPr><w:jc w:val="center" /></w:pPr>}{<w:pPr><w:spacing w:before="0" w:after="0" w:line="280" w:lineRule="exact"/><w:jc w:val="center"/></w:pPr>} or die "footer"' word/footer1.xml
xmllint --noout word/footer1.xml
rm -f "$OUT"
zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word
echo "$OUT"
