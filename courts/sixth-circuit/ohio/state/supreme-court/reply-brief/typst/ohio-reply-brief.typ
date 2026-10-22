// Ohio Supreme Court (ohio): reply brief of an appellant or relator (RoP 16.04; see ../../rules.md).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it
// (Rules of Practice of the Supreme Court of Ohio, effective May 1, 2025, Internet Archive capture; see
// ../../rules.md). No case-specific text, no coordinates measured off any filed brief, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the sample
// (schema: ../../rules.md, and the input contract in docs/MARKDOWN-CONTRACT.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // OHIO-FORM-003: Times New Roman declared (RoP 3.09(B)(1)(b)); Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 12pt                      // OHIO-FORM-004: at least 12-point type, all text incl. footnotes and quotations (RoP 3.09(B)(1)(b), (B)(3)).
#let body-leading = 1.65em                 // OHIO-FORM-005: double spacing (RoP 3.09(B)(3)). Typst adds about 0.69 em of line height to the leading; 1.65 em gives a baseline pitch of about 2.34 em (28 pt), double the single pitch below.
#let single-leading = 0.5em                // OHIO-FORM-005: quotations, headings, captions, footnotes, cover and counsel blocks may be single spaced (RoP 3.09(B)(3)); about 1.19 em pitch.
#let page-margin = (top: 1in + 4pt, bottom: 1in + 4pt, x: 1in)  // OHIO-FORM-002: at least one inch on all sides (RoP 3.09(B)(2)(c)); the extra 4 pt keeps descenders and superscripts inside the 1 in margin.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre (style; the filed example does the same).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohio-reply-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("ohio-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em)
    #for n in side.names [ #inl(n) \ ]
    #emph(side.designation)
  ]
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.lines [ #inl(l) \ ]
}

/// Counsel groups in two columns: the odd-numbered groups left, the even-numbered right, so a cover
/// with three counsel groups fits one page (RoP 3.07(G)).
#let counsel-columns(list) = {
  let left = list.enumerate().filter(((i, g)) => calc.rem(i, 2) == 0).map(((i, g)) => counsel-group(g))
  let right = list.enumerate().filter(((i, g)) => calc.rem(i, 2) == 1).map(((i, g)) => counsel-group(g))
  grid(columns: (1fr, 1fr), gutter: 0.3in, stack(dir: ttb, spacing: 0.8em, ..left), stack(dir: ttb, spacing: 0.8em, ..right))
}

/// Signers of the signature block. Rule: "/s/" and the typed name, underlined,
/// with the typed name again below the underline, then the counsel lines.
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

/// Table of authorities (optional). Each entry carries `find`: a string that appears in every
/// citation of the authority in the body. A show rule on that string drops a marker after each
/// occurrence; the table lists the pages where the markers fall.
#let toa-marker(key) = [#metadata(key)<ohio-toa>]

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
  let pages = query(<ohio-toa>)
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
        #grid(
          columns: (1fr, 0.6in),
          column-gutter: 0.1in,
          [#inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)])],
          align(bottom + right, if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }),
        )
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let ohio-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Cover unnumbered; front matter in roman numerals; the body restarts at 1 (RoP 3.07, 16.04 page limit).
  set page(paper: "us-letter", margin: page-margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: 0pt, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body. The author types the numbering ("I.", "A.").
  // Level 1: a section, bold, flush left. Level 2: a point heading, bold, hanging indent.
  // Level 3: bold italic.
  show heading.where(level: 1): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.0em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", it.body)
  ]

  // Block quotations: indented, single-spaced (RoP 3.09(B)(3): quoted matter may be single spaced).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 12 pt like the text (OHIO-FORM-004), single-spaced (RoP 3.09(B)(3)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (RoP 3.07(A)-(G)): court, case number, parties, the proceeding, the title, counsel ----
  page(numbering: none)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[IN THE SUPREME COURT OF OHIO] \
      #v(0.15in)
      #text(weight: "bold")[Case No. #need(meta, "case_number")]
    ]
    #v(0.15in)
    #caption-side(meta.caption.at(0))
    #v(0.1in)
    #align(center)[v.]
    #v(0.1in)
    #caption-side(meta.caption.at(1))
    #v(0.15in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #if "proceeding" in meta { inl(meta.proceeding) }
    ]
    #v(0.15in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", size: 16pt, upper(inl(need(meta, "brief_title"))))
    ]
    #v(0.3in)
    #counsel-columns(need(meta, "counsel"))
    #counter(page).update(0)  // the front matter starts at roman i on the next page
  ]

  // ---- Table of contents (optional; the filed reply has one, RoP 16.02(B)(1) as applied by 16.04) ----
  if meta.at("toc", default: false) {
    page(numbering: "i", number-align: center + bottom)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (optional; excluded from the 20-page limit, RoP 16.04(B)(1)) ----
  if "authorities" in meta {
    page(numbering: "i", number-align: center + bottom, authorities-table(meta))
  }

  // ---- Body: pages numbered from 1 ----
  pagebreak(weak: true)
  set page(numbering: "1", number-align: center + bottom)
  counter(page).update(1)
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Signature (OHIO-SIG-001: "/s/" and the typed name) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #par(first-line-indent: 0pt)[Respectfully submitted,]
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of service (RoP 3.11(B)(1)(a); OHIO-SERV-001, OHIO-SERV-002) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    align(center, text(weight: "bold")[CERTIFICATE OF SERVICE])
    v(0.5em)
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 0.5in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #for l in r [ #inl(l) \ ]
      ])
    }
    v(0.4em)
    signature-block(svc.at("signature", default: need(meta, "signature")), first-only: svc.at("first_signer_only", default: true))
  }
}
