#!/bin/sh
# docx/render.sh <court-dir> <sample.md> <out.docx>
# Called by tools/render-docx.sh, which validates the .docx and makes the .docx.pdf (LibreOffice).
# pandoc with reference.docx and the Lua filters of this folder, in two passes:
#   pass 1 writes the .docx and the heading list (the filter's GACTAPP_HEADINGS);
#   the LibreOffice PDF of pass 1 gives each heading's page: the printed number in the footer of the body page
#   where the heading first appears (body pages are numbered from 1; the cover and contents are not);
#   pass 2 writes the contents with those page numbers (GACTAPP_TOC_PAGES).
# The filter writes the placeholder rId "rIdFooterPage" for the footer of its raw section breaks; pandoc
# renames relationship IDs, so the real ID (the relationship whose Target is footer-page.xml) is put in here.
# Needs: pandoc, soffice (LibreOffice), pdfinfo, pdftotext, awk, unzip, zip, perl, xmllint.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
FILTERS=""
for f in "$D"/*.lua; do [ -e "$f" ] && FILTERS="$FILTERS --lua-filter=$f"; done

# to_docx <out.docx>: pandoc, then the footer relationship fix
to_docx() {
  # shellcheck disable=SC2086
  (cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" $FILTERS "$SAMPLE" -o "$1") || return 1
  W="$T/fix.$$"
  rm -rf "$W"
  mkdir "$W"
  (cd "$W" && unzip -q "$1") || return 1
  RID=$(perl -0ne 'while (/<Relationship\b[^>]*>/g) { my $r = $&; if ($r =~ /Target="footer-page\.xml"/ && $r =~ /Id="([^"]+)"/) { print $1; last } }' "$W/word/_rels/document.xml.rels")
  [ -n "$RID" ] || {
    echo "render.sh: no footer relationship for footer-page.xml in $1" >&2
    return 1
  }
  perl -pi -e "s/rIdFooterPage/$RID/g" "$W/word/document.xml"
  xmllint --noout "$W/word/document.xml" || return 1
  rm -f "$1"
  (cd "$W" && zip -X -q -r "$1" '[Content_Types].xml' _rels docProps word)
  rm -rf "$W"
}

GACTAPP_HEADINGS="$T/heads.txt" to_docx "$T/pass1.docx" || exit 1
"$SOFFICE" "-env:UserInstallation=file://$T/profile" --headless --convert-to pdf --outdir "$T" "$T/pass1.docx" > "$T/soffice.log" 2>&1 || {
  cat "$T/soffice.log" >&2
  exit 1
}
if [ -s "$T/heads.txt" ]; then
  # one line per body page: printed page number, then the page text as a-z0-9 only
  : > "$T/pages.tsv"
  N=$(pdfinfo "$T/pass1.pdf" | awk '/^Pages:/ { print $2 }')
  i=1
  while [ "$i" -le "$N" ]; do
    txt=$(pdftotext -f "$i" -l "$i" "$T/pass1.pdf" -)
    last=$(printf '%s\n' "$txt" | grep '[^[:space:]]' | tail -n 1 | tr -d '[:space:]' || true)
    case $last in
      '' | *[!0-9]*) ;;
      *) printf '%s\t%s\n' "$last" "$(printf '%s' "$txt" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9')" >> "$T/pages.tsv" ;;
    esac
    i=$((i + 1))
  done
  # each heading: level, text; the page is the first body page, from the previous heading's page on, that holds it
  awk -F '\t' '
    function norm(s) { s = tolower(s); gsub(/[^a-z0-9]/, "", s); return s }
    FILENAME == HEADS { key[++nh] = norm($2); next }
    { nb++; num[nb] = $1 + 0; page[nb] = $2 }
    END {
      p = 1
      for (h = 1; h <= nh; h++) {
        found = 0
        for (; p <= nb; p++) if (index(page[p], key[h]) > 0) { found = 1; break }
        if (!found) { printf "render.sh: heading not found on a body page: %s\n", key[h] > "/dev/stderr"; exit 1 }
        print num[p]
      }
    }
  ' HEADS="$T/heads.txt" "$T/heads.txt" "$T/pages.tsv" > "$T/pages.txt" || exit 1
  GACTAPP_TOC_PAGES="$T/pages.txt" to_docx "$T/final.docx" || exit 1
  cp "$T/final.docx" "$OUT"
else
  cp "$T/pass1.docx" "$OUT"
fi
echo "$OUT"
