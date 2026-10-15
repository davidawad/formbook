#!/bin/sh
# DOCX build for this doc type (docs/DOCX.md). Owns the .docx: tools/render-docx.sh calls this with
#   sh docx/render.sh <doc-type-dir> <sample.md, relative to the doc-type dir> <out.docx>
# The table of contents and table of authorities need page numbers, which Word and LibreOffice do not compute
# at conversion time. So: pass 1 writes the .docx and the search keys; LibreOffice renders it to PDF; pages.sh
# finds each heading and authority on the PDF pages; pass 2 writes the page numbers in. The pass repeats until
# the page map is the same as the one it was built from (at most three passes). The PDF that tools/check.sh
# measures is then the LibreOffice conversion of this .docx (tools/render-docx.sh makes it).
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
D=$(cd "$(dirname "$0")" && pwd)
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
KEYS="$W/keys.txt"

# one pass: the .docx from pandoc; $1 = page map to use ("" on the first pass), $2 = out .docx
build() {
  if [ -n "$1" ]; then
    (cd "$COURT" && FISCR_KEYS="$KEYS" FISCR_PAGES="$1" pandoc --from markdown+smart --to docx \
      --reference-doc="$D/reference.docx" --lua-filter="$D/fiscr-amicus.lua" "$SAMPLE" -o "$2")
  else
    (cd "$COURT" && FISCR_KEYS="$KEYS" pandoc --from markdown+smart --to docx \
      --reference-doc="$D/reference.docx" --lua-filter="$D/fiscr-amicus.lua" "$SAMPLE" -o "$2")
  fi
}

# LibreOffice PDF of a .docx: $1 = docx, $2 = out pdf
to_pdf() {
  n=$(basename "$1" .docx)
  mkdir -p "$W/pdf-$n"
  "$SOFFICE" "-env:UserInstallation=file://$W/profile-$n" --headless --convert-to pdf --outdir "$W/pdf-$n" "$1" > "$W/soffice-$n.log" 2>&1 || {
    cat "$W/soffice-$n.log" >&2
    echo "render.sh: LibreOffice failed on $1" >&2
    exit 1
  }
  [ -f "$W/pdf-$n/$n.pdf" ] || {
    echo "render.sh: LibreOffice wrote no PDF for $1" >&2
    exit 1
  }
  cp "$W/pdf-$n/$n.pdf" "$2"
}

build "" "$W/p1.docx"
to_pdf "$W/p1.docx" "$W/p1.pdf"
sh "$D/pages.sh" "$W/p1.pdf" "$KEYS" > "$W/pages1.txt"

build "$W/pages1.txt" "$W/p2.docx"
to_pdf "$W/p2.docx" "$W/p2.pdf"
sh "$D/pages.sh" "$W/p2.pdf" "$KEYS" > "$W/pages2.txt"
if cmp -s "$W/pages1.txt" "$W/pages2.txt"; then
  FINAL="$W/p2.docx"
else
  build "$W/pages2.txt" "$W/p3.docx"
  to_pdf "$W/p3.docx" "$W/p3.pdf"
  sh "$D/pages.sh" "$W/p3.pdf" "$KEYS" > "$W/pages3.txt"
  cmp -s "$W/pages2.txt" "$W/pages3.txt" || {
    echo "render.sh: the table of contents and authorities page numbers did not settle in three passes" >&2
    exit 1
  }
  FINAL="$W/p3.docx"
fi
cp "$FINAL" "$OUT"
echo "$OUT"
