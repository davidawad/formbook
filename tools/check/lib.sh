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

AWKU="env LC_ALL=en_US.UTF-8 gawk"
CHK="$ROOT/tools/check"

cfg() { yq e "$1" "$COURT/checks.yaml"; }
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
  out=$(awk -v pre="$pre" 'NR > 2 { n++
      name = $1; emb = ""; for (i = 1; i <= NF; i++) if ($i == "yes" || $i == "no") { emb = $i; break }
      sub(/^[A-Z]+\+/, "", name)
      if (emb != "yes") { bad++; msg[bad] = $1 " is not embedded" }
      if (name !~ "^" pre "-") { bad++; msg[bad] = $1 " is not " pre "-*  (a fallback font was used)" } }
    END { printf "%d fonts\n", n; for (i = 1; i <= bad; i++) print "!" msg[i]; exit (bad > 0) }' "$W/fonts.txt") && ST=PASS || ST=FAIL
  MEAS=$(printf '%s\n' "$out" | head -1)
  DETAIL=$(printf '%s\n' "$out" | sed -n 's/^!//p')
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
pdf_words() {
  awk -F'\t' '$5 ~ /^(H|Hc|P|Q|L|F)$/ { n += $6 } END { print n + 0 }' "$W/lines.tsv"
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
toa_page() { heading_page "TABLE OF AUTHORITIES" 3; }

chk_toc_present() {
  tp=$(toa_page)
  ST=PASS
  DETAIL=""
  first=$(awk -F'\t' '$1 == 2 { print $7; exit }' "$W/runs.tsv")
  [ "$first" = "TABLE OF CONTENTS" ] || {
    ST=FAIL
    DETAIL="page 2 starts with \"$first\", not TABLE OF CONTENTS"
  }
  [ -n "$tp" ] || {
    ST=FAIL
    MEAS="no TABLE OF AUTHORITIES heading"
    return
  }
  n=$($AWKU -v from=2 -v to=$((tp - 1)) -v skip='^(TABLE OF CONTENTS|Page)$' -f "$CHK/leader-entries.awk" "$W/runs.tsv" | wc -l | tr -d ' ')
  empty=$($AWKU -v from=2 -v to=$((tp - 1)) -v skip='^(TABLE OF CONTENTS|Page)$' -f "$CHK/leader-entries.awk" "$W/runs.tsv" | awk -F'\t' '$2 == ""' | wc -l | tr -d ' ')
  MEAS="$n entries with dot leaders on pages 2-$((tp - 1)); $empty without a page number"
  [ "$empty" = 0 ] || {
    ST=FAIL
    DETAIL="$DETAIL
$empty entries have leaders but no page number"
  }
  [ "$n" -gt 0 ] || ST=FAIL
}
chk_toc_pages() {
  tp=$(toa_page)
  [ -n "$tp" ] || {
    ST=FAIL
    MEAS="no TABLE OF AUTHORITIES heading"
    return
  }
  ap=$(add_page)
  {
    awk -F'\t' -v ap="${ap:-0}" '{ split($1, a, ""); lv = substr($1, 1, 1) + 0 } lv <= 4 && lv >= 1 && !(ap > 0 && $4 >= ap) { print $2 $5 "\t" $4 }' "$W/g0.heads"
    generated_heads | awk -F'\t' '{ print $1 "\t" $2 }'
  } | $AWKU -F'\t' -f "$CHK/norm.awk" -e '{ printf "%s\t%s\n", norm1($1), $2 }' > "$W/toc.expect"
  $AWKU -v from=2 -v to=$((tp - 1)) -v skip='^(TABLE OF CONTENTS|Page)$' -f "$CHK/leader-entries.awk" "$W/runs.tsv" > "$W/toc.got"
  out=$($AWKU -F'\t' -f "$CHK/norm.awk" -v labels="$W/labels.tsv" -e '
    BEGIN { while ((getline l < labels) > 0) { split(l, a, "\t"); lab[a[1]] = a[2] } }
    FILENAME == ARGV[1] { want[$1] = $2; order[++ne] = $1; next }
    { k = norm1($1); pg = $2; gsub(/ /, "", pg); seen[k] = 1
      if (!(k in want)) { bad++; if (bad <= 6) msg[bad] = sprintf("TOC lists \"%s\" which is not a heading of the brief", $1); next }
      if (pg != lab[want[k]]) { bad++; if (bad <= 6) msg[bad] = sprintf("TOC says \"%s\" is on page %s; it is on page %s (physical %s)", $1, pg, lab[want[k]], want[k]) } }
    END { for (i = 1; i <= ne; i++) if (!(order[i] in seen)) { miss++; if (miss <= 6) msg[bad + miss] = sprintf("heading \"%s\" (physical page %s) is not in the TOC", order[i], want[order[i]]) }
      printf "%d entries read, %d headings expected; %d wrong, %d missing\n", NR - 0, ne, bad, miss
      for (i = 1; i <= bad + miss && i <= 8; i++) print "!" msg[i]; exit (bad + miss > 0) }' "$W/toc.expect" "$W/toc.got") && ST=PASS || ST=FAIL
  MEAS=$(printf '%s\n' "$out" | head -1)
  DETAIL=$(printf '%s\n' "$out" | sed -n 's/^!//p')
}

# ---------------------------------------------------------------- Gate 1: table of authorities
toa_run() {
  tp=$(toa_page)
  bf=$(body_first)
  [ -n "$tp" ] || {
    TOA_OUT="!no TABLE OF AUTHORITIES heading"
    return
  }
  yq --front-matter=extract -o=json e '.authorities // {}' "$MD" |
    jq -r 'to_entries[] | [.key, .value.kind, (.value.name // ""), .value.cite, (.value.sort // ((.value.name // "") + " " + .value.cite))] | @tsv' |
    sed 's/[*]//g' > "$W/auth.tsv"
  # expected pages per key, in document order, as printed labels
  sort -t"$(printf '\t')" -k2,2n -s "$W/g0.links" 2> /dev/null | awk -F'\t' '{ print $1 "\t" $2 }' > "$W/toa.links"
  thr=$(cfg .params.passim_threshold)
  $AWKU -F'\t' -f "$CHK/norm.awk" -v labels="$W/labels.tsv" -v links="$W/toa.links" -v thr="$thr" -e '
    BEGIN { while ((getline l < labels) > 0) { split(l, a, "\t"); lab[a[1]] = a[2] }
            while ((getline l < links) > 0) { split(l, a, "\t"); k = a[1]; p = a[2]; if (!((k, p) in seenp)) { seenp[k, p] = 1; np[k]++; pages[k] = pages[k] (pages[k] == "" ? "" : ",") lab[p] } } }
    { key = $1; kind = $2; name = $3; cite = $4; srt = tolower($5); gsub(/[^a-z0-9 ]/, "", srt)
      if (!(key in np)) next
      title = (name != "") ? name "," cite : cite
      expv = (np[key] >= thr) ? "passim" : pages[key]
      print norm1(title) "\t" key "\t" kind "\t" srt "\t" expv }' "$W/auth.tsv" > "$W/toa.expect"
  $AWKU -v from="$tp" -v to=$((bf - 1)) -v skip='^(TABLE OF AUTHORITIES|Cases:|Constitutional Provisions:|Statutes:|Regulations:|Rules:|Other Authorities:|Page[(]s[)])$' \
    -f "$CHK/leader-entries.awk" "$W/runs.tsv" > "$W/toa.got"
  TOA_OUT=$($AWKU -F'\t' -f "$CHK/norm.awk" -v expf="$W/toa.expect" -e '
    BEGIN { while ((getline l < expf) > 0) { split(l, a, "\t"); want[a[1]] = a[5]; keyof[a[1]] = a[2]; kind[a[1]] = a[3]; srt[a[1]] = a[4]; nexp++ } }
    { k = norm1($1); pg = $2; gsub(/ /, "", pg)
      if (!(k in want)) { print "STRAY\t" $1; next }
      got[k] = 1
      if (pg != want[k]) print "PAGES\t" keyof[k] "\tTOA says " pg "\tthe citations are on " want[k]
      if (kind[k] == "case") { if (prev != "" && srt[k] < prev) print "ORDER\t" keyof[k] "\tcomes after an entry that sorts later"; prev = srt[k] } }
    END { for (k in want) if (!(k in got)) print "MISSING\t" keyof[k] "\tcited in the body but not listed"; print "COUNT\t" nexp "\t" NR }' "$W/toa.got")
}
chk_toa_complete() {
  toa_run
  n=$(printf '%s\n' "$TOA_OUT" | awk -F'\t' '$1 == "MISSING" || $1 == "ORDER" || $1 == "STRAY"' | wc -l | tr -d ' ')
  cnt=$(printf '%s\n' "$TOA_OUT" | awk -F'\t' '$1 == "COUNT" { print $2 " cited authorities, " $3 " TOA entries" }')
  MEAS="$cnt; $n missing, stray or out of order"
  pass_if "$n"
  DETAIL=$(printf '%s\n' "$TOA_OUT" | awk -F'\t' '$1 == "MISSING" || $1 == "ORDER" || $1 == "STRAY" { print $1 ": " $2 " " $3 }' | head -8)
}
chk_toa_pages() {
  toa_run
  n=$(printf '%s\n' "$TOA_OUT" | awk -F'\t' '$1 == "PAGES"' | wc -l | tr -d ' ')
  MEAS="$n entries with wrong page references"
  pass_if "$n"
  DETAIL=$(printf '%s\n' "$TOA_OUT" | awk -F'\t' '$1 == "PAGES" { print $2 ": " $3 "; " $4 }' | head -8)
}

# ---------------------------------------------------------------- Gate 1: cover
p1norm() { page_text 1 | norm; }
contains() { case "$1" in *"$2"*) return 0 ;; *) return 1 ;; esac }
chk_cover_one_page() {
  first=$(awk -F'\t' '$1 == 2 { print $7; exit }' "$W/runs.tsv")
  MEAS="page 2 starts with \"$first\""
  if [ "$first" = "TABLE OF CONTENTS" ]; then ST=PASS; else
    ST=FAIL
    DETAIL="the cover spills onto page 2"
  fi
}
chk_cover_number() {
  want=$(nstr "No. $(meta .case_number)")
  out=$(awk -F'\t' '$1 == 1 { if (t == "" || $3 < t - 0.5) { t = $3; l = ""; n = 0; lo = 1e9; hi = 0 } if ($3 > t - 0.5 && $3 < t + 0.5) { l = l $7; if ($2 < lo) lo = $2; if ($4 > hi) hi = $4 } } END { printf "%s\t%.2f\n", l, (lo + hi) / 2 }' "$W/words.tsv")
  got=$(printf '%s' "$out" | cut -f1 | norm)
  mid=$(printf '%s' "$out" | cut -f2)
  C=$(awk -v w="$(cfg .params.page_width_pt)" 'BEGIN { print w / 2 }')
  T=$(cfg .params.center_tolerance_pt)
  MEAS="top line of page 1: \"$(printf '%s' "$out" | cut -f1)\" centered at $mid (page center $C)"
  ok=$(awk -v m="$mid" -v c="$C" -v t="$T" 'BEGIN { d = m - c; if (d < 0) d = -d; print (d <= t) ? 1 : 0 }')
  if [ "$got" = "$want" ] && [ "$ok" = 1 ]; then ST=PASS; else
    ST=FAIL
    DETAIL="expected the top line to be \"No. $(meta .case_number)\", centered"
  fi
}
chk_cover_court() {
  t=$(page_text 1)
  n=$(printf '%s' "$t" | norm)
  ST=PASS
  DETAIL=""
  contains "$n" "$(nstr 'IN THE UNITED STATES COURT OF APPEALS FOR THE NINTH CIRCUIT')" || {
    ST=FAIL
    DETAIL="the Ninth Circuit court name is not on the cover"
  }
  for bad in "UNITED STATES DISTRICT COURT" "Civil Action" "CIVIL ACTION" "Case No." "Plaintiff," "Defendant,"; do
    case "$t" in *"$bad"*)
      ST=FAIL
      DETAIL="$DETAIL
the cover carries district-court caption text: \"$bad\""
      ;;
    esac
  done
  MEAS="court name present; no district-court caption text on page 1"
}
chk_cover_caption() {
  n=$(p1norm)
  ST=PASS
  DETAIL=""
  for v in $(meta '.caption[].names[]' | tr ' ' '\037') $(meta '.caption[].designation' | tr ' ' '\037'); do
    v=$(printf '%s' "$v" | tr '\037' ' ')
    contains "$n" "$(nstr "$v")" || {
      ST=FAIL
      DETAIL="$DETAIL
missing from the cover: $v"
    }
  done
  MEAS="every caption name and designation checked against page 1"
}
chk_cover_field() {
  v=$(meta ".$1")
  n=$(p1norm)
  k=$(nstr "$v")
  MEAS="$1: \"$v\""
  if contains "$n" "$k"; then ST=PASS; else
    ST=FAIL
    DETAIL="not found on page 1: $v"
  fi
}
chk_cover_counsel() {
  n=$(p1norm)
  ST=PASS
  DETAIL=""
  for v in $(meta '.counsel[].names[]' | tr ' ' '\037') $(meta '.counsel[].lines[]' | tr ' ' '\037') $(meta '.phone' | tr ' ' '\037'); do
    v=$(printf '%s' "$v" | tr '\037' ' ')
    contains "$n" "$(nstr "$v")" || {
      ST=FAIL
      DETAIL="$DETAIL
missing from the cover: $v"
    }
  done
  MEAS="counsel names, lines and telephone checked against page 1"
}
chk_cover_optional() {
  n=$(p1norm)
  ST=PASS
  DETAIL=""
  for f in district_court_case judge; do
    v=$(meta ".$f")
    [ "$v" = null ] && continue
    contains "$n" "$(nstr "$v")" || {
      ST=FAIL
      DETAIL="$DETAIL
$f \"$v\" is in the metadata but not on the cover"
    }
  done
  MEAS="optional cover fields checked"
}

