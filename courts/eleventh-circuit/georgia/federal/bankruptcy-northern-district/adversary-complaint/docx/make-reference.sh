#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document (docs/DOCX.md), to match typst/ganb-adversary-complaint.typ:
# EB Garamond 13 pt; body text 1.5 spaced (22.4 pt exact) with a half-inch first-line indent; single-spaced cover, caption,
# signature and footnote text (footnotes 11 pt); headings bold (level 1 centered capitals); letter page with 1-inch margins;
# a centered page-number footer (11 pt). Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
CERT_IND=0 # certificate text: the complaint template sets no first-line indent for it

pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/x"
(cd "$T/x" && unzip -q "$T/default.docx")
W="$T/w"
mkdir "$W"
cp -R "$T/x/." "$W/"

cat > "$T/docdefaults.frag" <<'XML'
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
XML

cat > "$T/styles.frag" <<'XML'
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="32" w:line="448" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Numbered"><w:name w:val="Numbered"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1152"/></w:tabs></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertificateText"><w:name w:val="Certificate Text"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="@CERT_IND@"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="208" w:line="299" w:lineRule="exact"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="120" w:line="254" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="312" w:after="234" w:line="299" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="234" w:after="182" w:line="299" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="208" w:after="156" w:line="299" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="299" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionLine"><w:name w:val="Caption Line"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="130" w:line="299" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Rule"><w:name w:val="Rule"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="156" w:after="0" w:line="120" w:lineRule="exact"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Signature"><w:name w:val="Signature"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="130" w:line="299" w:lineRule="exact"/><w:ind w:left="4680" w:firstLine="0"/></w:pPr></w:style>
XML
sed -i "s|@CERT_IND@|$CERT_IND|" "$T/styles.frag"

# Replace the doc defaults, then each style this reference defines (pandoc's copy is removed first).
DOCDEF="$T/docdefaults.frag" STYLES="$T/styles.frag" perl -0pi -e '
  BEGIN {
    local $/;
    open my $d, "<", $ENV{DOCDEF} or die "docdefaults: $!"; our $docdef = <$d>;
    open my $s, "<", $ENV{STYLES} or die "styles: $!"; our $styles = <$s>;
    our @ids = $styles =~ /w:styleId="([^"]+)"/g;
  }
  s{<w:docDefaults>.*?</w:docDefaults>}{$docdef}s or die "no docDefaults";
  for my $id (@ids) {
    s{<w:style\b[^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{}s;
  }
  s{</w:styles>}{$styles</w:styles>}s;
' "$W/word/styles.xml"

# Body section: letter, 1 in margins, the page-number footer.
cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{<w:sectPr\b.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>}s or die "no sectPr";' "$W/word/document.xml"
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"

for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do
  xmllint --noout "$f"
done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
