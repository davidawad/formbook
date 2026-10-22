# gate0.awk: Gate 0 CONTENT. Does every block of the markdown appear in the PDF, in order, intact?
#
# Usage: LC_ALL=C.UTF-8 gawk -v out=PREFIX -v footer_top=720 -f norm.awk -f gate0.awk runs.tsv blocks.tsv
#   runs.tsv    from pdf-runs.awk   (PDF text runs: page, geometry, italic flag, text)
#   blocks.tsv  from md-blocks.awk  (the markdown, one block per record)
#
# Method. Both sides are reduced to the same normal form (norm.awk: lower case, straight quotes,
# ligatures expanded, ALL whitespace removed, a dot leader of four or more dots cut to four: leader()) so line
# breaks, spacing and leader lengths can never matter, but a missing or altered character always does.
# Footer page numbers are dropped by position. Each footnote is first
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
    if (c == "." && T ~ /\.\.\.\.$/) continue   # a dot leader's length is layout, not content (leader())
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

# Locate a footnote (marker number + text, in normal form) in the PDF stream S. A note that starts at the foot of
# one page and continues at the foot of a later page is not contiguous in S (the body of the next page sits
# between the two parts), so it is reassembled: each part is the longest prefix of what is left that occurs in S
# after the previous part, and a continuation part must lie on a LATER page and be at least 8 characters unless
# it completes the note. At most 3 parts. Fills SEGP/SEGL (start in S, length) and returns the part count (0 = not found).
function fn_find(want,    rest, from, nseg, lo, hi, mid, q, prevpg, tmp) {
  delete SEGP; delete SEGL
  rest = want; from = 1; nseg = 0; prevpg = 0
  while (rest != "" && nseg < 3) {
    tmp = substr(S, from)
    if (index(tmp, rest) > 0) lo = length(rest)
    else {
      lo = 0; hi = length(rest) - 1
      while (lo < hi) { mid = int((lo + hi + 1) / 2); if (index(tmp, substr(rest, 1, mid)) > 0) lo = mid; else hi = mid - 1 }
      # a part that is followed by another ends the page's text (a note sits at the page foot): shorten past any
      # chance match of the next characters (the next page's "2." heading can extend a prefix by one digit)
      for (; lo > 0; lo--) {
        q = from + index(tmp, substr(rest, 1, lo)) - 1
        if (q + lo > length(S) || pageat(q + lo) != pageat(q + lo - 1)) break
      }
    }
    if (lo == 0 || (nseg > 0 && lo < length(rest) && lo < 8)) return 0
    q = from + index(tmp, substr(rest, 1, lo)) - 1
    if (nseg > 0 && pageat(q) <= prevpg) return 0
    nseg++; SEGP[nseg] = q; SEGL[nseg] = lo; prevpg = pageat(q + lo - 1)
    rest = substr(rest, lo + 1); from = q + lo
  }
  return (rest == "") ? nseg : 0
}

# offset in S of character number off (1-based) of a note located by fn_find
function fn_at(off, nseg,    g) {
  for (g = 1; g <= nseg; g++) { if (off <= SEGL[g]) return SEGP[g] + off - 1; off -= SEGL[g] }
  return SEGP[nseg] + SEGL[nseg] - 1
}

# A pipe-table row (kind R, cells joined by \001) that is not contiguous in the PDF, which is read line by line, so the
# lines of the cells of a row interleave: a short cell ("¶ 7") sits between the wrapped lines of the cell beside it. The cells are found whole,
# SHORTEST FIRST, each cut out of the window of the stream that follows the previous row before the next is looked for;
# so a short cell never splits a longer one. They may come in any order among themselves; the row ends at its
# furthest cell and the next row must start after that. Italics are checked per character, as for any block.
function tl_head_ok(h) { return length(h) >= 12 }                       # a header too short to be recognised is left alone

