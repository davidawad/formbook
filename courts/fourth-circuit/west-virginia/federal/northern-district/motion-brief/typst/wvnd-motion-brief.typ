// Memorandum of law supporting a motion to dismiss, for the U.S. District Court for the Northern
// District of West Virginia (wvnd). Rules: LR Civ P 7.02(a) (memorandum: not more than 25 pages,
// double spaced, 8 1/2 x 11, one-inch margins on all four sides, page numbers only in the margins,
// Times New Roman, Courier New or Arial at 12 point proportional, footnotes and indented quotations
// may be single spaced, footnotes at least 11 point proportional); LR Civ P 12.02 (a motion to dismiss
// is designated prominently and filed as a separate pleading; the memorandum is its own paper);
// LR Gen P 5.03(c) (signature "s/ name"); LR Gen P 5.06(e) (certificate of service on every filing,
// stating who was served and how); Fed. R. Civ. P. 11(a) (signer's address, e-mail, telephone).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // vendored in fonts/liberation-serif (Times New Roman substitute, metric-compatible); LR Civ P 7.02(a) names Times New Roman, Courier New or Arial (README, known gaps)
#let type-size = 12pt              // LR Civ P 7.02(a): 12 point proportionally spaced type
#let note-size = 11pt              // LR Civ P 7.02(a): footnote text no smaller than 11 point proportional
#let page-w = 8.5in                // LR Civ P 7.02(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                  // LR Civ P 7.02(a): one inch on all four sides; page numbers only in the margin
#let page-limit = 25               // LR Civ P 7.02(a): a supporting memorandum of not more than 25 pages
#let body-leading = 1.345em        // double spacing: Liberation Serif's line box is 0.655em, so 1.345em leading gives a 24 pt pitch at 12 pt (measured, pdftotext -bbox)
#let single-leading = 0.5em        // single spacing for caption, notes, quotations, signature: about 13.8 pt at 12 pt
#let caption-row = 13.8pt          // one single-spaced caption line, so the ")" column lines up with the party lines
#let para-indent = 0.5in           // first-line indent of body paragraphs
#let caption-left = 3.4in          // width of the party column of the caption
#let sig-left = 3.25in             // the signature block starts at the middle of the page

// Heading counters: level 2 is I., level 3 is A., level 4 is 1. Each level restarts under the one above.
#let h2 = counter("wvnd-h2")
#let h3 = counter("wvnd-h3")
#let h4 = counter("wvnd-h4")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wvnd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, links, footnote marks). Smart punctuation keeps the author's characters.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split the body into blank-line-separated chunks.
#let chunks-of(body) = body.split("\n\n").map(c => c.trim()).filter(c => c != "")

/// Footnote definitions ("[^key]: text") are set aside and attached to the chunk that cites them,
/// because cmarker resolves a footnote only inside the markdown that contains its definition.
#let body-chunks(body) = {
  let defs = (:)
  let out = ()
  for c in chunks-of(body) {
    let m = c.match(regex("^\\[\\^([^\\]]+)\\]:"))
    if m != none { defs.insert(m.captures.at(0), c) } else { out.push(c) }
  }
  out.map(c => {
    let keys = c.matches(regex("\\[\\^([^\\]]+)\\]")).map(m => m.captures.at(0))
    let extra = keys.filter(k => k in defs).map(k => defs.at(k))
    if extra.len() > 0 { c + "\n\n" + extra.join("\n\n") } else { c }
  })
}

/// The caption (LR Civ P 7.02 does not set it; the court's papers use this court title and a ")" column).
/// Party lines are rows of one fixed height, so the ")" column always lines up with them.
#let caption(meta) = {
  align(center)[
    UNITED STATES DISTRICT COURT \
    NORTHERN DISTRICT OF WEST VIRGINIA
    #if "division" in meta [ \ #meta.division ]
  ]
  v(body-leading)
  let rows = meta.caption.lines
  let case-row = meta.caption.at("case_row", default: 0)
  let cells = ()
  for (i, item) in rows.enumerate() {
    let r = if type(item) == str { (text: item) } else { item }
    cells.push(pad(left: r.at("indent", default: 0.0) * 1in, r.text))
    cells.push(")")
    cells.push(if i == case-row { "No. " + meta.case_number } else { [] })
  }
  // every row is one single-spaced line, so the column of ")" marks lines up with the party names
  grid(
    columns: (caption-left, 0.3in, 1fr),
    rows: (caption-row,) * rows.len(),
    ..cells,
  )
  v(body-leading)
}

