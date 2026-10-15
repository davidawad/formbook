#!/bin/sh
# Builds docx/reference.docx for the S.D. Cal. motion-brief (memorandum of points and authorities) from pandoc's default
# reference: pleading paper per S.D. Cal. Civil L.R. 5.1 (as the typst template casd-motion-brief.typ): EB Garamond 14 point
# everywhere, 24 pt exact double spacing on every body line, no space between paragraphs, first-line indent 0.5 in, US
# Letter, 1.5 in left margin, 1 in top margin, 48 pt bottom margin (so 28 lines of 24 pt end at 10.33 in), Word line
# numbering (w:lnNumType, restarting each page), and a double rule at the text's left edge and a single rule at its right.
# Headings: level 1 centered bold; level 2 (I.) and level 3 (A.) bold with hanging indents, level 3 italic too.
# Run once (needs pandoc, unzip, sed, zip); the result is committed. Usage: sh docx/make-reference.sh (from the doc-type folder).
# Not rendered here (no LibreOffice on the build box): these values are set in styles.xml and sectPr only.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref0.docx" --print-default-data-file reference.docx
unzip -q "$W/ref0.docx" -d "$W/x"

# styles.xml: one element per line, so each style can be edited on its own line.
S="$W/x/word/styles.xml"
sed -e ':a' -e 'N' -e '$!ba' -e 's/\n[ \t]*/ /g' \
  -e 's#</w:style>#</w:style>\n#g' -e 's#<w:style #\n<w:style #g' "$S" > "$W/styles1.xml"
sed \
  -e 's#<w:rFonts [^>]*/>#<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />#g' \
  -e 's#<w:sz w:val="[0-9]*" />#<w:sz w:val="28" />#g' \
  -e 's#<w:szCs w:val="[0-9]*" />#<w:szCs w:val="28" />#g' \
  -e 's#<w:color [^>]*/>#<w:color w:val="000000" />#g' \
  -e 's#<w:spacing w:after="200" />#<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" />#' \
  -e '/w:styleId="BodyText"/s#<w:spacing [^>]*/>#<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="720" />#' \
  -e '/w:styleId="Compact"/s#<w:spacing [^>]*/>#<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:firstLine="0" />#' \
  -e '/w:styleId="BlockText"/s#<w:spacing [^>]*/>#<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" />#' \
  -e '/w:styleId="Heading1"/s#<w:spacing [^>]*/>#<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:jc w:val="center" />#' \
  -e '/w:styleId="Heading2"/s#<w:spacing [^>]*/>#<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:left="720" w:hanging="720" />#' \
  -e '/w:styleId="Heading3"/s#<w:spacing [^>]*/>#<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact" /><w:ind w:left="1440" w:hanging="720" />#' \
  -e '/w:styleId="Heading[123]"/s#\(<w:rFonts [^>]*/>\)#\1<w:b />#' \
  -e '/w:styleId="Heading3"/s#<w:b />#<w:b /><w:i />#' \
  -e '/w:styleId="FootnoteText"/s#</w:style>#<w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto" /></w:pPr></w:style>#' \
  "$W/styles1.xml" > "$W/x/word/styles.xml"

# document.xml: page size, margins, the pleading rules and line numbering in the body section.
DOC="$W/x/word/document.xml"
sed -i 's#</w:footnotePr>#</w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1080" w:bottom="960" w:left="2160" w:header="720" w:footer="480" w:gutter="0" /><w:pgBorders w:offsetFrom="text"><w:left w:val="double" w:sz="4" w:space="14" w:color="auto" /><w:right w:val="single" w:sz="4" w:space="7" w:color="auto" /></w:pgBorders><w:lnNumType w:countBy="1" w:distance="580" w:restart="newPage" />#' "$DOC"

rm -f "$D/reference.docx"
(cd "$W/x" && zip -q -X -r "$D/reference.docx" .)
echo "$D/reference.docx"
