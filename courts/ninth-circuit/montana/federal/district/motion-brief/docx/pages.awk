# pages.awk: where the headings and authorities of a rendered memorandum are (docx/render.sh, first pass).
# usage: LC_ALL=C gawk -f pages.awk keys.tsv doc.txt   (doc.txt: pdftotext output, pages separated by form feeds)
# keys.tsv (written by mtd-motion-brief.lua): "H<TAB>idx<TAB>level<TAB>norm" and "A<TAB>key<TAB>norm".
# Prints "H<TAB>idx<TAB>label" and "A<TAB>key<TAB>label" (label = printed page of the memorandum, from 1),
# or "MISSING<TAB>..." for a heading or authority not found. Matching is on letters and digits only, so
# quotes, dashes, line breaks and hyphenation do not matter. The body starts at the first page with a line
# equal to the first level-1 heading that is not a contents or authorities page.
function nrm(s) {
  gsub(/\357\254\201/, "fi", s); gsub(/\357\254\202/, "fl", s); gsub(/\357\254\200/, "ff", s)
  gsub(/\357\254\203/, "ffi", s); gsub(/\357\254\204/, "ffl", s)
  s = tolower(s); gsub(/[^a-z0-9]/, "", s)
  return s
}
BEGIN {
  keys = ARGV[1]
  nh = 0; na = 0
  while ((getline line < keys) > 0) {
    n = split(line, f, "\t")
    if (f[1] == "H") { nh++; hlev[nh] = f[3]; hkey[nh] = f[4]; hidx[nh] = f[2] }
    else if (f[1] == "A") { na++; akey[na] = f[2]; anorm[na] = f[3] }
  }
  close(keys)
  ARGV[1] = ARGV[2]; ARGC = 2
  RS = "\f"
  miss = 0
}
{
  NLINES[NR] = split($0, L, "\n")
  for (i = 1; i <= NLINES[NR]; i++) { LN[NR, i] = nrm(L[i]) }
  txt = ""
  for (i = 1; i <= NLINES[NR]; i++) txt = txt LN[NR, i]
  PT[NR] = txt
}
END {
  NP = NR
  first1 = ""
  for (k = 1; k <= nh; k++) if (hlev[k] == 1) { first1 = hkey[k]; break }
  bs = 0
  for (p = 2; p <= NP && bs == 0; p++) {
    if (index(PT[p], "tableofcontents") > 0 || index(PT[p], "tableofauthorities") > 0) continue
    for (i = 1; i <= NLINES[p]; i++) if (LN[p, i] == first1) { bs = p; break }
  }
  if (bs == 0) { print "MISSING\tbody\t" first1; exit 1 }
  cur = bs
  for (k = 1; k <= nh; k++) {
    key = hkey[k]; q = 0
    for (p = cur; p <= NP && q == 0; p++) {
      for (i = 1; i <= NLINES[p]; i++) {
        ln = LN[p, i]
        if (ln == "") continue
        if (hlev[k] == 1) { if (ln == key) { q = p; break } }
        else if (index(ln, key) > 0 || (length(ln) >= 12 && index(key, ln) == 1)) { q = p; break }
      }
    }
    if (q == 0) { print "MISSING\tH\t" hidx[k] "\t" key; miss++ }
    else { cur = q; print "H\t" hidx[k] "\t" (q - bs + 1) }
  }
  for (k = 1; k <= na; k++) {
    key = akey[k]
    if (key in done) continue
    done[key] = 1
    found = 0
    for (p = bs; p <= NP; p++) {
      if (index(PT[p], anorm[k]) > 0) { hit[key, p] = 1; found = 1 }
    }
    # every other link text of the same key
    for (j = 1; j <= na; j++) if (akey[j] == key && j != k) for (p = bs; p <= NP; p++) if (index(PT[p], anorm[j]) > 0) { hit[key, p] = 1; found = 1 }
    if (!found) { print "MISSING\tA\t" key; miss++ }
    for (p = bs; p <= NP; p++) if ((key, p) in hit) print "A\t" key "\t" (p - bs + 1)
  }
  exit (miss > 0)
}
