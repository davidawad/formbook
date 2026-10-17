// Complaint for the U.S. District Court for the Western District of Oklahoma (okwd).
// Rules: LCvR7.1(d) (13-point print style including footnotes; margins at least one inch), LCvR5.2(a) (double-spaced,
// 8 1/2 by 11), LCvR5.4 (counsel's mailing address, telephone, fax and e-mail on every paper), LCvR3.1 (each party
// numbered separately in the caption), Fed. R. Civ. P. 8, 10(a), 10(b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "TeX Gyre Schola"   // Schola matches the audited exemplar (docs/FONTS.md)
#let type-size = 13pt                   // LCvR7.1(d): print style not less than 13-point, footnotes included
#let page-w = 8.5in                     // LCvR5.2(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LCvR7.1(d): minimum one inch on the top, bottom and sides
#let text-width = page-w - 2 * margin
#let body-leading = 1.345em             // LCvR5.2(a) double spacing: 0.655em line box + 1.345em = 2.0em pitch (26 pt at 13 pt)
#let single-leading = 0.495em            // single spacing for the caption, counsel and signature blocks
#let single-pitch = 15pt                // one single-spaced line at 13 pt (0.655em + 0.495em, measured in README.md)
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let caption-left = 3.4in               // width of the party column of the caption
#let paren-w = 0.3in                    // the ")" column between the parties and the case number

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("okwd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced line: a fixed-height block, so consecutive lines keep the single pitch whatever the font metrics.
#let single-line(c) = block(width: 100%, height: single-pitch, above: 0pt, below: 0pt, c)

// ---------------------------------------------------------------------------
// Caption (LCvR3.1: parties numbered; LCvR7.1(d) type size)
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
// Body and signature
// ---------------------------------------------------------------------------

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
      if "firm" in meta.signature and meta.signature.firm.len() > 0 { v(single-pitch) }
      single-line(meta.signature.sign)
      for line in meta.signature.lines { single-line(line) }
    },
  )
})

/// Numbered allegations (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a
/// heading nor a list is one numbered paragraph. Headings and lists are rendered unnumbered, and so is any
/// paragraph under a level-1 heading named in the frontmatter `unnumbered` list (the prayer and the jury demand
/// are not numbered in the filed complaint).
/// The signature block is kept with the last paragraph, so a signature never stands alone on a page.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content
/// recurses without end in typst 0.15.
#let allegations(body, para-counter, unnumbered, tail) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let numbering-on = true
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let last = i == chunks.len() - 1
    if t.starts-with("# ") {
      let title = t.slice(2).trim()
      numbering-on = not unnumbered.any(u => title.contains(u))
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Prayer items are lettered A., B., ... by the enum numbering set below; each item fills whole lines.
      {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if last { tail }
    } else {
      let para = block(width: text-width, {
        set par(leading: body-leading, first-line-indent: 0pt)
        h(para-indent)
        if numbering-on {
          para-counter.step()
          context [#(para-counter.display()).#h(0.25in)]
        }
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
      if last {
        block(breakable: false, width: text-width, { para; tail })
      } else {
        para
      }
    }
  }
}

#let okwd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    numbering: none,
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 a centered bold section (count headings too); level 2 a centered bold sub-heading.
  // A heading never ends a page: it is sticky to the block after it.
  show heading.where(level: 1): it => block(sticky: true, width: text-width, above: body-leading, below: body-leading,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(sticky: true, width: text-width, above: body-leading, below: body-leading,
    align(center, text(weight: "bold", it.body)))

  cover(meta)

  if "lead_in" in meta {
    block(width: text-width, {
      set par(leading: body-leading)
      h(para-indent)
      meta.lead_in
    })
  }

  // Prayer items are lettered (A., B., ...) as in the filed complaints; list spacing is double.
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.3in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.3in, spacing: body-leading)
  allegations(body, para-counter, meta.at("unnumbered", default: ()), signature-block(meta))
}
