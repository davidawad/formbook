#!/bin/sh
# Regenerate every image in docs/showcase/ from files committed in this repo.
# Usage (from anywhere): sh docs/showcase/make-screenshots.sh
# Needs: pdftoppm (poppler), magick (ImageMagick), typst. Put the formbook toolchain on PATH first:
#   export PATH="$HOME/.local/share/formbook/env/bin:$PATH"
# Layout and labels are typeset by typst with its bundled fonts (--ignore-system-fonts), so output
# does not depend on installed fonts. Page images come from pdftoppm at fixed resolution.
set -eu
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
OUT=$ROOT/docs/showcase
export PATH="$HOME/.local/share/formbook/env/bin:$PATH"
for t in pdftoppm magick typst; do
  command -v "$t" > /dev/null 2>&1 || {
    echo "make-screenshots.sh: missing $t" >&2
    exit 1
  }
done
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$ROOT"

# Source documents.
TRES=courts/third-circuit/court-of-appeals/opening-brief
NYS=courts/second-circuit/new-york/state/supreme-court/motion-brief
CAND=courts/ninth-circuit/california/federal/northern-district/complaint
SCOTUS=courts/supreme-court-of-the-united-states/merits-brief
CA1=courts/first-circuit/court-of-appeals/opening-brief
MDB=courts/fourth-circuit/maryland/federal/bankruptcy-district/adversary-complaint
CASUP=courts/ninth-circuit/california/state/superior-court/complaint
TXSC=courts/fifth-circuit/texas/state/supreme-court/brief-on-the-merits

# page SRC.pdf N NAME [RES]: rasterize one page to $W/NAME.png
page() { pdftoppm -r "${4:-110}" -f "$2" -l "$2" -png -singlefile "$1" "$W/$3"; }
# reduce SRC DST COLORS: palette-reduce and strip metadata (smaller, reproducible)
reduce() { magick "$1" -strip -colors "$3" -define png:exclude-chunks=date,time "$2"; }
# typeset FILE.typ OUT.png COLORS
typeset() {
  (cd "$W" && typst compile --root "$W" --ignore-system-fonts --format png --ppi 72 "$1" "$W/raw-$2")
  reduce "$W/raw-$2" "$OUT/$2" "$3"
}

TRES_OUT=$TRES/samples/OUTPUT-tresslar-opening-brief.pdf
TRES_FILED=$TRES/exemplars/FILED-EXAMPLE-tresslar-26-1367-opening-brief.pdf
TRES_OVL=$TRES/samples/OVERLAY-tresslar-opening-brief.pdf
TRES_IN=$TRES/samples/INPUT-tresslar-opening-brief.md

# ---------------------------------------------------------------- hero.png
grep -v '^#' "$TRES_IN" | head -n 30 | cut -c1-52 > "$W/input.txt"
page "$TRES_OUT" 1 h-ours 100
page "$TRES_FILED" 1 h-filed 100
cat > "$W/hero.typ" << 'TYP'
#set page(width: 1180pt, height: 520pt, margin: 18pt, fill: rgb("#f6f4ee"))
#set text(font: "Libertinus Serif", size: 15pt, fill: rgb("#222"))
#let lab(t) = align(center, text(weight: "bold", size: 17pt)[#t])
#let arrow = align(horizon + center, text(size: 40pt, fill: rgb("#888"))[→])
#let frame(body) = box(stroke: 0.8pt + rgb("#999"), fill: white, body)
#grid(columns: (1fr, 34pt, auto, 34pt, auto), rows: (1fr, auto), column-gutter: 4pt, row-gutter: 10pt,
  frame(box(width: 100%, height: 100%, inset: 9pt, clip: true,
    text(font: "DejaVu Sans Mono", size: 9.6pt, fill: rgb("#223"), raw(read("input.txt"), lang: none)))),
  arrow,
  frame(image("h-ours.png", height: 100%)),
  arrow,
  frame(image("h-filed.png", height: 100%)),
  lab[markdown in], [], lab[formbook (Typst)], [], lab[filed with the court])
TYP
typeset hero.typ hero.png 96

