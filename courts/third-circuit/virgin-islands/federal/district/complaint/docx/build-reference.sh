#!/bin/sh
# Builds docx/reference.docx for vid (District Court of the Virgin Islands) from pandoc's default reference.docx.
# Matches the typst template (typst/vid-*.typ): EB Garamond 12 pt, double spacing (24 pt exact), 1 in margins,
# letter paper, page number centered in the footer, single-spaced footnotes at 10 pt (LRCi 5.1 allows 10 pt).
# Parameters are the variables below. Usage: sh docx/build-reference.sh [out.docx]
# (default out: reference.docx next to this script). Needs pandoc, xmllint and ziptool (libzip);
# unzip and zip are not used, because they are not installed on the build box.
set -eu
FONT="EB Garamond"
SZ=24          # body size, half-points (24 = 12 pt)
LINE=480       # double spacing, twips, exact (480 = 24 pt)
INDENT=720     # first-line indent of body paragraphs, twips (720 = 0.5 in)
FN_SZ=20       # footnote size, half-points (20 = 10 pt)
export FONT SZ LINE INDENT FN_SZ
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$HERE/reference.docx}
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
SRC=$W/default.docx
pandoc -o "$SRC" --print-default-data-file reference.docx
P=$W/pkg
mkdir -p "$P"
n=$(ziptool "$SRC" get_num_entries 0 | awk '{print $1}')
i=0
while [ "$i" -lt "$n" ]; do
  name=$(ziptool "$SRC" stat "$i" | sed -n "s/^name: '\(.*\)'$/\1/p")
  mkdir -p "$P/$(dirname "$name")"
  ziptool "$SRC" cat "$i" > "$P/$name"
  i=$((i + 1))
done

# Styles: replaced whole, so no theme colours or sizes survive from pandoc's defaults.
cat > "$W/styles-new.xml" <<XML
<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/><w:spacing w:before="0" w:after="0" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="$INDENT"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="$INDENT"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="$LINE" w:after="$LINE" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="$SZ"/><w:szCs w:val="$SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="$LINE" w:after="$LINE" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr><w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="$SZ"/><w:szCs w:val="$SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="$LINE" w:after="$LINE" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr><w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/><w:sz w:val="$SZ"/><w:szCs w:val="$SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:spacing w:before="$LINE" w:after="$LINE" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="60" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="$FN_SZ"/><w:szCs w:val="$FN_SZ"/></w:rPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="CenteredBlock"><w:name w:val="Centered Block"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleBlock"><w:name w:val="Single Block"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr></w:style>
<w:style w:type="paragraph" w:customStyle="1" w:styleId="PrayerItem"><w:name w:val="Prayer Item"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="0" w:after="0" w:line="$LINE" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr></w:style>
XML

P_STYLES=$P/word/styles.xml
NEWSTYLES=$W/styles-new.xml
cat > "$W/edit-styles.pl" <<'PL'
# Usage: perl edit-styles.pl styles.xml new-styles.xml   (env: FONT, SZ, LINE, INDENT, FN_SZ)
use strict; use warnings;
my ($file, $newf) = @ARGV;
my $read = sub { my $p = shift; open my $h, '<', $p or die "$p: $!"; local $/; my $t = <$h>; close $h; $t };
my $s = $read->($file);
my $new = $read->($newf);
$s =~ s{(<w:docDefaults>.*?</w:docDefaults>)}{
  my $d = $1;
  $d =~ s{<w:rFonts [^>]*/>}{<w:rFonts w:ascii="$ENV{FONT}" w:hAnsi="$ENV{FONT}" w:eastAsia="$ENV{FONT}" w:cs="$ENV{FONT}"/>};
  $d =~ s{w:val="24"}{w:val="$ENV{SZ}"}g;
  $d =~ s{<w:spacing w:after="200"/>}{<w:spacing w:before="0" w:after="0" w:line="$ENV{LINE}" w:lineRule="exact"/>};
  $d }se or die "no docDefaults";
for my $id (qw(Normal BodyText FirstParagraph Compact Heading1 Heading2 Heading3 BlockText FootnoteText)) {
  $s =~ s{<w:style [^>]*w:styleId="$id"[^>]*>.*?</w:style>}{}s or die "style $id not found";
}
$s =~ s{</w:styles>}{$new</w:styles>}s or die "no </w:styles>";
open my $o, '>', $file or die; print $o $s; close $o;
PL
perl "$W/edit-styles.pl" "$P_STYLES" "$NEWSTYLES"

# Section: letter, 1 in margins, centered PAGE number in the footer (replaces pandoc's sectPr).
perl -0777 -i -pe 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>}s' "$P/word/document.xml"
cat > "$P/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
perl -0777 -i -pe 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml"/></Relationships>}' "$P/word/_rels/document.xml.rels"
perl -0777 -i -pe 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}' "$P/[Content_Types].xml"

# Every XML part must be well formed before packing.
for part in "$P/[Content_Types].xml" "$P/word/styles.xml" "$P/word/document.xml" "$P/word/footer1.xml" "$P/word/_rels/document.xml.rels"; do
  xmllint --noout "$part"
done

# Pack: [Content_Types].xml first, then the rest.
rm -f "$OUT"
ziptool -n "$OUT" add_file '[Content_Types].xml' "$P/[Content_Types].xml" 0 "$(wc -c < "$P/[Content_Types].xml")" > /dev/null
cd "$P"
find . -type f | sed 's|^\./||' | grep -v '^\[Content_Types\]\.xml$' | sort | while IFS= read -r f; do
  ziptool -n "$OUT" add_file "$f" "$P/$f" 0 "$(wc -c < "$P/$f")" > /dev/null
done
echo "$OUT"
