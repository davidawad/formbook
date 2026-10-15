#!/bin/sh
# Page map of a rendered PDF for the table of contents and table of authorities (see fiscr-amicus.lua).
# Usage: sh docx/pages.sh <rendered.pdf> <keys file written by fiscr-amicus.lua>   (prints the map on stdout)
# Needs pdfinfo, pdftotext (poppler) and gawk (the awk here is GNU awk; mawk is not used).
set -eu
PDF=$1
KEYS=$2
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
N=$(pdfinfo "$PDF" | awk '/^Pages:/ { print $2 }')
p=1
while [ "$p" -le "$N" ]; do
  pdftotext -f "$p" -l "$p" -enc UTF-8 "$PDF" "$W/$p.txt"
  p=$((p + 1))
done
gawk -v N="$N" -v W="$W" -f "$D/pages.awk" "$KEYS" | LC_ALL=C sort
