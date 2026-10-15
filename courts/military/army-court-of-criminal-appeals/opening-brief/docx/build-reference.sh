#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference for the ACCA brief (32 CFR 150.15, App. B;
# the typst template is the form it matches). EB Garamond 12 pt (no face is named by the rules; see ../../README.md),
# double-spaced body with a 0.5 in first-line indent, single-spaced headings, block quotes and footnotes,
# letter paper with 1 in margins, a centered page number on every page after the cover.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, perl, unzip, zip, xmllint on PATH)
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx

# styles: every style the brief uses is rewritten whole, so no theme colour or theme font survives
FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>'
export FONT
perl -0pi -e '
  my $f = $ENV{FONT};
  s{(<w:docDefaults>.*?</w:docDefaults>)}{ my $d = $1; $d =~ s{<w:rFonts [^>]*/>}{$f}; $d =~ s{<w:spacing w:after="200" />}{<w:spacing w:after="0" w:line="240" w:lineRule="auto" />}; $d }se;
  my %name = (BodyText => "Body Text", FirstParagraph => "First Paragraph", Compact => "Compact", BlockText => "Block Text",
    Heading1 => "heading 1", Heading2 => "heading 2", Heading3 => "heading 3", FootnoteText => "Footnote Text", BodyKeepNext => "Body Keep Next");
  sub style {
    my ($id, $body) = @_;
    my $n = $name{$id} // $id;
    return qq{<w:style w:type="paragraph" w:styleId="$id"><w:name w:val="$n"/>$body</w:style>};
  }
  my %new = (
    BodyText => q{<w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="auto"/><w:ind w:firstLine="720"/></w:pPr><w:rPr>}.$f.q{<w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>},
    FirstParagraph => q{<w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="auto"/><w:ind w:firstLine="720"/></w:pPr>},
    Compact => q{<w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="480" w:lineRule="auto"/><w:ind w:firstLine="720"/></w:pPr>},
    BlockText => q{<w:basedOn w:val="BodyText"/><w:next w:val="BodyText"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:right="720" w:firstLine="0"/></w:pPr>},
    Heading1 => q{<w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/></w:pPr><w:rPr>}.$f.q{<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>},
    Heading2 => q{<w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:hanging="720" w:firstLine="0"/><w:outlineLvl w:val="1"/></w:pPr><w:rPr>}.$f.q{<w:b/><w:bCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>},
    Heading3 => q{<w:basedOn w:val="Normal"/><w:next w:val="BodyText"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/><w:spacing w:before="120" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:left="720" w:firstLine="0"/><w:outlineLvl w:val="2"/></w:pPr><w:rPr>}.$f.q{<w:b/><w:bCs/><w:i/><w:iCs/><w:color w:val="000000"/><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>},
    FootnoteText => q{<w:basedOn w:val="Normal"/><w:uiPriority w:val="9"/><w:unhideWhenUsed/><w:pPr><w:spacing w:before="0" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr><w:rPr>}.$f.q{<w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr>},
    Centered => q{<w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr>},
    Single => q{<w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="180" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr>},
    CoverLine => q{<w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:spacing w:before="0" w:after="60" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/></w:pPr>},
    BodyKeepNext => q{<w:basedOn w:val="BodyText"/><w:qFormat/><w:pPr><w:keepNext/><w:keepLines/></w:pPr>},
    SigBlock => q{<w:basedOn w:val="Normal"/><w:qFormat/><w:pPr><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:left="4320" w:firstLine="0"/></w:pPr>},
  );
  for my $id (sort keys %new) {
    my $xml = style($id, $new{$id});
    if ($id eq "Centered" or $id eq "Single" or $id eq "CoverLine" or $id eq "SigBlock" or $id eq "BodyKeepNext") {
      $xml =~ s{<w:style (w:type="paragraph") }{<w:style $1 w:customStyle="1" };
      s{</w:styles>}{$xml</w:styles>};
    } else {
      my $done = s{<w:style [^>]*w:styleId="$id".*?</w:style>}{$xml}s;
      die "no $id style in the default reference\n" unless $done;
    }
  }
' word/styles.xml

# the body section: letter, 1 in margins, the page number in the default footer, none on the cover (titlePg)
perl -0pi -e 's{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rId101"/><w:footerReference w:type="first" r:id="rId102"/><w:footnotePr><w:numRestart w:val="eachSect"/></w:footnotePr><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/><w:titlePg/></w:sectPr>}s' word/document.xml

cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:t>2</w:t></w:r><w:r><w:rPr><w:sz w:val="24"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
cat > word/footer2.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:p></w:ftr>
XML
perl -0pi -e 's{</Relationships>}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId101" Target="footer1.xml"/><Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId102" Target="footer2.xml"/></Relationships>}' word/_rels/document.xml.rels
perl -0pi -e 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/><Override PartName="/word/footer2.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}' '[Content_Types].xml'

for part in word/styles.xml word/document.xml word/footer1.xml word/footer2.xml word/_rels/document.xml.rels '[Content_Types].xml'; do xmllint --noout "$part"; done
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
