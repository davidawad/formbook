# Page map for the table of contents of the motion (docx/render.sh). Input: the index written by the filter, one line per
# item: "start<TAB>marker" (the first body paragraph) and "h<TAB>n<TAB>heading text" (level 1 and 2 headings, in order).
# The page texts are read from $wd/page.N (whitespace-stripped text of page N of the first pass, np pages).
# Output: "n<TAB>body page number" for each heading (arabic, from the body's first page as 1).
# A marker or a heading that is not found is a fatal error: a silent missing page number is not acceptable.
BEGIN {
  FS = "\t"
  for (i = 1; i <= np; i++) {
    f = wd "/page." i; t = ""
    while ((getline line < f) > 0) t = t line
    close(f); pt[i] = t
  }
  cursor = 0
}
$1 == "start" {
  for (p = 1; p <= np; p++) if (index(pt[p], $2) > 0) { body = p; break }
  if (!body) { print "start marker not found" > "/dev/stderr"; exit 1 }
  cursor = body
  next
}
$1 == "h" {
  found = 0
  for (p = cursor; p <= np; p++) if (index(pt[p], $3) > 0) { found = p; break }
  if (!found) { print "heading not found: " $3 > "/dev/stderr"; exit 1 }
  cursor = found
  print $2 "\t" (found - body + 1)
}
