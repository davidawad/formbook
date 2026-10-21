#!/usr/bin/env bash
# Rebuild docx/reference.docx from pandoc's default reference document.
# Usage: bash docx/make-reference.sh   (run from anywhere)
# Sets: Times New Roman 12 pt; double-spaced Body Text with a 0.5 in first-line indent (37 CFR 2.126(a)(1));
# centred bold level-1 headings; bold level-2; bold italic level-3; single-spaced Block Text indented 1 in
# each side; a single-spaced "Drafting Note" style; Letter page, 1 in margins; centred page-number footer.
# Word-native features only (styles, footer PAGE field); no hand-set direct formatting in the body.
set -euo pipefail
cd "$(dirname "$0")"
HERE="$(pwd -P)"
W="$(mktemp -d)" || exit 1
safe_rmdir() {
  local target=${1:?}
  case "$target" in
    "${TMPDIR%/}"/tmp.* | /tmp/tmp.*) find "$target" -depth -delete ;;
    *) return 1 ;;
  esac
}
trap 'safe_rmdir "$W"' EXIT
pandoc -o "$W/ref0.docx" --print-default-data-file reference.docx
mkdir "$W/x"
unzip -q "$W/ref0.docx" -d "$W/x"
S="$W/x/word/styles.xml"
FONT='<w:rFonts w:ascii="Times New Roman" w:hAnsi="Times New Roman" w:eastAsia="Times New Roman" w:cs="Times New Roman" />'

# document defaults: Times New Roman 12, no spacing after
perl -0pi -e 's#<w:rPrDefault>.*?</w:rPrDefault>#<w:rPrDefault><w:rPr>'"$FONT"'<w:sz w:val="24" /><w:szCs w:val="24" /><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA" /></w:rPr></w:rPrDefault>#s; s#<w:pPrDefault>.*?</w:pPrDefault>#<w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto" /></w:pPr></w:pPrDefault>#s' "$S"

setstyle() { # id, new inner xml (everything after <w:name/> basedOn etc. is rebuilt)
  perl -0pi -e 's#(<w:style [^>]*w:styleId="'"$1"'"[^>]*>).*?(</w:style>)#$1'"$2"'$2#s' "$S"
}
# Body Text: double-spaced (line 480), first-line indent 0.5 in, widow control
setstyle BodyText '<w:name w:val="Body Text" /><w:basedOn w:val="Normal" /><w:link w:val="BodyTextChar" /><w:qFormat /><w:pPr><w:widowControl /><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="auto" /><w:ind w:firstLine="720" /></w:pPr>'
setstyle FirstParagraph '<w:name w:val="First Paragraph" /><w:basedOn w:val="BodyText" /><w:next w:val="BodyText" /><w:qFormat />'
setstyle Compact '<w:name w:val="Compact" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto" /></w:pPr>'
setstyle Heading1 '<w:name w:val="heading 1" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:link w:val="Heading1Char" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="360" w:after="240" w:line="240" w:lineRule="auto" /><w:jc w:val="center" /><w:outlineLvl w:val="0" /></w:pPr><w:rPr><w:b /><w:bCs /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr>'
setstyle Heading2 '<w:name w:val="heading 2" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="300" w:after="200" w:line="240" w:lineRule="auto" /><w:outlineLvl w:val="1" /></w:pPr><w:rPr><w:b /><w:bCs /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr>'
setstyle Heading3 '<w:name w:val="heading 3" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="240" w:after="180" w:line="240" w:lineRule="auto" /><w:outlineLvl w:val="2" /></w:pPr><w:rPr><w:b /><w:bCs /><w:i /><w:iCs /><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr>'
setstyle BlockText '<w:name w:val="Block Text" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:spacing w:before="200" w:after="220" w:line="240" w:lineRule="auto" /><w:ind w:left="1440" w:right="1440" w:firstLine="0" /></w:pPr>'
# custom style for drafting notes ("[CONFORM: ...]"): flush left, single-spaced, italic
perl -0pi -e 's#</w:styles>#<w:style w:type="paragraph" w:customStyle="1" w:styleId="DraftingNote"><w:name w:val="Drafting Note" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:keepNext /><w:spacing w:before="180" w:after="180" w:line="240" w:lineRule="auto" /></w:pPr><w:rPr><w:i /><w:iCs /></w:rPr></w:style><w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionCenter"><w:name w:val="Caption Center" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto" /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /><w:bCs /></w:rPr></w:style><w:style w:type="paragraph" w:customStyle="1" w:styleId="CaptionLine"><w:name w:val="Caption Line" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:spacing w:before="0" w:after="60" w:line="240" w:lineRule="auto" /></w:pPr></w:style><w:style w:type="paragraph" w:customStyle="1" w:styleId="PaperTitle"><w:name w:val="Paper Title" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:keepNext /><w:spacing w:before="280" w:after="240" w:line="240" w:lineRule="auto" /><w:jc w:val="center" /></w:pPr><w:rPr><w:b /><w:bCs /><w:u w:val="single" /></w:rPr></w:style><w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyTextKeep"><w:name w:val="Body Text Keep" /><w:basedOn w:val="BodyText" /><w:next w:val="BodyText" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /></w:pPr></w:style><w:style w:type="paragraph" w:customStyle="1" w:styleId="SignatureBlock"><w:name w:val="Signature Block" /><w:basedOn w:val="Normal" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="0" w:after="60" w:line="240" w:lineRule="auto" /><w:ind w:left="4680" /></w:pPr></w:style></w:styles>#s' "$S"
# footnote text and the footer
perl -0pi -e 's#(w:styleId="FootnoteText"[^>]*>).*?(</w:style>)#$1<w:name w:val="Footnote Text" /><w:basedOn w:val="Normal" /><w:next w:val="FootnoteText" /><w:uiPriority w:val="9" /><w:unhideWhenUsed /><w:qFormat /><w:pPr><w:spacing w:after="60" w:line="240" w:lineRule="auto" /></w:pPr><w:rPr><w:sz w:val="24" /><w:szCs w:val="24" /></w:rPr>$2#s' "$S"

# body: one empty paragraph and the section properties (Letter, 1 in margins, centred page-number footer)
cat > "$W/x/word/footer1.xml" <<'X'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center" /></w:pPr><w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
X
cat > "$W/x/word/document.xml" <<'X'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:body><w:p><w:pPr><w:pStyle w:val="BodyText" /></w:pPr><w:r><w:t>Reference document: styles for the TTAB template.</w:t></w:r></w:p><w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1" /><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" /></w:sectPr></w:body></w:document>
X
perl -0pi -e 's#</Relationships>#<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" /></Relationships>#' "$W/x/word/_rels/document.xml.rels"
perl -0pi -e 's#</Types>#<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>#' "$W/x/[Content_Types].xml"
rm -f "$HERE/reference.docx"
cd "$W/x"
zip -q -X -r "$HERE/reference.docx" '[Content_Types].xml' _rels docProps word
echo "$HERE/reference.docx"
