// Court of Criminal Appeals of Tennessee (tenncrimapp): answering-brief (e-filed form).
//
// Content-agnostic. Every number is a named parameter below and traces to the rule cited
// next to it (Tenn. R. App. P. 20, 27, 30 and Tenn. Sup. Ct. R. 46; see ../../rules.md).
// No case-specific text, no coordinates measured off any filed document, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata is the YAML frontmatter of the input
// (the key list is in ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Schola"       // SCT-46 3.02(3)(a): any font in the Century family; Century Schoolbook clone (docs/FONTS.md).
#let type-size = 14pt                      // SCT-46 3.02(3)(b)-(c): 14 point, footnotes included.
#let body-leading = 1.04em                 // SCT-46 3.02(2)(a): body 1.5-spaced: line pitch 1.5 x single pitch (single = line height + single-leading, measured 1.17em; see README).  
#let single-leading = 0.45em               // Single spacing for quotations, headings, captions, footnotes, TOC and TOA (paper-rule exception).
#let page-margin = 1in                     // SCT-46 3.02(2)(b): 1 inch on all four sides.
#let para-indent = 0.5in
#let toc-default = true                 // false for a motion: no table of contents or authorities (rules.md TENNCRIMAPP-SEC-010).
#let compliance-default = true   // certificate of compliance generated for briefs (SCT-46 3.02(2)(c)); not for a motion.
#let sig-indent = 3.2in                    // signature and counsel blocks start right of centre.
#let court-name = "IN THE COURT OF CRIMINAL APPEALS OF TENNESSEE"   // TENNCRIMAPP-COVER-001.

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tenncrimapp: the input must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let need(meta, key) = {
  if key not in meta { panic("tenncrimapp: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Heading numbers for argument points: level 2 "I.", level 3 "A.", level 4 "1.", level 5 "a.".
/// The level-1 section headings are unnumbered.
#let heading-number(..nums) = {
  let v = nums.pos()
  let k = v.len()
  if k == 2 { numbering("I.", v.at(1)) }
  else if k == 3 { numbering("A.", v.at(2)) }
  else if k == 4 { numbering("1.", v.at(3)) }
  else if k == 5 { numbering("a.", v.at(4)) }
  else { "" }
}

/// One caption side: centred names, then the designation.
#let caption-side(side) = {
  align(center)[
    #set par(leading: single-leading, spacing: 0.4em)
    #for n in side.names [ #inl(n) \ ]
    #emph(inl(side.designation))
  ]
}

/// Counsel group: names (bold) then the lines beneath.
#let counsel-group(g) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  for n in g.names [ #strong(inl(n)) \ ]
  for l in g.lines [ #inl(l) \ ]
  v(0.6em)
}

/// Signature block: "/s/" line, the signer's name, then any lines beneath.
#let signature-block(sig) = {
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt, justify: false)
    /s/ #inl(sig.signer) \
    #inl(sig.signer)
    #for l in sig.at("lines", default: ()) [ \ #inl(l) ]
  ])
}

/// Table of authorities. Each entry carries `find`: a string that appears in every citation of
/// the authority in the body (e.g. "182 S.W.3d"). A show rule on that string drops a marker after
/// each occurrence; the table lists the pages of the markers.
#let toa-marker(key) = [#metadata(key)<tenncrimapp-toa>]

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
  let pages = query(<tenncrimapp-toa>)
    .filter(m => m.value == key)
    .map(m => counter(page).at(m.location()).first())
    .dedup()
  if pages.len() == 0 { [--] } else { pages.map(str).join(", ") }
}

#let authorities-table(meta) = {
  heading(level: 1, outlined: true, numbering: none)[Table of Authorities]
  set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em, justify: false)
  for group in meta.authorities {
    block(above: 1.2em, below: 0.8em, sticky: true, strong(group.heading))
    for e in group.entries {
      block(above: 0.9em, below: 0.9em, breakable: false)[
        #grid(columns: (1fr, 1.4in), column-gutter: 0.4em, align: (left, bottom), [#inl(e.cite) #box(width: 1fr, repeat[.#h(2pt)])], if "find" in e { toa-pages(e.find) } else { e.at("pages", default: "") })
      ]
    }
  }
}

/// Words the filer's certificate of compliance counts: the text of the body, with markup removed
/// (citation links, footnote marks and footnote labels). Counted from the markdown, as rules.md says.
#let count-words(body) = {
  let t = body
    .replace(regex("\\(toa:[^)]*\\)"), "")
    .replace(regex("\\[\\^[^\\]]*\\]:?"), "")
  t.split(regex("\\s+")).filter(w => w.match(regex("[A-Za-z0-9]")) != none).len()
}

/// The certificate of the given type from the frontmatter, or none.
#let certificate(meta, kind) = {
  let found = meta.at("certificates", default: ()).filter(c => c.type == kind)
  if found.len() == 0 { none } else { found.at(0) }
}

// ---------------------------------------------------------------------------
// Template
// ---------------------------------------------------------------------------

