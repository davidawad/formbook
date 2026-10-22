#!/usr/bin/env bash
# docx/render.sh <court-dir> <sample.md> <out.docx>   (the court's own build, called by tools/render-docx.sh)
#
# Builds the brief as a .docx from the sample's frontmatter and body:
#   front.jq    the cover, the front matter (disclosure, certifications) and the back matter (signature,
#               certificate of compliance, certificate of service), as pandoc markdown;
#   body        the sample's markdown, unchanged;
#   brief.lua   heading labels and styles, the table of contents and the table of authorities.
# The TOC and TOA page numbers are measured, not guessed: the .docx is converted with LibreOffice, each body
# heading and each authority is found on its page, and the build repeats until the numbers stop changing.
# Needs: pandoc, soffice (LibreOffice), pdfinfo, pdftotext, jq, yq (mikefarah), perl, awk, xmllint, zip, unzip.
set -euo pipefail
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$PWD/$OUT ;; esac
SRC=$COURT/$SAMPLE
[ -f "$SRC" ] || { echo "render.sh: no sample $SRC" >&2; exit 1; }
SOFFICE=${SOFFICE:-$(command -v soffice || true)}
[ -n "$SOFFICE" ] || { echo "render.sh: soffice (LibreOffice) not found" >&2; exit 1; }
for tool in pandoc pdfinfo pdftotext jq yq perl awk xmllint zip unzip; do
  command -v "$tool" > /dev/null || { echo "render.sh: $tool not found" >&2; exit 1; }
done
W=$(mktemp -d) || exit 1
# safe_rmdir <dir>: delete a directory made by mktemp -d, and nothing else
safe_rmdir() {
  t=${TMPDIR:-/tmp}
  case "${1:?}" in
    "${t%/}"/tmp.* | /tmp/tmp.*) find "$1" -depth -delete ;;
    *) return 1 ;;
  esac
}
trap 'safe_rmdir "$W"' EXIT

# ---- 1. split the sample: frontmatter (YAML) and body (markdown) ----
: > "$W/meta.yaml"
: > "$W/body.md"
awk -v M="$W/meta.yaml" -v B="$W/body.md" '
  NR == 1 { if ($0 != "---") { print "render.sh: the sample must start with a YAML frontmatter block" > "/dev/stderr"; exit 2 }; inmeta = 1; next }
  inmeta && $0 == "---" { inmeta = 0; closed = 1; next }
  inmeta { print > M; next }
  { print > B }
  END { if (!closed) { print "render.sh: the frontmatter is not closed" > "/dev/stderr"; exit 2 } }
' "$SRC"
yq -o=json '.' "$W/meta.yaml" > "$W/meta.json"

# ---- 2. word count (typst count-words rule: the oral argument statement is not counted, FRAP 32(f)) ----
awk '
  /^#[ \t]+.*[Oo]ral [Aa]rgument/ { skip = 1; next }
  skip && /^#[ \t]/ { skip = 0 }
  !skip { print }
