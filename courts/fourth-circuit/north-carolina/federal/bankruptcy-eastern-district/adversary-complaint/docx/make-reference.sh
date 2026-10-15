#!/bin/sh
# Builds docx/reference.docx for the nceb adversary complaint from pandoc's default reference document. The
# settings follow typst/nceb-adversary-complaint.typ (the court's form is not set by a local rule; see ../README.md):
# EB Garamond 12 pt; body double-spaced (24 pt exact); allegations at the left margin (numbered by nceb-adversary-complaint.lua);
# headings centered; caption and signature styles single-spaced (13.8 pt exact); block quotations indented 1 inch
# both sides; letter page with 1-inch margins; a centered page-number footer.
# Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/x"
(cd "$T/x" && unzip -q "$T/default.docx")
W="$T/w"
mkdir "$W"
cp -R "$T/x/." "$W/"

# Style definitions. Each id here replaces any pandoc style with the same id.
cat > "$T/styles.frag" <<'XML'
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="120" w:after="240" w:line="276" w:lineRule="exact"/><w:ind w:left="1440" w:right="1440" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="480" w:after="240" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:b/><w:bCs/><w:caps/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="120" w:after="120" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="120" w:after="240" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="table" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/><w:uiPriority w:val="59"/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblCellMar><w:top w:w="60" w:type="dxa"/><w:left w:w="120" w:type="dxa"/><w:bottom w:w="60" w:type="dxa"/><w:right w:w="120" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCEBSingle"><w:name w:val="NCEB Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCEBCourt"><w:name w:val="NCEB Court"/><w:basedOn w:val="NCEBSingle"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCEBDivision"><w:name w:val="NCEB Division"/><w:basedOn w:val="NCEBCourt"/><w:qFormat/><w:pPr><w:spacing w:after="360"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCEBCaptionCell"><w:name w:val="NCEB Caption Cell"/><w:basedOn w:val="NCEBSingle"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCEBDesignation"><w:name w:val="NCEB Designation"/><w:basedOn w:val="NCEBSingle"/><w:qFormat/><w:pPr><w:spacing w:after="240"/><w:jc w:val="right"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCEBCaseNumbers"><w:name w:val="NCEB Case Numbers"/><w:basedOn w:val="NCEBSingle"/><w:qFormat/><w:pPr><w:spacing w:before="480" w:after="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCEBTitle"><w:name w:val="NCEB Title"/><w:basedOn w:val="NCEBCourt"/><w:qFormat/><w:pPr><w:spacing w:before="360" w:after="240"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCEBLeadIn"><w:name w:val="NCEB Lead In"/><w:basedOn w:val="NCEBSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCEBSignature"><w:name w:val="NCEB Signature"/><w:basedOn w:val="NCEBSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:left="4320" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCEBSignatureLast"><w:name w:val="NCEB Signature Last"/><w:basedOn w:val="NCEBSignature"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:after="240"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCEBQuoteItem"><w:name w:val="NCEB Quote Item"/><w:basedOn w:val="NCEBSingle"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="120"/><w:ind w:left="1800" w:right="1440" w:hanging="360"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCEBListItem"><w:name w:val="NCEB List Item"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:left="720" w:hanging="360"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCEBListItemLast"><w:name w:val="NCEB List Item Last"/><w:basedOn w:val="NCEBListItem"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCEBIndentItem"><w:name w:val="NCEB Indent Item"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:left="720" w:firstLine="0"/></w:pPr></w:style>
XML
# Replace the pandoc styles with these (remove the old block, append the new one before </w:styles>).
FRAG="$T/styles.frag" perl -0pi -e '
  my $frag = do { local $/; open my $f, "<", $ENV{FRAG} or die "frag"; <$f> };
  my @ids = ($frag =~ /w:styleId="([^"]+)"/g);
  for my $id (@ids) { s{<w:style [^>]*w:styleId="\Q$id\E".*?</w:style>\s*}{}s }
  s{</w:styles>}{$frag</w:styles>}s;
  s{<w:rFonts w:asciiTheme="minorHAnsi".*?/>}{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />}s;
' "$W/word/styles.xml"

# Page setup and the page-number footer (section properties come first in sectPr: footerReference before footnotePr).
perl -0pi -e '
  s{(<w:sectPr>)}{$1<w:footerReference w:type="default" r:id="rIdFooter1" />}s;
  s{(<w:footnotePr>\s*<w:numRestart w:val="eachSect" />\s*</w:footnotePr>)}{$1<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />}s;
' "$W/word/document.xml"
cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
