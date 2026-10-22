// Florida Fifth District Court of Appeal (fladistctapp5): answering brief (appellee's principal brief).
//
// Rules: Fla. R. App. P. 9.045 (form of documents; as amended eff. July 1, 2026) and 9.210 (2020 text:
// 8.5 x 11, margins no less than 1 inch); see ../../rules.md (FLADISTCTAPP5-FORM-001 to -010, BRIEF-001).
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to it.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the
// sample (see the frontmatter fields the functions below read).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Bonum"      // Rule 9.045(b): Arial 14 or Bookman Old Style 14; Bookman is named here (docs/FONTS.md: TeX Gyre Bonum, visual clone).
#let type-size = 14pt                      // Rule 9.045(b): 14-point computer-generated text; footnotes and quotations the same size.
#let body-leading = 1.65em                 // Rule 9.045(b): double-spaced (baseline pitch about 2 x the single line at 14 pt).
#let single-leading = 0.45em               // Rule 9.045(b): footnotes, quotations and headings may be single-spaced.
#let page-margin = 1in                     // Rule 9.210(a)(2) (2020 text): margins no less than 1 inch.
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre (style; exemplars do the same).

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("fladistctapp5-answering-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("fladistctapp5-answering-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt, justify: false)
  for n in side.names [ #inl(n) \ ]
  pad(left: 1.5in, inl(side.designation))
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
  for n in g.names [ #strong(n) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

/// Signers of the signature block: "/s/" and the typed name, then the bar number and contact lines
/// (Rule 9.045 sets no signature form; this follows the filed Florida briefs).
#let signers(sig) = {
  if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
}

#let signer-entry(s) = {
  [/s/ #inl(s.name)]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

#let signature-block(sig) = {
  let list = signers(sig)
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
/// the authority in the body (e.g. the volume and reporter, "280 So. 2d"). A show rule on that
/// string drops a marker after each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<fladistctapp5-toa>]

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
  let pages = query(<fladistctapp5-toa>)
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
      // The page references sit in their own right-hand column, so a long list of pages never
      // wraps alone onto a line; the citation fills the left column with dot leaders to its pages.
      block(above: 0.9em, below: 0.9em, breakable: false, grid(
        columns: (1fr, auto), column-gutter: 0.3em, align: (left, right + bottom),
        [#inl(e.cite) #h(0.6em) #box(width: 1fr, repeat[.#h(0.16em)])],
        if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") },
      ))
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let fladistctapp5-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Pages numbered in Arabic numerals at the bottom; the cover is page 1 (convention per the filed exemplars; Rule 9.045 sets no numbering rule).
  set page(paper: "us-letter", margin: (x: page-margin, top: page-margin + 4pt, bottom: page-margin + 4pt), numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left).
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

  // Block quotations: indented, single-spaced (Rule 9.045(b): may be single-spaced).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 14 pt like the text, single-spaced (Rule 9.045(b): same size; may be single-spaced).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #for l in (if type(need(meta, "court")) == array { meta.court } else { (meta.court,) }) [#strong(upper(l)) \ ]
    ]
    #v(0.4in)
    #grid(columns: (3.7in, 1fr), column-gutter: 0.2in,
      [
        #caption-side(meta.caption.at(0))
        #v(0.2in)
        #align(center)[v.]
        #v(0.2in)
        #caption-side(meta.caption.at(1))
        #v(0.1em)
        #align(left)[#"____________________________________/"]
      ],
      [
        #v(1in)
        DCA CASE NO. \ #need(meta, "case_number")
        #if "lower_court_case" in meta [ #v(0.6em) L.T. CASE NO. \ #inl(meta.lower_court_case) ]
      ],
    )
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", size: 16pt, upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: sig-indent, {
        for g in need(meta, "counsel") { counsel-group(g) }
        if "phone" in meta [ #meta.phone ]
      })
    }
  ]

  // ---- Table of contents ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body ----
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Closing and signature block (Florida form: "Respectfully submitted," then the /s/ signer) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #pad(left: sig-indent)[Respectfully submitted,]
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of service ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1)[Certificate of Service]
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    for r in svc.at("recipients", default: ()) {
      block(above: 1em, below: 1em, breakable: false, pad(left: 1in)[
        #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
        #for l in r [ #inl(l) \ ]
      ])
    }
    if "closing" in svc { par(inl(svc.closing)) }
    v(0.4em)
    // The certificate of service is signed by the first signer only, with no bar number or address (as filed).
    signature-block((signers: ((name: signers(need(meta, "signature")).first().name, lines: ()),)))
  }

  // ---- Certificate of compliance (Rule 9.045(e)): immediately after the certificate of service,
  // only when the brief is word-limited and the frontmatter carries it. The wording and signer come
  // from the frontmatter (`compliance`), not from the template.
  if "compliance" in meta {
    let cc = meta.compliance
    pagebreak(weak: true)
    heading(level: 1)[Certificate of Compliance]
    par(inl(need(cc, "text")))
    v(0.4em)
    block(breakable: false, pad(left: sig-indent)[
      #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
      #signer-entry((name: need(cc, "signer"), lines: cc.at("lines", default: ())))
    ])
  }
}
