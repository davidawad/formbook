// Brief in support of a motion (Fed. R. Civ. P. 12(b)) for the U.S. District Court for the Middle District
// of Georgia (gamd). Rules: M.D. Ga. L.R. 7.1 (a motion is accompanied by a memorandum of law citing its
// authorities, and a statement of fact where it alleges facts), 7.2 (response within 21 days), 7.3 (reply
// within 14 days), 7.4 (briefs limited to 20 pages; movant's reply 10 pages), 5.4 (privacy redaction),
// 83.1.2(B) (State Bar number on the signature page); Fed. R. Civ. P. 7(b), 12(b). No typeface, margin or
// spacing rule was found in the M.D. Ga. Local Rules (2022 consolidated text); the layout follows the exemplar.
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to the exemplar; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/; Times New Roman is not vendored (README, known gaps)
#let type-size = 13pt                   // the exemplar's body text is 12 pt Times New Roman; EB Garamond sets smaller at the same size
#let footnote-size = 11pt               // footnotes single-spaced, a point or so under the text (exemplar)
#let pitch = 27.6pt                     // the exemplar's double-spaced baseline pitch (12 pt Times, measured: about 27.5 pt)
#let body-leading = (pitch / type-size) * 1em - 0.65em   // EB Garamond's line box is about 0.65em (see README)
#let single-leading = 0.5em             // caption, headings' neighbours, footnotes, signature and address block
#let single-pitch = 1.15 * type-size      // the minimum height of one single-spaced caption row
#let para-indent = 0.5in                // first-line indent of body paragraphs (exemplar)
#let margin = 1in                       // the exemplar: 1 inch on every side
#let page-w = 8.5in                     // letter (exemplar)
#let page-h = 11in
#let text-width = page-w - 2 * margin
#let caption-w = 3.3in                  // width of the party column of the caption
#let sig-indent = 3in                   // the signature block starts at 3 inches (exemplar)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gamd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

// ---------------------------------------------------------------------------
// Cover: court heading, caption, title
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = meta.court
  if "division" in meta and meta.division != none { lines.push(meta.division) }
  align(center, stack(dir: ttb, spacing: single-leading, ..lines.map(x => text(weight: "bold", upper(x)))))
}

/// One caption row: the party line (names may wrap), a ")" for each line it takes, and the right-hand text.
/// The row is n single-spaced lines high, n measured in this row's own style, so the ")" marks line up with
/// the text whether or not a name wraps.
#let caption-row(c, right) = context {
  set par(leading: single-leading, spacing: 0pt)
  let n = calc.max(1, int(calc.round(measure(width: caption-w, c).height / single-pitch)))
  block(width: 100%, height: n * single-pitch, grid(
    columns: (caption-w, 0.3in, 1fr),
    column-gutter: 0pt,
    c,
    stack(dir: ttb, spacing: single-leading, ..range(n).map(_ => [)])),
    right,
  ))
}

/// The caption: each party is one row (its names, then its designation, all single-spaced), with "v." between
/// the parties; a column of ")" marks, and the file number and the jury demand in the right column (the exemplar's form).
#let caption(meta) = {
  let label = if "case_label" in meta { meta.case_label } else { "Civil Action No." }
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push(("v.", [])) }
    let party = {
      set par(leading: single-leading, spacing: 0pt)
      stack(dir: ttb, spacing: single-leading, ..p.names.map(n => [#n]), [#h(1in)#p.designation])
    }
    // File number on the first party's row; jury demand on the second party's row.
    let right = if k == 0 and "case_number" in meta {
      [#label #meta.case_number]
    } else if k == 1 and "jury_demand" in meta and meta.jury_demand {
      text(weight: "bold", "JURY TRIAL DEMANDED")
    } else {
      []
    }
    rows.push((party, right))
  }
  // The closing rule under the parties, with its ")" mark, as in the exemplar.
  rows.push((line(length: caption-w - 0.1in, stroke: 0.5pt), []))
  stack(dir: ttb, spacing: 0pt, ..rows.map(r => caption-row(r.at(0), r.at(1))))
}

#let cover(meta) = {
  court-title(meta)
  v(body-leading)
  caption(meta)
  v(body-leading)
  align(center, text(weight: "bold", meta.title))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// The signature block (L.R. 83.1.2(B): State Bar numbers on the signature page). The lead-counsel line
/// is optional: L.R. 83.1.2(A) asks for it on the first pleading only.
#let signature-block(meta) = {
  let sig = meta.signature
  block(breakable: false, width: text-width, {
    set par(leading: single-leading, spacing: 0pt)
    pad(left: sig-indent, stack(
      dir: ttb,
      spacing: body-leading,
      [Respectfully submitted,],
      stack(dir: ttb, spacing: single-leading, ..sig.firm.map(x => [#x])),
      ..sig.signers.map(g => stack(dir: ttb, spacing: single-leading, ..g.map(x => [#x]))),
    ))
    v(body-leading)
    stack(dir: ttb, spacing: single-leading,
      ..if "lead_counsel" in sig and sig.lead_counsel != none { ([Lead Counsel: #sig.lead_counsel],) } else { () },
      ..sig.address.map(x => [#x]))
    v(body-leading)
    stack(dir: ttb, spacing: single-leading, ..sig.attorney_for.map(x => [#x]))
  })
}

#let gamd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    // Page 1 carries no number (exemplar); the rest are numbered at the bottom centre.
    footer: context {
      if counter(page).get().first() > 1 {
        align(center, text(size: 12pt, counter(page).display()))
      }
    },
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set block(spacing: body-leading)

  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Headings are typed as written by the author (no case or numbering is applied): level 1 centred and
  // bold; level 2 bold, flush left (the author types "I.", "A.", and so on, as the exemplar does).
  show heading.where(level: 1): it => block(sticky: true, width: text-width, align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 2): it => block(sticky: true, width: text-width, text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => block(sticky: true, width: text-width, text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)

  // The body is rendered as one markdown document, so footnote references and definitions work across it.
  // A line reading [[signature]] places the signature block there (the certificate of service repeats it);
  // without the marker, the signature block closes the document.
  let pieces = body.split("[[signature]]")
  for (i, piece) in pieces.enumerate() {
    cmarker.render(piece, raw-typst: false, smart-punctuation: true, h1-level: 1)
    if i < pieces.len() - 1 {
      signature-block(meta)
    }
  }
  if pieces.len() == 1 {
    signature-block(meta)
  }
}
