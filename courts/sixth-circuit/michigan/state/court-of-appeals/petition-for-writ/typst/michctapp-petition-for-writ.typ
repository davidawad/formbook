// Michigan Court of Appeals (michctapp): complaint for an original action (MCR 7.206(D)).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next
// to it (Michigan Court Rules, Chapter 7, MCR 7.212, "Updated with MSC Order(s) Effective on
// September 1, 2026", https://www.courts.michigan.gov/siteassets/rules-instructions-administrative-orders/michigan-court-rules/court-rules-book-ch-7-responsive-html5.zip/Court_Rules_Book_Ch_7/Court_Rules_Chapter_7/Court_Rules_Chapter_7.htm ;
// see ../../rules.md). No case-specific text, no coordinates measured off any filed brief, no
// forced line breaks. The markdown body is rendered by cmarker; the metadata is the YAML
// frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // Times New Roman first; Liberation Serif is the metric-compatible fallback (docs/FONTS.md).
#let type-size = 12pt                      // MCR 7.212(B)(5): 12-point font; MCR 1.109(D)(1): 12 or 13 point body text.
// Typst's line pitch is leading + 0.69 em for this face (measured), so a single line (1.15 em, the
// face's single spacing) needs leading 0.46 em, and 1.5 lines (1.725 em) needs leading 1.035 em.
#let body-leading = 1.035em                // MCR 7.212(B)(5): 1.5-line-spaced text.
#let single-leading = 0.46em               // MCR 7.212(B)(5): quotations and footnotes may be single-spaced.
#let page-margin = 1in                     // MCR 7.212(B)(5): at least one-inch page margins.
#let para-indent = 0.5in
#let toc-depth = 2
#let sig-indent = 3.0in

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("michctapp-petition-for-writ: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("michctapp-petition-for-writ: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: names, then the designation.
#let caption-side(side) = {
  set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
  for n in side.names [ #inl(n) \ ]
  emph(side.designation)
}

/// Counsel group: names (bold) then the lines beneath, single-spaced.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.lines [ #inl(l) \ ]
}

/// Signers of the signature block. Each signer: "/s/" and the typed name, underlined, with the
/// typed name again below, then bar number and contact lines.
#let signers(sig) = {
  if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
}

#let signer-entry(s) = {
  underline[/s/ #emph(s.name)] + linebreak()
  [#s.name]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

#let signature-block(sig, first-only: false) = {
  let all = signers(sig)
  let list = if first-only { (all.first(),) } else { all }
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "firm" in sig [ #strong(sig.firm) #v(0.8em) ]
    #for (i, s) in list.enumerate() {
      if i > 0 { v(0.9em) }
      signer-entry(s)
    }
    #if sig.at("lines", default: ()).len() > 0 {
      v(0.6em)
      for l in sig.lines [ #inl(l) \ ]
    }
  ])
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of
/// the authority in the body (e.g. the volume and reporter). A show rule on that string drops a
/// marker after each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<michctapp-toa>]

#let mark-authorities(meta, content) = {
  let out = content
  for group in meta.at("authorities", default: ()) {
    for e in group.entries {
      if "find" in e {
        let key = e.find
        out = {
          show key: it => it + toa-marker(key)
          out
        }
      }
    }
  }
  out
}

#let toa-pages(key) = context {
  let pages = query(<michctapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  align(center, text(weight: "bold")[TABLE OF AUTHORITIES])
  v(0.6em)
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.6em, sticky: true, text(weight: "bold", group.heading))
    for e in group.entries {
      block(above: 0.6em, below: 0.6em, breakable: false)[
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let michctapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 is a principal point (MCR 7.212(C)(7): capitals or boldface, left, hanging);
  // level 3 is a sub-point (bold italic, left).
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 1em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 0.8em, below: 0.6em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented, single-spaced (MCR 7.212(B)(5) exclusion).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 12 pt, single-spaced (MCR 7.212(B)(5) exclusion); citations count toward the TOA.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover (MCR 1.109(D)(1)(b): court, case number, parties, counsel) ----
  page(numbering: none)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[STATE OF MICHIGAN] \
      #text(weight: "bold")[IN THE COURT OF APPEALS]
    ]
    #v(0.5in)
    #grid(
      columns: (1fr, 2.3in),
      gutter: 0.2in,
      [
        #for (i, side) in meta.caption.enumerate() {
          if i > 0 { v(0.3em); [v]; v(0.6em) }
          caption-side(side)
          v(0.6em)
        }
      ],
      [
        #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
        Court of Appeals No. #need(meta, "case_number") \
        #if "trial_court_case" in meta [ #inl(meta.trial_court_case) ]
      ],
    )
    #v(0.4in)
    #align(center)[
      #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
      #if "oral_argument" in meta [ \ #v(0.3em) #text(weight: "bold", upper(meta.oral_argument)) ]
      #if "subtitle" in meta [ \ #v(0.3em) #text(weight: "bold", upper(meta.subtitle)) ]
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
      grid(
        columns: (1fr, 1fr),
        gutter: 0.3in,
        ..need(meta, "counsel").map(g => counsel-group(g)),
      )
    }
  ]

  // ---- Table of contents (MCR 7.212(G) reply briefs; convention, exemplars) ----
  if meta.at("toc", default: true) {
    page(numbering: "i", number-align: center + bottom)[
      #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.6em, below: 0.6em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (MCR 7.212(C)(3) convention; reply briefs in exemplars) ----
  if "authorities" in meta {
    page(numbering: "i", number-align: center + bottom, authorities-table(meta))
  }

  // ---- Body: pages numbered from 1 (the cover and front matter are not body pages) ----
  pagebreak(weak: true)
  set page(numbering: "1", number-align: center + bottom)
  counter(page).update(1)
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block, then the MCR 7.212(B)(3) word-count statement ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #if "date" in meta [ DATED: #inl(meta.date) #v(0.4em) ]
    #pad(left: sig-indent)[ Respectfully submitted, ]
    #v(0.4em)
    #signature-block(need(meta, "signature"))
    #if "word_count" in meta [
      #v(0.6em)
      #par(first-line-indent: 0pt)[This brief contains #meta.word_count countable words under MCR 7.212(B)(2)-(3).]
    ]
  ]

  // ---- Certificate of service (MCR 7.206 and 7.212(A)(1)(b) service proof) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    align(center, text(weight: "bold")[CERTIFICATE OF SERVICE])
    v(0.4em)
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #for l in r [ #inl(l) \ ]
      ])
    }
    if "closing" in svc { par(inl(svc.closing)) }
    v(0.4em)
    signature-block(need(meta, "signature"), first-only: svc.at("first_signer_only", default: true))
  }
}
