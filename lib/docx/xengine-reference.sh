#!/bin/sh
# xengine-reference.sh: the style recipe of the cross-engine layout model (docs/EVAL-LOOP.md, "Cross-engine gate";
# fb-595.54.1): a reference.docx whose paragraph styles set the line boxes the typst reference sets, for a template
# whose docx filter uses lib/docx/xengine.lua. Built from pandoc's default reference document:
#   * one font and size everywhere (docDefaults, headings); widow control on; no paragraph spacing by default;
#   * exact line spacing (Word sets each line in a box of that height, the baseline at 0.8 of it): Body Text and
#     List Item at the body pitch, Block Text and Footnote Text at the single pitch, headings at their own;
#   * Body Text with a first-line indent; List Item with the label in a box of the list indent, the text hanging;
#     Block Text indented both sides; footnotes kept whole, a space after each (their own size and pitch if given);
#   * headings black, bold, level 1 centered capitals, levels 4 and 5 italic; links black;
#   * letter paper, 1 in margins, a centered page-number footer.
# Usage: sh lib/docx/xengine-reference.sh <out.docx> font=<family> size=<half points> body=<twips> single=<twips>
#          [indent=720] [list=<indent>] [heading=<single>] [heading_before=240] [heading_after=120] [quote=280]
#          [note_after=140] [note=<single>] [note_size=<size>] [footer=432]
#   (pitches and spaces in twips: 588 = 29.4 pt; needs pandoc, perl, unzip, zip, xmllint)
set -eu
[ $# -ge 1 ] || { echo "usage: sh lib/docx/xengine-reference.sh <out.docx> font=... size=... body=... single=..." >&2; exit 2; }
OUT=$1
shift
XE_INDENT=720 XE_HEADING_BEFORE=240 XE_HEADING_AFTER=120 XE_QUOTE=280 XE_NOTE_AFTER=140 XE_FOOTER=432
XE_FONT= XE_SIZE= XE_BODY= XE_SINGLE= XE_LIST= XE_HEADING= XE_NOTE= XE_NOTE_SIZE=
for a in "$@"; do
  case $a in
    font=*) XE_FONT=${a#*=} ;;
    size=*) XE_SIZE=${a#*=} ;;
    body=*) XE_BODY=${a#*=} ;;
    single=*) XE_SINGLE=${a#*=} ;;
    indent=*) XE_INDENT=${a#*=} ;;
    list=*) XE_LIST=${a#*=} ;;
    heading=*) XE_HEADING=${a#*=} ;;
    heading_before=*) XE_HEADING_BEFORE=${a#*=} ;;
    heading_after=*) XE_HEADING_AFTER=${a#*=} ;;
    quote=*) XE_QUOTE=${a#*=} ;;
    note_after=*) XE_NOTE_AFTER=${a#*=} ;;
    note=*) XE_NOTE=${a#*=} ;;
    note_size=*) XE_NOTE_SIZE=${a#*=} ;;
    footer=*) XE_FOOTER=${a#*=} ;;
    *) echo "xengine-reference.sh: unknown argument $a" >&2; exit 2 ;;
  esac
done
for v in XE_FONT XE_SIZE XE_BODY XE_SINGLE; do
  eval "[ -n \"\${$v}\" ]" || { echo "xengine-reference.sh: ${v#XE_}= is required" >&2; exit 2; }
done
: "${XE_LIST:=$XE_INDENT}" "${XE_HEADING:=$XE_SINGLE}" "${XE_NOTE:=$XE_SINGLE}" "${XE_NOTE_SIZE:=$XE_SIZE}"
export XE_FONT XE_SIZE XE_BODY XE_SINGLE XE_INDENT XE_LIST XE_HEADING XE_HEADING_BEFORE XE_HEADING_AFTER XE_QUOTE \
  XE_NOTE_AFTER XE_NOTE XE_NOTE_SIZE XE_FOOTER

case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
W="$T/w"
mkdir "$W"
(cd "$W" && unzip -q "$T/default.docx")

