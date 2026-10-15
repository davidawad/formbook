#!/bin/sh
# DOCX engine for the NMCCA brief (docs/DOCX.md). Called by tools/render-docx.sh:
#   sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# Pass 1 builds the brief and writes the heading list; LibreOffice lays it out; the page of each heading
# is read from the PDF (the arabic folio of the body page) and pass 2 writes it into the index. Pass 2 is
# laid out again and must give the same pages, or the script fails.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

# pandoc renumbers the relationships of the reference. The cover and index sections name the footer by
# the placeholder rIdNmccaFooter (nmcca.lua); it is replaced here by the id pandoc gave footer1.xml.
footer_rid() { # footer_rid <docx>
  X="$W/fix"
  rm -rf "$X"
  mkdir "$X"
  (cd "$X" && unzip -q "$1")
  rid=$(perl -0ne 'while (/<Relationship [^>]*\/>/g) { my $r = $&; print $1 if $r =~ /Target="footer1.xml"/ and $r =~ / Id="([^"]+)"/ }' "$X/word/_rels/document.xml.rels")
  [ -n "$rid" ] || { echo "render.sh: no footer relationship in $1" >&2; exit 1; }
  perl -pi -e "s/rIdNmccaFooter/$rid/g" "$X/word/document.xml"
  (cd "$X" && zip -q -X "$1" word/document.xml)
}

build() { # build <out.docx> <pages file or empty>
  (cd "$COURT" && NMCCA_HEADINGS="$W/heads.tsv" NMCCA_PAGES="$2" \
    pandoc --from markdown+smart-fancy_lists --to docx --reference-doc="$D/reference.docx" \
    --lua-filter="$D/nmcca.lua" "$SAMPLE" -o "$1")
  footer_rid "$1"
}

# pagemap <docx> <pages out>: the body page of each heading, in document order
pagemap() {
  pdfdir="$W/pdf-$(basename "$1" .docx)"
  mkdir -p "$pdfdir"
  "$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$pdfdir" "$1" > "$W/soffice.log" 2>&1 || {
    cat "$W/soffice.log" >&2
    exit 1
  }
  pdf="$pdfdir/$(basename "$1" .docx).pdf"
  n=$(pdfinfo "$pdf" | awk '/^Pages:/{print $2}')
  : > "$W/body.txt"
  p=1
  while [ "$p" -le "$n" ]; do
    pdftotext -f "$p" -l "$p" -layout "$pdf" - | tr -d "\f" > "$W/pg.txt"
    folio=$(awk 'NF{l=$0} END{gsub(/^[ \t]+|[ \t]+$/,"",l); print l}' "$W/pg.txt")
    case $folio in
      ''|*[!0-9]*) ;;
      *) awk -v P="$folio" '{ l=tolower($0); gsub(/[ \t]+/," ",l); sub(/^ /,"",l); sub(/ $/,"",l); print P "\t" l }' "$W/pg.txt" >> "$W/body.txt" ;;
    esac
    p=$((p + 1))
  done
  awk -F'\t' '
    function norm(s) { s = tolower(s); gsub(/[ \t]+/, " ", s); sub(/^ /, "", s); sub(/ $/, "", s); return s }
    function strip(s) { sub(/^([ivxlcdm]+|[a-z]|[0-9]+)\. /, "", s); sub(/^\([0-9]+\) /, "", s); return s }
    FNR == NR { keys[++nk] = norm($2); next }
    { pg[++nb] = $1; ln[nb] = strip(norm($2)) }
    END {
      j = 1
      for (i = 1; i <= nk; i++) {
        key = strip(keys[i]); found = 0
        while (j <= nb) {
          l = ln[j]
          if (l == key || (length(key) >= 40 && index(l, substr(key, 1, 40)) == 1) || (length(l) >= 20 && index(key, l) == 1)) { found = 1; break }
          j++
        }
        if (found) { print pg[j]; j++ }
        else { print ""; print "render.sh: heading not found in the PDF: " keys[i] > "/dev/stderr" }
      }
    }' "$W/heads.tsv" "$W/body.txt" > "$2"
}

build "$W/p1.docx" ""
pagemap "$W/p1.docx" "$W/pages1.tsv"
build "$W/p2.docx" "$W/pages1.tsv"
pagemap "$W/p2.docx" "$W/pages2.tsv"
cmp -s "$W/pages1.tsv" "$W/pages2.tsv" || {
  echo "render.sh: index page numbers changed on the second layout; not written" >&2
  exit 1
}
cp "$W/p2.docx" "$OUT"
