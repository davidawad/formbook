# first-run.awk: the first run of page `p` in reading order: the topmost (then leftmost) run above the footer.
# pdftohtml keeps the order of the content stream, and Word/LibreOffice PDFs draw the footer (the page number)
# before the body text, so the first record of a page is not always its first line.
# Usage: gawk -v p=2 -v ft=<footer top> -f first-run.awk runs.tsv
BEGIN { FS = "\t" }
$1 == p && $2 < ft && (!n++ || $2 < t - 0.5 || ($2 < t + 0.5 && $3 < l)) { t = $2; l = $3; x = $7 }
END { print x }
