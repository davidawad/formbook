# md-blocks.awk: a sample's markdown body -> one record per block, for the content gate.
#
# Usage: gawk -f md-blocks.awk sample.md > blocks.tsv
#
# Record: KIND <TAB> LEVEL <TAB> LABEL <TAB> TEXT
#   KIND   H heading, P paragraph, Q block quote, L list item, F footnote definition (LEVEL = key)
#   LEVEL  heading level (1-6) plus "c" when the template centers that heading; else "-"
#   LABEL  heading label the template must print ("I.", "A.", "1.", "a.", "(1)"), "" if none
#   TEXT   inline markup resolved into control characters, so later stages never see markdown:
#            \002 \003  italic on / off          \004KEY\005 ... \006  link to authority KEY
#            \007KEY\010  footnote reference     all backslash escapes already removed
#
# The parse is plain CommonMark for the constructs the template supports. It is written
# independently of the template (typst) so that a template bug cannot hide itself.

function resolve(s,    out, i, c, n, d, j, depth, txt, url, k, ital) {
  out = ""; i = 1; n = length(s); ital = 0
  while (i <= n) {
    c = substr(s, i, 1)
    if (c == "\\" && i < n) { out = out substr(s, i + 1, 1); i += 2; continue }
    if (c == "[" && substr(s, i + 1, 1) == "^" && (j = index(substr(s, i), "]")) > 0) {
      out = out "\007" substr(s, i + 2, j - 3) "\010"; i += j; continue
    }
    if (c == "[") {                       # link only if the matching ] is followed by (
      depth = 0; j = i
      for (k = i; k <= n; k++) {
        d = substr(s, k, 1)
        if (d == "\\") { k++; continue }
        if (d == "[") depth++
        else if (d == "]") { depth--; if (depth == 0) { j = k; break } }
      }
      if (j > i && substr(s, j + 1, 1) == "(") {
        txt = substr(s, i + 1, j - i - 1)
        k = index(substr(s, j + 1), ")"); url = substr(s, j + 2, k - 2)
        if (url ~ /^toa:/) out = out "\004" substr(url, 5) "\005" resolve(txt) "\006"
        else out = out resolve(txt)
        i = j + 1 + k; continue
      }
      out = out c; i++; continue
    }
    if (c == "*") {
      if (DEHYPHEN != "" && !ital && index(substr(s, i + 1), "*") == 0) { out = out c; i++; continue }   # a lone star ("*3" star page) is literal
      # CommonMark: a star that cannot open emphasis is literal text. "* * *" (an ellipsis: stars before a space) and
      # "Jones*," (a star after a letter, before punctuation) open nothing.
      if (DEHYPHEN != "" && !ital) {
        d = substr(s, i + 1, 1)
        if (d == "" || d ~ /[ \t]/ || (d ~ /[[:punct:]]/ && d != "*" && i > 1 && substr(s, i - 1, 1) ~ /[[:alnum:]]/)) { out = out c; i++; continue }
      }
      if (substr(s, i + 1, 1) == "*") { i += 2; continue }     # bold: no text effect
      ital = !ital; out = out (ital ? "\002" : "\003"); i++; continue
    }
    # default checks: a blank ("Br. __", "Appx__") is literal text: a run of underscores with nothing to emphasize
    # after it opens nothing (CommonMark finds no closer, and pandoc prints the underscores)
    if (DEHYPHEN != "" && c == "_" && !ital && match(substr(s, i), /^__+/) && substr(s, i + RLENGTH, 1) !~ /[[:alnum:]*]/) {
      out = out substr(s, i, RLENGTH); i += RLENGTH; continue
    }
    if (c == "_" && (i == 1 || substr(s, i - 1, 1) ~ /[ \t(\[“"]/) && substr(s, i + 1, 1) !~ /[ \t]/) {
      ital = 1; out = out "\002"; i++; continue
    }
    if (c == "_" && ital && substr(s, i + 1, 1) ~ /^([ \t.,;:)\]”"!?]|)$/) {
      ital = 0; out = out "\003"; i++; continue
    }
    if (c == "`") { i++; continue }
    out = out c; i++
  }
  return out
}

function flush(   t) {
  if (buf != "") {
    t = resolve(buf)
    if (DEHYPHEN != "" && t ~ /\{\{[^{}]*\}\}/) {    # default checks: a {{name}} placeholder is expanded by the template, so it matches any text:
      n = split(t, seg, /\{\{[^{}]*\}\}/)              # the block becomes its literal segments, each found in order; the placeholder itself is skipped
      for (i = 1; i <= n; i++) if (seg[i] !~ /^[ \t]*$/) print bkind "\t-\t\t" seg[i]
    } else print bkind "\t-\t\t" t
  }
  buf = ""; bkind = ""
}

function label(level, arg,    n) {
  n = cnt[level]
  if (arg) {
    if (level == 2) return roman(n) "."
    if (level == 3) return sprintf("%c", 64 + n) "."
    if (level == 4) return n "."
    if (level == 5) return sprintf("%c", 96 + n) "."
  } else {
    if (level == 2) return sprintf("%c", 64 + n) "."
    if (level == 3) return n "."
    if (level == 4) return sprintf("%c", 96 + n) "."
    if (level == 5) return "(" n ")"
  }
  return ""
}
function roman(n,   r, v, s, i) {
  split("1000 900 500 400 100 90 50 40 10 9 5 4 1", v, " ")
  split("M CM D CD C XC L XL X IX V IV I", s, " ")
  r = ""
  for (i = 1; i <= 13; i++) while (n >= v[i]) { r = r s[i]; n -= v[i] }
  return r
}

BEGIN { fm = 0; incomment = 0; section = ""; addendum = 0 }

# frontmatter
NR == 1 && /^---[ \t]*$/ { fm = 1; next }
# A "footnotes:" map in the frontmatter (a template that takes its notes from there, with the [^n] reference in
# a frontmatter field) is emitted as footnote definitions flagged "fm" in the LABEL column.
function fm_note_end() {
  if (fmkey != "") print "F\t" fmkey "\tfm\t" resolve(fmval)
  fmkey = ""; fmval = ""
}
fm == 1 {
  if ($0 ~ /^---[ \t]*$/) { fm_note_end(); fm = 2; infn = 0; next }
  if ($0 ~ /^footnotes:[ \t]*$/) { infn = 1; next }
  if (infn && $0 ~ /^[^ \t#]/) { fm_note_end(); infn = 0 }
  if (infn) {
    if ($0 ~ /^  ["']?[^"':]+["']?:/) {
      fm_note_end()
      fmkey = $0; sub(/^  ["']?/, "", fmkey); sub(/["']?:.*$/, "", fmkey)
      v = $0; sub(/^  ["']?[^"':]+["']?:[ \t]*/, "", v)
      if (v !~ /^[>|][-+]?[ \t]*$/) { gsub(/^["']|["']$/, "", v); fmval = v }
    } else if ($0 !~ /^[ \t]*$/) {
      v = $0; sub(/^[ \t]+/, "", v)
      fmval = (fmval == "" ? v : fmval " " v)
    }
  }
  next
}

# html comments (single or multi-line)
{
  line = $0
  while (match(line, /<!--[^>]*-->/)) line = substr(line, 1, RSTART - 1) substr(line, RSTART + RLENGTH)
  if (incomment) { if (line ~ /-->/) { sub(/^.*-->/, "", line); incomment = 0 } else next }
  if (line ~ /<!--/) { sub(/<!--.*$/, "", line); incomment = 1 }
}

# blank line ends the current block
line ~ /^[ \t]*$/ { flush(); next }
line ~ /^>[ \t]*$/ { flush(); next }

# footnote definition
line ~ /^\[\^[^\]]+\]:/ {
  flush()
  key = line; sub(/^\[\^/, "", key); sub(/\].*$/, "", key)
  body = line; sub(/^\[\^[^\]]+\]:[ \t]*/, "", body)
  print "F\t" key "\t\t" resolve(body)
  next
}

# heading
line ~ /^#{1,6}[ \t]+/ {
  flush()
  lv = 0; while (substr(line, lv + 1, 1) == "#") lv++
  txt = substr(line, lv + 1); sub(/^[ \t]+/, "", txt); sub(/[ \t]+$/, "", txt)
  if (lv == 1) {
    section = tolower(txt); for (k = 2; k <= 6; k++) cnt[k] = 0
    if (section == "addendum") addendum = 1
  } else {
    cnt[lv]++; for (k = lv + 1; k <= 6; k++) cnt[k] = 0
  }
  lab = (lv >= 2 && !addendum) ? label(lv, section == "argument") : ""
  cen = (lv == 1 || (lv == 2 && section == "argument" && !addendum)) ? "c" : ""
  print "H\t" lv cen "\t" lab "\t" resolve(txt)
  next
}

# block quote line
line ~ /^>/ {
  q = line; sub(/^>[ \t]?/, "", q)
  if (bkind != "Q") { flush(); bkind = "Q" }
  # default checks: a list inside a quote is bulleted or numbered by the template; each item is its own block
  if (DEHYPHEN != "" && q ~ /^[ \t]*([-*+]|[0-9]+[.)])[ \t]+/) { flush(); bkind = "Q"; sub(/^[ \t]*([-*+]|[0-9]+[.)])[ \t]+/, "", q) }
  buf = (buf == "" ? q : buf " " q)
  next
}

# default checks: a thematic break ("* * *", "---", "___") is not text
DEHYPHEN != "" && line ~ /^[ \t]*([-*_][ \t]*){3,}$/ { flush(); next }

# list item (unescaped marker): its own block
line ~ /^[ \t]*([-*+]|[0-9]+[.)])[ \t]+/ {
  flush()
  m = line; sub(/^[ \t]*/, "", m)
  # default checks (-v DEHYPHEN=1): templates number and bullet lists their own way, so the marker is not content
  if (m ~ /^[0-9]/) { num = m; sub(/[.)].*$/, "", num); sub(/^[0-9]+[.)][ \t]+/, "", m); buf = (DEHYPHEN != "" ? "" : num ". ") m }
  else { sub(/^[-*+][ \t]+/, "", m); buf = (DEHYPHEN != "" ? "" : "• ") m }
  bkind = "L"
  next
}

# paragraph text (continuation lines are joined with a space)
{
  t = line; sub(/^[ \t]+/, "", t)
  if (DEHYPHEN != "") {   # default checks: template-local paragraph markers ("~ ", "^") and pipe-table syntax are not content
    if (t ~ /^\|[ \t:|-]+\|?[ \t]*$/) next
    if (t ~ /^\|/) {          # pipe-table row: one record per row, cells joined by \001, so the gate can read them in any order
      flush()
      sub(/^\|/, "", t); sub(/\|[ \t]*$/, "", t)
      ncell = split(t, cells, /\|/); t = ""
      for (ci = 1; ci <= ncell; ci++) { c1 = cells[ci]; gsub(/^[ \t]+|[ \t]+$/, "", c1); t = t (ci > 1 ? "\001" : "") c1 }
      buf = t; bkind = "R"; flush()
      next
    }
    sub(/^~ /, "", t); sub(/^\^/, "", t)
    # template directives consumed (not printed) by court templates: the content is what follows them
    if (t ~ /^(\[\[(TOC|TOA|MEMO)\]\]|\[signature\])[ \t]*$/) next      # table / section / signature markers print no INPUT text
    sub(/^\[unnumbered\][ \t]*/, "", t); sub(/^\[sig\][ \t]*/, "", t)    # unnumbered paragraph, signature-block line
    sub(/^§ /, "", t)                                                     # Guam "§ " unnumbered-paragraph marker
    sub(/^: /, "", t); sub(/^%/, "", t)                                   # Idaho ": " and Missouri "%" paragraph markers
  }
  if (bkind == "") bkind = "P"
  buf = (buf == "" ? t : buf " " t)
}

END { flush() }
