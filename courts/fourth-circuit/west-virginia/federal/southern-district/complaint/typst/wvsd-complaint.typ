// Complaint, United States District Court, S.D. W. Va. (wvsd).
// Rules: Fed. R. Civ. P. 8(a) (short and plain statement; jurisdiction; demand for relief), 10(a) (caption),
// 10(b) (numbered paragraphs); LR Civ P 3.4(a) (civil docket cover sheet is submitted with any complaint).
// The local rules set no paper or typeface rule for a complaint (LR Civ P 7.1(a)(3)-(4) apply to memoranda),
// so the layout follows the memorandum template (wvsd motion-brief) for one court-wide look. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // proportional serif, vendored in fonts/ (see README.md)
#let type-size = 12pt                   // 12 point, as LR Civ P 7.1(a)(4) requires for memoranda
#let page-w = 8.5in                     // 8 1/2 by 11 inch paper (LR Civ P 7.1(a)(3))
#let page-h = 11in
#let margin = 1in                       // at least one inch on all four sides (LR Civ P 7.1(a)(3))
#let body-leading = 1.35em              // double spacing: EB Garamond line box 0.65em + 1.35em = 24 pt at 12 pt
#let single-leading = 0.5em             // single spacing for caption, counsel, signature, quotations, footnotes
#let para-indent = 0.5in                // the number of an allegation sits at this indent
#let caption-left = 3.7in               // width of the party column of the caption (wide enough for a party's address on one line)
#let caption-paren = 0.3in              // the column of ")" marks between parties and the case number
#let block-indent = 3.25in              // signature block starts here
#let text-width = page-w - 2 * margin

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wvsd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, addresses, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Single-spaced lines; "" is a blank line.
#let lines-block(items) = stack(dir: ttb, spacing: single-leading, ..items.map(i => if i == "" { v(single-leading * 2) } else { inl(i) }))

/// Heading numbers, set by the template (never typed in the sample). Level 1 I., level 2 A., level 3 1.,
/// level 4 (i), level 5 (1), level 6 (A).
#let heading-numbering(..n) = {
  let level = n.pos().len()
  let num = n.pos().last()
  if level == 1 { numbering("I.", num) }
  else if level == 2 { numbering("A.", num) }
  else if level == 3 { numbering("1.", num) }
  else if level == 4 { numbering("(i)", num) }
  else if level == 5 { numbering("(1)", num) }
  else { numbering("(A)", num) }
}

/// Set while lists, enumerations and block quotations are laid out: their paragraphs are not allegations.
#let no-number = state("wvsd-complaint-no-number", false)

/// Allegations are numbered 1, 2, ... by the template (Fed. R. Civ. P. 10(b)); the counter runs through the body.
#let allegation = counter("wvsd-complaint-allegation")

// ---------------------------------------------------------------------------
// Cover page: court title, caption, title of the paper (the cover carries no page number)
// ---------------------------------------------------------------------------

/// The caption: one row per party line, a column of ")" marks, and the case number (and judge, if any) at the right.
/// A side's `lead` is printed before it ("v." by default between sides; "" for none).
#let caption(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt, justify: false)
  let rows = ()
  for (k, side) in meta.caption.enumerate() {
    let lead = side.at("lead", default: if k == 0 { "" } else { "v." })
    if lead != "" { rows.push(pad(left: 0.5in, inl(lead))) }
    for n in side.names { rows.push(inl(n)) }
    rows.push(pad(left: 1.0in, inl(side.designation)))
    rows.push(v(single-leading * 2))
  }
  rows = rows.slice(0, rows.len() - 1)
  let cells = ()
  for (i, r) in rows.enumerate() {
    cells.push(r)
    cells.push(")")
    if i == 0 {
      cells.push(grid.cell(rowspan: rows.len(), align(horizon, pad(left: 0.2in, {
        set par(leading: single-leading, first-line-indent: 0pt)
        if "civil_action" in meta [#meta.civil_action]
        if "judge" in meta [#linebreak() #meta.judge]
      }))))
    }
  }
  grid(columns: (caption-left, caption-paren, 1fr), row-gutter: single-leading, ..cells)
}

#let cover(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt, justify: false)
  align(center, text(weight: "bold")[
    IN THE UNITED STATES DISTRICT COURT \
    FOR THE SOUTHERN DISTRICT OF WEST VIRGINIA \
    #upper(meta.division)
  ])
  v(24pt)
  caption(meta)
  v(24pt)
  align(center, text(weight: "bold", meta.brief_title))
}

// ---------------------------------------------------------------------------
// Signature and verification
// ---------------------------------------------------------------------------

