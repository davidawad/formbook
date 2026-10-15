#!/bin/sh
# Builds one sample with the SCOTUS cert-petition Word template (docs/EVAL-LOOP.md, "Engines").
# Pandoc writes the document with reference.docx and scotus.lua. Pass 1 is rendered by LibreOffice; the PDF gives the
# page of every heading and every cited authority (the needles scotus.lua wrote; the front matter is numbered i, ii ...,
# the body 1, 2 ...). Pass 2 writes the document again with those page labels in the tables of contents and authorities,
# and the footers of the sections (roman, arabic, none) are added to the package. Word may paginate slightly differently.
# Usage: sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
set -eu
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
D="$COURT/docx"
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
WORK=$(mktemp -d)
if [ -n "${FORMBOOK_KEEP:-}" ]; then echo "work: $WORK" >&2; else trap 'rm -rf "$WORK"' EXIT; fi

# add_parts <docx>: the footers the sections use (rIds of scotus.lua), and the final section, in place
add_parts() {
  X="$WORK/unz"
  rm -rf "$X"
  mkdir "$X"
  (cd "$X" && unzip -q "$1")
  page_footer() { # $1 = file, $2 = page number field (or none)
    if [ -n "$2" ]; then
      PN='<w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> PAGE </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>1</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r>'
    else
      PN=""
    fi
    cat > "$X/word/$1" <<XML
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:ftr xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/><w:ind w:firstLine="0"/><w:jc w:val="center"/></w:pPr>$PN</w:p></w:ftr>
XML
  }
  page_footer ftr-front.xml yes
  page_footer ftr-body.xml yes
  page_footer ftr-empty.xml ""
  perl -0pi -e '
    my $rels = join("", map { qq{<Relationship Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer" Id="$_->[0]" Target="$_->[1]" />} }
      (["rIdFtrFront", "ftr-front.xml"], ["rIdFtrBody", "ftr-body.xml"], ["rIdFtrEmpty", "ftr-empty.xml"]));
    s{(</Relationships>)}{$rels$1}s;
  ' "$X/word/_rels/document.xml.rels"
  perl -0pi -e '
    my $ov = join("", map { qq{<Override PartName="/word/$_" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml" />} }
      qw(ftr-front.xml ftr-body.xml ftr-empty.xml));
    s{(</Types>)}{$ov$1}s;
  ' "$X/[Content_Types].xml"
  # the final section (the certificate): no number, its own empty footer
  perl -0pi -e '
    my $cert = q{<w:sectPr><w:footerReference w:type="default" r:id="rIdFtrEmpty"/>} . q{<w:pgSz w:w="8820" w:h="13320"/><w:pgMar w:top="1530" w:right="1440" w:bottom="1530" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>} . q{<w:pgNumType w:fmt="decimal"/></w:sectPr>};
    s{<w:sectPr\b(?:(?!<w:sectPr\b).)*?</w:sectPr>(?=\s*</w:body>)}{$cert}s;
  ' "$X/word/document.xml"
  for f in "$X/word/_rels/document.xml.rels" "$X/[Content_Types].xml" "$X/word/document.xml" "$X/word/ftr-front.xml" "$X/word/ftr-body.xml" "$X/word/ftr-empty.xml"; do
    xmllint --noout "$f"
  done
  rm -f "$1"
  (cd "$X" && zip -X -q -r "$1" '[Content_Types].xml' _rels docProps word)
  rm -rf "$X"
}

# build <out.docx> <pages.tsv or empty>: pandoc with the reference and the filter, then the footers
build() {
  (cd "$COURT" && FORMBOOK_NEEDLES="$WORK/needles.tsv" FORMBOOK_PAGES="$2" pandoc --from markdown+smart --to docx \
    --reference-doc="$D/reference.docx" --lua-filter="$D/scotus.lua" "$SAMPLE" -o "$1") || exit 1
  add_parts "$1"
}

# Pass 1: placeholder page labels, then the PDF of it.
build "$WORK/pass1.docx" ""
mkdir "$WORK/pdf1"
"$SOFFICE" "-env:UserInstallation=file://$WORK/profile" --headless --convert-to pdf --outdir "$WORK/pdf1" "$WORK/pass1.docx" > "$WORK/soffice1.log" 2>&1 || {
  cat "$WORK/soffice1.log" >&2
  exit 1
}

# Pages (pdftotext, one record per page). Text is compared with letters and digits only, lower case.
# Page labels: front matter (before the body) roman from i on the Questions Presented page; body arabic from 1.
pdftotext "$WORK/pdf1/pass1.pdf" - | awk -v needles="$WORK/needles.tsv" '
function norm(s,   t) { t = tolower(s); gsub(/[^a-z0-9]/, "", t); return t }
function roman(n,   out, i, v, s) {
  split("1000 900 500 400 100 90 50 40 10 9 5 4 1", v, " ")
  split("m cm d cd c xc l xl x ix v iv i", s, " ")
  out = ""
  for (i = 1; i <= 13; i++) while (n >= v[i]) { out = out s[i]; n -= v[i] }
  return out
}
BEGIN { RS = "\f" }
{ pg[NR] = norm($0) }
function label(p) { return (p < bodystart) ? roman(p - 1) : (p - bodystart + 1) }
function find(text, from, to,   p) {
  for (p = from; p <= to; p++) if (index(pg[p], text) > 0) return p
  return 0
}
END {
  np = NR
  RS = "\n"
  bodystart = 0; certpage = 0
  while ((getline line < needles) > 0) {
    split(line, f, "\t")
    if (f[1] == "B") { bodystart = find(f[4], 2, np); if (!bodystart) { print "pages: body start not found" > "/dev/stderr"; exit 1 } }
    if (f[1] == "C") certpage = find(f[4], bodystart, np)
    if (f[1] == "H") { n++; hk[n] = f[2]; hf[n] = f[3]; ht[n] = f[4] }
    if (f[1] == "A") { m++; ak[m] = f[2]; at[m] = f[4] }
  }
  close(needles)
  cur = 2
  for (i = 1; i <= n; i++) {
    if (hf[i] == "B" && cur < bodystart) cur = bodystart
    p = find(ht[i], cur, np)
    if (!p) { print "pages: heading not found: " ht[i] > "/dev/stderr"; p = cur }
    cur = p
    print "H\t" hk[i] "\t" label(p)
  }
  last = certpage ? certpage - 1 : np
  for (j = 1; j <= m; j++) {
    for (p = bodystart; p <= last; p++) if (index(pg[p], at[j]) > 0) hit[ak[j], p] = 1
    keys[ak[j]] = 1
  }
  for (k in keys) {
    s = ""
    for (p = bodystart; p <= last; p++) if (hit[k, p]) s = s (s == "" ? "" : ", ") label(p)
    print "A\t" k "\t" s
  }
}' > "$WORK/pages.tsv"

# pass 2: the page labels in the tables, the same footers; this is the document
build "$OUT" "$WORK/pages.tsv"
echo "$OUT"
