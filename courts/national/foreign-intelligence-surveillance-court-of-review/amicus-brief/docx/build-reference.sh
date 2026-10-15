#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference: the styles of the FISCR brief (typst/fiscr-amicus-brief.typ)
# in Word terms. EB Garamond 14 pt everywhere (FRAP 32(a)(5)(A); the court names no face), exact double spacing
# (FISCR R. 9(c)(2)), first-line indents, single-spaced headings, quotations, footnotes and front matter, letter
# paper with one-inch margins (R. 9(c)(1), (3)), and footers: footer1 = centred PAGE field (R. 9(c)(4)),
# footer2 = empty (the cover is unnumbered). The section breaks themselves are written by lua/fiscr-amicus.lua.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, perl with IO::Compress::Zip, xmllint on PATH)
set -eu
OUT=$1
W=$(mktemp -d)
export W
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
cd "$W" && mkdir pkg && cd pkg && unzip -q ../ref.docx

FONTS='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>'
# every style this template uses is (re)defined below; the pandoc originals are removed first
STYLE_IDS='Normal BodyText FirstParagraph Compact BlockText FootnoteText Heading1 Heading2 Heading3 Heading4 Heading5 Hyperlink Title Subtitle Author Date Abstract Bibliography'
export FONTS STYLE_IDS
perl -0pi -e '
  my $fonts = $ENV{FONTS};
  s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$fonts<w:sz w:val="28"/><w:szCs w:val="28"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s;
  for my $id (split " ", $ENV{STYLE_IDS}) {
    s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{}s;
  }
' word/styles.xml

# the style definitions (paragraph styles unless noted; custom ones are named in lua/fiscr-amicus.lua)
cat > "$W/styles-add.xml" <<XML
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>$FONTS<w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="628" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="280" w:after="280" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="100" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="28"/><w:szCs w:val="28"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:sz w:val="32"/><w:szCs w:val="32"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading5"><w:name w:val="heading 5"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="4"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/></w:rPr></w:style>
<w:style w:type="character" w:styleId="Hyperlink"><w:name w:val="Hyperlink"/><w:rPr><w:color w:val="000000"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="280" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleTight"><w:name w:val="Single Tight"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Counsel"><w:name w:val="Counsel"/><w:basedOn w:val="SingleTight"/><w:qFormat/><w:pPr><w:ind w:left="4680" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigLine"><w:name w:val="Signature Line"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:pBdr><w:bottom w:val="single" w:sz="6" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="480" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4680" w:right="936" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="DoubleRule"><w:name w:val="Double Rule"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:pBdr><w:bottom w:val="double" w:sz="6" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="0" w:after="280" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ShortRule"><w:name w:val="Short Rule"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:pBdr><w:bottom w:val="single" w:sz="4" w:space="1" w:color="000000"/></w:pBdr><w:spacing w:before="0" w:after="280" w:line="240" w:lineRule="auto"/><w:ind w:left="3240" w:right="3240" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PointHeading"><w:name w:val="Point Heading"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:smallCaps/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SubHeading"><w:name w:val="Sub Heading"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="720"/></w:tabs><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="KeepBody"><w:name w:val="Keep With Signature"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOC1"><w:name w:val="TOC Entry 1"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="120" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="0" w:right="0" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOC2"><w:name w:val="TOC Entry 2"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="720"/><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="120" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="0" w:hanging="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOC3"><w:name w:val="TOC Entry 3"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="1440"/><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="120" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="1440" w:right="0" w:hanging="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOAGroup"><w:name w:val="Table of Authorities Group"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="right" w:pos="9360"/></w:tabs><w:spacing w:before="240" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOAEntry"><w:name w:val="Table of Authorities Entry"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepLines/><w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9360"/></w:tabs><w:spacing w:before="200" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="504" w:hanging="504"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SectionHeading"><w:name w:val="Section Heading"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="360" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:sz w:val="32"/><w:szCs w:val="32"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SectionHeadingBreak"><w:name w:val="Section Heading Break"/><w:basedOn w:val="SectionHeading"/><w:qFormat/><w:pPr><w:pageBreakBefore/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CoverLine"><w:name w:val="Cover Line"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepLines/><w:spacing w:before="0" w:after="200" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CheckLine"><w:name w:val="Check Line"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="480" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Indent"><w:name w:val="Indent"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:ind w:left="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigBlockKeep"><w:name w:val="Signature Block Keep"/><w:basedOn w:val="Counsel"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="400" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="TOCHead"><w:name w:val="TOC Head"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="right"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:pPr><w:tabs><w:tab w:val="center" w:pos="4680"/><w:tab w:val="right" w:pos="9360"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
XML
# insert the definitions before the closing tag (perl reads the file, so no sed escaping of the XML)
perl -0pi -e 'BEGIN{ local $/; open my $f, "<", "$ENV{W}/styles-add.xml" or die; $add = <$f>; close $f } s{</w:styles>}{$add</w:styles>}' word/styles.xml 2>/dev/null || {
  echo "build-reference.sh: could not insert the styles" >&2
  exit 1
}

# footer1: the page number (PAGE field, centred); footer2: empty (cover)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
cat > word/footer2.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId101" Target="footer2.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /><Override PartName="/word/footer2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'
# final section (the body after the front matter): arabic numbering from 1, footer1, letter, one-inch margins
perl -0pi -e 's{<w:sectPr\b.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal"/></w:sectPr>}s' word/document.xml
grep -q 'xmlns:r=' word/document.xml || { echo "build-reference.sh: no r namespace in document.xml" >&2; exit 1; }
for part in word/styles.xml word/document.xml word/footer1.xml word/footer2.xml; do xmllint --noout "$part"; done
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
# zip: this box has no zip(1); perl's IO::Compress::Zip (core Perl) writes the archive, [Content_Types].xml first
set -- "[Content_Types].xml" "[Content_Types].xml"
for f in $(find _rels docProps word -type f); do set -- "$@" "$f" "$f"; done
perl -MIO::Compress::Zip -e '
  my $out = shift;
  my $z;
  while (defined(my $name = shift)) {
    my $path = shift;
    open my $in, "<:raw", $path or die "$path: $!";
    local $/;
    my $data = <$in>;
    close $in;
    if (defined $z) { $z->newStream(Name => $name) or die $IO::Compress::Zip::ZipError; }
    else { $z = IO::Compress::Zip->new($out, Name => $name) or die $IO::Compress::Zip::ZipError; }
    print $z $data;
  }
  $z->close or die $IO::Compress::Zip::ZipError;
' "$OUT" "$@"
echo "$OUT"
