# pagemap.awk: the TOC and TOA page numbers, read from the LibreOffice PDF of a first pass (docx/render.sh).
# Usage: awk -v man=<manifest> -f pagemap.awk page-1.txt page-2.txt ...   (pdftotext -layout, one file per page)
# Output: H<TAB>idx<TAB>folio (headings), E<TAB>idx<TAB>folio (a heading whose next block starts on the next page), S<TAB>name<TAB>folio (table of authorities, certificates),
#         T<TAB>key<TAB>pages (authorities, from the C needles of the manifest; "passim" from 7 pages), and MISSING<TAB>... where a search failed.
# A page belongs to the body when its last text line is an arabic folio; the front matter has roman folios.
# true when text t occurs in s starting at or before position last (so it begins on this page)
function starts_here(s, t, last,    start, pos, abs) {
  start = 1
  while ((pos = index(substr(s, start), t)) > 0) {
    abs = start + pos - 1
    if (abs <= last) return 1
    start = abs + 1
  }
  return 0
}
function norm(s) {
  gsub(/\302\240/, " ", s)   # no-break spaces, as the PDF text has them or not
  s = tolower(s); gsub(/[ \t\r\f]+/, " ", s); sub(/^ /, "", s); sub(/ $/, "", s); return s
}
BEGIN {
  while ((getline line < man) > 0) {
    n = split(line, f, "\t")
    if (f[1] == "H") { nh++; hid[nh] = f[2]; hkey[nh] = f[4]; hnext[nh] = f[5] }
    else if (f[1] == "S") { ns++; sname[ns] = f[2]; smode[ns] = f[3]; skey[ns] = f[4] }
    else if (f[1] == "C") { nc++; ckey[nc] = f[2]; ckind[nc] = f[3]; ctext[nc] = f[4] }
  }
  close(man); pno = 0
}
FNR == 1 { pno++; nl[pno] = 0 }
{ nl[pno]++; L[pno, nl[pno]] = $0 }
END {
  for (p = 1; p <= pno; p++) {
    folio[p] = ""; joined[p] = " "
    for (k = nl[p]; k >= 1; k--) { t = norm(L[p, k]); if (t != "") { folio[p] = t; break } }
    for (k = 1; k <= nl[p]; k++) { t = norm(L[p, k]); if (t != "") joined[p] = joined[p] t " " }
    body[p] = (folio[p] ~ /^[0-9]+$/)
    roman[p] = (folio[p] ~ /^[ivxlc]+$/)
  }
  cur = 1
  for (h = 1; h <= nh; h++) {
    found = 0
    if (hkey[h] != "") {
      for (p = cur; p <= pno && !found; p++) {
        if (!body[p]) continue
        for (k = 1; k <= nl[p]; k++) {
          t = norm(L[p, k]); pos = index(t, hkey[h])
          if (pos == 1) { found = 1; hf = folio[p]; cur = p; hp = p; hk = k; break }
        }
      }
    }
    if (!found) { print "MISSING\theading\t" hid[h] "\t" hkey[h]; continue }
    print "H\t" hid[h] "\t" hf
    # a heading that ends its page (the first words of the block after it are not on the page below it): typst would
    # have moved it to the next page with what follows (a sticky heading), so docx/render.sh breaks the page before it
    if (hnext[h] != "") {
      after = 0
      for (j = hk + 1; j <= nl[hp] && !after; j++) if (index(norm(L[hp, j]), hnext[h]) > 0) after = 1
      if (!after) print "E\t" hid[h] "\t" hf
    }
  }
  for (s = 1; s <= ns; s++) {
    found = 0
    for (p = 1; p <= pno && !found; p++) {
      if (smode[s] == "roman" && !roman[p]) continue
      if (smode[s] == "body" && !body[p]) continue
      for (k = 1; k <= nl[p]; k++) {
        t = norm(L[p, k])
        if (smode[s] == "roman") { if (t == skey[s]) { found = 1; sf = folio[p]; break } }
        else if (index(t, skey[s]) == 1) { found = 1; sf = folio[p]; break }
      }
    }
    if (found) print "S\t" sname[s] "\t" sf
    else print "MISSING\tsection\t" sname[s]
  }
  for (p = 1; p <= pno; p++) {
    joined2[p] = joined[p]
    if (p < pno) joined2[p] = joined[p] substr(joined[p + 1], 1, 400)   # a citation may run over the page end
  }
  # citations, in document order: a body needle (B) is searched from where the last one was found and moves the
  # search on; a footnote needle (N) is searched from the start of the page the body has reached
  cp = 1; cpos = 1
  # (a needle that runs over a page end is not found whole: the folio and the footnotes come between its halves;
  # then its first two words are searched instead)
  for (c = 1; c <= nc; c++) {
    found = 0
    for (try = 1; try <= 2 && !found; try++) {
    needle = ctext[c]
    if (try == 2) { split(ctext[c], w, " "); needle = w[1] " " w[2] }
    for (p = cp; p <= pno && !found; p++) {
      if (!body[p]) continue
      start = (ckind[c] == "B" && p == cp) ? cpos : 1
      pos = index(substr(joined2[p], start), needle)
      if (pos == 0) continue
      abs = start + pos - 1
      if (abs > length(joined[p])) continue   # it begins on the next page
      found = 1; cf = folio[p]
      if (ckind[c] == "B") { cp = p; cpos = abs + 1 }
    }
    }
    key = ckey[c]
    if (!found) { print "MISSING\tcitation\t" key "\t" ctext[c]; continue }
    if (!(key in npg)) { nk++; korder[nk] = key; npg[key] = 0 }
    dup = 0
    for (i = 1; i <= npg[key]; i++) if (pg[key, i] == cf) dup = 1
    if (!dup) { npg[key]++; pg[key, npg[key]] = cf }
  }
  for (k = 1; k <= nk; k++) {
    key = korder[k]
    if (npg[key] >= 7) { print "T\t" key "\tpassim"; continue }
    s = pg[key, 1]; for (i = 2; i <= npg[key]; i++) s = s ", " pg[key, i]
    print "T\t" key "\t" s
  }
}
