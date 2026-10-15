# pages.awk: finds the pdf page of each search key (written by fiscr-amicus.lua, FISCR_KEYS) and prints the page map
# that fiscr-amicus.lua reads (FISCR_PAGES). Run by docx/pages.sh, which writes one text file per page in W.
#   key lines:  kind<TAB>id<TAB>mode<TAB>key
#     B  body start: the key is inside the page text (mode S)
#     M  marker: toc / toa / ident; the key starts a line of the page (mode L)
#     H  heading t<i>: starts a line of the page (mode L); the first page outside the TOC and TOA is used
#     A  authority: the key is inside the page text (mode S); every page outside the TOA is used
#   output lines:  B<TAB><TAB>page    H<TAB>t<i><TAB>page    A<TAB>key<TAB>p1,p2,...   ("?" when not found)
# Text is compared with all whitespace removed and in lower case (see norm in fiscr-amicus.lua).
function norm(s) { gsub(/[ \t\r\n\f-]+/, "", s); return tolower(s) }

BEGIN { FS = "\t"; nk = 0; np = N + 0 }
{
  nk++
  kind[nk] = $1; id[nk] = $2; mode[nk] = $3; key[nk] = $4
}
END {
  for (p = 1; p <= np; p++) {
    file = W "/" p ".txt"
    nl[p] = 0; pt[p] = ""
    while ((getline line < file) > 0) {
      n = norm(line)
      if (n != "") { nl[p]++; L[p, nl[p]] = n; pt[p] = pt[p] n }
    }
    close(file)
  }
  for (i = 1; i <= nk; i++) {
    first[i] = ""; all[i] = ""
    if (key[i] == "") continue
    for (p = 1; p <= np; p++) {
      hit = 0
      if (mode[i] == "L") {
        for (k = 1; k <= nl[p]; k++) if (index(L[p, k], key[i]) == 1) { hit = 1; break }
      } else {
        if (index(pt[p], key[i]) > 0) hit = 1
      }
      if (hit) {
        if (first[i] == "") first[i] = p
        all[i] = all[i] (all[i] == "" ? "" : ",") p
        hits[i, p] = 1
      }
    }
  }
  # the markers: where the TOC, the TOA, the identity section and the body begin
  for (i = 1; i <= nk; i++) {
    if (kind[i] == "B") body = first[i]
    if (kind[i] == "M" && id[i] == "toc") toc = first[i]
    if (kind[i] == "M" && id[i] == "toa") toa = first[i]
  }
  # the identity section is the first page after the TOA that starts with its heading (the TOC lists it too)
  for (i = 1; i <= nk; i++) {
    if (kind[i] != "M" || id[i] != "ident" || toa == "") continue
    for (p = toa + 1; p <= np; p++) if (hits[i, p]) { ident = p; break }
  }
  body_end = (ident != "") ? ident : body
  print "B\t\t" (body == "" ? "?" : body)
  for (i = 1; i <= nk; i++) {
    if (kind[i] == "H") {
      # a heading is not taken from the TOC or the TOA pages
      page = "?"
      for (p = 1; p <= np; p++) {
        if (toc != "" && toa != "" && p >= toc + 0 && p < toa + 0) continue
        if (hits[i, p]) { page = p; break }
      }
      print "H\t" id[i] "\t" page
    }
  }
  # authorities: the pages of their linked citations, outside the TOA (and the pages before the identity section
  # are kept: a citation there is counted, as typst counts it)
  # one line per authority id: the union of the pages of all its keys (one per linked citation text)
  for (i = 1; i <= nk; i++) {
    if (kind[i] != "A") continue
    if (!(id[i] in seen_id)) { seen_id[id[i]] = 1; order[++na] = id[i] }
    for (p = 1; p <= np; p++) {
      if (toa != "" && p >= toa + 0 && body_end != "" && p < body_end + 0) continue
      if (hits[i, p]) pg[id[i], p] = 1
    }
  }
  for (a = 1; a <= na; a++) {
    list = ""
    for (p = 1; p <= np; p++) if ((order[a], p) in pg) list = list (list == "" ? "" : ",") p
    if (list == "") list = "?"
    print "A\t" order[a] "\t" list
  }
}
