// Motion to dismiss with brief in support, for the U.S. District Court for the Western District of Oklahoma (okwd).
// Rules: LCvR7.1(b) (title shows on whose behalf), LCvR7.1(d) (13-point print style including footnotes; margins at
// least one inch), LCvR7.1(e) (25-page limit for a brief, cover, signature and certificate not counted; a brief over
// 15 pages needs a table of contents and table of authorities, which this template does not generate), LCvR7.1(k)
// (motion and brief as one document when so titled), LCvR5.2(a) (double-spaced, 8 1/2 by 11), LCvR5.4 (counsel's
// contact details on the paper), Fed. R. Civ. P. 5(b)(2)(C), 7(b), 11(a), 12(b)(6). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 13pt                   // LCvR7.1(d): print style not less than 13-point, footnotes included
#let page-w = 8.5in                     // LCvR5.2(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LCvR7.1(d): minimum one inch on the top, bottom and sides
#let text-width = page-w - 2 * margin
#let body-leading = 1.345em             // LCvR5.2(a) double spacing: 0.655em line box + 1.345em = 2.0em pitch (26 pt at 13 pt)
#let single-leading = 0.495em            // single spacing for the caption, counsel, signature and certificate blocks
#let single-pitch = 15pt                // one single-spaced line at 13 pt (0.655em + 0.495em, measured in README.md)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.4in               // width of the party column of the caption
#let paren-w = 0.3in                    // the ")" column between the parties and the case number

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("okwd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line: a fixed-height block, so consecutive lines keep the single pitch whatever the font metrics.
/// An empty string is a blank single-spaced line (used for a gap inside a signature block).
#let single-line(c) = block(width: 100%, height: single-pitch, above: 0pt, below: 0pt, c)

// ---------------------------------------------------------------------------
// Caption (LCvR7.1(b): the title shows on whose behalf the paper is filed)
// ---------------------------------------------------------------------------

/// One caption row: its text, then one ")" for each single-spaced line it occupies, so the ")" column keeps pace
/// with the party names whatever their length.
#let caption-row(c) = context {
  let n = calc.max(1, calc.ceil(measure(width: caption-left, c).height / single-pitch))
  grid(
    columns: (caption-left, paren-w),
    block(width: caption-left, height: n * single-pitch, above: 0pt, below: 0pt, c),
    stack(dir: ttb, ..range(n).map(_ => block(height: single-pitch, width: paren-w, align(center, [)])))),
  )
}

#let caption(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push([v.]) }
    for name in p.names { rows.push(text(name)) }
    rows.push(pad(left: 0.5in, text(p.designation)))
  }
  grid(
    columns: (caption-left + paren-w, 1fr),
    column-gutter: 0.2in,
    stack(dir: ttb, spacing: 0pt, ..rows.map(r => caption-row(r))),
    block(inset: (left: 0.1in), {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      if meta.case_number == "" [Case No. #"____________"] else [#meta.case_number]
      if "jury_demand" in meta and meta.jury_demand {
        v(body-leading)
        text(weight: "bold", "JURY TRIAL DEMANDED")
      }
    }),
  )
}

#let cover(meta) = {
  // Two single-spaced lines: each is a fixed-height line, so the court title keeps the single pitch.
  for line in ("IN THE UNITED STATES DISTRICT COURT", "FOR THE WESTERN DISTRICT OF OKLAHOMA") {
    single-line(align(center, text(weight: "bold", line)))
  }
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", upper(meta.brief_title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Signature and certificate
// ---------------------------------------------------------------------------

/// The signature block (LCvR5.4; Fed. R. Civ. P. 11(a)): an optional list before the signer, the "/s/" line, and the
/// signer's contact lines. A "" in either list is a blank single-spaced line.
#let signature-block(meta) = block(breakable: false, width: text-width, {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  v(body-leading)
  grid(
    columns: (3.2in, 1fr),
    column-gutter: 0.2in,
    if "date" in meta [Dated: #meta.date] else [],
    {
      single-line([Respectfully submitted,])
      v(single-pitch)
      for line in meta.signature.firm { single-line(line) }
      v(single-pitch)
      single-line(meta.signature.sign)
      for line in meta.signature.lines { single-line(line) }
    },
  )
})

/// The certificate (Fed. R. Civ. P. 5(b)(2)(C)): a centered bold heading, the statement, the recipients, and the
/// signer. Kept together, so the statement never stands apart from the signature.
#let certificate-block(cert) = block(breakable: false, width: text-width, {
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  v(body-leading)
  align(center, text(weight: "bold", upper(cert.title)))
  v(body-leading)
  block(width: text-width, {
    h(para-indent)
    cmarker.render(cert.text, raw-typst: false, smart-punctuation: true, h1-level: 1)
  })
  v(body-leading)
  set par(leading: single-leading)
  grid(
    columns: (3.2in, 1fr),
    column-gutter: 0.2in,
    [],
    {
      for line in cert.recipients { single-line(line) }
      v(body-leading)
      single-line(cert.sign)
      for line in cert.lines { single-line(line) }
    },
  )
})

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Body text. Each blank-line-separated chunk of markdown is one paragraph, indented on its first line (a paragraph
/// number, where the filed brief has one, is part of the text: the sample writes it as `1\.`). A heading is kept with
/// the paragraph after it. Lists are rendered with the enum numbering set below.
/// Chunks are rendered one by one, not with a `show par` rule: a show rule that re-wraps paragraph content recurses
/// without end in typst 0.15.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^([-*+]|\\d+\\.)[ \\t]")) {
      {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
    } else {
      block(width: text-width, {
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
    }
  }
}

#let okwd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    numbering: none,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 centered bold capitals (STATEMENT OF THE CASE, CONCLUSION); level 2 bold, left, for the
  // roman-numeral argument headings; level 3 bold italic, left, for the lettered sub-headings. A heading never ends
  // a page: it is sticky to the block after it.
  show heading.where(level: 1): it => block(sticky: true, width: text-width, above: body-leading, below: body-leading,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(sticky: true, width: text-width, above: body-leading, below: body-leading,
    text(weight: "bold", it.body))
  show heading.where(level: 3): it => block(sticky: true, width: text-width, above: body-leading, below: body-leading,
    text(weight: "bold", style: "italic", it.body))

  cover(meta)

  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.3in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.3in, spacing: body-leading)
  body-chunks(body)

  signature-block(meta)
  if "certificate" in meta { certificate-block(meta.certificate) }
}
