#!/usr/bin/env bash
# Render one sample to .docx and to the LibreOffice PDF of it (engine "docx").
# Usage: tools/render-docx.sh <doc-dir> <usage/INPUT-<stem>-<id>.md, relative to the doc dir> [out.docx.pdf]
# Default out: <doc-dir>/usage/OUTPUT-<stem>-<id>.docx.pdf ; the .docx sits beside it as OUTPUT-<stem>-<id>.docx.
# Gates 0 and 1 are measured on the .docx.pdf (Word may paginate slightly differently; see docs/DOCX.md).
#
# Contract (docs/EVAL-LOOP.md, "Engines"):
#   <court>/docx/render.sh        if present it owns the .docx: sh render.sh <court-dir> <sample.md> <out.docx>
#   <court>/docx/reference.docx   otherwise: pandoc --reference-doc, plus every <court>/docx/*.lua as a filter.
# Then: soffice --headless --convert-to pdf. The .docx must also open in Word and LibreOffice without repair:
# this script checks that it is a valid zip with well-formed XML parts (necessary, not sufficient).
# Strict mode. pipefail only where the shell has it (bash, macOS sh); Debian's dash lacks it.
# shellcheck shell=sh disable=SC3040
set -e -u; (set -o pipefail) 2> /dev/null && set -o pipefail
COURT=$(cd "$1" && pwd)
SAMPLE=$2
OUTPDF=${3:-$COURT/usage/$(basename "$SAMPLE" .md | sed 's/^INPUT-/OUTPUT-/').docx.pdf}
DOCX=${OUTPDF%.pdf}
case $DOCX in
  *.docx) ;;
  *)
    echo "render-docx.sh: output must end in .docx.pdf" >&2
    exit 2
    ;;
esac
D="$COURT/docx"
SOFFICE=${SOFFICE:-$(command -v soffice || echo /opt/homebrew/bin/soffice)}
if [ -f "$D/render.sh" ]; then
  sh "$D/render.sh" "$COURT" "$SAMPLE" "$DOCX" >&2 || exit 1
elif [ -f "$D/reference.docx" ]; then
  filters=""
  for f in "$D"/*.lua; do [ -e "$f" ] && filters="$filters --lua-filter=$f"; done
  # shellcheck disable=SC2086
  (cd "$COURT" && pandoc --from markdown+smart --to docx --reference-doc="$D/reference.docx" $filters "$SAMPLE" -o "$DOCX") || exit 1
else
  echo "render-docx.sh: no docx template ($D/reference.docx or $D/render.sh)" >&2
  exit 1
fi
[ -f "$DOCX" ] || {
  echo "render-docx.sh: $DOCX was not written" >&2
  exit 1
}
# integrity: valid zip, well-formed XML parts
unzip -tq "$DOCX" > /dev/null || {
  echo "render-docx.sh: $DOCX is not a valid zip" >&2
  exit 1
}
# recursive delete of one directory; an empty path aborts instead of deleting the wrong thing
safe_rmdir() { rm -r -f -- "${1:?safe_rmdir: empty path}"; }
WORK=$(mktemp -d) || exit 1
trap 'safe_rmdir "$WORK"' EXIT
if command -v xmllint > /dev/null; then
  X=$WORK/docx-parts
  unzip -q "$DOCX" -d "$X"
  find "$X" -type f \( -name '*.xml' -o -name '*.rels' \) | while IFS= read -r part; do
    xmllint --noout "$part" 2> /dev/null || {
      echo "render-docx.sh: ${part#"$X"/} is not well-formed XML" >&2
      exit 1
    }
  done || exit 1
fi
"$SOFFICE" "-env:UserInstallation=file://$WORK/profile" --headless --convert-to pdf --outdir "$WORK" "$DOCX" > "$WORK/soffice.log" 2>&1 || {
  cat "$WORK/soffice.log" >&2
  exit 1
}
cp "$WORK/$(basename "${DOCX%.docx}").pdf" "$OUTPDF"
echo "$OUTPDF"
