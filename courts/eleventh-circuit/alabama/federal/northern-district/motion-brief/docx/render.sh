#!/bin/sh
# DOCX engine for the motion brief, two passes (docs/DOCX.md, "Known limits": contents and authorities).
# Pass 1 writes the .docx with the heading and citation keys and placeholder page numbers; LibreOffice renders it;
# pdftotext finds the body page of each key (pages.awk). Pass 2 writes the .docx with those page numbers.
# Called by tools/render-docx.sh as: sh render.sh <doc-type-dir> <sample.md> <out.docx>
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
D=$(cd "$(dirname "$0")" && pwd)
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
FILTERS=""
for f in "$D"/*.lua; do [ -e "$f" ] && FILTERS="$FILTERS --lua-filter=$f"; done

# pass 1: the keys
# shellcheck disable=SC2086
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" $FILTERS \
  -M "keys_out=$W/keys.txt" "$SAMPLE" -o "$W/pass1.docx") || exit 1
"$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" \
  > "$W/soffice.log" 2>&1 || {
  cat "$W/soffice.log" >&2
  exit 1
}
[ -f "$W/pass1.pdf" ] || {
  echo "render.sh: LibreOffice did not write pass1.pdf" >&2
  exit 1
}

# the normalised text of each page: ligatures spelled out, then lower case letters and digits only
N=$(pdfinfo "$W/pass1.pdf" | awk '/^Pages:/ { print $2 }')
FILES=""
p=1
while [ "$p" -le "$N" ]; do
  # the page footer (a line of digits, last on the page) is left out, so a citation can run on across pages
  pdftotext -f "$p" -l "$p" "$W/pass1.pdf" - | sed 's/\f//g; s/ﬁ/fi/g; s/ﬂ/fl/g; s/ﬀ/ff/g; s/ﬃ/ffi/g; s/ﬄ/ffl/g' |
    awk 'NF { line[++n] = $0 } END { if (n > 0 && line[n] ~ /^[ \t]*[0-9]+[ \t]*$/) n--; for (i = 1; i <= n; i++) print line[i] }' |
    tr 'A-Z' 'a-z' | tr -cd 'a-z0-9' > "$W/page-$p.txt"
  echo >> "$W/page-$p.txt"
  FILES="$FILES $W/page-$p.txt"
  p=$((p + 1))
done
# shellcheck disable=SC2086
awk -f "$D/pages.awk" "$W/keys.txt" $FILES > "$W/pages.txt" || exit 1

# pass 2: the document with the page numbers
# shellcheck disable=SC2086
(cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" $FILTERS \
  -M "pages_in=$W/pages.txt" "$SAMPLE" -o "$OUT") || exit 1
[ -f "$OUT" ] || {
  echo "render.sh: $OUT was not written" >&2
  exit 1
}