function table_row(b,    full, cells, n, i, j, k, w, q, L, tt, total, wd, wl, W, ord, bad, idx, minpos, maxend, ht, hq, lim, r, r1, r2, badn, first) {
  full = braw[b]; n = split(full, cells, "\001"); total = 0
  for (i = 1; i <= n; i++) {
    tt = prep(cells[i]); ct[i] = tt; tl[i] = length(tt); total += tl[i]
    cti[i] = ""; for (k = 1; k <= tl[i]; k++) cti[i] = cti[i] (TI[k] ? "1" : "0")
  }
  W = total * 3 + 300; wd = substr(S2, cursor, W); wl = length(wd)
  for (k = 1; k <= wl; k++) mp[k] = cursor + k - 1
  if (thead != "" && tl_head_ok(thead)) {                                 # a repeated header row (after a page break) is not part of any cell
    while ((q = index(wd, thead)) > 0) {
      wd = substr(wd, 1, q - 1) substr(wd, q + length(thead))
      for (k = q; k <= wl - length(thead); k++) mp[k] = mp[k + length(thead)]
      wl -= length(thead)
    }
  }
  for (i = 1; i <= n; i++) ord[i] = i
  for (i = 2; i <= n; i++) { idx = ord[i]; j = i - 1; while (j >= 1 && tl[ord[j]] > tl[idx]) { ord[j + 1] = ord[j]; j-- } ord[j + 1] = idx }
  bad = 0; minpos = 0; maxend = cursor
  for (i = 1; i <= n; i++) {
    idx = ord[i]; L = tl[idx]; cfound[idx] = 0
    if (L == 0) continue
    q = index(wd, ct[idx])
    if (q == 0) { if (!bad) { braw[b] = cells[idx]; report_missing(b, cursor); braw[b] = full }; bad = 1; continue }
    cfound[idx] = 1
    for (k = 0; k < L; k++) corig[idx, k] = mp[q + k]
    if (minpos == 0 || corig[idx, 0] < minpos) minpos = corig[idx, 0]
    if (corig[idx, L - 1] + 1 > maxend) maxend = corig[idx, L - 1] + 1
    wd = substr(wd, 1, q - 1) substr(wd, q + L)
    for (k = q; k <= wl - L; k++) mp[k] = mp[k + L]
    wl -= L
  }
  if (minpos == 0) minpos = cursor
  lim = minpos - 1
  for (k = npend; k >= 1; k--) {                                         # headings sit just before the row
    ht = prep(braw[pend[k]]); hq = last_in(ht, cursor, lim)
    if (hq == 0) { report_missing(pend[k], cursor); continue }
    settle(pend[k], hq); lim = hq - 1
  }
  npend = 0
  if (bad) return
  r1 = runat(M2[minpos]); r2 = runat(M2[maxend - 1])
  for (r = r1; r <= r2; r++) if (!(r in kindof)) kindof[r] = "P"
  if (!bodyfirst) bodyfirst = page[RROW[r1]]
  bodylast = page[RROW[r2]]
  for (i = 1; i <= n; i++) if (cfound[i]) {
    badn = 0; first = ""
    for (k = 1; k <= tl[i]; k++) if (substr(cti[i], k, 1) == "1" && !SI[M2[corig[i, k - 1]]]) badn++
    if (badn) { nital++; printf "FAIL italic: table cell \"%.40s\" has %d italic characters rendered roman\n", cells[i], badn >> rep }
  }
  cursor = maxend
}

# A dot leader (four or more dots, whitespace already gone) is reduced to exactly four dots on both sides:
# its length depends on the line it ends, so a markdown entry transcribed with its leader matches the PDF
# whatever the leader's width. t is the next run's text, s the stream it extends.
function leader(s, t,    out, k, c) {
  out = ""
  for (k = 1; k <= length(t); k++) {
    c = substr(t, k, 1)
    if (c == "." && (substr(s, length(s) - 3) out) ~ /\.\.\.\.$/) continue
    out = out c
  }
  return out
}

BEGIN { FS = "\t"; nruns = 0; S = ""; fncount = 0 }

# ---- file 1: PDF runs -------------------------------------------------------
FILENAME == ARGV[1] {
  rr++
  page[rr] = $1
  if ($2 + $5 / 2 >= footer_top) next              # page numbers live in the bottom margin (judged by the run's middle: a footer box may start a few points above the margin line)
  if ($2 + $5 / 2 < (header_top == "" ? 54 : header_top + 0) && $7 ~ /^[ ]*([0-9]+|[ivxlcdm]+|[IVXLCDM]+)[ ]*$/) next   # a page number alone on its line in the TOP margin (ORAP 5.05(3)(c) and the like): dropped like a footer number; header_top defaults to 54 pt, inside every court margin
  t = leader(S, norm1($7))
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
    if (!(key in fnnum) && blab[b] == "fm" && key ~ /^[0-9]+$/) fnnum[key] = key + 0   # frontmatter note: its key is the printed number
    if (!(key in fnnum)) { print "NOTE footnote [^" key "] is defined but never referenced" >> rep; continue }
    want = fnnum[key] ftxt
    nseg = fn_find(want)
    if (nseg == 0) {
      fnmiss++
      lo = 0; hi = length(want)
      while (lo < hi) { mid = int((lo + hi + 1) / 2); if (index(S, substr(want, 1, mid)) > 0) lo = mid; else hi = mid - 1 }
      printf "FAIL footnote %s (marker %d) is not in the PDF in full: the text stops matching after %d of %d characters, at the markdown word \"%s\"\n", key, fnnum[key], lo, length(want), wordat(lo - length(fnnum[key] "")) >> rep
      continue
    }
    off = 0                                                   # cut every segment of the note out of the body stream
    for (g = 1; g <= nseg; g++) {
      for (k = SEGP[g]; k < SEGP[g] + SEGL[g]; k++) del[k] = 1
      for (r = runat(SEGP[g]); r <= runat(SEGP[g] + SEGL[g] - 1); r++) kindof[r] = "F"
    }
    fnpage[key] = pageat(SEGP[1])
    for (k = 1; k <= nlinks; k++) printf "%s\t%d\n", lk[k], pageat(fn_at(length(fnnum[key] "") + lkoff[k], nseg)) > lkf
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
    if (bk[b] != "R") intable = 0
    if (bk[b] == "R") {                                                   # table row: contiguous in the PDF, or interleaved with its neighbours
      full = braw[b]; gsub(/\001/, " ", braw[b]); t = prep(braw[b])
      if (!intable) { thead = t; intable = 1 }                            # the first row of a table is its header; the PDF repeats it after a page break
      if (index(substr(S2, cursor), t) == 0) { braw[b] = full; table_row(b); continue }
    }
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
