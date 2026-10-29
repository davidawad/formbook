#!/usr/bin/env sh
# gen-xetimes.sh: write the advance table of lib/latex/xetimes.sty (fb-595.54.84) from the pinned Times New Roman.
# Usage: tools/gen-xetimes.sh            (rewrites the lines between BEGIN TABLE and END TABLE in place)
#        tools/gen-xetimes.sh --check    (exits 1 if the committed table differs from a fresh one)
# Needs pdflatex (newtxtext), pdftotext, typst, jq, gawk and the four Times New Roman files pinned in
# data/render-pin.json (FB_TNR_DIR, else ~/.local/share/formbook/msttcorefonts, else the Debian install).
# Each T1 slot's character is read from newtx's own ToUnicode map (a page of every slot, through pdftotext); the
# slots kept are those that set one character Times New Roman has: not the accents (0-12), the compound word mark
# and the per-mille zero (23, 24), the dotless j (26), the f-ligatures and the visible space (27-32), the alternate
# hyphen (127) or the capital sharp s (223). typst measures each in the four faces at 2048 pt, so the width in pt is
# the advance in the font's 2048ths of an em.
set -eu
root="$(cd "$(dirname "$0")/.." && pwd)"
sty="$root/lib/latex/xetimes.sty"
check=0
[ "${1:-}" = --check ] && check=1

tnr=""
for d in ${FB_TNR_DIR:-} "$HOME/.local/share/formbook/msttcorefonts" /usr/share/fonts/truetype/msttcorefonts; do
  ok=1
  for f in $(jq -r '.tnr_sha256 | keys[]' "$root/data/render-pin.json"); do
    want=$(jq -r --arg f "$f" '.tnr_sha256[$f]' "$root/data/render-pin.json")
    have=$(sha256sum "$d/$f" 2>/dev/null | cut -d' ' -f1)
    [ "$have" = "$want" ] || ok=0
  done
  if [ $ok = 1 ]; then tnr=$d; break; fi
done
[ -n "$tnr" ] || { echo "gen-xetimes: no directory holds the pinned Times New Roman files (data/render-pin.json)" >&2; exit 2; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
# Stage only the pinned files, so typst can pick no other font.
mkdir "$work/fonts"
for f in $(jq -r '.tnr_sha256 | keys[]' "$root/data/render-pin.json"); do cp "$tnr/$f" "$work/fonts/"; done

cat > "$work/slots.tex" <<'TEX'
\documentclass{article}\usepackage[T1]{fontenc}\usepackage{newtxtext}\pagestyle{empty}
\begin{document}\count255=0
\loop \noindent\the\count255:\char\count255 :\par \advance\count255 1 \ifnum\count255<256 \repeat
\end{document}
TEX
(cd "$work" && pdflatex -interaction=nonstopmode slots.tex >/dev/null) ||
  { echo "gen-xetimes: pdflatex failed on the slot page" >&2; exit 2; }

{
  echo '#let slots = ('
  pdftotext -enc UTF-8 "$work/slots.pdf" - | gawk -F: '
    NF == 3 && length($2) == 1 && $1 >= 13 && $1 != 23 && $1 != 24 && $1 != 26 && ($1 < 27 || $1 > 32) &&
    $1 != 127 && $1 != 223 {
      c = $2; gsub(/\\/, "\\\\", c); gsub(/"/, "\\\"", c); printf "  (%d, \"%s\"),\n", $1, c }'
  echo ')'
  cat <<'TYP'
#let faces = (("normal", "regular"), ("italic", "regular"), ("normal", "bold"), ("italic", "bold"))
#let advance(c, style, weight) = measure(text(font: "Times New Roman", size: 2048pt, kerning: false,
  ligatures: false, fallback: false, style: style, weight: weight, c)).width / 1pt
#context [#metadata(slots.map(((s, c)) => (s, ..faces.map(((st, wt)) => advance(c, st, wt)))))<w>]
TYP
} > "$work/w.typ"
typst eval --ignore-system-fonts --font-path "$work/fonts" --in "$work/w.typ" 'query(<w>).first().value' |
  jq -r '.[] | if (.[1:] | all(. == floor)) then (map(floor) | "\\xe@do{\(.[0])}{\(.[1])}{\(.[2])}{\(.[3])}{\(.[4])}%")
    else error("gen-xetimes: an advance of slot \(.[0]) is not a whole 2048th") end' > "$work/table"
[ "$(wc -l < "$work/table")" -gt 200 ] || { echo "gen-xetimes: too few slots measured" >&2; exit 2; }

gawk -v table="$work/table" '
  /^% END TABLE/ { while ((getline l < table) > 0) print l; print "}"; skip = 0 }
  !skip { print }
  /^\\def\\xe@tnr@table\{%$/ { skip = 1 }' "$sty" > "$work/new.sty"
if [ $check = 1 ]; then
  cmp -s "$sty" "$work/new.sty" || { echo "gen-xetimes: lib/latex/xetimes.sty is not the generated table" >&2; exit 1; }
  echo "gen-xetimes: lib/latex/xetimes.sty is current"
else
  cp "$work/new.sty" "$sty"
fi
