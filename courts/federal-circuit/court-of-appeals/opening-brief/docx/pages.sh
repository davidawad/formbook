#!/bin/sh
# Finds the page labels that the contents and the table of authorities need, in a rendered PDF of the .docx.
# Usage: sh docx/pages.sh <rendered.pdf> <patterns.txt>   (writes "id<TAB>value" lines and _body_end, _cert_start)
# Modes (one per needle, written by cafc-docx.lua): first = first page of the area that has the needle;
# top = the needle is in the first 300 characters of the page (a heading); notoc = first page of the area with the
# needle that is not a table-of-contents page; all = every page of the area with the needle (a citation).
# Areas: front = roman labels, body = arabic labels up to the page that has the signature, add = Add- labels.
set -eu
PDF=$1
PAT=$2
LC_ALL=C
export LC_ALL
N=$(pdfinfo "$PDF" | awk '/^Pages:/{print $2}')
T=$(mktemp)
trap 'rm -f "$T"' EXIT
p=1
while [ "$p" -le "$N" ]; do
  pdftotext -f "$p" -l "$p" -layout "$PDF" - | awk -v p="$p" '
    { line[NR] = $0 }
    END {
      label = ""
      for (i = NR; i >= 1; i--) {
        s = line[i]; gsub(/^[ \t\f\r]+|[ \t\f\r]+$/, "", s)
        if (s != "") { label = s; break }
      }
      if (label !~ /^([ivxlcdm]+|[0-9]+|Add-[0-9]+)$/) label = ""
      all = ""
      for (i = 1; i <= NR; i++) {
        s = line[i]; gsub(/[ \t\f\r]+/, " ", s); gsub(/^ | $/, "", s)
        if (s != "") all = all (all == "" ? "" : "\036") toupper(s)
      }
      printf "%d\t%s\t%s\n", p, label, all
    }' >> "$T"
  p=$((p + 1))
done
awk -F'\t' -v PATFILE="$PAT" '
  function cls(l) {
    if (l ~ /^[ivxlcdm]+$/) return "front"
    if (l ~ /^[0-9]+$/) return "body"
    if (l ~ /^Add-[0-9]+$/) return "add"
    return ""
  }
  # a heading is a whole line of its page: its label and title, or the first line of a title that wraps
  function line_hit(t, nd,   n, ls, k, l) {
    n = split(t, ls, "\036")
    for (k = 1; k <= n; k++) {
      l = ls[k]
      sub(/^[A-Z0-9()]{1,6}\. /, "", l)
      if (l == nd) return 1
      if (length(l) >= 15 && index(nd, l) == 1) return 1
    }
    return 0
  }
  { idx[NR] = $1; lab[NR] = $2; txt[NR] = $3; flat[NR] = $3; gsub(/\036/, " ", flat[NR]); np = NR }
  END {
    # the body ends on the last arabic page that carries the signature ("Respectfully submitted")
    body_end = 0
    for (i = 1; i <= np; i++) {
      if (lab[i] ~ /^[0-9]+$/ && index(flat[i], "RESPECTFULLY SUBMITTED") > 0 && lab[i] + 0 > body_end) body_end = lab[i] + 0
    }
    if (body_end == 0) { for (i = 1; i <= np; i++) if (lab[i] ~ /^[0-9]+$/ && lab[i] + 0 > body_end) body_end = lab[i] + 0 }
    while ((getline pl < PATFILE) > 0) {
      n = split(pl, f, "\t")
      if (n < 4) continue
      mode = f[1]; area = f[2]; id = f[3]; needle = f[4]
      if (!(id in seen_id)) { seen_id[id] = 1; order[++no] = id }
      for (i = 1; i <= np; i++) {
        c = cls(lab[i])
        if (c == "") continue
        if (area == "body" && c != "body") continue
        if (area == "body" && (lab[i] + 0) > body_end) continue
        if (area == "front" && c != "front") continue
        if (area == "add" && c != "add") continue
        if (mode == "line") {
          if (!line_hit(txt[i], needle)) continue
          if (!(id in val) || val[id] == "") { val[id] = lab[i] }
          continue
        }
        hit = index(flat[i], needle)
        if (hit == 0) continue
        if (mode == "top" && hit > 60) continue
        if (mode == "notoc" && index(flat[i], "TABLE OF CONTENTS") > 0) continue
        if (mode == "all") {
          key = id SUBSEP lab[i]
          if (!(key in got)) { got[key] = 1; val[id] = (id in val && val[id] != "") ? val[id] ", " lab[i] : lab[i] }
          continue
        }
        if (!(id in val) || val[id] == "") { val[id] = lab[i] }
        if (mode != "all") { first_done[id] = 1 }
      }
    }
    for (k = 1; k <= no; k++) {
      id = order[k]
      v = (id in val) ? val[id] : ""
      if (index(id, "t:") == 1) {
        cnt = split(v, parts, ", ")
        if (v != "" && cnt >= 7) v = "passim"
      }
      printf "%s\t%s\n", id, v
    }
    printf "_body_end\t%d\n", body_end
    printf "_cert_start\t%d\n", body_end + 1
  }' "$T"
