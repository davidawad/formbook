#!/bin/sh
# Walk courts/ and emit one plain-text line per leaf court for tools/tracker.bend:
#   alias|group|level|name|path|manual|flags
# manual = court.json status (the only human-set field); flags = six presence
# bits in order: rules exemplar sample typst latex render. Output order follows
# data/index.json so groups are contiguous. Usage: tools/manifest.sh [repo-root]
set -eu
ROOT=${1:-$(cd "$(dirname "$0")/.." && pwd)}
cd "$ROOT"

# 1 if directory $1 holds at least one file matching extension $2, else 0
has_ext() {
  for f in "$1"/*."$2"; do
    [ -e "$f" ] && { printf 1; return; }
  done
  printf 0
}
has_file() { [ -f "$1" ] && printf 1 || printf 0; }

# "n|alias|group" in index order (n = position, used to sort the walk)
ORDER=$(jq -r '.courts | to_entries | to_entries[] | "\(.key)|\(.value.key)|\(.value.value.group)"' data/index.json)

find courts -name court.json | while IFS= read -r cj; do
  d=$(dirname "$cj")
  meta=$(jq -r '[.alias, .level, (.name | gsub("[|\n]"; " ")), .path, (.status // "todo")] | join("|")' "$cj")
  flags="$(has_file "$d/rules.md")$(has_ext "$d/exemplars" pdf)$(has_ext "$d/samples" md)$(has_ext "$d/typst" typ)$(has_ext "$d/latex" tex)$(has_ext "$d/samples" pdf)"
  printf '%s|%s\n' "$meta" "$flags"
done | awk -F'|' -v OFS='|' -v order="$ORDER" '
  BEGIN { n = split(order, ls, "\n"); for (i = 1; i <= n; i++) { split(ls[i], a, "|"); o[a[2]] = a[1]; g[a[2]] = a[3] } }
  { print o[$1], $1, g[$1], $2, $3, $4, $5, $6 }
' | sort -t'|' -k1,1n | cut -d'|' -f2-
