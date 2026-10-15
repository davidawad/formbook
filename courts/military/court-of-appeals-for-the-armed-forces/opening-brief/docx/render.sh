#!/bin/sh
# DOCX engine for the CAAF doc types (docs/DOCX.md). Owns the .docx: called by tools/render-docx.sh as
#   sh docx/render.sh <court-dir> <sample.md, relative to the court dir> <out.docx>
# Three pandoc/LibreOffice passes, because the index and the table of authorities print body page numbers:
#   1. pandoc (armfor.lua writes the search items: one per heading, one per authority link); LibreOffice
#      renders it to PDF;
#   2. the items are searched in the body pages (pdftotext; the body starts at the first page whose last
#      line is a number) to give one body page per item;
#   3. pandoc writes the final .docx with those pages; LibreOffice renders it again, and the pages are
#      searched a second time: the pass fails if they differ from pass 2 (the layout must not move).
# Needs: pandoc, soffice, pdftotext, awk, and unzip/zip (tools/render-docx.sh checks the zip).
set -eu
D=$(cd "$(dirname "$0")" && pwd)
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUT=$3
case $OUT in /*) ;; *) OUT=$(pwd)/$OUT ;; esac
KIND=$(basename "$COURT")
case $KIND in
  opening-brief | petition-supplement) ;;
  *) echo "docx/render.sh: unknown doc type $KIND" >&2; exit 1 ;;
esac
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
W=$(mktemp -d)
trap 'rm -rf "$W"' EXIT
cd "$COURT"

to_pdf() { # docx, outdir
  "$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$2" "$1" > "$W/soffice.log" 2>&1 \
    || "$SOFFICE" "-env:UserInstallation=file://$W/profile" --headless --convert-to pdf --outdir "$2" "$1" > "$W/soffice.log" 2>&1 \
    || { cat "$W/soffice.log" >&2; echo "docx/render.sh: soffice failed on $1" >&2; exit 1; }
  echo "$2/$(basename "${1%.docx}").pdf"
}

# every page: "<pdf page> <normalized line>"; the search runs in awk (below)
page_lines() { # pdf, out
  n=$(pdfinfo "$1" | awk '/^Pages:/ {print $2}')
  : > "$2"
  p=1
  while [ "$p" -le "$n" ]; do
    pdftotext -f "$p" -l "$p" "$1" - | perl -pe "s/\xc2\xa0|\xe2\x80\xaf|\xe2\x80\x89/ /g" | awk -v p="$p" '{ gsub(/^[[:space:]]+|[[:space:]]+$/, ""); gsub(/[[:space:]]+/, " "); if ($0 != "") print p "\t" $0 }' >> "$2"
    p=$((p + 1))
  done
}

# the items (from pass 1, normalized) against the body pages: one body page per item, in order
find_pages() { # items, pagelines, out
  awk -F '\t' '
    FNR == NR { n++; typ[n] = $1; s[n] = substr($0, 3); next }
    {
      p = $1 + 0; line = substr($0, length($1) + 2)
      if (p > maxp) maxp = p
      cnt[p]++; ln[p, cnt[p]] = line
      last[p] = line
    }
    END {
      # the body starts at the first page whose last line is a number (the footer)
      start = 0
      for (p = 1; p <= maxp && !start; p++) if (last[p] ~ /^[0-9]+$/) start = p
      if (!start) { print "docx/render.sh: no body page found" > "/dev/stderr"; exit 1 }
      # the text of a page without its footer (a page number ends the page): a citation may run over the break
      for (p = 1; p <= maxp; p++) {
        flat[p] = ""
        for (k = 1; k <= cnt[p]; k++) {
          if (k == cnt[p] && ln[p, k] ~ /^([0-9]+|[ivxlc]+)$/) continue
          flat[p] = flat[p] " " ln[p, k]
        }
      }
      ch = start; ct = start; bad = 0
      for (i = 1; i <= n; i++) {
        found = 0
        if (typ[i] == "H") {
          pre = substr(s[i], 1, 40)
          for (p = ch; p <= maxp && !found; p++)
            for (k = 1; k <= cnt[p] && !found; k++)
            {
              # a heading starts a line, or follows its label ("A. " at the start of the line)
              m = index(ln[p, k], pre)
              if (m == 1 || (m > 1 && m <= 8 && substr(ln[p, k], 1, m - 1) ~ /^[A-Za-z0-9().]+ $/)) found = p
            }
          if (found) ch = found
        } else {
          for (p = ct; p <= maxp && !found; p++)
            {
              # a citation may run over a page break: the match is filed on the page where it starts
              if (index(flat[p], s[i]) > 0) found = p
              else {
                c = flat[p] flat[p + 1]; m = index(c, s[i])
                if (m > 0) found = (m > length(flat[p])) ? p + 1 : p
              }
            }
          if (found) ct = found
        }
        if (!found) { print "docx/render.sh: no page for " typ[i] " item: " s[i] > "/dev/stderr"; bad = 1; continue }
        print found - start + 1
      }
      exit bad
    }' "$1" "$2" > "$3"
}

# the items: the same normalization as the pages
normalize_items() { # in, out
  # shellcheck disable=SC2016
  perl -pe 's/\xc2\xa0|\xe2\x80\xaf|\xe2\x80\x89/ /g' "$1" | awk -F '\t' '{ t = $2; gsub(/[ \t]+/, " ", t); sub(/^ /, "", t); sub(/ $/, "", t); print $1 "\t" t }' > "$2"
}

# ---- pass 1 ----
ARMFOR_KIND=$KIND ARMFOR_ITEMS="$W/items.raw" pandoc --from markdown+smart --to docx \
  --reference-doc="$D/reference.docx" --lua-filter="$D/armfor.lua" "$SAMPLE" -o "$W/pass1.docx" || exit 1
normalize_items "$W/items.raw" "$W/items.txt"
PDF1=$(to_pdf "$W/pass1.docx" "$W")
page_lines "$PDF1" "$W/lines1.txt"
find_pages "$W/items.txt" "$W/lines1.txt" "$W/pages.txt" || exit 1

# ---- pass 2: the final document with the page numbers ----
ARMFOR_KIND=$KIND ARMFOR_PAGES="$W/pages.txt" pandoc --from markdown+smart --to docx \
  --reference-doc="$D/reference.docx" --lua-filter="$D/armfor.lua" "$SAMPLE" -o "$OUT" || exit 1

# ---- check: the page numbers hold on the final document ----
mkdir -p "$W/final"
PDF2=$(to_pdf "$OUT" "$W/final")
page_lines "$PDF2" "$W/lines2.txt"
find_pages "$W/items.txt" "$W/lines2.txt" "$W/pages2.txt" || exit 1
cmp -s "$W/pages.txt" "$W/pages2.txt" || { echo "docx/render.sh: the page numbers moved between passes" >&2; exit 1; }
echo "$OUT"
