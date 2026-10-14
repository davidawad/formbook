// Complaint for the District Court of the Virgin Islands (vid).
// Rules: LRCi 5.1 (double-spaced, numbered pages, 8 1/2 x 11), LRCi 7.1(d) (page limit, not checked here);
// Fed. R. Civ. P. 10(a) (caption: court, title, file number, Rule 7(a) designation) and 10(b) (numbered
// paragraphs). See ../README.md for the sources and what is not asserted.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"       // vendored in fonts/eb-garamond/; the only font a render can use
#let type-size = 12pt                  // LRCi 5.1: at least 12-point type (source caveat in README.md)
#let margin = 1in                      // LRCi 5.1: one-inch margins (source caveat in README.md)
#let body-leading = 1.35em             // double spacing: EB Garamond's line box is 0.65em, so 1.35em leading gives a 24 pt pitch at 12 pt
#let single-leading = 0.5em            // single spacing for the caption, quotations and the signature block
#let para-indent = 0.5in               // first-line indent of numbered paragraphs
#let court-name = "IN THE DISTRICT COURT OF THE VIRGIN ISLANDS"   // Fed. R. Civ. P. 10(a): the court's name

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body (line endings normalised first).
#let split-frontmatter(src) = {
  let s = src.replace("\r\n", "\n")
  let m = s.match(regex("^---\n([\\s\\S]*?)\n---[ \t]*\n"))
  if m == none { panic("vid-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), s.slice(m.end))
}

/// Inline markdown (case names in *italics*, footnote-free text).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// What a markdown chunk (text between blank lines) is.
#let chunk-kind(c) = {
  if c.starts-with("### ") { "h3" }
  else if c.starts-with("## ") { "h2" }
  else if c.starts-with("# ") { "h1" }
  else if c.starts-with("> ") { "quote" }
  else if c.starts-with("~ ") { "plain" }
  else if c.match(regex("^(\\d+\\.|-|\\*) ")) != none { "list" }
  else { "para" }
}

/// Split the body into chunks and number the paragraphs (Fed. R. Civ. P. 10(b)).
/// Headings, quotations and lists are not numbered; the author never types the numbers.
#let chunks-of(body) = {
  let n = 0
  let out = ()
  for raw in body.split("\n\n") {
    let c = raw.trim()
    if c == "" { continue }
    let k = chunk-kind(c)
    if k == "para" {
      n += 1
      out.push((kind: k, n: n, text: c))
    } else {
      out.push((kind: k, n: none, text: c))
    }
  }
  out
}

// ---------------------------------------------------------------------------
// Blocks
// ---------------------------------------------------------------------------

/// The court's name and division, centered at the top of the first page.
#let court-header(division) = block(width: 100%, align(center)[
  #strong[#court-name] \
  DIVISION OF #upper(division)
])

/// The caption: the parties on the left (closed by a rule on the right and bottom), the civil action
/// number on the right. Parties are given in the frontmatter, never typed here.
#let caption(parties, case-number) = table(
  columns: (3.5in, 1fr),
  stroke: none,
  inset: 0pt,
  align: top,
  block(width: 100%, inset: (right: 0.2in, bottom: 0.12in),
    stroke: (right: 0.75pt + black, bottom: 0.75pt + black), {
    set par(leading: single-leading, spacing: 0pt)
    for (i, p) in parties.enumerate() {
      for name in p.names { [#name #linebreak()] }
      v(0.4em)
      h(1.2in)
      [#p.designation]
      if i < parties.len() - 1 {
        v(0.6em)
        align(center)[v.]
        v(0.6em)
      }
    }
  }),
  block(inset: (left: 0.3in), [
    Civil Action No. #if case-number == "" { "____________" } else { case-number }
  ]),
)

/// Section heading (markdown `#`, `##`, `###`): one block, kept with the text after it.
#let heading-block(c) = {
  if c.kind == "h1" {
    block(width: 100%, above: body-leading, below: body-leading, sticky: true,
      align(center, strong(inl(c.text.slice(2)))))
  } else if c.kind == "h2" {
    block(width: 100%, above: body-leading, below: body-leading, sticky: true,
      strong(inl(c.text.slice(3))))
  } else {
    block(width: 100%, above: body-leading, below: body-leading, sticky: true,
      emph(strong(inl(c.text.slice(4)))))
  }
}

/// Signature block: date at left; counsel's signature and block at right, single-spaced.
#let signature-block(sig) = block(width: 100%, above: body-leading, breakable: false, {
  set par(leading: single-leading, spacing: 0pt)
  grid(
    columns: (1fr, 3.1in),
    [Dated: #sig.at("date", default: "")],
    [
      #for l in sig.at("preamble", default: ()) [#l #linebreak()]
      #v(0.6em)
      /s/ #sig.signer #linebreak()
      #for l in sig.at("lines", default: ()) [#l #linebreak()]
    ],
  )
})

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let vid-complaint(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: "1", number-align: center)
  set text(font: font-family, size: type-size, lang: "en")
  // Leading spaces the lines inside a paragraph; spacing spaces the paragraphs. Both are the double
  // space, so a paragraph break is one full 24 pt line like every other line.
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set block(spacing: 0pt)

  court-header(meta.division)
  v(body-leading)
  caption(meta.caption, meta.at("case_number", default: ""))
  v(body-leading)
  block(width: 100%, above: body-leading, below: body-leading, align(center, strong(meta.title)))

  // The unnumbered opening paragraph (frontmatter `lead_in`), if the pleading has one.
  if "lead_in" in meta {
    h(para-indent)
    inl(meta.lead_in)
    parbreak()
  }

  for it in chunks-of(body) {
    if it.kind == "para" {
      // Plain text flow, not a block: a block around the markdown output overlapped the line above it.
      h(para-indent)
      [#(str(it.n) + ".") #h(0.1in) #inl(it.text)]
      parbreak()
    } else if it.kind == "plain" {
      // Unnumbered paragraph (the author writes it with a leading "~ "): e.g. the WHEREFORE clause.
      h(para-indent)
      inl(it.text.slice(2))
      parbreak()
    } else if it.kind == "quote" {
      block(width: 100%, inset: (left: 0.5in, right: 0.5in), above: body-leading, below: body-leading,
        {
          set par(leading: single-leading)
          inl(it.text.slice(2))
        })
    } else if it.kind == "list" {
      // A list (the prayer) sticks to the signature block, so a signature never stands alone on a page.
      block(width: 100%, above: body-leading, sticky: true, inl(it.text))
    } else {
      heading-block(it)
    }
  }

  signature-block(meta.signature)
}
