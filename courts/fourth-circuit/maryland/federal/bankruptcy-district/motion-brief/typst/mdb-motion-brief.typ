// Memorandum of fact and law in support of a motion, for the United States Bankruptcy Court for the District
// of Maryland (mdb). Rules: Local Bankruptcy Rule 9013-2 (a brief memorandum of fact and law with each motion),
// 9013-1(a) (caption with the court, case name and number, chapter if any, a descriptive title, and in an
// adversary the plaintiff and defendant); Fed. R. Bankr. P. 9004(a)-(b) (legibility, caption); Local Rule
// 9004-1 (1-inch margins, 12-point text). See ../README.md. Content-agnostic: every case word comes from the
// sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"         // Times New Roman substitute per docs/FONTS.md, vendored in fonts/ (see README: Times New Roman in the exemplar)
#let type-size = 12pt                    // Local Rule 9004-1: 12 point or larger for text (footer too: no footnotes)
#let page-margin = 1in                   // Local Rule 9004-1: at least one inch on each side
#let page-w = 8.5in
#let page-h = 11in
#let text-width = page-w - 2 * page-margin
#let body-leading = 1.345em              // double spacing: with the 0.655em line box, a 24 pt pitch at 12 pt (the exemplar)
#let pitch = 24pt                        // the double-spaced line pitch every block is rounded up to
#let single-leading = 0.5em              // single spacing for the caption, the block quotations and the signature
#let single-pitch = 14pt                 // 0.655em line box + 0.5em leading (13.9 pt), rounded
#let para-indent = 0.5in
#let caption-left = 4.0in                // the party column, with its ")" column
#let caption-right = text-width - caption-left

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mdb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline and block markdown.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Fill whole lines: the block is rounded up to a multiple of `step`, so whatever follows it stays on the
/// line grid. Typst does not count the trailing leading of a paragraph in its height, so without this the
/// next block overprints the last line of the one before (found on the complaint's first render).
#let on-grid(c, step: pitch) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / step) * step, above: 0pt, below: 0pt, c)
}

/// One single-spaced line per item, each on a fixed single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: 0pt, ..items.map(i => block(width: 100%, height: single-pitch, i)))
}

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 9004(b); Local Rule 9013-1(a))
// ---------------------------------------------------------------------------

/// One caption row: the party text, then the ")" column that closes the party block.
#let caption-row(c) = grid(columns: (caption-left - 0.4in, 0.4in), rows: (single-pitch,), c, [)])

#let caption-party(names, designation) = {
  for n in names { caption-row(n) }
  caption-row(pad(left: 0.5in, designation))
}

#let caption-left-column(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  let cap = meta.caption
  if "in_re" in cap and cap.in_re != none {
    caption-row("In re:")
    caption-party(cap.in_re.names, cap.in_re.designation)
    caption-row(line(length: 100%, stroke: 0.5pt))
  }
  for (k, p) in cap.parties.enumerate() {
    if k > 0 {
      caption-row(pad(left: 0.5in, "v."))
    }
    caption-party(p.names, p.designation)
  }
}

#let caption-right-column(meta) = align(horizon, block(inset: (left: 0.25in), {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  block(height: single-pitch, [Case No. #meta.case_number])
  v(single-pitch)
  if "chapter" in meta and meta.chapter != none {
    block(height: single-pitch, [Chapter #meta.chapter])
    v(single-pitch)
  }
  if "adv_number" in meta and meta.adv_number != "" {
    block(height: single-pitch, [Adv. Pro. No. #meta.adv_number])
  }
}))

#let cover(meta) = {
  // Court name lines, then the division, all centered and bold.
  line-stack(meta.court.map(t => align(center, text(weight: "bold", t))))
  if "division" in meta and meta.division != none {
    line-stack((align(center, text(weight: "bold", meta.division)),))
  }
  v(pitch)
  grid(columns: (caption-left, caption-right), caption-left-column(meta), caption-right-column(meta))
  v(pitch * 0.5)
  line(length: 100%, stroke: 0.75pt)
  v(pitch * 0.5)
  block(width: text-width, align(center, text(weight: "bold", upper(meta.title))))
  v(pitch * 0.5)
  line(length: 100%, stroke: 0.75pt)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, breakable: false, {
  line-stack((meta.date,))
  v(pitch * 0.5)
  pad(left: 3.0in, {
    line-stack(("Respectfully submitted:",))
    v(pitch * 0.5)
    line-stack(meta.signature.firm)
    v(pitch * 0.5)
    line-stack((meta.signature.signer,) + meta.signature.lines)
  })
})

/// The memorandum's body: each blank-line-separated chunk of markdown is one paragraph, indented, not numbered
/// (a memorandum of law is not a numbered pleading). A heading is kept with the paragraph after it. A block
/// quotation (the certificate's service list) is single-spaced. The chunk "# Certificate of Service" starts a
/// new page, as the filed exemplar does.
#let brief-body(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("# Certificate of Service") {
      pagebreak(weak: true)
    }
    if t.starts-with("#") {
      pending += on-grid(cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
      has-pending = true
    } else if t.starts-with(">") {
      let quoted = cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      if has-pending {
        block(breakable: false, width: text-width, { pending; quoted })
      } else {
        quoted
      }
      pending = []
      has-pending = false
    } else {
      let piece = on-grid({
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
      if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let mdb-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: page-margin,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered, bold, underlined section (INTRODUCTION, ARGUMENT, ...); level 2 a bold
  // roman-numeral heading at the margin; level 3 a bold lettered sub-heading. Each sits on the line grid.
  show heading.where(level: 1): it => on-grid(align(center, text(size: type-size, weight: "bold", underline(upper(it.body)))))
  show heading.where(level: 2): it => on-grid(text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => on-grid(text(size: type-size, weight: "bold", it.body))

  // Block quotations are single-spaced and indented on both sides.
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, {
    set par(leading: single-leading, spacing: pitch * 0.5)
    it.body
  })

  cover(meta)
  v(pitch * 0.5)

  if "lead_in" in meta and meta.lead_in != none {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  // The signature comes before the certificate of service, which starts a new page (as in the exemplar).
  // The last section's heading and paragraph are kept with the signature, so a signature never stands alone on a page.
  let parts = body.split("# Certificate of Service")
  let chunks = parts.at(0).split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let tail = if chunks.len() >= 2 and chunks.at(-2).trim().starts-with("#") { 2 } else { 1 }
  brief-body(chunks.slice(0, chunks.len() - tail).join("\n\n"))

  block(width: text-width, breakable: false, {
    brief-body(chunks.slice(chunks.len() - tail).join("\n\n"))
    v(pitch)
    signature-block(meta)
  })

  if parts.len() > 1 {
    brief-body("# Certificate of Service" + parts.at(1))
  }
}
