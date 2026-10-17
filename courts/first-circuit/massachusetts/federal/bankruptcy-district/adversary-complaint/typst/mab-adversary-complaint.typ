// Adversary complaint for the United States Bankruptcy Court, D. Massachusetts (mab).
// Rules (see ../README.md): Fed. R. Bankr. P. 7001, 7003 and MLBR 7003-1 (cover sheet, attached by the filer),
// 7008(a) (consent statement), 7010 (caption conforms to Form 416D; Fed. R. Civ. P. 10(a)), Fed. R. Civ. P. 10(b)
// (numbered paragraphs), MLBR Appendix 8 (paper, margins, double spacing, 12-point body, 10-point footnotes, numbering).
// Content-agnostic: every case word comes from the sample's frontmatter or body, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"        // Times New Roman substitute per docs/FONTS.md (fonts/); Appendix 8(c) asks for a plain roman type
#let type-size = 12pt                   // Appendix 8(c): not less than 12-point for the body
#let footnote-size = 10pt               // Appendix 8(c): not less than 10-point for footnotes
#let page-w = 8.5in                     // Appendix 8(a): 8.5 x 11-inch document format
#let page-h = 11in
#let margin = 1in                       // Appendix 8(a): at least one inch on all four sides
#let text-width = page-w - 2 * margin
#let body-leading = 1.345em             // Appendix 8(a): double-spaced; Liberation Serif's line box is 0.655em, so this is a 24 pt pitch at 12 pt
#let single-leading = 0.5em             // single spacing for the caption, counsel and signature (Appendix 8(a) exceptions)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.4in               // width of the party column of the caption
// Level-1 headings after which paragraphs are not numbered (the prayer and the certificate are not allegations).
#let unnumbered-sections = ("CERTIFICATE OF SERVICE", "SERVICE LIST")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mab-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line per item.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Cover: court (Form 416D), caption, title of the paper
// ---------------------------------------------------------------------------

#let caption(meta) = {
  align(center, text(weight: "bold", [UNITED STATES BANKRUPTCY COURT]))
  align(center, text(weight: "bold", [FOR THE DISTRICT OF MASSACHUSETTS]))
  align(center, text(weight: "bold", upper(meta.division)))
  v(body-leading)
  // Debtor (left) and case identification (right): "In re:" then the debtor, its designation.
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.2in,
    line-stack(("In re:", "") + meta.debtor_names + (meta.debtor_designation,)),
    align(top, line-stack((
      "CHAPTER " + str(meta.chapter),
      "",
      "CASE NO. " + meta.case_number,
    ))),
  )
  v(body-leading)
  // Adversary parties (left, bounded on the right and bottom) and the adversary number (right).
  grid(
    columns: (caption-left, 1fr),
    column-gutter: 0.2in,
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
      let rows = meta.plaintiffs.names + (meta.plaintiffs.designation, "", "v.", "")
      rows += meta.defendants.names + (meta.defendants.designation,)
      line-stack(rows)
    }),
    align(top + left, block(inset: (left: 0.1in), line-stack((
      if meta.adv_number == "" { "ADV. PROC. NO. ____________" } else { "Adv. Proc. No. " + meta.adv_number },
    )))),
  )
  v(body-leading)
  align(center, text(weight: "bold", inl(meta.title)))
}

// ---------------------------------------------------------------------------
// Signature: groups of lines, a half-line between groups, indented as the filed signature is (Appendix 8(a)).
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, breakable: false, {
  v(body-leading)
  pad(left: 3.1in, {
    for g in meta.signature {
      line-stack(g)
      v(single-leading * 1.5)
    }
  })
  v(body-leading * 0.5)
  line-stack(("Date: " + meta.date,))
})

