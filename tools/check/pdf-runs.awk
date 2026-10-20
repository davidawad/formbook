# pdf-runs.awk: `pdftohtml -xml` output -> one record per text run, in points.
#
# Usage: pdftohtml -xml -zoom 2 -i -q -stdout file.pdf | gawk [-v zoom=2] -f pdf-runs.awk > runs.tsv   (zoom = the -zoom given to pdftohtml)
#
# Record: PAGE TOP LEFT WIDTH HEIGHT ITALIC TEXT        (ITALIC is 1 when poppler wrapped the run in <i>)
# A run is a stretch of text in one font on one line, so a change of italic/roman starts a new run.
# Word-exact geometry (margins, spacing) comes from `pdftotext -tsv` instead; this stream is for text and style.

function unescape(s) {
  gsub(/&lt;/, "<", s); gsub(/&gt;/, ">", s); gsub(/&quot;/, "\"", s)
  gsub(/&apos;/, "'", s); gsub(/&#39;/, "'", s); gsub(/&#34;/, "\"", s)
  gsub(/&amp;/, "\\&", s)
  return s
}

/^<page / {
  page = $0; sub(/^.*number="/, "", page); sub(/".*$/, "", page)
  # poppler scales every page by the -zoom factor, whatever its size (a 441 x 666 booklet page is 882 x 1332
  # at zoom 2), so the factor is the zoom itself. Deriving it from page width / 612 assumed letter pages and
  # inflated the y of every run on a smaller page.
  scale = (zoom == "" ? 2 : zoom + 0)
  next
}

/^<text / {
  top = $0; sub(/^.*top="/, "", top); sub(/".*$/, "", top)
  left = $0; sub(/^.*left="/, "", left); sub(/".*$/, "", left)
  width = $0; sub(/^.*width="/, "", width); sub(/".*$/, "", width)
  height = $0; sub(/^.*height="/, "", height); sub(/".*$/, "", height)
  txt = $0; sub(/^<text [^>]*>/, "", txt); sub(/<\/text>$/, "", txt)
  ital = (txt ~ /<i>/) ? 1 : 0
  gsub(/<[^>]*>/, "", txt)
  txt = unescape(txt)
  printf "%d\t%.2f\t%.2f\t%.2f\t%.2f\t%d\t%s\n", page, top / scale, left / scale, width / scale, height / scale, ital, txt
}
