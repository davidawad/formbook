#!/bin/sh
# Builds docx/reference.docx from pandoc's default reference. Matches the typst form of this court's templates
# (typst/txsd-complaint.typ, typst/txsd-motion-brief.typ): EB Garamond 13 pt (the explicit face, no theme font),
# exact 26 pt line pitch (double spacing at 13 pt), 1 in margins on Letter, a centered PAGE field in the footer,
# and the named paragraph styles that docx/txsd.lua applies (caption, numbered and lettered items, signature block,
# table of contents). Usage: sh docx/build-reference.sh <out.docx>   (needs pandoc, unzip, zip, perl on PATH)
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
mkdir "$W/pkg"
cd "$W/pkg"
unzip -q ../ref.docx
cat > "$W/patch.pl" <<'PERL'
use strict;
use warnings;

sub slurp { my ($f) = @_; local $/; open my $h, '<:raw', $f or die "$f: $!"; my $s = <$h>; close $h; return $s; }
sub spit { my ($f, $s) = @_; open my $h, '>:raw', $f or die "$f: $!"; print $h $s; close $h; }

my $FONT = '<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/>';
my $RPR_BASE = $FONT . '<w:sz w:val="26"/><w:szCs w:val="26"/>';

# Paragraph style, custom: id = name without spaces (pandoc's rule for custom-style).
sub cs {
  my (%a) = @_;
  my $id = $a{id};
  my $based = $a{based} // 'Normal';
  my $custom = $a{builtin} ? '' : ' w:customStyle="1"';
  my $extra = $a{extra} // '';
  my $rpr = $a{rpr} // '';
  my $basedxml = $based eq '' ? '' : qq{<w:basedOn w:val="$based"/>};
  return qq{<w:style w:type="paragraph"$custom w:styleId="$id"><w:name w:val="$a{name}"/>$basedxml$extra<w:qFormat/><w:pPr>$a{ppr}</w:pPr><w:rPr>$rpr</w:rPr></w:style>};
}
my $EX520 = '<w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/>';
my $EX299 = '<w:spacing w:before="0" w:after="0" w:line="299" w:lineRule="exact"/>';
my $B = '<w:b/><w:bCs/>';