' "$W/body.md" > "$W/count.md"
# the typst template's count-words, rule for rule, so both engines certify the same number
WORDS=$(perl -CSD -0777 -ne '
  s/<!--.*?-->/ /gs;
  s/^\[\^[^\]]+\]:/ /gm;                  # footnote definition labels
  s/\[\^[^\]]+\]//g;                      # footnote references
  s/\[([^\]]*)\]\([^)]*\)/$1/g;           # links keep their text
  s/^#{1,6}[ \t]+//gm;
  s/^>[ \t]?//gm;
  s/^[ \t]*(?:[-*+]|[0-9]+[.)])[ \t]+//gm; # list markers are not words
  s/\\(.)/$1/g;                           # backslash escapes
  s/\*//g;
  s/(^|[\s(\[\x{201C}"])_/$1/g;
  s/_([\s.,;:)\]\x{201D}"!?]|$)/$1/g;
  my $n = grep { $_ ne "" } split /\s+/;
  print $n;' "$W/count.md")
case $(basename "$COURT") in
  reply-brief) LIMIT=6500 ;;   # FRBP 8015(a)(7)(B)(ii): half the principal-brief limit
  *) LIMIT=13000 ;;            # FRBP 8015(a)(7)(B)(i)
esac
[ "$WORDS" -le "$LIMIT" ] || { echo "render.sh: the brief has $WORDS words; FRBP 8015(a)(7)(B) allows $LIMIT" >&2; exit 1; }
WORDS_FMT=$(printf '%s' "$WORDS" | sed -E ':a;s/([0-9])([0-9]{3})($|,)/\1,\2\3/;ta')

# ---- 3. the cover, front matter and back matter (front.jq) ----
jq -f "$D/front.jq" --arg words "$WORDS_FMT" "$W/meta.json" > "$W/parts.json"
jq -r '.cover' "$W/parts.json" > "$W/cover.md"
jq -r '.front' "$W/parts.json" > "$W/front.md"
jq -r '.back' "$W/parts.json" > "$W/back.md"

# ---- 4. headings, citations and the authorities cited (the page map's keys) ----
grep -E '^#{1,5}[[:space:]]' "$W/body.md" | sed -E 's/^#+[[:space:]]+//' > "$W/heads.txt" || true
# Each citation as a needle for the page map: its link text and the first letters and digits after it in its paragraph
# (up to a footnote mark), or, at the end of a paragraph, the ones before it; so the same words elsewhere in the brief,
# unlinked, are not taken for it (typst counts the links only).
perl -0777 -ne '
  sub alnum { my $s = shift; $s =~ s/\[([^\]]*)\]\([^)]*\)/$1/g; $s = lc $s; $s =~ s/[^a-z0-9]//g; $s }
  while (/\[((?:[^\[\]]|\[[^\]]*\])+)\]\(toa:([A-Za-z0-9_]+)\)/g) {
    my ($t, $k, $end, $start) = ($1, $2, pos(), $-[0]);
    my $after = substr($_, $end, 300); $after =~ s/\n.*//s; $after =~ s/\[\^.*//s;
    my $a = substr(alnum($after), 0, 14);
    my $pre = "";
    if (length($a) < 6) {
      my $from = $start > 300 ? $start - 300 : 0;
      my $before = substr($_, $from, $start - $from); $before =~ s/.*\n//s;
      $pre = alnum($before); $pre = substr($pre, -14) if length($pre) > 14;
    }
    print "$k\t" . $pre . alnum($t) . $a . "\n";
  }' "$W/body.md" > "$W/links.tsv"
perl -0777 -ne 'while (/\(toa:([A-Za-z0-9_]+)\)/g) { print "$1\n" }' "$W/body.md" | awk '!s[$0]++' > "$W/keys.txt"
: > "$W/T.tsv"
while IFS= read -r k; do
  rec=$(jq -r --arg k "$k" '.authorities[$k] | if . == null then error("none") else "\(.kind)\t\(.cite)" end' "$W/meta.json") || {
    echo "render.sh: link toa:$k has no entry under authorities: in the frontmatter" >&2; exit 1; }
  printf 'T\t%s\t%s\n' "$k" "$rec" >> "$W/T.tsv"
done < "$W/keys.txt"

# ---- 5. the page map: H (body headings, in order), T (authorities), A (their pages) ----
write_map() {  # $1 = H file, $2 = A file (key TAB pages), $3 = map out
  { awk '{ print "H\t" $0 }' "$1"; cat "$W/T.tsv"; awk -F'\t' '{ print "A\t" $1 "\t" $2 }' "$2"; } > "$3"
}

