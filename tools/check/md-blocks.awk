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
      if (substr(s, i + 1, 1) == "*") { i += 2; continue }     # bold: no text effect
      ital = !ital; out = out (ital ? "\002" : "\003"); i++; continue
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
fm == 1 { if ($0 ~ /^---[ \t]*$/) fm = 2; next }

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
  buf = (buf == "" ? q : buf " " q)
  next
}

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
    sub(/^~ /, "", t); sub(/^\^/, "", t)
    if (t ~ /^\|/) gsub(/\|/, " ", t)
  }
  if (bkind == "") bkind = "P"
  buf = (buf == "" ? t : buf " " t)
}

END { flush() }
