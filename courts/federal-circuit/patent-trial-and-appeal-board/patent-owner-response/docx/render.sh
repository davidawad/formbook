#!/bin/sh
# Build one sample as a .docx (docs/EVAL-LOOP.md, "Engines"; tools/render-docx.sh calls this and converts the result).
#   sh docx/render.sh <court-dir> <sample.md> <out.docx>
# pandoc writes the document with ptab-patent-owner-response.lua on docx/reference.docx. The package then gets what
# the filter cannot write: the footers (roman for the contents; arabic from 1 for the body, with the running
# identification under the page number, as typst sets it) and the body's section properties. Every XML part is
# checked. The contents' page numbers come from the PDF: pass 1 writes the .docx with placeholders, LibreOffice
# converts it and the page of each heading is read from that PDF (pagemap below); pass 2 writes the numbers, and its
# PDF must give the same numbers again (otherwise the render fails).
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$(cd "$(dirname "$3")" && pwd)/$(basename "$3")
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
FILTER=$D/ptab-patent-owner-response.lua
RUNNING="Patent Owner Response"   # typst running-title
W=${RENDER_WORK:-$(mktemp -d)}   # RENDER_WORK=<dir>: keep the intermediate files there
[ -n "${RENDER_WORK:-}" ] || trap 'rm -rf "$W"' EXIT
NS='xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"'
# the footer sits 18.4 pt above the page edge (typst: 30 % footer descent below the 1 in margin's text area, two
# 16 pt lines); the cover and the contents keep the filter's 34.4 pt (one line)
PAGE='<w:pgSz w:w="12240" w:h="15840"/><w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="368" w:gutter="0"/>'
LINE='<w:spacing w:before="0" w:after="0" w:line="320" w:lineRule="exact"/><w:ind w:left="0" w:firstLine="0"/>'

