#!/bin/sh
# Renders the motion-brief sample to .docx (tools/render-docx.sh hands the build over here when this file exists).
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
#
# The table of contents and table of authorities print page numbers (docs/DOCX.md, "Known limits"). They are measured
# on the document itself, not taken from a field:
#   build    pandoc writes the document with the page numbers in the map (none on the first build); LibreOffice
#            makes the PDF.
#   measure  the body pages (from the first page after the cover whose footer is "1") are searched for each heading's
#            text and each authority link's text (whitespace removed, case folded); the result is a new map.
# The build is final when measuring it gives the map it was built with. Otherwise the new map is used and the
# build is repeated, at most 3 times. The body is checked against RCFC 5.4(b)(1): 40 pages, 50 for a cross-motion,
# counting the body and the certificate.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
FILTER="--lua-filter=$D/uscfc-motion-brief.lua"

# build <map or empty> <out.docx> <list out or empty>
build() {
  (cd "$COURT" && USCFC_MAP="$1" USCFC_LIST="$3" pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" $FILTER "$SAMPLE" -o "$2")
}

# to_pdf <docx> <outdir>: LibreOffice conversion with its own profile.
to_pdf() {
  mkdir -p "$2"
  "$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$2" "$1" > "$W/soffice.log" 2>&1 || {
    cat "$W/soffice.log" >&2
    return 1
  }
  [ -f "$2/$(basename "${1%.docx}").pdf" ] || {
    echo "render.sh: LibreOffice wrote no PDF for $1" >&2
    return 1
  }
}

# body_start <pdf>: the first page after the cover whose last text line is its footer "1".
body_start() {
  n=$(pdfinfo "$1" | awk '/^Pages:/ { print $2 }')
  p=2
  while [ "$p" -le "$n" ]; do
    last=$(pdftotext -layout -f "$p" -l "$p" "$1" - | grep -v '^[[:space:]]*$' | tail -n 1 | tr -d ' \t' || true)
    if [ "$last" = 1 ]; then echo "$p"; return 0; fi
    p=$((p + 1))
  done
  echo "render.sh: no body page (footer 1) in $1" >&2
  return 1
}

# measure <pdf> <list> <map>: "B <first body page>", "H <index> <body page>" and "A <key> <body pages>", or "?" where
# a heading or a link is not found on any body page.
measure() {
  start=$(body_start "$1")
  n=$(pdfinfo "$1" | awk '/^Pages:/ { print $2 }')
  : > "$W/pages.txt"
  p=$start
  while [ "$p" -le "$n" ]; do
    printf '%s %s\n' "$p" "$(pdftotext -f "$p" -l "$p" "$1" - | perl -CSD -pe 's/\x{00A0}//g' | tr -d ' \t\r\n\f' | tr 'a-z' 'A-Z')" >> "$W/pages.txt"
    p=$((p + 1))
  done
  echo "B $start" > "$3"
  perl -CSD -pe 's/\x{00A0}//g' "$2" > "$W/list-clean.txt"
  awk -v start="$start" '
    NR == FNR { T[$1] = substr($0, length($1) + 2); if ($1 + 0 > np) np = $1 + 0; next }
    # A text is found by its first characters: a citation can break across lines, pages or footnotes, but it starts on one page.
    function hit(p, s) {
      return index(T[p], s) > 0
    }
    {
      kind = $1; id = $2
      txt = substr($0, length($1) + length($2) + 3)
      gsub(/[ \t]/, "", txt); txt = toupper(txt)
      if (kind == "H" && length(txt) > 40) txt = substr(txt, 1, 40)
      if (kind == "L" && length(txt) > 30) txt = substr(txt, 1, 30)
      if (kind == "H") H[++nh] = id SUBSEP txt
      else { L[++nl] = id SUBSEP txt }
    }
    END {
      last = start
      for (i = 1; i <= nh; i++) {
        split(H[i], f, SUBSEP)
        found = ""
        for (p = last; p <= np; p++) if (hit(p, f[2])) { found = p; break }
        if (found == "") print "H " f[1] " ?"
        else { last = found; print "H " f[1] " " (found - start + 1) }
      }
      for (i = 1; i <= nl; i++) {
        split(L[i], f, SUBSEP)
        if (!(f[1] in seen)) { seen[f[1]] = 1; order[++no] = f[1] }
        for (p = start; p <= np; p++) if (hit(p, f[2])) {
          if (!((f[1] SUBSEP p) in got)) {
            got[f[1] SUBSEP p] = 1
            pages[f[1]] = (f[1] in pages) ? pages[f[1]] "," (p - start + 1) : (p - start + 1)
          }
        }
      }
      for (i = 1; i <= no; i++) print "A " order[i] " " ((order[i] in pages) ? pages[order[i]] : "?")
    }' "$W/pages.txt" "$W/list-clean.txt" >> "$3"
}

# ---- the page map: first build without numbers, then until the numbers match the measured pages ----
build "" "$W/build0.docx" "$W/list.txt"
to_pdf "$W/build0.docx" "$W/b0"
measure "$W/b0/build0.pdf" "$W/list.txt" "$W/map.txt"

i=0
while :; do
  i=$((i + 1))
  build "$W/map.txt" "$W/final.docx" ""
  to_pdf "$W/final.docx" "$W/final"
  measure "$W/final/final.pdf" "$W/list.txt" "$W/map2.txt"
  if grep -q ' ?$' "$W/map2.txt"; then
    echo "render.sh: a heading or an authority is not found on the body pages:" >&2
    grep ' ?$' "$W/map2.txt" >&2
    exit 1
  fi
  if cmp -s "$W/map.txt" "$W/map2.txt"; then break; fi
  if [ "$i" -ge 3 ]; then
    echo "render.sh: the table of contents and authorities did not settle in 3 passes" >&2
    exit 1
  fi
  cp "$W/map2.txt" "$W/map.txt"
done

# The body fits the page limit (RCFC 5.4(b)(1)).
PAGES=$(pdfinfo "$W/final/final.pdf" | awk '/^Pages:/ { print $2 }')
BODY_START=$(awk '$1 == "B" { print $2 }' "$W/map2.txt")
BODY_PAGES=$((PAGES - BODY_START + 1))
LIMIT=40
if grep -q '^cross_motion: *true' "$COURT/$SAMPLE"; then LIMIT=50; fi
if [ "$BODY_PAGES" -gt "$LIMIT" ]; then
  echo "render.sh: the body runs $BODY_PAGES pages; RCFC 5.4(b)(1) allows $LIMIT without leave of court" >&2
  exit 1
fi
echo "render.sh: body $BODY_PAGES pages (limit $LIMIT); page numbers measured in $i pass(es)" >&2
cp "$W/final.docx" "$OUT"
