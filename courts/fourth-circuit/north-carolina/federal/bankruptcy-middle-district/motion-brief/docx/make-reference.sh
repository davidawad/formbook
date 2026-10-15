#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document (see ../../../../../../../docs/DOCX.md).
# Form (from ../typst/ncmb-motion-brief.typ): EB Garamond 13 pt; body double-spaced at an exact 24 pt pitch,
# first-line indent 0.5 in, no space between paragraphs; headings single-spaced with 12 pt above and below:
# level 1 centered bold capitals, levels 2 to 5 bold with a 0.5 in hanging label (I., A., 1., a.), the label
# written by ncmb-motion-brief.lua; block quotations single-spaced, 0.5 in each side; footnotes 13 pt, single;
# letter page, 1-inch margins; the page number centered at the foot of every page but the first (the caption page).
# The caption, cover, lists, signature block and certificate of service are built by ncmb-motion-brief.lua.
# Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
F='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>'
pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/w"
(cd "$T/w" && unzip -q "$T/default.docx")

cat > "$T/frag.xml" <<XML
<w:docDefaults><w:rPrDefault><w:rPr>$F<w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/></w:pPr><w:rPr>$F<w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading1Char"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="0" w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr>$F<w:b/><w:bCs/><w:caps/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading2Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr>$F<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading3Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="1440" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr>$F<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading4Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="2160" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr>$F<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading5"><w:name w:val="heading 5"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading5Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="2880" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="4"/></w:pPr><w:rPr>$F<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepLines/><w:spacing w:before="140" w:after="140" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr>$F<w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text"/><w:basedOn w:val="Normal"/><w:next w:val="FootnoteText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="100" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr>$F<w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBSingle"><w:name w:val="NCMB Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="0" w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr>$F<w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBCourt"><w:name w:val="NCMB Court"/><w:basedOn w:val="NCMBSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBCourtLast"><w:name w:val="NCMB Court Last"/><w:basedOn w:val="NCMBCourt"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="480" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBCaption"><w:name w:val="NCMB Caption"/><w:basedOn w:val="NCMBSingle"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="320" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBCaptionRight"><w:name w:val="NCMB Caption Right"/><w:basedOn w:val="NCMBCaption"/><w:qFormat/><w:pPr><w:ind w:left="360"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBTitle"><w:name w:val="NCMB Title"/><w:basedOn w:val="NCMBSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="420" w:after="240" w:line="240" w:lineRule="auto"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBList"><w:name w:val="NCMB List"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1620"/></w:tabs><w:ind w:left="1620" w:hanging="900"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBSub"><w:name w:val="NCMB Sub"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:left="1440" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBBody"><w:name w:val="NCMB Body"/><w:basedOn w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBSigLeftFirst"><w:name w:val="NCMB Sig Left First"/><w:basedOn w:val="NCMBSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="480" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBSigRight"><w:name w:val="NCMB Sig Right"/><w:basedOn w:val="NCMBSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:ind w:left="4680"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBSigRightGap"><w:name w:val="NCMB Sig Right Gap"/><w:basedOn w:val="NCMBSigRight"/><w:qFormat/><w:pPr><w:spacing w:before="240" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBSigRightSmall"><w:name w:val="NCMB Sig Right Small"/><w:basedOn w:val="NCMBSigRight"/><w:qFormat/><w:pPr><w:spacing w:before="60" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBCertHead"><w:name w:val="NCMB Cert Head"/><w:basedOn w:val="NCMBTitle"/><w:qFormat/><w:pPr><w:pageBreakBefore/><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBCertStatement"><w:name w:val="NCMB Cert Statement"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="240" w:line="480" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBRecipient"><w:name w:val="NCMB Recipient"/><w:basedOn w:val="NCMBSingle"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="NCMBRecipientMethod"><w:name w:val="NCMB Recipient Method"/><w:basedOn w:val="NCMBRecipient"/><w:qFormat/><w:pPr><w:keepNext w:val="0"/><w:spacing w:before="60" w:after="160" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
XML

perl -0777 -e '
  my ($frag, $in) = @ARGV;
  local $/;
  open(my $fh, "<", $frag) or die "frag"; my $n = <$fh>; close $fh;
  open($fh, "<", $in) or die "in"; my $s = <$fh>; close $fh;
  if ($n =~ m{(<w:docDefaults>.*?</w:docDefaults>)}s) {
    my $dd = $1;
    $s =~ s{<w:docDefaults>.*?</w:docDefaults>}{$dd}s or die "docDefaults";
  }
  my @add;
  while ($n =~ m{(<w:style [^>]*?w:styleId="([^"]+)".*?</w:style>)}sg) {
    my ($x, $id) = ($1, $2);
    $s =~ s{<w:style [^>]*?w:styleId="\Q$id\E".*?</w:style>}{}s;
    push @add, $x;
  }
  my $add = join("\n", @add);
  $s =~ s{</w:styles>}{$add\n</w:styles>}s or die "styles end";
  print $s;
' "$T/frag.xml" "$T/w/word/styles.xml" > "$T/styles.new" && mv "$T/styles.new" "$T/w/word/styles.xml"

# Page setup. The first page (the caption page) has no page number; later pages are numbered at the foot.
perl -0pi -e '
  s{(<w:sectPr>)}{$1<w:footerReference w:type="default" r:id="rIdFooter1" /><w:footerReference w:type="first" r:id="rIdFooter2" />}s;
  s{(<w:footnotePr>\s*<w:numRestart w:val="eachSect" />\s*</w:footnotePr>)}{$1<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" /><w:titlePg />}s;
' "$T/w/word/document.xml"
cat > "$T/w/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center" /></w:pPr><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
cat > "$T/w/word/footer2.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center" /></w:pPr></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter2" Target="footer2.xml" />$1}s' "$T/w/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /><Override PartName="/word/footer2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$T/w/[Content_Types].xml"

for f in "$T/w/word/styles.xml" "$T/w/word/document.xml" "$T/w/word/footer1.xml" "$T/w/word/footer2.xml" "$T/w/word/_rels/document.xml.rels" "$T/w/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$T/w" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
