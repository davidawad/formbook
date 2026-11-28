#!/usr/bin/env bash
# Generalized real Microsoft Word DOCX verification harness for formbook.
# Opens OUTPUT-*.docx in /Applications/Microsoft Word.app, exports PDF (via AppleScript
# or macOS Print -> Save as PDF in View-Only mode), and verifies W0..W5 against OUTPUT-*.typst.pdf.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
MODE="${FORMBOOK_WORD_MODE:-auto}"
CHECK_BASELINE=1
LIST_FILE=""
PLEADING_ALL=0
DIRS=()

usage() {
  cat <<'EOF'
Usage: tools/check-word.sh [--mode auto|applescript|print-pdf] [--no-baseline] (--pleading-all | --list <file> | <doc-dir>...)
EOF
}

while (($# > 0)); do
  case "$1" in
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --no-baseline)
      CHECK_BASELINE=0
      shift
      ;;
    --pleading-all)
      PLEADING_ALL=1
      shift
      ;;
    --list)
      LIST_FILE="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      DIRS+=("$1")
      shift
      ;;
  esac
done

if [[ "$(uname -s)" != Darwin ]] || ! command -v osascript >/dev/null 2>&1; then
  printf 'FAIL: check-word.sh requires macOS and osascript.\n' >&2
  exit 2
fi
if ! /usr/bin/osascript -e 'id of application "Microsoft Word"' >/dev/null 2>&1; then
  printf 'FAIL: Microsoft Word is not installed or is not available to AppleScript.\n' >&2
  exit 2
fi
for tool in pdfinfo pdftotext pdffonts awk unzip; do
  command -v "$tool" >/dev/null 2>&1 || {
    printf 'FAIL: missing required tool: %s\n' "$tool" >&2
    exit 2
  }
done

if [[ "$MODE" == "auto" ]]; then
  unlicensed=$(defaults read com.microsoft.Word kSetupUIKeyNotSupportedLicenseFound 2>/dev/null || echo "0")
  if [[ "$unlicensed" == "1" ]]; then
    MODE="print-pdf"
  else
    MODE="applescript"
  fi
fi

if [[ "$MODE" != "applescript" && "$MODE" != "print-pdf" ]]; then
  printf 'FAIL: unknown --mode %s (expected auto|applescript|print-pdf)\n' "$MODE" >&2
  exit 2
fi

if (( PLEADING_ALL )); then
  while IFS= read -r eval_file; do
    DIRS+=("$(dirname "$eval_file")")
  done < <(find "$ROOT/courts" -name eval.yaml -exec grep -l 'pleading_lines:' {} + | sort)
fi

if [[ -n "$LIST_FILE" ]]; then
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    DIRS+=("$line")
  done < "$LIST_FILE"
fi

