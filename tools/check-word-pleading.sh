#!/usr/bin/env bash
# Export every N.D. Cal. pleading DOCX through Microsoft Word and compare page 1 with Typst.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
COURT="$ROOT/courts/ninth-circuit/california/federal/northern-district"
types=(answer complaint motion-brief proposed-order)

if [[ "$(uname -s)" != Darwin ]] || ! command -v osascript >/dev/null 2>&1; then
  printf 'FAIL: check-word-pleading.sh requires macOS and osascript (Microsoft Word is required for export).\n' >&2
  exit 2
fi
if ! /usr/bin/osascript -e 'id of application "Microsoft Word"' >/dev/null 2>&1; then
  printf 'FAIL: Microsoft Word is not installed or is not available to AppleScript.\n' >&2
  exit 2
fi
bash "$ROOT/tools/check-vml-textbox.sh"
for tool in pdftotext awk; do
  command -v "$tool" >/dev/null 2>&1 || { printf 'FAIL: missing required tool: %s\n' "$tool" >&2; exit 2; }
done

TMP=$(mktemp -d "${TMPDIR:-/tmp}/word-pleading.XXXXXX")
WOUT=$(mktemp -d "$HOME/Library/Containers/com.microsoft.Word/Data/tmp/formbook-word.XXXXXX")
trap 'rm -rf "$TMP" "$WOUT"' EXIT
APPLESCRIPT="$TMP/export.applescript"
cat >"$APPLESCRIPT" <<'APPLESCRIPT'
on run argv
  set docxPath to item 1 of argv
  set pdfPath to item 2 of argv
  tell application "Microsoft Word"
    open POSIX file docxPath
    repeat 100 times
      if (count of documents) > 0 then exit repeat
      delay 0.2
    end repeat
    set doc to active document
    save as doc file name pdfPath file format format PDF
    close doc saving no
  end tell
end run
APPLESCRIPT

# TSV line records have level=5; x<72 pt is the line-number gutter, while footer lines
# start at or below the declared bottom margin. Nearby glyph tops on one row collapse to one text line.
baselines() {
  local pdf=$1 bottom=$2 target=$3
  local tsv="$target.tsv"
  pdftotext -f 1 -l 1 -tsv "$pdf" "$tsv"
  awk -F '\t' -v bottom="$bottom" '
    $1 == 5 && $2 == 1 && $7 + 0 >= 72 && $8 + 0 < bottom { y[++n] = $8 + 0 }
    END {
      for (i = 1; i <= n; i++) for (j = i + 1; j <= n; j++)
        if (y[j] < y[i]) { t = y[i]; y[i] = y[j]; y[j] = t }
      lines = 0
      for (i = 1; i <= n; i++) if (i == 1 || y[i] - y[i - 1] > 1.5) {
        printf "%.1f\n", y[i]
        lines++
      }
    }
  ' "$tsv" >"$target"
}

check_numbers() {
  local pdf=$1 expected=$2 bottom_edge=$3 context=$4 tsv="$TMP/numbers.tsv"
  pdftotext -f 1 -l 1 -tsv "$pdf" "$tsv"
  awk -F '\t' -v expected="$expected" -v bottom="$bottom_edge" -v context="$context" '
    $1 == 5 && $2 == 1 && $7 + 0 < 72 && $12 ~ /^[0-9]+$/ {
      n = $12 + 0
      if (n >= 1 && n <= expected) {
        count[n]++
        if (!have || $8 + $10 > max_bottom) max_bottom = $8 + $10
        have = 1
      }
    }
    END {
      bad = 0
      for (i = 1; i <= expected; i++) if (count[i] != 1) {
        printf "FAIL %s: margin line %d occurs %d times on page 1\n", context, i, count[i] + 0 > "/dev/stderr"
        bad = 1
      }
      if (!have || max_bottom > bottom + 1.5) {
        printf "FAIL %s: last pleading number ends at %.1f pt; bottom margin starts at %.1f pt\n", context, max_bottom, bottom > "/dev/stderr"
        bad = 1
      }
      exit bad
    }
  ' "$tsv"
}

