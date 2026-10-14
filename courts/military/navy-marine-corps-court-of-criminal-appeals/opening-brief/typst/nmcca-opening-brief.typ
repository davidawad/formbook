// U.S. Navy-Marine Corps Court of Criminal Appeals: appellant's brief and assignments of error.
//
// Rule-driven and content-agnostic. Requirement IDs (NMCCA-...) refer to ../README.md, which cites
// the NMCCA Rules of Appellate Procedure (2022) and Appendix I. No case-specific text, no
// coordinates measured off any filed brief, no forced line breaks. The markdown body is rendered
// by cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"          // NMCCA-FORM-001: proportional serif, vendored in /fonts.
#let type-size = 14pt                      // NMCCA-FORM-001: 14-point type, footnotes included.
#let body-leading = 1.75em                 // NMCCA-FORM-002: double-spaced (see README: 2 x 1.2 em single pitch).
#let single-leading = 0.55em               // single pitch 1.2 em for the caption, headings, quotations, footnotes, signature blocks.
#let side-margin = 1in                     // NMCCA-FORM-003 (margins are not stated; 1 inch is conventional).
#let top-margin = 1in
#let bottom-margin = 1in                   // NMCCA-FORM-003: 1 inch bottom margin after the first page.
#let first-page-bottom-margin = 2in        // NMCCA-FORM-003: first page, for filing stamps.
#let para-indent = 0.5in

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Plain text of a piece of content, for comparisons only.
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

#let need(meta, key) = {
  if key not in meta { panic("nmcca-opening-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nmcca-opening-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// True when the level-1 section that contains `loc` is the Argument (NMCCA-CONT-004).
#let in-argument(loc) = {
  let tops = query(selector(heading.where(level: 1)).before(loc, inclusive: true))
  tops.len() > 0 and lower(plain(tops.last().body)).trim() == "argument"
}

// ---------------------------------------------------------------------------
// Cover (Appendix I, first page; NMCCA-FORM-004)
// ---------------------------------------------------------------------------

#let cover(meta) = {
  set block(spacing: single-leading)
  align(center)[
    #text(weight: "bold")[IN THE UNITED STATES NAVY-MARINE CORPS]
    #v(0pt)
    #text(weight: "bold")[COURT OF CRIMINAL APPEALS]
  ]
  v(1.2em)
  align(center)[Before #need(meta, "panel")]
  v(1.8em)
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    [
      #block[#need(meta, "appellee")]
      #v(0.9em)
      #block(width: 100%)[#align(center)[#need(meta, "appellee_role")]]
      #v(0.9em)
      #block[v.]
      #v(0.9em)
      #block[#need(meta, "appellant")]
      #for l in need(meta, "appellant_lines") {
        block[#text(style: "italic")[#l]]
      }
      #v(0.9em)
      #block(width: 100%)[#align(center)[#need(meta, "appellant_role")]]
    ],
    [
      #block[NMCCA No. #need(meta, "nmcca_no")]
      #v(0.9em)
      #block[#text(weight: "bold")[#upper(need(meta, "title"))]]
    ],
  )
  v(1.8em)
  align(center)[
    #text(weight: "bold")[TO THE HONORABLE, THE JUDGES OF THE UNITED STATES]
    #v(0pt)
    #text(weight: "bold")[NAVY-MARINE CORPS COURT OF CRIMINAL APPEALS]
  ]
  v(1.2em)
  set par(leading: single-leading, first-line-indent: 0pt)
  [#inl(need(meta, "tried_at"))]
  v(1fr)
  pad(left: 3in)[
    #set block(spacing: single-leading)
    #for l in need(meta, "counsel") {
      block[#l]
    }
  ]
}

// ---------------------------------------------------------------------------
// Signature block and certificate (Appendix I; NMCCA-FORM-008, NMCCA-FORM-009)
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(breakable: false, width: 100%)[
  #set par(leading: single-leading, first-line-indent: 0pt)
  #v(1.2em)
  #pad(left: 3in)[
    #set block(spacing: single-leading)
    Respectfully submitted.
    #v(2.4em)
    #line(length: 3in, stroke: 0.5pt)
    #let sig = need(meta, "signature")
    #block[#sig.signer]
    #for l in sig.lines {
      block[#text(style: "italic")[#l]]
    }
  ]
]

#let certificate(meta) = {
  set page(numbering: "1")
  pagebreak(weak: true)
  align(center)[#text(weight: "bold")[CERTIFICATE OF FILING AND SERVICE]]
  v(1.2em)
  set par(leading: body-leading, first-line-indent: para-indent)
  [I certify that the foregoing was delivered to the Navy-Marine Corps Court of Criminal Appeals, and that a copy was served on #need(meta, "served_on") on #need(meta, "date").]
  block(breakable: false, width: 100%)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #v(2.4em)
    #pad(left: 3in)[
      #set block(spacing: single-leading)
      #line(length: 3in, stroke: 0.5pt)
      #let sig = need(meta, "signature")
      #block[#sig.signer]
      #for l in sig.lines {
        block[#text(style: "italic")[#l]]
      }
    ]
  ]
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

