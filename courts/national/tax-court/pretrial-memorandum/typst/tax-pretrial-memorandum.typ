// U.S. Tax Court: pretrial memorandum (Standing Pretrial Order; Tax Court Rule 131(b)).
//
// Rule-driven and content-agnostic. Rule numbers refer to ../README.md, which cites the primary
// sources. No case-specific text, no coordinates measured off a filed paper, no forced line breaks.
// The narrative sections are markdown rendered by cmarker; the case fields, attorneys, amounts,
// status boxes and signature block come from the YAML frontmatter of the same file
// (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"       // Rule 23(d)(2): one consistent proportional typeface. Vendored in fonts/.
#let type-size = 14pt                  // Rule 23(d)(2): 14-point type produced by a proportional print font.
#let double-leading = 1.07em           // Rule 23(d)(2)-(3): double spacing, no more than 3 lines per inch.
                                       // Calibrated so the baseline pitch is 24.1 pt (see README, "Calibration").
#let single-leading = 0.4em            // Rule 23(d)(2)-(3): single spacing (no more than 6 lines per inch) for
                                       // the form fields, the caption, quotations and the signature block.
#let margin-side = 1in                 // Rule 23(d)(1): side margins no less than 1 inch.
#let margin-tb = 1in                   // Rule 23(d)(1): top and bottom margins no less than 3/4 inch.
#let footer-distance = 0.75in + 6pt    // page-number box bottom sits above the 3/4-inch line (6 pt for the line box below the glyph).
#let para-indent = 0.5in
#let label-width = 3.5in               // left column of the form fields
#let caption-width = 4.0in
#let caption-gutter = 0.3in

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

#let need(meta, key) = {
  if key not in meta { panic("tax-pretrial-memorandum: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tax-pretrial-memorandum: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A drawn check box (no font glyph needed, so no fallback can occur).
#let checkbox(checked) = box(
  width: 0.72em, height: 0.72em, baseline: 0.05em, stroke: 0.7pt, inset: 0pt,
  if checked {
    place(top + left, line(start: (0pt, 0pt), end: (100%, 100%), stroke: 0.9pt))
    place(top + left, line(start: (0pt, 100%), end: (100%, 0pt), stroke: 0.9pt))
  },
)

/// The party names as one phrase: "A and B", or "A".
#let names-phrase(names) = {
  if names.len() == 1 { names.at(0) } else {
    names.slice(0, -1).join(", ") + " and " + names.last()
  }
}

// ---------------------------------------------------------------------------
// Caption (Rule 23(a)(1)): the same caption as the petition, with the docket number once assigned.
// ---------------------------------------------------------------------------

#let caption(meta) = {
  let names = need(meta, "petitioners")
  if type(names) != array or names.len() == 0 {
    panic("tax-pretrial-memorandum: `petitioners` must be a non-empty list of names")
  }
  let designation = if names.len() > 1 { "Petitioners," } else { "Petitioner," }
  let docket = "Docket No. " + need(meta, "docket_no")

  let rows = ()
  for n in names { rows.push((n, ")", "")) }
  rows.push(("", ")", ""))
  rows.push((pad(left: 1.2in, designation), ")", ""))
  rows.push(("", ")", ""))
  rows.push((pad(left: 0.6in)[v.], ")", docket))
  rows.push(("", ")", ""))
  rows.push(("COMMISSIONER OF INTERNAL REVENUE,", ")", ""))
  rows.push(("", ")", ""))
  rows.push((pad(left: 1.2in)[Respondent.], ")", ""))

  align(center, text(weight: "bold", [UNITED STATES TAX COURT]))
  v(1.5em)
  grid(
    columns: (caption-width, caption-gutter, 1fr),
    align: (left, center, left),
    row-gutter: single-leading,
    ..rows.flatten(),
  )
}

// ---------------------------------------------------------------------------
// Form fields (single-spaced, as on the Court's Pretrial Memorandum form)
// ---------------------------------------------------------------------------

#let field(label, value) = grid(
  columns: (label-width, 1fr),
  column-gutter: 0.1in,
  row-gutter: single-leading,
  text(weight: "bold", label), value,
)

#let status-option(label, on) = [#checkbox(on) #h(0.4em) #label]

#let case-name(meta) = names-phrase(need(meta, "petitioners")) + " v. Commissioner of Internal Revenue"

#let attorney-block(a) = {
  let lines = (a.name,)
  if "tel" in a { lines.push("Tel. No.: " + a.tel) }
  if "email" in a { lines.push("Email: " + a.email) }
  lines.join(linebreak())
}

