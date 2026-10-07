# gate0.awk: Gate 0 CONTENT. Does every block of the markdown appear in the PDF, in order, intact?
#
# Usage: LC_ALL=en_US.UTF-8 gawk -v out=PREFIX -v footer_top=720 -f norm.awk -f gate0.awk runs.tsv blocks.tsv
#   runs.tsv    from pdf-runs.awk   (PDF text runs: page, geometry, italic flag, text)
#   blocks.tsv  from md-blocks.awk  (the markdown, one block per record)
#
# Method. Both sides are reduced to the same normal form (norm.awk: lower case, straight quotes,
# ligatures expanded, ALL whitespace removed) so line breaks and spacing can never matter, but a missing
# or altered character always does. Footer page numbers are dropped by position. Each footnote is first
# found in the PDF on its own (its marker number plus its text) and then cut out of the stream: it sits at
# the page foot, in the middle of a paragraph that continues on the next page. Every remaining non-heading
# block must then occur, whole and contiguous, after the previous one: "in order, nothing dropped".
# Headings are placed just before the block that follows them, so a table of contents earlier in the
# PDF can never stand in for the real heading. Nothing is averaged: every missing block is reported with
# the exact place where the text stops matching.
#
# Writes PREFIX.report (findings), .metrics (key=value), .tags (runs.tsv row -> block kind),
# .heads (every heading: level, expected label, label ok, page, text), .links (authority key -> page).

# Prepare a markdown block: returns its normal form T and fills TI[i] (italic flag per character),
# WS/WT (where each markdown word starts, for naming the first lost word), the link list lk/lkoff and the
# footnote-reference list refkey/refpos. A footnote reference becomes the footnote's number, because that
# is what the PDF prints at that spot.
function prep(raw,    i, n, c, ital, t, nc, k, key, wl) {
  T = ""; ital = 0; nlinks = 0; nrefs = 0; delete TI; delete WS; delete WT; nw = 0
  n = length(raw); wl = 0
  for (i = 1; i <= n; i++) {
    c = substr(raw, i, 1)
    if (c == "\002") { ital = 1; continue }
    if (c == "\003") { ital = 0; continue }
    if (c == "\004") { k = index(substr(raw, i), "\005"); key = substr(raw, i + 1, k - 2); i += k - 1; lk[++nlinks] = key; lkoff[nlinks] = length(T) + 1; continue }
    if (c == "\006") continue
    if (c == "\007") {
      k = index(substr(raw, i), "\010"); key = substr(raw, i + 1, k - 2); i += k - 1
      if (!(key in fnnum)) fnnum[key] = ++fncount
      nrefs++; refpos[nrefs] = length(T) + 1; refkey[nrefs] = key
      t = fnnum[key] ""; for (k = 1; k <= length(t); k++) { T = T substr(t, k, 1); TI[length(T)] = 0 }
      continue
    }
    if (c ~ /[ \t]/) { wl = 0; continue }
    nc = norm1(c)
    if (wl == 0) WS[++nw] = length(T) + 1
    wl++; WT[nw] = WT[nw] c
    for (k = 1; k <= length(nc); k++) { T = T substr(nc, k, 1); TI[length(T)] = ital }
  }
  return T
}

function runat(p,    lo, hi, mid) {            # index of the run holding offset p of the original stream S
  lo = 1; hi = nruns
  while (lo < hi) { mid = int((lo + hi + 1) / 2); if (RBEG[mid] <= p) lo = mid; else hi = mid - 1 }
  return lo
}
function pageat(p) { return page[RROW[runat(p)]] }   # physical page of offset p of S

function wordat(off,    k, best) {              # the markdown word that contains character offset off
  best = 1
  for (k = 1; k <= nw; k++) if (WS[k] <= off) best = k
  return WT[best]
}

# last occurrence of t in S2 that lies wholly inside [from, lim] (0 if none)
function last_in(t, from, lim,    found, q, base) {
  found = 0; base = from
  while (base <= lim && (q = index(substr(S2, base, lim - base + 1), t)) > 0) { found = base + q - 1; base = found + 1 }
  return found
}

