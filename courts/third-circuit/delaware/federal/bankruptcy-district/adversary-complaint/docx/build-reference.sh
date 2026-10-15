#!/bin/sh
# Builds docx/reference.docx for the D. Del. Bankruptcy adversary complaint (typst: deb-adversary-complaint.typ).
# Starts from pandoc's default reference.docx and sets: EB Garamond 12 pt (the typst face; no face is named
# for pleadings, see ../README.md), double spacing (Word "double": line 480 auto), first-line indent 0.5 in on
# body text, 1 in margins on letter paper, page number centered in the footer, black bold headings, footnotes
# 10 pt single spaced, and the "Centered" and "Single" paragraph styles that the Lua filter (deb.lua) uses for the
# caption, the signature block and the centered lines.
# Usage: sh docx/build-reference.sh <out.docx>      (needs pandoc, unzip, zip, perl, xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
FONT="EB Garamond"
FOOTNOTE_SZ=20        # half-points: 10 pt
H3_CAPS=0             # level 3 headings (COUNT I) are centered, not capitalized, in the typst template
export FONT FOOTNOTE_SZ H3_CAPS
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
cd "$W" && mkdir pkg && cd pkg && unzip -q ../ref.docx

perl -0777 -i -pe '
  my $f = $ENV{FONT}; my $fn = $ENV{FOOTNOTE_SZ}; my $caps = $ENV{H3_CAPS} ? "<w:caps/>" : "";
  my $rf = qq{<w:rFonts w:ascii="$f" w:hAnsi="$f" w:eastAsia="$f" w:cs="$f"/>};
  my $sp = qq{<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="auto"/>};
  my $single = qq{<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>};
  my $body = qq{<w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr><w:widowControl/>$sp<w:ind w:firstLine="720"/></w:pPr>};
  my %rep = (
    "docDefaults" => qq{<w:docDefaults><w:rPrDefault><w:rPr>$rf<w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr>$sp</w:pPr></w:pPrDefault></w:docDefaults>},
  );
  s{<w:docDefaults>.*?</w:docDefaults>}{$rep{docDefaults}}s;
  my %style = (
    BodyText => qq{<w:style w:type="paragraph" w:styleId="BodyText">$body</w:style>},
    Heading1 => qq{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading1Char"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$sp<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr>$rf<w:b/><w:bCs/><w:caps/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>},
    Heading2 => qq{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading2Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$sp<w:ind w:left="720" w:hanging="720" w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr>$rf<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>},
    Heading3 => qq{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading3Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$sp<w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr>$rf<w:b/><w:bCs/>$caps<w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>},
    BlockText => qq{<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>},
    FootnoteText => qq{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:link w:val="FootnoteTextChar"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="$fn"/><w:szCs w:val="$fn"/></w:rPr></w:style>},
  );
  for my $id (keys %style) {
    s{<w:style [^>]*w:styleId="$id".*?</w:style>}{$style{$id}}s or die "style $id not found\n";
  }
  my $cstyle = qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$single<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>};
  my $cbody = qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CenteredBody"><w:name w:val="Centered Body"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$sp<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>};
  my $sstyle = qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$single<w:ind w:firstLine="0"/></w:pPr></w:style>};
  s{</w:styles>}{$cstyle$cbody$sstyle</w:styles>}s;
' word/styles.xml

# body section: letter, 1 in margins, page-number footer (footnotePr of pandoc kept)
perl -0777 -i -pe 's{<w:sectPr>(.*?)</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/>$1<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>}s or die "no sectPr\n"' word/document.xml

cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
