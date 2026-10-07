# gate0.awk: Gate 0 CONTENT. Does every block of the markdown appear in the PDF, in order, intact?
#
# Usage: LC_ALL=en_US.UTF-8 gawk -v out=PREFIX -v footer_top=720 -f gate0.awk runs.tsv blocks.tsv
#   runs.tsv    from pdf-runs.awk   (PDF text runs: page, geometry, italic flag, text)
#   blocks.tsv  from md-blocks.awk  (the markdown, one block per record)
#
# Method. Both sides are reduced to the same normal form (lower case, straight quotes, ligatures
# expanded, ALL whitespace removed) so line breaks and spacing can never matter, but a missing or
# altered character always does. Footer page numbers are dropped by position; footnote text is cut
# out of the PDF stream (it sits at the page foot, in the middle of a paragraph that continues on the
# next page) after being checked on its own. Each remaining markdown block must then occur, whole and
# contiguous, after the previous block: that is "in order, nothing dropped". Nothing is averaged;
# every missing block is reported with the exact place the text stops matching.
#
# Writes PREFIX.report (human findings), PREFIX.metrics (key=value), PREFIX.tags (run -> block kind),
# PREFIX.heads (heading placement), PREFIX.links (authority citations -> physical page).

function norm1(s) {
  s = tolower(s)
  gsub(/[\x{2018}\x{2019}\x{201B}]/, "'", s)
  gsub(/[\x{201C}\x{201D}]/, "\"", s)
  gsub(/\x{FB00}/, "ff", s); gsub(/\x{FB01}/, "fi", s); gsub(/\x{FB02}/, "fl", s)
  gsub(/\x{FB03}/, "ffi", s); gsub(/\x{FB04}/, "ffl", s)
  gsub(/\x{2026}/, "...", s)
  gsub(/[ \t\r\n\x{00A0}\x{2009}\x{200A}\x{202F}\x{2060}\x{00AD}\x{200B}]/, "", s)
  return s
}

# prepare a markdown block text: fills T (normal form), TI[i] italic flag per char,
# WSTART/WTXT for naming the first lost word, link list, and returns T.
function prep(raw,    i, n, c, ital, t, nc, k, key, w, wl, plain) {
  T = ""; ital = 0; nlinks = 0; nrefs = 0; delete TI; delete WS; delete WT; nw = 0
  n = length(raw); w = ""; wl = 0
  for (i = 1; i <= n; i++) {
    c = substr(raw, i, 1)
    if (c == "\002") { ital = 1; continue }
    if (c == "\003") { ital = 0; continue }
    if (c == "\004") { k = index(substr(raw, i), "\005"); key = substr(raw, i + 1, k - 2); i += k - 1; lk[++nlinks] = key; lkoff[nlinks] = length(T) + 1; continue }
    if (c == "\006") { continue }
    if (c == "\007") {
      k = index(substr(raw, i), "\010"); key = substr(raw, i + 1, k - 2); i += k - 1
      if (!(key in fnnum)) fnnum[key] = ++fncount
      nrefs++; refpos[nrefs] = length(T) + 1; refkey[nrefs] = key
      t = fnnum[key] ""; for (k = 1; k <= length(t); k++) { T = T substr(t, k, 1); TI[length(T)] = 0 }
      continue
    }
    if (c ~ /[ \t]/) { w = ""; wl = 0; continue }
    nc = norm1(c)
    if (wl == 0) { WS[++nw] = length(T) + 1; wlen = 0 }
    wl++; WT[nw] = WT[nw] c
    for (k = 1; k <= length(nc); k++) { T = T substr(nc, k, 1); TI[length(T)] = ital }
  }
  return T
}

function runat(p,    lo, hi, mid) {            # run index containing offset p of the original stream S
  lo = 1; hi = nruns
  while (lo < hi) { mid = int((lo + hi + 1) / 2); if (RS[mid] <= p) lo = mid; else hi = mid - 1 }
  return lo
}

function wordat(off,    k, best) {              # first word of the prepared block at/after char offset off
  best = 1
  for (k = 1; k <= nw; k++) if (WS[k] <= off) best = k
  return WT[best]
}

# last occurrence of text t that lies wholly before offset lim of S2 (0 if none)
function last_before(t, lim,    p, found, from, q) {
  found = 0; from = 1
  while ((q = index(substr(S2, from, lim - from + 1), t)) > 0) { found = from + q - 1; from = found + 1 }
  return found
}

# one record per matched heading: LEVEL LABEL LABEL_OK PAGE TEXT. LABEL_OK says the PDF prints the
# label the numbering rules call for immediately before the heading text.
function emit_head(b, pos, r1,    lab, lp, labok) {
  lab = norm1(blab[b]); lp = pos - length(lab)
  labok = (lab == "" || (lp >= 1 && substr(S2, lp, length(lab)) == lab)) ? 1 : 0
  printf "%d\t%s\t%d\t%d\t%s\n", blv[b], blab[b], labok, page[RR[r1]], braw[b] > hd
}

BEGIN { FS = "\t"; nruns = 0; S = ""; fncount = 0 }

# ---- file 1: PDF runs -------------------------------------------------------
FILENAME == ARGV[1] {
  rr++
  page[rr] = $1; top[rr] = $2; left[rr] = $3; wid[rr] = $4; hgt[rr] = $5; it[rr] = $6
  if ($2 >= footer_top) { skipped[rr] = 1; next }             # page numbers live in the bottom margin
  t = norm1($7)
  if (t == "") { skipped[rr] = 1; next }
  nruns++
  RS[nruns] = length(S) + 1; RR[nruns] = rr
  S = S t
  RE[nruns] = length(S)
  for (k = RS[nruns]; k <= RE[nruns]; k++) SI[k] = $6
  next
}

