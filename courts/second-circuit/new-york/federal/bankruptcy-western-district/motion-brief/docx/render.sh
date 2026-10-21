#!/bin/sh
# Builds the court's .docx (tools/render-docx.sh delegates here: sh docx/render.sh <court-dir> <sample.md> <out.docx>).
# Two passes. pandoc writes the body with the Lua filter; pandoc 3.12 does not carry the reference's styles.xml, footer
# or page setup into the output, so this script puts them back. The table of contents needs page numbers: pass 1 is
# rendered with LibreOffice and docx/toc-pages.pl finds the body page of every heading; pass 2 writes them in.
# Sections: the cover (no footer), the table of contents (roman numbers from i), the body (arabic from 1).
# Layout values: docx/build-reference.sh.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFF=${SOFFICE:-soffice}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
mkdir "$W/ref"
unzip -q -o "$D/reference.docx" -d "$W/ref"

# finish <body.docx> <out.docx>: styles, footer, body section (arabic from 1), package
finish() {
  mkdir "$W/pkg"
  (cd "$W/pkg" && unzip -q "$1")
  P=$W/pkg
  cp "$W/ref/word/styles.xml" "$P/word/styles.xml"
  cp "$W/ref/word/footer1.xml" "$P/word/footer1.xml"
  # pandoc may already carry the reference's footer relationship over: add it (and its content type) only once
  perl -0pi -e 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>} unless m{Id="rId100"}' "$P/word/_rels/document.xml.rels"
  perl -0pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>} unless m{PartName="/word/footer1.xml"}' "$P/[Content_Types].xml"
  perl -0pi -e 's{(<w:sectPr\b[^>]*>(?:(?!</w:sectPr>).)*</w:sectPr>\s*)?</w:body>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal" w:start="1"/></w:sectPr></w:body>}s' "$P/word/document.xml"
  xmllint --noout "$P/word/styles.xml" "$P/word/document.xml" "$P/word/footer1.xml"
  rm -f "$2"
  (cd "$P" && zip -q -X "$2" '[Content_Types].xml' && zip -q -X -r "$2" _rels docProps word)
  rm -rf "$P"
}

build() {  # build <toc-pages-file or empty> <body.docx>
  (cd "$COURT" && NYWB_TOC_PAGES="$1" pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
    --lua-filter="$D/nywb-motion-brief.lua" "$SAMPLE" -o "$2")
}

# pass 1: no page numbers yet; render, then measure the body page of each heading
build "" "$W/pass1.docx"
finish "$W/pass1.docx" "$W/pass1-final.docx"
"$SOFF" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W" "$W/pass1-final.docx" > "$W/soffice.log" 2>&1 || {
  cat "$W/soffice.log" >&2
  exit 1
}
perl "$D/toc-pages.pl" "$W/pass1-final.pdf" "$COURT/$SAMPLE" > "$W/pages.txt"

# pass 2: the table of contents with the measured page numbers
build "$W/pages.txt" "$W/pass2.docx"
finish "$W/pass2.docx" "$OUT"
