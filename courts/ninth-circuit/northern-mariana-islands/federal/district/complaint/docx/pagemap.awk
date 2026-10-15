# Reads the index written by the filter (kind TAB id TAB search) and the page text files $wd/page.N
# (whitespace-stripped text of pass-1 page N). Prints the page map (kind TAB id TAB pages) on stdout.
#   start : the page where the body starts is the first page holding the marker text (search)
#   h     : a heading: the first page at or after the body start that holds the search text (in order)
#   t     : a table-of-authorities link: every page at or after the body start holding its search text
# A search text that is not found is a fatal error (a silent missing page is not acceptable).
BEGIN { FS = "\t"; cursor = 1 }
function holds(p, s) { return index(pagetext[p], s) > 0 }
{
  for (i = 1; i <= np; i++) if (!(i in pagetext)) {
    cmd = "cat " wd "/page." i " 2>/dev/null"; t = ""
    while ((cmd | getline line) > 0) t = t line
    close(cmd); pagetext[i] = t
  }
}
{
  kind = $1; id = $2; s = $3
  if (kind == "start") {
    for (p = 1; p <= np; p++) if (holds(p, s)) { body = p; break }
    if (!body) { print "start marker not found" > "/dev/stderr"; exit 1 }
    cursor = body
    next
  }
  if (kind == "h") {
    found = 0
    for (p = cursor; p <= np; p++) if (holds(p, s)) { found = p; break }
    if (!found) { print "heading not found: " s > "/dev/stderr"; exit 1 }
    cursor = found
    if (!firsth) { firsth = 1; if (found > body) body = found }
    print "h\t" id "\t" found
    next
  }
  if (kind == "t") {
    found = 0
    for (p = body; p <= np; p++) if (holds(p, s)) { found = 1; if ((id SUBSEP p) in seen) continue; seen[id SUBSEP p] = 1; pages[id] = pages[id] (pages[id] == "" ? "" : ",") p }
    if (!found) { print "authority text not found: " id ": " s > "/dev/stderr"; exit 1 }
    next
  }
}
END {
  for (id in pages) print "t\t" id "\t" pages[id]
}
