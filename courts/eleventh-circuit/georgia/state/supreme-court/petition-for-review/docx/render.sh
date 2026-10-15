#!/bin/sh
# Renders one sample to a .docx for the Georgia Supreme Court brief (docs/DOCX.md, "Checking a docx").
# Called by tools/render-docx.sh: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
#
# Two pandoc runs with docx/*.lua and docx/reference.docx:
#   pass 1  GA_PASS=1: the body headings and citations carry 1-pt white markers (zqh<n>zq, zqa<k>zq);
#           the LibreOffice PDF of pass 1 gives the body page of each marker (its printed folio);
#   pass 2  GA_PAGES=<those pages>: the TOC and TOA get the numbers, the markers are gone.
# Then the footer reference that the filter wrote (rIdGaFooter) is replaced by the id pandoc gave the footer.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

FILTERS=""
for f in "$D"/*.lua; do
  [ -e "$f" ] && FILTERS="$FILTERS --lua-filter=$f"
done

run_pandoc() { # run_pandoc <out.docx> [VAR=value ...]
  OUTDOCX=$1
  shift
  # shellcheck disable=SC2086
  (cd "$COURT" && env "$@" pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" $FILTERS "$SAMPLE" -o "$OUTDOCX")
}

run_pandoc "$W/pass1.docx" GA_PASS=1
"$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" > "$W/soffice.log" 2>&1 || {
  cat "$W/soffice.log" >&2
  exit 1
}
[ -f "$W/pass1.pdf" ] || {
  echo "render.sh: LibreOffice did not write $W/pass1.pdf" >&2
  exit 1
}

# the markers, page by page: "<key><TAB><folio>", where the folio is the page's printed number
N=$(pdfinfo "$W/pass1.pdf" | awk '/^Pages:/{print $2}')
: > "$W/markers.txt"
p=1
while [ "$p" -le "$N" ]; do
  pdftotext -layout -f "$p" -l "$p" "$W/pass1.pdf" "$W/page.txt"
  # the folio is the last line that is only digits (the markers sit elsewhere on the page)
  folio=$(awk '/^[ \t]*[0-9]+[ \t]*$/{f=$1} END{print f}' "$W/page.txt")
  case $folio in
    '' | *[!0-9]*) folio="" ;;
  esac
  if [ -n "$folio" ]; then
    grep -o 'zq[ha][0-9]*zq' "$W/page.txt" | sed 's/^zq\([ha][0-9]*\)zq$/\1/' |
      awk -v f="$folio" '{print $0 "\t" f}' >> "$W/markers.txt" || true
  fi
  p=$((p + 1))
done

# pages.txt: "h<n><TAB>folio" (first page of the heading) and "a<k><TAB>folio, folio" (7 or more: passim)
sort -u -t "$(printf '\t')" -k1,1 -k2,2n "$W/markers.txt" > "$W/sorted.txt"
awk -F'\t' '
  $1 ~ /^h/ { if (!($1 in h)) h[$1] = $2; next }
  { n[$1]++; list[$1] = (($1 in list) ? list[$1] ", " $2 : $2) }
  END {
    for (k in h) printf "%s\t%s\n", k, h[k]
    for (k in n) printf "%s\t%s\n", k, (n[k] >= 7 ? "passim" : list[k])
  }' "$W/sorted.txt" > "$W/pages.txt"

run_pandoc "$W/pass2.docx" GA_PAGES="$W/pages.txt"

# the footer part keeps the reference's name, but pandoc gives it a new relationship id
mkdir "$W/x"
(cd "$W/x" && unzip -q "$W/pass2.docx")
RID=$(grep -o '<Relationship [^>]*>' "$W/x/word/_rels/document.xml.rels" | grep 'footer-ga.xml' | grep -o 'Id="[^"]*"' | cut -d'"' -f2)
[ -n "$RID" ] || {
  echo "render.sh: no footer relationship for footer-ga.xml in the docx" >&2
  exit 1
}
sed -i "s/rIdGaFooter/$RID/g" "$W/x/word/document.xml"
# a table row (the caption, counsel and signature grids) is not split across a page
sed -i 's|<w:tr>|<w:tr><w:trPr><w:cantSplit/></w:trPr>|g' "$W/x/word/document.xml"
# list bullets: pandoc writes its own numbering, whose bullets are private-use glyphs in the Symbol font (not vendored);
# they become a bullet in the court face, and every other list font becomes the court face too
perl -CSD -pi -e 's/[\x{E000}-\x{F8FF}]/\x{2022}/g; s/w:(ascii|hAnsi)="[^"]*"/w:$1="TeX Gyre Schola"/g' "$W/x/word/numbering.xml"
xmllint --noout "$W/x/word/document.xml"
rm -f "$OUT"
(cd "$W/x" && zip -q -X "$OUT" '[Content_Types].xml' && zip -q -X -r "$OUT" . -x '[Content_Types].xml')
unzip -tq "$OUT" > /dev/null
echo "$OUT"
