#!/usr/bin/env bash
# Builds docx/reference.docx from pandoc's default reference document (see docs/DOCX.md and this folder's README,
# "Engines"). The court form it sets (typst/prd-motion-brief.typ, PRD-FORM-002 to -005): Times New Roman 12 pt (pinned);
# body double-spaced at 24 pt exact; 1-inch margins on US Letter; headings at body size, level 1 centred capitals;
# footnotes and block quotations single-spaced; a centred PAGE number at 12 pt in the footer.
# Styles are the ones in parts/styles-prd.xml (replacing pandoc's); the footer is parts/footer1.xml.
# Usage: sh docx/make-reference.sh [out.docx]   (needs pandoc, perl, unzip, zip, xmllint)
set -euo pipefail
D=$(cd "$(dirname "$0")" && pwd)
OUT=${1:-$D/reference.docx}
T=$(mktemp -d) || exit 1
# safe_rmdir <dir>: delete a directory made by mktemp -d (or one inside it), and nothing else
safe_rmdir() {
  t=${TMPDIR:-/tmp}
  case "${1:?}" in
    "${t%/}"/tmp.* | /tmp/tmp.*) find "$1" -depth -delete ;;
    *) return 1 ;;
  esac
}
trap 'safe_rmdir "$T"' EXIT
pandoc --print-default-data-file reference.docx > "$T/default.docx"
mkdir "$T/x"
(cd "$T/x" && unzip -q "$T/default.docx")
W="$T/w"
mkdir "$W"
cp -R "$T/x/." "$W/"
PRD_STYLES="$D/parts/styles-prd.xml" perl -0pi -e '
  my $new = do { local $/; open my $fh, "<", $ENV{PRD_STYLES} or die "$ENV{PRD_STYLES}: $!"; <$fh> };
  my ($dd) = $new =~ m{(<w:docDefaults>.*?</w:docDefaults>)}s or die "no docDefaults";
  s{<w:docDefaults>.*?</w:docDefaults>}{$dd}s or die "no docDefaults in default";
  while ($new =~ /(<w:style [^>]*w:styleId="([^"]+)".*?<\/w:style>)/gs) {
    my ($xml, $id) = ($1, $2);
    if (s{<w:style [^>]*w:styleId="\Q$id\E".*?</w:style>}{$xml}s) { }
    else { s{</w:styles>}{$xml\n</w:styles>}s }
  }
' "$W/word/styles.xml"
perl -0pi -e '
  s{<w:sectPr>.*?</w:sectPr>}{<w:sectPr><w:footerReference w:type="default" r:id="rIdFooter1" /><w:pgSz w:w="12240" w:h="15840" /><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0" /><w:pgNumType w:fmt="decimal" w:start="1" /></w:sectPr>}s or die "no sectPr";
' "$W/word/document.xml"
cp "$D/parts/footer1.xml" "$W/word/footer1.xml"
perl -0pi -e 's{(</Relationships>)}{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="rIdFooter1" Target="footer1.xml" />$1}s' "$W/word/_rels/document.xml.rels"
perl -0pi -e 's{(</Types>)}{<Override PartName="/word/footer1.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />$1}s' "$W/[Content_Types].xml"
for f in "$W/word/styles.xml" "$W/word/document.xml" "$W/word/footer1.xml" "$W/word/_rels/document.xml.rels" "$W/[Content_Types].xml"; do xmllint --noout "$f"; done
rm -f "$OUT"
(cd "$W" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
