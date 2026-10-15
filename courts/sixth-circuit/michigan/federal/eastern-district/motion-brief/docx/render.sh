#!/bin/sh
# Court-owned DOCX build for the E.D. Mich. motion to dismiss with brief (docs/EVAL-LOOP.md, "Engines").
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# pandoc writes the document with reference.docx and the Lua filters; the filter's section breaks name their footers
# by placeholder (FOOTER_PAGE, FOOTER_BLANK). Here they are replaced by the relationship ids pandoc gives the footer
# parts (found by their targets), so the sections point at the right footers. The zip is rebuilt with
# [Content_Types].xml first and no duplicate entries.
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
filters=""
for f in "$D"/*.lua; do [ -e "$f" ] && filters="$filters --lua-filter=$f"; done
# shellcheck disable=SC2086
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" $filters "$SAMPLE" -o "$W/raw.docx")
mkdir "$W/pkg"
(cd "$W/pkg" && unzip -q "$W/raw.docx")
PKG="$W/pkg"
PAGE=$(perl -0ne 'while (m{<Relationship\b[^>]*>}g) { my $r = $&; if ($r =~ m{Target="footer1\.xml"} && $r =~ m{Id="([^"]+)"}) { print $1; last } }' "$PKG/word/_rels/document.xml.rels")
BLANK=$(perl -0ne 'while (m{<Relationship\b[^>]*>}g) { my $r = $&; if ($r =~ m{Target="footer2\.xml"} && $r =~ m{Id="([^"]+)"}) { print $1; last } }' "$PKG/word/_rels/document.xml.rels")
[ -n "$PAGE" ] && [ -n "$BLANK" ] || { echo "render.sh: footer parts not found in the pandoc output" >&2; exit 1; }
perl -0pi -e "s/r:id=\"FOOTER_PAGE\"/r:id=\"$PAGE\"/g; s/r:id=\"FOOTER_BLANK\"/r:id=\"$BLANK\"/g" "$PKG/word/document.xml"
if grep -q 'FOOTER_' "$PKG/word/document.xml"; then echo "render.sh: a footer placeholder was not replaced" >&2; exit 1; fi
rm -f "$OUT"
(cd "$PKG" && zip -q -X "$OUT" '[Content_Types].xml' && zip -q -X -r "$OUT" $(ls -A | grep -v "^\[Content_Types\]\.xml$"))
echo "$OUT"
