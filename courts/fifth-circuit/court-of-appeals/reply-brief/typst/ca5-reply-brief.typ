// U.S. Court of Appeals for the Fifth Circuit: reply brief (FRAP 28(c)).
//
// Rule-driven and content-agnostic. Requirement IDs (CA5-...) refer to ../README.md, which
// cites the court's brief checklist and FRAP 28, 32 and 25. No case-specific text, no coordinates
// measured off any filed brief, no forced line breaks. The markdown body is rendered by cmarker;
// the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"          // CA5-FORM-005: proportional serif. Vendored in /fonts.
#let type-size = 14pt                      // CA5-FORM-005: 14 point or larger for text.
#let footnote-size = 12pt                  // CA5-FORM-005: 12 point or larger for footnotes.
#let body-leading = 1.55em                 // CA5-FORM-004: double spaced; this leading gives about
                                           // a 2.2 x type size baseline pitch (ca9 tuning, checked).
#let single-leading = 0.5em               // quotations, footnotes, headings, TOC/TOA, certificates.
#let page-margin = 1in                     // CA5-FORM-003: 1 inch on all sides.
#let para-indent = 0.5in
#let passim-threshold = 7                  // an authority cited on this many pages or more: "passim"
#let word-limit = 6500                     // CA5-LEN-002: reply brief, FRAP 32(a)(7)(B)(ii) (half of 13,000).
#let front-titles = (
  "Certificate of Interested Persons",     // CA5-CONT-001 (checklist 1(a); 5th Cir. R. 28.2.1): before the TOC
  "Statement Regarding Oral Argument",     // CA5-CONT-002 (checklist 1(b); 5th Cir. R. 28.2.3): before the TOC
)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Plain text of a piece of content, for comparisons only.
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ca5-reply-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// 6211 -> "6,211"
#let group-digits(n) = {
  let s = str(n)
  let out = ""
  for (i, c) in s.clusters().enumerate() {
    if i > 0 and calc.rem(s.len() - i, 3) == 0 { out += "," }
    out += c
  }
  out
}

/// Word count of markdown source, whitespace-delimited like a word processor.
/// Markup characters are removed first; links keep their text.
#let count-words(md) = {
  let s = md
  s = s.replace(regex("<!--[\\s\\S]*?-->"), " ")
  s = s.replace(regex("(?m)^\\[\\^[^\\]]+\\]:"), " ")      // footnote definition labels
  s = s.replace(regex("\\[\\^[^\\]]+\\]"), "")             // footnote references
  // (typst's string replacement has no $1: a function returns the captured text)
  let keep(m) = m.captures.at(0)
  s = s.replace(regex("\\[([^\\]]*)\\]\\([^)]*\\)"), keep)  // links keep their text
  s = s.replace(regex("(?m)^#{1,6}[ \t]+"), "")
  s = s.replace(regex("(?m)^>[ \t]?"), "")
  s = s.replace(regex("(?m)^[ \t]*([-*+]|[0-9]+[.)])[ \t]+"), "")   // list markers are not words
  s = s.replace(regex("\\\\(.)"), keep)                    // backslash escapes
  s = s.replace(regex("[*]"), "")
  s = s.replace(regex("(^|[\\s(\\[\u{201C}\"])_"), keep)
  s = s.replace(regex("_([\\s.,;:)\\]\u{201D}\"!?]|$)"), keep)
  s.split(regex("\\s+")).filter(w => w != "").len()
}

/// Split the markdown body into sections at each level-1 heading. Each section is
/// (title, md) with md starting with its own "# " line.
#let split-sections(body) = {
  let parts = ("\n" + body).split("\n# ").slice(1)
  parts.map(p => (title: p.split("\n").first().trim(), md: "# " + p))
}

// ---------------------------------------------------------------------------
// Headings: numbering scheme (CA5-CONT-010)
// ---------------------------------------------------------------------------

/// True when the level-1 section that contains `loc` is the Argument.
#let in-argument(loc) = {
  let tops = query(selector(heading.where(level: 1)).before(loc, inclusive: true))
  tops.len() > 0 and lower(plain(tops.last().body)).trim() == "argument"
}

