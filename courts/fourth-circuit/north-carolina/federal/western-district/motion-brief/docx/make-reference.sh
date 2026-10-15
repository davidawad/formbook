#!/bin/sh
# Builds docx/reference.docx for the ncwd memorandum (motion-brief) from pandoc's default reference document (docs/DOCX.md).
# Form (the typst template, ncwd-motion-brief.typ, and LCvR 7.1(d)): EB Garamond 12 pt; body double-spaced at a
# 27.6 pt exact pitch with a half-inch first-line indent; single lines at 13.8 pt exact; headings single-spaced
# with the typst template's block spacing (14.5 pt argument headings, 17 pt section headings); US Letter, one-inch margins; a centered PAGE field in the footer.
# Styles are replaced by styleId from the snippets below; custom styles used by motion-brief.lua are appended.
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
mkdir "$W" "$T/s"
cp -R "$T/x/." "$W/"
L=4320   # signature indent: 3.0 in (the typst template's pad)

cat > "$T/s/docDefaults.xml" <<'XML'
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:eastAsia="EB Garamond" w:hAnsi="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/></w:pPr></w:pPrDefault></w:docDefaults>
XML
cat > "$T/s/Normal.xml" <<'XML'
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
XML
cat > "$T/s/BodyText.xml" <<'XML'
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
XML
cat > "$T/s/Compact.xml" <<'XML'
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
XML
cat > "$T/s/Heading1.xml" <<'XML'
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading1Char"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="304" w:after="194" w:line="360" w:lineRule="exact"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:color w:val="000000"/><w:sz w:val="34"/><w:szCs w:val="34"/></w:rPr></w:style>
XML
cat > "$T/s/Heading2.xml" <<'XML'
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading2Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="304" w:after="194" w:line="330" w:lineRule="exact"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="29"/><w:szCs w:val="29"/></w:rPr></w:style>
XML
cat > "$T/s/Heading3.xml" <<'XML'
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading3Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="304" w:after="194" w:line="276" w:lineRule="exact"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
XML
cat > "$T/s/FootnoteText.xml" <<'XML'
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
XML
cat > "$T/s/Table.xml" <<'XML'
<w:style w:type="table" w:default="1" w:styleId="Table"><w:name w:val="Table"/><w:basedOn w:val="TableNormal"/><w:uiPriority w:val="99"/><w:tblPr><w:tblInd w:w="0" w:type="dxa"/><w:tblBorders><w:top w:val="nil"/><w:left w:val="nil"/><w:bottom w:val="nil"/><w:right w:val="nil"/><w:insideH w:val="nil"/><w:insideV w:val="nil"/></w:tblBorders><w:tblCellMar><w:top w:w="0" w:type="dxa"/><w:left w:w="0" w:type="dxa"/><w:bottom w:w="0" w:type="dxa"/><w:right w:w="0" w:type="dxa"/></w:tblCellMar></w:tblPr></w:style>
XML
# custom styles used by motion-brief.lua (the name, with spaces removed, is the styleId)
cat > "$T/s/CourtTitle.xml" <<'XML'
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitle"><w:name w:val="Court Title"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
XML
cat > "$T/s/CourtTitleEnd.xml" <<'XML'
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtTitleEnd"><w:name w:val="Court Title End"/><w:basedOn w:val="CourtTitle"/><w:qFormat/><w:pPr><w:spacing w:after="216"/></w:pPr></w:style>
XML
cat > "$T/s/CaptionLine.xml" <<'XML'
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionLine"><w:name w:val="Caption Line"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:right="144"/></w:pPr></w:style>
XML
cat > "$T/s/CaptionMark.xml" <<'XML'
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionMark"><w:name w:val="Caption Mark"/><w:basedOn w:val="CaptionLine"/><w:qFormat/></w:style>
XML
cat > "$T/s/CaptionRight.xml" <<'XML'
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionRight"><w:name w:val="Caption Right"/><w:basedOn w:val="CaptionLine"/><w:qFormat/><w:pPr><w:ind w:left="288"/></w:pPr></w:style>
XML
cat > "$T/s/CaptionRightGap.xml" <<'XML'
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionRightGap"><w:name w:val="Caption Right Gap"/><w:basedOn w:val="CaptionRight"/><w:qFormat/><w:pPr><w:spacing w:before="360"/></w:pPr></w:style>
XML
cat > "$T/s/LeadIn.xml" <<'XML'
<w:style w:type="paragraph" w:customStyle="1" w:styleId="LeadIn"><w:name w:val="Lead In"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="480"/></w:pPr></w:style>
XML
cat > "$T/s/BodyFlush.xml" <<'XML'
<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyFlush"><w:name w:val="Body Flush"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>
XML
cat > "$T/s/CounselGap.xml" <<XML
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CounselGap"><w:name w:val="Counsel Gap"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="480"/></w:pPr></w:style>
XML
cat > "$T/s/CounselLine.xml" <<'XML'
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CounselLine"><w:name w:val="Counsel Line"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>
XML
cat > "$T/s/CounselEnd.xml" <<'XML'
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CounselEnd"><w:name w:val="Counsel End"/><w:basedOn w:val="Normal"/><w:qFormat/></w:style>
XML
cat > "$T/s/ListItem.xml" <<'XML'
<w:style w:type="paragraph" w:customStyle="1" w:styleId="ListItem"><w:name w:val="List Item"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:left="1512" w:firstLine="-792"/></w:pPr></w:style>
XML
cat > "$T/s/SigDate.xml" <<'XML'
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigDate"><w:name w:val="Sig Date"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="480"/></w:pPr></w:style>
XML
cat > "$T/s/SigGap.xml" <<XML
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigGap"><w:name w:val="Sig Gap"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="480"/><w:ind w:left="$L"/></w:pPr></w:style>
XML
cat > "$T/s/SigLine.xml" <<XML
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigLine"><w:name w:val="Sig Line"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:ind w:left="$L"/></w:pPr></w:style>
XML
cat > "$T/s/SigEnd.xml" <<XML
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigEnd"><w:name w:val="Sig End"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:left="$L"/></w:pPr></w:style>
XML

