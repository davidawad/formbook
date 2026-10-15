#!/bin/sh
# Builds the motion-brief .docx (the contract of tools/render-docx.sh: sh render.sh <court-dir> <sample.md> <out.docx>).
# pandoc (fancy_lists off: "(a) text" stays text, as in typst) with reference.docx and nyeb-motion-brief.lua; then the footer's matter number from the frontmatter
# (matter_number, when the sample gives one), so the footer matches typst's. Needs pandoc, perl.
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
case $SAMPLE in /*) ;; *) SAMPLE=$COURT/$SAMPLE ;; esac
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
MATTER=$(sed -n 's/^matter_number: *"\{0,1\}\([^"]*\)"\{0,1\} *$/\1/p' "$SAMPLE" | head -n 1)
(cd "$COURT" && pandoc --from markdown+smart-fancy_lists --to docx --reference-doc="$HERE/reference.docx" \
  --lua-filter="$HERE/nyeb-motion-brief.lua" "$SAMPLE" -o "$W/out.docx")
perl "$HERE/pkg.pl" unpack "$W/out.docx" "$W/pkg"
MATTER="$MATTER" perl -0pi -e 'my $m = $ENV{MATTER}; $m =~ s/&/&amp;/g; $m =~ s/</&lt;/g; $m =~ s/>/&gt;/g; s/MATTERNUMBER/$m/' "$W/pkg/word/footer1.xml"
xmllint --noout "$W/pkg/word/footer1.xml"
perl "$HERE/pkg.pl" pack "$W/pkg" "$OUT"
echo "$OUT"
