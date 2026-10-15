#!/bin/sh
# Build docx/reference.docx for the moeb adversary complaint from pandoc's default reference.
# Same form as typst/moeb-adversary-complaint.typ: EB Garamond 12 pt, letter paper, 1 in margins,
# double spacing (27.6 pt exact, 552 twips) for text, single spacing (13.8 pt exact, 276 twips) for the
# caption, signature block, served entries and footnotes (10 pt, 11.75 pt exact), centered caps
# headings (Heading 1 at 17 pt; typst 16.8 pt), centered page number in the footer.
# Usage: sh make-reference.sh <absolute path of out.docx>   (needs pandoc, zip, unzip, perl)
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
cd "$W"
unzip -q ref.docx -d x
perl -0777 -i -pe '
  my $font = q{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:cs="EB Garamond" w:eastAsia="EB Garamond"/>};
  my $dbl = q{<w:spacing w:before="0" w:after="0" w:line="552" w:lineRule="exact"/>};
  my $sgl = q{<w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/>};
  # Replace the pPr and rPr of a style by styleId. They go at the end of the style, which keeps the
  # schema order (name, basedOn, ..., qFormat, pPr, rPr).
  sub setsty {
    my ($id, $ppr, $rpr) = @_;
    s{(<w:style [^>]*w:styleId="\Q$id\E"[^>]*>)(.*?)(</w:style>)}{
      my ($open, $body, $close) = ($1, $2, $3);
      $body =~ s{<w:pPr>.*?</w:pPr>}{}s;
      $body =~ s{<w:rPr>.*?</w:rPr>}{}s;
      $body .= "<w:pPr>$ppr</w:pPr>" if $ppr ne "";
      $body .= "<w:rPr>$rpr</w:rPr>" if $rpr ne "";
      $open . $body . $close;
    }se;
  }
  # Add a paragraph style (a custom style, as pandoc custom-style divs name it).
  sub addsty {
    my ($id, $name, $based, $ppr, $rpr) = @_;
    my $x = qq{<w:style w:type="paragraph" w:customStyle="1" w:styleId="$id"><w:name w:val="$name"/><w:basedOn w:val="$based"/><w:qFormat/>};
    $x .= "<w:pPr>$ppr</w:pPr>" if $ppr ne "";
    $x .= "<w:rPr>$rpr</w:rPr>" if $rpr ne "";
    $x .= "</w:style>";
    s{</w:styles>}{$x</w:styles>};
  }
  # Document defaults: EB Garamond, 12 pt, no space after (every style sets its own line spacing).
  s{<w:docDefaults>.*?</w:docDefaults>}{<w:docDefaults><w:rPrDefault><w:rPr>$font<w:sz w:val="24"/><w:szCs w:val="24"/><w:lang w:val="en-US" w:eastAsia="en-US" w:bidi="ar-SA"/></w:rPr></w:rPrDefault><w:pPrDefault><w:pPr><w:widowControl w:val="0"/><w:spacing w:after="0"/></w:pPr></w:pPrDefault></w:docDefaults>}s;
  setsty("Normal", $sgl, qq{$font<w:sz w:val="24"/><w:szCs w:val="24"/>});
  # Body text, first paragraph and list items: double spaced, flush left (the template indents the first line).
  setsty("BodyText", $dbl, "");
  setsty("FirstParagraph", $dbl, "");
  setsty("Compact", $dbl, "");
  setsty("BlockText", q{<w:spacing w:before="0" w:after="276" w:line="276" w:lineRule="exact"/><w:ind w:left="720" w:right="720"/>}, "");
  setsty("FootnoteText", q{<w:spacing w:before="0" w:after="0" w:line="235" w:lineRule="exact"/>}, q{<w:sz w:val="20"/><w:szCs w:val="20"/>});
  setsty("Heading1", q{<w:keepNext/><w:keepLines/><w:spacing w:before="228" w:after="0" w:line="340" w:lineRule="exact"/><w:jc w:val="center"/>},qq{$font<w:b/><w:caps/><w:sz w:val="34"/><w:szCs w:val="34"/>});
  setsty("Heading2", qq{<w:keepNext/><w:keepLines/>$dbl<w:jc w:val="center"/>}, qq{$font<w:b/><w:sz w:val="24"/><w:szCs w:val="24"/>});
  setsty("Heading3", qq{<w:keepNext/><w:keepLines/>$dbl}, qq{$font<w:b/><w:i/><w:sz w:val="24"/><w:szCs w:val="24"/>});
  for my $n (4 .. 9) {
    setsty("Heading$n", qq{<w:keepNext/><w:keepLines/>$dbl}, qq{$font<w:b/><w:sz w:val="24"/><w:szCs w:val="24"/>});
  }
  # Custom paragraph styles used by the Lua filter (Div custom-style). Tab stops: 1611 twips is where the text
  # of a numbered paragraph starts (0.5 in indent, "1.", then the same gap as typst); 4608 is the 3.2 in
  # column of the signature block.
  addsty("CourtTitle", "Court Title", "Normal", qq{<w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="276" w:line="276" w:lineRule="exact"/><w:jc w:val="center"/>}, qq{$font<w:b/><w:sz w:val="24"/><w:szCs w:val="24"/>});
  addsty("CaptionCell", "Caption Cell", "Normal", q{<w:keepNext/><w:keepLines/><w:spacing w:before="0" w:after="0" w:line="276" w:lineRule="exact"/><w:jc w:val="left"/>}, "");
  addsty("CaptionCellGap", "Caption Cell Gap", "CaptionCell", q{<w:keepNext/><w:keepLines/><w:spacing w:before="78" w:after="0" w:line="276" w:lineRule="exact"/><w:jc w:val="left"/>}, "");
  addsty("CaptionTitle", "Caption Title", "Normal", qq{<w:keepNext/><w:keepLines/><w:spacing w:before="200" w:after="0" w:line="200" w:lineRule="exact"/><w:jc w:val="center"/>}, qq{$font<w:b/><w:caps/><w:sz w:val="24"/><w:szCs w:val="24"/>});
  addsty("NumberedParagraph", "Numbered Paragraph", "Normal", qq{<w:tabs><w:tab w:val="left" w:pos="1611"/></w:tabs>$dbl<w:ind w:firstLine="720"/><w:jc w:val="left"/>}, "");
  addsty("NumberedParagraphKeep", "Numbered Paragraph Keep", "NumberedParagraph", q{<w:keepNext/><w:keepLines/>}, "");
  addsty("UnnumberedParagraph", "Unnumbered Paragraph", "Normal", qq{$dbl<w:ind w:firstLine="720"/><w:jc w:val="left"/>}, "");
  addsty("UnnumberedParagraphKeep", "Unnumbered Paragraph Keep", "UnnumberedParagraph", q{<w:keepNext/><w:keepLines/>}, "");
  addsty("CenteredParagraph", "Centered Paragraph", "Normal", qq{$dbl<w:jc w:val="center"/>}, "");
  addsty("BlankLine", "Blank Line", "Normal", qq{<w:keepNext/><w:keepLines/>$dbl}, "");
  addsty("SignatureBlock", "Signature Block", "Normal", qq{<w:keepNext/><w:keepLines/><w:tabs><w:tab w:val="left" w:pos="4608"/></w:tabs>$sgl}, "");
  addsty("SignatureRight", "Signature Right", "Normal", qq{<w:keepNext/><w:keepLines/>$sgl<w:ind w:left="4608"/>}, "");
  addsty("CertificateHeading", "Certificate Heading", "Normal", qq{<w:keepNext/><w:keepLines/>$dbl<w:jc w:val="center"/>}, qq{$font<w:b/><w:sz w:val="24"/><w:szCs w:val="24"/>});
  addsty("ServedEntry", "Served Entry", "Normal", q{<w:keepLines/><w:spacing w:before="0" w:after="120" w:line="276" w:lineRule="exact"/><w:jc w:val="left"/>}, "");
  addsty("ServedEntryKeep", "Served Entry Keep", "ServedEntry", q{<w:keepNext/>}, "");
  addsty("SignatureRightLast", "Signature Right Last", "Normal", qq{$sgl<w:ind w:left="4608"/>}, "");
' x/word/styles.xml
perl -0777 -i -pe '
  # Letter paper, 1 in margins (footer 0.55 in from the bottom edge, as the typst footer sits).
  s{<w:sectPr>(.*?)</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdMoebFooter"/>$1<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="792" w:gutter="0"/></w:sectPr>}s;
' x/word/document.xml
cat > x/word/footer1.xml <<'EOF'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:jc w:val="center"/></w:pPr><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:t>1</w:t></w:r><w:r><w:rPr><w:sz w:val="24"/><w:szCs w:val="24"/></w:rPr><w:fldChar w:fldCharType="end"/></w:r></w:p></w:ftr>
EOF
perl -0777 -i -pe 's{</Relationships>}{<Relationship Id="rIdMoebFooter" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer1.xml"/></Relationships>}' x/word/_rels/document.xml.rels
perl -0777 -i -pe 's{</Types>}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>}' 'x/[Content_Types].xml'
(cd x && zip -q -X -r "$W/out.docx" .)
cp "$W/out.docx" "$OUT"
echo "$OUT"
