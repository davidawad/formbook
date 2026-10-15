#!/bin/sh
# txwd motion with brief, DOCX engine (docs/DOCX.md, "Engines"): pandoc with reference.docx and
# txwd-motion-brief.lua, in two passes, so the table of contents carries real page numbers.
#   pass 1: pandoc writes the TOC entries with the placeholder ZZ and the list of headings; soffice renders it.
#           Each heading is found on its page of that PDF; the TOC occurrence (followed by the ZZ placeholder)
#           is skipped, so the first body occurrence counts.
#   pass 2: pandoc writes the TOC entries with those page numbers.
# The list definitions pandoc writes are patched (bullets in the body font, indents as typst).
# Usage: sh docx/render.sh <court-dir> <sample.md> <out.docx>    (render-docx.sh calls this when it exists)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-soffice}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$COURT"

# $1 = output docx; the environment decides the TOC pass (TXWD_TOC_LIST, TXWD_TOC_PAGES)
build() {
  pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" --lua-filter="$D/txwd-motion-brief.lua" "$SAMPLE" -o "$W/raw.docx"
  rm -rf "$W/pkg" && mkdir "$W/pkg" && (cd "$W/pkg" && unzip -q "$W/raw.docx")
  (cd "$W/pkg" && perl -0pi -e '
    my $font = q{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>};
    s{<w:rFonts w:ascii="(?:Courier New|Symbol|Wingdings)"[^>]*/>}{$font}g;
    s{<w:lvl w:ilvl="(\d+)"([^>]*)>(.*?)</w:lvl>}{
      my ($l, $a, $b) = ($1, $2, $3);
      if ($b =~ /numFmt w:val="bullet"/) { $b =~ s{<w:lvlText w:val="[^"]*"}{<w:lvlText w:val="&#x2022;"}; }
      my $left = 1152 + 720 * $l;
      $b =~ s{<w:ind [^>]*/>}{<w:ind w:left="$left" w:hanging="432"/>};
      "<w:lvl w:ilvl=\"$l\"$a>$b</w:lvl>";
    }ge;
  ' word/numbering.xml && xmllint --noout word/numbering.xml)
  rm -f "$1"
  (cd "$W/pkg" && zip -q -X -r "$1" '[Content_Types].xml' . -x '[Content_Types].xml')
}

# pass 1
TXWD_TOC_LIST="$W/headings.txt" build "$W/p1.docx"
"$SOFFICE" "-env:UserInstallation=file://$W/profile1" --headless --convert-to pdf --outdir "$W" "$W/p1.docx" > "$W/soffice1.log" 2>&1 || {
  cat "$W/soffice1.log" >&2
  exit 1
}
[ -f "$W/p1.pdf" ] || { echo "render.sh: first pass PDF was not written" >&2; exit 1; }

# page texts, one line per page, whitespace collapsed, ligatures spelled out
pdftotext -enc UTF-8 "$W/p1.pdf" - | awk 'BEGIN { RS = "\f" } {
  gsub(/\n/, " "); gsub(/[ \t]+/, " "); gsub(/ﬁ/, "fi"); gsub(/ﬂ/, "fl"); gsub(/ﬀ/, "ff")
  sub(/^ /, ""); sub(/ $/, "")
  if ($0 != "") print
}' > "$W/pages.txt"

awk 'FNR == NR { H[++nh] = $0; next }
{ P[++np] = $0 }
END {
  q = 1
  for (i = 1; i <= nh; i++) {
    h = H[i]; hit = 0
    if (h == "") { print "render.sh: empty heading in the list" > "/dev/stderr"; exit 1 }
    for (pg = q; pg <= np && !hit; pg++) {
      s = P[pg]; base = 0
      while ((pos = index(substr(s, base + 1), h)) > 0) {
        at = base + pos
        rest = substr(s, at + length(h))
        if (rest !~ /^[ .]*ZZ/) { res[i] = pg; q = pg; hit = 1; break }
        base = at + length(h) - 1
      }
    }
    if (!hit) { print "render.sh: heading not found in the first pass: " h > "/dev/stderr"; exit 1 }
  }
  for (i = 1; i <= nh; i++) print res[i]
}' "$W/headings.txt" "$W/pages.txt" > "$W/pages.nums" || exit 1

# pass 2
TXWD_TOC_PAGES="$W/pages.nums" build "$W/final.docx"
mv "$W/final.docx" "$OUT"
echo "$OUT"