// ---------------------------------------------------------------------------
// Body: numbered allegations (Fed. R. Civ. P. 10(b)); headings; tables; lists.
// Each blank-line-separated chunk of markdown is one unit: a heading, a table, a list, a paragraph,
// or a footnote definition (skipped: cmarker renders it at its reference). Numbering is applied per paragraph
// chunk, not with a show rule (a show rule that re-wraps paragraph content recurses without end in typst 0.15).
// ---------------------------------------------------------------------------

/// Render one chunk. A chunk that cites a footnote is rendered with the body's footnote definitions
/// appended, since the definitions live in other chunks (cmarker needs them in the same string).
#let md-chunk(t, defs) = cmarker.render(
  if t.contains("[^") { t + "\n\n" + defs } else { t },
  raw-typst: false, smart-punctuation: true, h1-level: 1,
)

#let allegations(body, para-counter, meta) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let defs = chunks.filter(c => c.trim().starts-with("[^")).join("\n\n")
  let out = []
  let pending = []
  let has-pending = false
  let numbered = false                  // the lead-in before the first heading is not numbered
  let signed = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("[^") { continue }
    if t.starts-with("#") {
      if t.starts-with("# ") {
        let title = upper(t.slice(2).trim())
        if title == "CERTIFICATE OF SERVICE" and not signed {
          out += signature-block(meta)
          signed = true
        }
        numbered = not (title in unnumbered-sections)
      }
      pending += md-chunk(t, defs)
      has-pending = true
    } else if t.starts-with("|") {
      // A table (the transfer schedule): kept whole, indented to the paragraph text.
      let piece = {
        set par(leading: body-leading, spacing: body-leading)
        pad(left: para-indent, md-chunk(t, defs))
        v(body-leading * 0.5)
      }
      out += if has-pending { block(breakable: false, width: text-width, { pending; piece }) } else { piece }
      pending = []
      has-pending = false
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; only a heading in front of it is kept with its first line.
      let items = {
        set par(leading: body-leading, spacing: body-leading)
        md-chunk(t, defs)
        v(body-leading)
      }
      out += if has-pending { block(breakable: false, width: text-width, { pending; items }) } else { items }
      pending = []
      has-pending = false
    } else {
      // A paragraph breaks across pages like any text. "WHEREFORE" paragraphs are the prayer: not numbered.
      let piece = if numbered and not t.starts-with("WHEREFORE") {
        {
          para-counter.step()
          set par(leading: body-leading, spacing: body-leading)
          context [#h(para-indent)#(para-counter.display()).#h(0.3in)#md-chunk(t, defs)]
        }
      } else {
        {
          set par(leading: body-leading, spacing: body-leading)
          h(para-indent)
          md-chunk(t, defs)
        }
      }
      out += if has-pending { block(breakable: false, width: text-width, { pending; piece }) } else { piece }
      pending = []
      has-pending = false
    }
  }
  if has-pending { out += pending }
  if not signed { out += signature-block(meta) }
  out
}

#let mab-adversary-complaint(meta, body) = {
  // FRBP 7008(a): the complaint must state whether the pleader does or does not consent to final orders or judgment.
  assert(body.contains("consent to the entry of final orders"),
    message: "mab-adversary-complaint: FRBP 7008(a) requires a statement of consent to the entry of final orders or judgment by the bankruptcy court")

  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    // Appendix 8(b): every page is numbered, the first need not be; page numbers sit in the margin.
    footer: context {
      if counter(page).get().first() > 1 {
        align(center, text(size: type-size, counter(page).display()))
      }
    },
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set enum(numbering: "a.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  set table(stroke: none, inset: (x: 8pt, y: 2pt), align: (left, left, right))
  show table: set text(size: type-size)

  // Headings: level 1 centered bold capitals; level 2 centered bold. Kept with the text after them.
  show heading.where(level: 1): it => block(width: text-width, above: body-leading, below: body-leading * 0.5, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, above: 0pt, below: body-leading * 0.5, sticky: true,
    align(center, text(size: type-size, weight: "bold", it.body)))

  caption(meta)
  allegations(body, para-counter, meta)
}