#let tenncrimapp-brief(meta, body) = {
  set document(title: need(meta, "brief_title"))
  // SCT-46 3.02(5): pagination begins with page 1, which is the cover; every page carries an Arabic number at the bottom.
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center + bottom)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false, overhang: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: (amount: para-indent, all: true), justify: true)
  set heading(numbering: heading-number)

  // Level 1: a section, centred, bold, capitals. Level 2-5: argument points, numbered automatically.
  show heading.where(level: 1): it => block(width: 100%, above: 1.6em, below: 1.2em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #align(center, text(weight: "bold", upper(it.body)))
  ]
  show heading.where(level: 2): it => block(width: 100%, above: 1.2em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", context numbering(it.numbering, ..counter(heading).at(it.location())) + h(0.5in) + it.body)
  ]
  show heading.where(level: 3): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", context numbering(it.numbering, ..counter(heading).at(it.location())) + h(0.5in) + it.body)
  ]
  show heading.where(level: 4): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", context numbering(it.numbering, ..counter(heading).at(it.location())) + h(0.5in) + it.body)
  ]
  show heading.where(level: 5): it => block(width: 100%, above: 1em, below: 0.8em, sticky: true)[
    #set text(size: type-size)
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false, hanging-indent: 0.5in)
    #text(weight: "bold", style: "italic", context numbering(it.numbering, ..counter(heading).at(it.location())) + h(0.5in) + it.body)
  ]

  // Block quotations: indented, single-spaced (SCT-46 3.02(2)(a), quoted matter).
  show quote.where(block: true): it => block(inset: (left: 0.5in, right: 0.5in), above: 0.8em, below: 1.2em)[
    #set par(leading: single-leading, first-line-indent: 0pt, justify: true)
    #it.body
  ]
  // Footnote marks in the text: a little smaller, so the raised mark stays inside the 1 in top margin (DEF-FORM-002).
  show footnote: set text(size: 10pt)
  // Footnotes: at the text size and single-spaced (SCT-46 3.02(3)(c)).
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    mark-authorities(meta, it)  // citations in footnotes count toward the table of authorities
  }

  // ---- Cover (TENNCRIMAPP-COVER-001 to -005) ----
  page[
    #set par(leading: single-leading, first-line-indent: 0pt, justify: false)
    #align(center)[
      #for n in meta.at("cover_notes", default: ()) [ #text(weight: "bold")[#inl(n)] \ ]
      #text(weight: "bold")[#inl(need(meta, "case_number"))] \
      #v(0.2in)
      #text(weight: "bold")[#court-name]
      #if "court_seat" in meta [ \ #text(weight: "bold")[#inl(meta.court_seat)] ]
    ]
    #v(0.3in)
    #caption-side(need(meta, "caption").at(0))
    #v(0.2in)
    #align(center)[v.]
    #v(0.2in)
    #caption-side(need(meta, "caption").at(1))
    #v(0.3in)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #if "proceeding" in meta { inl(meta.proceeding) }
    ]
    #v(1fr)
    #align(center)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #text(weight: "bold", size: 16pt, upper(inl(need(meta, "brief_title"))))
      #if meta.at("oral_argument", default: false) [ \ #v(0.3in) #text(weight: "bold")[ORAL ARGUMENT REQUESTED] ]
    ]
    #v(1fr)
    #{
      set par(leading: single-leading, first-line-indent: 0pt)
      grid(columns: (1fr, 1fr), column-gutter: 0.3in, ..need(meta, "counsel").map(g => counsel-group(g)))
    }
  ]

  // ---- Table of contents (SCT-46 3.02; TENNCRIMAPP-SEC-002) ----
  if meta.at("toc", default: toc-default) {
    page[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #align(center, text(weight: "bold")[TABLE OF CONTENTS])
      #v(0.5em)
      #show outline.entry: it => block(above: 0.9em, below: 0.9em, breakable: false)[
        #grid(columns: (1fr, auto), column-gutter: 0.4em, align: (left, bottom),
          [#h((it.level - 1) * 1.5em) #it.prefix() #h(0.5em) #it.element.body #box(width: 1fr, repeat[.#h(2pt)])], it.page())
      ]
      #outline(title: none, depth: 3)
    ]
  }

  // ---- Table of authorities (TENNCRIMAPP-SEC-003) ----
  if "authorities" in meta {
    page(authorities-table(meta))
  }

  // ---- Body ----
  pagebreak(weak: true)
  mark-authorities(meta, cmarker.render("\n" + body, raw-typst: false, smart-punctuation: true))

  // ---- Signature block, date (TENNCRIMAPP-CERT-003) ----
  v(0.3in)
  block(width: 100%, breakable: false)[
    #if "date" in meta { par(first-line-indent: 0pt, inl("Dated: " + meta.date)) }
    #v(0.4em)
    #block(width: 100%, pad(left: sig-indent, [Respectfully submitted,]))
    #v(0.4em)
    #signature-block(need(meta, "signature"))
  ]

  // ---- Certificate of compliance (SCT-46 3.02(2)(c); TENNCRIMAPP-CERT-001) ----
  if meta.at("compliance", default: compliance-default) {
    pagebreak(weak: true)
    heading(level: 1, numbering: none)[Certificate of Compliance]
    let words = count-words(body)
    par[I certify that this brief complies with the word limit of Tenn. R. App. P. 30(e) and contains #words words, excluding the parts of the brief exempt under that rule. The count was made from the text of the brief as filed.]
    v(0.4em)
    signature-block(need(meta, "signature"))
  }

  // ---- Certificate of service (TRAP 20(e); TENNCRIMAPP-CERT-002, -004) ----
  let svc = certificate(meta, "service")
  if svc == none { panic("tenncrimapp: the frontmatter needs a `certificates` entry of type service (Tenn. R. App. P. 20(e))") }
  pagebreak(weak: true)
  heading(level: 1, numbering: none)[Certificate of Service]
  for t in svc.text.split("\n\n") [ #par(inl(t)) ]
  v(0.4em)
  block(width: 100%, breakable: false, pad(left: sig-indent)[
    #set par(leading: single-leading, first-line-indent: 0pt, spacing: 0pt, justify: false)
    #if "date" in svc [ #inl(svc.date) \ ]
    #v(0.4em)
    /s/ #inl(svc.signer) \
    #inl(svc.signer)
  ])
}
