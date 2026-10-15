# Reads the index written by motion-brief.lua (kind TAB id TAB search text) and the page texts $wd/page.N (whitespace
# stripped, the page's body crop, pass 1). Prints "id TAB page" for each heading on stdout.
#   start : the body starts on the first page holding the first body paragraph (the search text);
#   h     : a heading: the first page at or after the body's first page, in order, holding its search text.
# A search text that is not found is a fatal error (a silent wrong page number is not acceptable).
BEGIN { FS = "\t"; cursor = 0 }
function text_of(p,    cmd, t, line) {
  if (!(p in pagetext)) {
    cmd = "cat " wd "/page." p " 2>/dev/null"; t = ""
    while ((cmd | getline line) > 0) t = t line
    close(cmd); pagetext[p] = t
  }
  return pagetext[p]
}
{
  kind = $1; id = $2; s = $3
  if (kind == "start") {
    if (s == "") { print "body start text is empty" > "/dev/stderr"; exit 1 }
    for (p = 1; p <= np; p++) if (index(text_of(p), s) > 0) { body = p; break }
    if (!body) { print "body start not found: " s > "/dev/stderr"; exit 1 }
    cursor = body
    next
  }
  if (kind == "h") {
    found = 0
    for (p = cursor; p <= np; p++) if (index(text_of(p), s) > 0) { found = p; break }
    if (!found) { print "heading not found: " s > "/dev/stderr"; exit 1 }
    cursor = found
    print id "\t" found
    next
  }
}
