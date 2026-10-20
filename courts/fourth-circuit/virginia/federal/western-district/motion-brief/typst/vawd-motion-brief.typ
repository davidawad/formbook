// Brief in support of a motion (Rule 12(b)) for the U.S. District Court for the Western District of Virginia.
// Rules: Fed. R. Civ. P. 7(b)(1) (a request for a court order is made by motion, stated with particularity);
// W.D. Va. Local Rule 11(a) (attorney's office address, telephone, e-mail and bar number on every motion);
// Local Rule 11(c)(1) (a motion is accompanied by a brief stating the facts and the authorities relied on).
// The local rules set no type size, margin, spacing, page limit or table-of-contents requirement for briefs:
// the values below are the convention both filed exemplars show (see ../README.md). Content-agnostic: every
// case word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to the exemplars; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no rule; Times New Roman substitute per docs/FONTS.md, vendored in fonts/. See README "Known gaps".
#let type-size = 12pt                   // no rule sets a size; 12 pt, the size of the Times used by the exemplars (docs/FONTS.md)
#let line-pitch = 27.6pt                // double spacing: baseline-to-baseline distance measured on both exemplars
#let body-leading = line-pitch - 1.15em // the text runs in a 1.15em line box (top-edge 0.9em, bottom-edge -0.25em); the gap makes the 27.6 pt pitch
#let single-pitch = 13.8pt              // one line of single-spaced text (1.15 x 12 pt, word-processor single spacing); the ")" marks are counted in these rows
#let single-leading = single-pitch - 1.15em // single spacing: the 1.15em line box plus this gap is single-pitch
#let margins = (top: 1in, bottom: 1in, left: 1in, right: 1in)
#let para-indent = 0.5in                // first line of a paragraph of text
#let caption-width = 3.3in              // width of the party block in the caption
#let footer-size = 12pt
#let footnote-size = 11pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("vawd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A frontmatter field the template cannot do without: a missing one stops the build.
#let need(meta, key) = {
  if key in meta and meta.at(key) != none { meta.at(key) } else { panic("vawd-motion-brief: the sample frontmatter needs `" + key + "`") }
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Heading labels: level 2 is "1.", level 3 is "a.", level 4 is "(i)"; level 1 (a section) is unnumbered.
#let heading-num(..n) = {
  let nums = n.pos()
  if nums.len() == 2 { str(nums.at(1)) + "." }
  else if nums.len() == 3 { numbering("a.", nums.at(2)) }
  else if nums.len() == 4 { "(" + numbering("i", nums.at(3)) + ")" }
  else { none }
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  align(center)[
    UNITED STATES DISTRICT COURT \
    WESTERN DISTRICT OF VIRGINIA \
    #upper(need(meta, "division"))
  ]
}

/// Box caption: the party block is closed by a rule at its right and bottom; the file number sits opposite.
#let caption-box(meta) = {
  let parties = need(meta, "caption").parties
  let items = ()
  for (i, p) in parties.enumerate() {
    if i > 0 { items.push(pad(left: 0.6in, [v.])) }
    for n in p.names { items.push(inl(n)) }
    items.push(pad(left: 1.5in, inl(p.designation)))
  }
  grid(
    columns: (caption-width, 1fr),
    column-gutter: 0.15in,
    block(width: caption-width, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 0.12in, bottom: 0.12in, top: 0.06in), {
      set par(leading: single-leading, first-line-indent: 0pt, justify: false)
      stack(dir: ttb, spacing: 0.9em, ..items)
    }),
    align(horizon, block(inset: (left: 0.1in), {
      set par(leading: single-leading, first-line-indent: 0pt)
      [#need(meta, "case_label") #need(meta, "case_number")]
    })),
  )
}

/// ")" caption: a column of ")" marks beside the party block. Each party line is one row of the grid; its ")"
/// column gets as many marks as the line takes up (a name can wrap), so the marks follow the text.
#let caption-parens(meta) = {
  let parties = need(meta, "caption").parties
  let rows = ()
  for (i, p) in parties.enumerate() {
    if i > 0 { rows.push(pad(left: 0.6in, [v.])) }
    for n in p.names { rows.push(inl(n)) }
    rows.push(pad(left: 1.5in, inl(p.designation)))
  }
  // Rows are sized from the measured height of the line, so the call is in a context.
  let cell-text(c) = context {
    let n = calc.max(1, calc.ceil(measure(width: caption-width, c).height / single-pitch))
    block(width: caption-width, height: n * single-pitch, c)
  }
  let cell-marks(c) = context {
    let n = calc.max(1, calc.ceil(measure(width: caption-width, c).height / single-pitch))
    stack(dir: ttb, spacing: 0pt, ..range(n).map(_ => block(height: single-pitch, width: 100%, align(center)[)])))
  }
  set par(leading: single-leading, first-line-indent: 0pt, justify: false)
  grid(columns: (caption-width, 0.4in), ..rows.map(c => (cell-text(c), cell-marks(c))).flatten())
}

#let cover(meta) = {
  court-title(meta)
  v(line-pitch)
  if need(meta, "caption").at("style", default: "box") == "parens" {
    caption-parens(meta)
    v(line-pitch * 0.5)
    [#need(meta, "case_label") #need(meta, "case_number")]
  } else {
    caption-box(meta)
  }
  v(line-pitch)
  align(center, strong(upper(inl(need(meta, "brief_title")))))
  v(line-pitch * 0.5)
}

