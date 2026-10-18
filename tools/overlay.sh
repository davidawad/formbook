#!/usr/bin/env bash
# Overlay a rendered sample on a filed SAMPLE, page by page.
#   red   = our render only
#   blue  = filed SAMPLE only
#   black = both agree (red multiplied over blue)
# Pages are paired by text, not index: each rendered page is matched to the
# SAMPLE page sharing the most words, so a partial transcription still
# lines up with the pages it came from.
#
# usage: tools/overlay.sh <doc-dir> <id> [SAMPLE.pdf]
#   <doc-dir> a court folder or a doc-type folder; every name comes from `fb usage` (tools/fb/src/layout.rs)
# reads:  `fb usage output <doc-dir> <id>`  = <doc-dir>/usage/OUTPUT-<stem>-<id>.typst.pdf (our render)
#         `fb usage pair <doc-dir> <id>`    = the SAMPLE-<stem>-*.pdf paired with <id>, unless SAMPLE.pdf is given
# writes: `fb usage overlay <doc-dir> <id> pdf|txt` = <repo>/.overlay/<doc path>/OVERLAY-<stem>-<id>.pdf and .txt
#         (page map). .overlay/ is gitignored: overlays are generated on demand, never committed.
# Strict mode. pipefail only where the shell has it (bash, macOS sh); Debian's dash lacks it.
# shellcheck shell=sh disable=SC3040
set -e -u; (set -o pipefail) 2> /dev/null && set -o pipefail

ROOT=$(realpath "$(dirname "$0")/..")
FB="cargo run -q --release --manifest-path $ROOT/tools/fb/Cargo.toml --"
export FB_ROOT="$ROOT"
dir=$1
id=$2
ours=$($FB usage output "$dir" "$id")
ref=${3:-$($FB usage pair "$dir" "$id")}
out=$($FB usage overlay "$dir" "$id" pdf)
map=$($FB usage overlay "$dir" "$id" txt)
dpi=100
label_font=$ROOT/fonts/eb-garamond/EBGaramond-Regular.otf

[ -f "$ours" ] || {
  echo "no render: $ours (run tools/render.sh first)" >&2
  exit 1
}
[ -f "$ref" ] || {
  echo "no SAMPLE pdf: $ref" >&2
  exit 1
}

mkdir -p "$(dirname "$out")"
# recursive delete of one directory; an empty path aborts instead of deleting the wrong thing
safe_rmdir() { rm -r -f -- "${1:?safe_rmdir: empty path}"; }
tmp=$(mktemp -d) || exit 1
trap 'safe_rmdir "$tmp"' EXIT

pages() { pdfinfo "$1" | awk '/^Pages:/ {print $2}'; }
words() { # one lowercased word per line, unique, for page $2 of pdf $1
  pdftotext -f "$2" -l "$2" "$1" - | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '\n' |
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

# best SAMPLE page per rendered page: Jaccard similarity of word sets
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
