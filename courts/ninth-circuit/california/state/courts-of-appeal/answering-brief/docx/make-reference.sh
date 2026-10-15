#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference.docx for one California Court of Appeal doc type.
# Form set in styles.xml and document.xml (sectPr), matching the typst template of this doc type:
#   EB Garamond 13 pt everywhere (footnotes included); body lines exact at LINE twips (the typst body pitch,
#   measured on the render: 25.4 pt for opening/reply, 23.3 pt for answering); first-line indent 0.5 in;
#   headings single spaced, bold, black; block quotations single spaced, indented 0.5 in both sides;
#   US Letter; 1.5 in left and right, 1 in top and bottom; footer page number centered, none on the cover
#   (titlePg). Set in styles.xml/sectPr, not rendered here: the LibreOffice render is BLOCKED on the build box.
# Usage: sh docx/make-reference.sh   (from anywhere; writes docx/reference.docx beside this script)
# Needs pandoc and either unzip + zip, or ziptool (libzip, shipped in ~/tb/bin on the build box).
set -eu
D=$(cd "$(dirname "$0")" && pwd)
LINE=467          # exact body line pitch, twips (1/20 pt)
FONT="EB Garamond"
SZ=26             # half-points: 13 pt
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
have() { command -v "$1" > /dev/null 2>&1; }

extract() { # $1 docx, $2 target dir
  if have unzip; then unzip -q "$1" -d "$2"; return; fi
  have ziptool || { echo "make-reference.sh: need unzip or ziptool" >&2; exit 1; }
  i=0
  while ziptool "$1" stat "$i" > /dev/null 2>&1; do
    n=$(ziptool "$1" stat "$i" 2> /dev/null | head -n 1 | sed "s/^name: '//; s/'\$//")
    mkdir -p "$2/$(dirname "$n")"
    ziptool "$1" cat "$i" > "$2/$n"
    i=$((i + 1))
  done
}

pack() { # $1 source dir, $2 output docx (absolute)
  rm -f "$2"
  if have zip; then (cd "$1" && zip -q -X -r "$2" .); return; fi
  have ziptool || { echo "make-reference.sh: need zip or ziptool" >&2; exit 1; }
  (cd "$1" && find . -type f | sed 's#^\./##' | LC_ALL=C sort | grep -v '^\[Content_Types\].xml$' | sed '1i\
[Content_Types].xml
') > "$W/list"
  while IFS= read -r n; do
    f="$1/$n"
    ziptool -n "$2" add_file "$n" "$f" 0 "$(wc -c < "$f" | tr -d ' ')" > /dev/null
  done < "$W/list"
}

pandoc -o "$W/ref0.docx" --print-default-data-file reference.docx
mkdir "$W/x"
extract "$W/ref0.docx" "$W/x"
S="$W/x/word/styles.xml"
DOC="$W/x/word/document.xml"
RELS="$W/x/word/_rels/document.xml.rels"
CT="$W/x/[Content_Types].xml"

# 1. Drop the styles this form redefines (each is a block from <w:style to </w:style>), then re-add them.
for id in BodyText FirstParagraph Compact BlockText FootnoteText Heading1 Heading2 Heading3 Heading4 Heading5 Heading6; do
  sed -i "/<w:style [^>]*w:styleId=\"$id\"/,/<\/w:style>/d" "$S"
done

# 2. The re-added styles (the fragment ends with </w:styles>; the original closing tag is removed).
F="$W/styles-add.xml"
cat > "$F" <<XML
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="720"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>
<w:style w:type="paragraph" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:link w:val="FootnoteTextChar"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="$SZ"/><w:szCs w:val="$SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="$SZ"/><w:szCs w:val="$SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="$SZ"/><w:szCs w:val="$SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="1440" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="$SZ"/><w:szCs w:val="$SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading4"><w:name w:val="heading 4"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="2160" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="3"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="$SZ"/><w:szCs w:val="$SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading5"><w:name w:val="heading 5"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="2880" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="4"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="$SZ"/><w:szCs w:val="$SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading6"><w:name w:val="heading 6"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="3600" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="5"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="$SZ"/><w:szCs w:val="$SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CalctappCover"><w:name w:val="Calctapp Cover"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CalctappCoverLeft"><w:name w:val="Calctapp Cover Left"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CalctappSignature"><w:name w:val="Calctapp Signature"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4320" w:firstLine="0"/><w:jc w:val="left"/></w:pPr></w:style>
</w:styles>
XML
sed -e '/<\/w:styles>/r '"$F" -e '/<\/w:styles>/d' "$S" > "$S.new" && mv "$S.new" "$S"

# 3. Whatever is left (Title, Caption, Hyperlink, Heading 7-9 and the rest of pandoc's list): one font, one
# size, black; no theme fonts or colors. Joined onto one line first, because pandoc writes some rFonts and
# color elements across several lines.
tr -d '\n' < "$S" > "$S.one" && mv "$S.one" "$S"
sed -i \
  -e "s#<w:rFonts [^>]*/>#<w:rFonts w:ascii=\"$FONT\" w:hAnsi=\"$FONT\" w:eastAsia=\"$FONT\" w:cs=\"$FONT\" />#g" \
  -e "s#<w:sz w:val=\"[0-9]*\" */>#<w:sz w:val=\"$SZ\" />#g" \
  -e "s#<w:szCs w:val=\"[0-9]*\" */>#<w:szCs w:val=\"$SZ\" />#g" \
  -e 's#<w:color [^>]*/>#<w:color w:val="000000" />#g' \
  -e "s#<w:spacing w:after=\"200\" />#<w:spacing w:before=\"0\" w:after=\"0\" w:line=\"$LINE\" w:lineRule=\"exact\" />#" \
  "$S"

# 4. Page: US Letter, 1.5 in left and right, 1 in top and bottom; footer page number; no number on the cover.
sed -i \
  -e 's#<w:sectPr>#<w:sectPr><w:footerReference w:type="default" r:id="rIdCalctappFooter" />#' \
  -e 's#</w:footnotePr>#</w:footnotePr><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="2160" w:bottom="1440" w:left="2160" w:header="720" w:footer="720" w:gutter="0" /><w:titlePg />#' \
  "$DOC"
grep -q 'footerReference' "$DOC" || { echo "make-reference.sh: sectPr not found in pandoc's reference" >&2; exit 1; }
cat > "$W/x/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's#</Relationships>#<Relationship Id="rIdCalctappFooter" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml" /></Relationships>#' "$RELS"
sed -i 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' "$CT"

pack "$W/x" "$D/reference.docx"
echo "$D/reference.docx"
