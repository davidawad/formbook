#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference for arwd complaints (typst/arwd-complaint.typ):
# EB Garamond 12 pt, exact 27.6 pt (double) line spacing, 0.5 in first-line indent, letter page with 1 in
# margins, centered page number in the footer. Single-spaced styles (caption, court title, signature) and the
# lettered-list style are added here too. Usage: sh docx/build-reference.sh <out.docx>
# Needs pandoc, unzip, zip and xmllint on PATH (micromamba env: zip unzip libxml2).
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc --print-default-data-file reference.docx > "$W/ref.docx"
mkdir "$W/pkg"
(cd "$W/pkg" && unzip -q ../ref.docx)
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac

cat > "$W/defaults.xml" <<'XML'
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:eastAsia="EB Garamond" w:hAnsi="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/></w:pPr></w:pPrDefault></w:docDefaults>
XML

# Paragraph styles. Body text is double spaced (exact 552 twips = 27.6 pt); "Single" and "Centered" are the single-spaced
# blocks (court title, caption, signature). Headings: one blank double-spaced line above and below.
HEAD_RPR='<w:rPr><w:rFonts w:ascii="EB Garamond" w:eastAsia="EB Garamond" w:hAnsi="EB Garamond" w:cs="EB Garamond"/><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>'
cat > "$W/styles.xml" <<XML
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="552" w:after="552" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr>$HEAD_RPR</w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="552" w:after="552" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr>$HEAD_RPR</w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="552" w:after="552" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr>$HEAD_RPR</w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="HeadingContinued"><w:name w:val="Heading Continued"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="552" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr>$HEAD_RPR</w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleRight"><w:name w:val="Single Right"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="right"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleKeep"><w:name w:val="Single Keep"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Lettered"><w:name w:val="Lettered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:left="1440" w:hanging="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="table" w:default="1" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/><w:semiHidden/><w:unhideWhenUsed/><w:qFormat/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
XML

# Splice: replace the docDefaults and every style defined above, then the section (page size, margins, footer).
cat > "$W/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
cat > "$W/sect.xml" <<'XML'
<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="576" w:gutter="0"/></w:sectPr>
XML

cd "$W/pkg"
W="$W" perl -0pi -e '
  my $rd = sub { local $/; open my $f, "<", "$ENV{W}/$_[0]" or die "$_[0]: $!"; <$f> };
  my $defaults = $rd->("defaults.xml");
  my $styles = $rd->("styles.xml");
  s{<w:docDefaults>.*?</w:docDefaults>}{$defaults}s or die "no docDefaults";
  for my $id (qw(BodyText FirstParagraph Compact Heading1 Heading2 Heading3 Footer Table)) {
    s{<w:style [^>]*w:styleId="$id"[^>]*>.*?</w:style>}{}s;
  }
  s{</w:styles>}{$styles</w:styles>}s;
' word/styles.xml
W="$W" perl -0pi -e 'my $sect = do { local $/; open my $f, "<", "$ENV{W}/sect.xml" or die; <$f> }; chomp $sect; s{<w:sectPr>.*?</w:sectPr>}{$sect}s or die "no sectPr"' word/document.xml
cp "$W/footer1.xml" word/footer1.xml
perl -0pi -e 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>}' word/_rels/document.xml.rels
perl -0pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>}' '[Content_Types].xml'
for part in word/styles.xml word/document.xml word/footer1.xml; do xmllint --noout "$part"; done

rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" . -x '[Content_Types].xml'
echo "$OUT"
