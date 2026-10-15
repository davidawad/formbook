#!/bin/sh
# Builds docx/reference.docx for the PAEB motion with memorandum of law (typst: paeb-motion-brief.typ).
# Starts from pandoc's default reference.docx and sets: EB Garamond 12 pt, exact 24 pt line pitch (the typst
# body leading at 12 pt measures 24 pt baselines), first-line indent 0.5 in, no space between paragraphs, 1 in
# margins on letter paper, bold capitals flush-left level-1 headings (typst show rule), bold flush-left level-2 and level-3
# headings, footnotes at body size single spaced (the typst template sets no footnote size), page number
# centered in the footer, and the "Centered", "CenteredBody", "Single", "ListItem", "ListItemKeep",
# "BodyKeep" and "BodyFlush" paragraph styles used by paeb.lua (the lead-in quotes are flush: no first-line indent). The caption, signature block and certificate are built by the filter.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, xmllint and ziptool on PATH; no unzip or zip here)
set -eu
OUT=$1
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
FONT="EB Garamond"
BODY_SZ=24            # half-points: 12 pt
FOOTNOTE_SZ=24        # half-points: body size (no typst footnote rule)
H1_JC=left            # level-1 headings: bold capitals, flush left (motion; the typst show rule does not center them)
export FONT BODY_SZ FOOTNOTE_SZ H1_JC
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT

# unpack <archive> <dir>: ziptool stat gives each entry's name; cat gives its bytes
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

# pack <out> <dir>: [Content_Types].xml first, then every file, stored with its relative name
pack() {
  rm -f "$1"
  ziptool -n "$1" add_file '[Content_Types].xml' "$2/[Content_Types].xml" 0 "$(wc -c < "$2/[Content_Types].xml")"
  (cd "$2" && find . -type f | sed "s|^\./||" | grep -v -x -F "[Content_Types].xml" | sort) | while IFS= read -r f; do
    ziptool "$1" add_file "$f" "$2/$f" 0 "$(wc -c < "$2/$f")"
  done
}

pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
unpack "$W/ref.docx" "$W/pkg"
cd "$W/pkg"

perl -0777 -i -pe '
  my $f = $ENV{FONT}; my $sz = $ENV{BODY_SZ}; my $fn = $ENV{FOOTNOTE_SZ}; my $jc = $ENV{H1_JC};
  my $rf = qq{<w:rFonts w:ascii="$f" w:hAnsi="$f" w:eastAsia="$f" w:cs="$f"/>};
  my $sp = qq{<w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="exact"/>};
  my $single = qq{<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/>};
  my $head = qq{<w:spacing w:before="120" w:after="120" w:line="480" w:lineRule="exact"/>};
  my $ind = qq{<w:ind w:firstLine="720"/>};
  my $col = qq{<w:color w:val="000000"/>};
  s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$rf<w:sz w:val="$sz"/><w:szCs w:val="$sz"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr>$single</w:pPr></w:pPrDefault></w:docDefaults>}s;
  my $body = qq{<w:widowControl/>$sp$ind};
  my %style = (
    BodyText => qq{<w:style w:type="paragraph" w:styleId="BodyText"><w:name w:val="Body Text"/><w:basedOn w:val="Normal"/><w:link w:val="BodyTextChar"/><w:qFormat/><w:pPr>$body</w:pPr></w:style>},
    FirstParagraph => qq{<w:style w:type="paragraph" w:styleId="FirstParagraph"><w:name w:val="First Paragraph"/><w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr>$body</w:pPr></w:style>},
    Heading1 => qq{<w:style w:type="paragraph" w:styleId="Heading1"><w:name w:val="heading 1"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading1Char"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$head<w:ind w:firstLine="0"/><w:jc w:val="$jc"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr>$rf<w:b/><w:bCs/><w:caps/>$col<w:sz w:val="$sz"/><w:szCs w:val="$sz"/></w:rPr></w:style>},
    Heading2 => qq{<w:style w:type="paragraph" w:styleId="Heading2"><w:name w:val="heading 2"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading2Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$head<w:ind w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr>$rf<w:b/><w:bCs/>$col<w:sz w:val="$sz"/><w:szCs w:val="$sz"/></w:rPr></w:style>},
    Heading3 => qq{<w:style w:type="paragraph" w:styleId="Heading3"><w:name w:val="heading 3"/><w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:link w:val="Heading3Char"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/>$head<w:ind w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr>$rf<w:b/><w:bCs/>$col<w:sz w:val="$sz"/><w:szCs w:val="$sz"/></w:rPr></w:style>},
    FootnoteText => qq{<w:style w:type="paragraph" w:styleId="FootnoteText"><w:name w:val="footnote text"/><w:basedOn w:val="Normal"/><w:link w:val="FootnoteTextChar"/><w:uiPriority w:val="99"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr><w:sz w:val="$fn"/><w:szCs w:val="$fn"/></w:rPr></w:style>},
  );
  for my $id (keys %style) {
    s{<w:style [^>]*w:styleId="$id".*?</w:style>}{$style{$id}}s or die "style $id not found\n";
  }
  my $custom = join "",
    qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Centered"><w:name w:val="Centered"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$single<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>},
    qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="CenteredBody"><w:name w:val="Centered Body"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$sp<w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr></w:style>},
    qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="Single"><w:name w:val="Single"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr>$single<w:ind w:firstLine="0"/></w:pPr></w:style>},
    qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="ListItem"><w:name w:val="List Item (Typst)"/><w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:tabs><w:tab w:val="left" w:pos="1584"/></w:tabs>$sp<w:ind w:left="1584" w:hanging="864"/></w:pPr></w:style>},
    qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="ListItemKeep"><w:name w:val="List Item Keep"/><w:basedOn w:val="ListItem"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>},
    qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyFlush"><w:name w:val="Body Flush"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:ind w:firstLine="0"/></w:pPr></w:style>},
    qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="BodyKeep"><w:name w:val="Body Keep"/><w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/></w:pPr></w:style>};
  s{</w:styles>}{$custom</w:styles>}s;
' word/styles.xml

# section: letter, 1 in margins, centered page number in the footer (replaces pandoc'"'"'s section properties)
perl -0777 -i -pe 's{<w:sectPr\b.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:cols w:space="720"/></w:sectPr>}s or die "no sectPr\n"' word/document.xml

cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'

for part in word/styles.xml word/document.xml word/footer1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
pack "$W/out.docx" "$W/pkg"
cp "$W/out.docx" "$OUT"
echo "$OUT"
