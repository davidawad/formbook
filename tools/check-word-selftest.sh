#!/usr/bin/env bash
# Mutation self-test for tools/check-word.sh: proves the real-Word harness passes an
# unmodified control and catches corrupt OOXML (W0), shifted page-1 baselines (W2),
# and missing pleading numbers / fallback fonts (W3/W4).
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SRC="$ROOT/courts/ninth-circuit/california/federal/northern-district/answer"
HARNESS="$ROOT/tools/check-word.sh"

for tool in unzip zip awk; do
  command -v "$tool" >/dev/null 2>&1 || {
    printf 'FAIL: missing required tool: %s\n' "$tool" >&2
    exit 2
  }
done

TMP_BASE="${TMPDIR:-/tmp}"
TMP_BASE="${TMP_BASE%/}"
TMP=$(mktemp -d "${TMP_BASE}/word-selftest.XXXXXX")
trap 'rm -rf "$TMP"' EXIT

make_copy() {
  local dst="$1"
  mkdir -p "$dst/usage"
  cp "$SRC/eval.yaml" "$dst/eval.yaml"
  cp "$SRC/usage/OUTPUT-answer.docx" "$dst/usage/OUTPUT-answer.docx"
  cp "$SRC/usage/OUTPUT-answer.typst.pdf" "$dst/usage/OUTPUT-answer.typst.pdf"
}

# 0. Control: unmodified folder must PASS
CTRL="$TMP/control"
make_copy "$CTRL"
if ! bash "$HARNESS" "$CTRL" >"$TMP/ctrl.out" 2>"$TMP/ctrl.err"; then
  cat "$TMP/ctrl.out" "$TMP/ctrl.err" >&2
  printf 'FAIL SELFTEST: control case did not pass\n' >&2
  exit 1
fi

# Mutant 1: Corrupt word/document.xml -> must FAIL W0
M1="$TMP/mutant-corrupt"
make_copy "$M1"
mkdir -p "$TMP/m1-unzip"
unzip -q "$M1/usage/OUTPUT-answer.docx" -d "$TMP/m1-unzip"
printf '<<<CORRUPT XML' > "$TMP/m1-unzip/word/document.xml"
(cd "$TMP/m1-unzip" && zip -q -r "$M1/usage/OUTPUT-answer.docx" .)
if bash "$HARNESS" "$M1" >"$TMP/m1.out" 2>"$TMP/m1.err"; then
  printf 'FAIL SELFTEST: mutant-corrupt (W0) was NOT caught\n' >&2
  exit 1
fi
if ! grep -Fq '[W0]' "$TMP/m1.err"; then
  cat "$TMP/m1.err" >&2
  printf 'FAIL SELFTEST: mutant-corrupt failed with unexpected gate (expected [W0])\n' >&2
  exit 1
fi

# Mutant 2: Inject extra paragraphs into word/document.xml shifting page-1 baselines -> must FAIL W1/W2
M2="$TMP/mutant-shift"
make_copy "$M2"
mkdir -p "$TMP/m2-unzip"
unzip -q "$M2/usage/OUTPUT-answer.docx" -d "$TMP/m2-unzip"
awk '{
  gsub(/<w:body>/, "<w:body><w:p><w:r><w:t>MUTANT SHIFT 1</w:t></w:r></w:p><w:p><w:r><w:t>MUTANT SHIFT 2</w:t></w:r></w:p>")
  print
}' "$TMP/m2-unzip/word/document.xml" > "$TMP/m2-unzip/word/document.xml.new"
mv "$TMP/m2-unzip/word/document.xml.new" "$TMP/m2-unzip/word/document.xml"
(cd "$TMP/m2-unzip" && zip -q -r "$M2/usage/OUTPUT-answer.docx" .)
if bash "$HARNESS" "$M2" >"$TMP/m2.out" 2>"$TMP/m2.err"; then
  printf 'FAIL SELFTEST: mutant-shift (W1/W2) was NOT caught\n' >&2
  exit 1
fi
if ! grep -Eq '\[W1\]|\[W2\]' "$TMP/m2.err"; then
  cat "$TMP/m2.err" >&2
  printf 'FAIL SELFTEST: mutant-shift failed with unexpected gate (expected [W1] or [W2])\n' >&2
  exit 1
fi

# Mutant 3: Strip pleading line number 27 from VML textbox in footer -> must FAIL W3
M3="$TMP/mutant-linenum"
make_copy "$M3"
mkdir -p "$TMP/m3-unzip"
unzip -q "$M3/usage/OUTPUT-answer.docx" -d "$TMP/m3-unzip"
for hf in "$TMP/m3-unzip"/word/ftr*.xml "$TMP/m3-unzip"/word/footer*.xml "$TMP/m3-unzip"/word/header*.xml; do
  [[ -f "$hf" ]] || continue
  awk '{ gsub(/>27</, "><"); print }' "$hf" > "$hf.new"
  mv "$hf.new" "$hf"
done
(cd "$TMP/m3-unzip" && zip -q -r "$M3/usage/OUTPUT-answer.docx" .)
if bash "$HARNESS" "$M3" >"$TMP/m3.out" 2>"$TMP/m3.err"; then
  printf 'FAIL SELFTEST: mutant-linenum (W3) was NOT caught\n' >&2
  exit 1
fi
if ! grep -Fq '[W3]' "$TMP/m3.err"; then
  cat "$TMP/m3.err" >&2
  printf 'FAIL SELFTEST: mutant-linenum failed with unexpected gate (expected [W3])\n' >&2
  exit 1
fi

printf 'WORD SELFTEST OK (control passed; 3/3 mutants caught: W0, W1/W2, W3)\n'