perl -0pi -e '
  my ($f, $sz, $body, $single, $indent, $list, $head, $hb, $ha, $quote, $note, $nline, $nsz) =
    @ENV{qw(XE_FONT XE_SIZE XE_BODY XE_SINGLE XE_INDENT XE_LIST XE_HEADING XE_HEADING_BEFORE XE_HEADING_AFTER
      XE_QUOTE XE_NOTE_AFTER XE_NOTE XE_NOTE_SIZE)};
  my $fonts = qq{<w:rFonts w:ascii="$f" w:hAnsi="$f" w:eastAsia="$f" w:cs="$f"/>};
  my $size = qq{<w:sz w:val="$sz"/><w:szCs w:val="$sz"/>};
  sub exact { qq{<w:spacing w:before="$_[0]" w:after="$_[1]" w:line="$_[2]" w:lineRule="exact"/>} }
  s{<w:rFonts w:asciiTheme="minorHAnsi"[^>]*/>\s*<w:sz w:val="24" />\s*<w:szCs w:val="24" />}{$fonts$size}s or die "docDefaults";
  s{<w:spacing w:after="200" />}{<w:widowControl/><w:spacing w:after="0"/>}s or die "pPrDefault";
  s{(<w:style [^>]*w:styleId="BodyText".*?)<w:pPr>.*?</w:pPr>}{$1<w:pPr>@{[exact(0, 0, $body)]}<w:ind w:firstLine="$indent"/></w:pPr>}s or die "BodyText";
  for my $n (1..5) {
    my $jc = $n == 1 ? q{<w:jc w:val="center"/>} : q{};
    my $caps = $n == 1 ? q{<w:caps/>} : q{};
    my $ital = $n >= 4 ? q{<w:i/>} : q{};
    my $ppr = qq{<w:pPr><w:keepNext/><w:keepLines/>@{[exact($hb, $ha, $head)]}<w:ind w:firstLine="0"/>$jc<w:outlineLvl w:val="} . ($n - 1) . q{"/></w:pPr>};
    my $rpr = qq{<w:rPr>$fonts<w:b/><w:bCs/>$caps$ital<w:color w:val="000000"/>$size</w:rPr>};
    s{(<w:style [^>]*w:styleId="Heading$n".*?)<w:pPr>.*?</w:pPr>\s*<w:rPr>.*?</w:rPr>}{$1$ppr$rpr}s or die "Heading$n";
  }
  s{(<w:style [^>]*w:styleId="BlockText")}{<w:style w:type="paragraph" w:customStyle="1" w:styleId="ListItem"><w:name w:val="List Item"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr>@{[exact(0, 0, $body)]}<w:ind w:left="$list" w:hanging="$list"/></w:pPr></w:style>$1}s or die "ListItem";
  s{(<w:style [^>]*w:styleId="BlockText".*?)<w:pPr>.*?</w:pPr>}{$1<w:pPr>@{[exact($quote, $quote, $single)]}<w:ind w:firstLine="0" w:left="$indent" w:right="$indent"/></w:pPr>}s or die "BlockText";
  s{(<w:style [^>]*w:styleId="FootnoteText".*?<w:qFormat />)}{$1<w:pPr><w:keepLines/>@{[exact(0, $note, $nline)]}</w:pPr><w:rPr><w:sz w:val="$nsz"/><w:szCs w:val="$nsz"/></w:rPr>}s or die "FootnoteText";
  s{(<w:style [^>]*w:styleId="FootnoteBlockText".*?)<w:pPr>.*?</w:pPr>}{$1<w:pPr><w:spacing w:before="$quote" w:after="$quote"/><w:ind w:firstLine="0" w:left="$indent" w:right="$indent"/></w:pPr>}s or die "FootnoteBlockText";
  s{(<w:style [^>]*w:styleId="Hyperlink".*?)<w:color w:val="4F81BD" w:themeColor="accent1" />}{$1<w:color w:val="000000"/>}s or die "Hyperlink";
' "$W/word/styles.xml"
xmllint --format "$W/word/styles.xml" > "$T/styles.xml"
mv "$T/styles.xml" "$W/word/styles.xml"

perl -0pi -e '
  s{<w:sectPr>\s*<w:footnotePr>\s*<w:numRestart w:val="eachSect" />\s*</w:footnotePr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1" />\n      <w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="$ENV{XE_FOOTER}" w:gutter="0" />}s or die "sectPr";
' "$W/word/document.xml"
cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center" /></w:pPr><w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do
  xmllint --noout "$f"
done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
