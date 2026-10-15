#!/bin/sh
# Owns the .docx build for this doc type (tools/render-docx.sh calls it when it exists; see ../../../../../../../docs/DOCX.md).
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# Pass 1: pandoc writes the document with reference.docx and prd-motion-brief.lua; the section breaks carry the
#   placeholder RIDFOOTER, replaced by the relationship id that pandoc gave footer1.xml (the page-number footer).
# Pass 2: the table-of-contents page numbers are cached in the PAGEREF fields. The page of each heading is found by
#   converting pass 1 with LibreOffice (SOFFICE, default soffice) and reading its text; body pages count from the page
#   after the table of contents. Word shows these cached numbers until it updates fields; LibreOffice computes them.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo soffice)}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
(cd "$COURT" && PRD_TOC_MAP="$T/toc.map" pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/prd-motion-brief.lua" "$SAMPLE" -o "$T/out.docx")
mkdir "$T/x"
(cd "$T/x" && unzip -q "$T/out.docx")
RID=$(perl -0ne 'for (/<Relationship [^>]*>/g) { print $1 if /Target="footer1\.xml"/ && /Id="([^"]+)"/ }' "$T/x/word/_rels/document.xml.rels" | head -1)
[ -n "$RID" ] || { echo "render.sh: footer1.xml has no relationship in the output" >&2; exit 1; }
PRD_RID=$RID perl -0pi -e 's/RIDFOOTER/$ENV{PRD_RID}/g' "$T/x/word/document.xml"

# pass 2: page of each table-of-contents heading
mkdir "$T/p1"
(cd "$T/x" && zip -X -q -r "$T/p1/pass1.docx" '[Content_Types].xml' _rels docProps word)
WORK="$T/lo"
"$SOFFICE" "-env:UserInstallation=file://$WORK/profile" --headless --convert-to pdf --outdir "$T/p1" "$T/p1/pass1.docx" > "$T/p1/soffice.log" 2>&1 || "$SOFFICE" "-env:UserInstallation=file://$WORK/profile" --headless --convert-to pdf --outdir "$T/p1" "$T/p1/pass1.docx" > "$T/p1/soffice.log" 2>&1 || {
  cat "$T/p1/soffice.log" >&2
  echo "render.sh: LibreOffice could not convert pass 1 (page numbers of the table of contents)" >&2
  exit 1
}
PDF="$T/p1/pass1.pdf"
NP=$(pdfinfo "$PDF" | awk '/^Pages:/ {print $2}')
page_text() { pdftotext -f "$1" -l "$1" -layout "$PDF" - | tr '\n' ' ' | tr -s ' ' | tr '[:lower:]' '[:upper:]'; }
LAST_TOC=1
p=1
while [ "$p" -le "$NP" ]; do
  case $(page_text "$p") in *"TABLE OF CONTENTS"*) LAST_TOC=$p ;; esac
  p=$((p + 1))
done
BODY0=$((LAST_TOC + 1))
: > "$T/pages.map"
CUR=$BODY0
while IFS="$(printf '\t')" read -r id text; do
  key=$(printf '%s' "$text" | tr '[:lower:]' '[:upper:]' | cut -c1-25)
  found=""
  p=$CUR
  while [ "$p" -le "$NP" ]; do
    case $(page_text "$p") in *"$key"*) found=$p; break ;; esac
    p=$((p + 1))
  done
  [ -n "$found" ] || { echo "render.sh: heading not found in the PDF: $text" >&2; exit 1; }
  CUR=$found
  printf '%s\t%s\n' "$id" "$((found - BODY0 + 1))" >> "$T/pages.map"
done < "$T/toc.map"
PRD_PAGES="$T/pages.map" perl -0pi -e '
  open my $fh, "<", $ENV{PRD_PAGES} or die "pages.map: $!";
  my %n;
  local $/ = "\n";
  for my $line (<$fh>) { chomp $line; my ($id, $pg) = split /\t/, $line; $n{$id} = $pg }
  s{(PAGEREF (sec\d+) \\h </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>)\d+(</w:t>)}{ exists $n{$2} ? $1 . $n{$2} . $3 : die "no page for $2" }ge;
' "$T/x/word/document.xml"
xmllint --noout "$T/x/word/document.xml"
rm -f "$OUT"
(cd "$T/x" && zip -X -q -r "$OUT" '[Content_Types].xml' _rels docProps word)
echo "$OUT"