/// Printed label of a numbered heading, e.g. "I.", "A.", "1.", "a.".
/// Argument: I. / A. / 1. / a.   Elsewhere: A. / 1. / a. / (1)
/// A reply brief's point headings are lettered directly under the Argument (level 3), as in the
/// filed exemplar; the level-2 Roman point is available for briefs that use it.
#let heading-label(h) = {
  let loc = h.location()
  let c = counter(heading).at(loc)
  let n = c.at(h.level - 1, default: 1)
  if in-argument(loc) {
    if h.level == 2 { numbering("I.", n) }
    else if h.level == 3 { numbering("A.", n) }
    else if h.level == 4 { numbering("1.", n) }
    else if h.level == 5 { numbering("a.", n) }
    else { panic("ca5-reply-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("ca5-reply-brief: headings deeper than level 5 are not supported") }
  }
}

// ---------------------------------------------------------------------------
// Blocks
// ---------------------------------------------------------------------------

/// Cover (CA5-CONT-003, 5th Cir. checklist 3(a)): case number, court, case title, nature of the
/// proceeding and court below, brief title, counsel. The cover is one page; the spacing is the
/// only thing that adapts. The colour (gray for a reply, checklist 3(c)) applies to paper copies only.
#let cover(meta) = {
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  align(center)[
    #text(size: type-size)[No. #meta.case_number]
    #v(0.25in)
    In the United States Court of Appeals for the Fifth Circuit
    #v(0.25in)
    #for (i, side) in meta.caption.enumerate() {
      for n in side.names { v(0.1em); inl(n) }
      v(0.2em)
      side.designation
      v(0.6em)
      if i < meta.caption.len() - 1 [v.]
      v(0.6em)
    }
    #v(0.1in)
    #meta.proceeding
    #v(0.25in)
    #strong[#meta.brief_title]
    #v(1fr)
    #for g in meta.counsel {
      for n in g.names { v(0.1em); inl(n) }
      for l in g.lines { v(0.02em); inl(l) }
      v(0.5em)
    }
    #v(0.1in)
    #meta.at("date", default: none)
  ]
}

/// Signer lines (CA5-CONT-006): "/s/ Name", the name, and the firm/title/contact lines.
#let signer-block(sig) = block(breakable: false)[
  #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  #pad(left: 3in)[
    /s/ #sig.signer
    #v(0.5em)
    #sig.signer
    #for l in sig.lines { v(0.02em); inl(l) }
  ]
]

/// The closing signature after the Conclusion: date and "Respectfully submitted," (CA5-CONT-006).
#let closing-signature(meta) = block(breakable: false)[
  #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  #v(0.4in)
  #if meta.at("date", default: none) != none [Dated: #meta.date]
  #v(0.4em)
  #pad(left: 3in)[Respectfully submitted,]
  #v(0.6em)
  #signer-block(meta.signature)
]

/// Table of contents: every level-1 to level-4 heading of the body, with its printed label and
/// the body page it starts on (CA5-CONT-004). Built from the headings, never typed in.
#let toc-page() = context {
  let hs = query(heading).filter(h => plain(h.body).trim() not in front-titles)
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  strong[TABLE OF CONTENTS]
  v(0.4in)
  for h in hs {
    let pg = counter(page).at(h.location()).first()
    let label = if h.level >= 2 { heading-label(h) + " " } else { "" }
    let ind = (h.level - 1) * 0.4in
    pad(left: ind, bottom: 0.7em)[
      #label#h.body #box(width: 1fr, repeat[ .]) #pg
    ]
  }
}

