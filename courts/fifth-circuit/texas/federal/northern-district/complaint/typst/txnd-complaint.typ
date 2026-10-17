// Complaint for the U.S. District Court for the Northern District of Texas (txnd).
// Rules: Fed. R. Civ. P. 8(a), 10(a) (caption, title, file number), 10(b) (numbered paragraphs, one set of
// circumstances each); N.D. Tex. LR 10.1 (required form: typed, 8 1/2 by 11, numbered pages, title, signature block
// with bar number, telephone, fax and email). See ../README.md for the rule text, the date verified and the gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // the rules name no typeface for a complaint; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // N.D. Tex. LR 7.2 sets 12-point or larger for briefs; applied to the complaint too
#let pitch = 24pt                       // double spacing: baseline-to-baseline distance of body text at 12 pt
#let page-w = 8.5in                     // LR 10.1: 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin-all = 1in                   // LR 7.2 margins (at least one inch); applied to the complaint too
#let text-width = page-w - 2 * margin-all
#let body-leading = 1.345em             // double spacing: Liberation Serif's line box is 0.655em, so 1.345em leading gives a 24 pt pitch at 12 pt (README.md)
#let single-leading = 0.495em            // single spacing for the caption, the title and the signature block
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.6in               // width of the party column of the caption
#let caption-sign = 0.4in               // the column of section marks (§) that separates the parties from the case data

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txnd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, quotations, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// The caption: each party name and designation is one row, with a section mark beside it; the case number and
/// the jury legend sit in the right-hand column, on the middle rows. Each name is one line in the sample; a name
/// that wraps would shift the marks in its row (see README.md).
#let caption(meta) = {
  let lines = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { lines.push("v.") }
    lines += p.names + (p.designation,)
  }
  let mid = calc.floor(lines.len() / 2)
  let cells = ()
  for (i, l) in lines.enumerate() {
    cells.push(align(left, inl(l)))
    cells.push(align(center, "§"))
    if i == mid - 1 {
      cells.push(align(left, "CIVIL ACTION NO. " + meta.case_number))
    } else if i == mid and "jury_demand" in meta and meta.jury_demand {
      cells.push(align(left, text(weight: "bold", "JURY TRIAL DEMANDED")))
    } else {
      cells.push([])
    }
  }
  set par(leading: single-leading, spacing: 0pt, justify: false)
  table(
    columns: (caption-left, caption-sign, 1fr),
    stroke: none,
    inset: 0pt,
    row-gutter: single-leading,
    ..cells,
  )
}

#let cover(meta) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  let court-lines = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF TEXAS")
  if "court_division" in meta and meta.court_division != none {
    court-lines.push(upper(meta.court_division))
  }
  align(center, stack(dir: ttb, spacing: single-leading, ..court-lines.map(l => text(weight: "bold", l))))
  v(pitch)
  caption(meta)
  v(pitch)
  align(center, text(weight: "bold", upper(meta.brief_title)))
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// One single-spaced line per item: a stack of blocks, each line one single-spaced pitch below the last.
#let line-stack(items) = stack(dir: ttb, spacing: single-leading, ..items.map(i => [#i]))

#let signature-block(meta) = block(breakable: false, width: text-width, {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  grid(
    columns: (3.0in, 1fr),
    column-gutter: 0.2in,
    [Dated: #meta.date],
    {
      [Respectfully submitted,]
      v(pitch * 0.5)
      line-stack(meta.signature.firm)
      v(pitch * 0.5)
      line-stack(("/s/ " + meta.signature.signer, meta.signature.signer, meta.signature.bar))
      v(pitch * 0.5)
      line-stack(meta.signature.address)
      v(pitch * 0.5)
      line-stack(meta.signature.lines)
    },
  )
})

/// Numbered paragraphs. Each blank-line-separated chunk of markdown that is neither a heading nor a list is one
/// numbered paragraph (Fed. R. Civ. P. 10(b)). Headings and lists are rendered unnumbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content recurses
/// without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Prayer items: numbered 1., 2., ... by the enum set in txnd-complaint; items are spaced by body-leading.
      block(width: text-width, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
    } else {
      block(width: text-width, below: body-leading, {
        para-counter.step()
        context [#h(para-indent)#(para-counter.display()).#h(0.15in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
      })
    }
  }
}

#let txnd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin-all,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered caps section; level 2 a bold left heading with a hanging numeral;
  // level 3 a centered bold sub-heading. Each heading stays with the paragraph after it.
  show heading.where(level: 1): it => block(width: text-width, above: pitch, below: body-leading, sticky: true,
    par(leading: single-leading, align(center, text(weight: "bold", upper(it.body)))))
  show heading.where(level: 2): it => block(width: text-width, above: pitch, below: body-leading, sticky: true,
    par(leading: single-leading, hanging-indent: 0.5in, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: text-width, above: body-leading, below: body-leading, sticky: true,
    par(leading: single-leading, align(center, text(weight: "bold", it.body))))

  cover(meta)

  // Body: numbered paragraphs; prayer items are numbered 1., 2., ... (Fed. R. Civ. P. 10(b)).
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter)

  v(pitch)
  signature-block(meta)
}
