// Court of Appeals of the State of Washington: motion for discretionary review (petition-for-discretionary-review, RAP 13.5).
//
// Content-agnostic. Every number is a named parameter below and traces to the Washington Rules of
// Appellate Procedure (RAP) or General Rules (GR) cited next to it. The type size and margins are
// also declared in the court's eval.yaml. No coordinates measured off any filed motion, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // RAP 18.17(a)(2) (WASHCTAPP-FORM-004): a 14-point serif equivalent to Times New Roman. Liberation Serif is its metric-compatible vendored face (docs/FONTS.md). The exemplar's Century Schoolbook is not a Times-equivalent face.
#let type-size = 14pt                      // RAP 18.17(a)(2) (WASHCTAPP-FORM-004): 14 point for all text, footnotes and block quotations.
#let body-leading = 1.65em                 // RAP 18.17(a)(2) (WASHCTAPP-FORM-005): double spaced. With typst's default line box this gives a baseline pitch of about 2 x the single line of this face at 14 pt.
#let single-leading = 0.45em               // Footnotes and block quotations may be single spaced (WASHCTAPP-FORM-005).
#let cover-leading = 0.2em                 // Title page and counsel block: set solid (about one line of the face), so the cover fits one page (DEF-COVER-001).
#let page-margin = (top: 1.5in, bottom: 1.6in, left: 2in, right: 1.5in)  // RAP 18.17(a)(1) (WASHCTAPP-FORM-002): 2 in left; 1.5 in right, top and bottom. The bottom is 0.1 in deeper so 14 pt footnote descenders stay inside the margin.
#let para-indent = 0.5in
#let toc-depth = 4
#let sig-indent = 2.0in                    // signature block starts at the middle of the text block; the longest e-mail line must still fit the right margin.
#let court-name = "THE COURT OF APPEALS OF THE STATE OF WASHINGTON"  // Form 5 (WASHCTAPP-COVER-001): the court and division on the title page.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("washctapp-petition-for-discretionary-review: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("washctapp-petition-for-discretionary-review: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Caption text: a string, or a list of lines (one per line).
#let caption-lines(v) = {
  if type(v) == array { v.map(l => [#inl(l) \ ]).join() } else { inl(v) }
}

/// Counsel group: names then the lines beneath, single-spaced, set in the right half of the title page.
#let counsel-group(g) = {
  set par(leading: cover-leading, spacing: 0pt, first-line-indent: 0pt)
  pad(left: 1.75in)[
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
  underline[/s/ #s.name]
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
#let toa-marker(key) = [#metadata(key)<washctapp-toa>]

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
  let pages = query(<washctapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: false)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      // The cite, then a line of leaders ending in the page list. The page list never shares a line
      // with a wrapped cite, so it cannot break off on its own.
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #inl(e.cite) \
        #box(width: 100%)[#box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }]
      ]
    }
  }
}

// Front matter (title page unnumbered, then roman numerals from the contents page, as in the exemplars).
#let front-numbering(..args) = numbering("i", args.pos().at(0) - 1)

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let washctapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // RAP 18.17(a)(1) and RAP 10.3(a)(1): pages are numbered at the bottom. The title page is not numbered;
  // the body restarts at 1 (the exemplars do the same).
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // levels 2 to 4 are sub-headings (bold, left, indented one step per level). The author types the numbers.
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
    #pad(left: 0.25in, text(weight: "bold", it.body))
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #pad(left: 0.5in, text(weight: "bold", it.body))
  ]

  // Block quotations: indented, single-spaced (RAP 18.17(a)(2), WASHCTAPP-FORM-005).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: same size and typeface as the text (RAP 18.17(a)(2)), single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Title page (RAP 10.3(a)(1), Form 5; WASHCTAPP-COVER-001, COVER-003) ----
  page(numbering: none)[
    #set par(leading: cover-leading, first-line-indent: 0pt)
    #align(center)[#text(weight: "bold")[#court-name]]
    #if "division" in meta [ #align(center)[#text(weight: "bold")[DIVISION #need(meta, "division")]] ]
    #v(0.25in)
    #grid(columns: (3.9in, 1fr), column-gutter: 0.3in,
      block(width: 100%, inset: (top: 0.3em, bottom: 0.4em, right: 0.3em), stroke: (right: 0.75pt + black, bottom: 0.75pt + black))[
        #set par(leading: cover-leading, first-line-indent: 0pt)
        #caption-lines(need(meta, "case_title"))
      ],
      {
        set par(leading: cover-leading, first-line-indent: 0pt)
        v(0.3em)
        h(0.3in)
        [No. #inl(need(meta, "case_number"))]
      },
    )
    #if "on_appeal" in meta [ #v(0.25in) #caption-lines(meta.on_appeal) ]
    #v(0.4in)
    #align(center)[#text(weight: "bold", inl(need(meta, "brief_title")))]
    #v(0.3in)
    #for g in need(meta, "counsel") { counsel-group(g) }
  ]

  // ---- Table of contents (only when the filing has one) ----
  if meta.at("toc", default: false) {
    page(numbering: front-numbering)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (only when the metadata registers authorities) ----
  if "authorities" in meta {
    page(numbering: front-numbering, authorities-table(meta))
  }

  // ---- Body: numbered from 1 ----
  counter(page).update(1)
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Date, word-count certificate (RAP 18.17(b)), signature block ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #par(first-line-indent: 0pt, inl(need(meta, "date")))
    #v(0.4em)
    #par(first-line-indent: (amount: para-indent, all: true))[
      Counsel certifies this motion complies with RAP 18.17 and contains #need(meta, "word_count") words, excluding the parts exempted by RAP 18.17(c).
    ]
    #v(0.4em)
    #par(first-line-indent: (amount: para-indent, all: true))[Respectfully submitted,]
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Declaration of filing and service (RAP 17.4; WASHCTAPP-MOT-001, MOT-006) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1, outlined: false)[#svc.at("heading", default: "Declaration of Service")]
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #for l in r [ #inl(l) \ ]
      ])
    }
    // The closing line and the signature stay together on one page.
    block(width: 100%, breakable: false)[
      #if "closing" in svc { par(first-line-indent: 0pt, inl(svc.closing)) }
      #v(0.4em)
      #signature-block(svc.at("signature", default: need(meta, "signature")), first-only: svc.at("first_signer_only", default: true))
    ]
  }
}