# the patent number from the frontmatter; the running identification names it
PN=$(yq --front-matter=extract '.patent-number' "$COURT/$SAMPLE" | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/-\([0-9]\)/<\/w:t><w:noBreakHyphen\/><w:t xml:space="preserve">\1/g')
[ -n "$PN" ] || {
  echo "render.sh: $SAMPLE has no patent-number in its frontmatter" >&2
  exit 1
}
PAGENO='<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'

finish() { # <raw.docx> <out.docx>: footers, the body's section; a valid zip with well-formed XML
  X=$W/pkg
  rm -rf "$X" && mkdir "$X"
  (cd "$X" && unzip -q "$1")
  printf '%s\n' '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' \
    "<w:ftr $NS><w:p><w:pPr>$LINE<w:jc w:val=\"center\"/></w:pPr>$PAGENO</w:p></w:ftr>" > "$X/word/footer-roman.xml"
  printf '%s\n' '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' \
    "<w:ftr $NS><w:p><w:pPr>$LINE<w:jc w:val=\"center\"/></w:pPr>$PAGENO</w:p><w:p><w:pPr>$LINE<w:jc w:val=\"right\"/></w:pPr><w:r><w:t xml:space=\"preserve\">$RUNNING, $PN</w:t></w:r></w:p></w:ftr>" > "$X/word/footer-arabic.xml"
  perl -0pi -e 's#</Relationships>#<Relationship Id="rIdFooterRoman" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer-roman.xml"/><Relationship Id="rIdFooterArabic" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Target="footer-arabic.xml"/></Relationships>#' "$X/word/_rels/document.xml.rels"
  perl -0pi -e 's#</Types>#<Override PartName="/word/footer-roman.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/><Override PartName="/word/footer-arabic.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/></Types>#' "$X/[Content_Types].xml"
  # the body's section (the last one, certificates included): arabic numbers from 1
  BODY_SECT="<w:sectPr><w:footerReference w:type=\"default\" r:id=\"rIdFooterArabic\"/>$PAGE<w:pgNumType w:fmt=\"decimal\" w:start=\"1\"/></w:sectPr>"
  export BODY_SECT
  perl -0pi -e 'my $s = $ENV{BODY_SECT}; s{<w:sectPr(?:(?!<w:sectPr).)*?</w:sectPr>(\s*</w:body>)}{$s$1}s or s{(\s*</w:body>)}{$s$1}s' "$X/word/document.xml"
  for part in "$X"/word/*.xml "$X"/word/_rels/*.rels "$X/[Content_Types].xml"; do
    xmllint --noout "$part" || {
      echo "render.sh: ${part#$X/} is not well-formed XML" >&2
      exit 1
    }
  done
  rm -f "$2"
  (cd "$X" && zip -X -q "$2" '[Content_Types].xml' && zip -X -q -r "$2" _rels docProps word)
  unzip -tq "$2" > /dev/null || { echo "render.sh: $2 is not a valid zip" >&2; exit 1; }
}

build() { # <out.docx> <page map, or empty> <manifest>
  (cd "$COURT" && DOCX_PAGEMAP="$2" DOCX_MANIFEST="$3" pandoc --from markdown+smart-fancy_lists --to docx \
    --reference-doc="$D/reference.docx" --lua-filter="$FILTER" "$SAMPLE" -o "$W/raw.docx") >&2 || return 1
  finish "$W/raw.docx" "$1"
}

convert() { # <docx>: the LibreOffice PDF, in $W/pdf
  mkdir -p "$W/pdf"
  "$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W/pdf" "$1" > "$W/soffice.log" 2>&1 || {
    cat "$W/soffice.log" >&2
    return 1
  }
  echo "$W/pdf/$(basename "${1%.docx}").pdf"
}

# pagemap <pdf> <manifest>: H<TAB>index<TAB>folio for each heading of the manifest (H<TAB>index<TAB>first words),
# searched in document order on the body pages (those whose folio, the line above the running identification, is
# an arabic number) as the start of a line; fails if one is not found
pagemap() {
  P=$W/pages
  rm -rf "$P" && mkdir "$P"
  n=$(pdfinfo "$1" | awk '/^Pages:/ { print $2 }')
  i=1
  files=""
  while [ "$i" -le "$n" ]; do
    pdftotext -layout -f "$i" -l "$i" "$1" "$P/$i.txt"
    files="$files $P/$i.txt"
    i=$((i + 1))
  done
  # shellcheck disable=SC2086
  awk -v man="$2" '
    function norm(s) { gsub(/\302\240/, " ", s); s = tolower(s); gsub(/[ \t\r\f]+/, " ", s); sub(/^ /, "", s); sub(/ $/, "", s); return s }
    BEGIN { while ((getline l < man) > 0) { split(l, f, "\t"); nh++; hid[nh] = f[2]; hkey[nh] = norm(f[3]) } }
    FNR == 1 { pno++ }
    { t = norm($0); if (t != "") { nl[pno]++; L[pno, nl[pno]] = t } }
    END {
      for (p = 1; p <= pno; p++) { folio[p] = (nl[p] >= 2) ? L[p, nl[p] - 1] : ""; body[p] = (folio[p] ~ /^[0-9]+$/) }
      cp = 1; ck = 1
      for (h = 1; h <= nh; h++) {
        found = 0
        for (p = cp; p <= pno && !found; p++) {
          if (!body[p]) continue
          for (k = (p == cp ? ck : 1); k <= nl[p] - 2; k++)
            if (index(L[p, k], hkey[h]) == 1) { found = 1; cp = p; ck = k + 1; print "H\t" hid[h] "\t" folio[p]; break }
        }
        if (!found) print "MISSING\t" hid[h] "\t" hkey[h]
      }
    }' $files > "$P/map.txt"
  if grep -q '^MISSING' "$P/map.txt"; then
    grep '^MISSING' "$P/map.txt" | sed 's/^/render.sh: heading not found in the PDF: /' >&2
    return 1
  fi
  cat "$P/map.txt"
}

build "$W/p1.docx" "" "$W/man1.txt"
pagemap "$(convert "$W/p1.docx")" "$W/man1.txt" > "$W/map1.txt" || exit 1
build "$W/p2.docx" "$W/map1.txt" "$W/man2.txt"
pagemap "$(convert "$W/p2.docx")" "$W/man2.txt" > "$W/map2.txt" || exit 1
cmp -s "$W/map1.txt" "$W/map2.txt" || {
  echo "render.sh: the page numbers of the second pass differ from the first:" >&2
  diff "$W/map1.txt" "$W/map2.txt" >&2
  exit 1
}
cp "$W/p2.docx" "$OUT"
echo "$OUT"
