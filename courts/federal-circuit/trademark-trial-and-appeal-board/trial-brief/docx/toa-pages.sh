#!/bin/sh
# toa-pages.sh <pdf> <search-file>: the body pages on which each table-of-authorities needle occurs.
# The search file has one "key<TAB>needle" line per link written by ttab-trial-brief.lua. Front matter (roman
# numbered pages) is not counted: only pages whose footer label is arabic are body pages. Needles are compared with
# all whitespace removed, so a citation broken across lines still matches. Output: "key<TAB>1, 4, 7" per key (empty
# when the needle is on no body page), sorted by key.
set -eu
PDF=$1
SEARCH=$2
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
N=$(pdfinfo "$PDF" | awk '/^Pages:/{print $2}')
p=1
while [ "$p" -le "$N" ]; do
  pdftotext -f "$p" -l "$p" -layout "$PDF" "$T/p.txt"
  label=$(awk '/[^[:space:]]/{l=$0} END{gsub(/^[[:space:]]+|[[:space:]]+$/,"",l); print l}' "$T/p.txt")
  text=$(sed 's/\xc2\xa0/ /g' "$T/p.txt" | tr -d '[:space:]')
  printf '%s\t%s\n' "$label" "$text"
  p=$((p + 1))
done > "$T/pages.tsv"
gawk -F'\t' '
  FNR == NR {
    if ($1 ~ /^[0-9]+$/) { n++; lab[n] = $1 + 0; txt[n] = $2 }
    next
  }
  {
    key = $1
    needle = $2
    gsub(/[ \t\r\n\f]/, "", needle)
    if (!(key in seen)) { seen[key] = 1; keys[++nk] = key }
    for (i = 1; i <= n; i++) if (index(txt[i], needle) > 0) hit[key, lab[i]] = 1
  }
  END {
    for (k = 1; k <= nk; k++) {
      key = keys[k]
      out = ""
      for (i = 1; i <= n; i++) {
        if (!((key, lab[i]) in hit)) continue
        out = out (out == "" ? "" : ", ") lab[i]
      }
      print key "\t" out
    }
  }
' "$T/pages.tsv" "$SEARCH" | sort
