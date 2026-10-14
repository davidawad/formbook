// Memorandum of law in support of a motion for the United States District Court for the Northern District
// of New York (nynd). Rules: N.D.N.Y. L.R. 7.1(b)(1) (memorandum of law: 25 pages, double-spaced, unless
// leave; table of contents; numbered pages; the rule or statute the motion is based on), 10.1(a) (form:
// 12-point type, one-inch margins, double-spaced body, consecutive pages), 10.1(c)(1) (caption), 10.1(c)(2)
// (filer identification). See ../README.md. Content-agnostic: case words come from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"     // L.R. 10.1 names no typeface; EB Garamond is the one vendored in fonts/
#let type-size = 12pt                // L.R. 10.1(a)(1): at least 12-point type, text and footnotes
#let margin = 1in                    // L.R. 10.1(a)(2): one-inch margins on all four sides
#let body-leading = 1.35em           // L.R. 10.1(a)(3): double-spaced body; 24 pt baseline pitch at 12 pt (as in the cand template)
#let single-leading = 0.5em          // L.R. 10.1(a)(4): block quotations, footnotes, caption, cover and signature are single-spaced
#let pitch = 24pt                    // one double-spaced line: the unit of vertical space between blocks
#let para-indent = 0.5in             // first-line indent of body paragraphs
#let caption-left = 3.6in            // width of the party column in the caption
#let page-w = 8.5in
#let text-width = page-w - 2 * margin
#let max-pages = 25                  // L.R. 7.1(b)(1): a memorandum of law may not exceed 25 pages, double-spaced, unless leave

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nynd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for case names, section signs, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Vertical space of a given height that is a block (so it never merges into a paragraph).
#let gap(h) = block(width: 100%, height: h, above: 0pt, below: 0pt)

// ---------------------------------------------------------------------------
// Cover and caption (L.R. 10.1(c)(1))
// ---------------------------------------------------------------------------

/// The party names, with "-against-" (or "v.") between parties and each designation under its names.
#let parties-block(caption) = stack(dir: ttb, spacing: 0pt,
  ..caption.parties.enumerate().map(((k, p)) => {
    let names = stack(dir: ttb, spacing: single-leading, ..p.names.map(n => inl(n)))
    let party = stack(dir: ttb, spacing: single-leading, names, pad(left: 2in, inl(p.designation)))
    if k == 0 {
      party
    } else {
      stack(dir: ttb, spacing: 0pt, gap(pitch * 0.5), pad(left: 0.5in, inl(caption.between)), gap(pitch * 0.5), party)
    }
  }),
)

#let caption(meta) = {
  assert(meta.at("judges", default: "") != "",
    message: "nynd-motion-brief: L.R. 10.1(c)(1) requires the assigned judge's initials in the caption (frontmatter: judges)")
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading,
    [UNITED STATES DISTRICT COURT],
    [NORTHERN DISTRICT OF NEW YORK],
  )
  gap(pitch)
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.3in,
    block(width: caption-left, stroke: (top: 0.75pt, bottom: 0.75pt), inset: (top: 10pt, bottom: 10pt), parties-block(meta.caption)),
    block(inset: (left: 0.1in, top: 10pt), [Case No. #meta.case_number (#meta.judges)]),
  )
}

// ---------------------------------------------------------------------------
// Signature and firm block (L.R. 10.1(c)(2): signature, typed name, bar roll number, office address,
// telephone, e-mail)
// ---------------------------------------------------------------------------
#let firm-block(sig, role, left: 0in) = {
  for s in sig.signers {
    assert(s.at("bar_roll", default: "") != "",
      message: "nynd-motion-brief: L.R. 10.1(c)(2) requires the bar roll number of each signing attorney (frontmatter: signature.signers[].bar_roll)")
  }
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  pad(left: left, stack(dir: ttb, spacing: single-leading,
    text(weight: "bold", upper(sig.firm)),
    ..sig.signers.map(s => stack(dir: ttb, spacing: single-leading,
      inl(s.name),
      inl(s.bar_roll),
      inl(s.email),
    )),
    ..sig.address.map(a => inl(a)),
    inl(sig.phone),
    text(style: "italic", inl(role)),
  ))
}

