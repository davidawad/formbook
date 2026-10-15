#!/bin/sh
# Renders the nyed memorandum of law to .docx (the DOCX engine contract: sh render.sh <court-dir> <sample.md> <out.docx>).
# Word has no page numbers for a TOC or TOA until fields are updated, so this script makes two passes:
#   pass 1: pandoc writes the .docx with placeholder page numbers; LibreOffice converts it to PDF.
#   read:   the page of each body heading and of each cited authority is found in that PDF (pdftotext; the
#           text is normalized to lowercase letters and digits, so curly quotes and line breaks do not matter).
#   pass 2: pandoc writes the .docx again with those numbers (NYED_PAGES). The body restarts at page 1 after
#           the front matter, so the numbers found in pass 1 are the final ones.
# Word count (LCR 7.1(c)) is counted here on the markdown and passed as NYED_WORDS; the build fails over the limit.
# Needs: pandoc, soffice (SOFFICE or PATH), pdfinfo, pdftotext, perl, awk, yq (mikefarah), jq.
# Limits: an authority is found by its first word (a case) or its last cite token (a rule or statute). A
# page where that word appears in the body is counted, so a common word can over-count; compare with the
# typst TOA before accepting a new authority list.
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
case $3 in /*) OUT=$3 ;; *) OUT=$(pwd)/$3 ;; esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$COURT"

# the word count as the template counts it (body markdown, footnotes included, no frontmatter)
WORDS=$(perl -e 'local $/; $_ = <STDIN>; s/\A---\r?\n.*?\r?\n---[ \t]*\r?\n//s; s/\]\(toa:[^)]*\)/]/g; s/\[\^[^\]]+\]:?/ /g; s/[#*_>]/ /g; my $n = 0; for (split /\s+/) { $n++ if /[A-Za-z0-9]/ } print "$n\n";' < "$SAMPLE")
LIMIT=$(yq --front-matter=extract '.word_limit // 8750' "$SAMPLE")
if [ "$WORDS" -gt "$LIMIT" ]; then
  echo "render.sh: $WORDS words exceeds the LCR 7.1(c) limit of $LIMIT" >&2
  exit 1
fi
export NYED_WORDS="$WORDS"

# pass 1
pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" --lua-filter="$D/nyed-motion-brief.lua" \
  "$SAMPLE" -o "$W/pass1.docx"
"$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$W" "$W/pass1.docx" \
  > "$W/soffice.log" 2>&1 || { cat "$W/soffice.log" >&2; echo "render.sh: LibreOffice failed on pass 1" >&2; exit 1; }
PDF=$W/pass1.pdf
N=$(pdfinfo "$PDF" | awk '/^Pages:/ { print $2 }')

# normalized text of each page: letters and digits only, lowercase, single spaces
norm() { perl -0pe 's/[^A-Za-z0-9 \n]+//g; s/\s+/ /g; $_ = lc'; }
i=1
while [ "$i" -le "$N" ]; do
  pdftotext -f "$i" -l "$i" "$PDF" - | norm > "$W/page$i.txt"
  i=$((i + 1))
done

# has PAGE KEY: the normalized key occurs on that page
has() {
  case " $(cat "$W/page$1.txt") " in
    *" $2 "*) return 0 ;;
  esac
  return 1
}

# the front matter ends before the page where the body's first heading is (the TOA page is the last
# front-matter page; the TOC has the same heading text, so the search starts after the TOA heading)
TOA_P=0
i=1
while [ "$i" -le "$N" ]; do
  if has "$i" "table of authorities"; then TOA_P=$i; break; fi
  i=$((i + 1))
done
[ "$TOA_P" -gt 0 ] || { echo "render.sh: no TABLE OF AUTHORITIES page in pass 1" >&2; exit 1; }

# the body's headings: the markdown lines that start with #, after the frontmatter
awk 'BEGIN { d = 0 } /^---[ \t]*$/ && d < 2 { d++; next } d >= 2 && /^#/ { print }' "$SAMPLE" > "$W/heads.txt"
# a heading's search key: its text without the hashes and the label, normalized (the whole heading: a shorter prefix
# can match two different headings, as "Plaintiffs Fail to Make a Prima Facie Showing" does for A and B)
keyof() {
  sed -E 's/^#+[[:space:]]+//; s/^([IVXLCDMivxlcdm]+|[A-Za-z]|[0-9]+)\.[[:space:]]+//' | norm | sed 's/^ //; s/ $//'
}

FIRST_KEY=$(head -n 1 "$W/heads.txt" | keyof)
BODY0=$((TOA_P + 1))
while [ "$BODY0" -le "$N" ] && ! has "$BODY0" "$FIRST_KEY"; do BODY0=$((BODY0 + 1)); done
[ "$BODY0" -le "$N" ] || { echo "render.sh: the body's first heading is not in pass 1" >&2; exit 1; }

: > "$W/pages.tsv"
ord=0
prev=$BODY0
while IFS= read -r line; do
  ord=$((ord + 1))
  key=$(printf '%s\n' "$line" | keyof)
  p=$prev
  found=0
  while [ "$p" -le "$N" ]; do
    if has "$p" "$key"; then found=$p; break; fi
    p=$((p + 1))
  done
  [ "$found" -gt 0 ] || { echo "render.sh: heading not found in pass 1: $line" >&2; exit 1; }
  printf 'H\t%s\t%s\n' "$ord" "$((found - BODY0 + 1))" >> "$W/pages.tsv"
  prev=$found
done < "$W/heads.txt"

# the authorities: the first word of a case name, or the last token of a rule or statute cite
yq --front-matter=extract -o=json '.authorities // {}' "$SAMPLE" |
  jq -r 'to_entries[] | [.key, (if .value.kind == "case" then (.value.name | split(" ") | .[0]) else (.value.cite | split(" ") | last) end)] | @tsv' |
  while IFS="$(printf '\t')" read -r key tok; do
    tok=$(printf '%s' "$tok" | norm)
    pages=""
    p=$BODY0
    while [ "$p" -le "$N" ]; do
      if has "$p" "$tok"; then
        pages="$pages${pages:+, }$((p - BODY0 + 1))"
      fi
      p=$((p + 1))
    done
    if [ -n "$pages" ]; then printf "A\t%s\t%s\n" "$key" "$pages" >> "$W/pages.tsv"; fi
  done

# pass 2
NYED_PAGES="$W/pages.tsv" pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" \
  --lua-filter="$D/nyed-motion-brief.lua" "$SAMPLE" -o "$OUT"
echo "$OUT"
