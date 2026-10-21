// Court of Appeals of the State of Nevada: motion and supporting papers (motion-brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the Nevada Rules of
// Appellate Procedure (NRAP) cited next to it. The type size is also declared in the court's eval.yaml.
// No coordinates measured off any filed motion, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // NRAP 32(a)(5)(A): Times New Roman is named; Liberation Serif is its metric-compatible substitute (docs/FONTS.md).
#let type-size = 14pt                      // NRAP 32(a)(5)(A) (NEVAPP-FORM-004, NEVAPP-MOT-007): proportional type of 14 points or larger.
#let body-leading = 1.65em                 // NRAP 32(a)(4) (NEVAPP-FORM-003): double spaced. With typst's default line box this gives a
                                           // baseline pitch of about 32.3 pt = 2 x the 1.15 em single line of this face at 14 pt.
#let single-leading = 0.45em               // NRAP 32(a)(4) excludes headings, footnotes and block quotations: single-spaced.
#let page-margin = (top: 1in, bottom: 1.1in, left: 1in, right: 1in)  // NRAP 32(a)(4) (NEVAPP-FORM-002): at least one inch on all sides. The bottom is 0.1 in deeper so 14 pt footnote descenders stay inside the 1 in line.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre (style; exemplars do the same).
#let court-name = "THE COURT OF APPEALS OF THE STATE OF NEVADA"  // NRAP 27(d)(1)(B) (NEVAPP-MOT-006): name of the court on the caption.
#let word-count-text(n) = [This motion contains #n words and complies with the word limit of NRAP 27(d)(2)(A).]  // NRAP 27(d)(2)(C) (NEVAPP-MOT-005): certificate of word count when the motion relies on it.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nevapp-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("nevapp-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Counsel group: names then the lines beneath, single-spaced, centred (NRAP 27(d)(1)(B) caption block).
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  align(center)[
    #for n in g.at("names", default: ()) [ #inl(n) \ ]
    #for l in g.at("lines", default: ()) [ #inl(l) \ ]
  ]
  v(0.9em)
}

/// Signers of the signature block: "/s/" and the typed name, underlined,
/// with the typed name again below the underline; counsel lines follow.
#let signers(sig) = {
  if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
}

#let signer-entry(s) = {
  underline[/s/ #s.name] + linebreak()
  [#s.name]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

#let signature-block(sig, first-only: false) = {
  let all = signers(sig)
  let list = if first-only { (all.first(),) } else { all }
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if "firm" in sig {
      if type(sig.firm) == str [ #strong(sig.firm) #v(0.8em) ] else [
        #for l in sig.firm [ #strong(l) \ ]
        #v(0.8em)
      ]
    }
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
/// the authority in the body. A show rule on that string drops a marker after each occurrence;
/// the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<nevapp-toa>]

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
  let pages = query(<nevapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: true)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let nevapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // NRAP 32(a)(4) (NEVAPP-FORM-006): pages are numbered at the bottom. The caption page is not numbered;
  // the body restarts at 1 (the exemplars do the same).
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left). The author types the section numbers.
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented, single-spaced (NRAP 32(a)(4)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: same size and typeface as the text (NRAP 32(a)(5)(B)), single-spaced (NRAP 32(a)(4)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Caption page (NRAP 27(d)(1)(B), NEVAPP-MOT-006; NRAP 32(a)(2) layout by convention) ----
  // The upper right quadrant is left clear for the court's file stamp (NRAP 27(d)(1)(B)).
  page(numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[#text(weight: "bold")[#court-name]]
    #v(0.5in)
    #grid(columns: (3.3in, 1fr), column-gutter: 0.3in,
      block(width: 100%, inset: (top: 0.3em, bottom: 0.4em, right: 0.3em), stroke: (right: 0.75pt + black, bottom: 0.75pt + black))[
        #set par(leading: single-leading, first-line-indent: 0pt)
        #inl(need(meta, "case_title"))
      ],
      {
        set par(leading: single-leading, first-line-indent: 0pt)
        v(0.3em)
        h(0.3in)
        [Case No. #inl(need(meta, "case_number"))]
      },
    )
    #v(0.7in)
    #align(center)[#text(weight: "bold", inl(need(meta, "brief_title")))]
    #v(0.5in)
    #for g in need(meta, "counsel") { counsel-group(g) }
  ]

  // ---- Table of contents (only when the filing has one) ----
  if meta.at("toc", default: false) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (only when the metadata registers authorities) ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body: numbered from 1 ----
  counter(page).update(1)
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Date, word-count certificate (NRAP 27(d)(2)(C), only when a count is stated), signature block ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: 0pt)[Dated: #inl(meta.date).] }
    #v(0.4em)
    #if "word_count" in meta {
      par(first-line-indent: (amount: para-indent, all: true))[#word-count-text(meta.word_count)]
      v(0.4em)
    }
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of service (NRAP 25(d)(1); NEVAPP-ELEC-004) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1)[#svc.at("heading", default: "Certificate of Service")]
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #for l in r [ #inl(l) \ ]
      ])
    }
    if "closing" in svc { par(inl(svc.closing)) }
    v(0.4em)
    signature-block(svc.at("signature", default: need(meta, "signature")), first-only: svc.at("first_signer_only", default: true))
  }
}