/// The required level-1 sections (NMCCA-CONT-001). Issues may be titled either way (see README).
#let required-sections = (
  "statement of statutory jurisdiction",
  "statement of the case",
  "statement of facts",
  "summary of argument",
  "argument",
  "conclusion",
)

/// Headings that take no label and do not advance the count (the filed brief leaves them bare;
/// "Discussion" is followed by the labelled A., B. sub-headings).
#let unlabelled = ("standard of review", "principles of law", "discussion", "conclusion")

/// The label of every heading, in document order (NMCCA-CONT-004). Labels are computed from a
/// query of all headings, so an unlabelled heading does not shift the numbering of the others.
/// Must be called inside `context`.
#let heading-labels() = {
  let counts = (0, 0, 0, 0, 0, 0)
  let arg = false
  let out = ()
  for h in query(heading) {
    let t = lower(plain(h.body)).trim()
    let lvl = h.level
    if lvl == 1 {
      arg = t == "argument"
      counts = (0, 0, 0, 0, 0, 0)
      out.push(none)
      continue
    }
    if lvl > 5 { panic("nmcca-opening-brief: headings deeper than level 5 are not supported") }
    for j in range(lvl + 1, 6) { counts.at(j) = 0 }
    if t in unlabelled {
      out.push(none)
      continue
    }
    counts.at(lvl) = counts.at(lvl) + 1
    let pat = if arg { ("I.", "A.", "1.", "a.").at(lvl - 2) } else { ("A.", "1.", "a.", "(1)").at(lvl - 2) }
    out.push(numbering(pat, counts.at(lvl)))
  }
  out
}

#let nmcca-opening-brief(meta, body) = {
  set document(title: "NMCCA " + need(meta, "nmcca_no") + " " + need(meta, "title"))
  set page(
    paper: "us-letter",
    margin: (top: top-margin, left: side-margin, right: side-margin, bottom: bottom-margin),
    numbering: none,
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)
  set heading(numbering: none)
  show footnote.entry: set par(leading: single-leading, spacing: 0.5em, first-line-indent: 0pt)
  show outline.entry: set block(spacing: 0.6em)
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in)[
    #set par(leading: single-leading, spacing: 0.8em, first-line-indent: 0pt)
    #it.body
  ]

  // Headings: level 1 is a centered bold capital section; deeper levels are labelled per
  // NMCCA-CONT-004 (Argument: I. / A. / 1. / a.; elsewhere: A. / 1. / a. / (1)).
  show heading: it => context {
    set text(size: type-size)
    let loc = it.location()
    if it.level == 1 {
      align(center, block(above: 1.4em, below: 1.2em, breakable: false)[
        #set par(leading: single-leading, first-line-indent: 0pt)
        #text(weight: "bold")[#upper(it.body)]
      ])
    } else {
      let labels = heading-labels()
      let label = labels.at(query(heading).position(h => h.location() == loc))
      let style = if it.level == 2 and in-argument(loc) { "italic" } else { "normal" }
      block(above: 1.1em, below: 1.1em, breakable: false, width: 100%)[
        #set par(leading: single-leading, first-line-indent: 0pt)
        #if label == none {
          text(weight: "bold", style: style, it.body)
        } else {
          grid(
            columns: (auto, 1fr),
            column-gutter: 0.5em,
            text(weight: "bold", label),
            text(weight: "bold", style: style, it.body),
          )
        }
      ]
    }
  }

  // 1. Cover: its own first page, with the 2-inch bottom margin (NMCCA-FORM-003). Unnumbered.
  page(margin: (top: top-margin, left: side-margin, right: side-margin, bottom: first-page-bottom-margin), numbering: none)[
    #cover(meta)
  ]

  // 2. Index of Brief (NMCCA-CONT-001(b)(1)): generated from the headings, with page references.
  page(numbering: "i")[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[#text(weight: "bold")[INDEX OF BRIEF]]
    #v(1.2em)
    #show outline.entry: set text(size: type-size)
    #outline(title: none, depth: 2, indent: 1.5em)
  ]

  // 3. Body, numbered from 1. Cover and index are not counted in the page numbers of the body.
  counter(page).update(1)
  set page(numbering: "1")
  // Required sections must be present (NMCCA-CONT-001), in either the 2013 or the 2022 wording of issues.
  context {
    let names = query(heading.where(level: 1)).map(h => lower(plain(h.body)).trim())
    for req in required-sections {
      if req not in names { panic("nmcca-opening-brief: missing required section `" + req + "`") }
    }
    if "issue(s) presented" not in names and "assignments of error" not in names {
      panic("nmcca-opening-brief: missing required section `Issue(s) Presented` or `Assignments of Error`")
    }
    let subs = query(heading).map(h => lower(plain(h.body)).trim())
    if not subs.any(s => s.contains("standard of review")) {
      panic("nmcca-opening-brief: a `Standard of Review` heading is required in the Argument (NMCCA-CONT-005)")
    }
  }
  cmarker.render(body, raw-typst: false, smart-punctuation: true)

  signature-block(meta)
  certificate(meta)
}