# ---- file 2: markdown blocks ------------------------------------------------
FILENAME == ARGV[2] { nb++; bk[nb] = $1; blv[nb] = $2; blab[nb] = $3; braw[nb] = $4; next }

END {
  rep = out ".report"; met = out ".metrics"; tag = out ".tags"; hd = out ".heads"; lkf = out ".links"
  printf "" > rep; printf "" > tag; printf "" > hd; printf "" > lkf

  # ---- footnotes: first pass assigns numbers in order of appearance in the body ----
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
    fnrun[key] = runat(p); fnpage[key] = page[RR[fnrun[key]]]
    for (r = runat(p); r <= runat(p + length(want) - 1); r++) kindof[r] = "F"
  }

  # ---- the PDF stream without footnotes ----
  S2 = ""; n2 = 0
  for (k = 1; k <= length(S); k++) if (!(k in del)) { S2 = S2 substr(S, k, 1); M2[++n2] = k }

  # ---- body blocks, in order ----
  cursor = 1; anchored = 0; npend = 0; missing = 0; nital = 0; nblocks = 0; nlinkout = 0
  for (b = 1; b <= nb; b++) {
    if (bk[b] == "F") continue
    nblocks++
    t = prep(braw[b])
    # copy per-block arrays that later code needs (prep() reuses the globals)
    bt = t; nl = nlinks; for (k = 1; k <= nl; k++) { blk[k] = lk[k]; blo[k] = lkoff[k] }
    nr = nrefs; for (k = 1; k <= nr; k++) { brk[k] = refkey[k]; brp[k] = refpos[k] }
    for (k = 1; k <= length(t); k++) bti[k] = TI[k]
    for (k = 1; k <= nw; k++) { bws[k] = WS[k]; bwt[k] = WT[k] }
    bnw = nw

    if (!anchored && bk[b] == "H") { pend[++npend] = b; pendt[npend] = t; continue }

    q = index(substr(S2, cursor), t)
    if (q == 0) {
      missing++
      lo2 = 0; hi2 = length(t)
      while (lo2 < hi2) { mid = int((lo2 + hi2 + 1) / 2); if (index(substr(S2, cursor), substr(t, 1, mid)) > 0) lo2 = mid; else hi2 = mid - 1 }
      pq = index(substr(S2, cursor), substr(t, 1, lo2 > 0 ? lo2 : 1))
      w = ""; for (k = 1; k <= bnw; k++) if (bws[k] <= lo2 + 1) w = bwt[k]
      printf "FAIL %s block %d is missing or altered in the PDF. Markdown: \"%.70s\". The text matches for %d of %d characters, then the markdown has \"%s\" where the PDF has \"%.30s\"\n", bk[b], b, braw[b], lo2, length(t), substr(t, lo2 + 1, 25), substr(S2, cursor + pq - 1 + lo2, 30) >> rep
      continue
    }
    pos = cursor + q - 1
    if (!anchored) {
      anchored = 1
      # headings that precede the first paragraph: they must occur before it (the TOC is earlier still)
      for (k = 1; k <= npend; k++) {
        hq = last_before(pendt[k], pos - 1)
        if (hq == 0) { missing++; printf "FAIL H block %d (a heading before the first paragraph) is missing in the PDF: \"%.70s\"\n", pend[k], braw[pend[k]] >> rep }
        else {
          r1 = runat(M2[hq]); r2 = runat(M2[hq + length(pendt[k]) - 1])
          for (r = r1; r <= r2; r++) if (!(r in kindof)) kindof[r] = "H"
          emit_head(pend[k], hq, r1)
        }
      }
    }
    endp = pos + length(t) - 1
    cursor = endp + 1
    r1 = runat(M2[pos]); r2 = runat(M2[endp])
    for (r = r1; r <= r2; r++) if (!(r in kindof)) kindof[r] = bk[b]
    if (!bodyfirst) bodyfirst = page[RR[r1]]
    bodylast = page[RR[r2]]
    if (bk[b] == "H") emit_head(b, pos, r1)
    # authority citations: physical page of each link's first character
    for (k = 1; k <= nl; k++) printf "%s\t%d\n", blk[k], page[RR[runat(M2[pos + blo[k] - 1])]] > lkf
    # footnote references: the footnote must sit on the page that carries its reference
    for (k = 1; k <= nr; k++) {
      refp = pos + brp[k] - 1 - 1                  # last character before the marker digits
      rp = page[RR[runat(M2[refp])]]
      if (brk[k] in fnpage && fnpage[brk[k]] != rp) {
        printf "FAIL footnote %s is on page %d but its reference is on page %d\n", brk[k], fnpage[brk[k]], rp >> rep
        fnmiss++
      }
    }
    # italics: every span the markdown italicises must be in an italic face in the PDF
    bad = 0; badw = ""
    for (k = 1; k <= length(t); k++) if (bti[k] && !SI[M2[pos + k - 1]]) {
      bad++
      if (length(badw) < 80) { for (w2 = bnw; w2 >= 1; w2--) if (bws[w2] <= k) break; if (index(badw, bwt[w2]) == 0) badw = badw (badw == "" ? "" : " ") bwt[w2] }
    }
    if (bad) { nital++; printf "FAIL italic: block %d has %d italic characters rendered roman, starting at: %s\n", b, bad, badw >> rep }
  }
  # run-level tags, keyed by the row number in runs.tsv
  for (r in kindof) printf "%d\t%s\n", RR[r], kindof[r] > tag

  printf "blocks=%d\nblocks_missing=%d\nfootnotes=%d\nfootnotes_bad=%d\nitalic_blocks_bad=%d\nbody_first_page=%d\nbody_last_page=%d\n", nblocks, missing, nfn, fnmiss, nital, bodyfirst, bodylast > met
}
