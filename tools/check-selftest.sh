#!/usr/bin/env bash
# check-selftest.sh: does the checker actually catch defects? Mutation test for tools/check.sh.
#
# Usage: tools/check-selftest.sh <court-dir>
#
# Each mutant breaks ONE thing, rebuilds the PDF, and runs the checker against the ORIGINAL markdown. The named
# requirement IDs must FAIL. A mutant the checker lets through means a check is blind, which is the failure
# mode that sank the earlier attempt (aggregate scores declaring PASS on visibly wrong pages). Run this after
# changing any check.
#
# Content mutants change the markdown that is rendered (but not the markdown the checks compare against).
# Layout mutants change the template in a scratch copy of the court folder.
# Strict mode. pipefail only where the shell has it (bash, macOS sh); Debian's dash lacks it.
# shellcheck shell=sh disable=SC3040
set -e -u; (set -o pipefail) 2> /dev/null && set -o pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
COURT=$(cd "${1:?usage: tools/check-selftest.sh <court-dir>}" && pwd)
ALIAS=$(jq -r .alias "$COURT/court.json")
SCRATCH="$ROOT/out/selftest/$ALIAS"
mkdir -p "$SCRATCH"
SAMPLE=generic
MD=$(yq e ".samples[] | select(.id == \"$SAMPLE\") | .md" "$COURT/checks.yaml")
PDF=$(yq e ".samples[] | select(.id == \"$SAMPLE\") | .pdf" "$COURT/checks.yaml")
fails=0

fresh_copy() { # a clean scratch court folder: $1 = name
  d="$SCRATCH/$1"
  mkdir -p "$d"
  cp -R "$COURT/typst" "$COURT/usage" "$COURT/checks.yaml" "$COURT/court.json" "$d/"
  mkdir -p "$d/reviews"
  echo "$d"
}

# mutant NAME "expected IDs" KIND SED-EXPR FILE
mutant() {
  name=$1
  want=$2
  kind=$3
  expr=$4
  d=$(fresh_copy "$name")
  if [ "$kind" = content ]; then
    sed "$expr" "$COURT/$MD" > "$d/mutated.md"
    sh "$ROOT/tools/render.sh" "$d" mutated.md "$d/$PDF" > /dev/null 2> "$d/render.err" || {
      echo "MUTANT $name: render failed: $(head -3 "$d/render.err")"
      fails=$((fails + 1))
      return
    }
  else
    sed "$expr" "$COURT/typst/ca9-brief.typ" > "$d/typst/ca9-brief.typ"
    cmp -s "$COURT/typst/ca9-brief.typ" "$d/typst/ca9-brief.typ" && {
      echo "MUTANT $name: the sed expression changed nothing"
      fails=$((fails + 1))
      return
    }
    sh "$ROOT/tools/render.sh" "$d" "$MD" "$d/$PDF" > /dev/null 2> "$d/render.err" || {
      echo "MUTANT $name: render failed: $(head -3 "$d/render.err")"
      fails=$((fails + 1))
      return
    }
  fi
  out=$(sh "$ROOT/tools/check.sh" "$d" --no-render --only "$SAMPLE" 2>&1) || true # a mutant is meant to fail the checker
  missed=""
  for id in $want; do
    grep -q "^  FAIL  $id " << EOF || missed="$missed $id"
$out
EOF
  done
  if [ -z "$missed" ]; then
    echo "caught   $name  (failed: $want)"
  else
    echo "MISSED   $name  (should have failed:$missed)"
    fails=$((fails + 1))
  fi
}

# ---- content mutants: PDF built from changed markdown, compared with the original ----
mutant drop-paragraph "CA9-TOOL-001" content '/^90\\\. The administrative record/d'
mutant drop-dash-paragraph "CA9-TOOL-001" content '/^\\- The District has never explained/d'
mutant alter-word "CA9-TOOL-001" content 's/The word “shall” forecloses/The word “may” forecloses/'
mutant lose-italics "CA9-TOOL-003" content 's/\*Brightwater\* held that/Brightwater held that/'
mutant alter-footnote "CA9-TOOL-004" content 's/The order was not preceded by notice/The order was preceded by notice/'
mutant lose-footnote-text "CA9-TOOL-004" content 's/ The point is reserved for any remand\.//'

# ---- layout mutants: template changed, markdown unchanged ----
mutant single-spaced "CA9-FORM-003" layout 's/^#let body-leading = 0.94em/#let body-leading = 0.2em/'
mutant small-type "CA9-FORM-004" layout 's/^#let type-size = 14pt/#let type-size = 12pt/'
mutant narrow-margins "CA9-FORM-002" layout 's/^#let page-margin = 1in/#let page-margin = 0.8in/'
mutant left-aligned-headings "CA9-FORM-009" layout 's/align(center, text(size: 1.15em, strong(upper(it.body))))/align(left, text(size: 1.15em, strong(upper(it.body))))/'
mutant wrong-font "CA9-FORM-007" layout 's/^#let font-family = ("Times New Roman", "Liberation Serif")/#let font-family = "DejaVu Sans Mono"/'
mutant footnotes-small "CA9-FORM-004" layout 's/set text(size: type-size)   \/\/ typst/set text(size: 11pt)   \/\/ typst/'
mutant no-footnote-size "CA9-FORM-004" layout 's/^    set text(size: type-size).*$//'
mutant wrong-word-count "CA9-CERT-002" layout 's/This brief contains #group-digits(words) words/This brief contains #group-digits(words + 7) words/'
mutant argument-numbering "CA9-CONT-012" layout 's/if h.level == 2 { numbering("I.", n) }/if h.level == 2 { numbering("A.", n) }/'
mutant case-text-in-template "CA9-TOOL-002" layout 's|^// U.S. Court of Appeals for the Ninth Circuit: principal (opening) brief\.|& Theresa Sweet, et al.,|'
mutant toa-tag-before-citation "CA9-TOOL-006" layout 's/tag-after-first-word(it.body, \[#metadata(it.dest.slice(4))<toa-hit>\]).first()/{ [#metadata(it.dest.slice(4))<toa-hit>]; it.body }/'
mutant toa-wrong-page "CA9-TOOL-006" layout 's/let page-text = if pages.len() >= passim-threshold { emph\[passim\] } else { pages.join(", ") }/let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.map(p => str(int(p) + 1)).join(", ") }/'

echo
if [ "$fails" = 0 ]; then
  echo "SELFTEST OK: every mutant was caught"
  exit 0
fi
echo "SELFTEST FAILED: $fails mutants were not caught (or did not build)"
exit 1