# longest prefix of t found anywhere in S2 at/after `from`
function longest_prefix(t, from,    lo, hi, mid) {
  lo = 0; hi = length(t)
  while (lo < hi) { mid = int((lo + hi + 1) / 2); if (index(substr(S2, from), substr(t, 1, mid)) > 0) lo = mid; else hi = mid - 1 }
  return lo
}

# Everything that follows from block b being found at offset pos of S2.
function settle(b, pos,    t, endp, r, r1, r2, k, bad, badw, w2, nr, nl, kind, lab, lp, labok, txt, refp, rp) {
  t = prep(braw[b]); endp = pos + length(t) - 1
  r1 = runat(M2[pos]); r2 = runat(M2[endp])
  kind = (bk[b] == "H" && blv[b] ~ /c/) ? "Hc" : bk[b]
  for (r = r1; r <= r2; r++) if (!(r in kindof)) kindof[r] = kind
  if (!bodyfirst) bodyfirst = page[RROW[r1]]
  bodylast = page[RROW[r2]]
  nl = nlinks; nr = nrefs
  for (k = 1; k <= nl; k++) printf "%s\t%d\n", lk[k], pageat(M2[pos + lkoff[k] - 1]) > lkf       # authority citations
  for (k = 1; k <= nr; k++) {                                                                   # footnote on its reference's page
    refp = pos + refpos[k] - 2; rp = pageat(M2[refp])
    if (refkey[k] in fnpage && fnpage[refkey[k]] != rp) { printf "FAIL footnote %s is on page %d but its reference is on page %d\n", refkey[k], fnpage[refkey[k]], rp >> rep; fnmiss++ }
  }
  if (bk[b] == "H") {                                                                           # heading label and page
    lab = norm1(blab[b]); lp = pos - length(lab)
    labok = (lab == "" || (lp >= 1 && substr(S2, lp, length(lab)) == lab)) ? 1 : 0
    txt = braw[b]; gsub(/\004[^\005]*\005/, "", txt); gsub(/[\002-\010]/, "", txt)
    printf "%s\t%s\t%d\t%d\t%s\n", blv[b], blab[b], labok, page[RROW[r1]], txt > hd
  }
  bad = 0; badw = ""                                                                            # italics
  for (k = 1; k <= length(t); k++) if (TI[k] && !SI[M2[pos + k - 1]]) {
    bad++
    if (length(badw) < 80) { for (w2 = nw; w2 >= 1; w2--) if (WS[w2] <= k) break; if (index(badw, WT[w2]) == 0) badw = badw (badw == "" ? "" : " ") WT[w2] }
  }
  if (bad) { nital++; printf "FAIL italic: block %d has %d italic characters rendered roman, starting at: %s\n", b, bad, badw >> rep }
}

function report_missing(b, from,    t, lo, pq) {
  t = prep(braw[b]); missing++
  lo = longest_prefix(t, from); pq = index(substr(S2, from), substr(t, 1, lo > 0 ? lo : 1))
  printf "FAIL %s block %d is missing or altered in the PDF. Markdown: \"%.70s\". The text matches for %d of %d characters, then the markdown has \"%s\" where the PDF has \"%.30s\"\n",
    bk[b], b, braw[b], lo, length(t), substr(t, lo + 1, 25), substr(S2, from + pq - 1 + lo, 30) >> rep
}

BEGIN { FS = "\t"; nruns = 0; S = ""; fncount = 0 }

# ---- file 1: PDF runs -------------------------------------------------------
FILENAME == ARGV[1] {
  rr++
  page[rr] = $1
  if ($2 >= footer_top) next                       # page numbers live in the bottom margin
  t = norm1($7)
  if (t == "") next
  nruns++
  RBEG[nruns] = length(S) + 1; RROW[nruns] = rr
  S = S t
  for (k = RBEG[nruns]; k <= length(S); k++) SI[k] = $6
  next
}

