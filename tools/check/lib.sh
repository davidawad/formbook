#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC2034
# ST, MEAS and DETAIL are consumed by the Rust bridge after each check function returns.
# lib.sh: the checks. Sourced by tools/check.sh; one function per `method:` in checks.yaml.
#
# Every check function sets three variables and nothing else:
#   ST      PASS or FAIL
#   MEAS    what was measured (worst instance)
#   DETAIL  extra lines naming the failing instances (empty when passing)
# The driver adds the requirement ID, the expected value and the template file:line to fix.
#
# Per-sample inputs, prepared by the driver in $W:
#   words.tsv runs.tsv blocks.tsv lines.tsv labels.tsv g0.{report,metrics,tags,heads,links} fonts.txt info.txt
# Needs: gawk, yq (mikefarah), jq, poppler (pdfinfo pdffonts pdftotext pdftohtml pdfimages), shasum.

AWKU="env LC_ALL=C.UTF-8 gawk"
CHK="$ROOT/tools/check"

cfg() { yq e "$1" "${CHECKS:-$COURT/checks.yaml}"; }
meta() { yq --front-matter=extract e "$1" "$MD"; }
norm() { $AWKU -f "$CHK/norm.awk" -f "$CHK/normline.awk"; } # stdin -> normal form
nstr() { printf '%s\n' "$1" | sed 's/[*]//g' | norm; }      # a metadata string -> normal form
metric() { sed -n "s/^$1=//p" "$W/g0.metrics"; }
pass_if() { if [ "$1" = 0 ]; then ST=PASS; else ST=FAIL; fi; }

# text of one physical page, runs joined by spaces
page_text() { awk -F'\t' -v p="$1" '$1 == p { printf "%s ", $7 }' "$W/runs.tsv"; }
# physical page of the first heading-like run (top of page) whose text equals $1, at or after page $2
heading_page() { awk -F'\t' -v t="$1" -v from="${2:-1}" '$1 >= from && $2 < 110 && $7 == t { print $1; exit }' "$W/runs.tsv"; }
body_first() { sort -t"$(printf '\t')" -k4,4n "$W/g0.heads" | head -1 | cut -f4; } # page of the first body heading
add_page() { awk -F'\t' '$1 ~ /^1/ && tolower($5) == "addendum" { print $4; exit }' "$W/g0.heads"; }
label_of() { awk -F'\t' -v p="$1" '$1 == p { print $2 }' "$W/labels.tsv"; }
first_run() { $AWKU -v p="$1" -v ft="$FTOP" -f "$CHK/first-run.awk" "$W/runs.tsv"; } # page $1's first line (first-run.awk)

# ---------------------------------------------------------------- Gate 0
chk_g0_content() {
  m=$(metric blocks_missing)
  n=$(metric blocks)
  MEAS="$n blocks, $m missing or altered"
  pass_if "$m"
  DETAIL=$(grep -E '^FAIL (H|P|Q|L) block' "$W/g0.report" | head -8)
}
chk_g0_italics() {
  m=$(metric italic_blocks_bad)
  MEAS="$m blocks with italic text rendered roman"
  pass_if "$m"
  DETAIL=$(grep '^FAIL italic' "$W/g0.report" | head -8)
}
chk_g0_footnotes() {
  m=$(metric footnotes_bad)
  n=$(metric footnotes)
  MEAS="$n footnotes, $m missing or misplaced"
  pass_if "$m"
  DETAIL=$(grep '^FAIL footnote' "$W/g0.report" | head -8)
}

# ---------------------------------------------------------------- Gate 1: page form
chk_page_size() {
  sizes=$(awk '/^Page +[0-9]+ size:/ { s[$4 " x " $6]++ } END { for (k in s) printf "%s (%d pages) ", k, s[k] }' "$W/info.txt")
  want="$(cfg .params.page_width_pt) x $(cfg .params.page_height_pt)"
  MEAS="$sizes"
  if [ "$sizes" = "$want ($NPAGES pages) " ]; then ST=PASS; else ST=FAIL; fi
}

