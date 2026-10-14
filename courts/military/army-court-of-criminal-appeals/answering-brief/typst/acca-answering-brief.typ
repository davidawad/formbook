// U.S. Army Court of Criminal Appeals: brief on behalf of the United States (answer to the appellant's brief).
//
// Rule-driven and content-agnostic. Requirement IDs (32 CFR 150.15 and App. B; JRAP 17) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; cover, signature and certificate come from the YAML
// frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Doc-type parameters
// ---------------------------------------------------------------------------

#let doc-kind = "answering-brief"
#let brief-title = "BRIEF ON BEHALF OF THE UNITED STATES"  // answer heading (convention, unverified; README)
#let court-line = "IN THE UNITED STATES ARMY COURT OF CRIMINAL APPEALS"   // App. B footnote: the court's name

// ---------------------------------------------------------------------------
// Parameters. Each traces to a rule or is marked PROVISIONAL (README, Known gaps).
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"           // the only serif family vendored in /fonts; ACCA's typeface rule is unverified
#let type-size = 12pt                      // PROVISIONAL: 12-point proportional copied from JRAP/AFCCA Rule 17.1; ACCA rule not read
#let body-leading = 1.55em                 // double spacing: baseline pitch ~2x single (32 CFR 150.15(a)); measured in README
#let single-leading = 0.3em                // block quotations, headings, footnotes, caption: single-spaced
#let page-margin = 1in                     // PROVISIONAL: at least one inch on all four sides (JRAP 17.1(a))
#let para-indent = 0.5in
#let para-spacing = 0.94em                 // extra space between paragraphs (on top of the leading)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let need(meta, key) = {
  if key not in meta { panic("acca-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("acca-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A column of lines, one block each (no forced breaks).
#let lines-block(lines, align-to: left) = stack(
  dir: ttb,
  spacing: 0.25em,
  ..lines.map(l => align(align-to, text(l))),
)

// ---------------------------------------------------------------------------
// Cover: caption, docket, trial information, title, counsel
// ---------------------------------------------------------------------------

#let cover(meta) = {
  let app = need(meta, "appellant")
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.9em)
  align(center, text(weight: "bold", court-line))
  v(1.2in)
  lines-block(("UNITED STATES,", "Appellee,"))
  v(0.9em)
  align(center, "v.")
  v(0.9em)
  lines-block((app.name + ",", app.rank, app.service + ",", "Appellant."))
  v(0.9in)
  align(center, text(weight: "bold", need(meta, "docket")))
  v(0.9in)
  align(center, text(weight: "bold", brief-title))
  v(1.0in)
  let trial = need(meta, "trial")
  align(center, box(width: 4.6in, par(justify: false, [
    Tried at #trial.place, on #trial.dates, before a #trial.court-type court-martial appointed by #trial.convening.
  ])))
  v(1fr)
  grid(
    columns: (1fr, 1fr),
    gutter: 0.3in,
    ..need(meta, "counsel").map(c => lines-block(c.lines)),
  )
}

// ---------------------------------------------------------------------------
// Closing: signature block, certificate of filing and service, optional appendix
// ---------------------------------------------------------------------------

#let closing(meta) = {
  set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.9em)
  v(1.2em)
  pad(left: 3.0in, lines-block(need(meta, "signature")))
  pagebreak(weak: true)
  align(center, text(weight: "bold", "CERTIFICATE OF FILING AND SERVICE"))
  v(1.0em)
  let cert = need(meta, "certificate")
  set par(leading: body-leading, first-line-indent: para-indent, spacing: para-spacing)
  [I certify that a copy of the foregoing was mailed or delivered to the Court and to appellate defense counsel for the appellant on #cert.date.]
  v(2.0em)
  pad(left: 3.0in, lines-block(cert.signature))
  if "appendix" in meta and meta.appendix.len() > 0 {
    pagebreak(weak: true)
    align(center, text(weight: "bold", "APPENDIX"))
    v(1.0em)
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.9em)
    for item in meta.appendix { [#item\ ] }
  }
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let acca-brief(meta, body) = {
  set document(title: brief-title, author: need(meta, "appellant").name)
  set page(paper: "us-letter", margin: page-margin, numbering: none, footer: context {
    // The cover is page 1 and carries no number; body pages print their page number centered.
    if counter(page).get().first() > 1 { align(center, text(counter(page).display())) }
  })
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: para-spacing, justify: false, first-line-indent: para-indent)

  // Section headings: level 1 centered bold; level 2 bold, flush left; level 3 bold italic.
  show heading.where(level: 1): it => {
    set par(first-line-indent: 0pt)
    v(0.8em)
    block(sticky: true, align(center, text(weight: "bold", it.body)))
    v(0.6em)
  }
  show heading.where(level: 2): it => {
    set par(first-line-indent: 0pt, leading: single-leading)
    v(0.8em)
    block(sticky: true, text(weight: "bold", it.body))
    v(0.6em)
  }
  show heading.where(level: 3): it => {
    set par(first-line-indent: 0pt, leading: single-leading)
    v(0.6em)
    block(sticky: true, text(weight: "bold", style: "italic", it.body))
    v(0.4em)
  }
  // Block quotations: single-spaced, indented on both sides.
  show quote.where(block: true): it => {
    set par(leading: single-leading, first-line-indent: 0pt, spacing: 0.9em)
    pad(x: 0.5in, it.body)
  }
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)

  cover(meta)
  pagebreak()
  cmarker.render(body, smart-punctuation: true)
  closing(meta)
}
