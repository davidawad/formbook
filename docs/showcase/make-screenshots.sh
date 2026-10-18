#!/usr/bin/env bash
# Regenerate every image in docs/showcase/ from files committed in this repo (the overlay is regenerated
# into the gitignored .overlay/ by tools/overlay.sh first; overlays are never committed).
# Usage (from anywhere): sh docs/showcase/make-screenshots.sh
# Needs: pdftoppm (poppler), magick (ImageMagick), typst. Put the formbook toolchain on PATH first:
#   export PATH="$HOME/.local/share/formbook/env/bin:$PATH"
# Layout and labels are typeset by typst with its bundled fonts (--ignore-system-fonts), so output
# does not depend on installed fonts. Page images come from pdftoppm at fixed resolution.
# Strict mode. pipefail only where the shell has it (bash, macOS sh); Debian's dash lacks it.
# shellcheck shell=sh disable=SC3040
set -e -u; (set -o pipefail) 2> /dev/null && set -o pipefail
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
OUT=$ROOT/docs/showcase
export PATH="$HOME/.local/share/formbook/env/bin:$PATH"
for t in pdftoppm magick typst; do
  command -v "$t" > /dev/null 2>&1 || {
    echo "make-screenshots.sh: missing $t" >&2
    exit 1
  }
done
# recursive delete of one directory; an empty path aborts instead of deleting the wrong thing
safe_rmdir() { rm -r -f -- "${1:?safe_rmdir: empty path}"; }
W=$(mktemp -d) || exit 1
trap 'safe_rmdir "$W"' EXIT
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
# compose FILE.typ OUT.png COLORS: typeset FILE.typ with typst, then palette-reduce into docs/showcase/
compose() {
  (cd "$W" && typst compile --root "$W" --ignore-system-fonts --format png --ppi 72 "$1" "$W/raw-$2")
  reduce "$W/raw-$2" "$OUT/$2" "$3"
}

TRES_OUT=$TRES/usage/OUTPUT-opening-brief.typst.pdf
TRES_FILED=$TRES/usage/FILED-EXAMPLE-opening-brief.pdf
TRES_IN=$TRES/usage/INPUT-opening-brief.md

# ---------------------------------------------------------------- hero.png
awk '/^#/ { next } ++n <= 30' "$TRES_IN" | cut -c1-52 > "$W/input.txt"
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
compose hero.typ hero.png 96

# ---------------------------------------------------------------- overlay.png
sh tools/overlay.sh "$CAND" complaint > /dev/null
page ".overlay/$CAND/OVERLAY-complaint.pdf" 2 o 130
cat > "$W/overlay.typ" << 'TYP'
#set page(width: auto, height: auto, margin: 14pt, fill: rgb("#f6f4ee"))
#set text(font: "Libertinus Serif", size: 14pt, fill: rgb("#222"))
#align(center)[
  #box(stroke: 0.8pt + rgb("#999"), image("o.png", height: 640pt))
  #v(6pt)
  #text(fill: rgb("#d00000"), weight: "bold")[red] = only in our render · #text(fill: rgb("#0044cc"), weight: "bold")[blue] = only in the filed exemplar · black = both agree
]
TYP
compose overlay.typ overlay.png 64

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
compose pages.typ pages.png 48

# ---------------------------------------------------------------- courts.png
cat > "$W/courts.list" << EOF
$SCOTUS/usage/OUTPUT-merits-brief.typst.pdf|U.S. Supreme Court: merits brief
$CA1/usage/OUTPUT-opening-brief.typst.pdf|1st Circuit: opening brief
$TRES_OUT|3rd Circuit: opening brief
$CAND/usage/OUTPUT-complaint.typst.pdf|N.D. Cal.: complaint
$MDB/usage/OUTPUT-adversary-complaint.typst.pdf|D. Md. Bankruptcy: adversary complaint
$CASUP/usage/OUTPUT-complaint.typst.pdf|California Superior Court: complaint
$NYS/usage/OUTPUT-motion-brief.typst.pdf|New York Supreme Court: motion brief
$TXSC/usage/OUTPUT-brief-on-the-merits.typst.pdf|Texas Supreme Court: brief on the merits
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
compose courts.typ courts.png 48

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
compose folder.typ folder.png 16

ls -l "$OUT"/*.png
