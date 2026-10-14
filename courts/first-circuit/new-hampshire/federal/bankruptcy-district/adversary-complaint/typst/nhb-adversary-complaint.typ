// Adversary complaint for the U.S. Bankruptcy Court, District of New Hampshire (nhb).
// Rules: Fed. R. Bankr. P. 7001 (adversary proceedings), 7008 (general pleading: jurisdiction and consent
// to final orders), 7010 (caption must substantially conform to Official Form 416D; Fed. R. Civ. P. 10
// otherwise applies, so paragraphs are numbered), 9004(b) (caption contents); D.N.H. LBR 9004-1 (chapter,
// judge initials, BNH number after signature), LBR 7003-1 (cover sheet, a separate attachment), LBR 9004-2.
// See ../README.md for the rule text, dates, and the known gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // vendored in fonts/; no NH rule sets a typeface (README.md, gap 1)
#let type-size = 12pt                   // no NH or federal minimum found for the body; 12 pt is the working standard
#let body-leading = 1.65em              // double spacing: about 27.6 pt line pitch at 12 pt (2 x 13.8 pt, the Word convention for 12 pt Times)
#let single-leading = 0.5em             // counsel block, caption and signature: single spaced
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let page-margin = 1in                  // letter paper, one-inch margins (no NH rule found; common practice)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nhb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, bold) in names, citations and text.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// The bankruptcy caption: the debtor, the chapter and the case number with the judge's initials (LBR 9004-1(a), (b)).
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

/// The adversary caption: parties, the "v." between them, and the adversary number (Official Form 416D).
#let adversary-caption(meta) = {
  let a = meta.adversary
  grid(
    columns: (1fr, 1fr),
    column-gutter: 0pt,
    block(
      width: 100%,
      stroke: (right: 0.5pt, bottom: 0.5pt),
      inset: (right: 10pt, bottom: 8pt, top: 2pt),
    )[
      #set par(leading: single-leading)
      #for (i, p) in a.parties.enumerate() {
        if i > 0 { [v.] ; v(6pt) }
        stack(dir: ttb, spacing: 3pt, ..p.names.map(n => strong(n)))
        align(right)[#p.designation]
        v(4pt)
      }
    ],
    block(inset: (left: 18pt, top: 2pt))[
      #set par(leading: single-leading)
      Adv. Pro. No. #if a.number == "" [#box(width: 1.3in, height: 0.9em, stroke: (bottom: 0.5pt))] else [#a.number]
    ],
  )
}

/// Caption block: court title, bankruptcy caption, adversary caption, the document title.
#let caption(meta) = {
  set par(leading: single-leading)
  align(center, stack(dir: ttb, spacing: 3pt, ..meta.court.map(l => strong(l))))
  v(18pt)
  bankruptcy-caption(meta)
  v(10pt)
  adversary-caption(meta)
  v(18pt)
  align(center, strong(meta.title))
  v(12pt)
}

/// Signature block (single spaced, right half of the page). The date sits at the left.
#let signature(meta) = {
  let s = meta.signature
  block(sticky: true, width: 100%)[
    #set par(leading: single-leading)
    #v(12pt)
    Date: #meta.date
    #v(12pt)
    #pad(left: 3.25in)[
      #stack(dir: ttb, spacing: 3pt, ..s.intro.map(l => [#l]))
      #v(24pt)
      #s.signer
      #v(2pt)
      #stack(dir: ttb, spacing: 3pt, ..s.lines.map(l => [#l]))
    ]
  ]
}

/// Body: `#` headings are centered bold caps (sections), `##` headings are centered bold (sub-sections),
/// every other chunk is a paragraph. Paragraphs are numbered unless their section is listed in
/// `unnumbered` (Fed. R. Civ. P. 10(b)).
#let body(src, unnumbered) = {
  let chunks = src.split("\n\n").map(s => s.trim()).filter(s => s != "")
  let last = chunks.len() - 1
  let n = 0
  let numbered = true
  // the last paragraph stays whole and on the same page as the signature block
  let wrap(stick, content) = if stick { block(sticky: true, breakable: false, width: 100%)[#content] } else { content }
  for (i, c) in chunks.enumerate() {
    if c.starts-with("## ") {
      block(sticky: true, width: 100%)[#align(center, strong(c.slice(3)))]
    } else if c.starts-with("# ") {
      let h = c.slice(2)
      numbered = not unnumbered.contains(h)
      block(sticky: true, width: 100%)[#v(6pt) #align(center, strong(h))]
    } else if c.match(regex("^\\([A-Z]\\) ")) != none {
      // lettered sub-items of a numbered paragraph are not numbered themselves; WHEREFORE paragraphs are not numbered in the filing
      pad(left: 1in)[#inl(c)]
      parbreak()
    } else if numbered and not c.starts-with("WHEREFORE") {
      n += 1
      wrap(i == last, [#h(para-indent) #n. #inl(c)])
      parbreak()
    } else {
      wrap(i == last, [#h(para-indent) #inl(c)])
      parbreak()
    }
  }
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------
#let nhb-adversary-complaint(meta, src) = {
  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: "1",
    footer: context align(center, counter(page).display()),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, justify: false)

  caption(meta)
  body(src, meta.at("unnumbered", default: ()))
  signature(meta)
}
