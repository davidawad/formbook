#!/bin/sh
# Build docx/reference.docx: pandoc's default reference (numbering, settings, theme) with this doc type's styles
# (styles.xml) and the heading list the styles number from (numId 901: I., A., 1., a.).
# Usage: sh docx/make-reference.sh <out.docx>      (run from anywhere; the committed reference.docx is its output)
# Page setup, headers and footers are not in the reference: render.sh adds them to each sample (they carry the
# patent number from the frontmatter).
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/base.docx" --print-default-data-file reference.docx
mkdir "$W/x"
(cd "$W/x" && unzip -q "$W/base.docx")
cp "$D/styles.xml" "$W/x/word/styles.xml"
# the heading list: one abstract level per heading style, label then a space (typst heading-number)
perl -0pi -e '
  my $lvl = sub { my ($i, $fmt, $style, $text) = @_;
    return qq{<w:lvl w:ilvl="$i"><w:start w:val="1"/><w:numFmt w:val="$fmt"/><w:pStyle w:val="$style"/><w:suff w:val="space"/><w:lvlText w:val="$text"/><w:lvlJc w:val="left"/><w:pPr><w:ind w:left="0" w:firstLine="0"/></w:pPr></w:lvl>} };
  my $abs = qq{<w:abstractNum w:abstractNumId="901"><w:multiLevelType w:val="multilevel"/>}
    . $lvl->(0, "upperRoman", "Heading1", "%1.") . $lvl->(1, "upperLetter", "Heading2", "%2.")
    . $lvl->(2, "decimal", "Heading3", "%3.") . $lvl->(3, "lowerLetter", "Heading4", "%4.") . q{</w:abstractNum>};
  s{(<w:num )}{$abs$1}; s{</w:numbering>}{<w:num w:numId="901"><w:abstractNumId w:val="901"/></w:num></w:numbering>};
' "$W/x/word/numbering.xml"
rm -f "$OUT"
(cd "$W/x" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
unzip -tq "$OUT" > /dev/null
echo "$OUT"
