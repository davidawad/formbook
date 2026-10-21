#!/usr/bin/env bash
# calibrate.sh: the word-compat calibration run (fb-w0vj, docs/EVAL-LOOP.md "Word compatibility").
# Renders every entry of data/calibration-set.json with one engine and prints, per entry, G0 (page
# count and size), G2 (content and order) and the identical-line-break count of `fb diff --breaks`,
# then the totals. Nothing is written but the OUTPUT files the render already writes.
# Usage: tools/calibrate.sh [--engine typst|latex] [--no-render] [entry-dir-substring]
set -euo pipefail
FB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export FB_ROOT
engine=typst render=1 only=
while [ $# -gt 0 ]; do
  case "$1" in
    --engine) engine="$2"; shift 2 ;;
    --no-render) render=0; shift ;;
    *) only="$1"; shift ;;
  esac
done
cargo build -q --release --manifest-path "$FB_ROOT/tools/fb/Cargo.toml"
fb="$FB_ROOT/tools/fb/target/release/fb"
tc=0 ti=0 tl=0 g0p=0 n=0
printf '%-70s %-5s %-5s %s\n' "entry" "G0" "G2" "identical/compared (exemplar lines)"
while IFS=$'\t' read -r dir id exemplar; do
  case "$dir" in *"$only"*) ;; *) continue ;; esac
  d="$FB_ROOT/$dir"
  out="$d/usage/OUTPUT-$id.$engine.pdf"
  if [ "$render" = 1 ]; then
    "$fb" render --engine "$engine" --deny-warnings "$d" "usage/INPUT-$id.md" >/dev/null 2>"/tmp/calibrate.$$.err" \
      || { printf '%-70s RENDER FAILED: %s\n' "$dir:$id" "$(head -c 200 /tmp/calibrate.$$.err)"; continue; }
  fi
  c=$("$fb" diff --content "$d/$exemplar" "$out" || true)
  g0=$(printf '%s\n' "$c" | awk '$1=="G0"{print $2}')
  g2=$(printf '%s\n' "$c" | awk '$1=="G2"{print $2}')
  r=$("$fb" diff --breaks "$d/$exemplar" "$out" | awk '/^RESULT: BREAKS/{print $3, $7}' || true)
  set -- $r
  i=${1%/*} cmp=${1#*/} lines=${2#(}
  ti=$((ti+i)) tc=$((tc+cmp)) tl=$((tl+lines)) n=$((n+1))
  [ "$g0" = PASS ] && g0p=$((g0p+1))
  printf '%-70s %-5s %-5s %s/%s (%s)\n' "$dir:$id" "$g0" "$g2" "$i" "$cmp" "$lines"
done < <(jq -r '.entries[] | [.dir, .id, .exemplar] | @tsv' "$FB_ROOT/data/calibration-set.json")
printf 'TOTAL %s entries, engine %s: G0 pass %s/%s; identical line breaks %s/%s compared lines (%s exemplar lines)\n' \
  "$n" "$engine" "$g0p" "$n" "$ti" "$tc" "$tl"
