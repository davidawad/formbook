# leader-entries.awk: read a table of contents / authorities back out of the PDF.
#
# Usage: gawk -v from=2 -v to=3 -v skip='^(Cases|Statutes):$|^Page' -f leader-entries.awk runs.tsv
# Record: TITLE <TAB> PAGES <TAB> PHYSICAL_PAGE
#
# An entry is every text run since the previous entry up to and including the run that holds the dot
# leaders; whatever follows the leaders is the page reference (a page number, a list, or "passim").
# Entries that wrap across lines are therefore read as one. Runs matching `skip` (titles, column
# headings, group labels) are not part of any entry.
BEGIN { FS = "\t"; acc = "" }
$1 < from || $1 > to { next }
{
  t = $7
  if (skip != "" && t ~ skip) { acc = ""; next }
  if (match(t, /( \.){3,}/)) {
    title = acc substr(t, 1, RSTART - 1)
    pages = substr(t, RSTART + RLENGTH); gsub(/^[ \t]+|[ \t]+$/, "", pages)
    printf "%s\t%s\t%d\n", title, pages, $1
    acc = ""
  } else acc = acc t
}
