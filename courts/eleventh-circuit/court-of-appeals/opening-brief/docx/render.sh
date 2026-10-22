#!/bin/sh
# Builds one sample with the ca11 Word template (docs/EVAL-LOOP.md, "Engines"). Pandoc writes the document with
# reference.docx and ca11.lua. The document is first rendered by LibreOffice; the pages of every heading and every
# citation are looked up in that PDF (the needles ca11.lua wrote); the document is then written again with those pages
# in its tables, and its sections get their footers (C-1, roman, arabic). Word may paginate slightly differently.
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
set -eu
ROOT=$(cd "$(dirname "$0")/../../../../.." && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
D="$COURT/docx"
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
WORK=$(mktemp -d)
# FORMBOOK_KEEP=1 keeps the work directory (the needles, the pages, both passes) for debugging
if [ -n "${FORMBOOK_KEEP:-}" ]; then echo "work: $WORK" >&2; else trap 'rm -rf "$WORK"' EXIT; fi

# add_footers <docx>: the footers of the sections (rIds used by ca11.lua), in place
add_footers() {
  X="$WORK/unz.$$"
  rm -rf "$X"
  mkdir "$X"
  (cd "$X" && unzip -q "$1")
  page_footer() { # $1 = file, $2 = text before the page number
    cat > "$X/word/$1" <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="400" w:lineRule="exact" /><w:jc w:val="center" /></w:pPr>$2<w:r><w:fldChar w:fldCharType="begin" /></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate" /></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end" /></w:r></w:p></w:ftr>
XML
  }
  cat > "$X/word/ftr-cover.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="400" w:lineRule="exact" /><w:jc w:val="center" /></w:pPr></w:p></w:ftr>
XML
  page_footer ftr-cip.xml '<w:r><w:t xml:space="preserve">C-</w:t></w:r>'
  page_footer ftr-front.xml ''
  page_footer ftr-body.xml ''
  perl -0pi -e '
    my $rels = join("", map { qq{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="$_->[0]" Target="$_->[1]" />} }
      (["rIdFtrCover", "ftr-cover.xml"], ["rIdFtrCip", "ftr-cip.xml"], ["rIdFtrFront", "ftr-front.xml"], ["rIdFtrBody", "ftr-body.xml"]));
    s{(</Relationships>)}{$rels$1}s;
  ' "$X/word/_rels/document.xml.rels"
  perl -0pi -e '
    my $ov = join("", map { qq{<Override PartName="/word/$_" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />} }
      qw(ftr-cover.xml ftr-cip.xml ftr-front.xml ftr-body.xml));
    s{(</Types>)}{$ov$1}s;
  ' "$X/[Content_Types].xml"
  for f in "$X/word/_rels/document.xml.rels" "$X/[Content_Types].xml" "$X/word/ftr-cover.xml" "$X/word/ftr-cip.xml" "$X/word/ftr-front.xml" "$X/word/ftr-body.xml"; do
    xmllint --noout "$f"
  done
  rm -f "$1"
  (cd "$X" && zip -X -q -r "$1" '[Content_Types].xml' _rels docProps word)
  rm -rf "$X"
}

# build <out.docx> <pages.tsv or empty>: pandoc with the reference and the filter; writes the needles
build() {
  (cd "$COURT" && FORMBOOK_NEEDLES="$WORK/needles.tsv" FORMBOOK_PAGES="$2" pandoc --from markdown+smart --to docx \
    --reference-doc="$D/reference.docx" --lua-filter="$D/ca11.lua" "$SAMPLE" -o "$1") || exit 1
  add_footers "$1"
}

# Pass 1: no pages yet (placeholders of the final width), then the PDF of it.
build "$WORK/pass1.docx" ""
mkdir "$WORK/pdf1"
"$SOFFICE" "-env:UserInstallation=file://$WORK/profile" --headless --convert-to pdf --outdir "$WORK/pdf1" "$WORK/pass1.docx" > "$WORK/soffice1.log" 2>&1 || {
  cat "$WORK/soffice1.log" >&2
  exit 1
}

# Pages: every needle (heading, citation, section start) is looked up in the PDF's text in document order. Text is
# compared with letters and digits only, lower case, on both sides; the PDF text keeps its line starts ("|"), which a
# needle may run over. Sections: searched page by page. Headings: their label and title at the start of a line, each
# after the one before. Citations (T): the link text and the words after it, each after the one before it in the
# text; in a footnote (N): from the start of the page the body has reached, moving nothing. A citation not found with
# its words is searched by its first words alone (it may run over a page end, where the footnotes come between).
pdftotext "$WORK/pdf1/pass1.pdf" - | awk -v needles="$WORK/needles.tsv" '
function norm(s,   t) { t = tolower(s); gsub(/\n/, "|", t); gsub(/[^a-z0-9|]/, "", t); return t }
function flat(s,   t) { t = s; gsub(/\|/, "", t); return t }
# a needle may run over the break between two pages: it is found on the page where it starts
function find(s, from,   p, j, idx) {
  for (p = from; p <= np; p++) {
    j = flat(pg[p]) flat(pg[p + 1]); idx = index(j, s)
    if (idx > 0 && idx <= length(flat(pg[p]))) return p
  }
  return 0
}
# the position of needle s in the whole text from position `from` (a line start before it when `bol`), or 0; the
# match length in MLEN
function at(s, from, bol,   pat, i, r) {
  pat = bol ? "\\|" : ""
  for (i = 1; i <= length(s); i++) pat = pat (i > 1 ? "\\|*" : "") substr(s, i, 1)
  r = match(substr(all, from), pat)
  if (r == 0) return 0
  MLEN = RLENGTH
  return from + RSTART - 1 + (bol ? 1 : 0)
}
function pageof(pos,   p) { for (p = 1; p <= np; p++) if (pos < st[p + 1]) return p; return 0 }
function roman(n,   out, i, v, sy) {
  split("1 4 5 9 10 40 50 90 100", v, " "); split("I IV V IX X XL L XC C", sy, " ")
  out = ""
  for (i = 9; i >= 1; i--) while (n >= v[i]) { out = out sy[i]; n -= v[i] }
  return out
}
function label_for(p) {
  if (p <= 0) return "??"
  if (body_p > 0 && p >= body_p) return sprintf("%d", p - body_p + 1)
  if (front_p > 0 && p >= front_p) return tolower(roman(p - front_p + 1))
  if (cip_p > 0 && p >= cip_p) return "C-" sprintf("%d", p - cip_p + 1)
  return "cover"
}
BEGIN { RS = "\f" }
# the text of a page without its page number (the last line, when it is only a number or a numeral)
{
  n = split($0, L, "\n"); k = n
  while (k > 0 && L[k] ~ /^[ \t]*$/) k--
  if (k > 0 && L[k] ~ /^[ \t]*(C-)?[ivxlcdmIVXLCDM0-9]+[ \t]*$/) k--
  t = "\n"
  for (j = 1; j <= k; j++) t = t L[j] "\n"
  pg[NR] = norm(t)
}
END {
  np = NR
  all = ""
  for (p = 1; p <= np; p++) { st[p] = length(all) + 1; all = all pg[p] }
  st[np + 1] = length(all) + 1
  RS = "\n"
  nn = 0
  while ((getline line < needles) > 0) {
    split(line, f, "\t"); nn++; nid[nn] = f[1]; nkind[nn] = f[2]; nnd[nn] = f[3]; nshort[nn] = f[4]
  }
  close(needles)
  cur = 1
  for (i = 1; i <= nn; i++) if (nkind[i] == "S") {
    p = find(nnd[i], cur); page[nid[i]] = p
    if (p > 0) cur = p
  }
  cip_p = page["S:cip"] + 0; body_p = page["S:body"] + 0
  front_p = page["S:oral"] > 0 ? page["S:oral"] + 0 : page["S:toc"] + 0
  pos = st[body_p > 0 ? body_p : 1]
  for (i = 1; i <= nn; i++) if (nkind[i] == "H") {
    q = at(nnd[i], pos - 1 > 0 ? pos - 1 : 1, 1)
    if (q > 0) { page[nid[i]] = pageof(q); pos = q + MLEN - 1 }
  }
  pos = st[body_p > 0 ? body_p : 1]
  for (i = 1; i <= nn; i++) if (nkind[i] == "T" || nkind[i] == "N") {
    from = nkind[i] == "N" ? st[pageof(pos)] : pos
    q = at(nnd[i], from, 0)
    if (q == 0 && nshort[i] != "") q = at(nshort[i], from, 0)
    if (q > 0) { page[nid[i]] = pageof(q); if (nkind[i] == "T") pos = q + 1 }
  }
  for (i = 1; i <= nn; i++) printf "%s\t%d\t%s\n", nid[i], page[nid[i]] + 0, label_for(page[nid[i]] + 0)
}' > "$WORK/pages.tsv"

if grep -q '??' "$WORK/pages.tsv"; then
  echo "render.sh: some headings or citations were not found in the PDF:" >&2
  grep '??' "$WORK/pages.tsv" >&2
fi

# Pass 2: the tables with their pages.
build "$WORK/pass2.docx" "$WORK/pages.tsv"
cp "$WORK/pass2.docx" "$OUT"
echo "$OUT"
