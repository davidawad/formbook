#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference (innb DOCX engine; see ../README.md, "Engines").
# Matches innb-adversary-complaint.typ: EB Garamond 13 pt, exact 24 pt (double) line pitch, 0.5 in first-line
# indent, single-spaced caption/signature/footnote styles, letter paper with 1 in margins, centred page number
# (11 pt) in the footer. Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl, xmllint)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q "$W/ref.docx"

# styles.xml: replace the style definitions the filter uses, add the custom ones, set the document defaults.
cat > "$W/styles.pl" <<'PL'
local $/; my $s = <STDIN>;
my $font = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
my $ink = '<w:color w:val="000000"/><w:sz w:val="26"/><w:szCs w:val="26"/>';
my %new = (
  BodyText => '<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/><w:jc w:val="left"/></w:pPr><w:rPr>' . $font . $ink . '</w:rPr></w:style>',
  Heading1 => '<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr>' . $font . '<w:b/><w:bCs/><w:caps/>' . $ink . '</w:rPr></w:style>',
  Heading2 => '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr>' . $font . '<w:b/><w:bCs/>' . $ink . '</w:rPr></w:style>',
  BlockText => '<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr>' . $font . $ink . '</w:rPr></w:style>',
  FootnoteText => '<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="Footnote Text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="80" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr>' . $font . $ink . '</w:rPr></w:style>',
);
for my $id (sort keys %new) {
  my $n = ($s =~ s{<w:style [^>]*w:styleId="\Q$id\E">.*?</w:style>}{$new{$id}}s);
  die "build-reference: style $id not found in pandoc's reference.docx\n" unless $n;
}
my $custom = join '', map { '<w:style w:type="paragraph" w:customStyle="1" w:styleId="' . $_->[0] . '"><w:name w:val="' . $_->[0] . '"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>' . $_->[1] . '</w:pPr><w:rPr>' . $font . $ink . '</w:rPr></w:style>' } (
  # Centered: cover, court title, title block, debtor/party labels (single spaced, centred)
  [ 'Centered', '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/>' ],
  # Single: caption, counsel and signature lines (single spaced, left)
  [ 'Single', '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/>' ],
  # Spacer: one blank double-spaced line (24 pt), and HalfSpacer: half of it (12 pt)
  [ 'Spacer', '<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/>' ],
  [ 'HalfSpacer', '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/>' ],
);
$s =~ s{</w:styles>}{$custom</w:styles>} or die "build-reference: no </w:styles>\n";
# document defaults: the named font (no theme font), 13 pt, no space after
$s =~ s{(<w:docDefaults>.*?</w:docDefaults>)}{
  my $d = $1;
  $d =~ s{<w:rFonts [^>]*/>}{$font};
  $d =~ s{<w:sz w:val="24"/>}{<w:sz w:val="26"/>};
  $d =~ s{<w:szCs w:val="24"/>}{<w:szCs w:val="26"/>};
  $d =~ s{<w:spacing w:after="200"/>}{<w:spacing w:after="0" w:line="240" w:lineRule="auto"/>};
  $d }se or die "build-reference: no docDefaults\n";
print $s;
PL
perl "$W/styles.pl" < word/styles.xml > "$W/styles.new" && mv "$W/styles.new" word/styles.xml

# footer: the page number (PAGE field, cached result 1), centred, 11 pt
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
grep -q 'Id="rId900"' word/_rels/document.xml.rels && { echo "build-reference: rId900 already used" >&2; exit 1; }
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId900" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

# body section: letter, 1 in margins, the page-number footer (replaces pandoc's empty sectPr)
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId900"/><w:footnotePr><w:numRestart w:val="continuous"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>}s' word/document.xml
grep -q 'rId900' word/document.xml || { echo "build-reference: sectPr not replaced" >&2; exit 1; }

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
