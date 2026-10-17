// Complaint for the U.S. District Court for the Middle District of Louisiana (lamd).
// Rules: Fed. R. Civ. P. 10(a) (caption, title, file number), 10(b) (numbered paragraphs);
// M.D. La. Local Civil Rules 10(a)(1) (paper, type size, double spacing, margins, page numbers),
// 10(a)(2) (judge initials in the caption), 11(a)(3) (counsel block under the signature). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let court-name = ("UNITED STATES DISTRICT COURT", "MIDDLE DISTRICT OF LOUISIANA") // the court's name, not a case's
#let font-family = "Liberation Serif"   // LR 10(a)(1): standard typeface; Times New Roman substitute per docs/FONTS.md
#let type-size = 12pt                   // LR 10(a)(1): no smaller than standard 12-point
#let page-w = 8.5in                     // LR 10(a)(1): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LR 10(a)(1): every margin no less than one inch
#let footer-descent = 0.6in             // LR 10(a)(1): page numbers no less than 1/2 inch from the bottom edge
#let body-leading = 1.345em             // LR 10(a)(1): double spaced; Liberation Serif's 0.655em line box + 1.345em = 24 pt pitch at 12 pt (README.md)
#let single-pitch = 13.8pt              // single spacing (caption, quotations, signature): 0.655em + 0.495em at 12 pt
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let text-width = page-w - 2 * margin
#let caption-party-w = 2.7in            // width of the party column (the party names, then "VERSUS" between them)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("lamd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown inline to content (for names with *et al.*, etc.).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line per item; each line is a fixed-height block, so the caption and the
/// signature keep the single pitch whatever the text is.
#let single-lines(items, width: auto) = stack(dir: ttb, spacing: 0pt, ..items.map(i =>
  block(width: width, height: single-pitch, above: 0pt, below: 0pt, text(i))))

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number centered in the bottom margin (page-number placement: LR 10(a)(1)).
#let page-footer() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: court name, caption, title of the paper
// ---------------------------------------------------------------------------

/// LR 10(a)(2): the civil action number carries the judge and magistrate initials once allotted.
#let file-number(meta) = {
  let n = meta.civil_action_no
  if "judges" in meta { for j in meta.judges { n += "-" + j } }
  n
}

#let caption(meta) = {
  grid(
    columns: (caption-party-w, 1fr),
    single-lines(meta.caption),
    block(inset: (left: 0.3in), {
      single-lines(("CIVIL ACTION NO. " + file-number(meta),))
      if "judge" in meta and meta.judge != "" {
        v(single-pitch)
        single-lines((meta.judge,))
      }
      if "magistrate" in meta and meta.magistrate != "" {
        single-lines((meta.magistrate,))
      }
    }),
  )
}

#let cover(meta) = {
  align(center, {
    for line in court-name { text(weight: "bold", line) + linebreak() }
  })
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", upper(meta.title)))
  if "subtitle" in meta and meta.subtitle != none {
    align(center, text(meta.subtitle))
  }
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: text-width, {
  if "date" in meta.signature and meta.signature.date != "" {
    single-lines(("Dated: " + meta.signature.date,))
    v(body-leading)
  }
  // The signature block sits in the right half of the page, single spaced (LR 11(a)(3)).
  pad(left: 3.0in, single-lines(meta.signature.lines, width: text-width - 3.0in))
})

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is
/// neither a heading nor a list is one numbered paragraph, except a chunk that starts with ">":
/// that is an unnumbered paragraph (the jurisdiction statement, the prayer's lead-in).
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Items are spaced by body-leading, so each item fills whole lines; a list may break across pages.
      {
        set par(leading: body-leading)
        md(t)
        v(body-leading)
      }
    } else if t.starts-with(">") {
      // Unnumbered paragraph, flush with the numbered ones.
      set par(leading: body-leading)
      h(para-indent)
      md(t.slice(1).trim())
      parbreak()
    } else {
      para-counter.step()
      set par(leading: body-leading)
      context [#h(para-indent)#(para-counter.display()).#h(0.3in)#md(t)]
      parbreak()
    }
  }
}

#let lamd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: page-footer(),
    footer-descent: footer-descent,
  )
  set text(font: font-family, size: type-size, lang: "en")
  // Paragraph and block spacing equal the double-space pitch: a line of text is about 0.655em tall, so
  // with spacing 0 consecutive paragraphs and blocks overprint (measured; see README.md).
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set block(spacing: body-leading)

  // Headings: level 1 is a centered section; level 2 a centered bold heading (COUNT ...); level 3 bold, left.
  show heading.where(level: 1): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    text(size: type-size, weight: "bold", it.body))

  cover(meta)

  if "lead_in" in meta {
    set par(leading: body-leading)
    h(para-indent)
    md(meta.lead_in)
    parbreak()
  }

  // Body: numbered paragraphs; markdown lists become a numbered prayer (1., 2., ...) or bullets.
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.3in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.3in, spacing: body-leading)
  // The last chunk stays on the page with the signature block: a signature never starts a page alone.
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  allegations(chunks.slice(0, -1).join("\n\n", default: ""), para-counter)
  block(breakable: false, width: text-width, {
    allegations(chunks.last(), para-counter)
    v(body-leading)
    signature-block(meta)
  })
}