my @styles = (
  # Built-in paragraph styles the document uses (replaced whole).
  cs(id => 'Normal', name => 'Normal', builtin => 1, based => '',ppr => '<w:widowControl/>' . $EX520 . '<w:ind w:firstLine="0"/>', rpr => $RPR_BASE),
  cs(id => 'BodyText', name => 'Body Text', builtin => 1, ppr => '<w:spacing w:before="0" w:after="0"/><w:ind w:firstLine="0"/>', rpr => ''),
  cs(id => 'Compact', name => 'Compact', ppr => '<w:spacing w:before="0" w:after="0"/>', rpr => ''),
  cs(id => 'Heading1', name => 'heading 1', builtin => 1, extra => '<w:next w:val="BodyText"/>', ppr => '<w:keepNext/><w:keepLines/><w:spacing w:before="140" w:after="140"/><w:ind w:firstLine="0"/><w:jc w:val="center"/><w:outlineLvl w:val="0"/>', rpr => $B . '<w:color w:val="000000"/>'),
  cs(id => 'Heading2', name => 'heading 2', builtin => 1, extra => '<w:next w:val="BodyText"/>', ppr => '<w:keepNext/><w:keepLines/><w:spacing w:before="140" w:after="140"/><w:ind w:firstLine="0"/><w:jc w:val="left"/><w:outlineLvl w:val="1"/>', rpr => $B . '<w:color w:val="000000"/>'),
  cs(id => 'FootnoteText', name => 'Footnote Text', builtin => 1, ppr => '<w:spacing w:before="0" w:after="60" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/>', rpr => '<w:sz w:val="26"/><w:szCs w:val="26"/>'),
  # Court title and caption (typst: court-title, caption-box, caption-section). Single lines are 14.95 pt (exact 299).
  cs(id => 'CourtTitle', name => 'Court Title', ppr => $EX299 . '<w:ind w:firstLine="0"/><w:jc w:val="center"/>', rpr => $B),
  cs(id => 'CourtTitleLast', name => 'Court Title Last', based => 'CourtTitle', ppr => '<w:spacing w:before="0" w:after="221" w:line="299" w:lineRule="exact"/>', rpr => ''),
  cs(id => 'CaptionRow', name => 'Caption Row', ppr => '<w:spacing w:before="0" w:after="26" w:line="299" w:lineRule="exact"/><w:ind w:firstLine="0"/>', rpr => ''),
  cs(id => 'CaptionIndent', name => 'Caption Indent', based => 'CaptionRow', ppr => '<w:ind w:left="720" w:firstLine="0"/>', rpr => ''),
  cs(id => 'CaptionCA', name => 'Caption CA', ppr => '<w:tabs><w:tab w:val="left" w:pos="2304"/></w:tabs><w:spacing w:before="0" w:after="221" w:line="299" w:lineRule="exact"/><w:ind w:firstLine="0"/>', rpr => ''),
  cs(id => 'CaptionJury', name => 'Caption Jury', ppr => '<w:spacing w:before="0" w:after="0" w:line="299" w:lineRule="exact"/><w:ind w:firstLine="0"/>', rpr => ''),
  cs(id => 'CaptionSection', name => 'Caption Section', ppr => '<w:spacing w:before="0" w:after="65" w:line="299" w:lineRule="exact"/><w:ind w:firstLine="0"/>', rpr => ''),
  cs(id => 'CaptionSectionIndent', name => 'Caption Section Indent', based => 'CaptionSection', ppr => '<w:ind w:left="720" w:firstLine="0"/>', rpr => ''),
  cs(id => 'CaptionSectionMid', name => 'Caption Section Mid', based => 'CaptionSection', ppr => '<w:jc w:val="center"/>', rpr => ''),
  # Titles and body variants.
  cs(id => 'BriefTitle', name => 'Brief Title', ppr => '<w:keepNext/><w:spacing w:before="351" w:after="351" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="0"/><w:jc w:val="center"/>', rpr => $B),
  cs(id => 'LeadKeep', name => 'Lead Keep', based => 'BodyText', ppr => '<w:keepNext/>', rpr => ''),
  cs(id => 'LetteredItem', name => 'Lettered Item', ppr => '<w:tabs><w:tab w:val="left" w:pos="1440"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/><w:ind w:left="1440" w:hanging="1440"/>', rpr => ''),
  cs(id => 'NumberedParagraph', name => 'Numbered Paragraph', ppr => '<w:tabs><w:tab w:val="left" w:pos="1680"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/><w:ind w:firstLine="720"/>', rpr => ''),
  cs(id => 'NumberedItem', name => 'Numbered Item', ppr => '<w:tabs><w:tab w:val="left" w:pos="1800"/></w:tabs><w:spacing w:before="0" w:after="0" w:line="520" w:lineRule="exact"/><w:ind w:left="1800" w:hanging="1080"/>', rpr => ''),
  # Signature block (typst: signature-block, pad left 3.25 in, single-spaced lines).
  cs(id => 'SigDate', name => 'Sig Date', ppr => '<w:keepNext/><w:spacing w:before="0" w:after="351" w:line="299" w:lineRule="exact"/><w:ind w:firstLine="0"/>', rpr => ''),
  cs(id => 'SigLeadFirst', name => 'Sig Lead First', ppr => '<w:keepNext/><w:spacing w:before="351" w:after="175" w:line="299" w:lineRule="exact"/><w:ind w:left="4680" w:firstLine="0"/>', rpr => ''),
  cs(id => 'SigLead', name => 'Sig Lead', ppr => '<w:keepNext/><w:spacing w:before="0" w:after="175" w:line="299" w:lineRule="exact"/><w:ind w:left="4680" w:firstLine="0"/>', rpr => ''),
  cs(id => 'SigParty', name => 'Sig Party', based => 'SigLead', ppr => '', rpr => $B),
  cs(id => 'SigBy', name => 'Sig By', based => 'SigLead', ppr => '<w:spacing w:before="0" w:after="130" w:line="299" w:lineRule="exact"/>', rpr => ''),
  cs(id => 'SigLine', name => 'Sig Line', based => 'SigLead', ppr => '<w:spacing w:before="0" w:after="0" w:line="299" w:lineRule="exact"/>', rpr => ''),
  cs(id => 'SigLast', name => 'Sig Last', based => 'SigLead', ppr => '<w:keepNext w:val="0"/><w:spacing w:before="0" w:after="0" w:line="299" w:lineRule="exact"/>', rpr => ''),
  # Table of contents (typst outline: dot leaders to the right margin, 26 pt pitch).
  cs(id => 'TOCTitle', name => 'TOC Title', ppr => '<w:keepNext/><w:pageBreakBefore/>' . $EX520 . '<w:ind w:firstLine="0"/><w:jc w:val="center"/>', rpr => $B),
  cs(id => 'TOC1', name => 'toc 1', builtin => 1, ppr => '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9350"/></w:tabs>' . $EX520 . '<w:ind w:firstLine="0"/>', rpr => ''),
  cs(id => 'TOC2', name => 'toc 2', builtin => 1, ppr => '<w:tabs><w:tab w:val="right" w:leader="dot" w:pos="9350"/></w:tabs>' . $EX520 . '<w:ind w:firstLine="0"/>', rpr => ''),
  cs(id => 'PageStart', name => 'Page Start', ppr => '<w:spacing w:before="0" w:after="0" w:line="20" w:lineRule="exact"/><w:ind w:firstLine="0"/>', rpr => ''),
);

