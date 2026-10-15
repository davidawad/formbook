#!/bin/sh
# Builds docx/reference.docx for the N.D. Ill. complaint from pandoc's default reference.docx.
# Follows typst/ilnd-complaint.typ: EB Garamond 12 pt; body lines exact 27.6 pt (552 twips, the double pitch of
# the template); first-line indent 0.5 in, justified; front matter and signature lines single (exact 13.8 pt,
# 276 twips); headings single with one double line above and below; footnotes 11 pt single; US Letter with
# 1 in margins; the page number centered in the footer.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl and xmllint on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc --print-default-data-file reference.docx > "$W/ref.docx"
mkdir "$W/pkg"
cd "$W/pkg"
unzip -q ../ref.docx

# style definitions, one per line: styleId|<w:style ...>...</w:style> (replaces the style, or appends it)
cat > "$W/styles.txt" <<'STY'
docDefaults|<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
BodyText|<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/><w:jc w:val="both"/></w:pPr></w:style>
Heading1|<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading1Char"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="552" w:after="552" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
Heading2|<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading2Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="552" w:after="552" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
Heading3|<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading3Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="552" w:after="552" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
FootnoteText|<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="both"/></w:pPr><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
Centered|<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
Single|<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
HangingItem|<w:style w:type="paragraph" w:customStyle="1" w:styleId="HangingItem"><w:name w:val="Hanging Item"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:left="1440" w:hanging="720"/><w:jc w:val="both"/></w:pPr></w:style>
KeepWithNext|<w:style w:type="paragraph" w:customStyle="1" w:styleId="KeepWithNext"><w:name w:val="Keep With Next"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr></w:style>
Footer|<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
STY

cat > "$W/merge.pl" <<'PL'
# usage: perl merge.pl styles.txt word/styles.xml
my ($list, $file) = @ARGV;
open my $fh, '<', $list or die "merge.pl: $list\n";
my (%new, @order);
while (my $line = <$fh>) {
  chomp $line;
  next unless length $line;
  my ($id, $xml) = split /\|/, $line, 2;
  $new{$id} = $xml;
  push @order, $id;
}
close $fh;
local $/;
open my $in, '<', $file or die "merge.pl: $file\n";
my $s = <$in>;
close $in;
my @append;
for my $id (@order) {
  my $x = $new{$id};
  if ($id eq 'docDefaults') {
    $s =~ s{<w:docDefaults>.*?</w:docDefaults>}{$x}s or die "merge.pl: no docDefaults\n";
    next;
  }
  next if $s =~ s{<w:style\b[^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$x}s;
  push @append, $x;
}
$s =~ s{</w:styles>}{join('', @append) . '</w:styles>'}e;
open my $out, '>', $file or die "merge.pl: $file\n";
print $out $s;
close $out;
PL
perl "$W/merge.pl" "$W/styles.txt" word/styles.xml

# body section: US Letter, 1 in margins, the page-number footer (rId900), numbering from 1
SECT='<w:sectPr><w:footerReference w:type="default" r:id="rId900"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:start="1"/></w:sectPr>' \
  perl -0777 -pi -e 's{<w:sectPr>.*?</w:sectPr>}{$ENV{SECT}}s' word/document.xml

# footer with the page number (PAGE field, cached result 1)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId900" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'
for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done

case $OUT in /*) ;; *) OUT=$(pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
