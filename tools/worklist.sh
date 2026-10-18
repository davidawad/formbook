#!/usr/bin/env bash
# Generate data/worklist.json: every open unit of work in the formbook tree.
#
# Usage: sh tools/worklist.sh [--stdout] [--check]
#   (default) write data/worklist.json
#   --stdout  print instead of writing
#   --check   exit 1 if data/worklist.json is stale (CI / PR hygiene)
#
# A unit is one (court, doc type) pair. Its id is "<court alias>.<doctype>", which is also the claim
# branch suffix (contrib/<id>). Needs: sh, jq; poppler's pdfinfo is optional (without it, no deepen units).
#
# Per (court, doctype), looking at courts/<court>/<doctype>/:
#   no folder, doctype is `core` for the court's level   -> kind new-template, priority high
#   no folder, doctype is `extended` for the level       -> kind new-doctype,  priority normal
#   folder, no typst/*.typ                               -> kind new-template, priority high (exemplar may exist)
#   folder + template, no usage/FILED-EXAMPLE-*.pdf             -> kind add-exemplar, priority high
#   folder + template + FILED-EXAMPLE, longest usage/OUTPUT-*.typst.pdf shorter than the doc type's min_pages
#                                                        -> kind deepen,       priority low
#   anything else                                        -> complete, not listed
# Vocabulary: data/doctypes.json. Courts: data/index.json. Court order: data/priority.json.
# Output is deterministic (no timestamps), sorted by id, so regenerating produces a clean diff.
# Strict mode. pipefail only where the shell has it (bash, macOS sh); Debian's dash lacks it.
# shellcheck shell=sh disable=SC3040
set -e -u; (set -o pipefail) 2> /dev/null && set -o pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

MODE='write'
for a in "$@"; do
  case $a in
    --stdout) MODE=stdout ;;
    --check) MODE=check ;;
    *)
      echo "usage: tools/worklist.sh [--stdout|--check]" >&2
      exit 2
      ;;
  esac
done

HAVE_PDFINFO=0
command -v pdfinfo > /dev/null 2>&1 && HAVE_PDFINFO=1

# recursive delete of one directory; an empty path aborts instead of deleting the wrong thing
safe_rmdir() { rm -r -f -- "${1:?safe_rmdir: empty path}"; }
TMP=$(mktemp -d) || exit 1
trap 'safe_rmdir "$TMP"' EXIT

# longest typst-engine OUTPUT pdf in folder $1, in pages (0 if none or no pdfinfo)
max_pages() {
  best=0
  [ "$HAVE_PDFINFO" = 1 ] || {
    echo 0
    return
  }
  for o in "$1"/usage/OUTPUT-*.typst.pdf; do
    [ -f "$o" ] || continue
    p=$(pdfinfo "$o" 2> /dev/null | awk '/^Pages:/ {print $2}') || p=""
    [ -n "$p" ] && [ "$p" -gt "$best" ] && best=$p
  done
  echo "$best"
}

