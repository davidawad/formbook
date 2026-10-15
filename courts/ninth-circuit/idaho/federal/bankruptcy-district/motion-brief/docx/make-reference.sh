#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference, to the typst form of this doc type
# (typst/idb-motion-brief.typ): EB Garamond 13 point, double-spaced body with 0.6 em (156 twips) after,
# single-spaced headings, centered bold headings (level 1 and 2) and a left bold level 3, US Letter with
# 1 inch margins, footer page number centered at 11 point. Set in styles.xml, sectPr and footer1.xml; not rendered here.
# Run once (needs pandoc, unzip, sed, zip); the result is committed.
# Usage: sh docx/make-reference.sh   (from anywhere; all OOXML work happens in a fresh temp dir)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$W"
pandoc -o ref0.docx --print-default-data-file reference.docx
unzip -q ref0.docx -d x
S=x/word/styles.xml
DOC=x/word/document.xml

# styles.xml: one element per line in pandoc's output, so ranges per styleId are safe.
cat > "$W/styles.sed" <<'SED'
/<w:docDefaults>/,/<\/w:docDefaults>/{
s#<w:rFonts [^>]*/>#<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />#
s#<w:sz w:val="[0-9]*" />#<w:sz w:val="26" />#
s#<w:szCs w:val="[0-9]*" />#<w:szCs w:val="26" />#
s#<w:spacing [^>]*/>#<w:spacing w:before="0" w:after="156" w:line="480" w:lineRule="auto" />#
}
/w:styleId="BodyText"/,/<\/w:style>/{
s#<w:spacing [^>]*/>#<w:spacing w:before="0" w:after="156" w:line="480" w:lineRule="auto" />#
}
/w:styleId="Compact"/,/<\/w:style>/{
s#<w:spacing [^>]*/>#<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="auto" />#
}
/w:styleId="BlockText"/,/<\/w:style>/{
s#<w:spacing [^>]*/>#<w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto" />#
s#<w:ind [^>]*/>#<w:ind w:firstLine="0" w:left="1080" w:right="720" />#
}
/w:styleId="Heading1"/,/<\/w:style>/{
/<w:rPr>/,/<\/w:rPr>/d
s#<w:spacing [^>]*/>#<w:spacing w:before="312" w:after="156" w:line="240" w:lineRule="auto" />#
s#<w:outlineLvl#<w:jc w:val="center" /><w:outlineLvl#
s#</w:pPr>#</w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:b /><w:color w:val="000000" /><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr>#
}
/w:styleId="Heading2"/,/<\/w:style>/{
/<w:rPr>/,/<\/w:rPr>/d
s#<w:spacing [^>]*/>#<w:spacing w:before="234" w:after="156" w:line="240" w:lineRule="auto" />#
s#<w:outlineLvl#<w:jc w:val="center" /><w:outlineLvl#
s#</w:pPr>#</w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:b /><w:color w:val="000000" /><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr>#
}
/w:styleId="Heading3"/,/<\/w:style>/{
/<w:rPr>/,/<\/w:rPr>/d
s#<w:spacing [^>]*/>#<w:spacing w:before="234" w:after="104" w:line="240" w:lineRule="auto" />#
s#</w:pPr>#</w:pPr><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" /><w:b /><w:color w:val="000000" /><w:sz w:val="26" /><w:szCs w:val="26" /></w:rPr>#
}
SED
sed -i -f "$W/styles.sed" "$S"

# Custom paragraph styles used by the Lua filter (idb.lua); the names are the style ids.
cat > "$W/custom.xml" <<'XML'
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Allegation"><w:name w:val="Allegation"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="156" w:line="480" w:lineRule="auto" /><w:ind w:firstLine="720" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Continuation"><w:name w:val="Continuation"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="156" w:line="480" w:lineRule="auto" /><w:ind w:firstLine="0" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Lettered"><w:name w:val="Lettered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="auto" /><w:ind w:left="1800" w:hanging="1080" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Counsel"><w:name w:val="Counsel"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtHead"><w:name w:val="CourtHead"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="240" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CoverTitle"><w:name w:val="CoverTitle"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionCell"><w:name w:val="CaptionCell"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:firstLine="0" /></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigBlock"><w:name w:val="SigBlock"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:ind w:left="4320" w:firstLine="0" /></w:pPr></w:style>
XML
sed -i "/<\/w:styles>/e cat \"$W/custom.xml\"" "$S"

# Footer: centered PAGE field at 11 point, the typst footer (text size 11pt, counter(page)).
mkdir -p x/word
cat > x/word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:jc w:val="center" /></w:pPr><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="22" /><w:szCs w:val="22" /></w:rPr><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
sed -i 's#</Relationships>#<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFtr1" Target="footer1.xml" /></Relationships>#' x/word/_rels/document.xml.rels
sed -i 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' "x/[Content_Types].xml"

# sectPr: US Letter, 1 inch margins, footer reference (order: footerReference, footnotePr, pgSz, pgMar).
sed -i \
  -e '/<w:sectPr>/,/<\/w:sectPr>/{' \
  -e 's#<w:footnotePr>#<w:footerReference w:type="default" r:id="rIdFtr1" /><w:footnotePr>#' \
  -e 's#</w:footnotePr>#</w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />#' \
  -e '}' "$DOC"

for check in 'w:styleId="Allegation"' 'w:ascii="EB Garamond"' 'footerReference' 'pgMar' 'rIdFtr1'; do
  grep -rq "$check" x/word || { echo "make-reference.sh: $check missing after edit" >&2; exit 1; }
done
rm -f "$D/reference.docx"
(cd "$W/x" && zip -q -X -r "$D/reference.docx" .)
echo "$D/reference.docx"
