#!/bin/sh
# Overlay a rendered sample on its filed exemplar, page by page.
#   red   = our render only
#   blue  = filed exemplar only
#   black = both agree (red multiplied over blue)
# Pages are paired by text, not index: each sample page is matched to the
# exemplar page sharing the most words, so a partial transcription still
# lines up with the pages it came from.
#
# usage: tools/overlay.sh <court-dir> <sample-id> [exemplar.pdf]
# reads:  <court-dir>/samples/OUTPUT-<sample-id>.pdf (our render)
# writes: <court-dir>/samples/OVERLAY-<sample-id>.pdf and OVERLAY-<sample-id>.txt (page map)
set -eu

dir=$1
id=$2
ours=$dir/samples/OUTPUT-$id.pdf
ref=${3:-$(ls "$dir"/exemplars/*.pdf | head -1)}
out=$dir/samples/OVERLAY-$id.pdf
map=$dir/samples/OVERLAY-$id.txt
dpi=100
label_font=$(dirname "$0")/../fonts/eb-garamond/EBGaramond-Regular.otf

[ -f "$ours" ] || {
  echo "no render: $ours (run tools/render.sh first)" >&2
  exit 1
}
[ -f "$ref" ] || {
  echo "no exemplar pdf in $dir/exemplars" >&2
  exit 1
}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

pages() { pdfinfo "$1" | awk '/^Pages:/ {print $2}'; }
words() { # one lowercased word per line, unique, for page $2 of pdf $1
  pdftotext -f "$2" -l "$2" "$1" - | tr 'A-Z' 'a-z' | tr -cs 'a-z0-9' '\n' |
    awk 'length($0) > 3' | sort -u
}

n_ours=$(pages "$ours")
n_ref=$(pages "$ref")

i=1
while [ "$i" -le "$n_ours" ]; do
  words "$ours" "$i" > "$tmp/o.$i"
  i=$((i + 1))
done
j=1
while [ "$j" -le "$n_ref" ]; do
  words "$ref" "$j" > "$tmp/r.$j"
  j=$((j + 1))
done

# best exemplar page per sample page: Jaccard similarity of word sets
: > "$map"
i=1
while [ "$i" -le "$n_ours" ]; do
  best=0
  best_j=0
  j=1
  while [ "$j" -le "$n_ref" ]; do
    both=$(comm -12 "$tmp/o.$i" "$tmp/r.$j" | wc -l)
    any=$(sort -u "$tmp/o.$i" "$tmp/r.$j" | wc -l)
    score=$(awk -v b="$both" -v a="$any" 'BEGIN { printf "%d", (a ? 1000 * b / a : 0) }')
    if [ "$score" -gt "$best" ]; then
      best=$score
      best_j=$j
    fi
    j=$((j + 1))
  done
  printf 'ours p.%s  filed p.%s  word-overlap %s.%s%%\n' "$i" "$best_j" "$((best / 10))" "$((best % 10))" >> "$map"

  pdftoppm -r "$dpi" -gray -png -singlefile -f "$i" -l "$i" "$ours" "$tmp/op"
  magick "$tmp/op.png" +level-colors red,white "$tmp/oc.png"
  if [ "$best_j" -gt 0 ]; then
    pdftoppm -r "$dpi" -gray -png -singlefile -f "$best_j" -l "$best_j" "$ref" "$tmp/rp"
    magick "$tmp/rp.png" +level-colors blue,white "$tmp/rc.png"
    label="ours p.$i (red)  over  filed p.$best_j (blue)"
  else
    magick "$tmp/oc.png" -fill white -colorize 100 "$tmp/rc.png"
    label="ours p.$i (red)  no matching filed page"
  fi
  geo=$(magick identify -format '%wx%h' "$tmp/rc.png")
  magick "$tmp/rc.png" \( "$tmp/oc.png" -resize "$geo!" \) -compose multiply -composite \
    -font "$label_font" -gravity north -fill gray40 -pointsize 14 -annotate +0+6 "$label" \
    "$tmp/page-$(printf '%03d' "$i").png"
  i=$((i + 1))
done

magick -density "$dpi" "$tmp"/page-*.png "$out"
echo "wrote $out"
cat "$map"
