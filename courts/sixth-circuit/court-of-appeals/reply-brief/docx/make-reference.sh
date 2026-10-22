#!/usr/bin/env bash
# Builds docx/reference.docx: the shared style recipe of the cross-engine layout
# model (lib/docx/xengine-reference.sh; docs/EVAL-LOOP.md, "Cross-engine gate": Times New Roman 14 pt, Body Text in
# 31.4 pt line boxes with a half-inch indent, footnotes 14 pt in 20 pt boxes with 7 pt between them, block quotations
# 14 pt above and below; exact line spacing; the typst pitch-double and pitch-single), plus the footers in
# docx/reference-src/ (none on the cover, the page number in a 20 pt line) and the page setup of the last section.
# Every other paragraph (cover, headings, tables, signature, certificates) carries its own spacing, written by
# ca6-reply-brief.lua. Rerun after editing reference-src/ or the numbers below.
# Needs: pandoc, perl, unzip, zip, xmllint (the formbook toolchain).
set -euo pipefail
D=$(cd "$(dirname "$0")" && pwd)
S=$D/reference-src
T=$(mktemp -d) || exit 1
# safe_rmdir <dir>: delete a directory made by mktemp -d (or one inside it), and nothing else
safe_rmdir() {
  t=${TMPDIR:-/tmp}
  case "${1:?}" in
    "${t%/}"/tmp.* | /tmp/tmp.*) find "$1" -depth -delete ;;
    *) return 1 ;;
  esac
}
trap 'safe_rmdir "$T"' EXIT
sh "$D/../../../../../lib/docx/xengine-reference.sh" "$T/base.docx" font="Times New Roman" size=28 body=628 \
  single=400 indent=720 quote=280 note_after=140 >/dev/null

# build <final footer relationship id> <out.docx>
build() {
  W=$(mktemp -d "$T/w.XXXXXX") || exit 1
  (cd "$W" && unzip -q "$T/base.docx")
  # the body's last paragraph stays with the signature block (typst sets them in one unbreakable block)
  perl -0pi -e 's{</w:styles>}{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CABodyKeep"><w:name w:val="CA Body Keep"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style></w:styles>} or die "styles"' "$W/word/styles.xml"
  # the recipe's single footer gives way to the three of this brief
  rm -f "$W/word/footer1.xml"
  perl -0pi -e 's{<Relationship [^>]*Id="rIdFooter1"[^>]*/>}{}' "$W/word/_rels/document.xml.rels"
  perl -0pi -e 's{<Override PartName="/word/footer1.xml"[^>]*/>}{}' "$W/[Content_Types].xml"
  cp "$S/footer0.xml" "$S/footer1.xml" "$W/word/"
  # Word 2013+ layout rules (tab stops measured from the margin, as LibreOffice needs for the TOC)
  sed -i "s#<w:rsids>#<w:compat><w:compatSetting w:name=\"compatibilityMode\" w:uri=\"http://schemas.microsoft.com/office/word\" w:val=\"15\"/></w:compat><w:rsids>#" "$W/word/settings.xml"
  R=http://schemas.openxmlformats.org/officeDocument/2006/relationships
  sed -i "s#</Relationships>#<Relationship Type=\"$R/footer\" Id=\"rIdFtr0\" Target=\"footer0.xml\" /><Relationship Type=\"$R/footer\" Id=\"rIdFtr1\" Target=\"footer1.xml\" /></Relationships>#" "$W/word/_rels/document.xml.rels"
  M=application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml
  sed -i "s#</Types>#<Override PartName=\"/word/footer0.xml\" ContentType=\"$M\" /><Override PartName=\"/word/footer1.xml\" ContentType=\"$M\" /></Types>#" "$W/[Content_Types].xml"
  SECT="<w:sectPr><w:footerReference w:type=\"default\" r:id=\"$1\" /><w:pgSz w:w=\"12240\" w:h=\"15840\" /><w:pgMar w:top=\"1440\" w:right=\"1440\" w:bottom=\"1440\" w:left=\"1440\" w:header=\"720\" w:footer=\"720\" w:gutter=\"0\" /><w:pgNumType w:fmt=\"decimal\" w:start=\"1\" /></w:sectPr>"
  SECT=$SECT perl -0pi -e 's{<w:sectPr>.*</w:sectPr>}{$ENV{SECT}}s or die "sectPr"' "$W/word/document.xml"
  for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do
    xmllint --noout "$f"
  done
  rm -f "$2"
  (cd "$W" && zip -q -X -r "$2" '[Content_Types].xml' _rels docProps word)
}

build rIdFtr1 "$D/reference.docx"
echo "$D/reference.docx"
