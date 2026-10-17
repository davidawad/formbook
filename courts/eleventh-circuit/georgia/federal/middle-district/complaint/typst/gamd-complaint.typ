// Complaint for the U.S. District Court for the Middle District of Georgia (gamd).
// Rules: Fed. R. Civ. P. 8(a), 10(a)-(c); M.D. Ga. L.R. 5.4 (privacy redaction, filer's duty), 83.1.2(A)-(B)
// (lead counsel and State Bar numbers on the signature page of the first pleading), 87.1-87.3 (corporate
// disclosure with the initial pleading). No typeface, margin or spacing rule was found in the M.D. Ga. Local
// Rules (2022 consolidated text); the layout follows the exemplar. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to the exemplar; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"   // Times New Roman substitute per docs/FONTS.md (Times New Roman itself cannot be vendored)
#let type-size = 14pt                   // the exemplar's body text is 14 pt Times New Roman (no M.D. Ga. size rule found)
#let footer-size = 12pt                 // the exemplar's page number is 12 pt
#let page-w = 8.5in                     // Fed. R. Civ. P. 10(a) and the paper: letter size (the exemplar is letter)
#let page-h = 11in
#let margin = 1in                       // the exemplar: 1 inch on every side
#let text-width = page-w - 2 * margin
#let pitch = 32pt                       // the exemplar's baseline pitch (double spacing, measured on the exemplar)
#let body-leading = (pitch / type-size) * 1em - 0.655em  // Liberation Serif's line box is 0.655em
#let single-leading = 0.495em            // single spacing for the signature and the address block
#let single-pitch = 16pt                // one single-spaced caption row (about 1.15 em at 14 pt)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs (exemplar)
#let caption-w = 3.3in                  // width of the party column of the caption
#let sig-indent = 3in                   // the signature block starts at 3 inches (exemplar)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gamd-complaint: the sample must start with a YAML frontmatter block") }
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
  align(center, text(weight: "bold", upper(meta.title)))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lists
// ---------------------------------------------------------------------------

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a
/// heading nor a list is one numbered paragraph: its number on a line of its own, centred, then the text with a
/// first-line indent (the exemplar's form). Headings and lists are not numbered. Numbering is applied per chunk,
/// not with a `show par` rule: a show rule that re-wraps paragraph content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // A heading is a sticky block: it stays with the number line or text after it.
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Markdown lists (the prayer) are lettered (a), (b), ... by the template; they may break across pages.
      set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
      block(width: text-width, cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
    } else if t.starts-with("WHEREFORE") {
      // The request for relief is not a numbered allegation (Fed. R. Civ. P. 10(b)); it keeps the paragraph indent.
      block(width: text-width, [#h(para-indent)#inl(t)])
    } else {
      para-counter.step()
      context block(sticky: true, width: text-width, align(center, [#(para-counter.display()).]))
      block(width: text-width, [#h(para-indent)#inl(t)])
    }
  }
}

#let signature-block(meta) = {
  let sig = meta.signature
  block(sticky: true, width: text-width, [Respectfully submitted #meta.date.])
  block(breakable: false, width: text-width, {
    set par(leading: single-leading, spacing: 0pt)
    pad(left: sig-indent, stack(
      dir: ttb,
      spacing: body-leading,
      ..sig.firm.map(x => [#x]),
      ..sig.signers.map(g => stack(dir: ttb, spacing: single-leading, ..g.map(x => [#x])))
    ))
    v(body-leading)
    // Lead counsel (L.R. 83.1.2(A)): the name, and the address and telephone below, on the signature page.
    stack(dir: ttb, spacing: single-leading, [Lead Counsel: #sig.lead_counsel], ..sig.address.map(x => [#x]))
    v(body-leading)
    stack(dir: ttb, spacing: single-leading, ..sig.attorney_for.map(x => [#x]))
  })
}

#let gamd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(size: footer-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set block(spacing: body-leading)

  // Headings: level 1 is a centred bold caps line; level 2 a centred bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => block(sticky: true, width: text-width, align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(sticky: true, width: text-width, align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(sticky: true, width: text-width, text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)

  if "lead_in" in meta {
    block(width: text-width, [#h(para-indent)#inl(meta.lead_in)])
  }

  allegations(body, para-counter)

  signature-block(meta)
}
