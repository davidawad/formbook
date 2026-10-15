#!/bin/sh
# txwd complaint, DOCX engine (docs/DOCX.md, "Engines"): pandoc with reference.docx and txwd-complaint.lua,
# then one patch to the list definitions pandoc writes (its bullets are Courier New "o" and Symbol/Wingdings
# marks; the typst form draws a bullet and a dash in the body font, and indents numbers at 0.5 in).
# Usage: sh docx/render.sh <court-dir> <sample.md> <out.docx>    (render-docx.sh calls this when it exists)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$COURT"
pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" --lua-filter="$D/txwd-complaint.lua" "$SAMPLE" -o "$W/raw.docx"
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/raw.docx"
perl -0pi -e '
  my $font = q{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>};
  s{<w:rFonts w:ascii="(?:Courier New|Symbol|Wingdings)"[^>]*/>}{$font}g;
  s{<w:lvl w:ilvl="(\d+)"([^>]*)>(.*?)</w:lvl>}{
    my ($l, $a, $b) = ($1, $2, $3);
    if ($b =~ /numFmt w:val="bullet"/) {
      my $g = "&#x2022;";
      $b =~ s{<w:lvlText w:val="[^"]*"}{<w:lvlText w:val="$g"};
    }
    my $left = 1152 + 720 * $l;
    $b =~ s{<w:ind [^>]*/>}{<w:ind w:left="$left" w:hanging="432"/>};
    "<w:lvl w:ilvl=\"$l\"$a>$b</w:lvl>";
  }ge;
' word/numbering.xml
xmllint --noout word/numbering.xml
rm -f "$OUT"
zip -q -X -r "$OUT" '[Content_Types].xml' . -x '[Content_Types].xml'
echo "$OUT"
