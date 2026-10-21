// Court of Appeals of Oregon (orctapp): amicus curiae brief (ORAP 8.15: the form is that of a party's brief, ORAP 5.05(3)).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule
// cited next to it (Oregon Rules of Appellate Procedure, ORAP 2019 compilation effective
// 2019-04-15, https://www.courts.oregon.gov/rules/ORAP/ORAP%20Effective%202019-04-15.pdf;
// see ../../rules.md, rows ORCTAPP-FORM-002, -003, -007, -008). No case-specific text,
// no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the
// sample (schema: the input contract in skills/formbook/reference/input-contract.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // ORCTAPP-FORM-003 (ORAP 5.05(3)(b)(ii)): proportionally spaced serif. Liberation Serif is the metric-compatible substitute (docs/FONTS.md).
#let type-size = 14pt                      // ORCTAPP-FORM-003 (ORAP 5.05(3)(b)(ii); 5.05(1)(d)(ii)): not smaller than 14 point, text and footnotes.
#let body-leading = 1.65em                 // ORCTAPP-FORM-006 (ORAP 5.05(3)(b)(iv)): double-spaced. With typst's default line box this gives a
                                           // baseline pitch of about 2 x the 1.15 em single line of this face at 14 pt.
#let single-leading = 0.45em               // ORCTAPP-FORM-006 excludes quotations and headings: single-spaced (double space above and below a quotation).
#let margin-top = 0.75in                   // ORCTAPP-FORM-002 (ORAP 5.05(3)(a)(ii)): top 3/4 inch.
#let margin-bottom = 0.75in                // ORCTAPP-FORM-002 (ORAP 5.05(3)(a)(ii)): bottom 3/4 inch.
#let margin-inside = 1.25in                // ORCTAPP-FORM-002 (ORAP 5.05(3)(a)(ii)): inside 1 1/4 inch. Single-sided print: inside is the left edge.
#let margin-outside = 1in                  // ORCTAPP-FORM-002 (ORAP 5.05(3)(a)(ii)): outside 1 inch. Single-sided print: outside is the right edge.
#let page-number-ascent = 0.375in          // ORCTAPP-FORM-007 (ORAP 5.05(3)(c)): page numbers at the top, within 3/8 inch of the top edge.
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
  if m == none { panic("orctapp-amicus-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("orctapp-amicus-brief: missing required metadata field `" + key + "`") }
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

/// Signers of the signature block. The "/s/" and the typed name, underlined,
/// with the typed name again below the underline; then the bar number and contact lines.
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
    #if "closing" in sig [ #inl(sig.closing) #v(0.8em) ]
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
/// the authority in the body. A show rule on that string drops a marker after each occurrence;
/// the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<orctapp-toa>]

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
  let pages = query(<orctapp-toa>)
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

#let orctapp-amicus-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // ORCTAPP-FORM-001, -002, -007: US letter; margins as above; consecutive page numbers at the top.
  // The cover is page 1 and carries no number.
  set page(
    paper: "us-letter",
    margin: (top: margin-top, bottom: margin-bottom, left: margin-inside, right: margin-outside),
    header-ascent: page-number-ascent,
    header: context {
      if counter(page).get().first() > 1 { align(right, counter(page).display()) }
    },
    footer: none,
    numbering: "1",
  )
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

  // Block quotations: indented, single-spaced, with a double space above and below (ORCTAPP-FORM-006).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 14 pt like the text (ORCTAPP-FORM-003), single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(bottom: 0.25em, mark-authorities(meta, it))  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (ORCTAPP-FORM-008, ORCTAPP-FORM-013, ORCTAPP-FORM-010) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[IN THE COURT OF APPEALS] \
      #text(weight: "bold")[FOR THE STATE OF OREGON] \
      #v(0.3in)
      #if "case_number" in meta [ CA #meta.case_number ]
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
      #if "trial_court_case" in meta [ \ #inl(meta.trial_court_case) ]
    ]
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
    #v(0.3in)
    #align(right)[#set par(leading: single-leading, first-line-indent: 0pt)
      #inl(need(meta, "filed_month_year"))]
  ]

  // ---- Table of contents (ORAP 5.35 arrangement; ORCTAPP-ORDER-001) ----
  if meta.at("toc", default: true) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities (when the frontmatter registers authorities) ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body ----
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block (ORCTAPP-FORM-009): name and signature of the author, firm, party ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of compliance (ORCTAPP-LEN-006): wording is filer-supplied metadata ----
  if "compliance" in meta {
    let cc = meta.compliance
    pagebreak(weak: true)
    heading(level: 1)[#inl(cc.at("heading", default: "Certificate of Compliance"))]
    for p in cc.at("paragraphs", default: ()) { par(inl(p)) }
    if "date" in cc { par(inl(cc.date)) }
    v(0.4em)
    signature-block(need(meta, "signature"), first-only: true)
  }

  // ---- Certificate of filing and service (ORAP 16.45, ORCTAPP-AMICUS-004) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1)[#inl(svc.at("heading", default: "Certificate of Filing and Service"))]
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