/// The cover: caption, the title of the paper at the middle of the page, and the filing firm at the foot.
#let cover(meta) = {
  caption(meta)
  v(1fr)
  align(center, text(weight: "bold", upper(meta.brief_title)))
  v(1fr)
  firm-block(meta.signature, meta.counsel_role, left: 3.25in)
}
/// The signature block after the conclusion: the date at the left; the firm, the signature line and the
/// signing attorneys at the right (L.R. 10.1(c)(2)).
#let signature-block(sig, role) = block(width: 100%, above: pitch, below: 0pt, breakable: false, grid(
  columns: (1fr, 3.25in),
  column-gutter: 0.2in,
  [Dated: #sig.dated],
  {
    set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
    stack(dir: ttb, spacing: single-leading,
      text(weight: "bold", upper(sig.firm)),
      gap(pitch),
      [By: #box(width: 2.6in, line(length: 100%, stroke: 0.5pt))],
      ..sig.signers.map(s => stack(dir: ttb, spacing: single-leading,
        inl(s.name),
        inl(s.bar_roll),
        inl(s.email),
      )),
      gap(single-leading),
      ..sig.address.map(a => inl(a)),
      inl(sig.phone),
      text(style: "italic", inl(role)),
    )
  },
))

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, quotations, lists
// ---------------------------------------------------------------------------

/// A heading occupies whole double-spaced lines (a multiple of `pitch`), so the text after it stays on the grid.
#let heading-box(c, align-fn) = block(width: 100%, above: body-leading, below: 0pt, sticky: true, context {
  let c2 = { set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt); par(c) }
  // The trailing leading is measured too: a heading of n lines fills n pitches, as a paragraph of n lines does.
  let h = measure(width: text-width, [#c2#v(body-leading)]).height
  block(width: 100%, height: calc.max(1, calc.ceil(h / pitch - 0.01)) * pitch, align-fn(c2))
})

// ---------------------------------------------------------------------------
// Table of contents (L.R. 7.1(b)(1): a table of contents with numbered pages), generated from the headings
// ---------------------------------------------------------------------------
#let toc() = {
  align(center, text(weight: "bold", "TABLE OF CONTENTS"))
  gap(pitch)
  set par(leading: single-leading, spacing: 0pt)
  outline(title: none, depth: 3, indent: n => 0.5in * (n - 1))
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------
#let nynd-motion-brief(meta, body) = {
  assert("motion_basis" in meta and meta.motion_basis != "",
    message: "nynd-motion-brief: L.R. 7.1(b)(1) requires the moving party to specify the rule or statute the motion is based on (frontmatter: motion_basis)")
  set text(font: font-family, size: type-size, lang: "en")
  // Body paragraphs: double-spaced, first line indented, one leading between paragraphs (so the text stays on the grid).
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt), gap: 0.5em)
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading)
  show quote.where(block: true): it => block(width: 100%, inset: (left: 1in, right: 1in), above: pitch * 0.5, below: body-leading, {
    set par(leading: single-leading, first-line-indent: 0pt)
    it.body
  })
  set list(indent: 0.5in, body-indent: 0.5in, spacing: body-leading)
  set enum(indent: 0.5in, body-indent: 0.5in, spacing: body-leading)
  show list: set par(first-line-indent: 0pt)
  show enum: set par(first-line-indent: 0pt)

  // Headings: level 1 is a centered section in capitals (a POINT heading may run to two lines);
  // level 2 a centered bold heading; level 3 a bold left subheading.
  show heading.where(level: 1): it => heading-box(text(weight: "bold", upper(it.body)), c => align(center, c))
  show heading.where(level: 2): it => heading-box(text(weight: "bold", it.body), c => align(center, c))
  show heading.where(level: 3): it => heading-box(text(weight: "bold", it.body), c => c)

  // Page 1: the cover (no page number).
  set page(paper: "us-letter", margin: margin, numbering: none)
  cover(meta)
  pagebreak()

  // Front matter: the table of contents, numbered i, ii, ...
  set page(numbering: "i")
  counter(page).update(1)
  toc()
  pagebreak()

  // Body: numbered 1, 2, ... from the first page of text (the preliminary statement). The check at the end
  // reads the body page count from this counter.
  set page(numbering: "1")
  counter(page).update(1)
  // The body is one markdown document, so footnote references and their definitions resolve together.
  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)

  signature-block(meta.signature, meta.counsel_role)

  // L.R. 7.1(b)(1): the body (from the first numbered page to the end, signature included) may not exceed 25
  // pages, double-spaced, unless the judge granted leave (frontmatter: leave.pages).
  context {
    let limit = if "leave" in meta { meta.leave.pages } else { max-pages }
    let n = counter(page).final().first()
    assert(n <= limit,
      message: "nynd-motion-brief: the memorandum body is " + str(n) + " pages; L.R. 7.1(b)(1) allows " + str(limit) + " without leave (frontmatter: leave.pages)")
  }
}
