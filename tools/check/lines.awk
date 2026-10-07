# lines.awk: build the line table the geometry checks read.
#
# Usage: gawk -v hmin=14.6 -f lines.awk tags.tsv runs.tsv words.tsv | sort -k1,1n -k2,2n > lines.tsv
#   tags.tsv   row-in-runs.tsv <TAB> block kind        (from gate0.awk; H heading, Hc centered heading, P, Q, L, F)
#   runs.tsv   PDF text runs                           (pdf-runs.awk)
#   words.tsv  exact word boxes                        (words.awk)
#   hmin       words shorter than this (superscript marks) do not make lines of their own
#
# Record: PAGE TOP LEFT RIGHT KIND NWORDS
# KIND is what the content gate matched on that line ("-" if nothing: cover, tables, certificates).
function key(top) { return int(top * 2 + 0.5) }
BEGIN { FS = "\t"; OFS = "\t" }
FILENAME == ARGV[1] { kind[$1] = $2; next }
FILENAME == ARGV[2] { row++; if (row in kind) rk[$1 "\t" key($2)] = kind[row]; next }
{
  if ($6 < hmin) next
  k = $1 "\t" key($3)
  if (!(k in n)) { top[k] = $3; left[k] = $2; right[k] = $4; pg[k] = $1; kd[k] = "-"
    for (d = -1; d <= 1; d++) { kk = $1 "\t" (key($3) + d); if (kk in rk) kd[k] = rk[kk] } }
  n[k]++
  if ($2 < left[k]) left[k] = $2
  if ($4 > right[k]) right[k] = $4
}
END { for (k in n) print pg[k], top[k], left[k], right[k], kd[k], n[k] }