# ---- 6. build the .docx for one map ----
build() {  # $1 = map, $2 = out docx
  # the last body paragraph is kept with the signature block (typst: block(breakable: false, ...))
  awk '
    { line[NR] = $0 }
    END {
      last = NR; while (last > 0 && line[last] ~ /^[ \t]*$/) last--
      start = last; while (start > 1 && line[start - 1] ~ /[^ \t]/) start--
      first = line[start]
      keep = !(first ~ /^#/ || first ~ /^\[\^/ || first ~ /^<!--/ || first ~ /^>/ || first ~ /^:::/ || first ~ /^[-*+] / || first ~ /^[0-9]+[.)] /)
      for (i = 1; i < start; i++) print line[i]
      if (keep) { print "::: {custom-style=\"BodyKeep\"}"; for (i = start; i <= last; i++) print line[i]; print ":::" }
      else { for (i = start; i <= last; i++) print line[i] }
      for (i = last + 1; i <= NR; i++) print line[i]
    }
  ' "$W/body.md" > "$W/body-keep.md"
  cat "$W/cover.md" "$W/front.md" "$W/body-keep.md" > "$W/main.md"
  printf '\n\n' >> "$W/main.md"
  cat "$W/back.md" >> "$W/main.md"
  BAP8_MAP="$1" pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
    --lua-filter="$D/brief.lua" "$W/main.md" -o "$2" || { echo "render.sh: pandoc failed" >&2; exit 1; }
  finish "$2"
}

# the footer relationship id is whatever pandoc chose; put it where the section properties ask for it
finish() {  # $1 = docx, rewritten in place
  X=$(mktemp -d "$W/unpack.XXXXXX") || exit 1
  unzip -q "$1" -d "$X"
  FID=$(perl -0ne 'while (/<Relationship\b[^>]*\/>/g) { my $r = $&; if ($r =~ /\/footer"/ && $r =~ /Id="([^"]+)"/) { print $1; last } }' "$X/word/_rels/document.xml.rels")
  [ -n "$FID" ] || { echo "render.sh: no footer part in the output" >&2; exit 1; }
  perl -pi -e 's/r:id="rIdBapFooter"/r:id="'"$FID"'"/g' "$X/word/document.xml"
  find "$X" -type f \( -name '*.xml' -o -name '*.rels' \) | while IFS= read -r part; do
    xmllint --noout "$part" 2> /dev/null || { echo "render.sh: ${part#"$X"/} is not well-formed" >&2; exit 1; }
  done
  rm -f "$1"
  (cd "$X" && zip -q -X "$1" '[Content_Types].xml' && zip -q -X -r "$1" . -x '[Content_Types].xml')
}

# ---- 7. LibreOffice PDF of a docx, and the page numbers measured on it ----
to_pdf() {  # $1 = docx, $2 = out dir
  mkdir -p "$2"
  "$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$2" "$1" > "$W/soffice.log" 2>&1 || {
    cat "$W/soffice.log" >&2; echo "render.sh: LibreOffice failed" >&2; exit 1; }
  [ -f "$2/$(basename "${1%.docx}").pdf" ] || { echo "render.sh: no PDF from LibreOffice" >&2; exit 1; }
}

# heading_hit NEEDLE PAGE: true when a line of the page is the heading (or its first wrapped line), after
# the label ("I.", "A.", "1.", "(1)") is taken off the line. Whole lines, so "Argument" is not found in
# "Summary of Argument".
heading_hit() {
  awk -v N="$1" '
    function norm(s) { s = tolower(s); gsub(/[^a-z0-9]+/, " ", s); sub(/^ /, "", s); sub(/ $/, "", s); return s }
    {
      L = norm($0); S = L
      sub(/^([ivxlcdm]+|[a-z]|[0-9]+) /, "", S)
      if (L == N || S == N) found = 1
      if (length(L) >= 15 && index(N, L) == 1) found = 1
      if (length(S) >= 15 && index(N, S) == 1) found = 1
    }
    END { exit !found }
  ' "$M/raw$2.txt"
}

# hit_on NEEDLE PAGE: true when the needle starts on that page (it may run over to the next one)
hit_on() {
  q=$(( $2 + 1 )); [ "$q" -le "$N" ] || q=$2
  grep -q "$1" "$M/n$2.txt" && return 0
  [ "$q" -ne "$2" ] || return 1
  cat "$M/n$2.txt" "$M/n$q.txt" | grep -q "$1" && ! grep -q "$1" "$M/n$q.txt"
}

# measure PDF: sets N and BODY_START, writes $W/H.new (body heading pages) and $W/A.new (authority pages)
measure() {
  M=$(mktemp -d "$W/m.XXXXXX") || exit 1
  N=$(pdfinfo "$1" | awk '/^Pages:/ { print $2 }')
  last_front=0
  p=1
  while [ "$p" -le "$N" ]; do
    pdftotext -f "$p" -l "$p" "$1" "$M/raw$p.txt"
    if grep -Eq '(\. ?){5,}' "$M/raw$p.txt"; then last_front=$p; fi   # dot leaders: the TOC and TOA pages
    # the text of the page without its footer (the page number is the last line), normalized to a-z0-9
    tr -d '\f' < "$M/raw$p.txt" | awk 'NF { line[++n] = $0 } END { if (n > 0 && line[n] ~ /^[ivxlcdmIVXLCDM0-9]+$/) n--; for (i = 1; i <= n; i++) print line[i] }' \
      | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9' > "$M/n$p.txt"
    p=$((p + 1))
  done
  BODY_START=$((last_front + 1))
  : > "$W/H.new"
  cur=$BODY_START
  while IFS= read -r title; do
    needle=$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9' ' ' | tr -s ' ' | sed 's/^ //; s/ $//')
    [ -n "$needle" ] || { echo "render.sh: a heading has no letters or digits: $title" >&2; exit 1; }
    found=""
    p=$cur
    while [ "$p" -le "$N" ]; do
      if heading_hit "$needle" "$p"; then found=$p; break; fi
      p=$((p + 1))
    done
    [ -n "$found" ] || { echo "render.sh: heading not found in the PDF: $title" >&2; exit 1; }
    echo $((found - BODY_START + 1)) >> "$W/H.new"
    cur=$found
  done < "$W/heads.txt"
  : > "$W/A.new"
  while IFS= read -r k; do
    awk -F'\t' -v k="$k" '$1 == k { print $2 }' "$W/links.tsv" | while IFS= read -r t; do
      nn=$(printf '%s' "$t" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9')
      [ -n "$nn" ] || continue
      p=$BODY_START
      while [ "$p" -le "$N" ]; do
        if hit_on "$nn" "$p"; then echo $((p - BODY_START + 1)); fi
        p=$((p + 1))
      done
    done | sort -n -u > "$M/hits"
    count=$(wc -l < "$M/hits" | tr -d ' ')
    [ "$count" -gt 0 ] || { echo "render.sh: authority $k is not found on any body page" >&2; exit 1; }
    if [ "$count" -ge 7 ]; then pages=passim; else pages=$(paste -sd, "$M/hits" | sed 's/,/, /g'); fi
    printf '%s\t%s\n' "$k" "$pages" >> "$W/A.new"
  done < "$W/keys.txt"
}

# ---- 8. iterate: map 0 (placeholder pages), then the measured pages until they are stable ----
awk '{ print "0" }' "$W/heads.txt" > "$W/H.0"
awk '{ print $1 "\t0" }' "$W/keys.txt" > "$W/A.0"
write_map "$W/H.0" "$W/A.0" "$W/map.0"
cp "$W/map.0" "$W/map.cur"
FINAL=""
i=1
while [ "$i" -le 5 ]; do
  build "$W/map.cur" "$W/pass$i.docx"
  to_pdf "$W/pass$i.docx" "$W/pdf$i"
  measure "$W/pdf$i/pass$i.pdf"
  write_map "$W/H.new" "$W/A.new" "$W/map.next"
  if cmp -s "$W/map.cur" "$W/map.next"; then FINAL=$W/pass$i.docx; break; fi
  cp "$W/map.next" "$W/map.cur"
  i=$((i + 1))
done
[ -n "$FINAL" ] || { echo "render.sh: the page numbers did not settle after 5 passes" >&2; exit 1; }
cp "$FINAL" "$OUT"
echo "$OUT"
