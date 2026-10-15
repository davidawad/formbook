# Finds the printed page of each search needle in a rendered memorandum (docx/render.sh uses it; no Python).
# Input (FOOTERS: a file of the footer lines; NEEDLES: see below): pdftotext output on stdin (pages are separated by form feeds). Needles: a file of lines
#   "B<TAB>text" (the first body heading and paragraph: where the body starts) and "<k><TAB>text" (one per event,
#   in document order). Output: "<k><TAB><label>" per event, the body page number ("??" when not found).
# Text is compared with letters and digits only, lower case, so line breaks and punctuation cannot matter.
# The m-th event with the same needle is matched to the m-th occurrence of that needle after the body start.
# Run with LC_ALL=C: the match is on bytes of ASCII letters and digits only.
function norm(s) { s = tolower(s); gsub(/[^a-z0-9]/, "", s); return s }
function page_of(pos,   p) {
  for (p = 1; p <= NP; p++) if (PEND[p] >= pos) return p
  return NP
}
# the footer lines (page number, footer title, case line) are not part of the text being searched
function strip_page(s,   n, L, i, t, last, out) {
  n = split(s, L, "\n")
  last = 0
  for (i = 1; i <= n; i++) if (L[i] ~ /[^ \t\r]/) last = i
  out = ""
  for (i = 1; i <= n; i++) {
    t = norm(L[i])
    if (t == "" || t in FOOT) continue
    if (i >= last - 2 && (t ~ /^[0-9]+$/ || t ~ /^[ivxlc]+$/)) continue
    out = out t
  }
  return out
}
BEGIN {
  while ((getline fl < FOOTERS) > 0) FOOT[norm(fl)] = 1
  close(FOOTERS)
  while ((getline line < NEEDLES) > 0) {
    tab = index(line, "\t")
    key = substr(line, 1, tab - 1)
    txt = substr(line, tab + 1)
    if (key == "B") { bneedle = norm(txt) } else { nk++; ek[nk] = key; en[nk] = norm(txt) }
  }
  close(NEEDLES)
  RS = "\f"
}
{
  T = T strip_page($0)
  PEND[NR] = length(T)
}
END {
  NP = NR
  if (bneedle == "") { print "find-pages: no body start needle" > "/dev/stderr"; exit 1 }
  bpos = index(T, bneedle)
  if (bpos == 0) { print "find-pages: the body start is not in the rendered text" > "/dev/stderr"; exit 1 }
  bp = page_of(bpos)
  for (i = 1; i <= nk; i++) {
    x = en[i]
    cnt[x]++
    found = 0
    if (x != "") {
      m = 0
      pos = bpos
      while ((q = index(substr(T, pos), x)) > 0) {
        m++
        a = pos + q - 1
        if (m == cnt[x]) { found = a; break }
        pos = a + 1
      }
    }
    if (found) print ek[i] "\t" (page_of(found) - bp + 1)
    else print ek[i] "\t??"
  }
}
