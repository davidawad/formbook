#!/bin/sh
# Walk courts/ and emit one plain-text line per leaf court for tools/tracker.bend:
#   alias|group|level|name|path|manual|flags
# manual = court.json status (the only human-set field); flags = eight characters, in order:
#   1 rules.md present (0/1)
#   2 number of exemplars/*.pdf (0-9, capped)
#   3 number of samples/*.md, i.e. INPUT-*.md (0-9, capped)
#   4 typst engine state   5 latex engine state   6 docx engine state
#       0 = no template or no rendered PDF, 1 = built (template + rendered PDF), 2 = pass (valid stamp)
#   7 overlay PDF present (samples/OVERLAY-*.pdf)
#   8 review file present (reviews/*.md)
# A stamp samples/.check-<engine>.txt (written by tools/check.sh on a full green run) is valid only while its
# first line is PASS and every "sha256  path" line still matches the file on disk.
# Output order follows data/index.json so groups are contiguous. Usage: tools/manifest.sh [--doctypes] [repo-root]
#
# With --doctypes it emits one line per Typst doc type instead, for the per-doc-type table:
#   alias|group|doctype|path|flags
# A doc type is a subfolder of a court folder (COURT/<doctype>/, no court.json of its own) holding typst/, samples/
# or exemplars/; the court folder itself counts as doc type "(court root)" when its own typst/ is not empty.
# flags = six characters, in order:
#   1 typst template present (typst/ not empty, 0/1)
#   2 number of samples/INPUT-*.md (0-9, capped)
#   3 typst render: 0 = no samples/OUTPUT-*.pdf, 1 = rendered, 2 = rendered and a valid typst stamp (gates green)
#   4 number of exemplars/*.pdf (0-9, capped)
#   5 overlay PDF present (samples/OVERLAY-*.pdf, 0/1)
#   6 review file present (reviews/*.md, 0/1)
set -eu
DOCTYPES=0
[ "${1:-}" != --doctypes ] || {
  DOCTYPES=1
  shift
}
ROOT=${1:-$(cd "$(dirname "$0")/.." && pwd)}
cd "$ROOT"

has_file() { [ -f "$1" ] && printf 1 || printf 0; }
# count of files matching the glob(s) given, capped at 9
count() {
  n=0
  for f in "$@"; do [ -e "$f" ] && n=$((n + 1)); done
  [ "$n" -gt 9 ] && n=9
  printf %s "$n"
}
# true if directory $1 holds a template file for its engine: anything visible
has_template() {
  for f in "$1"/*; do [ -e "$f" ] && return 0; done
  return 1
}
# rendered PDFs of an engine in court dir $1: typst = every samples/OUTPUT-*.pdf that is not another engine's
pdfs() {
  case $2 in
    typst) for f in "$1"/samples/OUTPUT-*.pdf; do
      case $f in *.latex.pdf | *.docx.pdf) ;; *) [ -e "$f" ] && echo "$f" ;; esac
    done ;;
    latex) for f in "$1"/samples/OUTPUT-*.latex.pdf; do [ -e "$f" ] && echo "$f"; done ;;
    docx) for f in "$1"/samples/OUTPUT-*.docx.pdf; do [ -e "$f" ] && echo "$f"; done ;;
  esac
}
stamp_valid() { # $1 court dir, $2 engine
  s="$1/samples/.check-$2.txt"
  [ -f "$s" ] || return 1
  [ "$(head -1 "$s")" = PASS ] || return 1
  [ "$(wc -l < "$s")" -gt 1 ] || return 1
  tail -n +2 "$s" | (cd "$1" && shasum -a 256 -c --status - 2> /dev/null)
}
engine_state() { # $1 court dir, $2 engine -> 0|1|2
  case $2 in
    typst) tdir="$1/typst" ;;
    latex) tdir="$1/latex" ;;
    docx) tdir="$1/docx" ;;
  esac
  has_template "$tdir" || {
    printf 0
    return
  }
  [ -n "$(pdfs "$1" "$2")" ] || {
    printf 0
    return
  }
  if stamp_valid "$1" "$2"; then printf 2; else printf 1; fi
}

# "n|alias|group" in index order (n = position, used to sort the walk)
ORDER=$(jq -r '.courts | to_entries | to_entries[] | "\(.key)|\(.value.key)|\(.value.value.group)"' data/index.json)

# sort "alias|..." lines into data/index.json order (extra sort keys in "$@"), inserting the group after the alias
in_order() {
  awk -F'|' -v OFS='|' -v order="$ORDER" '
    BEGIN { n = split(order, ls, "\n"); for (i = 1; i <= n; i++) { split(ls[i], a, "|"); o[a[2]] = a[1]; g[a[2]] = a[3] } }
    { $1 = o[$1] "|" $1 "|" g[$1]; print }
  ' | sort -t'|' -k1,1n "$@" | cut -d'|' -f2-
}

# typst render state of doc-type folder $1: 0 none, 1 rendered, 2 rendered with a valid typst stamp
render_state() {
  [ -n "$(pdfs "$1" typst)" ] || {
    printf 0
    return
  }
  if stamp_valid "$1" typst; then printf 2; else printf 1; fi
}
doctype_flags() { # $1 folder
  t=0
  if [ -f "$1/typst/main.typ" ]; then t=1; fi
  printf '%s%s%s%s%s%s' "$t" "$(count "$1"/samples/INPUT-*.md)" "$(render_state "$1")" "$(count "$1"/exemplars/*.pdf)" \
    "$(count "$1"/samples/OVERLAY-*.pdf | sed 's/[2-9]/1/')" "$(count "$1"/reviews/*.md | sed 's/[2-9]/1/')"
}

if [ "$DOCTYPES" = 1 ]; then
  # doc types sort by name within a court; "(court root)" sorts first (byte order)
  export LC_ALL=C
  find courts -name court.json | while IFS= read -r cj; do
    d=$(dirname "$cj")
    a=$(jq -r .alias "$cj")
    [ ! -f "$d/typst/main.typ" ] || printf '%s|(court root)|%s|%s\n' "$a" "$d" "$(doctype_flags "$d")"
    for s in "$d"/*/; do
      s=${s%/}
      [ -d "$s" ] && [ ! -f "$s/court.json" ] || continue
      [ -d "$s/typst" ] || [ -d "$s/samples" ] || [ -d "$s/exemplars" ] || continue
      printf '%s|%s|%s|%s\n' "$a" "${s##*/}" "$s" "$(doctype_flags "$s")"
    done
  done | in_order -k2,2 -k4,4
  exit 0
fi

find courts -name court.json | while IFS= read -r cj; do
  d=$(dirname "$cj")
  meta=$(jq -r '[.alias, .level, (.name | gsub("[|\n]"; " ")), .path, (.status // "todo")] | join("|")' "$cj")
  flags="$(has_file "$d/rules.md")$(count "$d"/exemplars/*.pdf)$(count "$d"/samples/*.md)$(engine_state "$d" typst)$(engine_state "$d" latex)$(engine_state "$d" docx)$(count "$d"/samples/OVERLAY-*.pdf | sed 's/[2-9]/1/')$(count "$d"/reviews/*.md | sed 's/[2-9]/1/')"
  printf '%s|%s\n' "$meta" "$flags"
done | in_order
