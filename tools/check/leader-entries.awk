# leader-entries.awk: read a table of contents / authorities back out of the PDF.
#
# Usage: gawk -v from=2 -v to=3 -v skip='^(Cases|Statutes):$|^Page$' -f leader-entries.awk runs.tsv
# Record: TITLE <TAB> PAGES <TAB> PHYSICAL_PAGE
#
# An entry is every text run since the previous entry up to and including the run that holds the dot
# leaders (spaced, " . . .", as typst and latex set them, or contiguous, "....", as Word and LibreOffice set a
# dot-leader tab); whatever follows the leaders, in the same run or in the next run on the same line, is the
# page reference (a page number, a list, or "passim"). Entries that wrap across lines are therefore
# read as one. Runs matching `skip` (titles, column headings, group labels) belong to no entry.
# Remember that `-v` expands backslash escapes: write brackets as [(] and [)], not \( and \).
BEGIN { FS = "\t"; acc = ""; have = 0 }

function flush() {
  if (have) printf "%s\t%s\t%d\n", ptitle, ppages, ppage
  have = 0
}

$1 < from || $1 > to { next }
$2 >= footer_top { next }          # page numbers in the bottom margin are not part of any entry
{
  t = $7
  if (have) {   # the page number may sit in its own run, on the same line as the leaders
    if ($1 == ppage && $2 > ptop - 1 && $2 < ptop + 1 && ppages == "" && t !~ /( \.){2,}|\.{3,}/) { ppages = t; gsub(/^[ \t]+|[ \t]+$/, "", ppages); flush(); next }
    flush()
  }
  if (skip != "" && t ~ skip) { acc = ""; next }
  if (match(t, /( \.){2,}|\.{3,}/)) {
    ptitle = acc substr(t, 1, RSTART - 1)
    ppages = substr(t, RSTART + RLENGTH); gsub(/^[ \t]+|[ \t]+$/, "", ppages)
    ppage = $1; ptop = $2; have = 1
    acc = ""
  } else acc = acc t
}
END { flush() }
