# mdcount.awk: independent word count of the brief, from blocks.tsv (md-blocks.awk).
#
# Counts whitespace-delimited words in every heading, paragraph, quotation, list item and footnote
# that comes before the Addendum, the way a word processor does, leaving out list markers and
# footnote reference marks. (FRAP 32(f): headings, footnotes and quotations count; the addendum,
# cover, tables, certificates and signature block do not.)
BEGIN { FS = "\t"; n = 0; stop = 0 }
{
  kind = $1; txt = $4
  if (kind == "H" && tolower(txt) == "addendum" && $2 ~ /^1/) { stop = 1 }
  if (stop && kind != "F") next
  gsub(/\004[^\005]*\005/, "", txt); gsub(/[\002\003\006]/, "", txt); gsub(/\007[^\010]*\010/, "", txt)
  if (kind == "L") sub(/^([0-9]+\.|•) /, "", txt)
  k = split(txt, w, /[ \t]+/)
  for (i = 1; i <= k; i++) if (w[i] != "") n++
}
END { print n }