# ---------------------------------------------------------------- Gate 1: electronic filing
chk_elec_text() {
  empty=$(awk -F'\t' -v N="$NPAGES" '{ c[$1]++ } END { for (p = 1; p <= N; p++) if (!c[p]) printf "%d ", p }' "$W/words.tsv")
  img=$(pdfimages -list "$PDF" 2> /dev/null | awk 'NR > 2' | wc -l | tr -d ' ')
  MEAS="pages without extractable text: ${empty:-none}; raster images: $img"
  if [ -z "$empty" ] && [ "$img" = 0 ]; then ST=PASS; else ST=FAIL; fi
}
chk_elec_size() {
  b=$(wc -c < "$PDF" | tr -d ' ')
  mb=$(awk -v b="$b" 'BEGIN { printf "%.2f", b / 1048576 }')
  MEAS="$mb MB"
  lim=$(cfg .params.max_attachment_mb)
  if awk -v m="$mb" -v l="$lim" 'BEGIN { exit !(m < l) }'; then ST=PASS; else ST=FAIL; fi
}
chk_elec_signature() {
  s=$(nstr "s/ $(meta .signature.signer)")
  c=$(page_text_all | norm | awk -v s="$s" '{ n = gsub(s, "&"); print n }')
  need=3
  [ "$(meta .service.certificate)" = true ] && need=4
  MEAS="\"s/ $(meta .signature.signer)\" appears $c times (need $need)"
  if [ "$c" -ge "$need" ]; then ST=PASS; else ST=FAIL; fi
}
page_text_all() { awk -F'\t' '$2 < 720 { printf "%s ", $7 }' "$W/runs.tsv"; }
chk_elec_bookmarks() {
  n=$(pdftohtml -xml -i -q -stdout "$PDF" 2> /dev/null | grep -c '^<item ')
  h1=$(awk -F'\t' '$1 ~ /^1/' "$W/g0.heads" | wc -l | tr -d ' ')
  MEAS="$n bookmarks, $h1 level-1 headings in the markdown"
  if [ "$n" -ge "$h1" ] && [ "$n" -gt 0 ]; then ST=PASS; else ST=FAIL; fi
}

