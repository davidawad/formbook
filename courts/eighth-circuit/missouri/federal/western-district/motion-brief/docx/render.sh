#!/bin/sh
# Renders the .docx of one sample for the motion-brief doc type (the docx engine, docs/DOCX.md).
# Usage: sh docx/render.sh <doc-type-dir> <sample.md, relative to it> <out.docx>
# Called by tools/render-docx.sh, which converts the .docx to the LibreOffice PDF that the checks read.
#
# The table of contents and the table of authorities carry page numbers, which Word and LibreOffice do not
# compute from a plain docx. So this script lays the document out and writes the numbers from that layout:
#   pass 1: pandoc (mowd-motion-brief.lua) with placeholder page numbers and the search list (side.tsv);
#           LibreOffice lays it out to a PDF.
#   pages:  the body starts on the page whose footer is "1" (the cover and the front matter are unnumbered
#           or roman); every heading and every authority link is found on the body pages, in order, by its
#           text. A heading or a link that is not on a body page fails the render (no silent gaps).
#   pass N: the filter runs again with those pages; repeat until the page numbers do not change.
# Needs pandoc, soffice (LibreOffice), pdfinfo and pdftotext (poppler), awk.
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
D="$COURT/docx"
SOFFICE=${SOFFICE:-$(command -v soffice || true)}
[ -n "$SOFFICE" ] || {
  echo "render.sh: soffice (LibreOffice) is needed for the table of contents page numbers" >&2
  exit 1
}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

# layout PDF SIDE PAGES_OUT: writes the page numbers of the headings (H) and the authorities (K) to PAGES_OUT.
layout() {
  PDF=$1
  SIDE=$2
  OUTF=$3
  N=$(pdfinfo "$PDF" | awk '/^Pages:/ { print $2 }')
  p=1
  while [ "$p" -le "$N" ]; do
    pdftotext -f "$p" -l "$p" "$PDF" "$W/text-$p.txt"
    pdftotext -layout -f "$p" -l "$p" "$PDF" "$W/layout-$p.txt"
    p=$((p + 1))
  done
  awk -v N="$N" -v W="$W" -v SIDE="$SIDE" '
    function norm(s) { gsub(/\302\240/, " ", s); gsub(/[ \t\r\n\f]+/, " ", s); sub(/^ /, "", s); sub(/ $/, "", s); return s }
    function fail(msg) { print "render.sh: " msg > "/dev/stderr"; exit 1 }
    BEGIN {
      body = 0
      for (p = 1; p <= N; p++) {
        txt = ""
        f = W "/text-" p ".txt"
        while ((getline line < f) > 0) txt = txt " " line
        close(f)
        PAGE[p] = norm(txt)
        f = W "/layout-" p ".txt"
        last = ""
        while ((getline line < f) > 0) if (line ~ /[^ \t\f]/) last = line
        close(f)
        gsub(/^[ \t]+|[ \t]+$/, "", last)
        if (body == 0 && last == "1") body = p
      }
      if (body == 0) fail("no page with the footer 1: the body was not laid out")
      nh = 0
      nn = 0
      while ((getline line < SIDE) > 0) {
        split(line, cols, "\t")
        if (cols[1] == "H") { nh++; HS[nh] = cols[3] }
        if (cols[1] == "N") { nn++; NK[nn] = cols[2]; NN[nn] = cols[3]; KEYS[cols[2]] = 1 }
      }
      close(SIDE)
      cur = body
      for (i = 1; i <= nh; i++) {
        s = norm(HS[i])
        found = 0
        for (p = cur; p <= N && found == 0; p++) if (index(PAGE[p], s) > 0) found = p
        if (found == 0) fail("heading " i " is not on a body page: " s)
        cur = found
        print "H\t" i "\t" (found - body + 1)
      }
      for (j = 1; j <= nn; j++) {
        s = norm(NN[j])
        hit = 0
        for (p = body; p <= N; p++) if (index(PAGE[p], s) > 0) { MARK[NK[j], p - body + 1] = 1; hit = 1 }
        if (hit == 0) fail("the authority link text is not on a body page: " s)
      }
      for (k in KEYS) {
        n = 0
        list = ""
        for (q = 1; q <= N - body + 1; q++) {
          if (MARK[k, q]) {
            n++
            list = (list == "") ? q : list ", " q
          }
        }
        if (n == 0) fail("authority " k " has no page")
        if (n >= 7) list = "passim"
        print "K\t" k "\t" list
      }
      print "render.sh: body starts on page " body " of " N > "/dev/stderr"
    }
  ' > "$OUTF"
}

pass=0
while :; do
  pass=$((pass + 1))
  if [ "$pass" -gt 4 ]; then
    echo "render.sh: the page numbers did not settle in 4 passes" >&2
    exit 1
  fi
  # Pass 1 has no pages file yet: the filter writes placeholders.
  (cd "$COURT" && MOWD_PAGES="$W/pages-$((pass - 1)).tsv" MOWD_SIDECAR="$W/side.tsv" \
    pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
    --lua-filter="$D/mowd-motion-brief.lua" "$SAMPLE" -o "$W/pass$pass.docx") || exit 1
  "$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W" "$W/pass$pass.docx" \
    > "$W/soffice.log" 2>&1 || {
    cat "$W/soffice.log" >&2
    exit 1
  }
  layout "$W/pass$pass.pdf" "$W/side.tsv" "$W/pages-$pass.tsv"
  if [ "$pass" -gt 1 ] && cmp -s "$W/pages-$pass.tsv" "$W/pages-$((pass - 1)).tsv"; then
    break
  fi
done
cp "$W/pass$pass.docx" "$OUT"
echo "$OUT"
