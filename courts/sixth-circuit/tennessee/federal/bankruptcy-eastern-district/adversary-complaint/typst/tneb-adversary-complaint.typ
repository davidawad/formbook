// Adversary complaint for the United States Bankruptcy Court, E.D. Tennessee (tneb).
// Rules (see ../README.md): FRBP 7001 (an adversary proceeding), 7003 and E.D. Tenn. LBR 7003-1 (Form B 1040
// cover sheet filed with the complaint; not produced here), 7008(a) (Rule 8 applies; the complaint states the
// jurisdiction and whether the pleader consents to final orders), 7010 (Rule 10 applies; the caption substantially
// conforms to Official Form 416), Fed. R. Civ. P. 10(b) (numbered paragraphs), E.D. Tenn. LBR 9004-1(a) (8 1/2 by
// 11 inches, double-spaced, paginated at the bottom from page 2), LBR 9004-2(a) (the caption identifies the division
// and the case or adversary number with the judge's initials).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // no rule names a font for this court (LBR 9004-1 is silent); Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // the usual 12-point text; the rules set no minimum for this court
#let body-leading = 1.345em             // double spacing (LBR 9004-1(a)): the line box is 0.655em, so 0.655em + 1.345em = 2em (about 24 pt)
#let single-leading = 0.495em            // single spacing for the caption, counsel and signature (about 13.8 pt)
#let single-pitch = 13.8pt
#let page-w = 8.5in                     // LBR 9004-1(a): 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                // first-line indent; the paragraph number sits at this indent
#let caption-left = 3.25in              // width of the party column; the ")" column follows
#let caption-mid = 0.3in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline text: *italic*, **bold**, and \_ or \* escapes. Everything else is literal (no typst markup is read
/// from the sample, so "$", "#" and "@" in a filing print as written).
#let inl(s) = {
  let src = s.replace("\\_", "\u{E001}").replace("\\*", "\u{E002}")
  let restore(x) = x.replace("\u{E001}", "_").replace("\u{E002}", "*")
  let out = ()
  let pos = 0
  for m in src.matches(regex("\\*\\*[^*]+\\*\\*|\\*[^*]+\\*")) {
    out.push(text(restore(src.slice(pos, m.start))))
    if m.text.starts-with("**") {
      out.push(strong(restore(m.text.slice(2, -2))))
    } else {
      out.push(emph(restore(m.text.slice(1, -1))))
    }
    pos = m.end
  }
  out.push(text(restore(src.slice(pos))))
  out.join()
}

/// One caption row: party text, a ")" in the middle column, and the case information on the right.
/// The row is a fixed single-spaced pitch, so an empty row still takes its line.
#let caption-row(r) = block(width: text-width, height: single-pitch, above: 0pt, below: 0pt,
  grid(
    columns: (caption-left, caption-mid, 1fr),
    inl(r.at("left", default: "")),
    align(center, ")"),
    inl(r.at("right", default: "")),
  ))

#let caption(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  for r in meta.caption { caption-row(r) }
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (FRBP 7010; Form 416; LBR 9004-2)
// ---------------------------------------------------------------------------

/// One centered line of the cover, as a block so that consecutive lines stack.
#let center-line(c) = block(width: text-width, height: single-pitch, align(center, c))

#let cover(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  center-line(text(weight: "bold", "IN THE " + meta.court))
  center-line(text(weight: "bold", meta.district))
  if "division" in meta {
    center-line(text(weight: "bold", upper(meta.division)))
  }
  v(single-pitch)
  caption(meta)
  v(single-pitch)
  center-line(text(weight: "bold", inl(meta.title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Blank-line-separated chunks of the markdown body.
#let chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

/// A heading: centered and bold. It stays with the paragraph after it.
#let heading(t) = block(width: text-width, sticky: true, above: body-leading, below: body-leading,
  align(center, text(weight: "bold", inl(t.replace(regex("^#+[ \t]*"), "")))))

/// Lettered prayer items: a markdown list is lettered (a), (b), ... (Rule 10(b) numbering is for allegations).
/// Items are double-spaced, so each item is followed by one body-leading line.
#let prayer(t) = {
  let items = t.split(regex("\\r?\\n")).map(l => l.trim()).filter(l => l != "")
  for (k, it) in items.enumerate() {
    let text-of = it.replace(regex("^\\d+\\.[ \\t]+"), "")
    pad(left: 0.5in, grid(
      columns: (0.4in, 1fr),
      [(#str.from-unicode(97 + k))],
      inl(text-of),
    ))
    v(body-leading)
  }
}

#let signature(sig) = block(breakable: false, width: text-width, {
  set par(leading: single-leading, spacing: single-leading, justify: false)
  if "dated" in sig {
    v(body-leading)
    block(width: text-width, { set par(leading: body-leading, spacing: body-leading); h(para-indent); inl(sig.dated) })
  }
  v(body-leading)
  let lines = ()
  if "lead" in sig { lines.push(inl(sig.lead)) }
  if "by" in sig { lines.push(inl(sig.by)) }
  for l in sig.lines { lines.push(inl(l)) }
  pad(left: 3.25in, stack(dir: ttb, spacing: single-leading, ..lines.map(l => block(width: 100%, l))))
})

/// The body: headings, numbered allegations (Rule 10(b)), an unnumbered WHEREFORE lead-in, and the
/// lettered prayer list. Paragraphs are counted in the template, never typed into the sample.
#let body-of(body) = {
  let n = 0
  for c in chunks(body) {
    if c.starts-with("#") {
      heading(c)
    } else if c.starts-with(regex("^\\d+\\.[ \\t]")) {
      prayer(c)
    } else if c.starts-with("WHEREFORE") {
      set par(leading: body-leading, spacing: body-leading)
      h(para-indent)
      inl(c)
      parbreak()
    } else {
      n += 1
      set par(leading: body-leading, spacing: body-leading)
      h(para-indent)
      [#n.]
      h(0.3in)
      inl(c)
      parbreak()
    }
  }
}

#let adversary-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    // LBR 9004-1(a): paginated consecutively at the bottom, beginning with the second page.
    footer: context {
      if counter(page).get().first() > 1 {
        align(center, text(size: type-size, counter(page).display()))
      }
    },
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  cover(meta)

  if "lead_in" in meta {
    set par(leading: body-leading, spacing: body-leading)
    h(para-indent)
    inl(meta.lead_in)
    parbreak()
  }

  body-of(body)

  if "signature" in meta { signature(meta.signature) }
}
