#!/bin/sh
# Audit the body font of every filed exemplar and classify how exactly we can reproduce it.
# Usage: tools/exemplar-fonts.sh [out.json]   (default data/exemplar-fonts.json)
#
# For each courts/**/exemplars/FILED-EXAMPLE-*.pdf:
#   body      the font family carrying the most characters (pdftohtml -xml, every page; the
#             subset tag and the style/PS suffixes are dropped, so TimesNewRomanPS-BoldMT counts
#             as TimesNewRoman). The ECF header stamp is short and never wins.
#   fonts     every embedded font name pdffonts lists (subset tag dropped), sorted, unique
#   class     metric-exact  we have the face itself or a metric-compatible one (identical advance
#                           widths), so line breaks can match the filing
#             approximate   a near-metric clone (same design lineage, widths differ slightly)
#             impossible    no redistributable face with these metrics (Monotype Garamond,
#                           Aptos, Century Expanded, ...), or no text layer (scanned / OCR only)
#   face      what a template should ask for (docs/FONTS.md)
# Sources: pdffonts, pdftohtml (poppler), gawk, jq. No network.
set -eu
ROOT=$(cd "$(dirname "$0")/.." && pwd)
OUT=${1:-$ROOT/data/exemplar-fonts.json}
ID=$ROOT/data/exemplar-fonts-identified.tsv
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT
cd "$ROOT"
find courts -name 'FILED-EXAMPLE-*.pdf' | LC_ALL=C sort | while IFS= read -r f; do
  fonts=$(pdffonts "$f" 2>/dev/null | awk 'NR > 2 { sub(/^[A-Z][A-Z][A-Z][A-Z][A-Z][A-Z]\+/, "", $1); print $1 }' | LC_ALL=C sort -u | paste -sd' ' -)
  # pages among the first twelve (the pages the body font is read from) that carry a page-sized raster of real content (a scan, possibly
  # OCRed); blank page-sized backgrounds a few hundred bytes long do not count
  scans=$(pdfimages -list -l 12 "$f" 2>/dev/null | awk 'NR > 2 { b = $15 + 0; if ($15 ~ /K/) b *= 1024; if ($15 ~ /M/) b *= 1048576; if ($4 >= 1000 && $5 >= 1300 && b >= 8192) p[$1] = 1 } END { print length(p) }')
  pages=$(pdfinfo "$f" 2>/dev/null | awk '/^Pages:/ { print ($2 < 12 ? $2 : 12) }')
  pdftohtml -xml -i -q -stdout -l 12 "$f" 2>/dev/null | gawk -v file="$f" -v fonts="$fonts" -v scans="$scans" -v pages="${pages:-0}" -v idfile="$ID" '
    BEGIN {
      FS = "\t"
      while ((getline line < idfile) > 0) {
        split(line, a, "\t")
        if (a[1] == file) { idf[a[2]] = a[3]; ide[a[2]] = a[4] }
      }
      FS = " "
    }
    function norm(s) {
      sub(/^[A-Z]{6}\+/, "", s)
      s = tolower(s)
      gsub(/[^a-z0-9+]/, "", s)
      while (sub(/(bold|italic|oblique|regular|semibold|light|medium|black|condensed|narrow|ps|mt|psmt|std|ltstd|lt|it|bd|bi|ms|wpm)$/, "", s)) {}
      return s
    }
    /<fontspec / {
      match($0, /id="[^"]*"/); id = substr($0, RSTART + 4, RLENGTH - 5)
      match($0, /family="[^"]*"/); fam[id] = norm(substr($0, RSTART + 8, RLENGTH - 9))
    }
    /<text / {
      match($0, /font="[^"]*"/); id = substr($0, RSTART + 6, RLENGTH - 7)
      t = $0; sub(/^<text[^>]*>/, "", t); gsub(/<[^>]*>/, "", t); gsub(/[ \t]/, "", t)
      n[fam[id]] += length(t); total += length(t)
    }
    END {
      body = ""; best = 0
      for (k in n) if (n[k] > best) { best = n[k]; body = k }
      share = total ? best / total : 0
      b = body
      if (b in idf) { note = " (unnamed font identified as " idf[b] ": " ide[b] ")"; b = norm(idf[b]) } else note = ""
      if (total < 200 || b ~ /glyphless|hiddenhorzocr/ || 2 * scans > pages) {
        cls = "impossible"; face = ""; why = (total < 200 ? "no text layer (scanned image)" : "scanned image with an OCR text layer")
      } else if (b ~ /^timesnewroman/) { cls = "metric-exact"; face = "Times New Roman"; why = "Times New Roman itself (pinned install, docs/FONTS.md)" }
      else if (b ~ /^liberationserif/) { cls = "metric-exact"; face = "Liberation Serif"; why = "vendored" }
      else if (b ~ /^(times|nimbusroman|texgyretermes|nimbusromno9l|timesten)/) { cls = "metric-exact"; face = "TeX Gyre Termes"; why = "Adobe Times metrics (Nimbus Roman lineage)" }
      else if (b ~ /^(arial|helvetica|liberationsans|arimo)/) { cls = "metric-exact"; face = "Liberation Sans"; why = "Arial/Helvetica metrics" }
      else if (b ~ /^(couriernew|liberationmono|cousine)/) { cls = "metric-exact"; face = "Liberation Mono"; why = "Courier New metrics" }
      else if (b ~ /^courier/) { cls = "metric-exact"; face = "TeX Gyre Cursor"; why = "Adobe Courier metrics" }
      else if (b ~ /^(calibri|carlito)/) { cls = "metric-exact"; face = "Carlito"; why = "Calibri metrics" }
      else if (b ~ /^(cambria|caladea)$/) { cls = "metric-exact"; face = "Caladea"; why = "Cambria metrics" }
      else if (b ~ /^(georgia|gelasio)/) { cls = "metric-exact"; face = "Gelasio"; why = "Georgia metrics" }
      else if (b ~ /^(newcenturyschlbk|newcenturyschoolbook|texgyreschola|centuryschl)/) { cls = "metric-exact"; face = "TeX Gyre Schola"; why = "Adobe New Century Schoolbook metrics" }
      else if (b ~ /^ebgaramond/) { cls = "metric-exact"; face = "EB Garamond"; why = "vendored" }
      else if (b ~ /^centuryschoolbook/) { cls = "approximate"; face = "TeX Gyre Schola"; why = "Monotype Century Schoolbook; Schola has the Adobe NCS widths" }
      else if (b ~ /^(bookantiqua|palatino|texgyrepagella)/) { cls = "approximate"; face = "TeX Gyre Pagella"; why = "Palatino lineage; widths differ slightly" }
      else if (b ~ /^(bookman|texgyrebonum)/) { cls = "approximate"; face = "TeX Gyre Bonum"; why = "ITC Bookman lineage; Bookman Old Style widths differ" }
      else if (b ~ /^cidfont/) { cls = "impossible"; face = ""; why = "unnamed embedded font (" body "); face not identifiable from the file" }
      else { cls = "impossible"; face = ""; why = "no redistributable metric-compatible face for " body }
      printf "%s\t%s\t%.3f\t%s\t%s\t%s\t%s\n", file, body, share, cls, face, why note, fonts
    }'
done > "$TMP"
jq -R -s '
  split("\n") | map(select(length > 0) | split("\t")) |
  map({ key: .[0], value: { body: .[1], body_share: (.[2] | tonumber), class: .[3], face: .[4], why: .[5],
        fonts: (.[6] | split(" ") | map(select(length > 0))) } }) |
  { generated_by: "tools/exemplar-fonts.sh", classes: ["metric-exact", "approximate", "impossible"],
    exemplars: from_entries }' "$TMP" > "$OUT"
jq -r '.exemplars | to_entries | group_by(.value.class) | map("\(.[0].value.class)\t\(length)") | .[]' "$OUT"
echo "$OUT"
