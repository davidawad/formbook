#!/bin/sh
# check.sh: run the eval loop's mechanical gates for one court folder.
#
# Usage: tools/check.sh <court-dir> [--engine typst|latex|docx] [--no-render] [--only SAMPLE_ID]
#
#   --engine  which rendering of the samples to check (default typst). latex checks samples/<id>.latex.pdf,
#             docx checks samples/<id>.docx.pdf (LibreOffice conversion of <id>.docx; Word may differ slightly).
#             A check in checks.yaml may carry `engines: [typst]` and `engines_reason:` to run only there; it is
#             printed as SKIP, with the reason, on the others.
#   On a full green run (no --only) a stamp samples/.check-<engine>.txt is written: PASS plus the sha256 of every
#   PDF checked (and the .docx). Any failure removes it. tools/manifest.sh counts an engine as passing only
#   while the stamp exists and its hashes match the files on disk.
#
#   Gate 0 CONTENT        every markdown block is in the PDF, in order, unaltered; italics; footnotes
#   Gate 1 RULES          one check per requirement ID in <court>/checks.yaml, measured on the PDF
#   Gate 2 VISUAL REVIEW  <court>/reviews/*.md must cover every page of the CURRENT PDF with no open defect
#   Gate 3 GENERALIZATION the structurally different sample has the required features and passes 0-2
#
# Every check is PASS or FAIL on its worst instance; nothing is averaged. A failure prints the requirement
# ID, what was measured, what was expected, the failing instances, and the template file:line to fix.
# Exit status is 0 only when every check passes. "Done" is never set here: only David sets it, by hand,
# in court.json (docs/EVAL-LOOP.md). This script is the stand-in for a Rust validator that will read the same
# checks.yaml and must give the same verdicts (docs/EVAL-LOOP.md, "Replacing this script").
#
# Needs: sh, gawk, yq (mikefarah), jq, typst, poppler (pdfinfo pdffonts pdftotext pdftohtml pdfimages), shasum.
ROOT=$(cd "$(dirname "$0")/.." && pwd)
DOC=$(cd "${1:?usage: tools/check.sh <court-dir-or-doc-type> [--engine E] [--no-render] [--only SAMPLE_ID]}" && pwd)
shift
# Document-type folders do not carry court.json. Resolve court metadata upward,
# but keep document files and stamps rooted at the folder supplied by the caller.
COURT=$DOC
while [ ! -f "$COURT/court.json" ] && [ "$COURT" != / ]; do COURT=$(dirname "$COURT"); done
[ -f "$COURT/court.json" ] || {
  echo "no court.json found above $DOC" >&2
  exit 2
}
[ -f "$COURT/checks.yaml" ] || {
  echo "no court-level checks.yaml at $COURT" >&2
  exit 2
}
ENGINE=typst
RENDER=1
ONLY=""
while [ $# -gt 0 ]; do
  case $1 in
    --no-render) RENDER=0 ;;
    --engine)
      ENGINE=$2
      shift
      ;;
    --only)
      ONLY=$2
      shift
      ;;
    *)
      echo "unknown option $1" >&2
      exit 2
      ;;
  esac
  shift
done
case $ENGINE in typst | latex | docx) ;; *)
  echo "unknown engine $ENGINE (typst, latex, docx)" >&2
  exit 2
  ;;
esac
export LC_ALL=en_US.UTF-8
. "$ROOT/tools/check/lib.sh"

