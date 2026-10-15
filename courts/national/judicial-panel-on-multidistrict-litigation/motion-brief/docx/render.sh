#!/bin/sh
# DOCX engine for the JPML motion-brief (docs/DOCX.md). Called by tools/render-docx.sh as:
#   sh docx/render.sh <doc-type-dir> <sample.md> <out.docx>
# Writes the .docx only; tools/render-docx.sh converts it to PDF with LibreOffice and checks it.
#
# Two passes give the table of contents and the table of authorities their page numbers: pass 1 builds the document
# with placeholder numbers, LibreOffice renders it, and docx/pages.awk finds where each heading and each authority
# lands; pass 2 builds it with those numbers. The build repeats until the numbers found in the rendered PDF equal the
# numbers the document was built with, so a stale table of contents cannot be delivered.
set -eu
D=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
H=$D/docx
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

# build <n> <pages.tsv or empty>: writes $W/build<n>.docx and $W/needles<n>.tsv
build() {
  if [ -n "$2" ]; then export JPML_PAGES=$2; else unset JPML_PAGES; fi
  JPML_NEEDLES=$W/needles$1.tsv
  export JPML_NEEDLES
  (cd "$D" && pandoc --from markdown+smart --to docx --reference-doc="$H/reference.docx" \
    --lua-filter="$H/jpml.lua" "$SAMPLE" -o "$W/build$1.docx") || {
    echo "docx/render.sh: pandoc failed (pass $1)" >&2
    exit 1
  }
  unset JPML_PAGES JPML_NEEDLES
}

# pages <n>: LibreOffice PDF of build<n>.docx, then the page list from pages.awk into $W/pages<n>.tsv
pages() {
  mkdir -p "$W/pdf$1"
  "$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W/pdf$1" \
    "$W/build$1.docx" > "$W/soffice$1.log" 2>&1 || {
    cat "$W/soffice$1.log" >&2
    exit 1
  }
  LC_ALL=C pdftotext -enc UTF-8 "$W/pdf$1/build$1.pdf" - |
    LC_ALL=C gawk -v NEED="$W/needles$1.tsv" -f "$H/pages.awk" > "$W/pages$1.tsv" || {
    echo "docx/render.sh: could not place the headings and authorities in the rendered PDF (pass $1)" >&2
    exit 1
  }
}

build 1 ""
pages 1
n=1
while :; do
  build $((n + 1)) "$W/pages$n.tsv"
  pages $((n + 1))
  n=$((n + 1))
  if cmp -s "$W/pages$((n - 1)).tsv" "$W/pages$n.tsv"; then break; fi
  if [ "$n" -ge 4 ]; then
    echo "docx/render.sh: the page numbers do not settle after $n passes" >&2
    exit 1
  fi
done
# fix_final <in.docx> <out.docx>: pandoc writes its own final sectPr and ignores the reference's, so the memorandum
# body would inherit the table-of-authorities footer and numbering. This puts the section properties (page-number
# footer, arabic from 1) on the body's last section, and repackages the file with libzip's ziptool (no zip(1) here).
fix_final() {
  X=$W/fix
  DEST=$2
  rm -rf "$X"
  mkdir -p "$X"
  (cd "$X" && unzip -q "$1")
  perl -0pi -e 's{<w:sectPr>(?:(?!<w:sectPr).)*?</w:sectPr>(\s*</w:body>)}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/><w:cols w:space="720"/></w:sectPr>$1}s' "$X/word/document.xml"
  xmllint --noout "$X/word/document.xml" || {
    echo "docx/render.sh: document.xml is not well-formed after the section fix" >&2
    exit 1
  }
  rm -f "$DEST"
  set -- add_file '[Content_Types].xml' "$X/[Content_Types].xml" 0 0
  for f in $(cd "$X" && find . -type f | sed 's|^\./||' | grep -v '^\[Content_Types\].xml$' | sort); do
    set -- "$@" add_file "$f" "$X/$f" 0 0
  done
  ziptool -n "$DEST" "$@" > /dev/null
  unzip -tq "$DEST" > /dev/null
}

fix_final "$W/build$n.docx" "$OUT"
echo "$OUT"
