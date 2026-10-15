#!/bin/sh
# docx engine for the motion brief: sh docx/render.sh <court-dir> <sample.md> <out.docx>
# Three passes, because the table of contents and table of authorities carry page numbers:
#   1. the front matter alone (cover, contents, authorities) gives F, the number of front pages;
#   2. the whole brief, with blank page numbers, is laid out by LibreOffice; each heading and each authority
#      link is searched for on the body pages (page > F) of that PDF, and the body page is page - F;
#   3. the final .docx is written with those numbers (the layout is the same: only numbers change).
# The footer is a PAGE field in the reference; the front sections use lower roman, the body arabic from 1.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
SOFFICE=${SOFFICE:-soffice}
NBSP=$(printf '\302\240')

awk '/^\[\^[^]]+\]:/ && prev != "" { print "" } { print; prev = $0 }' "$COURT/$SAMPLE" > "$T/in.md"
filters=""
for f in "$D"/*.lua; do [ -e "$f" ] && filters="$filters --lua-filter=$f"; done

# build <out.docx> <front-only 0|1> <map file or ""> <needles file or "">
build() {
  # shellcheck disable=SC2086
  (cd "$COURT" && BRIEF_FRONT=$2 BRIEF_MAP=$3 BRIEF_NEEDLES=$4 pandoc --from markdown+smart --to docx \
    --reference-doc="$D/reference.docx" $filters "$T/in.md" -o "$T/raw.docx")
  X=$(mktemp -d "$T/x.XXXXXX")
  (cd "$X" && unzip -q "$T/raw.docx")
  RID=$(grep -o '<w:footerReference[^>]*' "$X/word/document.xml" | tail -1 | sed 's/.*r:id="\([^"]*\)".*/\1/')
  perl -0pi -e "s/RIDPLACE/$RID/g; s{<w:cols w:space=\"720\" />(\s*</w:sectPr>\s*</w:body>)}{<w:pgNumType w:fmt=\"decimal\" w:start=\"1\" /><w:cols w:space=\"720\" />\$1}s" "$X/word/document.xml"
  xmllint --noout "$X/word/document.xml"
  rm -f "$1"
  (cd "$X" && zip -X -q "$1" '[Content_Types].xml' && zip -X -q -r "$1" _rels docProps word)
}
convert_pdf() { # <docx> <outdir>
  timeout 300 "$SOFFICE" "-env:UserInstallation=file://$T/profile" --headless --convert-to pdf --outdir "$2" "$1" > "$2/soffice.log" 2>&1 || { cat "$2/soffice.log" >&2; exit 1; }
}

# pass 1: front matter only
mkdir -p "$T/a"
build "$T/a/front.docx" 1 "" ""
convert_pdf "$T/a/front.docx" "$T/a"
N=$(pdfinfo "$T/a/front.pdf" | awk '/^Pages:/{print $2}')
LAST=$(pdftotext -f "$N" -l "$N" "$T/a/front.pdf" - | tr -d " \n\f0-9")
F=$N
if [ -z "$LAST" ]; then F=$((N - 1)); fi
echo "render.sh: front matter pages F=$F" >&2

# pass 2: the whole brief without numbers; search the body pages
mkdir -p "$T/b"
build "$T/b/full.docx" 0 "" "$T/needles.txt"
convert_pdf "$T/b/full.docx" "$T/b"
NB=$(pdfinfo "$T/b/full.pdf" | awk '/^Pages:/{print $2}')
p=$((F + 1))
while [ "$p" -le "$NB" ]; do
  pdftotext -f "$p" -l "$p" "$T/b/full.pdf" - | tr '\n' ' ' | sed "s/$NBSP/ /g; s/  */ /g" > "$T/page-$((p - F)).txt"
  p=$((p + 1))
done
: > "$T/map.txt"
while IFS="$(printf '\t')" read -r kind id needle; do
  pages=""
  b=1
  while [ "$b" -le $((NB - F)) ]; do
    if grep -F -q -- "$needle" "$T/page-$b.txt"; then
      pages="${pages:+$pages, }$b"
      [ "$kind" = H ] && break
    fi
    b=$((b + 1))
  done
  [ -n "$pages" ] || { echo "render.sh: no page found for $kind $id: $needle" >&2; pages="0"; }
  printf '%s\t%s\t%s\n' "$kind" "$id" "$pages" >> "$T/map.txt"
done < "$T/needles.txt"

# pass 3: the final docx with the numbers
mkdir -p "$T/c"
build "$OUT" 0 "$T/map.txt" ""
echo "$OUT"