# ---- file 2: markdown blocks ------------------------------------------------
FILENAME == ARGV[2] { nb++; bk[nb] = $1; blv[nb] = $2; blab[nb] = $3; braw[nb] = $4; next }

END {
  rep = out ".report"; met = out ".metrics"; tag = out ".tags"; hd = out ".heads"; lkf = out ".links"
  printf "" > rep; printf "" > tag; printf "" > hd; printf "" > lkf

  # ---- footnotes: numbers follow the order of references in the body ----
  for (b = 1; b <= nb; b++) if (bk[b] != "F") prep(braw[b])
  nfn = 0; fnmiss = 0
  for (b = 1; b <= nb; b++) if (bk[b] == "F") {
    key = blv[b]; nfn++
    ftxt = prep(braw[b])
    if (!(key in fnnum)) { print "NOTE footnote [^" key "] is defined but never referenced" >> rep; continue }
    want = fnnum[key] ftxt
    p = index(S, want)
    if (p == 0) {
      fnmiss++
      lo = 0; hi = length(want)
      while (lo < hi) { mid = int((lo + hi + 1) / 2); if (index(S, substr(want, 1, mid)) > 0) lo = mid; else hi = mid - 1 }
      printf "FAIL footnote %s (marker %d) is not in the PDF in full: the text stops matching after %d of %d characters, at the markdown word \"%s\"\n", key, fnnum[key], lo, length(want), wordat(lo - length(fnnum[key] "")) >> rep
      continue
    }
    for (k = p; k < p + length(want); k++) del[k] = 1
    fnpage[key] = pageat(p)
    for (k = 1; k <= nlinks; k++) printf "%s\t%d\n", lk[k], pageat(p + length(fnnum[key] "") + lkoff[k] - 1) > lkf
    for (r = runat(p); r <= runat(p + length(want) - 1); r++) kindof[r] = "F"
  }

  # ---- the PDF stream without footnotes ----
  S2 = ""; n2 = 0
  for (k = 1; k <= length(S); k++) if (!(k in del)) { S2 = S2 substr(S, k, 1); M2[++n2] = k }

  # ---- body blocks, in order ----
  cursor = 1; npend = 0; missing = 0; nital = 0; nblocks = 0
  for (b = 1; b <= nb; b++) {
    if (bk[b] == "F") continue
    nblocks++
    if (bk[b] == "H") { pend[++npend] = b; continue }
    t = prep(braw[b])
    q = index(substr(S2, cursor), t)
    if (q == 0) {
      report_missing(b, cursor)
      for (k = 1; k <= npend; k++) {                                     # place the headings that preceded it
        ht = prep(braw[pend[k]]); q2 = index(substr(S2, cursor), ht)
        if (q2 == 0) { report_missing(pend[k], cursor); continue }
        settle(pend[k], cursor + q2 - 1); cursor = cursor + q2 - 1 + length(ht)
      }
      npend = 0
      continue
    }
    pos = cursor + q - 1
    lim = pos - 1
    for (k = npend; k >= 1; k--) {                                       # headings sit just before this block
      ht = prep(braw[pend[k]]); hq = last_in(ht, cursor, lim)
      if (hq == 0) { report_missing(pend[k], cursor); continue }
      settle(pend[k], hq); lim = hq - 1
    }
    npend = 0
    settle(b, pos)
    cursor = pos + length(t)
  }
  for (k = 1; k <= npend; k++) {                                         # headings with nothing after them
    ht = prep(braw[pend[k]]); q = index(substr(S2, cursor), ht)
    if (q == 0) { report_missing(pend[k], cursor); continue }
    settle(pend[k], cursor + q - 1); cursor = cursor + q - 1 + length(ht)
  }

  for (r in kindof) printf "%d\t%s\n", RROW[r], kindof[r] > tag
  printf "blocks=%d\nblocks_missing=%d\nfootnotes=%d\nfootnotes_bad=%d\nitalic_blocks_bad=%d\nbody_first_page=%d\nbody_last_page=%d\n", nblocks, missing, nfn, fnmiss, nital, bodyfirst, bodylast > met
}
