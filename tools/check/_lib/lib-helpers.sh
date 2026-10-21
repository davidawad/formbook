#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC2016,SC2034
# SC2016 protects intentionally literal awk programs; SC2034 flags values consumed by the Rust bridge.
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
  n=$($AWKU -v from=2 -v to=$((tp - 1)) -v skip='^(TABLE OF CONTENTS|Page)$' -v footer_top="$FTOP" -f "$CHK/leader-entries.awk" "$W/runs.tsv" | wc -l | tr -d ' ')
  empty=$($AWKU -v from=2 -v to=$((tp - 1)) -v skip='^(TABLE OF CONTENTS|Page)$' -v footer_top="$FTOP" -f "$CHK/leader-entries.awk" "$W/runs.tsv" | awk -F'\t' '$2 == ""' | wc -l | tr -d ' ')
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
  # shellcheck disable=SC2016
  {
    awk -F'\t' -v ap="${ap:-0}" '{ split($1, a, ""); lv = substr($1, 1, 1) + 0 } lv <= 4 && lv >= 1 && !(ap > 0 && $4 >= ap) { print $2 $5 "\t" $4 }' "$W/g0.heads"
    generated_heads | awk -F'\t' '{ print $1 "\t" $2 }'
  } | $AWKU -F'\t' -f "$CHK/norm.awk" -e '{ printf "%s\t%s\n", norm1($1), $2 }' > "$W/toc.expect"
  $AWKU -v from=2 -v to=$((tp - 1)) -v skip='^(TABLE OF CONTENTS|Page)$' -v footer_top="$FTOP" -f "$CHK/leader-entries.awk" "$W/runs.tsv" > "$W/toc.got"
  # shellcheck disable=SC2016
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
  # shellcheck disable=SC2016
  $AWKU -F'\t' -f "$CHK/norm.awk" -v labels="$W/labels.tsv" -v links="$W/toa.links" -v thr="$thr" -e '
    BEGIN { while ((getline l < labels) > 0) { split(l, a, "\t"); lab[a[1]] = a[2] }
            while ((getline l < links) > 0) { split(l, a, "\t"); k = a[1]; p = a[2]; if (!((k, p) in seenp)) { seenp[k, p] = 1; np[k]++; pages[k] = pages[k] (pages[k] == "" ? "" : ",") lab[p] } } }
    { key = $1; kind = $2; name = $3; cite = $4; srt = tolower($5); gsub(/[^a-z0-9 ]/, "", srt)
      if (!(key in np)) next
      title = (name != "") ? name "," cite : cite
      expv = (np[key] >= thr) ? "passim" : pages[key]
      print norm1(title) "\t" key "\t" kind "\t" srt "\t" expv }' "$W/auth.tsv" > "$W/toa.expect"
  $AWKU -v from="$tp" -v to=$((bf - 1)) -v skip='^(TABLE OF AUTHORITIES|Cases:|Constitutional Provisions:|Statutes:|Regulations:|Rules:|Other Authorities:|Page[(]s[)])$' \
    -v footer_top="$FTOP" -f "$CHK/leader-entries.awk" "$W/runs.tsv" > "$W/toa.got"
  # shellcheck disable=SC2016
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
  # shellcheck disable=SC2016
  awk -F'\t' -v ap="$ap" '$1 ~ /^2/ && $4 >= ap { print $5 "\t" $4 }' "$W/g0.heads" |
    $AWKU -F'\t' -f "$CHK/norm.awk" -e '{ printf "%s\t%s\n", norm1($1), $2 }' > "$W/add.expect"
  $AWKU -v from="$ap" -v to="$NPAGES" -v skip='^(TABLE OF CONTENTS|ADDENDUM)$' -v footer_top="$FTOP" -f "$CHK/leader-entries.awk" "$W/runs.tsv" > "$W/add.got"
  # shellcheck disable=SC2016
  bad=$($AWKU -F'\t' -f "$CHK/norm.awk" -v labels="$W/labels.tsv" -e '
    BEGIN { while ((getline l < labels) > 0) { split(l, a, "\t"); lab[a[1]] = a[2] } }
    FILENAME == ARGV[1] { want[$1] = $2; n++; next }
    { k = norm1($1); pg = $2; gsub(/ /, "", pg); got[k] = 1
      if (!(k in want)) { print "the addendum TOC lists \"" $1 "\" which is not an addendum item"; next }
      if (pg != lab[want[k]]) print "the addendum TOC says \"" $1 "\" is on " pg "; it is on " lab[want[k]] }
    END { for (k in want) if (!(k in got)) print "addendum item \"" k "\" is not in the addendum TOC" }' "$W/add.expect" "$W/add.got")
  [ -z "$bad" ] || {
    # shellcheck disable=SC2034
    ST=FAIL
    DETAIL="$DETAIL
$bad"
  }
  MEAS="addendum starts on page $ap ($l); $(wc -l < "$W/add.got" | tr -d ' ') items in its table of contents"
}

# ---------------------------------------------------------------- Gate 2: visual review
chk_review() {
  rd="$COURT/$(cfg .review.dir)"
  newest=$(find "$rd" -maxdepth 1 -type f -name '*.md' -print | sort | tail -1)
  if [ -z "$newest" ]; then
    ST=FAIL
    MEAS="no review file in $(cfg .review.dir)/"
    DETAIL="a reviewer must render every page, compare with the exemplar, and record findings"
    return
  fi
  sha=$(shasum -a 256 "$PDF" | cut -d' ' -f1)
  sec=$(awk -v id="$SID" -v eng="$ENGINE" '/^## sample / { on = ($3 == id && (eng == "typst" ? NF == 3 : $4 == eng)) } on' "$newest")
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
    # shellcheck disable=SC2034
    ST=FAIL
    MEAS="missing features:$miss"
  fi
}

# ---------------------------------------------------------------- Gate 1: the template itself
chk_template_agnostic() { # CA9-TOOL-002: no case-specific text from any sample inside the template
  tmpl="$COURT/$TEMPLATE"
  for sid2 in $(cfg ".samples[].id"); do
    smd="$COURT/$(cfg ".samples[] | select(.id == \"$sid2\") | .md")"
    yq --front-matter=extract -o=json e '[.case_number, (.caption[].names[]), (.caption[].designation), (.counsel[].names[]), .signature.signer, .proceeding, (.authorities[]? | .name, .cite)] | map(select(. != null)) | .[]' "$smd" |
      sed 's/^"//; s/"$//; s/[*]//g' | while IFS= read -r s; do
      [ "${#s}" -ge 6 ] || continue
      grep -r -F -i -q -- "$s" "$tmpl" && echo "$sid2: \"$s\" appears in the template"
    done
  done > "$W/agnostic.txt"
  n=$(wc -l < "$W/agnostic.txt" | tr -d ' ')
  # shellcheck disable=SC2034
  MEAS="$n sample strings found in $(basename "$tmpl")"
  pass_if "$n"
  DETAIL=$(head -6 "$W/agnostic.txt")
}
