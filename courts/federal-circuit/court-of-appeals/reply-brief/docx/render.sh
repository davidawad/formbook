#!/bin/sh
# Build one sample as a .docx (docs/EVAL-LOOP.md, "Engines"; tools/render-docx.sh calls this and converts the result).
#   sh docx/render.sh <court-dir> <sample.md> <out.docx>
# pandoc writes the body with cafc-docx.lua on docx/reference.docx. The package then gets its footers (arabic
# pages, Add- pages) and the section numbering. The contents and the table of authorities need page numbers, which
# only the rendered pages have: LibreOffice renders the .docx, pages.sh reads the page labels, and the document is
# written again with them until they stop changing (at most 5 runs). The last run's .docx is the output.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$D/../../../../.." && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$(cd "$(dirname "$3")" && pwd)/$(basename "$3")
SCHEME=reply
SOFFICE=${SOFFICE:-soffice}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
NS='xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"'
footer() { # $1 file, $2 label prefix ("" or "Add-")
  printf '%s\n' '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' \
    "<w:ftr $NS><w:p><w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"399\" w:lineRule=\"exact\"/><w:jc w:val=\"center\"/></w:pPr>" \
    "<w:r><w:t xml:space=\"preserve\">$2</w:t></w:r><w:fldSimple w:instr=\" PAGE \"><w:r><w:t>1</w:t></w:r></w:fldSimple></w:p></w:ftr>" > "$1"
}
# The package: footer parts, their relationships and content types, the page start of the certificates.
package() { # $1 unpacked dir, $2 start page of the certificates, $3 output .docx
  X=$1
  footer "$X/word/footer-arabic.xml" ""
  footer "$X/word/footer-add.xml" "Add-"
  # bullets: pandoc's Symbol bullet (U+F0B7) becomes EB Garamond's bullet; LibreOffice would draw Symbol with OpenSymbol
  perl -0pi -e 's/w:ascii="Symbol" w:hAnsi="Symbol" w:cs="Symbol"/w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:cs="EB Garamond"/g; s/\xEF\x82\xB7/\xE2\x80\xA2/g' "$X/word/numbering.xml"
  perl -0pi -e 's#</Relationships>#<Relationship Id="rIdFooterArabic" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer-arabic.xml"/><Relationship Id="rIdFooterAdd" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer-add.xml"/></Relationships>#' "$X/word/_rels/document.xml.rels"
  perl -0pi -e 's#</Types>#<Override PartName="/word/footer-arabic.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/><Override PartName="/word/footer-add.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>#' "$X/[Content_Types].xml"
  # the last section (the certificates) is the reference's body section: it gets the arabic footer and continues the
  # numbering from the body's last page
  perl -0pi -e "s#^(.*)<w:sectPr([^>]*)>(.*?)</w:sectPr>#\$1<w:sectPr\$2><w:footerReference w:type=\"default\" r:id=\"rIdFooterArabic\"/>\$3<w:pgNumType w:fmt=\"decimal\" w:start=\"$2\"/></w:sectPr>#s" "$X/word/document.xml"
  rm -f "$3"
  (cd "$X" && zip -X -q -r "$3" .)
  unzip -tq "$3" > /dev/null
}
PAGES=$W/pages.tsv
: > "$PAGES"
prev=""
n=0
while :
do
  n=$((n + 1))
  PATS=$W/patterns.txt
  CAFC_PAGES=$PAGES CAFC_PATTERNS=$PATS \
    pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
      --lua-filter="$D/cafc-docx.lua" -M label_scheme=$SCHEME \
      -M "fontdir=$ROOT/fonts/" \
      --resource-path="$COURT" "$COURT/$SAMPLE" -o "$W/build.docx" || exit 1
  rm -rf "$W/x" && mkdir "$W/x" && (cd "$W/x" && unzip -q "$W/build.docx")
  START=$(awk -F'\t' '$1 == "_cert_start" { print $2 }' "$PAGES")
  package "$W/x" "${START:-1}" "$W/pass.docx"
  rm -rf "$W/pdf" && mkdir "$W/pdf"
  "$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W/pdf" "$W/pass.docx" > "$W/soffice.log" 2>&1 || {
    cat "$W/soffice.log" >&2
    echo "render.sh: LibreOffice did not convert $W/pass.docx" >&2
    exit 1
  }
  sh "$D/pages.sh" "$W/pdf/pass.pdf" "$PATS" > "$W/pages.new"
  if [ "$(cat "$W/pages.new")" = "$(cat "$PAGES")" ]; then
    break
  fi
  if [ "$n" -ge 5 ]; then
    echo "render.sh: the page numbers did not settle in 5 runs" >&2
    exit 1
  fi
  cp "$W/pages.new" "$PAGES"
  prev=$n
done
cp "$W/pass.docx" "$OUT"
echo "$OUT"
