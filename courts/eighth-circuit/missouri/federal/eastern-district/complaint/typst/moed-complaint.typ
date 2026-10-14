// Complaint for the U.S. District Court for the Eastern District of Missouri (moed).
// Rules: E.D. Mo. L.R. 2.01(A) (12-point or larger type, double spacing, 8 1/2 by 11 inch paper, a blank
// 2 by 2 inch area in the upper left and upper right corners of page 1, contact details under each
// signature); Fed. R. Civ. P. 8(a), 10(a), 10(b), 38(b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // L.R. 2.01(A)(1) names no typeface; EB Garamond is the vendored font in fonts/
#let type-size = 12pt                   // L.R. 2.01(A)(1): 12-point or larger
#let pitch = 24pt                       // L.R. 2.01(A)(1): double spaced; a 24 pt baseline pitch at 12 pt
#let body-leading = 1.35em              // EB Garamond's line box is 0.65em, so 0.65em + 1.35em = 2em = 24 pt
#let single-leading = 0.5em             // single spacing: caption, signature blocks, block notes
#let page-w = 8.5in                     // L.R. 2.01(A)(1): 8 1/2 by 11 inch pages
#let page-h = 11in
#let margin = 1in                       // not stated in L.R. 2.01; a 1 inch margin is the convention used here
#let text-width = page-w - 2 * margin
#let corner = 2in                       // L.R. 2.01(A)(2): blank 2 by 2 inch area, upper left and upper right, page 1
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let caption-left = 3.3in               // width of the party column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("moed-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, emphasis, typographic punctuation).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Allegations are numbered by the template, not by the sample.
#let allegation = counter("allegation")

// ---------------------------------------------------------------------------
// First page: court title (inside the 2 inch corner band), caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF MISSOURI")
  if "division" in meta { lines.push(meta.division) }
  // The title block fills the band from the top margin down to the 2 inch corner line, so the
  // caption always starts below the blank corners (L.R. 2.01(A)(2)).
  block(width: text-width, height: corner - margin, above: 0pt, below: 0pt,
    align(center, stack(dir: ttb, spacing: single-leading,
      ..lines.map(l => text(weight: "bold", l)))))
}

#let caption-parties(meta) = {
  let items = ()
  for (i, p) in meta.caption.parties.enumerate() {
    if i > 0 { items.push[v.] }
    items.push[#p.names]
    items.push(pad(left: 0.5in)[#p.designation])
  }
  stack(dir: ttb, spacing: single-leading, ..items)
}

#let caption(meta) = block(width: text-width, above: 0pt, below: 0pt, grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.3in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt),
    inset: (right: 0.15in, bottom: 0.1in), caption-parties(meta)),
  {
    let case-line = if "case_number" in meta and meta.case_number != none {
      [Case No. #meta.case_number]
    } else {
      [Case No. #line(length: 1.6in, stroke: 0.5pt)]
    }
    let legends = meta.at("legends", default: ())
    stack(dir: ttb, spacing: pitch, case-line, stack(dir: ttb, spacing: single-leading,
      ..legends.map(l => text(weight: "bold", l))))
  },
))

#let title-block(s) = block(width: text-width, above: pitch, below: body-leading, sticky: true,
  align(center, text(weight: "bold", s)))

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// A numbered allegation: the number sits at the first-line indent, the text wraps to the margin.
#let numbered(s) = {
  allegation.step()
  block(width: text-width, above: 0pt, below: body-leading,
    [#h(para-indent)#context [#allegation.display().]#h(0.25in)#inl(s)])
}

/// Unnumbered prose with a first-line indent (the lead-in paragraph).
#let prose(s) = block(width: text-width, above: 0pt, below: body-leading,
  [#h(para-indent)#inl(s)])

/// A block note (a single-spaced, unnumbered paragraph, such as an omission marker).
#let note(s) = block(width: text-width, above: body-leading, below: body-leading, {
  set par(leading: single-leading)
  inl(s)
})

#let render-heading(level, s) = {
  if level == 1 {
    block(width: text-width, above: pitch, below: body-leading, sticky: true,
      align(center, text(weight: "bold", s)))
  } else if level == 2 {
    block(width: text-width, above: 0pt, below: body-leading, sticky: true,
      align(center, text(weight: "bold", s)))
  } else {
    block(width: text-width, above: 0pt, below: body-leading, sticky: true,
      text(weight: "bold", s))
  }
}

/// A markdown list: items are lettered (a), (b), ... and wrap to a 1 inch text indent.
#let list-block(lines) = {
  let items = ()
  for l in lines {
    let m = l.match(regex("^[0-9]+\\. (.*)$"))
    if m != none { items.push(m.captures.at(0)) } else { items.at(-1) = items.at(-1) + " " + l }
  }
  block(width: text-width, above: 0pt, below: body-leading, grid(
    columns: (para-indent, 0.5in, 1fr),
    row-gutter: body-leading,
    ..items.enumerate().map(((i, t)) => ([], [#numbering("(a)", i + 1)], [#inl(t)])).flatten(),
  ))
}

#let render-body(body) = {
  let chunks = body.split(regex("\n\\s*\n")).map(c => c.trim()).filter(c => c != "")
  for c in chunks {
    if c.starts-with("### ") {
      render-heading(3, c.slice(4))
    } else if c.starts-with("## ") {
      render-heading(2, c.slice(3))
    } else if c.starts-with("# ") {
      render-heading(1, c.slice(2))
    } else if c.starts-with(">") {
      note(c.slice(1).trim())
    } else {
      let lines = c.split("\n").map(l => l.trim()).filter(l => l != "")
      if lines.at(0).match(regex("^[0-9]+\\. ")) != none {
        list-block(lines)
      } else {
        numbered(lines.join(" "))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature: date, firm blocks (L.R. 2.01(A)(1): name, address, telephone, email, bar number under each
// signature), and the party represented
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, above: pitch, below: 0pt, sticky: true, {
  set par(leading: single-leading, spacing: 0pt)
  if "date" in meta { [DATED: #meta.date] ; v(pitch) }
  pad(left: 3.25in, {
    let items = ([Respectfully submitted,],)
    for f in meta.signature {
      items.push(v(pitch * 0.5))
      items.push([#text(weight: "bold", f.firm)])
      if "signer" in f { items.push([#f.signer]) }
      for l in f.lines { items.push([#l]) }
    }
    if "attorneys_for" in meta {
      items.push(v(pitch * 0.5))
      items.push(text(style: "italic", meta.attorneys_for))
    }
    stack(dir: ttb, spacing: single-leading, ..items)
  })
})

// ---------------------------------------------------------------------------
// Page and document
// ---------------------------------------------------------------------------

#let moed-complaint(meta, body) = {
  set page(width: page-w, height: page-h, margin: margin, numbering: "1", number-align: center)
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, justify: false)

  court-title(meta)
  caption(meta)
  title-block(meta.title)
  if "lead_in" in meta { prose(meta.lead_in) }
  render-body(body)
  signature-block(meta)
}
