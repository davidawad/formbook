#!/bin/sh
# Builds docx/reference.docx for W.D. Pa. (pawd) complaints from pandoc's default reference. The mandated form of
# pawd-complaint.typ (LCvR 5.1.A-B): EB Garamond 13 pt (not smaller than 12 pt), exact 26 pt (double) line pitch,
# 0.5 in first-line indent, 1 in margins on US Letter, single-spaced (16.25 pt) headings, caption, signature and
# footnotes, footnotes in the body size, page number centered in the footer.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, xmllint and ziptool (libzip) on PATH; no unzip/zip)
# Edits are made per style block by id (pandoc's reference is pretty-printed, so single-line sed does not match).
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
# unpack every entry (ziptool addresses entries by index; stat fails past the last one)
mkdir "$W/pkg"
i=0
while ziptool "$W/ref.docx" stat "$i" > "$W/stat.txt" 2>/dev/null; do
  name=$(sed -n "s/^name: '\(.*\)'\$/\1/p" "$W/stat.txt")
  mkdir -p "$(dirname "$W/pkg/$name")"
  ziptool "$W/ref.docx" cat "$i" > "$W/pkg/$name"
  i=$((i + 1))
done
cd "$W/pkg"

# styles: one definition per style id, replacing pandoc's; custom styles are appended
perl -0777 -e '
my $F = q{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>};
my $R = "<w:rPr>$F<w:sz w:val=\"26\"/><w:szCs w:val=\"26\"/></w:rPr>";
my $DBL = q{<w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/>};
my $SGL = q{<w:spacing w:before="0" w:after="0" w:line="325" w:lineRule="exact"/>};
my %S = (
  Normal => qq{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr><w:widowControl/>$DBL<w:jc w:val="left"/></w:pPr>$R</w:style>},
  BodyText => qq{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr>$DBL<w:ind w:firstLine="720"/></w:pPr></w:style>},
  FirstParagraph => q{<w:style w:type="paragraph" w:customStyle="1" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/></w:style>},
  Compact => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Compact"><w:name w:val="Compact"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr>$DBL<w:ind w:firstLine="0"/></w:pPr></w:style>},
  BlockText => qq{<w:style w:type="paragraph" w:styleId="BlockText"><w:name w:val="Block Text"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="520" w:after="520" w:line="325" w:lineRule="exact"/><w:ind w:left="1440" w:right="1440" w:firstLine="0"/></w:pPr></w:style>},
  FootnoteText => qq{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="60" w:line="325" w:lineRule="exact"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr></w:style>},
  Title => qq{<w:style w:type="paragraph" w:styleId="Title"><w:name w:val="Title"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>},
);
# custom styles used by the markdown filter (pawd.lua); appended if pandoc does not define them
my %C = (
  Centered => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$SGL<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>},
  Single => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$SGL<w:ind w:firstLine="0"/></w:pPr></w:style>},
  SingleGap => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="SingleGap"><w:name w:val="Single Gap"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:spacing w:before="520" w:after="0" w:line="325" w:lineRule="exact"/></w:pPr></w:style>},
  Sig => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Sig"><w:name w:val="Signature"/><w:basedOn w:val="Single"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:ind w:left="4320" w:firstLine="0"/></w:pPr></w:style>},
  SigGap => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="SigGap"><w:name w:val="Signature Gap"/><w:basedOn w:val="Sig"/><w:qFormat/><w:pPr><w:spacing w:before="520" w:after="0" w:line="325" w:lineRule="exact"/></w:pPr></w:style>},
  CourtHead => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CourtHead"><w:name w:val="Court Head"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:jc w:val="center"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>},
  TitleBlock => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="TitleBlock"><w:name w:val="Title Block"/><w:basedOn w:val="CourtHead"/><w:qFormat/></w:style>},
  Lettered => qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Lettered"><w:name w:val="Lettered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:ind w:left="1440" w:hanging="720"/></w:pPr></w:style>},
);
# headings (LCvR 5.1.B allows single spacing): sections centered in bold capitals; counts centered bold; sub-heads flush left bold
my %H = (
  1 => ["center", q{<w:ind w:firstLine="0"/>}],
  2 => ["center", q{<w:ind w:firstLine="0"/>}],
  3 => ["left", q{<w:ind w:firstLine="0"/>}],
  4 => ["left", q{<w:ind w:firstLine="0"/>}],
);
for my $l (1 .. 4) {
  my ($jc, $ind) = @{$H{$l}};
  $S{"Heading$l"} = qq{<w:style w:type="paragraph" w:styleId="Heading$l"><w:name w:val="heading $l"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading${l}Char"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="520" w:after="0" w:line="325" w:lineRule="exact"/>$ind<w:jc w:val="$jc"/><w:outlineLvl w:val="} . ($l - 1) . q{"/></w:pPr><w:rPr><w:b/><w:bCs/></w:rPr></w:style>};
}
local $/;
my $x = <STDIN>;
$x =~ s{(<w:style [^>]*?w:styleId="([A-Za-z0-9]+)".*?</w:style>)}{ exists $S{$2} ? $S{$2} : $1 }gse;
my $add = "";
for my $id (sort keys %S) { $add .= $S{$id} unless $x =~ /w:styleId="\Q$id\E"/; }
for my $id (sort keys %C) { $add .= $C{$id} unless $x =~ /w:styleId="\Q$id\E"/; }
$x =~ s{</w:styles>}{$add</w:styles>};
my $dd = q{<w:docDefaults><w:rPrDefault><w:rPr>} . $F . q{<w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0"/></w:pPr></w:pPrDefault></w:docDefaults>};
$x =~ s{<w:docDefaults>.*?</w:docDefaults>}{$dd}s;
print $x;
' < word/styles.xml > word/styles.new && mv word/styles.new word/styles.xml

# footer: the page number, centered, 13 pt (the footer is in the bottom margin, LCvR 5.1.B)
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="26"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="26"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="26"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="26"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="26"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'
# body section (the last one): US Letter, 1 in margins, the page-number footer, numbering from 1
perl -0777 -i -pe 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:pgNumType w:start="1"/></w:sectPr>}s' word/document.xml
for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done

# pack: [Content_Types].xml first, then every other part (no directory entries)
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
rm -f "$OUT"
cd "$W/pkg"
POSIXLY_CORRECT=1 ziptool -n "$OUT" add_file '[Content_Types].xml' "$W/pkg/[Content_Types].xml" 0 -1 > /dev/null
find . -type f ! -name '\[Content_Types\].xml' | sort | while read -r f; do
  n=${f#./}
  POSIXLY_CORRECT=1 ziptool "$OUT" add_file "$n" "$W/pkg/$n" 0 -1 > /dev/null
done
echo "$OUT"
