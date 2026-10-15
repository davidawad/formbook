#!/bin/sh
# Builds docx/reference.docx for the W.D. Wis. motion brief (DOCX engine; docs/DOCX.md; README.md "Engines").
# Starts from pandoc's default reference.docx and replaces the styles the sample uses, to match
# typst/wiwd-complaint.typ: EB Garamond 12 pt (vendored in fonts/eb-garamond), exact 24 pt line pitch
# (the typst "double" leading; the brief body), first-line indent 0.5 in, US Letter with 1 in margins, a footer page number
# at 11 pt with a cached PAGE result.
# Usage: sh docx/build-reference.sh <out.docx>
# Needs pandoc and libzip's ziptool (or set ZIPTOOL=/path/to/ziptool). Needs no zip or unzip.
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
ZT=${ZIPTOOL:-ziptool}
command -v pandoc > /dev/null 2>&1 || { echo "build-reference.sh: pandoc not found" >&2; exit 1; }
command -v "$ZT" > /dev/null 2>&1 || { echo "build-reference.sh: $ZT not found" >&2; exit 1; }
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
R=$W/ref.docx

# package access through ziptool: part_idx <name>, part_get <name> <file>, part_put <name> <file>
part_idx() { "$ZT" "$R" name_locate "$1" 0 | awk '{print $NF}'; }
part_get() { "$ZT" "$R" cat "$(part_idx "$1")" > "$2"; }
part_put() { "$ZT" "$R" replace_file_contents "$(part_idx "$1")" "$(cat "$2")"; }

part_get word/styles.xml "$W/styles.xml"
part_get word/document.xml "$W/document.xml"
part_get word/_rels/document.xml.rels "$W/rels.xml"
part_get '[Content_Types].xml' "$W/ct.xml"

FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>'

# document defaults: EB Garamond 12 pt, single spacing unless a style says otherwise
cat > "$W/docdefaults.xml" <<XML
<w:docDefaults><w:rPrDefault><w:rPr>$FONT<w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>
XML

# the styles the sample uses; each replaces pandoc's style of the same styleId
cat > "$W/styles-new.xml" <<XML
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr>$FONT<w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="22"/><w:szCs w:val="22"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Signature"><w:name w:val="Signature"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="3960" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Lettered"><w:name w:val="Lettered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/><w:ind w:left="1296" w:hanging="576"/><w:jc w:val="left"/></w:pPr></w:style>
XML

# splice: drop the old styles, put the new ones and the defaults in place
NEW="$W/styles-new.xml" DD="$W/docdefaults.xml" perl -0pi -e '
  my $slurp = sub { open my $f, "<", $_[0] or die "$_[0]: $!"; local $/; <$f> };
  my $new = $slurp->($ENV{NEW});
  my $dd = $slurp->($ENV{DD});
  for my $id (qw(Normal BodyText FirstParagraph Compact Heading1 Heading2 Heading3 FootnoteText Footer Centered Single Lettered)) {
    s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{}s;
  }
  s{<w:docDefaults>.*?</w:docDefaults>}{$dd}s or die "no docDefaults in styles.xml";
  s{</w:styles>}{$new</w:styles>}s or die "no </w:styles>";
' "$W/styles.xml"

# footer: centered PAGE field, cached result 1
cat > "$W/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML

# body section: US Letter, 1 in margins, the footer
perl -0pi -e 's{<w:sectPr\b.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>}s or die "no sectPr"' "$W/document.xml"
perl -0pi -e 's{</Relationships>}{<Relationship Id="rId100" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/></Relationships>}' "$W/rels.xml"
perl -0pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}' "$W/ct.xml"

if command -v xmllint > /dev/null 2>&1; then
  for part in "$W/styles.xml" "$W/document.xml" "$W/rels.xml" "$W/ct.xml" "$W/footer1.xml"; do
    xmllint --noout "$part"
  done
fi

part_put word/styles.xml "$W/styles.xml"
part_put word/document.xml "$W/document.xml"
part_put word/_rels/document.xml.rels "$W/rels.xml"
part_put '[Content_Types].xml' "$W/ct.xml"
"$ZT" "$R" add word/footer1.xml "$(cat "$W/footer1.xml")"

rm -f "$OUT"
cp "$R" "$OUT"
echo "$OUT"
