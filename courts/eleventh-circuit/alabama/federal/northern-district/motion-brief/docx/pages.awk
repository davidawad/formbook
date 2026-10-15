# pages.awk: the page numbers of the contents and the authorities, from the first pass (render.sh).
# Input: the keys file (B, H and L lines, written by alnd-motion-brief.lua), then one normalised text file per page
# of the first-pass PDF, in page order (lowercase letters and digits only, one line each).
# Output: "H<TAB>key<TAB>label" per heading and "A<TAB>key<TAB>labels" per authority (labels comma-joined).
# A label is the body page number: the body starts on the first page that holds the first body paragraph.
# A heading is found on the first page, from the previous heading's page on, that holds its text; an
# authority on every body page that holds the text of one of its links. A key that is not found stops
# the run (exit 1) rather than printing a guessed page.
FNR == NR {
  if ($1 == "B") { bkey = $2 }
  else if ($1 == "H") { hk[++nh] = $2 }
  else if ($1 == "L") { lk[++nl] = $2; ltext[nl] = $3 }
  next
}
{ pg[++np] = $0 }
# a match counts on the page where it starts, also when it runs on into the next page
function hit(s, p,   t, m) { t = pg[p] pg[p + 1]; m = index(t, s); return (m > 0 && m <= length(pg[p])) }
END {
  for (b = 1; b <= np; b++) if (hit(bkey, b)) { bs = b; break }
  if (bs == 0) { print "pages.awk: the body start was not found on any page" > "/dev/stderr"; exit 1 }
  prev = bs
  for (i = 1; i <= nh; i++) {
    found = 0
    for (p = prev; p <= np; p++) if (hit(hk[i], p)) { found = p; break }
    if (found == 0) { print "pages.awk: heading not found on a body page: " hk[i] > "/dev/stderr"; exit 1 }
    print "H\t" hk[i] "\t" (found - bs + 1)
    prev = found
  }
  for (i = 1; i <= nl; i++) {
    k = lk[i]
    if (!(k in order)) { order[k] = ++nk; korder[nk] = k }
    any = 0
    for (p = bs; p <= np; p++) {
      if (hit(ltext[i], p)) { on[k, p] = 1; any = 1 }
    }
    if (any == 0) { print "pages.awk: citation text not found on a body page: " ltext[i] > "/dev/stderr"; exit 1 }
  }
  for (j = 1; j <= nk; j++) {
    k = korder[j]
    list = ""
    for (p = bs; p <= np; p++) if ((k, p) in on) list = list (list == "" ? "" : ",") (p - bs + 1)
    print "A\t" k "\t" list
  }
}