ALIAS=$(jq -r .alias "$COURT/court.json")
DOC_KEY=${DOC#"$ROOT/"}
DOC_KEY=$(printf '%s' "$DOC_KEY" | tr '/' '_')
OUT="$ROOT/out/check/$ALIAS/$DOC_KEY"
mkdir -p "$OUT"
TAB=$(printf '\t')
# the template file(s) a failure points at: checks.yaml `template` for typst, `templates.<engine>` otherwise
if [ "$ENGINE" = typst ]; then TEMPLATE=$(cfg .template); else TEMPLATE=$(cfg ".templates.$ENGINE // \"\""); fi
[ -n "$TEMPLATE" ] || TEMPLATE=$ENGINE
export TEMPLATE ENGINE

# ---- calibration: how tall is a word of the declared font at 14 pt, as pdftotext reports it? ---------
calibrate() {
  d="$OUT/calib"
  mkdir -p "$d"
  printf '#set page(width: 400pt, height: 220pt, margin: 20pt)\n#set text(font: "%s", size: 100pt, top-edge: "ascender", bottom-edge: "descender")\nHxg\n' \
    "$(cfg .font.typst_family)" > "$d/c.typ"
  typst compile --font-path "$ROOT/fonts" --ignore-system-fonts "$d/c.typ" "$d/c.pdf" 2> "$d/err" ||
    {
      cat "$d/err" >&2
      echo "calibration failed" >&2
      exit 2
    }
  pdftotext -tsv "$d/c.pdf" - | awk -F'\t' '$1 == 5 { printf "%.5f", $10 / 100; exit }'
}
CALIB=$(calibrate)
FTOP=$(($(cfg .params.page_height_pt) - $(cfg .params.margin_pt))) # text below this line is footer (page numbers)

# ---- per-sample derived data ------------------------------------------------------------------------
prepare() {
  W="$OUT/$SID"
  mkdir -p "$W"
  [ "$RENDER" = 0 ] || sh "$ROOT/tools/render.sh" --engine "$ENGINE" "$DOC" "$(cfg ".samples[] | select(.id == \"$SID\") | .md")" "$PDF" > /dev/null || return 1
  [ -f "$PDF" ] || {
    echo "no PDF at $PDF" >&2
    return 1
  }
  pdfinfo -f 1 -l 9999 "$PDF" > "$W/info.txt" 2> /dev/null
  NPAGES=$(sed -n 's/^Pages: *//p' "$W/info.txt")
  pdffonts "$PDF" > "$W/fonts.txt" 2> /dev/null
  pdftotext -tsv "$PDF" - 2> /dev/null | gawk -f "$CHK/words.awk" > "$W/words.tsv"
  pdftohtml -xml -zoom 2 -i -q -stdout "$PDF" 2> /dev/null | gawk -f "$CHK/pdf-runs.awk" > "$W/runs.tsv"
  gawk -f "$CHK/md-blocks.awk" "$MD" > "$W/blocks.tsv"
  PH=$(cfg .params.page_height_pt)
  PM=$(cfg .params.margin_pt)
  gawk -v out="$W/g0" -v footer_top=$((PH - PM)) -f "$CHK/norm.awk" -f "$CHK/gate0.awk" "$W/runs.tsv" "$W/blocks.tsv"
  hmin=$(awk -v r="$CALIB" -v s="$(cfg .font.size_pt)" 'BEGIN { printf "%.2f", r * s * 0.8 }')
  gawk -v hmin="$hmin" -f "$CHK/lines.awk" "$W/g0.tags" "$W/runs.tsv" "$W/words.tsv" | sort -t"$TAB" -k1,1n -k2,2n > "$W/lines.tsv"
  # printed page labels: the one word in the bottom margin of each page
  awk -F'\t' -v t=$((PH - PM)) '$3 >= t { print $1 "\t" $7 }' "$W/words.tsv" > "$W/labels.tsv"
}

# ---- run every check of the given gates against the prepared sample -------------------------------------
run_checks() { # $1 = space-separated gate numbers
  GATES=$1
  yq -o=json e '.checks' "$COURT/checks.yaml" | jq -r '.[] | [.id, (.gate|tostring), .method, .name, .expect, (.fix.anchor // ""), ((.engines // ["*"]) | join(",")), (.engines_reason // "-"), ((.args // []) | join("\u001f"))] | @tsv' |
    while IFS="$TAB" read -r id gate method name expect anchor engines ereason args; do
      case " $GATES " in *" $gate "*) ;; *) continue ;; esac
      case ",$engines," in *",*,"* | *",$ENGINE,"*) ;; *)
        printf '  SKIP  %-14s %s\n          not run for engine %s (only: %s): %s\n' "$id" "$name" "$ENGINE" "$engines" "$ereason"
        continue
        ;;
      esac
      [ "$gate" = 3 ] && [ "$SID" != "$(cfg .generalization.second_sample)" ] && continue
      if [ "$method" = generalization_all ]; then
        ST=PASS
        MEAS="no failing check on any sample"
        DETAIL=""
        [ "$(cat "$OUT/.fails" 2> /dev/null || echo 0)" = 0 ] || {
          ST=FAIL
          MEAS="$(cat "$OUT/.fails") checks failed on the samples"
        }
      else
        ST=FAIL
        MEAS="(check did not run)"
        DETAIL=""
        oldifs=$IFS
        IFS=$(printf '\037')
        # shellcheck disable=SC2086 # intentional split on IFS (unit separator)
        set -- $args
        IFS=$oldifs
        "chk_$method" "$@"
      fi
      if [ "$ST" = PASS ]; then
        printf '  PASS  %-14s %s\n          %s\n' "$id" "$name" "$MEAS"
        echo P >> "$OUT/.tally"
      else
        line=$(grep -rnH -F -- "$anchor" "$DOC/$TEMPLATE" 2> /dev/null | head -1 | sed "s/^[^:]*:\([0-9]*\):.*/\1/")
        printf '  FAIL  %-14s %s\n          measured: %s\n          expected: %s\n          fix:      %s:%s  (%s)\n' "$id" "$name" "$MEAS" "$expect" "$TEMPLATE" "${line:-?}" "$anchor"
        [ -z "$DETAIL" ] || printf '%s\n' "$DETAIL" | sed 's/^/          - /'
        echo F >> "$OUT/.tally"
        [ "$gate" = 3 ] || echo F >> "$OUT/.fails_sample"
      fi
    done
}

