// Florida First District Court of Appeal (fladistctapp1): filing template shared by the brief,
// motion and petition doc types. Content-agnostic: every number is a named parameter below and
// traces to the rule cited beside it (Florida Rules of Appellate Procedure; see ../rules.md).
// No case-specific text, no coordinates measured off any filed document, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the input.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "Liberation Sans"            // Rule 9.045(b) names Arial 14-point; Liberation Sans is the vendored metric-compatible Arial (docs/FONTS.md)
#let type-size = 14pt                            // Rule 9.045(b): 14-point, footnotes and quotations in the same size as the text
#let body-leading = 1.55em                        // Rule 9.045(b): double-spaced body text (extra leading added to a single line)
#let single-leading = 0.46em                     // footnotes, block quotations, headings, captions and cover are single-spaced (Rule 9.045(b)); 0.46 em on the cap-height line is a 1.15 em pitch
#let page-margin = 1in                           // Rule 9.210(a)(2): margins no less than 1 inch
#let page-top-margin = 1.1in                     // a little more than 1 inch so a superscript on the first line stays inside the margin
#let para-indent = 0.5in
#let toc-depth = 3
#let sig-indent = 3.2in                          // signature block starts right of centre

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("fladistctapp1 template: the input must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("fladistctapp1 template: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em, first-line-indent: 0pt)
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

/// Signers of the signature block (Rule 9.045 signature by counsel): "/s/" and the typed name.
#let signers(sig) = {
  if "signers" in sig { sig.signers } else { ((name: need(sig, "signer"), lines: ()),) }
}

#let signer-entry(s) = {
  [/s/ #s.name]
  for l in s.at("lines", default: ()) { linebreak() + inl(l) }
}

#let signature-block(sig, first-only: false) = {
  let all = signers(sig)
  let list = if first-only { (all.first(),) } else { all }
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt)
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
/// the authority in the body. A show rule on that string drops a marker after each occurrence; the
/// table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<fl-toa>]

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
  let pages = query(<fl-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else if pages.len() > 6 { [passim] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: true)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #grid(columns: (1fr, 2.6in), column-gutter: 0.2in, inl(e.cite), pad(right: 4pt, align(right, if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") })))
      ]
    }
  }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let fladistctapp1-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  set page(paper: "us-letter", margin: (top: page-top-margin, bottom: page-margin, left: page-margin, right: page-margin), numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false)
  set heading(numbering: none)

  // Heading levels in the markdown body: level 1 is a centred bold capitals heading; level 2 and 3
  // are bold sub-headings (single-spaced, Rule 9.045(b): headings may be single-spaced).
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

  // Block quotations: indented on both sides, single-spaced, same size as the text (Rule 9.045(b)).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #it.body
  ]
  // Footnotes: same size as the text (Rule 9.045(b)), single-spaced.
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)
  }

  // ---- Cover (Rule 9.210(a)(4)) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center)[
      #text(weight: "bold")[IN THE DISTRICT COURT OF APPEAL OF THE STATE OF FLORIDA] \
      #text(weight: "bold")[FIRST DISTRICT]
      #v(0.3in)
      #text(weight: "bold")[Case No. #need(meta, "case_number")]
    ]
    #v(0.3in)
    #caption-side(need(meta, "caption").at(0))
    #v(0.2in)
    #align(center)[v.]
    #v(0.2in)
    #caption-side(meta.caption.at(1))
    #if "lower_tribunal" in meta [
      #v(0.3in)
      #align(center)[
        #set par(leading: single-leading, first-line-indent: 0pt)
        #for l in meta.lower_tribunal [ #inl(l) \ ]
      ]
    ]
    #v(1fr) #v(single-leading)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", upper(inl(need(meta, "brief_title"))))
    ]
    #v(1fr) #v(single-leading)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      pad(left: sig-indent, {
        for g in need(meta, "counsel") { counsel-group(g) }
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

  // ---- Date and signature block ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: (amount: para-indent, all: true), inl(meta.date)) }
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
    signature-block(need(meta, "signature"), first-only: svc.at("first_signer_only", default: true))
  }

  // ---- Certificate of compliance (Rule 9.045(e)): immediately after the certificate of service ----
  {
    heading(level: 1)[Certificate of Compliance]
    let word-count = meta.at("word_count", default: none)
    par(first-line-indent: (amount: para-indent, all: true))[
      #if word-count != none [
        I certify that this document complies with the font requirements of Florida Rule of Appellate Procedure 9.045(b) (Arial 14-point) and with the word count limit of the applicable rule, and that it contains #inl(str(word-count)) words, excluding the caption, cover page, table of contents, table of citations, certificate of compliance, certificate of service and signature block, as Rule 9.045(e) provides.
      ] else [
        I certify that this document complies with the font requirements of Florida Rule of Appellate Procedure 9.045(b) (Arial 14-point) and with the word count limit of the applicable rule, and that it contains #box(width: 0.6in, line(length: 100%)) words, excluding the caption, cover page, table of contents, table of citations, certificate of compliance, certificate of service and signature block, as Rule 9.045(e) provides.
      ]
    ]
    v(0.4em)
    signature-block(need(meta, "signature"), first-only: true)
  }
}
