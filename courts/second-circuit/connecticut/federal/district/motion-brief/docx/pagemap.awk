# Reads the index written by motion-brief.lua (kind TAB id TAB search) and the page text files $wd/page.N of the
# first pass (lower case, whitespace removed). Prints the page map with PRINTED page numbers (body pages from 1):
#   h TAB seq TAB page       a heading (the first page at or after the previous heading that holds its search text)
#   t TAB key TAB pages      a table-of-authorities entry (every body page holding its search text)
# The body starts on the first page holding the body's first words (start). A search text that is not found is a
# fatal error: a silent missing page is not acceptable.
BEGIN { FS = "\t"; cursor = 0; body = 0 }
function holds(p, s) { return index(pagetext[p], s) > 0 }
{
  for (i = 1; i <= np; i++) if (!(i in pagetext)) {
    cmd = "cat " wd "/page." i " 2>/dev/null"; t = ""
    while ((cmd | getline line) > 0) t = t line
    close(cmd); pagetext[i] = t
  }
}
{
  kind = $1; id = $2; s = tolower($3)
  if (kind == "start") {
    for (p = 1; p <= np; p++) if (holds(p, s)) { body = p; break }
    if (!body) { print "body start not found" > "/dev/stderr"; exit 1 }
    cursor = body
    next
  }
  if (kind == "h") {
    found = 0
    for (p = cursor; p <= np; p++) if (holds(p, s)) { found = p; break }
    if (!found) { print "heading not found: " s > "/dev/stderr"; exit 1 }
    cursor = found
    print "h\t" id "\t" (found - body + 1)
    next
  }
  if (kind == "t") {
    found = 0
    for (p = body; p <= np; p++) if (holds(p, s)) {
      found = 1
      if ((id SUBSEP p) in seen) continue
      seen[id SUBSEP p] = 1
      pages[id] = pages[id] (pages[id] == "" ? "" : ",") (p - body + 1)
    }
    if (!found) { print "authority text not found: " id ": " s > "/dev/stderr"; exit 1 }
    next
  }
}
END {
  for (id in pages) print "t\t" id "\t" pages[id]
}