/// "Dated" line at the left, the signature lines at the right, kept together.
#let signature-block(meta) = block(breakable: false, above: 24pt, {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
  grid(columns: (block-indent, 1fr), align(bottom, [#meta.date]), lines-block(meta.signature))
})

/// A declaration under 28 U.S.C. § 1746 (verification), on its own page.
#let verification(v-meta) = {
  pagebreak()
  set par(leading: body-leading, first-line-indent: 0pt, spacing: body-leading, justify: false)
  align(center, text(weight: "bold", underline(v-meta.heading)))
  v(12pt)
  [#v-meta.lead]
  for (k, item) in v-meta.items.enumerate() {
    pad(left: 0.5in, [#(k + 1). #h(0.25in) #inl(item)])
  }
  v(12pt)
  [Executed on #v-meta.executed.]
  v(36pt)
  pad(left: block-indent, lines-block(v-meta.signature))
}

// ---------------------------------------------------------------------------
// The complaint: cover (no number), optional table of contents, body numbered from 1, signature, verification
// ---------------------------------------------------------------------------

#let complaint(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en")
  set heading(numbering: heading-numbering)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)

  // Headings: one line each, in the body size (the number and the text share the size and weight);
  // the number comes from `heading-numbering`. Levels 1 to 3 are bold; deeper levels are roman.
  show heading.where(level: 1): it => context block(width: 100%, above: 18pt, below: 12pt, sticky: true,
    text(size: type-size, weight: "bold", grid(columns: (0.5in, 1fr), counter(heading).display(it.numbering), it.body)))
  show heading.where(level: 2): it => context block(width: 100%, above: 12pt, below: 12pt, sticky: true,
    pad(left: 0.5in, text(size: type-size, weight: "bold", grid(columns: (0.5in, 1fr), counter(heading).display(it.numbering), it.body))))
  show heading.where(level: 3): it => context block(width: 100%, above: 12pt, below: 12pt, sticky: true,
    pad(left: 1.0in, text(size: type-size, weight: "bold", grid(columns: (0.5in, 1fr), counter(heading).display(it.numbering), it.body))))
  show heading.where(level: 4): it => context block(width: 100%, above: 12pt, below: 12pt, sticky: true,
    pad(left: 1.5in, text(size: type-size, grid(columns: (0.5in, 1fr), counter(heading).display(it.numbering), it.body))))
  show heading.where(level: 5): it => context block(width: 100%, above: 12pt, below: 12pt, sticky: true,
    pad(left: 2.0in, text(size: type-size, grid(columns: (0.5in, 1fr), counter(heading).display(it.numbering), it.body))))
  show heading.where(level: 6): it => context block(width: 100%, above: 12pt, below: 12pt, sticky: true,
    pad(left: 2.5in, text(size: type-size, grid(columns: (0.5in, 1fr), counter(heading).display(it.numbering), it.body))))

  show quote.where(block: true): it => block(above: 12pt, below: 12pt, inset: (left: 0.5in, right: 0.5in), {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    it.body
  })
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)

  cover(meta)

  if meta.at("toc", default: false) {
    pagebreak()
    set page(numbering: "i", number-align: center)
    counter(page).update(1)
    align(center, text(weight: "bold", [TABLE OF CONTENTS]))
    v(12pt)
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    outline(title: none, depth: meta.at("toc_depth", default: 2), indent: 0.5in)
  }

  pagebreak()
  set page(numbering: "1", number-align: center)
  counter(page).update(1)

  // Unnumbered lead-in paragraphs: the address to the court is flush left; the paragraphs after it are indented.
  for (k, p) in meta.at("lead_in", default: ()).enumerate() {
    block(width: 100%, above: 0pt, below: body-leading, {
      set par(leading: body-leading, first-line-indent: if k == 0 { 0pt } else { (amount: para-indent, all: true) }, spacing: 0pt)
      inl(p)
    })
  }

  // The body: each paragraph is an allegation (numbered); lists, enumerations and quotations are not.
  {
    show par: it => context {
      if no-number.get() { it.body } else {
        allegation.step()
        block(width: 100%, above: 0pt, below: body-leading, {
          set par(leading: body-leading, first-line-indent: 0pt, spacing: 0pt)
          h(para-indent)
          context allegation.display()
          h(0.25in)
          it.body
        })
      }
    }
    show list: it => {
      no-number.update(true)
      it
      no-number.update(false)
    }
    show enum: it => {
      no-number.update(true)
      it
      no-number.update(false)
    }
    cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)
  }

  signature-block(meta)

  if "verification" in meta { verification(meta.verification) }
}