#let form-block(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
  let att = need(meta, "attorneys")
  let amounts = need(meta, "amounts")
  let status = need(meta, "status")
  let stip = need(meta, "stipulation_status")

  field([NAME OF CASE:], case-name(meta))
  v(0.9em)
  field([DOCKET NO(S).:], need(meta, "docket_no"))
  v(0.9em)
  field([TRIAL CALENDAR:], need(meta, "trial_calendar"))
  v(0.9em)

  text(weight: "bold", [ATTORNEYS:])
  v(0.3em)
  grid(
    columns: (1fr, 1fr), column-gutter: 0.3in,
    [*Petitioner:*\ #attorney-block(att.petitioner)],
    [*Respondent:*\ #attorney-block(att.respondent)],
  )
  v(0.9em)

  text(weight: "bold", [AMOUNTS IN DISPUTE:])
  v(0.3em)
  table(
    columns: (1fr, 1.6fr, 1.6fr),
    stroke: 0.5pt,
    inset: 0.4em,
    table.header(
      text(weight: "bold", [Year(s)/Period(s)]),
      text(weight: "bold", [Deficiencies/Liabilities]),
      text(weight: "bold", [Additions/Penalties]),
    ),
    ..amounts.map(a => (a.years, a.deficiency, a.additions)).flatten(),
  )
  v(0.9em)

  text(weight: "bold", [STATUS OF CASE:])
  v(0.3em)
  grid(
    columns: (1fr, 1fr, 1fr),
    status-option([Probable Settlement], status == "probable-settlement"),
    status-option([Probable Trial], status == "probable-trial"),
    status-option([Definite Trial], status == "definite-trial"),
  )
  v(0.9em)

  text(weight: "bold", [CURRENT ESTIMATE OF TRIAL TIME:]) + [ ] + need(meta, "trial_time") + [ hour(s)]
  v(0.9em)

  text(weight: "bold", [STATUS OF STIPULATION OF FACTS:])
  v(0.3em)
  grid(
    columns: (1fr, 1fr),
    status-option([Completed, will be filed electronically], stip == "completed"),
    status-option([In Progress], stip == "in-progress"),
  )
  v(0.9em)
}

// ---------------------------------------------------------------------------
// Signature block (Rule 23(a)(2)-(3): date, name, mailing address, email, telephone, bar number)
// ---------------------------------------------------------------------------

#let signature(meta) = {
  let sig = need(meta, "signature")
  let date = need(meta, "date")
  block(breakable: false, width: 100%, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt, justify: false)
    v(2em)
    grid(
      columns: (1fr, 3.2in),
      [Dated: #date], [
        #v(0.6em)
        #line(length: 100%, stroke: 0.7pt)
        #v(0.6em)
        #sig.signer
        #for l in sig.lines [
          \ #l
        ]
      ],
    )
  })
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let tax-pretrial-memorandum(meta, body) = {
  let party = need(meta, "party")
  if party not in ("petitioner", "respondent") {
    panic("tax-pretrial-memorandum: `party` must be `petitioner` or `respondent`")
  }

  set document(title: "Pretrial Memorandum", author: "")
  set page(
    paper: "us-letter",
    margin: (x: margin-side, top: margin-tb, bottom: margin-tb),
    // The page number sits on the 3/4-inch line: placed from the bottom edge, not by typst's footer
    // (whose footer-descent does not place it at a fixed distance from the edge in typst 0.15).
    foreground: context place(bottom + center, dy: -footer-distance, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  // spacing = leading: a new paragraph starts one double-spaced pitch below the last line.
  set par(justify: false, leading: double-leading, spacing: double-leading, first-line-indent: (amount: para-indent, all: true))

  // Section headings of the narrative: bold capitals, flush left, single-spaced (the Court's form style).
  show heading: it => block(above: 1em, below: 0.9em, width: 100%, {
    set par(first-line-indent: 0pt, leading: single-leading)
    set text(size: type-size, weight: "bold")
    it.body
  })

  // Tables in the narrative (witnesses): single-spaced, with the body typeface and size.
  show table: set text(size: type-size)
  show table.cell: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0pt)

  // Quotations longer than five lines are set off and indented, single-spaced (Rule 23(d)(2)).
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(
    left: para-indent, right: para-indent,
    {
      set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
      it.body
    },
  ))

  caption(meta)
  v(2em)
  align(center, text(weight: "bold", [PRETRIAL MEMORANDUM FOR #{ if party == "petitioner" { "PETITIONER" } else { "RESPONDENT" } }]))
  v(1em)

  form-block(meta)

  // Narrative sections (Motions, Issues, Witnesses, Summary of Facts): markdown, double-spaced text.
  cmarker.render(body, raw-typst: false, smart-punctuation: true, h1-level: 1)

  signature(meta)
}
