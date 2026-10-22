// California Court of Appeal: a motion and its supporting memorandum.
//
// Rule-driven and content-agnostic. The form follows CALCTAPP5D-FORM-001 to -007 (CRC 8.204(b)) as far as the
// exemplar and the rules show; no motion-length or motion-form limit is stated in rules.md (Motions section),
// so none is enforced here. No case-specific text, no coordinates measured off any filed document, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Schola"          // Rule 8.74(b)(1): proportionally spaced serif; Century Schoolbook is preferred (TeX Gyre Schola is its clone). Vendored in /fonts.
#let type-size = 13pt                      // Rule 8.204(b)(4), 8.74(b)(1): 13-point, footnotes included.
#let body-leading = 0.65em                 // Rule 8.74(b)(2): lines 1.5 spaced. Measured on the render (README.md).
#let single-leading = 0.12em               // headings, block quotations, footnotes, cover: single spaced.
#let side-margin = 1.5in                   // Rule 8.204(b)(6): 1-1/2 inches left and right.
#let top-margin = 1.1in                    // Rule 8.204(b)(6): at least 1 inch top and bottom. The extra 0.1 in keeps a superscript footnote mark on a first line inside the margin (DEF-FORM-002).
#let para-indent = 0.5in
#let heading-tab = 0.5in

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("calctapp1d-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Plain text of a markup string, for the document title (emphasis markers removed).
#let plain-title(s) = s.replace(regex("[*_]"), "")

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("calctapp1d-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

// ---------------------------------------------------------------------------
// Headings
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: I. / A. / 1. / a. (level 2 to 5).
#let heading-label(h) = {
  let n = counter(heading).at(h.location()).at(h.level - 1, default: 1)
  if h.level == 2 { numbering("I.", n) }
  else if h.level == 3 { numbering("A.", n) }
  else if h.level == 4 { numbering("1.", n) }
  else if h.level == 5 { numbering("a.", n) }
  else { panic("calctapp1d-motion-brief: headings deeper than level 5 are not supported") }
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)   // every heading is body size or larger
  if it.level == 1 {
    // Section headings (for example the memorandum's title): bold, capitals, centered.
    block(width: 100%, sticky: true, above: 1.2em, below: 1em,
      align(center, strong(upper(it.body))))
  } else if it.numbering == none {
    block(width: 100%, sticky: true, above: 1em, below: 0.8em, strong(it.body))
  } else {
    let ind = (it.level - 2) * heading-tab
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 1em, below: 0.8em, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, strong(lab))
      if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Cover (Rule 8.204(b)(10), 8.40; the cover is page 1 and is not printed with a number)
// ---------------------------------------------------------------------------

#let cover-body(meta, gap) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.35em, justify: false)
  set align(center)
  for l in need(meta, "court_lines") { strong(l); linebreak() }
  v(gap)
  // Caption on the left, Court of Appeal case number on the right.
  grid(columns: (4fr, 2fr), column-gutter: 0.25in,
    align(left, {
      set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.6em)
      let sides = need(meta, "caption")
      for (i, side) in sides.enumerate() {
        for name in side.names { inl(name); parbreak() }
        pad(left: 45%, inl(side.designation))
        if i < sides.len() - 1 { v(gap * 0.4); pad(left: 45%, [v.]); v(gap * 0.4) }
      }
    }),
    align(left + horizon, [Court of Appeal Case No. #need(meta, "case_number")]),
  )
  v(gap)
  // Superior court, the trial judge when the document names one, then the title of the document.
  need(meta, "trial_court")
  linebreak()
  [Case No. #need(meta, "superior_case_number")]
  linebreak()
  if "judge" in meta { inl(meta.judge) }
  v(gap * 1.6)
  strong(upper(inl(need(meta, "brief_title"))))
  v(gap * 1.6)
  // Counsel: the attorney's name, State Bar number, firm and address, and the party represented.
  align(left, pad(left: 50%, {
    set par(hanging-indent: 0pt, spacing: 0.5em)
    let groups = need(meta, "counsel")
    for g in groups {
      block(breakable: false, {
        for n in g.names { n; linebreak() }
        for l in g.at("lines", default: ()) { l; linebreak() }
      })
      v(0.5em)
    }
    emph(inl(need(meta, "counsel_for")))
  }))
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.2, 1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("calctapp1d-motion-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Signature block
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3in),
      [Dated: #need(meta, "date")],
      [
        #for l in sig.firm { l; linebreak() }
        #v(1.2em)
        s/#sig.signer \
        #sig.signer \
        #emph(inl(sig.role))
      ])
  })
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let calctapp1d-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court_lines", "case_number", "caption", "trial_court", "superior_case_number",
            "brief_title", "counsel", "counsel_for", "signature", "date") { let _ = need(meta, k) }

  // ---- document-wide settings ----
  set document(
    title: plain-title(need(meta, "brief_title")) + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set page(paper: "us-letter", margin: (x: side-margin, y: top-margin), number-align: center, footer-descent: 30%)
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: none)
  set footnote.entry(
    gap: 0.5em, clearance: 0.9em, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size)   // typst's default is 0.85em; Rule 8.204(b)(4) allows nothing under 13 pt
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    it.body
  }))
  // Typography that holds for any text: never break inside a token of adjacent parentheses
  // ("60(b)(5)"), and never between a section sign and its number.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§¶]+ \\S+"): it => box(it)
  show heading: style-heading

  // ---- cover (page 1) ----
  cover(meta)

  // ---- body: page numbers start at the cover as page 1 (Rule 8.74(a)(2)) ----
  set page(numbering: "1")
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the last paragraph is kept with it
    // (unless that last block is a heading or a footnote definition).
    let text-md = md.trim(at: end)
    let breaks = text-md.matches(regex("\n[ \t]*\n"))
    let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
    let tail = text-md.slice(cut)
    let keep = tail.len() > 0 and not tail.starts-with("#") and not tail.starts-with("[^")
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    if keep {
      render(text-md.slice(0, cut))
      block(breakable: false, { render(tail); signature-block(meta) })
    } else {
      render(text-md)
      signature-block(meta)
    }
  }
}
