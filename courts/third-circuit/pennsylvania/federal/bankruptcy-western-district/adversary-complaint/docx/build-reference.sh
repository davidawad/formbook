#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference for the pawb adversary complaint (docs/DOCX.md).
# Form (from typst/pawb-adversary-complaint.typ): EB Garamond 13 pt; double spacing = exact 26 pt lines (the typst
# pitch: 0.65 em line box + 1.35 em leading); single spacing = exact 14.95 pt lines (1.15 em); 1 in margins on
# US Letter; first-line indent 0.5 in on body paragraphs; numbered paragraphs use a 1 in tab stop after "N.";
# headings: level 1 centered bold, level 2 centered bold, level 3 bold italic at the margin; footnotes 13 pt single;
# sequential page number centered in the footer.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, xmllint and ziptool (libzip) on PATH)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
ZT=ziptool
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

# --- zip helpers (ziptool: unzip = cat each entry, zip = add_file each entry) ---
unpack() { # <zip> <dir>
  n=$($ZT "$1" get_num_entries 0 | awk '{print $1}')
  i=0
  while [ "$i" -lt "$n" ]; do
    name=$($ZT "$1" stat "$i" | sed -n "s/^name: '\(.*\)'\$/\1/p")
    mkdir -p "$2/$(dirname "$name")"
    $ZT "$1" cat "$i" > "$2/$name"
    i=$((i + 1))
  done
}
pack() { # <dir> <zip>: [Content_Types].xml first
  rm -f "$2"
  (cd "$1" && $ZT -n "$2" add_file "[Content_Types].xml" "$1/[Content_Types].xml" 0 "$(wc -c < "[Content_Types].xml")")
  (cd "$1" && find . -type f | sed 's|^\./||' | grep -v -x '\[Content_Types\]\.xml' | sort) | while IFS= read -r name; do
    $ZT "$2" add_file "$name" "$1/$name" 0 "$(wc -c < "$1/$name")"
  done
}

pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
unpack "$W/ref.docx" "$W/pkg"
cd "$W/pkg"

# --- styles: replace the pandoc styles this form uses (ids), then append the custom ones ---
cat > "$W/new-styles.xml" <<'XML'
<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0"/></w:pPr></w:pPrDefault></w:docDefaults>
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="720"/><w:jc w:val="both"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="104" w:line="299" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr><w:rPr><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before="130" w:after="130" w:line="299" w:lineRule="exact"/><w:ind w:left="720" w:right="720" w:firstLine="0"/><w:jc w:val="both"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="299" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="299" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="299" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Address"><w:name w:val="Address"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="299" w:line="299" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
XML
NEW="$W/new-styles.xml" perl -0pi -e '
  open my $f, "<", $ENV{NEW} or die "new styles"; local $/; my $new = <$f>; close $f;
  my ($dd) = $new =~ m{(<w:docDefaults>.*?</w:docDefaults>)}s; $new =~ s{<w:docDefaults>.*?</w:docDefaults>\n}{}s;
  s{<w:docDefaults>.*?</w:docDefaults>}{$dd}s or die "no docDefaults";
  for my $id (qw(Normal BodyText FirstParagraph Compact Heading1 Heading2 Heading3 Heading4 FootnoteText BlockText Footer Centered Single Address)) {
    s{<w:style\b[^>]*?w:styleId="\Q$id\E"[^>]*>.*?</w:style>\s*}{}s;
  }
  s{</w:styles>}{$new</w:styles>}s;
' word/styles.xml
xmllint --noout word/styles.xml

# --- footer with the page number (PAGE field, cached result 1) ---
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

# --- body section: letter, 1 in margins, footer 0.5 in from the page edge (replaces pandoc's sectPr) ---
SECT='<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>'
SECT="$SECT" perl -0pi -e 'my $s = $ENV{SECT}; s{<w:sectPr\b.*?</w:sectPr>}{$s}s or s{</w:body>}{$s</w:body>}s or die "no body";' word/document.xml

for part in word/styles.xml word/document.xml word/footer1.xml '[Content_Types].xml' word/_rels/document.xml.rels; do xmllint --noout "$part"; done
pack "$W/pkg" "$OUT"
echo "$OUT"
