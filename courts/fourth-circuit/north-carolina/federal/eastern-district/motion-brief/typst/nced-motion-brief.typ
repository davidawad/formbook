// Memorandum of law supporting a motion (Fed. R. Civ. P. 12(b)) for the U.S. District Court for the Eastern
// District of North Carolina (nced). Rules: Local Civil Rule 7.1(e) and 7.2(a) (a supporting memorandum; its
// content); 7.2(f) (length: 30 pages or 8,400 words; the word-count certificate when the word limit is used);
// 10.1 (letter paper, double-spaced, at least 11-point type, one-inch margins, court and division, case number,
// caption, title with the rule relied on, attorney block, date, signature with the typed name, page numbers).
// See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; see README, "Known gaps"
#let type-size = 12pt                   // LR 10.1(a): at least 11 point
#let margin = 1in                       // LR 10.1(a): one inch on all sides
#let body-leading = 1.645em             // LR 10.1(a): double-spaced; measured on the render (README)
#let single-leading = 0.5em             // single spacing: court title, caption, signature block
#let para-indent = 0.5in                // first-line indent of text paragraphs
#let caption-left = 3.4in               // party column of the caption
#let caption-paren = 0.25in             // column of ")" marks, one per caption line
#let title-gap = 0.25in                 // space between the ")" column and the title block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nced-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, bold, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown: a "#" heading is level 1, "##" level 2, "###" level 3.
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// LR 10.1(j): every page numbered sequentially, centered at the foot of the page.
#let page-number() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: court and division (LR 10.1(b)), case number (LR 10.1(c)), caption (LR 10.1(d)), title (LR 10.1(e))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  let lines = (
    "IN THE UNITED STATES DISTRICT COURT",
    "FOR THE EASTERN DISTRICT OF NORTH CAROLINA",
    upper(meta.division) + " DIVISION",
  )
  stack(dir: ttb, spacing: single-leading, ..lines.map(l => align(center, l)))
}

#let case-number-line(meta) = {
  // LR 10.1(c): the case number is assigned by the clerk; an initial filing leaves it blank.
  let num = meta.at("case_number", default: none)
  align(center, if num == none { [No. #("_" * 14)] } else { [No. #num] })
}

/// One caption line. The line is a list entry: `"text"`, or `{t: "text", i: indent in half inches}`.
#let caption-item(x) = if type(x) == str { (t: x, i: 0) } else { (t: x.at("t", default: ""), i: x.at("i", default: 0)) }

#let caption-cell(r) = context {
  let c = [#h(r.i * 0.5in)#r.t]
  assert(measure(c).width <= caption-left, message: "nced-motion-brief: a caption line must fit on one line: " + r.t)
  c
}

/// The title block, to the right of the ")" column: the paper's title and any jury legend.
#let title-block(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  text(weight: "bold", inl(meta.brief_title))
}

#let caption(meta) = {
  let rows = meta.caption.lines.map(caption-item)
  grid(
    columns: (caption-left, caption-paren, 1fr),
    row-gutter: single-leading,
    // The title sits beside the whole caption, centered on it; the caption rows fill columns 1 and 2.
    grid.cell(x: 2, y: 0, rowspan: rows.len(), align(horizon, pad(left: title-gap, title-block(meta)))),
    ..rows.map(r => (caption-cell(r), [)])).flatten(),
  )
}

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  case-number-line(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Signature and certificates
// ---------------------------------------------------------------------------

#let line-stack(items) = stack(dir: ttb, spacing: single-leading, ..items.map(i => [#i]))

/// The attorney block (LR 10.1(f), (h), (i)): firm, the "BY: /s/" line, each signer's typed name with bar number
/// and e-mail, the address and telephone, and the party represented.
#let signature-lines(meta) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  let sig = meta.signature
  let firm = sig.at("firm", default: ())
  pad(left: 3in, {
    if firm.len() > 0 {
      line-stack(firm)
      v(single-leading)
    }
    let by = sig.at("by", default: sig.signers.at(0).name)
    line-stack((if firm.len() > 0 { "BY: /s/ " + by } else { "/s/ " + by },))
    v(single-leading)
    for s in sig.signers {
      line-stack((s.name,) + s.lines)
      v(single-leading)
    }
    line-stack(sig.at("address", default: ()))
    v(single-leading)
    line-stack(sig.at("counsel_for", default: ()))
  })
}

