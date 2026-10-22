// Ohio Court of Appeals (ohioctapp): opening brief (appellant's principal brief).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule
// cited next to it (Ohio Rules of Appellate Procedure, amended through July 1, 2026;
// Internet Archive capture of the Supreme Court of Ohio PDF, see ../../rules.md).
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the
// sample (schema: ../../rules.md, and the input contract in docs/MARKDOWN-CONTRACT.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // OHIOCTAPP-FORM-004: Times New Roman declared (no face is named by App.R. 19 (A)); Liberation Serif is its metric twin (docs/FONTS.md).
#let type-size = 12pt                      // OHIOCTAPP-FORM-002: at least twelve-point type, all printed matter incl. footnotes and captions (App.R. 19 (A)).
#let body-leading = 1.65em                 // OHIOCTAPP-FORM-003: double spacing. Typst adds about 0.65 em of line box to the leading; 1.65 em gives a baseline pitch of about 2.3 em, twice the single pitch below.
#let single-leading = 0.5em                // OHIOCTAPP-FORM-003: quoted matter, headings, captions, footnotes, cover and counsel blocks are single spaced (about 1.15 em pitch).
#let page-margin = (top: 1in + 4pt, bottom: 1in + 4pt, x: 1in)  // OHIOCTAPP-FORM-001: at least one inch at each side and 1 1/2 in top and bottom combined; the extra 4 pt keeps descenders and superscripts inside the 1 in margin.
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
  if m == none { panic("ohioctapp-opening-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("ohioctapp-opening-brief: missing required metadata field `" + key + "`") }
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
  v(0.6em)
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

/// Table of authorities (optional; the filed reply brief in the sample has none). Each entry
/// carries `find`: a string that appears in every citation of the authority in the body.
/// A show rule on that string drops a marker after each occurrence; the table lists the pages.
#let toa-marker(key) = [#metadata(key)<ohioctapp-toa>]

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
  let pages = query(<ohioctapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  // Six or more pages read "passim" (the Bluebook convention); a long list would wrap its last page number off the entry (DEF-TOC-001).
  if pages.len() == 0 { [--] } else if pages.len() >= 6 { [passim] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: true)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      // The citation wraps in its own column; the leaders and the page list sit in a fixed column that
      // is bottom-aligned, so the page list always ends the citation's last line (DEF-TOC-001).
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #grid(columns: (1fr, 1.2in), align: (left, bottom), column-gutter: 0pt,
          [#set par(hanging-indent: 0pt, first-line-indent: 0pt); #inl(e.cite)],
          [#set par(hanging-indent: 0pt, first-line-indent: 0pt); #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }],
        )
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let ohioctapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Page numbers at the bottom centre, the cover being page 1 (conventional; not mandated by App.R. 19).
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
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

  // Block quotations: indented, single-spaced (OHIOCTAPP-FORM-003: quoted matter is single spaced).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 12 pt like the text (OHIOCTAPP-FORM-002), single-spaced (quoted/footnote matter).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (App.R. 19 (A) (1)-(5), if separately bound) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[IN THE COURT OF APPEALS] \
      #if "district" in meta [ #text(weight: "bold", upper(inl(meta.district))) \ ]
      #text(weight: "bold")[STATE OF OHIO] \
      #v(0.3in)
      #text(weight: "bold")[Appellate Case No. #need(meta, "case_number")]
      #if "trial_court_case" in meta [ \ #text(weight: "bold")[Trial Court Case No. #inl(meta.trial_court_case)] ]
    ]
    #v(0.3in)
    #caption-side(meta.caption.at(0))
    #v(0.2in)
    #align(center)[v.]
    #v(0.2in)
    #caption-side(meta.caption.at(1))
    #v(0.3in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #if "proceeding" in meta { inl(meta.proceeding) }
    ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", size: 16pt, upper(inl(need(meta, "brief_title"))))
    ]
    #v(0.5in)
    // Counsel groups side by side (two columns), so a cover with two firms fits on one page.
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: 0.5in, grid(columns: (1fr, 1fr), column-gutter: 0.25in, ..need(meta, "counsel").map(counsel-group)))
    }
  ]

  // ---- Table of contents (App.R. 16 (A) (1) for an appellant's brief; OHIOCTAPP-CONT-001) ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (App.R. 16 (A) (2); OHIOCTAPP-CONT-001). Required: the INPUT must carry it. ----
  page(authorities-table(meta))

  // ---- Body ----
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Signature (OHIOCTAPP-CERT-001: the signature bears the certification; no separate sentence is mandated) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #par(first-line-indent: 0pt)[Respectfully submitted,]
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of service (App.R. 13 (C); OHIOCTAPP-SVC-001) ----
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