/// The signature block, after the conclusion (LR Gen P 5.03(c); Fed. R. Civ. P. 11(a)).
#let signature-block(meta) = {
  let sig = meta.signature
  assert(sig.lines.any(l => l.contains("@")), message: "wvnd-motion-brief: the signature lines need an e-mail address (Fed. R. Civ. P. 11(a))")
  assert(sig.lines.any(l => l.match(regex("\\(?\\d{3}\\)?[ .-]?\\d{3}[ .-]?\\d{4}")) != none), message: "wvnd-motion-brief: the signature lines need a telephone number (Fed. R. Civ. P. 11(a))")
  block(sticky: true, above: body-leading, below: 0pt, [DATED: #meta.date])
  block(sticky: true, above: body-leading, below: 0pt, pad(left: sig-left, {
    "Respectfully submitted,"
    v(body-leading)
    "s/ " + sig.signer
    v(single-leading)
    for l in sig.lines { block(below: single-leading, inl(l)) }
  }))
}

/// The certificate of service (LR Gen P 5.06(e)): on its own page, with the caption repeated.
#let certificate(meta) = {
  let c = meta.certificate_of_service
  assert("served" in c, message: "wvnd-motion-brief: the certificate needs served (who was served, LR Gen P 5.06(e))")
  pagebreak()
  caption(meta)
  [#block(width: 100%, sticky: true, above: body-leading, below: body-leading, align(center, text(weight: "bold", [CERTIFICATE OF SERVICE]))) <wvnd-cert>]
  [#h(para-indent)I hereby certify that on #c.date, I electronically filed the foregoing with the Clerk of the District Court using the CM/ECF system, which will send notification of such filing electronically to the following counsel of record, who are served by that means:]
  parbreak()
  for s in c.served {
    block(below: single-leading, pad(left: 0.5in, inl(s)))
  }
  v(body-leading)
  block(sticky: true, pad(left: sig-left, {
    "s/ " + c.signer
    v(single-leading)
    block(below: single-leading, inl(c.role))
  }))
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let wvnd-motion-brief(meta, body) = {
  assert("case_number" in meta, message: "wvnd-motion-brief: frontmatter needs case_number")
  assert("caption" in meta, message: "wvnd-motion-brief: frontmatter needs caption (lines and case_row)")
  assert("brief_title" in meta, message: "wvnd-motion-brief: frontmatter needs brief_title")
  assert("signature" in meta, message: "wvnd-motion-brief: frontmatter needs signature")
  assert("certificate_of_service" in meta, message: "wvnd-motion-brief: frontmatter needs certificate_of_service")

  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(justify: false, leading: body-leading, spacing: body-leading, first-line-indent: 0pt)
  // quotations are single spaced; footnotes are at least 11 point and single spaced (LR Civ P 7.02(a))
  show quote: set par(leading: single-leading, spacing: single-leading)
  show footnote.entry: set text(size: note-size)
  show footnote.entry: set par(leading: single-leading, spacing: single-leading)

  caption(meta)

  align(center, block(width: 100%, sticky: true, above: body-leading, below: body-leading, text(weight: "bold", meta.brief_title)))

  for c in body-chunks(body) {
    if c.starts-with("#") {
      let level = c.match(regex("^#+")).text.len()
      let t = c.replace(regex("^#+\\s*"), "")
      if level == 1 {
        h2.update(0)
        h3.update(0)
        h4.update(0)
        block(width: 100%, sticky: true, above: body-leading, below: body-leading,
          align(center, text(weight: "bold", underline(inl(t)))))
      } else if level == 2 {
        h2.step()
        h3.update(0)
        h4.update(0)
        block(width: 100%, sticky: true, above: body-leading, below: body-leading, grid(
          columns: (0.5in, 1fr),
          context [#numbering("I.", h2.get().first())],
          text(weight: "bold", inl(t)),
        ))
      } else if level == 3 {
        h3.step()
        h4.update(0)
        block(width: 100%, sticky: true, above: body-leading, below: body-leading, grid(
          columns: (0.5in, 1fr),
          context [#pad(left: 0.5in, numbering("A.", h3.get().first()))],
          text(weight: "bold", inl(t)),
        ))
      } else {
        h4.step()
        block(width: 100%, sticky: true, above: body-leading, below: body-leading, grid(
          columns: (1in, 1fr),
          context [#pad(left: 1in, numbering("1.", h4.get().first()))],
          text(style: "italic", inl(t)),
        ))
      }
    } else {
      [#h(para-indent)#inl(c)]
      parbreak()
    }
  }

  signature-block(meta)

  certificate(meta)

  // LR Civ P 7.02(a): the memorandum (everything before the certificate of service) is at most 25 pages.
  context {
    let pg = counter(page).at(query(<wvnd-cert>).first().location()).first()
    assert(pg - 1 <= page-limit, message: "wvnd-motion-brief: the memorandum runs " + str(pg - 1) + " pages; LR Civ P 7.02(a) allows " + str(page-limit) + " without leave")
  }
}