compare_baselines() {
  local word=$1 typst=$2 context=$3
  awk -v context="$context" '
    FILENAME == ARGV[1] { a[++na] = $1 + 0; next }
    { b[++nb] = $1 + 0 }
    END {
      bad = 0
      if (na != nb) {
        printf "FAIL %s: Word page 1 has %d text lines; Typst has %d\n", context, na, nb > "/dev/stderr"
        bad = 1
      }
      n = na < nb ? na : nb
      for (i = 1; i <= n; i++) if ((a[i] - b[i] > 1.5) || (b[i] - a[i] > 1.5)) {
        printf "FAIL %s: page-1 line %d starts at Word %.1f pt, Typst %.1f pt (caption/body offset or line pitch differs)\n", context, i, a[i], b[i] > "/dev/stderr"
        bad = 1
        break
      }
      exit bad
    }
  ' "$word" "$typst"
}

count=0 fails=0
for type in "${types[@]}"; do
  dir="$COURT/$type"
  [[ -d "$dir" ]] || { printf 'FAIL: missing pleading folder %s\n' "$dir" >&2; exit 1; }
  expected=$(awk '/^[[:space:]]*pleading_lines:/ { print $2; exit }' "$dir/eval.yaml")
  if [[ ! "$expected" =~ ^[0-9]+$ ]]; then
    printf 'FAIL %s: eval.yaml does not declare params.pleading_lines\n' "$type" >&2
    exit 1
  fi
  bottom_margin=$(awk '/^[[:space:]]*margin_bottom_pt:/ { print $2; found=1; exit } END { if (!found) print 72 }' "$dir/eval.yaml")
  bottom_edge=$(awk -v m="$bottom_margin" 'BEGIN { printf "%.1f", 792 - m }')
  shopt -s nullglob
  docxs=("$dir"/usage/OUTPUT-*.docx)
  shopt -u nullglob
  if ((${#docxs[@]} == 0)); then
    printf 'FAIL %s: no OUTPUT-*.docx exemplars to test\n' "$type" >&2
    exit 1
  fi
  for docx in "${docxs[@]}"; do
    stem=${docx%.docx}
    typst="${stem}.typst.pdf"
    if [[ ! -f "$typst" ]]; then
      printf 'FAIL %s: missing paired Typst output for %s\n' "$type" "$(basename "$docx")" >&2
      exit 1
    fi
    word_pdf="$WOUT/${type}-$(basename "$stem").pdf"
    context="$type/$(basename "$stem")"
    word_docx="$WOUT/${type}-$(basename "$docx")"
    cp "$docx" "$word_docx"
    /usr/bin/osascript "$APPLESCRIPT" "$word_docx" "$word_pdf"
    [[ -s "$word_pdf" ]] || { printf 'FAIL %s: Word did not export a PDF\n' "$context" >&2; exit 1; }
    word_lines="$TMP/word-lines"
    typst_lines="$TMP/typst-lines"
    baselines "$word_pdf" "$bottom_edge" "$word_lines"
    baselines "$typst" "$bottom_edge" "$typst_lines"
    check_numbers "$word_pdf" "$expected" "$bottom_edge" "$context Word" || { fails=$((fails + 1)); continue; }
    compare_baselines "$word_lines" "$typst_lines" "$context" || { fails=$((fails + 1)); continue; }
    count=$((count + 1))
    printf 'PASS %s (Word page-1 numbers, line count/offset, bottom fit)\n' "$context"
  done
done
((fails == 0)) || { printf 'WORD PLEADING GATE FAILED (%d of %d DOCX outputs)\n' "$fails" "$((count + fails))" >&2; exit 1; }
printf 'WORD PLEADING GATE OK (%d DOCX outputs)\n' "$count"
