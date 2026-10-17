// Complaint for the United States District Court for the District of Alaska (akd).
// Rules: D. Alaska Local Civil Rule 7.5(a) (double-spaced; margins of at least 1 inch, footers included;
// a page number and a footer with the case name and number on every page of a multi-page document;
// at least 13-point proportionally spaced font), 7.5(b) (first-page layout: attorney block, court title,
// case number with the judge's initials, caption, document title), 7.5(c) (signature page), 8.1(a)
// (statute under the title), 8.1(b) (jurisdictional statement at the start of the body), 10.1 (form of
// pleadings: 7.5 and 8.1). Fed. R. Civ. P. 8(a) and 10(a)-(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // L.R. 7.5(a)(1)(D): proportionally spaced; vendored in fonts/
#let type-size = 13pt                   // L.R. 7.5(a)(1)(D): at least 13-point
#let body-leading = 1.35em              // L.R. 7.5(a)(1)(A): double-spaced. Measured at 13 pt: single line 17.0 pt, double 34.5 pt (README.md)
#let single-leading = 0em              // single spacing: the line pitch is the font line height (17.0 pt at 13 pt)
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let margins = 1in                      // L.R. 7.5(a)(1)(B): at least 1 inch on all sides, footer included
#let footer-size = 13pt                 // L.R. 7.5(a)(1)(D): the footer is part of the document; same size as the text
#let caption-left = 3.4in               // width of the party column of the caption
#let title-gap = 1.5em                  // space above and below a heading or the document title

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("akd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A required frontmatter field; a missing one fails the build with its name.
#let need(meta, k) = {
  if k not in meta { panic("akd-complaint: the sample frontmatter needs `" + k + "`") }
  meta.at(k)
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Heading numbers: level 1 is a Roman numeral (I., II., ...); deeper levels are unnumbered.
#let heading-num(..nums) = {
  let v = nums.pos()
  if v.len() == 1 { numbering("I.", v.at(0)) } else { none }
}

/// Lettered list items (a), (b), ... for the prayer for relief and other lists.
#let lettered(..nums) = "(" + str.from-unicode(96 + nums.pos().first()) + ")"

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Footer on every page: page number, then the case name and the case number (L.R. 7.5(a)(1)(C)).
#let running-footer(meta) = context {
  let loc = here()
  set text(size: footer-size)
  align(center)[
    #numbering(loc.page-numbering(), ..counter(page).get())
    #v(0.2em)
    #need(meta, "footer_title"), Case No. #need(meta, "case_number")
  ]
}

/// Counsel block, upper left, single-spaced (L.R. 7.5(b)(1)(A)): name, bar number, firm, address,
/// telephone, e-mail, then the party the attorney represents (L.R. 7.5(b)(1)(C)).
#let counsel-block(lines) = block(width: 100%, above: 0pt, below: 0pt)[
  #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  #for l in lines [#inl(l)\ ]
]

/// Court title, centered, one line per entry (L.R. 7.5(b)(2)).
#let court-title(lines) = block(width: 100%, above: 0pt, below: 0pt)[
  #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  #align(center)[#for l in lines [#strong[#upper(l)]\ ]]
]

/// Caption: parties on the left, closed by a rule on the right and bottom; the case number (with the
/// judge's initials, L.R. 7.5(b)(3)(B)) on the right, beside the parties.
#let caption(meta) = {
  let sides = need(meta, "caption")
  let left = []
  for s in sides {
    for n in s.names { left += inl(n) + linebreak() }
    left += v(0.4em)
    left += align(right, [#s.designation])
    left += v(0.8em)
  }
  block(width: 100%, above: 1.2em, below: 0pt)[
    #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    #grid(
      columns: (caption-left, 1fr),
      column-gutter: 0.6em,
      block(width: 100%, stroke: (right: 0.7pt, bottom: 0.7pt), inset: (right: 0.6em, bottom: 0.6em), left),
      block(width: 100%, inset: (left: 0.4em, top: 0.2em), [Case No. #need(meta, "case_number")]),
    )
  ]
}

/// Document title, centered and bold, with the statute under it (L.R. 8.1(a)) and an optional
/// oral-argument legend (L.R. 7.1(f)).
#let doc-title(meta) = block(width: 100%, above: title-gap, below: title-gap)[
  #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  #align(center)[#strong(upper(need(meta, "title")))]
  #if "statute" in meta [#align(center)[(#meta.statute)]]
  #if meta.at("oral_argument", default: false) [#align(center)[#strong[Oral Argument Requested]]]
]

/// The cover block: attorney block, court title, caption and title (L.R. 7.5(b)).
#let cover(meta) = {
  counsel-block(need(meta, "counsel"))
  v(0.8in)
  court-title(need(meta, "court"))
  v(0.3in)
  caption(meta)
  doc-title(meta)
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Split the markdown body into blank-line-separated chunks. Footnote definitions are collected
/// first and attached to each chunk that cites them, because cmarker needs the definition in the
/// same source.
#let split-body(body) = {
  let chunks = body.replace("\r\n", "\n").split("\n\n").map(c => c.trim()).filter(c => c != "")
  let defs = (:)
  let rest = ()
  for c in chunks {
    let m = c.match(regex("^\\[\\^([^\\]]+)\\]:"))
    if m != none { defs.insert(m.captures.at(0), c) } else { rest.push(c) }
  }
  (rest, defs)
}