: > "$OUT/.tally"
: > "$OUT/.shas"
printf '0\n' > "$OUT/.fails"
: > "$OUT/.fails_sample"
echo "formbook check: $ALIAS ($(jq -r .name "$COURT/court.json"))  font calibration: 14 pt = $(awk -v r="$CALIB" 'BEGIN { printf "%.2f", r * 14 }') pt word height"
for SID in $(cfg '.samples[].id'); do
  [ -z "$ONLY" ] || [ "$ONLY" = "$SID" ] || continue
  MD="$DOC/$(cfg ".samples[] | select(.id == \"$SID\") | .md")"
  PDF="$DOC/$(cfg ".samples[] | select(.id == \"$SID\") | .pdf")"
  case $ENGINE in latex) PDF="${PDF%.pdf}.latex.pdf" ;; docx) PDF="${PDF%.pdf}.docx.pdf" ;; esac
  echo
  echo "=== sample $SID"
  prepare || {
    echo "  could not prepare $SID"
    echo F >> "$OUT/.tally"
    continue
  }
  echo "    $(basename "$PDF"): $NPAGES pages"
  printf '%s  %s\n' "$(shasum -a 256 "$PDF" | cut -d" " -f1)" "${PDF#"$DOC"/}" >> "$OUT/.shas"
  [ "$ENGINE" != docx ] || printf '%s  %s\n' "$(shasum -a 256 "${PDF%.pdf}" | cut -d' ' -f1)" "${PDF%.pdf}" | sed "s|  $DOC/|  |" >> "$OUT/.shas"
  echo " GATE 0 CONTENT"
  run_checks "0"
  echo " GATE 1 RULES"
  run_checks "1"
  echo " GATE 2 VISUAL REVIEW"
  run_checks "2"
  nf=$(grep -c F "$OUT/.fails_sample" 2> /dev/null)
  nf=${nf:-0}
  printf '%s\n' "$(($(cat "$OUT/.fails") + nf))" > "$OUT/.fails"
  : > "$OUT/.fails_sample"
  [ "$SID" = "$(cfg .generalization.second_sample)" ] && {
    echo " GATE 3 GENERALIZATION"
    run_checks "3"
  }
done

P=$(grep -c P "$OUT/.tally")
F=$(grep -c F "$OUT/.tally")
echo
echo "RESULT: $P checks passed, $F failed"
STAMP="$DOC/samples/.check-$ENGINE.txt"
if [ "$F" != 0 ]; then
  rm -f "$STAMP" # any failure invalidates the engine's stamp
elif [ -z "$ONLY" ]; then
  {
    echo PASS
    sort -k2 "$OUT/.shas"
  } > "$STAMP"
  echo "stamp: ${STAMP#"$DOC"/} written for engine $ENGINE"
fi
if [ "$F" = 0 ]; then
  echo "All gates green: this court folder is eligible for 'up for review' (tools/tracker.sh). 'done' is set by David, by hand, in court.json."
  exit 0
fi
exit 1
