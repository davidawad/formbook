#!/bin/sh
# Build docx/reference.docx: pandoc's default reference (numbering, settings, theme) with this court's styles
# (styles.xml.in) and the brief's page setup: letter, one inch margins, footer 0.4 in from the page edge.
# Usage: sh docx/make-reference.sh <body-line-twips> <out.docx>
#   body line pitch: 629 twips (31.43 pt, 0.94em leading) for the opening and reply briefs, 643 (32.13 pt) for the answering brief.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/base.docx" --print-default-data-file reference.docx
mkdir "$W/x"
(cd "$W/x" && unzip -q "$W/base.docx")
sed -e "s/@BODY@/$1/g" -e "s/@SINGLE@/399/g" "$D/styles.xml.in" > "$W/x/word/styles.xml"
# bullets in EB Garamond: pandoc's default bullet font is Symbol, which LibreOffice draws with its own OpenSymbol
sed -i -e 's/w:ascii="Symbol" w:hAnsi="Symbol"/w:ascii="EB Garamond" w:hAnsi="EB Garamond"/g' "$W/x/word/numbering.xml"
perl -CSD -pi -e 's/\x{F0B7}/\x{2022}/g' "$W/x/word/numbering.xml"
cat > "$W/x/word/document.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:body><w:p/><w:sectPr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="0" w:footer="576" w:gutter="0"/></w:sectPr></w:body></w:document>
XML
OUT=$(cd "$(dirname "$2")" && pwd)/$(basename "$2")
rm -f "$OUT"
(cd "$W/x" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