if ((${#DIRS[@]} == 0)); then
  usage >&2
  exit 2
fi

TMP_BASE="${TMPDIR:-/tmp}"
TMP_BASE="${TMP_BASE%/}"
TMP=$(mktemp -d "${TMP_BASE}/check-word.XXXXXX")
WOUT=$(mktemp -d "$HOME/Library/Containers/com.microsoft.Word/Data/tmp/formbook-word.XXXXXX")
cleanup() {
  if [[ "$MODE" == "print-pdf" ]]; then
    killall "Microsoft Word" >/dev/null 2>&1 || true
  fi
  rm -rf "$TMP" "$WOUT"
}
trap cleanup EXIT

AS_LICENSED="$TMP/export-applescript.applescript"
cat > "$AS_LICENSED" <<'APPLESCRIPT'
on run argv
  set docxPath to item 1 of argv
  set pdfPath to item 2 of argv
  with timeout of 30 seconds
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
  end timeout
end run
APPLESCRIPT

AS_PRINT="$TMP/export-print.applescript"
cat > "$AS_PRINT" <<'APPLESCRIPT'
on run argv
  set pdfPath to item 1 of argv
  with timeout of 30 seconds
    tell application "System Events"
      -- Wait for a Word document window (not the gallery or a repair modal)
      set foundDoc to false
      repeat 50 times
        if exists process "Microsoft Word" then
          tell process "Microsoft Word"
            if (count of windows) > 0 then
              set wName to name of window 1
              if wName is not "Open new and recent files" and wName is not "Microsoft Word" and wName is not "Word" then
                set foundDoc to true
                exit repeat
              end if
            end if
          end tell
        end if
        delay 0.25
      end repeat
      if not foundDoc then error "Word did not open a document window (repair dialog or timeout)"
      set frontmost of process "Microsoft Word" to true
      delay 0.5
      tell process "Microsoft Word"
        if (count of sheets of window 1) > 0 then error "Document opened with modal sheet/repair dialog"
        set printEnabled to enabled of menu item "Print..." of menu "File" of menu bar 1
        if not printEnabled then error "File -> Print... is disabled"
        click menu item "Print..." of menu "File" of menu bar 1
        set gotPrint to false
        repeat 35 times
          if (name of window 1) is "Print" then
            set gotPrint to true
            exit repeat
          end if
          delay 0.2
        end repeat
        if not gotPrint then error "Print dialog did not appear"
        delay 0.6
        set sg to splitter group 1 of window "Print"
        set pdfMenuBtn to missing value
        repeat with g in groups of sg
          if (count of menu buttons of g) > 0 then
            set pdfMenuBtn to menu button 1 of g
          end if
        end repeat
        if pdfMenuBtn is missing value then error "PDF menu button not found in Print dialog"
        click pdfMenuBtn
        delay 0.5
        if (exists menu item "Save as PDF…" of menu 1 of pdfMenuBtn) then
          click menu item "Save as PDF…" of menu 1 of pdfMenuBtn
        else if (exists menu item "Save as PDF..." of menu 1 of pdfMenuBtn) then
          click menu item "Save as PDF..." of menu 1 of pdfMenuBtn
        else
          click menu item "Save as PDF" of menu 1 of pdfMenuBtn
        end if
        repeat 30 times
          if (exists sheet 1 of window "Print") or ((name of window 1) is not "Print") then exit repeat
          delay 0.2
        end repeat
        delay 0.8
        set the clipboard to pdfPath
        keystroke "g" using {command down, shift down}
        delay 0.8
        keystroke "v" using command down
        delay 0.4
        key code 36
        delay 0.8
        key code 36
      end tell
    end tell
  end timeout
end run
APPLESCRIPT

export_via_word() {
  local docx="$1" pdf="$2" context="$3"
  local stem_name
  stem_name="$(basename "$docx")"
  local w_docx="$WOUT/${RANDOM}-${stem_name}"
  cp "$docx" "$w_docx"
  rm -f "$pdf"

  if [[ "$MODE" == "applescript" ]]; then
    if ! /usr/bin/osascript "$AS_LICENSED" "$w_docx" "$pdf" >/dev/null 2>"$TMP/as.err"; then
      printf 'FAIL %s [W0]: Word AppleScript export failed (%s)\n' "$context" "$(tr '\n' ' ' < "$TMP/as.err")" >&2
      rm -f "$w_docx"
      return 1
    fi
  else
    # View-Only Print-to-PDF path: restart cleanly if any stale Word window exists
    killall "Microsoft Word" >/dev/null 2>&1 || true
    sleep 0.5
    open -a "Microsoft Word" "$w_docx"
    if ! /usr/bin/osascript "$AS_PRINT" "$pdf" >/dev/null 2>"$TMP/as.err"; then
      printf 'FAIL %s [W0]: Word open/Print-to-PDF failed (%s)\n' "$context" "$(tr '\n' ' ' < "$TMP/as.err")" >&2
      killall "Microsoft Word" >/dev/null 2>&1 || true
      rm -f "$w_docx"
      return 1
    fi
    # Wait up to 12s for PDF flush
    local waited=0 prev_sz=0 cur_sz=0
    while (( waited < 48 )); do
      if [[ -s "$pdf" ]]; then
        cur_sz=$(wc -c < "$pdf")
        if (( cur_sz > 0 && cur_sz == prev_sz )); then
          break
        fi
        prev_sz=$cur_sz
      fi
      sleep 0.25
      waited=$((waited + 1))
    done
    killall "Microsoft Word" >/dev/null 2>&1 || true
  fi
  rm -f "$w_docx"
  if [[ ! -s "$pdf" ]]; then
    printf 'FAIL %s [W0]: Microsoft Word wrote no PDF\n' "$context" >&2
    return 1
  fi
  return 0
}

page_count() {
  pdfinfo "$1" 2>/dev/null | awk '/^Pages:/ { print $2; exit }'
}

baselines() {
  local pdf="$1" min_x="$2" bottom="$3" target="$4"
  local tsv="$target.tsv"
  pdftotext -f 1 -l 1 -tsv "$pdf" "$tsv"
  awk -F '\t' -v min_x="$min_x" -v bottom="$bottom" '
    $1 == 5 && $2 == 1 && $7 + 0 >= min_x && $8 + 0 < bottom { y[++n] = $8 + $10 }
    END {
      for (i = 1; i <= n; i++) for (j = i + 1; j <= n; j++)
        if (y[j] < y[i]) { t = y[i]; y[i] = y[j]; y[j] = t }
      for (i = 1; i <= n; i++) if (i == 1 || y[i] - y[i - 1] > 1.5) {
        printf "%.1f\n", y[i]
      }
    }
  ' "$tsv" > "$target"
}

check_numbers() {
  local pdf="$1" expected="$2" bottom_edge="$3" context="$4" tsv="$TMP/numbers.tsv"
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
        printf "FAIL %s [W3]: margin line %d occurs %d times on page 1\n", context, i, count[i] + 0 > "/dev/stderr"
        bad = 1
      }
      if (!have || max_bottom > bottom + 1.5) {
        printf "FAIL %s [W3]: last pleading number ends at %.1f pt; bottom margin starts at %.1f pt\n", context, max_bottom, bottom > "/dev/stderr"
        bad = 1
      }
      exit bad
    }
  ' "$tsv"
}

compare_baselines() {
  local word="$1" typst="$2" context="$3"
  awk -v context="$context" '
    FILENAME == ARGV[1] { a[++na] = $1 + 0; next }
    { b[++nb] = $1 + 0 }
    END {
      bad = 0
      if (na != nb) {
        printf "FAIL %s [W2]: Word page 1 has %d text lines; Typst has %d\n", context, na, nb > "/dev/stderr"
        bad = 1
      }
      n = na < nb ? na : nb
      for (i = 1; i <= n; i++) if ((a[i] - b[i] > 1.5) || (b[i] - a[i] > 1.5)) {
        printf "FAIL %s [W2]: page-1 line %d starts at Word %.1f pt, Typst %.1f pt\n", context, i, a[i], b[i] > "/dev/stderr"
        bad = 1
        break
      }
      exit bad
    }
  ' "$word" "$typst"
}

check_fonts() {
  local word_pdf="$1" typst_pdf="$2" context="$3"
  local w_fonts t_fonts
  w_fonts=$(pdffonts "$word_pdf" | awk 'NR > 2 { print $1 }')
  t_fonts=$(pdffonts "$typst_pdf" | awk 'NR > 2 { print $1 }')
  if [[ -z "$w_fonts" ]]; then
    printf 'FAIL %s [W4]: Word PDF embeds no fonts\n' "$context" >&2
    return 1
  fi
  if grep -Eiq 'Calibri|Cambria|Aptos|LucidaGrande' <<< "$w_fonts"; then
    if ! grep -Eiq 'Calibri|Cambria|Aptos' <<< "$t_fonts"; then
      printf 'FAIL %s [W4]: Word substituted fallback font (%s)\n' "$context" "$(tr '\n' ',' <<< "$w_fonts")" >&2
      return 1
    fi
  fi
  return 0
}

check_completeness() {
  local word_pdf="$1" typst_pdf="$2" context="$3"
  local w_words t_words
  w_words=$(pdftotext "$word_pdf" - 2>/dev/null | wc -w | tr -d ' ')
  t_words=$(pdftotext "$typst_pdf" - 2>/dev/null | wc -w | tr -d ' ')
  if (( w_words == 0 )); then
    printf 'FAIL %s [W5]: Word PDF extracted 0 words\n' "$context" >&2
    return 1
  fi
  if (( t_words > 0 )); then
    awk -v w="$w_words" -v t="$t_words" -v context="$context" 'BEGIN {
      diff = (w > t) ? (w - t) : (t - w)
      if (diff / t > 0.10) {
        printf "FAIL %s [W5]: word count drift (Word=%d vs Typst=%d)\n", context, w, t > "/dev/stderr"
        exit 1
      }
    }' || return 1
  fi
  return 0
}

