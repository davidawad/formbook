#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference, restyled to match typst/njd-complaint.typ:
# EB Garamond 12 pt, exact 27.6 pt (double) line spacing, 0.5 in first-line indent, letter page with
# 1 in margins, centered page number in the footer, single-spaced front matter styles ("Single",
# "Centered", "Gap"). Uses only pandoc, perl, ziptool and xmllint (no unzip or zip on this box).
# Usage: sh docx/build-reference.sh <out.docx>
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
PKG=$W/pkg
mkdir -p "$PKG"

# unpack <archive> <dir>: every entry of the zip, by index (ziptool has no extract command)
unpack() {
  n=$(ziptool "$1" get_num_entries 0 | awk '{print $1}')
  i=0
  while [ "$i" -lt "$n" ]; do
    name=$(ziptool "$1" stat "$i" | sed -n "s/^name: '\(.*\)'$/\1/p")
    case $name in
      */) mkdir -p "$2/$name" ;;
      *) mkdir -p "$2/$(dirname "$name")"; ziptool "$1" cat "$i" > "$2/$name" ;;
    esac
    i=$((i + 1))
  done
}

# pack <dir> <archive>: every file under dir, [Content_Types].xml first
pack() {
  rm -f "$2"
  (cd "$1" && find . -type f | sed 's|^\./||' | sort) | while IFS= read -r f; do
    ziptool -n "$2" add_file "$f" "$1/$f" 0 0 > /dev/null
  done
}

# setstyle <styleId> <xml>: replace the whole w:style element (or append it when absent)
STY=$PKG/word/styles.xml
setstyle() {
  ID=$1 NEW=$2 perl -0777 -i -pe 'BEGIN { $id = $ENV{ID}; $new = $ENV{NEW} }
    if (!s{<w:style [^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$new}s) { s{</w:styles>}{$new\n</w:styles>} }' "$STY"
}

pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
unpack "$W/ref.docx" "$PKG"

# document defaults: EB Garamond 12 pt, single line spacing, no space after
ID=docDefaults perl -0777 -i -pe 's{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s' "$STY"

# body text: double spaced (exact 27.6 pt = 552 twips), first-line indent 0.5 in (720 twips)
setstyle Normal '<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>'
setstyle BodyText '<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>'
setstyle FirstParagraph '<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/></w:pPr></w:style>'
setstyle Compact '<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>'

# headings: centered bold, single-line, double pitch; H1 in capitals (the typst heading show rule)
setstyle Heading1 '<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="414" w:after="138" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:caps/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>'
setstyle Heading2 '<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="414" w:after="138" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>'
setstyle Heading3 '<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="414" w:after="138" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>'

# block quotations: single spaced, indented both sides (not used by this complaint; kept for the markdown contract)
setstyle BlockText '<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>'
# footnotes: 12 pt (the body size), single spaced
setstyle FootnoteText '<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="100" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>'

# custom styles for the cover, the caption, the signature blocks and the certification
setstyle Single '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>'
setstyle Centered '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr></w:style>'
setstyle Gap '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Gap"><w:name w:val="Gap"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>'
setstyle CertTitle '<w:style w:type="paragraph" w:customStyle="1" w:styleId="CertTitle"><w:name w:val="Certification Title"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:pageBreakBefore/><w:spacing w:before="0" w:after="276" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>'
setstyle Half '<w:style w:type="paragraph" w:customStyle="1" w:styleId="Half"><w:name w:val="Half"/><w:basedOn w:val="Normal"/><w:pPr><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>'
setstyle Footer '<w:style w:type="paragraph" w:styleId="Footer"><w:name w:val="footer"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr></w:style>'

# footer with the page number (PAGE field; the cached result is 1, Word and LibreOffice update it)
cat > "$PKG/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:pStyle w:val="Footer"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0777 -i -pe 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>}' "$PKG/word/_rels/document.xml.rels"
perl -0777 -i -pe 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>}' "$PKG/[Content_Types].xml"

# final section: letter, 1 in margins, the page-number footer (pandoc keeps this sectPr for the document)
perl -0777 -i -pe 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>}s' "$PKG/word/document.xml"

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels "[Content_Types].xml"; do
  xmllint --noout "$PKG/$part"
done
pack "$PKG" "$W/reference.docx"
mv "$W/reference.docx" "$OUT"
echo "$OUT"
