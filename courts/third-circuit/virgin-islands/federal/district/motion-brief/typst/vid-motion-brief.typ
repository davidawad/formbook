// Memorandum of law in support of a motion, for the District Court of the Virgin Islands (vid).
// Rules: LRCi 5.1 (double-spaced, numbered pages, 8 1/2 x 11), LRCi 7.1(c) (a motion is accompanied by a
// brief stating reasons and authorities), LRCi 7.1(d) (20-page limit, not checked here); Fed. R. Civ. P.
// 10(a) (caption) and 12(b) (the defense by motion). See ../README.md for the sources and what is not asserted.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")       // Times New Roman substitute per docs/FONTS.md, vendored in fonts/liberation-serif/
#let type-size = 12pt                  // LRCi 5.1: at least 12-point type (source caveat in README.md)
#let margin = 1in                      // LRCi 5.1: one-inch margins (source caveat in README.md)
#let body-leading = 1.345em            // double spacing: Liberation Serif's line box is 0.655em, so 1.345em leading gives a 24 pt pitch at 12 pt
#let single-leading = 0.5em            // single spacing for the caption, quotations and the signature block
#let para-indent = 0.5in               // first-line indent of body paragraphs
#let court-name = "IN THE DISTRICT COURT OF THE VIRGIN ISLANDS"   // Fed. R. Civ. P. 10(a): the court's name

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body (line endings normalised first).
#let split-frontmatter(src) = {
  let s = src.replace("\r\n", "\n")
  let m = s.match(regex("^---\n([\\s\\S]*?)\n---[ \t]*\n"))
  if m == none { panic("vid-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), s.slice(m.end))
}

/// Inline markdown (case names in *italics*).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// What a markdown chunk (text between blank lines) is.
#let chunk-kind(c) = {
  if c.starts-with("### ") { "h3" }
  else if c.starts-with("## ") { "h2" }
  else if c.starts-with("# ") { "h1" }
  else if c.starts-with("> ") { "quote" }
  else if c.match(regex("^(\\d+\\.|-|\\*) ")) != none { "list" }
  else { "para" }
}

/// Split the body into chunks. A memorandum's paragraphs are not numbered.
#let chunks-of(body) = {
  let out = ()
  for raw in body.split("\n\n") {
    let c = raw.trim()
    if c == "" { continue }
    out.push((kind: chunk-kind(c), text: c))
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

/// The caption: the parties on the left (closed by a rule on the right and bottom), the case number on
/// the right. Parties and the number label are given in the frontmatter, never typed here.
#let caption(parties, number-label, case-number) = table(
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
    #number-label #if case-number == "" { "____________" } else { case-number }
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

#let vid-motion-brief(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: "1", number-align: center)
  set text(font: font-family, size: type-size, lang: "en")
  // Leading spaces the lines inside a paragraph; spacing spaces the paragraphs. Both are the double
  // space, so a paragraph break is one full 24 pt line like every other line.
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set block(spacing: 0pt)

  court-header(meta.division)
  v(body-leading)
  caption(meta.caption, meta.at("number_label", default: "Civil Action No."), meta.at("case_number", default: ""))
  v(body-leading)
  block(width: 100%, above: body-leading, below: body-leading, align(center, strong(meta.title)))

  for it in chunks-of(body) {
    if it.kind == "para" {
      // Plain text flow, not a block: a block around the markdown output overlapped the line above it.
      h(para-indent)
      inl(it.text)
      parbreak()
    } else if it.kind == "quote" {
      block(width: 100%, inset: (left: 0.5in, right: 0.5in), above: body-leading, below: body-leading,
        {
          set par(leading: single-leading)
          inl(it.text.slice(2))
        })
    } else if it.kind == "list" {
      // A list sticks to what follows, so a closing list never stands alone at the foot of a page.
      block(width: 100%, above: body-leading, sticky: true, inl(it.text))
    } else {
      heading-block(it)
    }
  }

  signature-block(meta.signature)

  // The certificate of service (frontmatter `certificate`: title, text, signer), after the signature as filed.
  if "certificate" in meta {
    block(width: 100%, above: body-leading, below: body-leading, sticky: true,
      align(center, strong(meta.certificate.title)))
    h(para-indent)
    inl(meta.certificate.text)
    parbreak()
    block(width: 100%, breakable: false, align(right, [/s/ #meta.certificate.signer]))
  }
}
