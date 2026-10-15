# pagemap.awk: the TOC and TOA page numbers, read from the LibreOffice PDF of a first pass (docx/render.sh).
# Usage: awk -v man=<manifest> -f pagemap.awk page-1.txt page-2.txt ...   (pdftotext -layout, one file per page)
# Output: H<TAB>idx<TAB>folio (headings), S<TAB>name<TAB>folio (table of authorities, certificates),
#         T<TAB>key<TAB>pages (authorities; "passim" from 7 pages), and MISSING<TAB>... where a search failed.
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
    if (f[1] == "H") { nh++; hid[nh] = f[2]; hkey[nh] = f[4] }
    else if (f[1] == "S") { ns++; sname[ns] = f[2]; smode[ns] = f[3]; skey[ns] = f[4] }
    else if (f[1] == "T") {
      if (!(f[2] in tcount)) { tkeys++; tkey[tkeys] = f[2]; tcount[f[2]] = 0 }
      tcount[f[2]]++; ttext[f[2], tcount[f[2]]] = f[3]
    }
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
          if (pos > 0 && pos <= 12) { found = 1; hf = folio[p]; cur = p; break }
        }
      }
    }
    if (found) print "H\t" hid[h] "\t" hf
    else print "MISSING\theading\t" hid[h] "\t" hkey[h]
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
  for (t = 1; t <= tkeys; t++) {
    key = tkey[t]; np = 0
    for (p = 1; p <= pno; p++) {
      if (!body[p]) continue
      hit = 0
      for (x = 1; x <= tcount[key]; x++) if (ttext[key, x] != "" && starts_here(joined2[p], ttext[key, x], length(joined[p]))) hit = 1
      if (hit) { np++; pl2[np] = folio[p] }
    }
    if (np == 0) print "MISSING\tauthority\t" key
    else if (np >= 7) print "T\t" key "\tpassim"
    else { s = pl2[1]; for (i = 2; i <= np; i++) s = s ", " pl2[i]; print "T\t" key "\t" s }
  }
}
