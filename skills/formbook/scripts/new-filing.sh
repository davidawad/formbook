#!/bin/sh
# new-filing.sh: start a filing from a doc type's sample input.
# Usage (from the repo root): sh skills/formbook/scripts/new-filing.sh <alias> <doctype> <out-dir>
#   doctype is as printed by find.sh (e.g. complaint, opening-brief; "." for a court-root template).
# Copies the doc type's first samples/INPUT-*.md to <out-dir>/filing.md and prints the render command.
# Edit filing.md (frontmatter + body) and delete the sample's case text. The template folder is not touched.
set -eu
[ $# -eq 3 ] || { echo "usage: sh skills/formbook/scripts/new-filing.sh <alias> <doctype> <out-dir>" >&2; exit 2; }
ALIAS=$1 DT=$2 OUT=$3
HERE=$(cd "$(dirname "$0")" && pwd)
SEL=$(sh "$HERE/find.sh" "$ALIAS" "$DT" | awk -F'\t' '/^  doctype:/ { print $3 }')
[ -n "$SEL" ] || { echo "new-filing.sh: no doc type '$DT' for '$ALIAS' (run: sh skills/formbook/scripts/find.sh $ALIAS)" >&2; exit 1; }
if [ "$(printf '%s\n' "$SEL" | wc -l | tr -d ' ')" -ne 1 ]; then
  echo "new-filing.sh: '$DT' matches several doc types for '$ALIAS'; pass the exact name:" >&2
  printf '%s\n' "$SEL" >&2
  exit 1
fi
SRC=$(ls "$SEL"/samples/INPUT-*.md 2>/dev/null | head -1)
[ -n "$SRC" ] || { echo "new-filing.sh: $SEL has no samples/INPUT-*.md" >&2; exit 1; }
mkdir -p "$OUT"
cp "$SRC" "$OUT/filing.md"
ABS=$(cd "$OUT" && pwd)
echo "template : $SEL"
echo "starting : $SRC -> $OUT/filing.md"
echo "render   : sh skills/formbook/scripts/render-filing.sh $SEL $ABS/filing.md $ABS/filing.pdf"
echo "note     : the sample is a real filing excerpt; replace every party, fact and cite. Contract: skills/formbook/reference/input-contract.md"
