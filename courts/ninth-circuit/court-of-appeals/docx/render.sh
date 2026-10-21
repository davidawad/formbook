#!/bin/sh
# Builds one sample with the ca9 Word template (docs/EVAL-LOOP.md, "Engines"; docs/DOCX.md). Pandoc writes the
# document with reference.docx and ca9.lua. The document is first rendered by LibreOffice; the page of every
# heading and every citation is looked up in that PDF (the needles ca9.lua wrote); the document is then written
# again with those pages in its tables, and its sections get their footers (none, roman, arabic, Add-n).
# Word may paginate slightly differently from LibreOffice (docs/DOCX.md, "Known limits").
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
D="$COURT/docx"
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
WORK=$(mktemp -d)
# FORMBOOK_KEEP=1 keeps the work directory (the needles, the pages, both passes) for debugging
if [ -n "${FORMBOOK_KEEP:-}" ]; then echo "work: $WORK" >&2; else trap 'rm -rf "$WORK"' EXIT; fi

# add_footers <docx>: the footers of the sections (the rIds ca9.lua uses) and the last section, in place
add_footers() {
  X="$WORK/unz"
  rm -rf "$X"
  mkdir "$X"
  (cd "$X" && unzip -q "$1")
  footer() { # $1 = file, $2 = the runs of the footer paragraph
    cat > "$X/word/$1" <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0"/><w:jc w:val="center"/></w:pPr>$2</w:p></w:ftr>
XML
  }
  PAGE='<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
  footer ftr-none.xml ''
  footer ftr-page.xml "$PAGE"
  footer ftr-add.xml "<w:r><w:t>Add-</w:t></w:r>$PAGE"
  # The last section (body and certificates, or the addendum) is the document's own sectPr: arabic from 1,
  # or Add-1 when the addendum ends the document (ca9.lua writes which into $WORK/final).
  if [ "$(cat "$WORK/final")" = addendum ]; then last=rIdFtrAdd; else last=rIdFtrPage; fi
  LAST="<w:sectPr><w:footerReference w:type=\"default\" r:id=\"$last\"/><w:pgSz w:w=\"12240\" w:h=\"15840\"/><w:pgMar w:top=\"1440\" w:right=\"1440\" w:bottom=\"1440\" w:left=\"1440\" w:header=\"720\" w:footer=\"576\" w:gutter=\"0\"/><w:pgNumType w:fmt=\"decimal\" w:start=\"1\"/></w:sectPr>" \
    perl -0pi -e 's{<w:sectPr>(?:(?!<w:sectPr>).)*</w:sectPr>\s*</w:body>}{$ENV{LAST}</w:body>}s or die "render.sh: no final sectPr\n"' "$X/word/document.xml"
  perl -0pi -e '
    my $rels = join("", map { qq{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="$_->[0]" Target="$_->[1]"/>} }
      (["rIdFtrNone", "ftr-none.xml"], ["rIdFtrPage", "ftr-page.xml"], ["rIdFtrAdd", "ftr-add.xml"]));
    s{(</Relationships>)}{$rels$1}s;
  ' "$X/word/_rels/document.xml.rels"
  perl -0pi -e '
    my $ov = join("", map { qq{<Override PartName="/word/$_" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"/>} }
      qw(ftr-none.xml ftr-page.xml ftr-add.xml));
    s{(</Types>)}{$ov$1}s;
  ' "$X/[Content_Types].xml"
  for f in "$X/word/document.xml" "$X/word/_rels/document.xml.rels" "$X/[Content_Types].xml" "$X/word/ftr-none.xml" "$X/word/ftr-page.xml" "$X/word/ftr-add.xml"; do
    xmllint --noout "$f"
  done
  rm -f "$1"
  # Reproducible archive: every part dated 2026-01-01 (pandoc's SOURCE_DATE_EPOCH), parts in a fixed order, no
  # directory entries; the review records the sha256 of this file
  find "$X" -type f -exec env TZ=UTC touch -t 202601010000.00 {} +
  (cd "$X" && find . -type f | sed 's|^\./||' | LC_ALL=C sort | TZ=UTC zip -X -D -q "$1" -@)
  rm -rf "$X"
}

# build <out.docx> <pages.tsv or empty>: pandoc with the reference and the filter; writes the needles
build() {
  (cd "$COURT" && FORMBOOK_NEEDLES="$WORK/needles.tsv" FORMBOOK_FINAL="$WORK/final" FORMBOOK_PAGES="$2" \
    pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" --lua-filter="$D/ca9.lua" \
    "$SAMPLE" -o "$1") || exit 1
  add_footers "$1"
}

# pdf <docx> <dir>: the LibreOffice PDF of a pass
pdf() {
  mkdir -p "$2"
  "$SOFFICE" "-env:UserInstallation=file://$WORK/profile" --headless --convert-to pdf --outdir "$2" "$1" > "$WORK/soffice.log" 2>&1 || {
    cat "$WORK/soffice.log" >&2
    exit 1
  }
}

# pages <pdf> <out.tsv>: the page of every needle. The text of every page (its page number dropped) is reduced to
# letters and digits, lower case, as ca9.lua reduces the needles, and the pages are joined into one string. The body
# needles (kind B: headings, citations, the generated sections) are found in document order, each from where the one
# before it was found, so a short citation ("Id.") is found after the text before it, not earlier on the page. A
# citation in a footnote (kind N) is searched from the start of the page the body has reached (footnotes are printed
# at the foot of the page, after the body text) and does not move the search on. A needle is the text plus what
# follows it; when that runs over a page break with footnotes between, the text alone is tried.
pages() {
  pdftotext "$1" - | awk -v needles="$WORK/needles.tsv" '
function norm(s,   t) { t = tolower(s); gsub(/[^a-z0-9]/, "", t); return t }
function roman(n,   out, i, v, sy) {
  split("1 4 5 9 10 40 50 90 100", v, " "); split("i iv v ix x xl l xc c", sy, " ")
  out = ""
  for (i = 9; i >= 1; i--) while (n >= v[i]) { out = out sy[i]; n -= v[i] }
  return out
}
function page_at(pos,   p) { for (p = np; p >= 1; p--) if (start[p] <= pos) return p; return 0 }
function find(s, from,   idx) { if (s == "") return 0; idx = index(substr(all, from), s); return idx > 0 ? from + idx - 1 : 0 }
function label_for(p) {
  if (p <= 0) return "??"
  if (add_p > 0 && p >= add_p) return "Add-" (p - add_p + 1)
  if (body_p > 0 && p >= body_p) return p - body_p + 1
  if (p >= 2) return roman(p - 1)
  return "cover"
}
BEGIN { RS = "\f" }
{
  n = split($0, L, "\n"); k = n
  while (k > 0 && L[k] ~ /^[ \t]*$/) k--
  if (k > 0 && L[k] ~ /^[ \t]*(Add-)?[ivxlcdm0-9]+[ \t]*$/) k--
  t = ""
  for (j = 1; j <= k; j++) t = t L[j] "\n"
  pg[NR] = norm(t)
}
END {
  np = NR
  all = ""
  for (p = 1; p <= np; p++) { start[p] = length(all) + 1; all = all pg[p] }
  RS = "\n"
  nn = 0
  while ((getline line < needles) > 0) {
    split(line, f, "\t"); nn++; nid[nn] = f[1]; nkind[nn] = f[2]; nnd[nn] = f[3]; nfb[nn] = f[4]
  }
  close(needles)
  cur = 1
  for (i = 1; i <= nn; i++) {
    from = cur
    if (nkind[i] == "N") from = start[page_at(cur)]
    pos = find(nnd[i], from)
    if (pos == 0) pos = find(nfb[i], from)
    page[i] = pos > 0 ? page_at(pos) : 0
    if (pos > 0 && nkind[i] == "B") cur = pos + 1
    if (nid[i] == "H:1") body_p = page[i]
    if (nid[i] == "S:add") add_p = page[i]
  }
  for (i = 1; i <= nn; i++) printf "%s\t%d\t%s\n", nid[i], page[i], label_for(page[i])
}' > "$2"
  if grep -q '??' "$2"; then
    echo "render.sh: some headings or citations were not found in the PDF:" >&2
    grep '??' "$2" >&2
    exit 1
  fi
}

# Pass 1 prints placeholders for the pages; each later pass prints the pages found in the PDF of the pass before it.
# A page list longer than its placeholder can move text, so the passes go on until the pages stop changing.
build "$WORK/pass1.docx" ""
pdf "$WORK/pass1.docx" "$WORK/pdf1"
pages "$WORK/pdf1/pass1.pdf" "$WORK/pages1.tsv"
n=1
while [ "$n" -lt 5 ]; do
  m=$((n + 1))
  build "$WORK/pass$m.docx" "$WORK/pages$n.tsv"
  pdf "$WORK/pass$m.docx" "$WORK/pdf$m"
  pages "$WORK/pdf$m/pass$m.pdf" "$WORK/pages$m.tsv"
  if cmp -s "$WORK/pages$n.tsv" "$WORK/pages$m.tsv"; then
    cp "$WORK/pass$m.docx" "$OUT"
    exit 0
  fi
  n=$m
done
echo "render.sh: the pages did not settle in 5 passes" >&2
exit 1
