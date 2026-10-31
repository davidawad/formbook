#!/usr/bin/env bash
# Guard the VML pleading-number boxes used by the N.D. Cal. answer, complaint and proposed-order filters.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
COURT="$ROOT/courts/ninth-circuit/california/federal/northern-district"
filters=(answer complaint proposed-order)
failed=0

for filter in "${filters[@]}"; do
  source="$COURT/$filter/docx/cand.lua"
  if [[ ! -f "$source" ]]; then
    printf 'FAIL %s: missing filter %s\n' "$filter" "$source" >&2
    failed=1
    continue
  fi
  if ! rg -Fq 'local VML_TEXTBOX_TYPE = '\''<v:shapetype id="_x0000_t202"' "$source"; then
    printf 'FAIL %s: VML textbox shapetype declaration missing\n' "$filter" >&2
    failed=1
  fi
  if ! rg -Fq '<v:shape id="CandLineNumbers" type="#_x0000_t202"' "$source"; then
    printf 'FAIL %s: line-number shape does not reference its textbox type\n' "$filter" >&2
    failed=1
  fi
  if ! command -v unzip >/dev/null 2>&1; then
    printf 'FAIL %s: unzip is required to inspect rendered DOCX outputs\n' "$filter" >&2
    failed=1
    continue
  fi
  shopt -s nullglob
  outputs=("$COURT/$filter"/usage/OUTPUT-*.docx)
  shopt -u nullglob
  if ((${#outputs[@]} == 0)); then
    printf 'FAIL %s: no rendered DOCX outputs to inspect\n' "$filter" >&2
    failed=1
  fi
  for output in "${outputs[@]}"; do
    matched=0
    while IFS= read -r part; do
      [[ "$part" == word/*.xml ]] || continue
      xml=$(unzip -p "$output" "$part") || { failed=1; break; }
      if grep -Fq '<v:shapetype id="_x0000_t202"' <<<"$xml" &&
         grep -Fq '<v:shape id="CandLineNumbers" type="#_x0000_t202"' <<<"$xml"; then
        matched=1
        break
      fi
    done < <(unzip -Z1 "$output")
    if (( ! matched )); then
      printf 'FAIL %s: %s has no typed VML line-number textbox\n' "$filter" "$(basename "$output")" >&2
      failed=1
    fi
  done
done

# The motion brief uses DrawingML textboxes from the shared engine, so it must not add an untyped VML textbox.
motion="$COURT/motion-brief/docx/xdoc.lua"
if [[ ! -f "$motion" ]]; then
  printf 'FAIL motion-brief: generated DOCX layout missing\n' >&2
  failed=1
elif rg -n '<v:shape[^>]*CandLineNumbers|<v:shape[^>]*<w:txbxContent>' "$motion"; then
  printf 'FAIL motion-brief: unexpected VML pleading-number textbox\n' >&2
  failed=1
fi

if (( failed )); then exit 1; fi
printf 'VML TEXTBOX GUARD OK (%s)\n' "${filters[*]}"
