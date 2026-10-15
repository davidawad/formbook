# Page numbers for the motion brief's tables (docx/render.sh pass 1 -> pass 2).
# Input: DATA (the keys written by pass 1: "B<TAB>first body text", "H<TAB>heading text" for each TOC
# heading in order, "A<TAB>key<TAB>link text" for each authority hit in document order) and the text of
# the pass-1 PDF (pdftotext output; pages are separated by form feeds). The body starts at the page where
# the first body paragraph appears; body page labels run from 1 there. Keys are searched in order in the
# body text (headings and hits each keep their own cursor). Output, on stdout:
#   H<TAB>idx<TAB>label           for each TOC heading
#   A<TAB>key<TAB>label,label...  for each authority, pages distinct, in order
# Authority matching uses the first 28 bytes of the link text: a footnote number or note can sit inside a
# citation that breaks across lines, and then the whole string would not match.
# A key that is not found is an error (exit 3), never a blank entry.
BEGIN {
  nh = 0; na = 0; nk = 0
  while ((getline line < DATA) > 0) {
    n = split(line, f, "\t")
    if (f[1] == "B") snip = f[2]
    else if (f[1] == "H") { nh++; HT[nh] = f[2] }
    else if (f[1] == "A") { na++; AK[na] = f[2]; AT[na] = substr(f[3], 1, 28) }
  }
  close(DATA)
  # Hyphens are dropped on both sides: a hyphen at a line end is not copied by pdftotext.
  gsub(/-/, "", snip)
  for (h = 1; h <= nh; h++) gsub(/-/, "", HT[h])
  for (a = 1; a <= na; a++) gsub(/-/, "", AT[a])
  RS = "\f"
}
{
  t = $0
  gsub(/\302\240/, " ", t)
  gsub(/[ \n\t]+/, " ", t)
  gsub(/-/, "", t)
  P[NR] = t
  NP = NR
}
END {
  if (NP == 0) { print "pages.awk: no pages" > "/dev/stderr"; exit 2 }
  bs = 0
  for (i = 1; i <= NP; i++) if (index(P[i], snip) > 0) { bs = i; break }
  if (bs == 0) { print "pages.awk: body start not found: " snip > "/dev/stderr"; exit 2 }
  G = ""
  nb = 0
  for (i = bs; i <= NP; i++) { nb++; START[nb] = length(G) + 1; G = G P[i] " " }
  # body label of a position: the page whose start is the last one at or before it
  c = 0
  for (h = 1; h <= nh; h++) {
    s = index(substr(G, c + 1), HT[h])
    if (s == 0) { print "pages.awk: heading not found: " HT[h] > "/dev/stderr"; exit 3 }
    pos = c + s
    c = pos + length(HT[h]) - 1
    HL[h] = label(pos)
  }
  c = 0
  for (a = 1; a <= na; a++) {
    s = index(substr(G, c + 1), AT[a])
    if (s == 0) { print "pages.awk: link text not found: " AT[a] " (" AK[a] ")" > "/dev/stderr"; exit 3 }
    pos = c + s
    c = pos + length(AT[a]) - 1
    lab = label(pos)
    if (!(AK[a] in APG)) { nk++; KL[nk] = AK[a]; APG[AK[a]] = "" }
    if (index("," APG[AK[a]] ",", "," lab ",") == 0) APG[AK[a]] = APG[AK[a]] (APG[AK[a]] == "" ? "" : ",") lab
  }
  for (h = 1; h <= nh; h++) printf "H\t%d\t%s\n", h, HL[h]
  for (k = 1; k <= nk; k++) printf "A\t%s\t%s\n", KL[k], APG[KL[k]]
}
function label(pos,   k) {
  for (k = nb; k >= 1; k--) if (START[k] <= pos) return k
  return 1
}
