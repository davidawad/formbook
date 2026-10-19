// Complaint for the U.S. District Court for the District of Colorado (cod).
// Rules: D.C.COLO.LCivR 10.1 (paper, margins, font, double spacing, one side); 5.1(a) (CM/ECF format);
// Fed. R. Civ. P. 8(a), 10(a) (caption), 10(b) (numbered paragraphs), 11(a) (signature), 38(b) (jury demand).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no typeface rule in 10.1(d); Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // LCivR 10.1(d): not less than 12-point font
#let page-w = 8.5in                     // LCivR 10.1(b): 8 1/2 by 11 inch white paper
#let page-h = 11in
#let margin-top = 1.5in                 // LCivR 10.1(c): 1 1/2 inches at the top
#let margin-side = 1in                  // LCivR 10.1(c): 1 inch at the left and right
#let margin-bottom = 1in                // LCivR 10.1(c): 1 inch at the bottom
#let body-leading = 1.345em             // LCivR 10.1(e): double spaced (about 24 pt baseline pitch at 12 pt, see README)
#let single-leading = 0.65em            // single spacing for the caption, counsel block, signature and block quotations
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let court-lines = (
  "IN THE UNITED STATES DISTRICT COURT",
  "FOR THE DISTRICT OF COLORADO",
)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cod-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Blank-line-separated chunks of the body: the markdown contract (README.md).
#let chunks(body) = {
  let parts = body.split(regex("\n[ \t]*\n"))
  parts.map(c => c.trim()).filter(c => c != "")
}

/// What a chunk is: heading, list, quotation, unnumbered paragraph (starts with "::") or numbered paragraph.
#let kind(c) = {
  if c.starts-with("#") { "heading" }
  else if c.starts-with(">") { "quote" }
  else if c.starts-with("~ ") { "unnumbered" }
  else if c.match(regex("^(\\d+\\.|[-*+]) ")) != none { "list" }
  else { "para" }
}

// Numbered paragraphs (Fed. R. Civ. P. 10(b)). The counter runs across headings and lists.
#let allegation = counter("allegation")

/// One numbered paragraph: the number at the first-line indent, the text after it.
#let numbered(c) = block(width: 100%, [
  #h(para-indent)#allegation.step()#context numbering("1.", ..allegation.get())#h(0.5em)#cmarker.render(c, raw-typst: false)
])

/// One unnumbered paragraph, indented like a numbered one.
#let unnumbered(c) = block(width: 100%, [
  #h(para-indent)#cmarker.render(c, raw-typst: false)
])

/// Lines of a caption or signature block, single spaced (no forced line breaks: one item per line).
#let lines(items, indent: 0pt) = stack(
  dir: ttb,
  spacing: single-leading - 0.1em,
  ..items.map(l => pad(left: indent, [#l])),
)

/// The caption (Fed. R. Civ. P. 10(a)): court, civil action number, parties, title of the paper.
#let caption(sides, case-number, title) = {
  set par(leading: single-leading, spacing: single-leading)
  align(center, lines(court-lines))
  v(body-leading)
  [Civil Action No. #if case-number != none and case-number != "" { case-number } else { "__________________" }]
  v(body-leading)
  for (i, side) in sides.enumerate() {
    if i > 0 {
      v(body-leading / 2)
      [v.]
      v(body-leading / 2)
    }
    lines(side.names)
    lines((side.designation,), indent: 0.5in)
  }
  v(body-leading)
  align(center, strong(title))
  v(body-leading)
}

/// The signature block (LCivR 5.1; Fed. R. Civ. P. 11(a)). `sig.intro` is a list of lines (the date and
/// "Respectfully submitted,"); each signer prints "s/ Name" (or `sig_line`), the name, then `lines`.
#let signature(sig) = block(width: 100%, sticky: true, {
  set par(leading: single-leading, spacing: single-leading)
  v(body-leading)
  lines(sig.intro)
  if "firm" in sig { v(single-leading); lines((sig.firm,)) }
  for s in sig.signers {
    v(body-leading)
    lines((
      if "sig_line" in s { s.sig_line } else { "s/ " + s.name },
      s.name,
    ) + s.at("lines", default: ()))
  }
  if "role" in sig { v(body-leading); lines((sig.role,)) }
})

// ---------------------------------------------------------------------------
// Page furniture and text
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

/// `meta`: the frontmatter (see README.md, markdown contract). `body`: the markdown after it.
#let cod-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    width: page-w,
    height: page-h,
    margin: (top: margin-top, bottom: margin-bottom, left: margin-side, right: margin-side),
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, fill: black, lang: "en")
  set par(justify: false, leading: body-leading, spacing: body-leading, first-line-indent: 0pt)
  set block(spacing: body-leading)
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.5em, spacing: body-leading)
  show footnote.entry: set text(size: type-size)
  show quote.where(block: true): it => pad(left: 1in, right: 1in, block(width: 100%, {
    set par(leading: single-leading, spacing: single-leading)
    text(size: type-size, it.body)
  }))
  // Headings: level 1 centered bold capitals; level 2 centered bold; level 3 bold italic, left.
  show heading.where(level: 1): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    text(size: type-size, align(center, strong(upper(it.body)))))
  show heading.where(level: 2): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    text(size: type-size, align(center, strong(it.body))))
  show heading.where(level: 3): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    text(size: type-size, strong(emph(it.body))))

  caption(meta.caption, meta.at("case_number", default: none), meta.title)

  if "lead_in" in meta { unnumbered(meta.lead_in) }

  for c in chunks(body) {
    let k = kind(c)
    if k == "heading" or k == "list" or k == "quote" {
      cmarker.render(c, raw-typst: false)
    } else if k == "unnumbered" {
      unnumbered(c.slice(2).trim())
    } else {
      numbered(c)
    }
  }

  signature(meta.signature)
}