# Replace each style by styleId (or append it), docDefaults by its element.
cat > "$T/setstyles.pl" <<'PL'
my ($file, @snips) = @ARGV;
local $/;
open my $fh, '<', $file or die "open $file: $!";
my $x = <$fh>;
close $fh;
for my $s (@snips) {
  (my $id = $s) =~ s{.*/}{};
  $id =~ s{\.xml$}{};
  open my $sh, '<', $s or die "open $s: $!";
  my $new = <$sh>;
  close $sh;
  $new =~ s{\s+\z}{};
  if ($id eq 'docDefaults') {
    $x =~ s{<w:docDefaults>.*?</w:docDefaults>}{$new}s or die "no docDefaults";
    next;
  }
  next if $x =~ s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$new}s;
  $x =~ s{</w:styles>}{$new\n</w:styles>}s or die "no </w:styles>";
}
open my $o, '>', $file or die "write $file: $!";
print $o $x;
close $o;
PL
perl "$T/setstyles.pl" "$W/word/styles.xml" "$T"/s/*.xml

# Section: US Letter, one-inch margins, footer with the page number (document.xml), as make-reference does for ca9.
perl -0pi -e '
  s{(<w:sectPr>)}{$1<w:footerReference w:type="default" r:id="rIdFooter1" />}s;
  s{(<w:footnotePr>\s*<w:numRestart w:val="eachSect" />\s*</w:footnotePr>)}{$1<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />}s;
' "$W/word/document.xml"
cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center" /></w:pPr><w:r><w:rPr><w:sz w:val="24" /></w:rPr><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:rPr><w:sz w:val="24" /></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="24" /></w:rPr><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:rPr><w:sz w:val="24" /></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="24" /></w:rPr><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