# styles.xml: docDefaults with explicit fonts (no theme font), then replace or append each style by id.
my $st = slurp('word/styles.xml');
$st =~ s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$FONT<w:sz w:val="26"/><w:szCs w:val="26"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:spacing w:after="0"/></w:pPr></w:pPrDefault></w:docDefaults>}s
  or die 'no docDefaults';
for my $xml (@styles) {
  my ($id) = $xml =~ /w:styleId="([^"]+)"/;
  if ($st =~ s{<w:style [^>]*w:styleId="\Q$id\E".*?</w:style>}{$xml}s) {
    # replaced in place
  } else {
    $st =~ s{</w:styles>}{$xml</w:styles>}s or die 'no </w:styles>';
  }
}
spit('word/styles.xml', $st);

# theme: the court face for the major and minor theme fonts too (nothing may fall back to Aptos or Calibri)
my $th = slurp('word/theme/theme1.xml');
$th =~ s{<a:latin typeface="[^"]*"}{<a:latin typeface="EB Garamond"}g;
spit('word/theme/theme1.xml', $th);

# footer: centered PAGE field (typst: numbering "1" centered at the foot, body size)
spit('word/footer1.xml', <<'XML');
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:eastAsia="EB Garamond" w:cs="EB Garamond"/><w:sz w:val="26"/><w:szCs w:val="26"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
XML
my $rels = slurp('word/_rels/document.xml.rels');
$rels =~ s{</Relationships>}{<Relationship Id="rIdTxsdFooter1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/></Relationships>}s or die 'rels';
spit('word/_rels/document.xml.rels', $rels);
my $ct = slurp('[Content_Types].xml');
$ct =~ s{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}s or die 'ct';
spit('[Content_Types].xml', $ct);

# body section: Letter, 1 in margins, the footer (replaces pandoc's sectPr)
my $doc = slurp('word/document.xml');
$doc =~ s{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdTxsdFooter1"/><w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/></w:sectPr>}s
  or die 'no sectPr';
spit('word/document.xml', $doc);
PERL
perl "$W/patch.pl"
for part in word/styles.xml word/document.xml word/footer1.xml word/theme/theme1.xml word/_rels/document.xml.rels '[Content_Types].xml'; do
  xmllint --noout "$part"
done
case $OUT in /*) ;; *) OUT=$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT") ;; esac
rm -f "$OUT"
zip -q -X "$OUT" '[Content_Types].xml'
zip -q -X -r "$OUT" _rels docProps word
echo "$OUT"
