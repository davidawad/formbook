// Florida Fourth District Court of Appeal (fladistctapp4): reply brief (see the doc-type name in the README).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited next to
// it: Fla. R. App. P. 9.045 (form of documents, as amended eff. July 1, 2026) and 9.210 (2020 text:
// 8.5 x 11, margins no less than 1 inch); see ../../rules.md (FLADISTCTAPP4-FORM-001 to -010,
// BRIEF-001). No case-specific text, no coordinates measured off any filed brief, no forced line
// breaks. The markdown body is rendered by cmarker; the cover, caption, signature and certificates
// come from the YAML frontmatter of the sample (schema: ../README.md).

#import "@preview/cmarker:0.1.10"
#import "../../../../../../../lib/typst/tables.typ": leader-row

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Bonum"    // Rule 9.045(b): Arial 14 or Bookman Old Style 14; Bookman is named here (docs/FONTS.md: TeX Gyre Bonum, visual clone)
#let type-size = 14pt                   // Rule 9.045(b): 14-point computer-generated text; footnotes and quotations the same size (9.045(b))
#let body-leading = 1.65em              // Rule 9.045(b): double-spaced (baseline pitch about 2 x the single line at 14 pt)
#let single-leading = 0.35em            // Rule 9.045(b) exclusions: headings, footnotes, quotations may be single-spaced
#let page-margin = (top: 1in + 4pt, bottom: 1in + 4pt, x: 1in)  // Rule 9.210(a)(2) (2020 text): margins no less than 1 inch; 4 pt more keeps a footnote marker or descender inside the margin
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 2.25in                  // signature block starts right of centre (style; the exemplars do the same).
#let compliance-text = "I CERTIFY that pursuant to Florida Rules of Appellate Procedure 9.045(b) and 9.210(a)(2)(B), as amended, this pleading was prepared using proportionately spaced Bookman Old Style 14-point font and complies with the applicable font and word count limit requirements."  // Rule 9.045(e): certificate of compliance, immediately after the certificate of service; wording as filed.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("fladistctapp4-reply-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("fladistctapp4-reply-brief: missing required metadata field `" + key + "`") }
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

/// Signers of the signature block (Rule 9.045 sets no signature form: "/s/" and the typed name,
/// then the bar number and the e-mail addresses as filed).
#let signers(sig) = {
  if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
}

#let signer-entry(s) = {
  [/s/ #inl(s.name)]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

/// Signature block. `full: false` omits the firm, its address and the closing line (the
/// certificate of service repeats only the signer, as filed).
#let signature-block(sig, full: true) = {
  let all = signers(sig)
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
    #if full and "firm" in sig [ #strong(sig.firm) \ ]
    #if full { for l in sig.at("firm_lines", default: ()) [ #inl(l) \ ] }
    #if full and "firm" in sig [ #v(0.8em) ]
    #for (i, s) in all.enumerate() {
      if i > 0 { v(0.9em) }
      signer-entry(s)
    }
    #if full and sig.at("lines", default: ()).len() > 0 {
      v(0.6em)
      for l in sig.lines [ #inl(l) \ ]
    }
  ])
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of
/// the authority in the body (e.g. a case name or a statute number). A show rule on that string
/// drops a marker after each occurrence; the table lists the pages of the markers. An entry with
/// `pages` (e.g. "passim") prints that text instead.
#let toa-marker(key) = [#metadata(key)<fladistctapp4-toa>]

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
  let pages = query(<fladistctapp4-toa>)
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
      block(above: 0.9em, below: 0.9em, breakable: false,
        // The page reference keeps level with the entry's last line, after the leaders (DEF-TOC-001).
        leader-row(inl(e.cite), if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") },
          hang: 1.5em, dot-gap: 2pt, lead-gap: 0.25em, gutter: 4pt))
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let fladistctapp4-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // Pages numbered in Arabic numerals at the bottom (Rule 9.045 sets no numbering rule; convention per exemplars).
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a section (centred, capitals, bold);
  // level 2 and 3 are sub-headings (bold, left). Headings may be single-spaced (Rule 9.045(b)).
  show heading.where(level: 1): it => block(width: 100%, above: 1.4em, below: 1em, sticky: true)[
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
    #text(weight: "bold", it.body)
  ]

  // Block quotations: indented, single-spaced, same size (Rule 9.045(b)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), width: 100%, above: 0.8em, below: 1.2em)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: 14 pt like the text, single-spaced (Rule 9.045(b)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover: court heading, case number, caption, proceeding, title, counsel ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, strong[#for l in need(meta, "court") [#upper(l) \ ]])
    #v(0.6em)
    #align(center, strong[Case No. #need(meta, "case_number")])
    #v(1.2em)
    #caption-side(meta.caption.at(0))
    #v(0.2in)
    #align(center)[v.]
    #v(0.2in)
    #caption-side(meta.caption.at(1))
    #align(center, "_______________________________/")
    #v(0.3in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #if "proceeding" in meta { inl(meta.proceeding) }
      #if "lower_court_case" in meta [ \ #inl(meta.lower_court_case) ]
    ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: sig-indent - 0.5in, {
        for g in need(meta, "counsel") { counsel-group(g) }
      })
    }
  ]

  // ---- Table of contents (the form of a Rule 9.045 document; the exemplars carry one) ----
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

  // ---- Date and signature block ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
    #if "signature_intro" in meta { par(first-line-indent: 0pt, inl(meta.signature_intro)) }
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of service (Rule 2.516, as filed) ----
  if "service" in meta {
    let svc = meta.service
    pagebreak(weak: true)
    heading(level: 1)[Certificate of Service]
    for p in svc.at("paragraphs", default: ()) { par(inl(p)) }
    if "closing" in svc { par(inl(svc.closing)) }
    v(0.4em)
    signature-block(need(meta, "signature"), full: false)

    // ---- Certificate of compliance (Rule 9.045(e)): immediately after the certificate of service ----
    block(breakable: false)[
      #heading(level: 1)[Certificate of Compliance]
      #par(inl(compliance-text))
      #v(0.4em)
      #signature-block(need(meta, "signature"), full: false)
    ]
  }
}
