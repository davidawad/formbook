#!/bin/sh
# Build docx/reference.docx from pandoc's default reference: EB Garamond 14 pt text, double spacing
# (30.8 pt exact), single spacing (17 pt exact) for headings, quotations and footnotes (12 pt),
# letter paper, 1 in margins. Same form as typst/ca5-*.typ and latex/template.tex.
# Usage: sh make-reference.sh <out.docx>   (needs pandoc, zip, unzip, perl)
set -eu
OUT=$1
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
pandoc -o "$W/ref.docx" --print-default-data-file reference.docx
cd "$W"
unzip -q ref.docx -d x
perl -0777 -i -pe '
  # set the pPr and rPr of a style by styleId (adds them if the style has none)
  sub setsty {
    my ($id, $ppr, $rpr) = @_;
    s{(<w:style [^>]*w:styleId="\Q$id\E"[^>]*>)(.*?)(</w:style>)}{
      my ($open, $body, $close) = ($1, $2, $3);
      $body =~ s{<w:pPr>.*?</w:pPr>}{}s;
      $body =~ s{<w:rPr>.*?</w:rPr>}{}s;
      $body = "<w:pPr>$ppr</w:pPr>" . $body if $ppr ne "";
      $body .= "<w:rPr>$rpr</w:rPr>" if $rpr ne "";
      $open . $body . $close;
    }se;
  }
  my $font = q{<w:rFonts w:ascii="EB Garamond" w:hAnsi="EB Garamond" w:cs="EB Garamond"/>};
  my $dbl = q{<w:spacing w:before="0" w:after="0" w:line="616" w:lineRule="exact"/>};
  my $sgl = q{<w:spacing w:before="0" w:after="0" w:line="340" w:lineRule="exact"/>};
  setsty("Normal", "", qq{$font<w:sz w:val="28"/><w:szCs w:val="28"/>});
  setsty("BodyText", qq{$dbl<w:ind w:firstLine="720"/><w:jc w:val="both"/>}, "");
  setsty("FirstParagraph", qq{$dbl<w:ind w:firstLine="720"/><w:jc w:val="both"/>}, "");
  setsty("Compact", $sgl, "");
  setsty("BlockText", qq{$sgl<w:ind w:left="720" w:right="720"/>}, "");
  setsty("FootnoteText", q{<w:spacing w:before="0" w:after="0" w:line="280" w:lineRule="exact"/>}, q{<w:sz w:val="24"/><w:szCs w:val="24"/>});
  setsty("Heading1", qq{<w:keepNext/><w:keepLines/>$sgl<w:spacing w:before="240" w:after="220" w:line="340" w:lineRule="exact"/><w:jc w:val="center"/>}, qq{<w:b/><w:caps/><w:sz w:val="28"/><w:szCs w:val="28"/>});
  for my $n (2 .. 5) {
    setsty("Heading$n", qq{<w:keepNext/><w:keepLines/><w:spacing w:before="200" w:after="180" w:line="340" w:lineRule="exact"/>}, qq{$font<w:b/><w:sz w:val="28"/><w:szCs w:val="28"/>});
  }
' x/word/styles.xml
perl -0777 -i -pe '
  s{<w:pgSz[^>]*/>}{<w:pgSz w:w="12240" w:h="15840"/>}g;
  s{<w:pgMar[^>]*/>}{<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>}g;
' x/word/document.xml
(cd x && zip -q -X -r "$W/out.docx" .)
cp "$W/out.docx" "$OUT"
echo "$OUT"
