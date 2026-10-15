#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference (docs/DOCX.md). NY Appellate Division,
# opening brief: EB Garamond 14 pt body (22 NYCRR 1250.8(f)(1)), double-spaced lines (Word "double"),
# first-line paragraph indent, single-spaced headings, block quotations, cover and counsel blocks;
# letter paper with 1 in margins; centered page number in the footer; footnote text 14 pt single-spaced.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl, xmllint on PATH)
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
export BODY=28 NOTE=28 FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>'
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
cd "$W/pkg" && unzip -q "$W/ref.docx"
cat > "$W/styles.pl" <<'PL'
# Replace (or add) the paragraph styles this court uses; theme fonts and colours go to the body font and black.
local $/; my $s = <STDIN>;
my $F = $ENV{FONT}; my $B = $ENV{BODY}; my $N = $ENV{NOTE};
$s =~ s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$F<w:sz w:val="$B"/><w:szCs w:val="$B"/><w:lang w:val="en-US"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s;
$s =~ s{<w:rFonts [^>]*Theme[^>]*/>}{$F}sg;
$s =~ s{<w:color [^>]*/>}{<w:color w:val="000000"/>}sg;
my %def = (
  Normal => qq{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/></w:pPr><w:rPr>$F<w:sz w:val="$B"/><w:szCs w:val="$B"/></w:rPr></w:style>},
  BodyText => qq{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="auto"/><w:ind w:firstLine="720"/></w:pPr></w:style>},
  FirstParagraph => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>},
  Compact => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>},
  Heading1 => qq{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr>$F<w:b/><w:bCs/><w:caps/><w:sz w:val="$B"/><w:szCs w:val="$B"/></w:rPr></w:style>},
  Heading2 => qq{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr>$F<w:b/><w:bCs/><w:sz w:val="$B"/><w:szCs w:val="$B"/></w:rPr></w:style>},
  Heading3 => qq{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="200" w:after="200" w:line="240" w:lineRule="auto"/><w:ind w:left="1440" w:hanging="720"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr>$F<w:b/><w:bCs/><w:sz w:val="$B"/><w:szCs w:val="$B"/></w:rPr></w:style>},
  Heading4 => qq{<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="200" w:after="200" w:line="240" w:lineRule="auto"/><w:ind w:left="2160" w:hanging="720"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr>$F<w:b/><w:bCs/><w:i/><w:iCs/><w:sz w:val="$B"/><w:szCs w:val="$B"/></w:rPr></w:style>},
  Heading5 => qq{<w:style w:type="paragraph" w:styleId="Heading5"><w:name w:val="heading 5"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="200" w:after="200" w:line="240" w:lineRule="auto"/><w:ind w:left="2880" w:hanging="720"/><w:outlineLvl w:val="4"/></w:pPr><w:rPr>$F<w:i/><w:iCs/><w:sz w:val="$B"/><w:szCs w:val="$B"/></w:rPr></w:style>},
  BlockText => qq{<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>},
  FootnoteText => qq{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>$F<w:sz w:val="$N"/><w:szCs w:val="$N"/></w:rPr></w:style>},
  Centered => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>},
  Single => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="200" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>},
  Right => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Right"><w:name w:val="Right"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:after="0"/><w:jc w:val="right"/></w:pPr></w:style>},
  Counsel => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Counsel"><w:name w:val="Counsel"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:after="0"/><w:ind w:left="4320"/></w:pPr></w:style>},
  Signature => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Signature"><w:name w:val="Signature"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:spacing w:after="0"/><w:ind w:left="4680"/></w:pPr></w:style>},
);
for my $id (sort keys %def) {
  if ($s =~ s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$def{$id}}s) { next }
  $s =~ s{</w:styles>}{$def{$id}</w:styles>}s;
}
print $s;
PL
perl "$W/styles.pl" < word/styles.xml > "$W/styles.new" && mv "$W/styles.new" word/styles.xml
# footer: centered PAGE field, 14 pt
cat > word/footer1.xml <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr>$FONT<w:sz w:val="$BODY"/><w:szCs w:val="$BODY"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr>$FONT<w:sz w:val="$BODY"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr>$FONT<w:sz w:val="$BODY"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr>$FONT<w:sz w:val="$BODY"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr>$FONT<w:sz w:val="$BODY"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'
# body section (the one pandoc copies): letter, 1 in margins, footer, page numbers from 1
export SECT='<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:fmt="decimal"/></w:sectPr>'
perl -0777 -e '$s=<STDIN>; $n = ($s =~ s{<w:sectPr\b.*?</w:sectPr>}{$ENV{SECT}}s); $s =~ s{</w:body>}{$ENV{SECT}</w:body>}s unless $n; print $s' < word/document.xml > "$W/doc.new" && mv "$W/doc.new" word/document.xml
for part in word/styles.xml word/document.xml word/footer1.xml '[Content_Types].xml' word/_rels/document.xml.rels; do xmllint --noout "$part"; done
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