chk_addendum() {
  ap=$(add_page)
  if [ -z "$ap" ]; then
    ST=PASS
    MEAS="no addendum in this sample (not applicable)"
    return
  fi
  ST=PASS
  DETAIL=""
  l=$(label_of "$ap")
  [ "$l" = "Add-1" ] || {
    ST=FAIL
    DETAIL="the addendum's first page prints \"$l\", not Add-1"
  }
  first=$(awk -F'\t' -v p="$ap" '$1 == p { print $7; exit }' "$W/runs.tsv")
  [ "$first" = "ADDENDUM" ] || {
    ST=FAIL
    DETAIL="$DETAIL
the addendum page starts with \"$first\", not ADDENDUM"
  }
  has=$(awk -F'\t' -v p="$ap" '$1 == p && $7 == "TABLE OF CONTENTS"' "$W/runs.tsv" | wc -l | tr -d ' ')
  [ "$has" -ge 1 ] || {
    ST=FAIL
    DETAIL="$DETAIL
the addendum has no TABLE OF CONTENTS of its own (Circuit Rule 28-2.7)"
  }
  awk -F'\t' -v ap="$ap" '$1 ~ /^2/ && $4 >= ap { print $5 "\t" $4 }' "$W/g0.heads" |
    $AWKU -F'\t' -f "$CHK/norm.awk" -e '{ printf "%s\t%s\n", norm1($1), $2 }' > "$W/add.expect"
  $AWKU -v from="$ap" -v to="$NPAGES" -v skip='^(TABLE OF CONTENTS|ADDENDUM)$' -f "$CHK/leader-entries.awk" "$W/runs.tsv" > "$W/add.got"
  bad=$($AWKU -F'\t' -f "$CHK/norm.awk" -v labels="$W/labels.tsv" -e '
    BEGIN { while ((getline l < labels) > 0) { split(l, a, "\t"); lab[a[1]] = a[2] } }
    FILENAME == ARGV[1] { want[$1] = $2; n++; next }
    { k = norm1($1); pg = $2; gsub(/ /, "", pg); got[k] = 1
      if (!(k in want)) { print "the addendum TOC lists \"" $1 "\" which is not an addendum item"; next }
      if (pg != lab[want[k]]) print "the addendum TOC says \"" $1 "\" is on " pg "; it is on " lab[want[k]] }
    END { for (k in want) if (!(k in got)) print "addendum item \"" k "\" is not in the addendum TOC" }' "$W/add.expect" "$W/add.got")
  [ -z "$bad" ] || {
    ST=FAIL
    DETAIL="$DETAIL
$bad"
  }
  MEAS="addendum starts on page $ap ($l); $(wc -l < "$W/add.got" | tr -d ' ') items in its table of contents"
}

# ---------------------------------------------------------------- Gate 2: visual review
chk_review() {
  rd="$COURT/$(cfg .review.dir)"
  newest=$(ls -1 "$rd"/*.md 2> /dev/null | sort | tail -1)
  if [ -z "$newest" ]; then
    ST=FAIL
    MEAS="no review file in $(cfg .review.dir)/"
    DETAIL="a reviewer must render every page, compare with the exemplar, and record findings"
    return
  fi
  sha=$(shasum -a 256 "$PDF" | cut -d' ' -f1)
  sec=$(awk -v id="$SID" '/^## sample / { on = ($3 == id) } on' "$newest")
  if [ -z "$sec" ]; then
    ST=FAIL
    MEAS="$(basename "$newest") has no '## sample $SID' section"
    return
  fi
  out=$(printf '%s\n' "$sec" | awk -F'|' -v sha="$sha" -v N="$NPAGES" '
    /^sha256:/ { got = $0; sub(/^sha256:[ \t]*/, "", got); gsub(/[ \t]/, "", got) }
    /^\|[ \t]*[0-9]+[ \t]*\|/ { p = $2 + 0; st = $(NF - 1); gsub(/[ \t]/, "", st); rows[p]++; if (st == "OPEN") { open++; if (open <= 6) msg[open] = "page " p ": " $(NF - 2) }
        else if (st != "PASS" && st != "FIXED" && st != "ACCEPTED") { badst++; if (badst <= 3) bmsg[badst] = "page " p " has the unknown status \"" st "\"" } }
    END { if (got != sha) { stale = 1 }
      for (p = 1; p <= N; p++) if (!rows[p]) { nopg = nopg " " p }
      printf "review %s: %d pages, %d open, %s\n", FILENAME, N, open + 0, (stale ? "STALE (the PDF changed after the review)" : "current")
      if (stale) print "!the review recorded sha256 " got " but the PDF is " sha
      if (nopg != "") print "!no review row for page(s):" nopg
      for (i = 1; i <= open && i <= 6; i++) print "!OPEN " msg[i]
      for (i = 1; i <= badst; i++) print "!" bmsg[i]
      exit (stale || nopg != "" || open > 0 || badst > 0) }') && ST=PASS || ST=FAIL
  MEAS=$(printf '%s\n' "$out" | head -1 | sed "s|review [^:]*:|$(basename "$newest"):|")
  DETAIL=$(printf '%s\n' "$out" | sed -n 's/^!//p')
}