// ---------------------------------------------------------------------------
// Signature block and certificate of service (Fed. R. Civ. P. 11(a); Local Rule 11(a))
// ---------------------------------------------------------------------------

/// The signer's block: an optional preamble (the parties, or "Respectfully submitted,"), the e-signature line, then
/// one group per counsel (names, then the firm, address, telephone, fax and e-mail lines), then the role lines.
#let signer-block(sig, preamble: true) = pad(left: 3.25in, {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  let pre = if preamble { sig.at("preamble", default: ()) } else { () }
  for l in pre { inl(l); linebreak() }
  if pre.len() > 0 { v(line-pitch) }
  inl(sig.signed_by)
  linebreak()
  for (k, g) in sig.counsel.enumerate() {
    if k > 0 { v(line-pitch) }
    for n in g.names { inl(n); linebreak() }
    for l in g.at("lines", default: ()) { inl(l); linebreak() }
  }
  let role = sig.at("role", default: ())
  if role.len() > 0 { v(line-pitch) }
  for l in role { inl(l); linebreak() }
})

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, width: 100%, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    if "date" in meta and meta.date != none {
      [Dated: #meta.date]
      v(line-pitch)
    }
    signer-block(sig)
  })
}

#let certificate(meta) = {
  if "service" in meta and meta.service != none {
    let svc = meta.service
    block(breakable: false, above: line-pitch, width: 100%, {
      align(center, strong("CERTIFICATE OF SERVICE"))
      v(line-pitch * 0.5)
      block(width: 100%, {
        set par(leading: body-leading, first-line-indent: para-indent)
        inl(svc.text)
      })
      v(line-pitch * 0.5)
      pad(left: 0.5in, {
        set par(first-line-indent: 0pt, leading: single-leading, justify: false)
        for l in svc.recipients { inl(l); linebreak() }
      })
      v(line-pitch)
      signer-block(need(meta, "signature"), preamble: false)
    })
  }
}

/// Splits the markdown body where the final section (its last level-1 heading and what follows) starts, so
/// that a short final section can be kept on one page with the signature block. Footnote definitions stay in
/// the head: a reference and its definition must be in the same render. Returns (head: str, tail: str or none).
#let final-section(md) = {
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let defs = chunks.filter(c => c.trim().starts-with("[^")).join("\n\n")
  let body-chunks = chunks.filter(c => not c.trim().starts-with("[^"))
  let last = none
  for (i, c) in body-chunks.enumerate() {
    if c.trim().starts-with("# ") { last = i }
  }
  let tail = if last == none { () } else { body-chunks.slice(last) }
  let tail-text = tail.join("\n\n")
  let keep = last != none and tail-text.len() < 1200 and not tail-text.contains("[^")
  let head = if keep { body-chunks.slice(0, last) } else { body-chunks }
  let head-text = head.join("\n\n") + if defs != "" { "\n\n" + defs } else { "" }
  (head: head-text, tail: if keep { tail-text } else { none })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let vawd-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "case_label", "division", "caption", "brief_title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set document(
    title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signed_by,
  )
  set page(
    paper: "us-letter",
    margin: margins,
    footer: context align(center, text(size: footer-size, counter(page).display())),
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    // A 1.15em line box (a word-processor single line); Liberation Serif's ascender-descender box is only 0.909em,
    // so single-spaced lines with no gap would touch.
    top-edge: 0.9em, bottom-edge: -0.25em,
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: heading-num)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  // each footnote is unbreakable, so its text is never split across a page break
  show footnote.entry: it => block(breakable: false, {
    set text(size: footnote-size)
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)
    it
  })

  // Headings: level 1 a centered caps section (no number); levels 2 to 4 numbered, hung from the left margin.
  // Kept with the paragraph after them (a heading never ends a page).
  show heading: it => context {
    if it.level == 1 {
      block(width: 100%, above: line-pitch, below: 0pt, sticky: true,
        text(size: type-size, align(center, strong(upper(it.body)))))
    } else {
      let nums = counter(heading).at(it.location()).slice(0, it.level)
      let lab = numbering(it.numbering, ..nums)
      let ind = (it.level - 2) * 0.5in
      block(width: 100%, above: line-pitch * 0.5, below: 0pt, sticky: true,
        pad(left: ind, grid(
          columns: (0.4in, 1fr),
          text(size: type-size, strong(lab)),
          text(size: type-size, strong(it.body)),
        )))
    }
  }

  // Block quotations: single-spaced, indented on both sides, a line apart from the text.
  show quote.where(block: true): it => block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5,
    inset: (left: 0.5in, right: 0.5in), {
      set par(leading: single-leading, first-line-indent: 0pt)
      it.body
    })

  cover(meta)
  let parts = final-section(md)
  cmarker.render(parts.head, raw-typst: false, smart-punctuation: true, h1-level: 1)
  if parts.tail == none {
    signature-block(meta)
  } else {
    block(breakable: false, width: 100%, {
      cmarker.render(parts.tail, raw-typst: false, smart-punctuation: true, h1-level: 1)
      signature-block(meta)
    })
  }
  certificate(meta)
}
