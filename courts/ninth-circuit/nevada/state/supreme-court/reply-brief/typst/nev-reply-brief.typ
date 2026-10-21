// Supreme Court of Nevada briefs (nev): appellant's reply brief, filed under NRAP 28(c) and 32.
//
// Content-agnostic. Every number is a named parameter below and traces to the Nevada Rules of Appellate Procedure
// cited next to it (rules.md, IDs NEV-FORM-*, NEV-COVER-*, NEV-ORDER-*, NEV-LEN-*, NEV-CERT-*); no coordinates
// measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the
// sample (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // NRAP 32(a)(5)(A) lists Times New Roman among the proportionally spaced faces; Liberation Serif is its metric-compatible substitute (docs/FONTS.md).
#let type-size = 14pt                      // NRAP 32(a)(5)(B) and eval.yaml (NEV-FORM-004): 14-point or larger; footnotes the same size.
#let body-leading = 1.65em                 // NRAP 32(a)(4) (NEV-FORM-003): double spaced. With typst's default line box this gives a
                                           // baseline pitch of about 32.3 pt = 2 x the 1.15 em single line of this face at 14 pt.
#let single-leading = 0.45em               // NRAP 32(a)(4) allows single spacing for headings, footnotes and quotations of more than two lines.
#let page-margin = (top: 1in, bottom: 1.1in, left: 1in, right: 1in)  // NRAP 32(a)(4) (NEV-FORM-002): at least one inch on all sides. The bottom is 0.1 in deeper so 14 pt footnote descenders stay inside the 1 in line (DEF-FORM-002).
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                    // signature block starts right of centre (style; exemplars do the same).

// NRAP 32(a)(9)(A) (NEV-CERT-001): the certificate of compliance states the formatting, typeface and type-style
// compliance, the word count the filer relies on (NRAP 32(a)(7)), the NRAP 28(e) record-citation undertaking, and
// the reader's sanction acknowledgment. The text follows the filed exemplars; the court's form was not retrieved.
#let compliance-certificate(words) = {
  set par(first-line-indent: (amount: para-indent, all: true), leading: body-leading, spacing: body-leading)
  par[I hereby certify that this brief complies with the formatting requirements of NRAP 32(a)(4), the typeface requirements of NRAP 32(a)(5), and the type style requirements of NRAP 32(a)(6) because this brief has been prepared in a proportionally spaced typeface using #font-family.at(0) in size #str(type-size.pt()) font.]
  par[I further certify that this brief complies with the page- or type-volume limitations of NRAP 32(a)(7) because, excluding the parts of the brief exempted by NRAP 32(a)(7)(C), it contains #words words.]
  par[Finally, I hereby certify that I have read this appellate brief, and to the best of my knowledge, information, and belief, it is not frivolous or interposed for any improper purpose. I further certify that this brief complies with all applicable Nevada Rules of Appellate Procedure, in particular NRAP 28(e)(1), which requires every assertion in the brief regarding matters in the record to be supported by a reference to the page and volume number, if any, of the transcript or appendix where the matter relied on is to be found. I understand that I may be subject to sanctions in the event that the accompanying brief is not in conformity with the requirements of the Nevada Rules of Appellate Procedure.]
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nev-reply-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("nev-reply-brief: missing required metadata field `" + key + "`") }
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

/// Signers of the signature block: "/s/" and the typed name, underlined,
/// with the typed name again below the underline; counsel lines (bar number, address, phone, e-mail) follow.
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
/// the authority in the body (e.g. the reporter volume and page, or a case name). A show rule on that
/// string drops a marker after each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<nev-toa>]

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
  let pages = query(<nev-toa>)
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
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)]) #h(4pt) #if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") }
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let nev-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // NRAP 32(a)(4) (NEV-FORM-006): front pages (cover, tables) lowercase Roman, the cover unnumbered;
  // from the statement of the case on, Arabic. A reply brief starts its Arabic count at the Introduction.
  set page(paper: "us-letter", margin: page-margin, numbering: none, number-align: center + bottom)
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

  // Block quotations: indented, single-spaced (NRAP 32(a)(4)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: the same size as the text (NRAP 32(a)(5)), single-spaced (NRAP 32(a)(4)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (NRAP 32(a)(2)(A)-(E); NEV-COVER-001, -002) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[IN THE SUPREME COURT OF THE STATE OF NEVADA] \
      #v(0.3in)
      #text(weight: "bold")[#need(meta, "case_number")]
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
      grid(columns: (1fr, 1fr), column-gutter: 0.4in, row-gutter: 0.6em,
        ..need(meta, "counsel").map(g => counsel-group(g)),
      )
    }
  ]

  // ---- Table of contents (NRAP 28(a)(2) as applied to replies by NRAP 28(c); NEV-ORDER-004) ----
  if meta.at("toc", default: true) {
    page(numbering: "i", number-align: center + bottom)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, it)
      #outline(title: none, depth: toc-depth, indent: 1.5em)
    ]
  }

  // ---- Table of authorities ----
  if "authorities" in meta {
    page(numbering: "i", number-align: center + bottom, authorities-table(meta))
  }

  // ---- Body: Arabic page numbers from the first page of the Introduction ----
  set page(numbering: "1", number-align: center + bottom)
  counter(page).update(1)
  mark-authorities(meta, cmarker.render(body, raw-typst: false, smart-punctuation: true))

  // ---- Date and signature after the Conclusion (NRAP 25(a)(5)) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of compliance (NRAP 32(a)(9)(A); NEV-CERT-001 to -003) ----
  pagebreak(weak: true)
  heading(level: 1, outlined: false)[Certificate of Compliance]
  compliance-certificate(need(meta, "word_count"))
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of service (NEV-ELEC-004) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1, outlined: false)[#svc.at("heading", default: "Certificate of Service")]
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