# ---------------------------------------------------------------- Gate 3: generalization (run once, on the second sample)
chk_generalization_features() {
  g=$(cfg .generalization.second_sample)
  gmd="$COURT/$(cfg ".samples[] | select(.id == \"$g\") | .md")"
  body=$(sed '1,/^---$/d' "$gmd")
  miss=""
  has() { printf '%s\n' "$body" | grep -Eq "$1"; }
  for f in $(cfg '.generalization.require_features[]'); do
    case $f in
      footnote) has '^\[\^[^]]+\]:' ;;
      block_quote) has '^> ' ;;
      escaped_numeral_start) has '^[0-9]+\\\. ' ;;
      escaped_dash_start) has '^\\- ' ;;
      escaped_paren_numeral_start) has '^[0-9]+\\\) ' ;;
      escaped_plus_start) has '^\\\+ ' ;;
      heading_depth_5) has '^##### ' ;;
      three_or_more_parties) [ "$(yq --front-matter=extract e '.caption[0].names | length' "$gmd")" -ge 3 ] ;;
      addendum) has '^# Addendum' ;;
      toa_every_kind) [ "$(yq --front-matter=extract -o=json e '[.authorities[].kind] | unique | length' "$gmd")" -ge 6 ] ;;
      certificate_of_service) [ "$(yq --front-matter=extract e '.service.certificate' "$gmd")" = true ] ;;
      related_cases_listed) [ "$(yq --front-matter=extract e '.related_cases.cases | length' "$gmd")" -ge 1 ] ;;
      ordered_list) has '^[0-9]+\. ' ;;
      *) false ;;
    esac || miss="$miss $f"
  done
  if [ -z "$miss" ]; then
    ST=PASS
    MEAS="all $(cfg '.generalization.require_features | length') required features present in $g"
  else
    ST=FAIL
    MEAS="missing features:$miss"
  fi
}
