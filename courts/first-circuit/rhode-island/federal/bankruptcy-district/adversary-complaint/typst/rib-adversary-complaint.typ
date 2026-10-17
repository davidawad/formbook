// Adversary complaint for the United States Bankruptcy Court, District of Rhode Island (rib).
// Rules: FRBP 7001 (adversary proceeding), FRBP 7008 (pleading), FRCP 10(a)-(b) as applied by FRBP 7010
// (caption; numbered paragraphs); LBR 1005-1(a)-(c) (case name, number and chapter on every paper and on the
// signature page; 8 1/2 x 11; text at least 11 point and double spaced; footnotes at least 10 point; signer's
// identification); LBR 7007-1 (papers in adversary proceedings follow LBR 1005-1); LBR 7003-1(b) and 5005-1(b)
// (cover sheet, Official Form B1040, filed separately). See ../README.md for each rule's text and date.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"          // Times New Roman substitute per docs/FONTS.md, vendored in fonts/liberation-serif; no system font is used
#let type-size = 12pt                     // LBR 1005-1(b): text at least 11 point
#let footnote-size = 10pt                 // LBR 1005-1(b): footnotes at least 10 point
#let body-leading = 1.345em               // LBR 1005-1(b): double spaced. The Liberation Serif line box is 0.655em, so 2em = 24 pt pitch at 12 pt
#let single-leading = 0.5em               // single spacing: caption, counsel, quotations, signature (exempt under LBR 1005-1(b))
#let para-indent = 0.5in
#let page-w = 8.5in                       // LBR 1005-1(b): 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin = 1in                         // not set by LBR 1005-1; the usual 1 inch on every side
#let text-width = page-w - 2 * margin
#let caption-left = 3.3in                 // width of the party column of the caption
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF RHODE ISLAND")   // court-level text, not case text

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("rib-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced lines: one item per line, the stack keeps single spacing.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// A heading kept in one unbreakable block with the chunk after it, so it never ends a page.
#let keep-with(c) = block(breakable: false, width: text-width, c)

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title() = {
  for line in court-name {
    align(center, text(weight: "bold", line))
  }
}

/// The caption: the bankruptcy case (In re) above, the adversary proceeding (parties) below a rule,
/// and the case numbers on the right. Parties and debtors come from the frontmatter.
#let caption(meta) = grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    line-stack(("IN RE:",))
    v(single-leading)
    line-stack(meta.in_re)
    v(single-leading * 0.5)
    align(right, line-stack((meta.debtor_designation,)))
    v(single-leading * 2)
    {
      let rows = ()
      for (k, p) in meta.caption.parties.enumerate() {
        if k > 0 { rows.push("v.") }
        rows += p.names + (p.designation,)
      }
      line-stack(rows)
    }
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack((
      "Chapter " + meta.chapter,
      "Bankruptcy Case No. " + meta.case_number,
      "",
      "Adversary Proceeding No. " + meta.adversary_number,
    ))
  }),
)

#let cover(meta) = {
  court-title()
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", upper(meta.title)))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lettered lists, quotations
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let s = meta.signature
  keep-with(block(width: text-width, {
    // LBR 1005-1(a): the bankruptcy case name, number and chapter must appear on the signature page too.
    set par(leading: single-leading, spacing: 0pt, justify: false)
    text(size: type-size, [In re #meta.in_re.join(", "), Debtor; Chapter #meta.chapter; Bankruptcy Case No. #meta.case_number; Adversary Proceeding No. #meta.adversary_number])
    v(body-leading)
    grid(
      columns: (2.8in, 1fr),
      column-gutter: 0.2in,
      [Dated: #meta.date],
      {
        [Respectfully submitted,]
        v(single-leading * 2)
        line-stack((s.client, s.by))
        v(single-leading * 2)
        line-stack(("/s/ " + s.signer, s.signer))
        v(single-leading)
        line-stack(s.firm + (
          "RI Bar No. " + s.bar_id,
        ) + s.lines)
      },
    )
  }))
}

/// Body chunks. A chunk is one blank-line-separated piece of markdown:
/// - a heading (`#` centered caps, `##` centered bold, `###` bold italic): unnumbered, sticky (stays with the next chunk);
/// - a list (`1.` items): lettered (a), (b), ...;
/// - a block quotation (`>`): single spaced and indented, unnumbered;
/// - a paragraph: numbered (FRCP 10(b)), unless it starts with WHEREFORE (the prayer lead-in is unnumbered).
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // A heading is sticky (see the heading show rules), so it is emitted as it is and stays with the next chunk.
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      let items = {
        set par(leading: body-leading, spacing: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      items
    } else if t.starts-with(">") {
      let q = {
        set par(leading: single-leading, spacing: body-leading * 0.5)
        pad(left: 0.75in, right: 0.5in, cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
        v(body-leading * 0.5)
      }
      q
    } else if t.starts-with("WHEREFORE") {
      let piece = {
        set par(leading: body-leading, spacing: body-leading)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      }
      piece
    } else {
      let piece = {
        para-counter.step()
        set par(leading: body-leading, spacing: body-leading)
        context [#h(para-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      }
      piece
    }
  }
}

#let rib-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: 11pt, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  // Footnotes: 10 point and single spaced (LBR 1005-1(b)); a footnote may not hold body text.
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(leading: single-leading, spacing: 0pt)

  // Headings: level 1 is a centered bold section; level 2 centered bold; level 3 bold italic.
  // A heading gets half a line of space above it (weak: it is dropped at the top of a page). Sticky: it stays
  // on the page of the paragraph after it, and that paragraph may still break.
  show heading.where(level: 1): it => block(width: text-width, breakable: false, sticky: true, {
    v(body-leading * 0.5, weak: true)
    align(center, text(size: type-size, weight: "bold", upper(it.body)))
  })
  show heading.where(level: 2): it => block(width: text-width, breakable: false, sticky: true, {
    v(body-leading * 0.5, weak: true)
    align(center, text(size: type-size, weight: "bold", it.body))
  })
  show heading.where(level: 3): it => block(width: text-width, breakable: false, sticky: true, {
    v(body-leading * 0.5, weak: true)
    align(center, text(size: type-size, weight: "bold", style: "italic", it.body))
  })

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none {
    let leads = if type(meta.lead_in) == array { meta.lead_in } else { (meta.lead_in,) }
    for p in leads {
      block(width: text-width, {
        set par(leading: body-leading, spacing: body-leading)
        h(para-indent)
        inl(p)
      })
    }
  }

  allegations(body, para-counter)
  signature-block(meta)
}