chk_margins() {
  eval "$(cfg '.params | "M=\(.margin_pt) E=\(.eps_pt) PW=\(.page_width_pt) PH=\(.page_height_pt)"')"
  out=$(awk -F'\t' -v M="$M" -v E="$E" -v PW="$PW" -v PH="$PH" '
    function pn(t) { return t ~ /^([0-9]+|[ivxlc]+|Add-[0-9]+)$/ }
    { left = $2; top = $3; right = $4; bot = $5
      if (top >= PH - M) { if (!pn($7)) { bad++; msg[bad] = sprintf("page %d: \"%s\" sits in the bottom margin and is not a page number", $1, $7) } ; next }
      if (left < minl || NR == 1) { minl = left; wl = $1 ": \"" $7 "\"" }
      if (right > maxr) { maxr = right; wr = $1 ": \"" $7 "\"" }
      if (top < mint || NR == 1) { mint = top; wt = $1 ": \"" $7 "\"" }
      if (bot > maxb) { maxb = bot; wb = $1 ": \"" $7 "\"" } }
    END {
      printf "left %.2f right %.2f top %.2f bottom %.2f\n", minl, maxr, mint, maxb
      if (minl < M - E) { bad++; msg[bad] = "left edge " minl " < " M " at page " wl }
      if (maxr > PW - M + E) { bad++; msg[bad] = "right edge " maxr " > " PW - M " at page " wr }
      if (mint < M - E) { bad++; msg[bad] = "top edge " mint " < " M " at page " wt }
      if (maxb > PH - M + E) { bad++; msg[bad] = "bottom edge " maxb " > " PH - M " at page " wb }
      for (i = 1; i <= bad && i <= 8; i++) print "!" msg[i]
      exit (bad > 0) }' "$W/words.tsv") && ST=PASS || ST=FAIL
  MEAS=$(printf '%s\n' "$out" | head -1)
  DETAIL=$(printf '%s\n' "$out" | sed -n 's/^!//p')
}

chk_top_margin_empty() {
  M=$(cfg .params.margin_pt)
  E=$(cfg .params.eps_pt)
  n=$(awk -F'\t' -v M="$M" -v E="$E" '$3 < M - E' "$W/words.tsv" | wc -l | tr -d ' ')
  MEAS="$n words above ${M} pt"
  pass_if "$n"
  DETAIL=$(awk -F'\t' -v M="$M" -v E="$E" '$3 < M - E { printf "page %d: \"%s\" at top %.2f\n", $1, $7, $3 }' "$W/words.tsv" | head -5)
}

chk_double_space() {
  MIN=$(cfg .params.min_body_pitch_pt)
  out=$(awk -F'\t' -v MIN="$MIN" '
    { if ($1 != pp) { pp = $1; prev = "" }
      if ($5 == "P" && prev != "" && pk == "P") { d = $2 - pt; n++; if (n == 1 || d < worst) { worst = d; where = "page " $1 " at y=" $2 } if (d < MIN - 0.01) { bad++; if (bad <= 6) msg[bad] = sprintf("page %d: lines %.2f pt apart at y=%.2f (need >= %s)", $1, d, $2, MIN) } }
      prev = "x"; pt = $2; pk = $5 }
    END { printf "%d consecutive body-line pairs; tightest %.2f pt (%s)\n", n, worst, where; for (i = 1; i <= bad && i <= 6; i++) print "!" msg[i]; exit (bad > 0) }' "$W/lines.tsv") && ST=PASS || ST=FAIL
  MEAS=$(printf '%s\n' "$out" | head -1)
  DETAIL=$(printf '%s\n' "$out" | sed -n 's/^!//p')
}

chk_font_size() {
  want=$(awk -v r="$CALIB" -v s="$(cfg .font.size_pt)" 'BEGIN { printf "%.2f", r * s }')
  out=$(awk -F'\t' -v want="$want" '$7 ~ /[A-Za-z]/ { if (n++ == 0 || $6 < min) { min = $6; w = $1 ": \"" $7 "\"" } if ($6 < want - 0.05) { bad++; if (bad <= 6) msg[bad] = sprintf("page %d: \"%s\" is %.2f pt tall (a 14 pt line is %s)", $1, $7, $6, want) } }
    END { printf "smallest word height %.2f (%s); 14 pt = %s\n", min, w, want; for (i = 1; i <= bad && i <= 6; i++) print "!" msg[i]; exit (bad > 0) }' "$W/words.tsv") && ST=PASS || ST=FAIL
  MEAS=$(printf '%s\n' "$out" | head -1)
  DETAIL=$(printf '%s\n' "$out" | sed -n 's/^!//p')
}

chk_italic_face() {
  if grep -q Italic "$W/fonts.txt"; then
    ST=PASS
    MEAS="an Italic font is embedded"
  else
    ST=FAIL
    MEAS="no Italic font embedded"
  fi
}

chk_fonts_embedded() {
  pre=$(cfg .font.pdf_prefix)
  # latex only: a declared Times New Roman may be a metric-compatible Times (FONT_ALT, set by fb check; fb-595.45)
  if [ -n "${FONT_ALT:-}" ]; then pre="$pre|$FONT_ALT"; fi
  out=$(awk -v pre="$pre" 'NR > 2 { n++
      name = $1; emb = ""; for (i = 1; i <= NF; i++) if ($i == "yes" || $i == "no") { emb = $i; break }
      sub(/^[A-Z]+\+/, "", name)
      if (emb != "yes") { bad++; msg[bad] = $1 " is not embedded" }
      if (name !~ "^(" pre ")") { bad++; msg[bad] = $1 " is not " pre "*  (a fallback font was used)" } }
    END { printf "%d fonts\n", n; for (i = 1; i <= bad; i++) print "!" msg[i]; exit (bad > 0) }' "$W/fonts.txt") && ST=PASS || ST=FAIL
  MEAS=$(printf '%s\n' "$out" | head -1)
  DETAIL=$(printf '%s\n' "$out" | sed -n 's/^!//p')
}

# ---- court-agnostic defaults (data/checks-default.yaml; docs/EVAL-LOOP.md "Default checks")
chk_fonts_all_embedded() {
  out=$(awk 'NR > 2 { n++; emb = ""; for (i = 1; i <= NF; i++) if ($i == "yes" || $i == "no") { emb = $i; break }
      if (emb != "yes") { bad++; msg[bad] = $1 " is not embedded" } }
    END { printf "%d fonts\n", n; if (n == 0) { bad++; msg[bad] = "no fonts in the PDF" } for (i = 1; i <= bad && i <= 8; i++) print "!" msg[i]; exit (bad > 0) }' "$W/fonts.txt") && ST=PASS || ST=FAIL
  MEAS=$(printf '%s\n' "$out" | head -1)
  DETAIL=$(printf '%s\n' "$out" | sed -n 's/^!//p')
}

# default checks: the four edges of body text (a word centred inside the top or bottom margin is a running header or
# footer and is not judged; digit-only words left of the margin are line numbers); vertical tolerance covers glyph boxes
chk_margins_body() {
  eval "$(cfg '.params | "ML=\(.margin_left_pt // .margin_pt) MR=\(.margin_right_pt // .margin_pt) MT=\(.margin_top_pt // .margin_pt) MB=\(.margin_bottom_pt // .margin_pt) E=\(.eps_pt) EV=\(.eps_v_pt) PW=\(.page_width_pt) PH=\(.page_height_pt)"')"
  out=$(awk -F'\t' -v ML="$ML" -v MR="$MR" -v MT="$MT" -v MB="$MB" -v E="$E" -v EV="$EV" -v PW="$PW" -v PH="$PH" '
    { left = $2; top = $3; right = $4; bot = $5
      c = (top + bot) / 2
      if (c < MT || c > PH - MB) next                # running header or footer: not judged
      if ($7 ~ /^[0-9]+$/ && left < ML) next         # pleading-paper line numbers sit in the left margin by design
      b++
      if (left < minl || b == 1) { minl = left; wl = $1 ": \"" $7 "\"" }
      if (right > maxr) { maxr = right; wr = $1 ": \"" $7 "\"" }
      if (top < mint || b == 1) { mint = top; wt = $1 ": \"" $7 "\"" }
      if (bot > maxb) { maxb = bot; wb = $1 ": \"" $7 "\"" } }
    END {
      printf "body left %.2f right %.2f top %.2f bottom %.2f\n", minl, maxr, mint, maxb
      if (minl < ML - E) { bad++; msg[bad] = "left edge " minl " < " ML " at page " wl }
      if (maxr > PW - MR + E) { bad++; msg[bad] = "right edge " maxr " > " PW - MR " at page " wr }
      if (mint < MT - EV) { bad++; msg[bad] = "body top edge " mint " < " MT " at page " wt }
      if (maxb > PH - MB + EV) { bad++; msg[bad] = "body bottom edge " maxb " > " PH - MB " at page " wb }
      for (i = 1; i <= bad; i++) print "!" msg[i]
      exit (bad > 0) }' "$W/words.tsv") && ST=PASS || ST=FAIL
  MEAS=$(printf '%s\n' "$out" | head -1)
  DETAIL=$(printf '%s\n' "$out" | sed -n 's/^!//p')
}

# the most common word height (the body text) is at least the configured size (footnotes and headings may differ)
chk_body_size() {
  want=$(awk -v r="$CALIB" -v s="$(cfg .font.size_pt)" 'BEGIN { printf "%.2f", r * s }')
  out=$(awk -F'\t' -v want="$want" -v size="$(cfg .font.size_pt)" '$7 ~ /[A-Za-z]/ { h = sprintf("%.1f", $6); c[h]++ }
    END { for (k in c) if (c[k] > bm) { bm = c[k]; mode = k }
      printf "body word height %s (%d words); %s pt = %s\n", mode, bm, size, want
      exit (mode + 0 < want - 0.1) }' "$W/words.tsv") && ST=PASS || ST=FAIL
  MEAS=$(printf '%s\n' "$out" | head -1)
  DETAIL=""
}

chk_page_limit() {
  lim=$(cfg .params.page_limit)
  MEAS="$NPAGES pages; limit $lim"
  pass_if $((NPAGES > lim))
}

chk_page_numbers() {
  bf=$(body_first)
  ap=$(add_page)
  out=$(awk -F'\t' -v bf="$bf" -v ap="${ap:-0}" -v N="$NPAGES" '
    function roman(n,   r, v, s, i) { split("1000 900 500 400 100 90 50 40 10 9 5 4 1", v, " "); split("m cm d cd c xc l xl x ix v iv i", s, " "); r = ""; for (i = 1; i <= 13; i++) while (n >= v[i]) { r = r s[i]; n -= v[i] } return r }
    { got[$1] = $2 }
    END { for (p = 1; p <= N; p++) {
        if (p == 1) want = ""
        else if (p < bf) want = roman(p - 1)
        else if (ap > 0 && p >= ap) want = "Add-" (p - ap + 1)
        else want = p - bf + 1
        if (got[p] != want) { bad++; if (bad <= 6) msg[bad] = sprintf("page %d prints \"%s\", expected \"%s\"", p, got[p], want) } }
      printf "%d pages checked; body starts on page %d%s\n", N, bf, (ap > 0 ? "; addendum on page " ap : "")
      for (i = 1; i <= bad && i <= 6; i++) print "!" msg[i]; exit (bad > 0) }' "$W/labels.tsv") && ST=PASS || ST=FAIL
  MEAS=$(printf '%s\n' "$out" | head -1)
  DETAIL=$(printf '%s\n' "$out" | sed -n 's/^!//p')
}

chk_centered_headings() {
  T=$(cfg .params.center_tolerance_pt)
  C=$(awk -v w="$(cfg .params.page_width_pt)" 'BEGIN { print w / 2 }')
  out=$(awk -F'\t' -v T="$T" -v C="$C" '$5 == "Hc" { n++; mid = ($3 + $4) / 2; d = mid - C; if (d < 0) d = -d
      if (d > worst) { worst = d; where = "page " $1 " y=" $2 }
      if (d > T) { bad++; if (bad <= 6) msg[bad] = sprintf("page %d y=%.2f: line centered at %.2f, page center is %s", $1, $2, mid, C) } }
    END { printf "%d centered-heading lines; worst off-center %.2f pt (%s)\n", n, worst, where; if (n == 0) { print "!no centered heading line was found"; exit 1 } for (i = 1; i <= bad && i <= 6; i++) print "!" msg[i]; exit (bad > 0) }' "$W/lines.tsv") && ST=PASS || ST=FAIL
  MEAS=$(printf '%s\n' "$out" | head -1)
  DETAIL=$(printf '%s\n' "$out" | sed -n 's/^!//p')
}

# ---------------------------------------------------------------- Gate 1: length and certificates
cert_page() { heading_page "CERTIFICATE OF COMPLIANCE" "$(body_first)"; }
cert_words() { page_text "$(cert_page)" | sed -n 's/.*contains \([0-9,]*\) words.*/\1/p' | tr -d ','; }
md_words() { $AWKU -f "$CHK/mdcount.awk" "$W/blocks.tsv"; }
pdf_words() { # words on body lines (not the addendum, not the cover, tables or certificates)
  ap=$(add_page)
  awk -F'\t' -v ap="${ap:-0}" '$5 ~ /^(H|Hc|P|Q|L|F)$/ && !(ap > 0 && $1 >= ap) { n += $6 } END { print n + 0 }' "$W/lines.tsv"
}
chk_length_limit() {
  lim=$(cfg .params.word_limit)
  n=$(md_words)
  MEAS="$n words counted from the markdown (limit $lim)"
  if [ "$n" -le "$lim" ]; then ST=PASS; else ST=FAIL; fi
}
chk_cert_count() {
  tol=$(cfg .params.wordcount_tolerance)
  lim=$(cfg .params.word_limit)
  c=$(cert_words)
  m=$(md_words)
  p=$(pdf_words)
  lab=$(awk -F'\t' '$2 != "" && $1 !~ /^1/ { n++ } END { print n + 0 }' "$W/g0.heads")
  lis=$(awk -F'\t' '$1 == "L" { n++ } END { print n + 0 }' "$W/blocks.tsv")
  p=$((p - lab - lis))
  MEAS="certificate says ${c:-none}; independent markdown count $m; PDF-derived count $p (within $tol)"
  ST=PASS
  DETAIL=""
  [ -n "$c" ] || {
    ST=FAIL
    DETAIL="no 'This brief contains N words' sentence found on the certificate page"
    return
  }
  [ "$c" = "$m" ] || {
    ST=FAIL
    DETAIL="certificate $c differs from the independent count $m"
  }
  [ "$c" -le "$lim" ] || {
    ST=FAIL
    DETAIL="$DETAIL
certificate $c exceeds the limit $lim"
  }
  dev=$(awk -v a="$p" -v b="$c" -v t="$tol" 'BEGIN { d = a - b; if (d < 0) d = -d; print (d <= b * t + 3) ? 0 : 1 }')
  [ "$dev" = 0 ] || {
    ST=FAIL
    DETAIL="$DETAIL
the PDF holds about $p counted words but the certificate says $c"
  }
}

form_phrases() { # $1 = forms key, $2 = page
  txt=$(page_text "$2" | norm)
  miss=""
  for i in $(seq 0 $(($(cfg ".forms.$1 | length") - 1))); do
    ph=$(cfg ".forms.$1[$i]")
    k=$(nstr "$ph")
    case "$txt" in *"$k"*) ;; *) miss="$miss
missing: $ph" ;; esac
  done
  printf '%s' "$miss"
}
sig_ok() { # page $1 has "s/ signer"
  s=$(nstr "s/ $(meta .signature.signer)")
  case "$(page_text "$1" | norm)" in *"$s"*) return 0 ;; *) return 1 ;; esac
}
chk_cert_form8() {
  p=$(cert_page)
  ST=PASS
  DETAIL=""
  [ -n "$p" ] || {
    ST=FAIL
    MEAS="no CERTIFICATE OF COMPLIANCE heading"
    return
  }
  MEAS="certificate of compliance on page $p"
  DETAIL=$(form_phrases form8 "$p")
  k=$(nstr "$(meta .case_number)")
  case "$(page_text "$p" | norm)" in *"$k"*) ;; *) DETAIL="$DETAIL
missing: case number $(meta .case_number)" ;; esac
  sig_ok "$p" || DETAIL="$DETAIL
missing: s/ $(meta .signature.signer)"
  [ -z "$DETAIL" ] || ST=FAIL
}
related_page() { heading_page "STATEMENT OF RELATED CASES" "$(body_first)"; }
chk_cert_form17() {
  p=$(related_page)
  ST=PASS
  DETAIL=""
  [ -n "$p" ] || {
    ST=FAIL
    MEAS="no STATEMENT OF RELATED CASES heading"
    return
  }
  MEAS="statement of related cases on page $p"
  DETAIL=$(form_phrases form17 "$p")
  if [ "$(meta '.related_cases.status')" = pending ]; then
    for i in $(seq 0 $(($(meta '.related_cases.cases | length') - 1))); do
      for f in number name relationship; do
        v=$(meta ".related_cases.cases[$i].$f")
        k=$(nstr "$v")
        case "$(page_text "$p" | norm)" in *"$k"*) ;; *) DETAIL="$DETAIL