# ---------------------------------------------------------------- overlay.png
page "$CAND/samples/OVERLAY-superhuman-complaint.pdf" 2 o 130
cat > "$W/overlay.typ" << 'TYP'
#set page(width: auto, height: auto, margin: 14pt, fill: rgb("#f6f4ee"))
#set text(font: "Libertinus Serif", size: 14pt, fill: rgb("#222"))
#align(center)[
  #box(stroke: 0.8pt + rgb("#999"), image("o.png", height: 640pt))
  #v(6pt)
  #text(fill: rgb("#d00000"), weight: "bold")[red] = only in our render · #text(fill: rgb("#0044cc"), weight: "bold")[blue] = only in the filed exemplar · black = both agree
]
TYP
typeset overlay.typ overlay.png 64

# ---------------------------------------------------------------- pages.png
n=0
for p in 1 2 3 6 11 14 15 18; do
  n=$((n + 1))
  page "$TRES_OUT" "$p" "p$n" 70
done
cat > "$W/pages.typ" << 'TYP'
#set page(width: auto, height: auto, margin: 14pt, fill: rgb("#f6f4ee"))
#set text(font: "Libertinus Serif", size: 13pt, fill: rgb("#222"))
#let names = ("cover", "table of contents", "table of authorities", "statement", "argument", "conclusion", "certificate of compliance", "certificate of service")
#grid(columns: 4, column-gutter: 10pt, row-gutter: 12pt,
  ..range(8).map(i => align(center, stack(spacing: 5pt,
    box(stroke: 0.8pt + rgb("#999"), image("p" + str(i + 1) + ".png", width: 215pt)),
    names.at(i)))))
TYP
typeset pages.typ pages.png 48

# ---------------------------------------------------------------- courts.png
cat > "$W/courts.list" << EOF
$SCOTUS/samples/OUTPUT-in-re-grand-jury.pdf|U.S. Supreme Court: merits brief
$CA1/samples/OUTPUT-figueroa-opening-brief.pdf|1st Circuit: opening brief
$TRES_OUT|3rd Circuit: opening brief
$CAND/samples/OUTPUT-superhuman-complaint.pdf|N.D. Cal.: complaint
$MDB/samples/OUTPUT-kapitus-complaint.pdf|D. Md. Bankruptcy: adversary complaint
$CASUP/samples/OUTPUT-sweetwater-complaint.pdf|California Superior Court: complaint
$NYS/samples/OUTPUT-valentino.pdf|New York Supreme Court: motion brief
$TXSC/samples/OUTPUT-hawthorne-brief-on-the-merits.pdf|Texas Supreme Court: brief on the merits
EOF
n=0
: > "$W/courts.typ"
while IFS='|' read -r pdf label; do
  n=$((n + 1))
  page "$pdf" 1 "c$n" 70
  printf '#let l%s = "%s"\n' "$n" "$label" >> "$W/courts.typ"
done < "$W/courts.list"
cat >> "$W/courts.typ" << 'TYP'
#set page(width: auto, height: auto, margin: 14pt, fill: rgb("#f6f4ee"))
#set text(font: "Libertinus Serif", size: 13pt, fill: rgb("#222"))
#let labels = (l1, l2, l3, l4, l5, l6, l7, l8)
#grid(columns: 4, column-gutter: 10pt, row-gutter: 12pt,
  ..range(8).map(i => align(center, stack(spacing: 5pt,
    box(stroke: 0.8pt + rgb("#999"), image("c" + str(i + 1) + ".png", width: 215pt)),
    labels.at(i)))))
TYP
typeset courts.typ courts.png 48

# ---------------------------------------------------------------- folder.png
{
  echo "$TRES/"
  (cd "$TRES" && find . -mindepth 1 -maxdepth 2 ! -name '.DS_Store' ! -path './docx*' ! -path './latex*' | LC_ALL=C sort |
    awk '{ n = gsub("/", "/"); sub(/^\.\//, ""); if (n == 1) print "|-- " $0; else { sub(/^[^\/]*\//, ""); print "|   |-- " $0 } }')
} | cut -c1-90 > "$W/tree.txt"
cat > "$W/folder.typ" << 'TYP'
#set page(width: auto, height: auto, margin: 16pt, fill: rgb("#f6f4ee"))
#set text(font: "DejaVu Sans Mono", size: 13pt, fill: rgb("#223"))
#raw(read("tree.txt"), lang: none)
TYP
typeset folder.typ folder.png 16

ls -l "$OUT"/*.png
