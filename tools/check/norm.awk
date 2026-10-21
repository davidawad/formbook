# norm.awk: the one normal form both sides of every text comparison are reduced to.
# Lower case, straight quotes, ligatures expanded, every kind of whitespace removed.
# Included with `gawk -f norm.awk -f other.awk`. Needs a UTF-8 locale (LC_ALL=C.UTF-8).

function norm1(s) {
  if (WS_RE == "") {      # invisible characters are built from code points so the file stays readable
    WS_RE = "[ \t\r\n" sprintf("%c%c%c%c%c%c%c", 160, 8201, 8202, 8239, 8288, 173, 8203) "]"
  }
  s = tolower(s)
  gsub(/[‘’‛]/, "'", s)
  gsub(/[“”]/, "\"", s)
  gsub(/ﬀ/, "ff", s); gsub(/ﬁ/, "fi", s); gsub(/ﬂ/, "fl", s); gsub(/ﬃ/, "ffi", s); gsub(/ﬄ/, "ffl", s)
  gsub(/…/, "...", s)
  gsub(WS_RE, "", s)
  if (DEHYPHEN != "") gsub("[-" sprintf("%c%c%c%c", 8208, 8209, 8211, 8212) "]", "", s)   # default checks: templates may hyphenate; a hyphen is not content
  return s
}