/// Table of authorities: from the `authorities:` registry, grouped (cases; then statutes and other
/// authorities), each with the body pages it is cited on. Cited on 7 or more pages: "passim".
#let toa-page(auth) = context {
  let cites = query(<toa-cite>)
  let pages-for(key) = {
    let ps = ()
    for c in cites {
      if c.value.key == key {
        let p = counter(page).at(c.location()).first()
        if p not in ps { ps.push(p) }
      }
    }
    ps.sorted()
  }
  let entry(key) = {
    let a = auth.at(key)
    let ps = pages-for(key)
    if ps.len() == 0 { return none }
    let pstr = if ps.len() >= passim-threshold { "passim" } else { ps.map(str).join(", ") }
    block(breakable: false, below: 0.8em)[
      #if a.at("name", default: "") != "" [#emph(a.name), ]
      #a.cite #box(width: 1fr, repeat[ .]) #pstr
    ]
  }
  let keys-of(kinds) = auth.keys().filter(k => auth.at(k).kind in kinds)
  set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
  strong[TABLE OF AUTHORITIES]
  v(0.4in)
  let case-keys = keys-of(("case",)).sorted(key: k => lower(auth.at(k).name))
  let other-keys = keys-of(("constitution", "statute", "regulation", "rule", "other"))
  if case-keys.len() > 0 {
    [Cases:]
    v(0.3em)
    for k in case-keys { entry(k) }
  }
  if other-keys.len() > 0 {
    [Statutes & Other Authorities:]
    v(0.3em)
    for k in other-keys.sorted(key: k => lower(auth.at(k).cite)) { entry(k) }
  }
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca5-reply-brief(meta, body) = {
  let auth = meta.at("authorities", default: (:))
  let sections = split-sections(body)
  let front = sections.filter(s => s.title in front-titles)
  let certs = sections.filter(s => s.title.starts-with("Certificate of") and s.title not in front-titles)
  let main = sections.filter(s => s.title not in front-titles and s.title not in certs.map(c => c.title))

  // CA5-LEN-002 and CA5-CONT-007: the word count is computed from the body markdown (the main
  // sections and their footnotes; not the cover, tables, oral argument statement, signature or
  // certificates; FRAP 32(f)). A reply over the limit does not build.
  let main-md = main.map(s => s.md).join("\n")
  let n-words = count-words(main-md)
  if n-words > word-limit {
    panic("ca5-reply-brief: the reply has " + str(n-words) + " words; the limit is " + str(word-limit) + " (FRAP 32(a)(7)(B)(ii))")
  }
  let words = group-digits(n-words)
  let cert-md = certs.map(s => s.md.replace("{{words}}", words))

  set page(paper: "us-letter", margin: page-margin, numbering: none)
  // Typst steps the heading counter only when numbering is set; the labels are drawn by the show rules below.
  set heading(numbering: "1")
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)

  // ---- rules for the parts of the markdown ----
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      if key not in auth {
        panic("ca5-reply-brief: citation key `" + key + "` is not in authorities:")
      }
      [#metadata((key: key))<toa-cite>#it.body]
    } else {
      it
    }
  }

  show footnote.entry: it => {
    set text(size: footnote-size)
    set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    it
  }

  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in)[
    #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
    #it.body
  ]

  show heading.where(level: 1): it => context {
    block(width: 100%, above: 1.1em, below: 0.9em, sticky: true)[
      #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
      #align(center, strong(upper(it.body)))
    ]
  }

  show heading.where(level: 2): it => context {
    let label = heading-label(it)
    block(width: 100%, above: 1.1em, below: 0.9em, sticky: true)[
      #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
      #grid(columns: (0.5in, 1fr), column-gutter: 0.1in, label, strong(it.body))
    ]
  }

  show heading.where(level: 3): it => context {
    let label = heading-label(it)
    block(above: 1em, below: 0.8em, sticky: true)[
      #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
      #pad(left: 0.5in)[#grid(columns: (0.5in, 1fr), column-gutter: 0.1in, label, strong(it.body))]
    ]
  }

  show heading.where(level: 4): it => context {
    let label = heading-label(it)
    block(above: 1em, below: 0.8em, sticky: true)[
      #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
      #pad(left: 1in)[#grid(columns: (0.5in, 1fr), column-gutter: 0.1in, label, it.body)]
    ]
  }

  show heading.where(level: 5): it => context {
    let label = heading-label(it)
    block(above: 1em, below: 0.8em, sticky: true)[
      #set par(leading: single-leading, spacing: single-leading, first-line-indent: 0pt)
      #pad(left: 1.5in)[#grid(columns: (0.5in, 1fr), column-gutter: 0.1in, label, it.body)]
    ]
  }

  // ---- cover (unnumbered) ----
  cover(meta)

  // ---- front matter (roman numerals) ----
  pagebreak()
  set page(numbering: "i")
  counter(page).update(1)
  for s in front {
    cmarker.render(s.md, raw-typst: false, smart-punctuation: true)
    if s.title == "Certificate of Interested Persons" { signer-block(meta.signature) }
    pagebreak(weak: true)
  }
  toc-page()
  pagebreak(weak: true)
  toa-page(auth)
  pagebreak(weak: true)

  // ---- body (arabic numerals from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  cmarker.render(main-md, raw-typst: false, smart-punctuation: true)
  closing-signature(meta)

  // ---- certificates: each on its own page, numbered in the body sequence ----
  for c in cert-md {
    pagebreak(weak: true)
    cmarker.render(c, raw-typst: false, smart-punctuation: true)
    signer-block(meta.signature)
  }
}