/// The markdown source for one chunk, with the footnote definitions it cites appended.
#let chunk-source(c, defs) = {
  let extra = ()
  for m in c.matches(regex("\\[\\^([^\\]]+)\\]")) {
    let k = m.captures.at(0)
    if k in defs and defs.at(k) not in extra { extra.push(defs.at(k)) }
  }
  c + "\n\n" + extra.join("\n\n")
}

/// Render the body. A chunk is a heading (starts with #), a list (starts with a number and a dot, or
/// a bullet), a block quotation (starts with >) or a paragraph; paragraphs are numbered 1, 2, ...
/// (Fed. R. Civ. P. 10(b)). Headings and lists are not numbered.
#let render-body(body) = {
  let (chunks, defs) = split-body(body)
  counter("para").update(0)
  for c in chunks {
    if c.starts-with("#") or c.starts-with(">") or c.match(regex("^(\\d+\\.|[-*+]) ")) != none {
      cmarker.render(chunk-source(c, defs), raw-typst: false, smart-punctuation: true)
    } else {
      counter("para").step()
      block(width: 100%, above: 0pt, below: 0pt)[
        #h(para-indent)
        #context counter("para").display("1.") #h(0.25em)
        #cmarker.render(chunk-source(c, defs), raw-typst: false, smart-punctuation: true)
      ]
    }
  }
}

/// Lead-in paragraph under the title, unnumbered (the opening sentence of the pleading).
#let lead-in(meta) = if "opening" in meta {
  block(width: 100%, above: 0pt, below: 0pt)[#h(para-indent) #inl(meta.opening)]
}

/// Date line and signature block (L.R. 7.5(c)(1)-(2)), single-spaced, set in the right half of the page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, above: title-gap, below: 0pt, breakable: false)[
    #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    #if "date" in meta [#h(para-indent) #inl(meta.date)\ ]
    #v(0.8em)
    #pad(left: 2.5in)[
      #strong(sig.firm)\
      #if "role" in sig [#inl(sig.role)\ ]
      #v(1em)
      /s/ #sig.signer\
      #sig.signer\
      #if "bar" in sig [#sig.bar]
    ]
  ]
}

/// Verification page (the plaintiff's verification of the factual allegations), when the sample has one.
#let verification(meta) = if "verification" in meta {
  let v-meta = meta.verification
  pagebreak(weak: true)
  align(center)[#strong(upper(v-meta.heading))]
  v(title-gap)
  block(width: 100%, above: 0pt, below: 0pt)[#h(para-indent) #inl(v-meta.text)]
  if "date" in v-meta [#v(title-gap) #h(para-indent) #inl(v-meta.date)]
  v(2.4em)
  pad(left: 3in)[
    #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    #line(length: 3in, stroke: 0.5pt)
    #v-meta.signer
  ]
}

/// Jury demand under the body, when the sample asks for one (Fed. R. Civ. P. 38(b)).
#let jury-demand(meta) = if meta.at("jury_demand", default: false) {
  block(width: 100%, above: title-gap, below: 0pt)[
    #align(center)[#strong[DEMAND FOR JURY TRIAL]]
    #v(0.5em)
    #h(para-indent) Plaintiff demands a trial by jury on all issues so triable.
  ]
}

// ---------------------------------------------------------------------------
// The pleading
// ---------------------------------------------------------------------------

#let akd-complaint(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "case_number", "footer_title", "caption", "counsel", "title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",                       // L.R. 7.5(a)(2)(A): letter size, white
    margin: margins,
    footer: running-footer(meta),
    numbering: "1",
  )
  set document(
    title: need(meta, "title") + ", Case No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(leading: body-leading, spacing: 0pt, justify: false)
  set heading(numbering: heading-num)
  set enum(numbering: lettered)              // prayer items are lettered (a), (b), ...
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)
  show quote: it => block(width: 100%, inset: (left: 0.5in, right: 0.5in), above: 0.6em, below: 0.9em)[
    #set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    #it.body
  ]
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    if it.level == 1 {
      block(width: 100%, above: title-gap, below: title-gap, sticky: true)[
        #align(center)[#strong(upper([#lab #it.body]))]
      ]
    } else {
      block(width: 100%, above: title-gap, below: title-gap, sticky: true)[
        #align(center)[#strong(it.body)]
      ]
    }
  }

  cover(meta)
  lead-in(meta)
  render-body(body)
  jury-demand(meta)
  signature-block(meta)
  verification(meta)
}