missing: related case $f \"$v\"" ;; esac
      done
    done
  fi
  sig_ok "$p" || DETAIL="$DETAIL
missing: s/ $(meta .signature.signer)"
  [ -z "$DETAIL" ] || ST=FAIL
}
chk_cert_service() {
  want=$(meta '.service.certificate')
  p=$(heading_page "CERTIFICATE OF SERVICE" "$(body_first)")
  if [ "$want" = true ]; then
    if [ -z "$p" ]; then
      ST=FAIL
      MEAS="service.certificate is true but there is no CERTIFICATE OF SERVICE"
      return
    fi
    MEAS="certificate of service on page $p"
    DETAIL=$(form_phrases form15 "$p")
    sig_ok "$p" || DETAIL="$DETAIL
missing: s/ $(meta .signature.signer)"
    for i in $(seq 0 $(($(meta '.service.unregistered | length') - 1))); do
      v=$(meta ".service.unregistered[$i].name")
      k=$(nstr "$v")
      case "$(page_text "$p" | norm)" in *"$k"*) ;; *) DETAIL="$DETAIL
missing: unregistered participant $v" ;; esac
    done
    [ -z "$DETAIL" ] && ST=PASS || ST=FAIL
  else
    if [ -n "$p" ]; then
      ST=FAIL
      MEAS="a CERTIFICATE OF SERVICE was produced but service.certificate is not true"
    else
      ST=PASS
      MEAS="none, as the metadata asks"
    fi
  fi
}

