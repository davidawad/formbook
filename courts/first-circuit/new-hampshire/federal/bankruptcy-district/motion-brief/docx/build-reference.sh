#!/bin/sh
# Builds docx/reference.docx for the nhb motion (memorandum) and its certificate from pandoc's default reference.
# Form (typst/nhb-motion-brief.typ): EB Garamond 12 pt (vendored), body double spaced at an exact
# 27.6 pt line pitch (552 twentieths), first-line indent 0.5 in, no space between paragraphs (typst motion template renders none), letter paper with
# 1 in margins, centered page number (PAGE field) in the footer. Single-spaced caption and signature styles.
# Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, perl, unzip, zip, xmllint on PATH)
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg" && cd "$W/pkg" && unzip -q ../ref.docx
cat > "$W/styles.pl" <<'PL'
# Replaces or adds the paragraph styles of the nhb adversary complaint in word/styles.xml (stdin file: argv[1]).
local $/;
my $s = <>;
my $font = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
sub rpr { my ($sz, $x) = @_; $x //= ''; return "<w:rPr>$font$x<w:sz w:val=\"$sz\"/><w:szCs w:val=\"$sz\"/></w:rPr>"; }
sub st {
  my (%a) = @_;
  my $custom = $a{custom} ? ' w:customStyle="1"' : '';
  my $next = $a{next} ? qq{<w:next w:val="$a{next}"/>} : '';
  my $base = $a{base} // 'Normal';
  my $ppr = $a{ppr};
  return qq{<w:style w:type="paragraph"$custom w:styleId="$a{id}"><w:name w:val="$a{name}"/><w:basedOn w:val="$base"/>$next<w:qFormat/><w:pPr>$ppr</w:pPr>} . rpr($a{sz} // 24, $a{rx} // '') . qq{</w:style>};
}
sub setst {
  my ($id, $xml) = @_;
  $s =~ s{<w:style\b[^>]*w:styleId="\Q$id\E"[^>]*>.*?</w:style>}{$xml}s
    or $s =~ s{</w:styles>}{$xml</w:styles>}s;
}
my $single = '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/>';
my $exact = '<w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/>';
$s =~ s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$font<w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:pPrDefault></w:docDefaults>}s;
setst('Normal', qq{<w:style w:type="paragraph" w:default="1" w:styleId="Normal"><w:name w:val="Normal"/><w:qFormat/><w:pPr>$single</w:pPr>} . rpr(24) . qq{</w:style>});
setst('BodyText', st(id => 'BodyText', name => 'Body Text', next => 'BodyText', ppr => $exact));
setst('FirstParagraph', st(id => 'FirstParagraph', name => 'First Paragraph', base => 'BodyText', next => 'BodyText', ppr => $exact));
setst('BodyLast', st(custom => 1, id => 'BodyLast', name => 'Body Last', base => 'BodyText', ppr => '<w:keepNext/><w:keepLines/>' . $exact));
setst('SubItem', st(custom => 1, id => 'SubItem', name => 'Sub Item', base => 'BodyText', ppr => '<w:spacing w:before="0" w:after="120" w:line="552" w:lineRule="exact"/><w:ind w:left="1440" w:firstLine="0"/>'));
my $hd = '<w:keepNext/><w:keepLines/><w:spacing w:before="120" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/>';
setst('Heading1', st(id => 'Heading1', name => 'heading 1', next => 'BodyText', ppr => $hd . '<w:outlineLvl w:val="0"/>', rx => '<w:b/><w:bCs/>'));
setst('Heading2', st(id => 'Heading2', name => 'heading 2', next => 'BodyText', ppr => '<w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:left="720" w:hanging="720"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/>', rx => '<w:b/><w:bCs/>'));
setst('BlockText', st(id => 'BlockText', name => 'Block Text', next => 'BodyText', ppr => '<w:spacing w:before="0" w:after="240" w:line="276" w:lineRule="exact"/><w:ind w:left="720" w:right="720" w:firstLine="0"/>'));
setst('FootnoteText', st(id => 'FootnoteText', name => 'footnote text', ppr => '<w:spacing w:before="0" w:after="0" w:line="230" w:lineRule="exact"/><w:ind w:firstLine="0"/>', sz => 20));
# single-spaced caption, signature and title styles (names are generic; no case text)
my $cs = '<w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/>';
setst('CourtLine', st(custom => 1, id => 'CourtLine', name => 'Court Line', ppr => '<w:keepNext/><w:spacing w:before="0" w:after="0" w:line="216" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/>', rx => '<w:b/><w:bCs/>'));
setst('CourtLineLast', st(custom => 1, id => 'CourtLineLast', name => 'Court Line Last', base => 'CourtLine', ppr => '<w:keepNext/><w:spacing w:before="0" w:after="360" w:line="216" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/>', rx => '<w:b/><w:bCs/>'));
setst('TitleBlock', st(custom => 1, id => 'TitleBlock', name => 'Title Block', ppr => '<w:keepNext/><w:keepLines/><w:spacing w:before="360" w:after="240" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/>', rx => '<w:b/><w:bCs/>'));
setst('CapLeft', st(custom => 1, id => 'CapLeft', name => 'Caption Left', ppr => '<w:keepNext/><w:spacing w:before="0" w:after="120" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/>'));
setst('CapName', st(custom => 1, id => 'CapName', name => 'Caption Name', ppr => '<w:keepNext/><w:spacing w:before="0" w:after="60" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/>', rx => '<w:b/><w:bCs/>'));
setst('CapNameLast', st(custom => 1, id => 'CapNameLast', name => 'Caption Name Last', base => 'CapName', ppr => '<w:keepNext/><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/>', rx => '<w:b/><w:bCs/>'));
setst('CapRight', st(custom => 1, id => 'CapRight', name => 'Caption Right', ppr => '<w:keepNext/><w:spacing w:before="0" w:after="80" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="right"/>'));
setst('SigDate', st(custom => 1, id => 'SigDate', name => 'Signature Date', ppr => '<w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="540" w:line="216" w:lineRule="exact"/><w:ind w:firstLine="0"/>'));
setst('SigRight', st(custom => 1, id => 'SigRight', name => 'Signature Right', ppr => '<w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="60" w:line="216" w:lineRule="exact"/><w:ind w:left="4680" w:firstLine="0"/>'));
setst('SigSigner', st(custom => 1, id => 'SigSigner', name => 'Signature Signer', base => 'SigRight', ppr => '<w:keepNext/><w:keepLines/><w:spacing w:before="780" w:after="384" w:line="216" w:lineRule="exact"/><w:ind w:left="4680" w:firstLine="0"/>'));
setst('SigRightEnd', st(custom => 1, id => 'SigRightEnd', name => 'Signature Right End', ppr => '<w:keepLines/><w:spacing w:before="0" w:after="0" w:line="216" w:lineRule="exact"/><w:ind w:left="4680" w:firstLine="0"/>'));
setst('GapExact10', st(custom => 1, id => 'GapExact10', name => 'Gap 10 pt', ppr => '<w:spacing w:before="0" w:after="0" w:line="200" w:lineRule="exact"/><w:ind w:firstLine="0"/>'));
setst('Heading3', st(id => 'Heading3', name => 'heading 3', next => 'BodyText', ppr => '<w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="2"/>', rx => '<w:b/><w:bCs/><w:i/><w:iCs/>'));
setst('CertTitle', st(custom => 1, id => 'CertTitle', name => 'Certificate Title', ppr => '<w:keepNext/><w:keepLines/><w:spacing w:before="480" w:after="120" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/>', rx => '<w:b/><w:bCs/>'));
setst('SigDateSolo', st(custom => 1, id => 'SigDateSolo', name => 'Signature Date Solo', ppr => '<w:keepNext/><w:keepLines/><w:spacing w:before="240" w:after="240" w:line="216" w:lineRule="exact"/><w:ind w:firstLine="0"/>'));
setst('SigSignerSolo', st(custom => 1, id => 'SigSignerSolo', name => 'Signature Signer Solo', base => 'SigRight', ppr => '<w:keepNext/><w:keepLines/><w:spacing w:before="480" w:after="384" w:line="216" w:lineRule="exact"/><w:ind w:left="4680" w:firstLine="0"/>'));
setst('CertBody', st(custom => 1, id => 'CertBody', name => 'Certificate Body', base => 'BodyText', ppr => '<w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/><w:ind w:firstLine="720"/>'));
 print $s;
PL
perl -0777 "$W/styles.pl" word/styles.xml > "$W/styles.new" && mv "$W/styles.new" word/styles.xml
cat > "$W/doc.pl" <<'PL'
# Section: letter, 1 in margins, the page-number footer (rId100). Replaces the reference's sectPr.
local $/;
my $s = <>;
my $sect = '<w:sectPr><w:footerReference w:type="default" r:id="rId100"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>';
$s =~ s{<w:sectPr\b.*?</w:sectPr>}{$sect}s or $s =~ s{</w:body>}{$sect</w:body>}s;
 print $s;
PL
perl -0777 "$W/doc.pl" word/document.xml > "$W/doc.new" && mv "$W/doc.new" word/document.xml
cat > word/footer1.xml <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="24"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
grep -q 'Id="rId100"' word/_rels/document.xml.rels || sed -i 's|</Relationships>|<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rId100" Target="footer1.xml" /></Relationships>|' word/_rels/document.xml.rels
grep -q 'footer1.xml' '[Content_Types].xml' || sed -i 's|</Types>|<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" /></Types>|' '[Content_Types].xml'
for part in word/styles.xml word/document.xml word/footer1.xml; do xmllint --noout "$part"; done
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