/// Dated signature block after the memorandum's conclusion (LR 10.1(g)).
#let signature-block(meta) = block(breakable: false, width: 100%, {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  [This the #meta.date.]
  v(body-leading)
  signature-lines(meta)
})

/// LR 7.2(f)(3): a memorandum that uses the word limit carries a certificate stating its word count.
#let word-certificate(meta) = block(breakable: false, width: 100%, {
  set par(leading: body-leading, spacing: 0pt, first-line-indent: para-indent)
  align(center, text(weight: "bold", "CERTIFICATE OF COMPLIANCE WITH WORD LIMIT"))
  v(body-leading)
  [The undersigned certifies that this memorandum complies with the word limit of Local Civil Rule 7.2(f)(3)(A) and contains #meta.word_count words, excluding the matters listed in Local Civil Rule 7.2(f)(1), as counted by the word-processing software used to prepare it.]
  v(body-leading)
  signature-lines(meta)
})

/// Certificate of service (Fed. R. Civ. P. 5(b)).
#let service-certificate(meta) = block(breakable: false, width: 100%, {
  set par(leading: body-leading, spacing: 0pt, first-line-indent: para-indent)
  align(center, text(weight: "bold", "CERTIFICATE OF SERVICE"))
  v(body-leading)
  [#meta.certificate.text]
  v(body-leading)
  pad(left: 0.5in, line-stack(meta.certificate.served))
  v(body-leading)
  [This the #meta.certificate.date.]
  v(body-leading)
  signature-lines(meta)
})

// ---------------------------------------------------------------------------
// Headings
// ---------------------------------------------------------------------------

/// Under "ARGUMENT" the points are Roman numerals (I., II.) and their sub-points lettered (A., B.); elsewhere the
/// sub-headings are lettered (A., B.) and their sub-points numbered (1., 2.). The template numbers them: the
/// sample writes the heading text alone.
#let h2-count = counter("heading-level-2")
#let h3-count = counter("heading-level-3")
#let in-argument = state("in-argument", false)

#let hanging(label, body) = grid(columns: (0.5in, 1fr), column-gutter: 0.1in, label, body)

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

#let nced-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: page-number(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set block(spacing: 0pt)
  // LR 10.1(a) "typed matter": footnotes are typed matter too.
  show footnote.entry: set text(size: type-size)

  // Level 1 is a centered section ("ARGUMENT" switches the sub-heading scheme).
  show heading.where(level: 1): it => block(sticky: true, width: 100%, above: body-leading, below: body-leading, {
    let plain = if it.body.has("text") { it.body.text } else { "" }
    in-argument.update(plain == "ARGUMENT")
    h2-count.update(0)
    h3-count.update(0)
    align(center, text(weight: "bold", upper(it.body)))
  })
  show heading.where(level: 2): it => {
    h2-count.step()
    h3-count.update(0)
    block(sticky: true, width: 100%, above: body-leading, below: body-leading, context {
      let n = h2-count.get().first()
      let label = if in-argument.get() { numbering("I.", n) } else { numbering("A.", n) }
      hanging(text(weight: "bold", label), text(weight: "bold", it.body))
    })
  }
  show heading.where(level: 3): it => {
    h3-count.step()
    block(sticky: true, width: 100%, above: body-leading, below: body-leading, context {
      let n = h3-count.get().first()
      let label = if in-argument.get() { numbering("A.", n) } else { numbering("1.", n) }
      pad(left: 0.5in, hanging(text(weight: "bold", label), text(weight: "bold", it.body)))
    })
  }

  cover(meta)

  md(body)

  v(body-leading)
  signature-block(meta)

  if "word_count" in meta {
    pagebreak(weak: true)
    word-certificate(meta)
  }
  if "certificate" in meta {
    v(body-leading)
    service-certificate(meta)
  }
}
