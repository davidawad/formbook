#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document, to the values of typst/ared-motion-brief.typ
# (see ../../README.md and docs/DOCX.md): EB Garamond 12 pt; body double-spaced (24 pt exact, the baseline pitch of
# the typst template) with a half-inch first-line indent; headings on the same 24 pt grid, level 1 centered bold
# capitals (numbers come from the filter), level 2 bold and level 3 bold italic with a hanging indent; list items
# double-spaced ("Compact"); table cells single-spaced 11 pt ("Table Text"); block quotes single-spaced, indented
# 1 inch each side; letter page with 1-inch margins; a centered page-number footer (11 pt).
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
cat > "$T/styles.pl" <<'PERL'
my $F = q{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />};
my $DBL = q{<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" />};
my %new = (
  Normal => qq{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr>$DBL</w:pPr><w:rPr>$F<w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>},
  BodyText => qq{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$DBL<w:ind w:firstLine="720" /></w:pPr></w:style>},
  FirstParagraph => qq{<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr>$DBL<w:ind w:firstLine="720" /></w:pPr></w:style>},
  Compact => qq{<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$DBL<w:ind w:firstLine="0" /></w:pPr></w:style>},
  BlockText => qq{<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto" /><w:ind w:left="1440" w:right="1440" w:firstLine="0" /><w:jc w:val="both" /></w:pPr></w:style>},
  Table => qq{<w:style w:type="table" w:default="1" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/><w:uiPriority w:val="59"/><w:tblPr><w:tblInd w:w="0" w:type="dxa" /><w:tblBorders><w:top w:val="single" w:sz="4" w:space="0" w:color="000000" /><w:left w:val="single" w:sz="4" w:space="0" w:color="000000" /><w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000" /><w:right w:val="single" w:sz="4" w:space="0" w:color="000000" /><w:insideH w:val="single" w:sz="4" w:space="0" w:color="000000" /><w:insideV w:val="single" w:sz="4" w:space="0" w:color="000000" /></w:tblBorders><w:tblCellMar><w:top w:w="0" w:type="dxa" /><w:left w:w="72" w:type="dxa" /><w:bottom w:w="0" w:type="dxa" /><w:right w:w="72" w:type="dxa" /></w:tblCellMar></w:tblPr></w:style>},
  TableText => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="TableText"><w:name w:val="Table Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr></w:style>},
  FootnoteText => qq{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /></w:pPr><w:rPr><w:sz w:val="20" /><w:szCs w:val="20" /></w:rPr></w:style>},
);
my @heads = (
  [ 'Heading1', 0, 'w:firstLine="0"', q{<w:jc w:val="center" />}, q{<w:caps />} ],
  [ 'Heading2', 1, 'w:left="720" w:hanging="720"', q{}, q{} ],
  [ 'Heading3', 2, 'w:left="720" w:hanging="720"', q{}, q{<w:i />} ],
);
for my $h (@heads) {
  my ($id, $lvl, $ind, $jc, $extra) = @$h;
  my $ital = $extra =~ /<w:i \/>/ ? q{<w:i />} : q{};
  my $caps = $extra =~ /caps/ ? q{<w:caps />} : q{};
  $new{$id} = qq{<w:style w:type="paragraph" w:styleId="$id"><w:name w:val="heading $lvl+1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext /><w:keepLines />$DBL<w:ind $ind />$jc<w:outlineLvl w:val="$lvl" /></w:pPr><w:rPr>$F<w:b /><w:bCs />$caps$ital<w:color w:val="000000" /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr></w:style>};
}
for my $id (sort keys %new) {
  # A style pandoc does not define is added before the end of the style list.
  s{<w:style [^>]*w:styleId="\Q$id\E".*?</w:style>}{$new{$id}}s or s{</w:styles>}{$new{$id}</w:styles>}s or die "styles.xml: no style $id\n";
}
s{<w:rFonts w:asciiTheme="minorHAnsi".*?/>}{$F}s or die "styles.xml: no minorHAnsi font in docDefaults\n";
PERL
perl -0777 -pi -e "$(cat "$T/styles.pl")" "$W/word/styles.xml"
perl -0pi -e '
  s{(<w:sectPr>)}{$1<w:footerReference w:type="default" r:id="rIdFooter1" />}s;
  s{(<w:footnotePr>\s*<w:numRestart w:val="eachSect" />\s*</w:footnotePr>)}{$1<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="432" w:gutter="0" />}s;
' "$W/word/document.xml"
cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center" /></w:pPr><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
