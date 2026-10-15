#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference.docx for the S.D. Ind. bankruptcy adversary
# complaint. Matches typst/insb-adversary-complaint.typ (see ../README.md, "Engines"):
# EB Garamond 12 pt, exact 27.6 pt (double) line spacing, 0.5 in first-line indent, letter page with
# 1 in margins, centered page number in the footer, single-spaced caption and signature styles.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, perl, unzip, zip, xmllint on PATH)
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
cd "$W" && mkdir pkg && cd pkg && unzip -q ../ref.docx

# styles.xml: replace the defaults and the styles the body uses, add the front-matter styles.
cat > "$W/styles.pl" <<'PERL'
undef $/;
my $s = <STDIN>;
my $font = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
my $defaults = '<w:docDefaults><w:rPrDefault><w:rPr>' . $font
  . '<w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault>'
  . '<w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>';
$s =~ s{<w:docDefaults>.*?</w:docDefaults>}{$defaults}s or die "no docDefaults\n";
my @replace = qw(BodyText Heading1 Heading2 BlockText FootnoteText);
foreach my $id (@replace) {
  $s =~ s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{}s or die "no style $id\n";
}
my $new = join '', map { "<w:style $_</w:style>" } (
  # body: exact double spacing, first-line indent (typst: body-leading, para-indent)
  'w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/>'
    . '<w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr>'
    . '<w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>',
  # headings: bold, black, double spaced; level 1 centered and capitals (typst: upper + centered)
  'w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading1Char"/><w:uiPriority w:val="9"/><w:qFormat/>'
    . '<w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="276" w:after="276" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr>'
    . "<w:rPr>$font<w:b/><w:bCs/><w:caps/><w:color w:val=\"000000\"/><w:sz w:val=\"24\"/><w:szCs w:val=\"24\"/></w:rPr>",
  'w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading2Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/>'
    . '<w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="276" w:after="276" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr>'
    . "<w:rPr>$font<w:b/><w:bCs/><w:color w:val=\"000000\"/><w:sz w:val=\"24\"/><w:szCs w:val=\"24\"/></w:rPr>",
  # block quotation: single spaced, indented 1 in left and 0.5 in right, no first-line indent (typst: pad)
  'w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/>'
    . '<w:pPr><w:spacing w:before="0" w:after="276" w:line="240" w:lineRule="auto"/><w:ind w:left="1440" w:right="720" w:firstLine="0"/></w:pPr>',
  # footnote text: single spaced, 12 pt
  'w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text"/><w:basedOn w:val="Normal"/><w:next w:val="FootnoteText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/>'
    . '<w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>',
  # front matter (custom styles, used by docx/insb.lua)
  'w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/>'
    . '<w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr>',
  'w:type="paragraph" w:customStyle="1" w:styleId="CenteredBody"><w:name w:val="Centered Body"/><w:basedOn w:val="BodyText"/><w:qFormat/>'
    . '<w:pPr><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr>',
  'w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/>'
    . '<w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr>',
  'w:type="paragraph" w:customStyle="1" w:styleId="SignatureBlock"><w:name w:val="Signature Block"/><w:basedOn w:val="Single"/><w:qFormat/>'
    . '<w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:left="4320" w:firstLine="0"/></w:pPr>',
  'w:type="paragraph" w:customStyle="1" w:styleId="Lettered"><w:name w:val="Lettered"/><w:basedOn w:val="BodyText"/><w:qFormat/>'
    . '<w:pPr><w:tabs><w:tab w:val="left" w:pos="1584"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:left="1584" w:hanging="864"/></w:pPr>',
  'w:type="paragraph" w:customStyle="1" w:styleId="Allegation"><w:name w:val="Allegation"/><w:basedOn w:val="BodyText"/><w:qFormat/>'
    . '<w:pPr><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr>',
  'w:type="paragraph" w:customStyle="1" w:styleId="Continuation"><w:name w:val="Continuation"/><w:basedOn w:val="BodyText"/><w:qFormat/>'
    . '<w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/></w:pPr>',
  'w:type="paragraph" w:customStyle="1" w:styleId="Gap"><w:name w:val="Gap"/><w:basedOn w:val="Normal"/><w:qFormat/>'
    . '<w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr>',
  'w:type="paragraph" w:customStyle="1" w:styleId="HalfGap"><w:name w:val="Half Gap"/><w:basedOn w:val="Normal"/><w:qFormat/>'
    . '<w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr>',
  'w:type="paragraph" w:customStyle="1" w:styleId="NewPageTitle"><w:name w:val="New Page Title"/><w:basedOn w:val="Heading1"/><w:next w:val="BodyText"/><w:qFormat/>'
    . '<w:pPr><w:pageBreakBefore/><w:spacing w:before="0" w:after="276" w:line="552" w:lineRule="exact"/><w:jc w:val="center"/></w:pPr>',
);
$s =~ s{</w:styles>}{$new</w:styles>}s;
print $s;
PERL
perl "$W/styles.pl" < word/styles.xml > "$W/styles.new" && mv "$W/styles.new" word/styles.xml

# footer with the page number (PAGE field, cached result 1), centered, 12 pt
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

# body section (the one sectPr pandoc takes from the reference): letter, 1 in margins, the footer
cat > "$W/sect.pl" <<'PERL'
undef $/;
my $s = <STDIN>;
my $sect = '<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1"/>'
  . '<w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr>'
  . '<w:pgSz w:w="12240" w:h="15840"/>'
  . '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>';
my $n = () = $s =~ /<w:sectPr>/g;
die "expected one body sectPr, found $n\n" unless $n == 1;
$s =~ s{<w:sectPr>.*?</w:sectPr>}{$sect}s;
print $s;
PERL
perl "$W/sect.pl" < word/document.xml > "$W/document.new" && mv "$W/document.new" word/document.xml

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
