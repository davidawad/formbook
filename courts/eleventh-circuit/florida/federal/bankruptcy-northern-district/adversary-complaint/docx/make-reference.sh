#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference document (see ../../docs/DOCX.md): EB Garamond 14 pt
# everywhere (no face is named by the district rule; EB Garamond as in typst/); the body double-spaced (32.2 pt exact,
# the pitch of the typst render) with a half-inch first-line indent; headings single-spaced, bold where typst is
# bold, keep-with-next; footnotes 14 pt single-spaced; letter page with 1-inch margins; a centred page number in the
# footer. The caption, title, signature block and certificates are written by docx/flnb-adversary-complaint.lua.
# Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -eu
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/x"
(cd "$T/x" && unzip -q "$T/default.docx")
W="$T/w"
mkdir "$W"
cp -R "$T/x/." "$W/"
FONT='<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond" />'
export FONT
# Each style the court uses is replaced whole, so no spacing inherited from pandoc's defaults survives.
perl -0pi -e '
  my $f = $ENV{FONT};
  s{<w:rFonts [^>]*/>}{$f}sg;
  s{<w:sz w:val="24" />}{<w:sz w:val="28" />}sg;
  s{<w:szCs w:val="24" />}{<w:szCs w:val="28" />}sg;
  s{<w:spacing w:after="200" />}{<w:spacing w:after="0" />}s;
  my %style = (
    Normal => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="308" w:lineRule="exact" /></w:pPr>},
    BodyText => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="644" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr>},
    FirstParagraph => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="644" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr>},
    KeepNext => q{<w:pPr><w:keepNext /><w:spacing w:before="0" w:after="0" w:line="644" w:lineRule="exact" /><w:ind w:firstLine="720" /></w:pPr>},
    FootnoteText => q{<w:pPr><w:spacing w:before="0" w:after="0" w:line="308" w:lineRule="exact" /></w:pPr><w:rPr><w:sz w:val="28" /><w:szCs w:val="28" /></w:rPr>},
  );
  for my $id (keys %style) {
    my $body = $style{$id};
    my $name = $id eq "KeepNext" ? "Body Text Keep Next" : $id;
    my $based = $id eq "Normal" ? "" : ($id eq "KeepNext" ? q{<w:basedOn w:val="BodyText" />} : q{<w:basedOn w:val="Normal" />});
    if ($id eq "KeepNext") { s{(</w:styles>)}{<w:style w:type="paragraph" w:customStyle="1" w:styleId="KeepNext"><w:name w:val="$name" />$based<w:qFormat />$body</w:style>$1}s; next; }
    s{<w:style [^>]*w:styleId="$id".*?</w:style>}{<w:style w:type="paragraph" w:styleId="$id"><w:name w:val="$id" />$based<w:qFormat />$body</w:style>}s;
  }
  # Headings 1 to 4 (typst: level 2 and 3 bold and centred, level 4 centred; level 1 unused). Space before and after
  # are the typst v() values (0.8em, 0.4em for level 2; 0.6em, 0.3em for level 3; 0.6em after for level 4).
  my %head = (
    1 => [224, 112, 1, 1],
    2 => [224, 112, 1, 1],
    3 => [168, 84, 1, 1],
    4 => [168, 168, 1, 0],
  );
  for my $n (1..4) {
    my ($b, $a, $bold, $jc) = @{$head{$n}};
    my $jcx = $jc ? q{<w:jc w:val="center" />} : q{};
    my $bx = $bold ? q{<w:b /><w:bCs />} : q{};
    my $new = qq{<w:style w:type="paragraph" w:styleId="Heading$n"><w:name w:val="heading $n" /><w:basedOn w:val="Normal" /><w:next w:val="BodyText" /><w:uiPriority w:val="9" /><w:qFormat /><w:pPr><w:keepNext /><w:keepLines /><w:spacing w:before="$b" w:after="$a" w:line="308" w:lineRule="exact" /><w:ind w:firstLine="0" />$jcx<w:outlineLvl w:val="} . ($n-1) . qq{" /></w:pPr><w:rPr>$bx<w:color w:val="000000" /><w:sz w:val="28" /><w:szCs w:val="28" /></w:rPr></w:style>};
    s{<w:style [^>]*w:styleId="Heading$n".*?</w:style>}{$new}s;
  }
' "$W/word/styles.xml"
perl -0pi -e '
  s{(<w:sectPr>)}{$1<w:footerReference w:type="default" r:id="rIdFooter1" />}s;
  s{(<w:footnotePr>\s*<w:numRestart w:val="eachSect" />\s*</w:footnotePr>)}{$1<w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" />}s;
' "$W/word/document.xml"
cat > "$W/word/footer1.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center" /></w:pPr><w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