# 1. facts: one line per existing doctype folder:  alias<TAB>doctype<TAB>has_typ<TAB>n_exemplars<TAB>pages
jq -r '.courts | to_entries[] | "\(.key)\t\(.value.path)"' data/index.json | while IFS="$(printf '\t')" read -r alias path; do
  for d in "$path"/*/; do
    [ -d "$d" ] || continue
    d=${d%/}
    b=${d##*/}
    case $b in typst | latex | docx | usage | reviews) continue ;; esac
    [ -f "$d/court.json" ] && continue # a nested court, not a doc type
    t=0
    for f in "$d"/typst/*.typ; do [ -f "$f" ] && t=1; done
    n=0
    for f in "$d"/usage/FILED-EXAMPLE-*.pdf; do [ -f "$f" ] && n=$((n + 1)); done
    printf '%s\t%s\t%s\t%s\t%s\n' "$alias" "$b" "$t" "$n" "$(max_pages "$d")"
  done
done > "$TMP/facts.tsv"

# 2. assemble
jq -n -c --rawfile facts "$TMP/facts.tsv" \
  --slurpfile idx data/index.json --slurpfile dt data/doctypes.json --slurpfile pr data/priority.json '
  def rank: ($pr[0].order // []) as $o | . as $a | ($o | index($a)) // ($o | length);
  ($idx[0].courts) as $courts
  | ($dt[0]) as $voc
  | ($facts | split("\n") | map(select(length > 0) | split("\t"))
      | map({key: (.[0] + "." + .[1]), value: {has_typ: (.[2] == "1"), n_ex: (.[3] | tonumber), pages: (.[4] | tonumber)}})
      | from_entries) as $have
  | [ $courts | to_entries[] | .key as $alias | .value as $c
      | ($voc.levels[$c.level] // {core: [], extended: []}) as $lv
      | ( ($lv.core | map({d: ., tier: "core"})) + ($lv.extended | map({d: ., tier: "extended"})) ) as $want
      | ( $want
          | map(select(($have[$alias + "." + .d]) | not))
          | map({alias: $alias, doctype: .d, tier: .tier, kind: (if .tier == "core" then "new-template" else "new-doctype" end),
                 priority: (if .tier == "core" then "high" else "normal" end), note: "no folder yet"}) )
        + ( [ $have | to_entries[] | select(.key | startswith($alias + ".")) | {d: (.key | ltrimstr($alias + ".")), v: .value} ]
            | map(. as $f
                | ($want | map(select(.d == $f.d)) | .[0].tier // "other") as $tier
                | ($voc.doctypes[$f.d].min_pages // 2) as $min
                | if ($f.v.has_typ | not) then
                    {alias: $alias, doctype: $f.d, tier: $tier, kind: "new-template", priority: "high",
                     note: (if $f.v.n_ex > 0 then "folder has an exemplar but no typst template" else "folder exists but has no typst template and no exemplar" end)}
                  elif $f.v.n_ex == 0 then
                    {alias: $alias, doctype: $f.d, tier: $tier, kind: "add-exemplar", priority: "high",
                     note: "template exists but no usage/FILED-EXAMPLE-*.pdf (BLOCKED: no exemplar)"}
                  elif $f.v.pages > 0 and $f.v.pages < $min then
                    {alias: $alias, doctype: $f.d, tier: $tier, kind: "deepen", priority: "low",
                     note: "longest sample is \($f.v.pages) pages; a realistic \($f.d) runs about \($min)+"}
                  else empty end) )
        | map(. + {court_path: $c.path, court_name: $c.name, level: $c.level, court_rank: ($alias | rank)})
      ]
  | add
  | map({id: (.alias + "." + .doctype), kind, alias, court_path, level, doctype,
         title: ($voc.doctypes[.doctype].title // .doctype), folder: (.court_path + "/" + .doctype),
         status: "open", priority, court_rank, note})
  | sort_by(.id)
  | {schema: 1, generated_by: "tools/worklist.sh", count: length,
     counts: (group_by(.kind) | map({key: .[0].kind, value: length}) | from_entries), units: .}
' > "$TMP/raw.json"
# one unit per line so diffs of the committed file stay reviewable
{
  jq -r '"{\"schema\": \(.schema), \"generated_by\": \(.generated_by | tojson), \"count\": \(.count), \"counts\": \(.counts | tojson),\n\"units\": ["' "$TMP/raw.json"
  jq -r '.units | to_entries[] | (if .key == 0 then "" else "," end) + (.value | tojson)' "$TMP/raw.json"
  echo ']}'
} > "$TMP/worklist.json"
jq -e . "$TMP/worklist.json" > /dev/null

case $MODE in
  stdout) cat "$TMP/worklist.json" ;;
  check)
    cmp -s "$TMP/worklist.json" data/worklist.json || {
      echo "worklist.sh: data/worklist.json is stale; run: sh tools/worklist.sh" >&2
      exit 1
    }
    echo "worklist.json is current"
    ;;
  write)
    cp "$TMP/worklist.json" data/worklist.json
    jq -r '"wrote data/worklist.json: \(.count) open units " + (.counts | tostring)' data/worklist.json
    ;;
esac
