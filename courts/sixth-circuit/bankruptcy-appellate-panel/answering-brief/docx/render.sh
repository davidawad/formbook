#!/bin/sh
# Owns the .docx build for this doc type (tools/render-docx.sh calls it when present; docs/EVAL-LOOP.md, "Engines").
# Usage: sh docx/render.sh <doc-dir> <sample.md, relative to the doc dir> <out.docx>
# 1. pandoc with docx/reference.docx and docx/bap6-brief.lua (cover, front matter, certificates, TOC/TOA/TA fields)
# 2. the section breaks written by the filter name their footer as rIdBapFooter1; pandoc gives the footer
#    its own relationship id in the output, so that id is looked up and substituted here.
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
case $3 in /*) OUT=$3 ;; *) OUT=$(pwd)/$3 ;; esac
D="$COURT/docx"
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/bap6-brief.lua" "$SAMPLE" -o "$W/pandoc.docx") || exit 1
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/pandoc.docx"
RID=$(perl -ne 'while (/<Relationship [^>]*>/g) { my $r = $&; next unless $r =~ /\/footer"/ || $r =~ /Target="footer[0-9]*\.xml"/; ($id) = $r =~ /Id="([^"]+)"/; print "$id\n" }' word/_rels/document.xml.rels | head -n 1)
if [ -z "$RID" ]; then
  echo "render.sh: pandoc wrote no footer relationship; the page numbers would be missing" >&2
  exit 1
fi
perl -pi -e "s/rIdBapFooter1/$RID/g" word/document.xml
rm -f "$OUT"
zip -q -X -r "$OUT" '[Content_Types].xml' _rels docProps word
echo "$OUT"
