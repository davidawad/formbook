// Adversary complaint, United States Bankruptcy Court for the Western District of Wisconsin (wiwb).
// Rules (see ../README.md for quotes, URLs and the verification date):
//   Fed. R. Bankr. P. 7001 (adversary proceeding), 7008(a) (jurisdiction statement and consent to
//   entry of final orders), 7010 (Fed. R. Civ. P. 10 applies; caption per Official Form 416),
//   9004(a)-(b) (legibility; caption: court, title, case and adversary numbers, designation),
//   9011 (signature block), Fed. R. Civ. P. 10(b) (numbered paragraphs).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/; no system font is used (tools/render.sh)
#let type-size = 12pt                   // convention: 12 point body text (no W.D. Wis. rule found; README.md)
#let page-w = 8.5in                     // 8 1/2 by 11 inch paper (convention; README.md)
#let page-h = 11in
#let margin-x = 1in                     // convention: 1 inch side margins
#let margin-top = 1in
#let margin-bottom = 1in
#let text-width = page-w - 2 * margin-x
#let body-leading = 1.35em              // convention: loosely double-spaced body; measured pitch in README.md
#let single-leading = 0.5em             // single-spaced caption and signature block
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.4in               // width of the party column of the caption
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF WISCONSIN")   // Fed. R. Bankr. P. 9004(b)(1)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wiwb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced stack of lines (caption, counsel, signature block).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number, centered in the footer. The ECF header is added by the court's system, not here.
#let footer() = context align(center, text(size: 11pt, counter(page).display()))

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 9004(b); Fed. R. Bankr. P. 7010, Official Form 416)
// ---------------------------------------------------------------------------

/// Court name, centered, bold, two lines.
#let court-title() = {
  align(center, line-stack(court-name.map(l => "**" + l + "**")))
  v(1.5em)
}

/// The party column: each side is its names, then its designation; "v." between the sides.
#let party-column(meta) = {
  let sides = meta.caption
  for (i, side) in sides.enumerate() {
    line-stack(side.names)
    v(single-leading)
    block(width: caption-left - 0.4in, align(right, inl(side.designation)))
    if i < sides.len() - 1 {
      v(0.8em)
      align(left, "v.")
      v(0.8em)
    }
  }
}

#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 10pt), {
    // "In re" and the debtor, then the adversary parties.
    line-stack(("In re:", meta.debtor, "Case No. " + meta.bankruptcy_case, "Chapter " + meta.chapter))
    v(1.2em)
    party-column(meta)
  }),
  align(top, {
    v(0.2em)
    text(weight: "bold", "Adversary Case No.")
    if "adversary_case" in meta and meta.adversary_case != "" {
      h(0.4em)
      meta.adversary_case
    } else {
      h(0.4em)
      box(width: 1.6in, line(length: 1.6in, stroke: 0.5pt))
    }
  }),
)

#let cover(meta) = {
  court-title()
  caption(meta)
  v(1.5em)
  align(center, text(weight: "bold", upper(meta.title)))
  v(1.5em)
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, prayer
// ---------------------------------------------------------------------------

/// Numbered paragraphs (Fed. R. Civ. P. 10(b), via Fed. R. Bankr. P. 7010). Each blank-line-separated
/// chunk of markdown that is neither a heading nor a list is one numbered paragraph; a paragraph that
/// begins with WHEREFORE is the prayer lead-in and stays unnumbered. Markdown ordered lists become (a), (b), ...
/// Numbering is applied per chunk, not with a `show par` rule (a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15).
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  for c in chunks {
    let t = c.trim()
    parbreak()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Prayer items, lettered; a list may break across pages.
      set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with("WHEREFORE") {
      h(para-indent)
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else {
      // Plain paragraph flow: lines use `leading`, paragraphs use `spacing` (set in the entry point).
      n += 1
      h(para-indent)
      [#n.#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Bankr. P. 9011): date, firm, /s/ signature, signer, bar number, address, phone
// ---------------------------------------------------------------------------

#let signature(meta) = {
  v(2 * body-leading)
  block(width: text-width, breakable: false, grid(
    columns: (1fr, 3.1in),
    align(top, if "date" in meta { inl(meta.date) } else { [] }),
    align(top, {
      if "firm" in meta.signature { text(weight: "bold", meta.signature.firm) }
      v(single-leading)
      "Respectfully submitted,"
      v(2 * body-leading)
      "/s/ " + box(width: 2.8in, line(length: 2.8in, stroke: 0.5pt))
      v(0.2em)
      line-stack((meta.signature.signer,) + meta.signature.lines)
    }),
  ))
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let wiwb-adversary-complaint(meta, body) = {
  // Fed. R. Bankr. P. 7008(a): the complaint must state whether the pleader consents to entry of final orders
  // (in force since the December 1, 2016 amendment), and must give the jurisdiction statement.
  assert(body.match(regex("(?i)consent")) != none, message: "wiwb-adversary-complaint: Fed. R. Bankr. P. 7008(a) requires a statement whether the pleader consents to entry of final orders")
  assert(body.match(regex("(?im)^# *jurisdiction")) != none, message: "wiwb-adversary-complaint: Fed. R. Bankr. P. 7008(a) requires a jurisdiction statement (a '# JURISDICTION' heading)")

  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-x, right: margin-x),
    footer: footer(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  // Paragraph gap: the line box of EB Garamond is 0.65em, so a paragraph gap of body-leading gives a 24 pt
  // baseline pitch at the start of each paragraph, the same as inside it (measured with pdftotext -bbox).
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered, bold, capitalised section heading; level 2 is bold, left.
  show heading.where(level: 1): it => block(width: text-width, above: 1.2em, below: 0.6em, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, above: 1em, below: 0.5em, sticky: true,
    text(weight: "bold", it.body))

  cover(meta)

  allegations(body)

  signature(meta)
}
