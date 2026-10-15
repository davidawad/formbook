#!/bin/sh
# DOCX build for the Fifth Court of Appeals briefs (docs/DOCX.md): owns the .docx (tools/render-docx.sh calls it).
# The contents page carries page numbers, so the build runs in two passes:
#   pass 1: pandoc writes the .docx with placeholder page numbers and lists the contents entries;
#           LibreOffice lays it out; the page of each entry is found in the PDF text, in order
#           (the contents lines come first in the PDF, so entries are matched once in the contents, then again in the body);
#   pass 2: pandoc writes the .docx with those page numbers as the TOC field's cached result;
#           a last LibreOffice layout must give the same pages, or the build fails.
# Usage: sh docx/render.sh <court-dir> <sample.md> <out.docx>
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
D=$(cd "$(dirname "$0")" && pwd)
SOFFICE=${SOFFICE:-soffice}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

# star paging ("at *3") is escaped, or pandoc reads the asterisk as emphasis; the sample file is not changed
sed 's/ \*\([0-9]\)/ \\*\1/g' "$COURT/$SAMPLE" > "$W/sample.md"

# pass 1
(cd "$COURT" && TEXAPP_TOC_LIST="$W/toc.tsv" pandoc --from markdown+smart --to docx \
  --reference-doc="$D/reference.docx" --lua-filter="$D/texapp.lua" "$W/sample.md" -o "$W/pass1.docx") || exit 1
"$SOFFICE" "-env:UserInstallation=file://$W/profile1" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" > "$W/soffice1.log" 2>&1 || {
  cat "$W/soffice1.log" >&2
  exit 1
}
[ -f "$W/pass1.pdf" ] || { echo "render.sh: pass 1 PDF was not written" >&2; exit 1; }

# heading pages from the PDF text: normalized (lower case, letters only), matched line by line
# (a heading may wrap; the first line of it is a prefix of the key, or the line starts with the key)
find_pages() {
  awk -F'\t' '
    function norm(s) {
      s = tolower(s)
      gsub(/\357\254\201/, "fi", s); gsub(/\357\254\202/, "fl", s)
      gsub(/[^a-z]/, "", s)
      return s
    }
    BEGIN { page = 1; k = 1; phase = 0 }
    FNR == NR { n++; key[n] = norm($2); next }
    {
      # pdftotext starts each page after the first with a form feed: the page counts before the line is matched
      line = $0
      page += gsub(/\f/, "", line)
      s = norm(line)
      if (phase < 2 && length(s) >= 6 && (index(key[k], s) == 1 || index(s, key[k]) == 1)) {
        got[phase, k] = page
        k++
        if (k > n) {
          if (phase == 0) { phase = 1; k = 1 } else { phase = 2 }
        }
      }
    }
    END {
      if (phase != 2) { print "render.sh: not every heading was found in the PDF (body matched " (k - 1) " of " n ")" > "/dev/stderr"; exit 1 }
      for (i = 1; i <= n; i++) print got[1, i]
    }
  ' "$1" "$2"
}
pdftotext "$W/pass1.pdf" "$W/pass1.txt"
[ -s "$W/toc.tsv" ] || { echo "render.sh: no contents entries" >&2; exit 1; }
find_pages "$W/toc.tsv" "$W/pass1.txt" > "$W/pages.txt"

# pass 2
(cd "$COURT" && TEXAPP_TOC_PAGES="$W/pages.txt" pandoc --from markdown+smart --to docx \
  --reference-doc="$D/reference.docx" --lua-filter="$D/texapp.lua" "$W/sample.md" -o "$OUT") || exit 1

# pandoc writes its own bullet definitions (a Symbol-font glyph, which LibreOffice draws in OpenSymbol):
# use a bullet in the body font (EB Garamond)
X="$W/unzipped"
mkdir -p "$X"
unzip -q "$OUT" -d "$X"
perl -0pi -e 's{(<w:numFmt w:val="bullet"\s*/>\s*<w:lvlText w:val=")[^"]*("\s*/>)}{$1\xe2\x80\xa2$2}g; s{(<w:numFmt w:val="bullet"\s*/>.*?)</w:pPr>(\s*</w:lvl>)}{$1</w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/></w:rPr>$2}gs' "$X/word/numbering.xml"
rm -f "$W/rebuilt.docx"
(cd "$X" && zip -q -X -r "$W/rebuilt.docx" .) || exit 1
mv "$W/rebuilt.docx" "$OUT"

# the pages must not move: lay out the final file and compare
mkdir -p "$W/check"
"$SOFFICE" "-env:UserInstallation=file://$W/profile2" --headless --convert-to pdf --outdir "$W/check" "$OUT" > "$W/soffice2.log" 2>&1 || {
  cat "$W/soffice2.log" >&2
  exit 1
}
pdftotext "$W/check/$(basename "${OUT%.docx}").pdf" "$W/check.txt"
find_pages "$W/toc.tsv" "$W/check.txt" > "$W/check-pages.txt"
cmp -s "$W/pages.txt" "$W/check-pages.txt" || {
  echo "render.sh: contents page numbers changed between layouts" >&2
  paste "$W/pages.txt" "$W/check-pages.txt" >&2
  exit 1
}
echo "$OUT"
