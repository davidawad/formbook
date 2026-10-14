// Memorandum in support of a motion for the U.S. District Court for the Middle District of Louisiana (lamd).
// Rules: M.D. La. Local Civil Rules 7(d) (a contested motion is accompanied by a separate memorandum),
// 7(g) (memoranda limited to 25 pages excluding attachments; a table of contents and table of authorities
// are excluded from the count; the signature block may extend beyond the limit; the form complies with
// LR 10(a)); 10(a)(1) (paper, type size, double spacing, margins, page numbers); 10(a)(2) (judge initials in
// the caption); 11(a)(3) (counsel block under the signature). Fed. R. Civ. P. 12(b)(6) is the motion's basis.
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let court-name = ("UNITED STATES DISTRICT COURT", "MIDDLE DISTRICT OF LOUISIANA") // the court's name, not a case's
#let font-family = "EB Garamond"        // LR 10(a)(1): standard typeface; the only serif vendored in fonts/
#let type-size = 12pt                   // LR 10(a)(1): no smaller than standard 12-point
#let page-w = 8.5in                     // LR 10(a)(1): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LR 10(a)(1): every margin no less than one inch
#let footer-descent = 0.6in             // LR 10(a)(1): page numbers no less than 1/2 inch from the bottom edge
#let body-leading = 1.35em              // LR 10(a)(1): double spaced; EB Garamond's 0.65em line box + 1.35em = 24 pt pitch at 12 pt (README.md)
#let single-pitch = 13.8pt              // single spacing (caption, quotations, signature): 0.65em + 0.5em at 12 pt
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let quote-indent = 1in                 // block quotation indent, both sides
#let single-leading-quote = 0.5em       // single spacing for block quotations: the single pitch minus the 0.65em line box
#let signature-indent = 2.5in           // the signature column starts at mid-page, as in the filed exemplars
#let text-width = page-w - 2 * margin
#let caption-party-w = 2.7in            // width of the party column (the party names, then "VERSUS" between them)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("lamd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Markdown inline to content (for case names in italics, etc.).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// One single-spaced line per item; each line is a fixed-height block, so the caption and the
/// signature keep the single pitch whatever the text is.
#let single-lines(items, width: auto) = stack(dir: ttb, spacing: 0pt, ..items.map(i =>
  block(width: width, height: single-pitch, above: 0pt, below: 0pt, text(i))))

/// The markdown line that marks where the signature block goes (after the conclusion, before the certificate).
#let signature-marker = "[[signature]]"

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

#let caption(meta) = grid(
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

#let cover(meta) = {
  align(center, {
    for line in court-name { text(weight: "bold", line) + linebreak() }
  })
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", upper(meta.title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Counsel block under the signature (LR 11(a)(3)): right part of the page, single spaced. Wide enough
/// for the longest firm name on one line (single lines are fixed-height, so they cannot wrap).
#let signature-block(meta) = block(breakable: false, width: text-width, {
  pad(left: signature-indent, single-lines(meta.signature_lines, width: text-width - signature-indent))
  v(body-leading)
})

/// Body paragraphs. Each blank-line-separated chunk of markdown is one paragraph (first-line indent,
/// double spaced), except: a heading (`#`, `##`, `###`), a list, or a chunk that starts with ">", which is a
/// single-spaced block quotation indented on both sides.
/// Paragraphs are handled per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let paragraphs(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      md(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lists are not used by this memorandum's body; rendered flush, double spaced, as written.
      {
        set par(leading: body-leading)
        md(t)
        v(body-leading)
      }
    } else if t.starts-with(">") {
      pad(left: quote-indent, right: quote-indent, {
        set par(leading: single-leading-quote)
        md(t.slice(1).trim())
      })
      v(body-leading)
    } else if t.starts-with("/s/") {
      // An electronic signature line (LR 11(a)(2)) sits in the signature column, flush, not indented.
      pad(left: signature-indent, {
        set par(leading: single-leading-quote)
        md(t)
      })
      v(body-leading)
    } else {
      set par(leading: body-leading)
      h(para-indent)
      md(t)
      parbreak()
    }
  }
}

#let lamd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer: page-footer(),
    footer-descent: footer-descent,
  )
  set text(font: font-family, size: type-size, lang: "en")
  // Paragraph and block spacing equal the double-space pitch: a line of text is about 0.65em tall, so
  // with spacing 0 consecutive paragraphs and blocks overprint (measured; see README.md).
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set block(spacing: body-leading)

  // Headings: level 1 is a centered bold section (INTRODUCTION, CONCLUSION); level 2 a bold heading at the
  // left margin (I. ..., II. ...); level 3 a bold sub-heading at the left margin (A. ...).
  show heading.where(level: 1): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => block(width: 100%, sticky: true, above: body-leading, below: body-leading,
    pad(left: 0.5in, text(size: type-size, weight: "bold", it.body)))

  cover(meta)

  // The signature marker splits the body: everything after it (the certificate) follows the signature block.
  let parts = body.split(signature-marker)
  let before = parts.at(0)
  let after = parts.slice(1).join("", default: "")

  // The last paragraph before the signature stays on the page with it: a signature never starts a page alone.
  let chunks = before.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  paragraphs(chunks.slice(0, -1).join("\n\n", default: ""))
  block(breakable: false, width: text-width, {
    paragraphs(chunks.last())
    signature-block(meta)
  })
  paragraphs(after)
}
