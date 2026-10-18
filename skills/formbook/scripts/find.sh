#!/usr/bin/env bash
# find.sh: locate court folders and the doc types that have a typst template.
# Usage (from the repo root): sh skills/formbook/scripts/find.sh <alias|text> [doctype]
#   alias    a key of data/index.json (CourtListener court id, e.g. ca1, cand, nysupct)
#   text     case-insensitive substring of a court name or path (e.g. "northern district")
#   doctype  optional filter on the doc-type folder name (e.g. complaint)
# Prints per court: "alias<TAB>path<TAB>name", then one "  doctype:" line per subfolder holding typst/main.typ.
# A court whose template sits at the court root (older layout, e.g. ca9) shows "." as its doc type.
# Strict mode. pipefail only where the shell has it (bash, macOS sh); Debian's dash lacks it.
# shellcheck shell=sh disable=SC3040
set -e -u; (set -o pipefail) 2> /dev/null && set -o pipefail
[ $# -ge 1 ] || {
  echo "usage: sh skills/formbook/scripts/find.sh <alias|text> [doctype]" >&2
  exit 2
}
IDX=data/index.json
[ -f "$IDX" ] || {
  echo "find.sh: run from the formbook repo root (no $IDX)" >&2
  exit 2
}
Q=$1
DT=${2:-}
TAB=$(printf '\t')
# alias<TAB>path<TAB>name per court. The index is pretty-printed, so awk reads it without jq.
LIST=$(awk '
  /^ "courts": \{/ { in_c = 1; next }
  in_c && /^ \},?$/ { in_c = 0 }
  in_c && /^  "[^"]+": \{/ { a = $0; sub(/^  "/, "", a); sub(/".*/, "", a); next }
  in_c && /^   "path":/ { p = $0; sub(/^   "path": "/, "", p); sub(/".*/, "", p); next }
  in_c && /^   "name":/ { n = $0; sub(/^   "name": "/, "", n); sub(/",?$/, "", n); print a "\t" p "\t" n }
' "$IDX")
# legacy_aliases map an old alias to its current one.
CUR=$(awk -v q="$Q" '/"legacy_aliases"/ { f = 1; next } f && /^ \}/ { f = 0 }
  f && /"[^"]+": "[^"]+"/ { l = $0; gsub(/[ ",]/, "", l); split(l, kv, ":"); if (kv[1] == q) print kv[2] }' "$IDX")
[ -n "$CUR" ] && Q=$CUR
MATCH=$(printf '%s\n' "$LIST" | awk -F'\t' -v q="$Q" 'tolower($1) == tolower(q)')
[ -n "$MATCH" ] || MATCH=$(printf '%s\n' "$LIST" | awk -F'\t' -v q="$Q" 'index(tolower($2 " " $3), tolower(q))')
# Fallback: the index can lag the tree; every court folder's court.json carries its own alias.
[ -n "$MATCH" ] || MATCH=$(find courts -name court.json | while read -r cj; do
  a=$(sed -n 's/^ *"alias": "\(.*\)",$/\1/p' "$cj" | head -1)
  [ "$(printf %s "$a" | tr '[:upper:]' '[:lower:]')" = "$(printf %s "$Q" | tr '[:upper:]' '[:lower:]')" ] || continue
  n=$(sed -n 's/^ *"name": "\(.*\)",$/\1/p' "$cj" | head -1)
  printf '%s\t%s\t%s\n' "$a" "$(dirname "$cj")" "$n"
done)
[ -n "$MATCH" ] || {
  echo "find.sh: no court matches '$1'" >&2
  exit 1
}
printf '%s\n' "$MATCH" | while IFS=$TAB read -r alias path name; do
  printf '%s\t%s\t%s\n' "$alias" "$path" "$name"
  [ -d "$path" ] || continue
  find "$path" -type d -name typst | sort | while read -r t; do
    [ -f "$t/main.typ" ] || continue
    d=${t%/typst}
    rel=${d#"$path"}
    rel=${rel#/}
    [ -n "$rel" ] || rel=.
    if [ -n "$DT" ]; then
      case $rel in "$DT" | */"$DT") ;; *) continue ;; esac
    fi
    n=$(find "$d" -mindepth 2 -maxdepth 2 -path "$d/usage/INPUT-*.md" | wc -l | tr -d ' ')
    printf '  doctype: %s\t(%s sample inputs)\t%s\n' "$rel" "$n" "$d"
  done
done
