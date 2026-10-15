#!/bin/sh
# Builds docx/reference.docx for the ilcb court (C.D. Illinois bankruptcy) from pandoc's default reference.
# Mirrors the typst template (typst/ilcb-*.typ): EB Garamond 13 pt, body paragraphs double spaced
# (exact 28.4 pt pitch, measured on the typst render), 0.5 in first-line indent, 1 in margins on US Letter,
# single-spaced block quotations and footnotes (11 pt), centered page number in the footer.
# Usage: sh docx/build-reference.sh [out.docx]   (default: reference.docx beside this script; needs pandoc, unzip, zip, xmllint, perl)
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$HERE/reference.docx}
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/ref.docx"

# 1. document defaults: EB Garamond 13 pt, no space after, single line spacing unless a style says otherwise
perl -0777 -i -pe 's{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="zh-CN" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s' word/styles.xml

# 2. styles: each style below replaces the pandoc style of the same id, or is added (custom styles)
cat > "$W/styles-frag.xml" <<'XML'
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="568" w:lineRule="exact"/><w:ind w:firstLine="720"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="416" w:after="260" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="312" w:after="234" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="260" w:after="208" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="234" w:after="182" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:i/><w:iCs/><w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="100" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CenteredBold"><w:name w:val="Centered Bold"/><w:basedOn w:val="Centered"/><w:qFormat/><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtHeadEnd"><w:name w:val="Court Head End"/><w:basedOn w:val="CenteredBold"/><w:qFormat/><w:pPr><w:spacing w:after="390"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TitleLine"><w:name w:val="Title Line"/><w:basedOn w:val="CenteredBold"/><w:qFormat/><w:pPr><w:keepLines/><w:spacing w:before="390" w:after="390"/><w:ind w:left="702" w:right="702" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleGap"><w:name w:val="Single Gap"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:after="234"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertBody"><w:name w:val="Certificate Body"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:after="260"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertHead"><w:name w:val="Certificate Heading"/><w:basedOn w:val="CenteredBold"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="520" w:after="260"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyKeep"><w:name w:val="Body Keep"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="DatedLine"><w:name w:val="Dated Line"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="390" w:after="312"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigTop"><w:name w:val="Signature Top"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="390" w:after="260"/><w:ind w:left="4212" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigFirst"><w:name w:val="Signature First"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="260"/><w:ind w:left="4212" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertBody"><w:name w:val="Certificate Body"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:after="260"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertLine"><w:name w:val="Certificate Line"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertGap"><w:name w:val="Certificate Gap"/><w:basedOn w:val="CertLine"/><w:qFormat/><w:pPr><w:spacing w:after="234"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertSig"><w:name w:val="Certificate Signature"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepLines/><w:spacing w:before="312"/><w:ind w:left="4212" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigLine"><w:name w:val="Signature Line"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:left="4212" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigGap"><w:name w:val="Signature Gap"/><w:basedOn w:val="SigLine"/><w:qFormat/><w:pPr><w:spacing w:after="260"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigEnd"><w:name w:val="Signature End"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:left="4212" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CounselFirst"><w:name w:val="Counsel First"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="312"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CounselLine"><w:name w:val="Counsel Line"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionCell"><w:name w:val="Caption Cell"/><w:basedOn w:val="Single"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionParen"><w:name w:val="Caption Paren"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>
XML
perl -0777 -e '
  my ($file, $frag) = @ARGV;
  local $/; open my $fh, "<", $file or die; my $s = <$fh>; close $fh;
  open my $gh, "<", $frag or die; my $f = <$gh>; close $gh;
  my $add = "";
  while ($f =~ m{(<w:style [^>]*?w:styleId="([^"]+)".*?</w:style>)}gs) {
    my ($x, $id) = ($1, $2);
    unless ($s =~ s{<w:style [^>]*?w:styleId="\Q$id\E".*?</w:style>}{$x}s) { $add .= $x }
  }
  $s =~ s{</w:styles>}{$add</w:styles>}s;
  print $s;
' word/styles.xml "$W/styles-frag.xml" > "$W/styles.new" && mv "$W/styles.new" word/styles.xml

# 3. footer with the page number (PAGE field; cached result 1), centered, on every page
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

# 4. section: US Letter, 1 in margins, footer reference. Replaces pandoc's own body sectPr (footnote restart only).
perl -0777 -i -pe 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>}s' word/document.xml
grep -q 'footerReference' word/document.xml || { echo "build-reference.sh: section not set" >&2; exit 1; }

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
