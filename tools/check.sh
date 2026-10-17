#!/usr/bin/env bash
# check.sh: run the eval loop's mechanical gates of one court or doc-type folder.
#
# Usage: tools/check.sh <court-dir> [--engine typst|latex|docx] [--no-render] [--only SAMPLE_ID]
#
# The driver is `fb check` (tools/fb, Rust); the checks themselves are tools/check/lib.sh and the awk files.
#   --engine  which rendering of the samples to check (default typst). latex checks samples/<id>.latex.pdf,
#             docx checks samples/<id>.docx.pdf (LibreOffice conversion of <id>.docx). A check in checks.yaml
#             may carry `engines: [typst]` and `engines_reason:` to run only there; it prints SKIP elsewhere.
#   On a full green run (no --only) the stamp samples/.check-<engine>.txt is written: PASS plus the sha256 of
#   every PDF checked (and the .docx). Any failure removes it.
#
#   Gate 0 CONTENT        every markdown block is in the PDF, in order, unaltered; italics; footnotes
#   Gate 1 RULES          one check per requirement ID in <court>/checks.yaml, measured on the PDF
#   Gate 2 VISUAL REVIEW  <court>/reviews/*.md must cover every page of the CURRENT PDF with no open defect
#   Gate 3 GENERALIZATION the structurally different sample has the required features and passes 0-2
#
# Exit status is 0 only when every check passes. "Done" is never set here: only David sets it, by hand.
# Needs: cargo, gawk, yq (mikefarah), jq, typst, poppler (pdfinfo pdffonts pdftotext pdftohtml pdfimages).
set -euo pipefail
FB_ROOT="$(dirname "$0")/.."
export FB_ROOT
exec cargo run -q --release --manifest-path "$FB_ROOT/tools/fb/Cargo.toml" -- check "$@"