eval_val() {
  local dir="$1" key="$2" default="$3"
  local val=""
  for f in "$(dirname "$dir")/eval.yaml" "$dir/eval.yaml"; do
    [[ -f "$f" ]] || continue
    local hit
    hit=$(awk -v k="$key" '$1 == k ":" { print $2; exit }' "$f")
    [[ -n "$hit" ]] && val="$hit"
  done
  printf '%s' "${val:-$default}"
}

passed=0
failed=0
total=0

for raw_dir in "${DIRS[@]}"; do
  if [[ "$raw_dir" = /* ]]; then
    dir="$raw_dir"
  else
    dir="$ROOT/$raw_dir"
  fi
  if [[ ! -d "$dir" ]]; then
    printf 'FAIL %s [W0]: directory not found\n' "$raw_dir" >&2
    failed=$((failed + 1))
    total=$((total + 1))
    continue
  fi
  rel_dir="${dir#"$ROOT"/}"
  pleading_lines=$(eval_val "$dir" "pleading_lines" "")
  bottom_margin=$(eval_val "$dir" "margin_bottom_pt" "")
  if [[ -z "$bottom_margin" ]]; then
    bottom_margin=$(eval_val "$dir" "margin_pt" "72")
  fi
  bottom_edge=$(awk -v m="$bottom_margin" 'BEGIN { printf "%.1f", 792 - m }')
  min_x=0
  if [[ "$pleading_lines" =~ ^[0-9]+$ ]]; then
    min_x=72
  fi

  shopt -s nullglob
  docxs=("$dir"/usage/OUTPUT-*.docx)
  shopt -u nullglob
  if ((${#docxs[@]} == 0)); then
    if (( PLEADING_ALL )) && [[ ! -d "$dir/docx" ]]; then
      printf 'SKIP %s (no docx engine)\n' "$rel_dir"
      continue
    fi
    printf 'FAIL %s [W0]: no OUTPUT-*.docx files found\n' "$rel_dir" >&2
    failed=$((failed + 1))
    total=$((total + 1))
    continue
  fi

  for docx in "${docxs[@]}"; do
    total=$((total + 1))
    stem="${docx%.docx}"
    typst_pdf="${stem}.typst.pdf"
    base_name="$(basename "$stem")"
    context="$rel_dir/$base_name"
    if [[ ! -f "$typst_pdf" ]]; then
      printf 'FAIL %s [W0]: missing paired %s.typst.pdf\n' "$context" "$base_name" >&2
      failed=$((failed + 1))
      continue
    fi

    word_pdf="$TMP/out-${total}-${base_name}.pdf"
    if ! export_via_word "$docx" "$word_pdf" "$context"; then
      failed=$((failed + 1))
      continue
    fi

    sample_ok=1
    w_pages=$(page_count "$word_pdf")
    t_pages=$(page_count "$typst_pdf")
    if [[ -z "$w_pages" || -z "$t_pages" || "$w_pages" != "$t_pages" ]]; then
      printf 'FAIL %s [W1]: page count Word=%s vs Typst=%s\n' "$context" "${w_pages:-?}" "${t_pages:-?}" >&2
      sample_ok=0
    fi

    if (( CHECK_BASELINE )) && (( sample_ok )); then
      baselines "$word_pdf" "$min_x" "$bottom_edge" "$TMP/w-lines"
      baselines "$typst_pdf" "$min_x" "$bottom_edge" "$TMP/t-lines"
      compare_baselines "$TMP/w-lines" "$TMP/t-lines" "$context" || sample_ok=0
    fi

    if [[ "$pleading_lines" =~ ^[0-9]+$ ]]; then
      check_numbers "$word_pdf" "$pleading_lines" "$bottom_edge" "$context" || sample_ok=0
    fi

    check_fonts "$word_pdf" "$typst_pdf" "$context" || sample_ok=0
    check_completeness "$word_pdf" "$typst_pdf" "$context" || sample_ok=0

    if (( sample_ok )); then
      passed=$((passed + 1))
      printf 'PASS %s (mode=%s, pages=%s, font+text+layout ok)\n' "$context" "$MODE" "$w_pages"
    else
      failed=$((failed + 1))
    fi
  done
done

if (( failed > 0 )); then
  printf 'RESULT: WORD CHECK FAIL (%d of %d DOCX outputs failed; mode=%s)\n' "$failed" "$total" "$MODE" >&2
  exit 1
fi
printf 'RESULT: WORD CHECK PASS (%d DOCX outputs; mode=%s)\n' "$passed" "$MODE"
