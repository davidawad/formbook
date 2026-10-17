// Motion with supporting memorandum (or the memorandum alone) for the U.S. Bankruptcy Court, District of
// New Hampshire (nhb), filed in a bankruptcy case (a contested matter, not an adversary proceeding).
// Rules: Fed. R. Bankr. P. 9013 (a motion must state its grounds with particularity), 9004(b) (caption:
// court, title, case number and a brief designation of the document); D.N.H. LBR 7102(a) (caption shows the
// character of the paper and the party's relationship to the estate; chapter and judge's initials after the
// case number), LBR 7102(b)(2) (memorandum page limits: 15 pages nondispositive, 25 pages dispositive),
// LBR 9004-1 (BNH number after the signature), LBR 7103 (certificate of service). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; no NH rule sets a typeface (README.md, gap 1)
#let type-size = 12pt                   // no NH or federal minimum found for the body; 12 pt is the working standard
#let body-leading = 1.645em             // double spacing: about 27.6 pt line pitch at 12 pt (2 x 13.8 pt, the Word convention for 12 pt Times)
#let single-leading = 0.5em             // counsel block, caption, signature, footnotes: single spaced
#let para-indent = 0.5in                // first-line indent of body paragraphs (memoranda are not numbered)
#let page-margin = 1in                  // letter paper, one-inch margins (no NH rule found; common practice)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nhb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, bold, footnote references) in text.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// The bankruptcy caption: the debtor, the chapter and the case number with the judge's initials (LBR 7102(a)(2), (3)).
#let bankruptcy-caption(meta) = {
  let b = meta.bankruptcy
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0pt,
    block(
      width: 100%,
      stroke: (right: 0.5pt, bottom: 0.5pt),
      inset: (right: 10pt, bottom: 8pt, top: 2pt),
    )[
      #set par(leading: single-leading)
      In re:

      #v(6pt)
      #strong(b.debtor)

      #align(right)[#b.designation]
    ],
    block(inset: (left: 18pt, top: 2pt))[
      #set par(leading: single-leading)
      #b.chapter

      #v(6pt)
      Case No. #b.case_number
    ],
  )
}

/// Caption block: court title, bankruptcy caption, the document title.
#let caption(meta) = {
  set par(leading: single-leading)
  align(center, stack(dir: ttb, spacing: 3pt, ..meta.court.map(l => strong(l))))
  v(18pt)
  bankruptcy-caption(meta)
  v(18pt)
  align(center, strong(meta.title))
  v(12pt)
}

/// A signature block: the date (left), then the firm or party, the signer and the counsel lines (right half).
#let signature-block(date-label, date, intro, signer, lines) = block(sticky: true, width: 100%)[
  #set par(leading: single-leading)
  #v(12pt)
  #date-label #date
  #v(12pt)
  #pad(left: 3.25in)[
    #stack(dir: ttb, spacing: 3pt, ..intro.map(l => [#l]))
    #v(24pt)
    #signer
    #v(2pt)
    #stack(dir: ttb, spacing: 3pt, ..lines.map(l => [#l]))
  ]
]

/// Footnotes: cmarker does not render markdown footnotes, so `[^n]` references in a paragraph become typst
/// footnotes, with the text of the `[^n]: ...` definition (`notes`, keyed by n).
#let with-footnotes(c, notes) = {
  // cmarker drops leading spaces, so a space after a marker is put back as typst content
  let seg(s) = if s.starts-with(" ") { [ ] + inl(s.slice(1)) } else { inl(s) }
  let out = []
  let pos = 0
  for m in c.matches(regex("\\[\\^([0-9]+)\\]")) {
    out += seg(c.slice(pos, m.start))
    out += footnote(inl(notes.at(m.captures.at(0))))
    pos = m.end
  }
  out + seg(c.slice(pos))
}

/// Body: `#` headings are centered bold caps (sections), `##` headings are bold, left, with a hanging
/// indent (lettered sub-sections). Every other chunk is an unnumbered, first-line-indented paragraph.
/// Footnote definitions (`[^n]: ...`) are not body text; they are read into `notes`.
#let body(src, notes) = {
  let chunks = src.split("\n\n").map(s => s.trim()).filter(s => s != "" and not s.starts-with("[^"))
  let last = chunks.len() - 1
  for (i, c) in chunks.enumerate() {
    if c.starts-with("### ") {
      block(sticky: true, width: 100%)[#strong(emph(c.slice(4)))]
    } else if c.starts-with("> ") {
      // block quotation: single spaced, indented both sides, no first-line indent
      block(width: 100%, inset: (left: 0.5in, right: 0.5in), below: 12pt)[
        #set par(leading: single-leading, spacing: 12pt)
        #with-footnotes(c.slice(2), notes)
      ]
    } else if c.starts-with("## ") {
      block(sticky: true, width: 100%)[
        #set par(hanging-indent: 0.5in)
        #strong(c.slice(3))
      ]
    } else if c.starts-with("# ") {
      block(sticky: true, width: 100%)[#v(6pt) #align(center, strong(c.slice(2)))]
    } else if i == last {
      // the last paragraph stays whole and on the same page as the signature block
      block(sticky: true, breakable: false, width: 100%)[#h(para-indent) #with-footnotes(c, notes)]
      parbreak()
    } else {
      [#h(para-indent) #with-footnotes(c, notes)]
      parbreak()
    }
  }
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------
#let nhb-motion-brief(meta, src) = {
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    footer: context align(center, counter(page).display()),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, justify: false)
  set footnote.entry(separator: line(length: 1.5in, stroke: 0.5pt))
  show footnote.entry: set text(size: 10pt)
  show footnote.entry: set par(leading: single-leading)

  let notes = (:)
  for m in src.matches(regex("(?m)^\\[\\^([0-9]+)\\]: (.*)$")) {
    notes.insert(m.captures.at(0), m.captures.at(1))
  }

  caption(meta)
  body(src, notes)
  let s = meta.signature
  signature-block(
    meta.at("date_label", default: "Date:"),
    meta.date,
    s.intro,
    s.signer,
    s.lines,
  )
  let c = meta.at("certificate", default: none)
  if c != none {
    v(24pt)
    block(sticky: true, width: 100%)[#align(center, strong(c.title))]
    v(6pt)
    for p in c.paragraphs {
      [#h(para-indent) #inl(p)]
      parbreak()
    }
    signature-block(
      c.at("date_label", default: "Date:"),
      c.date,
      (),
      c.signer,
      c.lines,
    )
  }
}
