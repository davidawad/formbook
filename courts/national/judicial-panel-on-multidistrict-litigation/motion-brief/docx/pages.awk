# docx/pages.awk: where each search item of the JPML motion-brief lands in a rendered PDF (docx/render.sh).
# Input (stdin): the text of the PDF from pdftotext, one record per page (pages are separated by form feeds).
# NEED (-v): the search list written by docx/jpml.lua, one item per line: "n<TAB>kind<TAB>needle", in document order.
# Each needle is normalized (lower case, letters and digits only), so line breaks and punctuation never matter, and
# is searched for at or after the end of the previous hit, in reading order. Output: "n<TAB>label" where label is the
# printed body page (the page of the item of kind B, the first body paragraph, is body page 1). Exit 1 on a miss.
function norm(s) { s = tolower(s); gsub(/[^a-z0-9]/, "", s); return s }
function pageof(pos,   p) { for (p = 1; p <= NR; p++) if (pend[p] >= pos) return p; return NR }
BEGIN {
  nn = 0
  while ((getline line < NEED) > 0) {
    split(line, f, "\t")
    nn++; num[nn] = f[1]; kind[nn] = f[2]; nd[nn] = norm(f[3])
  }
  close(NEED)
  RS = "\f"
  if (nn == 0) { print "pages.awk: empty search list " NEED > "/dev/stderr"; exit 1 }
}
{ text = text norm($0); pend[NR] = length(text) }
END {
  cur = 1; bodyPage = 0
  for (i = 1; i <= nn; i++) {
    if (nd[i] == "") { print "pages.awk: empty needle for item " num[i] > "/dev/stderr"; exit 1 }
    k = index(substr(text, cur), nd[i])
    if (k == 0) {
      print "pages.awk: item " num[i] " (" kind[i] ") not found in the PDF after the previous hit: " nd[i] > "/dev/stderr"
      exit 1
    }
    pos = cur + k - 1
    pg[i] = pageof(pos)
    cur = pos + length(nd[i])
    if (kind[i] == "B") bodyPage = pg[i]
  }
  if (bodyPage == 0) { print "pages.awk: no body item (kind B) in the search list" > "/dev/stderr"; exit 1 }
  for (i = 1; i <= nn; i++) print num[i] "\t" (pg[i] - bodyPage + 1)
}
