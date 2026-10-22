#!/usr/bin/env bash
# docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# Owns the build of the .docx (tools/render-docx.sh hands over to it). Pandoc writes the body from ca4.lua on
# reference.docx; this script then writes the sections (cover: no number; front matter: lower roman; body: arabic
# from 1), the page-number footers and the page setup, which pandoc does not carry over from the reference.
# The TOC and TOA page numbers come from the PDF: pass 1 writes the .docx with placeholders, LibreOffice converts
# it, pagemap.awk reads the page of each heading and authority from that PDF; the next pass writes the numbers into
# the .docx, until a pass gives the numbers it was written with (see the loop at the end).
set -euo pipefail
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
FILTER=$D/ca4.lua
# safe_rmdir <dir>: delete a directory made by mktemp -d (or one inside it), and nothing else
safe_rmdir() {
  t=${TMPDIR:-/tmp}
  case "${1:?}" in
    "${t%/}"/tmp.* | /tmp/tmp.*) find "$1" -depth -delete ;;
    *) return 1 ;;
  esac
}
if [ -n "${RENDER_WORK:-}" ]; then
  W=$RENDER_WORK   # RENDER_WORK=<dir>: keep the intermediate files there
else
  W=$(mktemp -d) || exit 1
  trap 'safe_rmdir "$W"' EXIT
fi

finish() { # <raw.docx> <out.docx>: sections, footers, page setup; a valid zip with well-formed XML
  X=$(mktemp -d "$W/pkg.XXXXXX") || exit 1
  (cd "$X" && unzip -q "$1")
  cp "$D/footer.xml" "$X/word/footer-roman.xml"
  cp "$D/footer.xml" "$X/word/footer-arabic.xml"
  sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdRomanFtr" Target="footer-roman.xml"/><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdArabicFtr" Target="footer-arabic.xml"/></Relationships>|' "$X/word/_rels/document.xml.rels"
  sed -i 's|</Types>|<Override PartName="/word/footer-roman.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/><Override PartName="/word/footer-arabic.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>|' "$X/[Content_Types].xml"
  perl -0pi -e 's/RIDROMAN/rIdRomanFtr/g; s{<w:sectPr>(?:(?!<w:sectPr>).)*?</w:sectPr>(\s*</w:body>)}{<w:sectPr><w:footerReference w:type="default" r:id="rIdArabicFtr"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr>$1}s' "$X/word/document.xml"
  for part in word/document.xml word/footer-roman.xml word/footer-arabic.xml word/styles.xml word/_rels/document.xml.rels; do
    xmllint --noout "$X/$part" || { echo "render.sh: $part is not well-formed XML" >&2; exit 1; }
  done
  rm -f "$2"
  (cd "$X" && zip -q -X "$2" '[Content_Types].xml' && zip -q -X -r "$2" _rels word docProps)
  unzip -tq "$2" > /dev/null || { echo "render.sh: $2 is not a valid zip" >&2; exit 1; }
}

build() { # <out.docx> <page map, or empty> <manifest>
  (cd "$COURT" && DOCX_PAGEMAP="$2" DOCX_MANIFEST="$3" pandoc --from markdown+smart --to docx \
    --reference-doc="$D/reference.docx" --lua-filter="$FILTER" "$SAMPLE" -o "$W/raw.docx") >&2 || return 1
  finish "$W/raw.docx" "$1"
}

convert() { # <docx>: the LibreOffice PDF, in $W/pdf
  mkdir -p "$W/pdf"
  "$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W/pdf" "$1" > "$W/soffice.log" 2>&1 || {
    cat "$W/soffice.log" >&2
    return 1
  }
  echo "$W/pdf/$(basename "${1%.docx}").pdf"
}

pagemap() { # <pdf> <manifest>: the page map on stdout; fails on any MISSING search
  P=$(mktemp -d "$W/pages.XXXXXX") || exit 1
  n=$(pdfinfo "$1" | awk '/^Pages:/ { print $2 }')
  files=""
  i=1
  while [ "$i" -le "$n" ]; do
    pdftotext -layout -f "$i" -l "$i" "$1" "$P/$i.txt"
    files="$files $P/$i.txt"
    i=$((i + 1))
  done
  # shellcheck disable=SC2086
  awk -v man="$2" -f "$D/pagemap.awk" $files > "$P/map.txt"
  if grep -q '^MISSING' "$P/map.txt"; then
    grep '^MISSING' "$P/map.txt" | sed 's/^/render.sh: not found in the PDF: /' >&2
    return 1
  fi
  cat "$P/map.txt"
}

# Pass 1 has no page numbers. Each later pass writes those of the pass before, and the headings any pass found at the
# foot of a page (E rows) open the next page from then on (typst's sticky headings; ca4.lua writes headings without
# keep-with-next, which LibreOffice honours by moving a heading whenever the paragraph after it is split). The render
# is done when a pass gives the page map it was written with; at most five passes.
build "$W/p1.docx" "" "$W/man1.txt"
pagemap "$(convert "$W/p1.docx")" "$W/man1.txt" > "$W/map1.txt" || exit 1
pass=1
while :; do
  m=$((pass + 1))
  build "$W/p$m.docx" "$W/map$pass.txt" "$W/man$m.txt"
  pagemap "$(convert "$W/p$m.docx")" "$W/man$m.txt" > "$W/new.txt" || exit 1
  { grep -v '^E' "$W/new.txt" || true; { grep '^E' "$W/map$pass.txt" "$W/new.txt" -h || true; } | sort -u; } > "$W/map$m.txt"
  cmp -s "$W/map$pass.txt" "$W/map$m.txt" && break
  if [ "$m" -ge 5 ]; then
    echo "render.sh: the page numbers do not settle after $m passes:" >&2
    diff "$W/map$pass.txt" "$W/map$m.txt" >&2
    exit 1
  fi
  pass=$m
done
cp "$W/p$m.docx" "$OUT"
echo "$OUT"
