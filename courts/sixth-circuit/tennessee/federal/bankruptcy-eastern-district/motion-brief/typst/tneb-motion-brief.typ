// Memorandum (brief) in support of a motion, United States Bankruptcy Court, E.D. Tennessee (tneb).
// Rules (see ../README.md): FRBP 9004(a)-(b) (legible; caption with the court, title, case number and adversary
// number, and a designation of the document), E.D. Tenn. LBR 9004-1(a) (8 1/2 by 11 inches, double-spaced except
// quoted material, paginated at the bottom from page 2), LBR 9004-2(a) (the caption identifies the division and the
// case number with the judge's initials), LBR 9013-1(b) (the motion the brief supports states its grounds and the
// relief requested; the brief is filed with it), LBR 9013-3(b) (certificate of service: the paper served, and for
// each person served the name, service address, manner and date). The proposed order and the Notice of Hearing
// legend are separate papers (LBR 9013-1(c), (f)); not produced here (see README.md).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no rule names a font for this court (LBR 9004-1 is silent); Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // the usual 12-point text; the rules set no minimum for this court
#let body-leading = 1.345em             // double spacing (LBR 9004-1(a)): the line box is 0.655em, so 0.655em + 1.345em = 2em (about 24 pt)
#let single-leading = 0.495em            // single spacing for the caption, counsel, signature and certificate (about 13.8 pt)
#let single-pitch = 13.8pt
#let page-w = 8.5in                     // LBR 9004-1(a): 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.25in              // width of the party column; the ")" column follows
#let caption-mid = 0.3in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("motion-brief: the sample must start with a YAML frontmatter block") }
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

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (FRBP 9004(b); LBR 9004-2)
// ---------------------------------------------------------------------------

/// One centered line of the cover, as a block of one single-spaced pitch so that consecutive lines stack.
#let center-line(c) = block(width: text-width, height: single-pitch, align(center, c))

#let cover(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  center-line(text(weight: "bold", "IN THE " + meta.court))
  center-line(text(weight: "bold", meta.district))
  if "division" in meta {
    center-line(text(weight: "bold", upper(meta.division)))
  }
  v(single-pitch)
  set par(leading: single-leading, spacing: 0pt, justify: false)
  for r in meta.caption { caption-row(r) }
  v(single-pitch)
  block(width: text-width, {
    set par(leading: body-leading, spacing: body-leading)
    align(center, text(weight: "bold", inl(meta.title)))
  })
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body, signature and certificate of service
// ---------------------------------------------------------------------------

/// Blank-line-separated chunks of the markdown body.
#let chunks(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

/// A first-level heading (a roman-numeral section): bold, at the left margin, kept with the text after it.
#let section-heading(t) = block(width: text-width, sticky: true, above: body-leading, below: body-leading,
  text(weight: "bold", inl(t.replace(regex("^#+[ \t]*"), ""))))

/// A second-level heading (a lettered argument): bold, indented, kept with the text after it.
#let argument-heading(t) = block(width: text-width, sticky: true, above: body-leading, below: body-leading,
  pad(left: 0.5in, text(weight: "bold", inl(t.replace(regex("^#+[ \t]*"), "")))))

#let signature(sig) = block(breakable: false, width: text-width, {
  set par(leading: single-leading, spacing: single-leading, justify: false)
  v(body-leading)
  let lines = ()
  if "lead" in sig { lines.push(inl(sig.lead)) }
  if "firm" in sig { lines.push(inl(sig.firm)) }
  if "by" in sig { lines.push(inl(sig.by)) }
  for l in sig.lines { lines.push(inl(l)) }
  pad(left: 3.25in, stack(dir: ttb, spacing: single-leading, ..lines.map(l => block(width: 100%, l))))
})

/// Certificate of service (LBR 9013-3(b)): the paper served, the persons served in a two-column grid, the signer.
#let certificate(cert) = block(breakable: false, width: text-width, {
  set par(leading: body-leading, spacing: body-leading)
  v(body-leading)
  align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
  v(body-leading)
  h(para-indent)
  inl(cert.text)
  v(body-leading)
  let cells = ()
  for served in cert.served {
    let lines = served.split("\n").map(l => inl(l))
    cells.push(stack(dir: ttb, spacing: single-leading, ..lines.map(l => block(width: 100%, l))))
  }
  set par(leading: single-leading, spacing: single-leading, justify: false)
  grid(columns: (1fr, 1fr), column-gutter: 0.3in, row-gutter: body-leading, ..cells)
  v(body-leading)
  pad(left: 3.25in, inl(cert.signer))
})

/// The body: section headings (# ), argument headings (## ), and unnumbered paragraphs with a first-line indent.
#let body-of(body) = {
  for c in chunks(body) {
    if c.starts-with("##") {
      argument-heading(c)
    } else if c.starts-with("#") {
      section-heading(c)
    } else {
      set par(leading: body-leading, spacing: body-leading)
      h(para-indent)
      inl(c)
      parbreak()
    }
  }
}

#let motion-brief(meta, body) = {
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
  if "certificate" in meta { certificate(meta.certificate) }
}