# ---------------------------------------------------------------- Gate 1: contents and order
heads_lc() { awk -F'\t' '{ print tolower($5) "\t" $1 "\t" $4 }' "$W/g0.heads"; } # text, level, page
chk_heading_present() {
  re="$1"
  hit=$(heads_lc | awk -F'\t' -v re="$re" '$2 ~ /^1/ && $1 ~ re { print $1 " (page " $3 ")"; exit }')
  if [ -n "$hit" ]; then
    ST=PASS
    MEAS="found: $hit"
  else
    ST=FAIL
    MEAS="no level-1 heading matching /$re/"
  fi
}
chk_heading_any_level() {
  re="$1"
  hit=$(heads_lc | awk -F'\t' -v re="$re" '$1 ~ re { print $1 " (level " $2 ", page " $3 ")"; exit }')
  if [ -n "$hit" ]; then
    ST=PASS
    MEAS="found: $hit"
  else
    ST=FAIL
    MEAS="no heading containing '$re'"
  fi
}
chk_section_order() {
  out=$(heads_lc | awk -F'\t' '
    BEGIN { split("^statement of jurisdiction|^statement of (the )?issues?|^statement of the case|^summary of (the )?argument|^argument|^conclusion", re, "|"); n = 6 }
    $2 ~ /^1/ { for (i = 1; i <= n; i++) if ($1 ~ re[i] && !(i in at)) at[i] = ++pos }
    END { last = 0
      for (i = 1; i <= n; i++) { if (!(i in at)) { bad++; msg[bad] = "section " i " (" re[i] ") is missing" } else { if (at[i] < last) { bad++; msg[bad] = "section " i " (" re[i] ") is out of order" } last = at[i] } }
      printf "%d of %d required sections found in order\n", n - bad, n
      for (i = 1; i <= bad; i++) print "!" msg[i]; exit (bad > 0) }') && ST=PASS || ST=FAIL
  MEAS=$(printf '%s\n' "$out" | head -1)
  DETAIL=$(printf '%s\n' "$out" | sed -n 's/^!//p')
}
chk_no_disclosure() {
  n=$(awk -F'\t' '$2 < 110 && tolower($7) ~ /disclosure statement/' "$W/runs.tsv" | wc -l | tr -d ' ')
  MEAS="$n headings mentioning a disclosure statement"
  pass_if "$n"
}
# shellcheck disable=SC2034
chk_heading_labels() {
  out=$(awk -F'\t' '$2 != "" { n++; if ($3 != 1) { bad++; if (bad <= 6) msg[bad] = sprintf("page %d: heading \"%s\" should be preceded by the label \"%s\"", $4, $5, $2) } }
    END { printf "%d numbered headings, %d with a wrong or missing label\n", n, bad; for (i = 1; i <= bad && i <= 6; i++) print "!" msg[i]; exit (bad > 0) }' "$W/g0.heads") && ST=PASS || ST=FAIL
  MEAS=$(printf '%s\n' "$out" | head -1)
  DETAIL=$(printf '%s\n' "$out" | sed -n 's/^!//p')
}

# generated headings that belong in the table of contents, with the page each really sits on
generated_heads() {
  bf=$(body_first)
  ap=$(add_page)
  p=$(heading_page "TABLE OF AUTHORITIES" 3)
  [ -z "$p" ] || printf 'table of authorities\t%s\n' "$p"
  p=$(related_page)
  [ -z "$p" ] || printf 'statement of related cases\t%s\n' "$p"
  p=$(cert_page)
  [ -z "$p" ] || printf 'certificate of compliance\t%s\n' "$p"
  p=$(heading_page "CERTIFICATE OF SERVICE" "$bf")
  [ -z "$p" ] || printf 'certificate of service\t%s\n' "$p"
  if [ -n "$ap" ]; then printf 'addendum\t%s\n' "$ap"; fi
}

# Gate 1-3 checks are split into this module to keep the shared library reviewable.
source "$CHK/_lib/lib-helpers.sh"
