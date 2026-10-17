// United States Bankruptcy Appellate Panel of the Sixth Circuit: reply brief (appellant's reply).
//
// Rule-driven and content-agnostic. Governing rules: Fed. R. Bankr. P. 8012, 8014, 8015, 8019;
// 6th Cir. BAP LBR 8014-1. ../README.md records the rule text, the source and the date verified,
// and the one conflict (LBR 8014-1(d) says 12-point; FRBP 8015(a)(5)(A) says 14-point, and the
// federal rule governs). No case-specific text, no coordinates measured off any filed brief,
// no forced line breaks. The body is markdown rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or is a style choice)
// ---------------------------------------------------------------------------

#let doc-type = "reply"                  // "opening", "answering" or "reply": selects the rules below
#let doc-title = "reply brief of appellant"      // FRBP 8014(c)
#let font-family = ("Times New Roman", "Liberation Serif")      // FRBP 8015(a)(5): proportionally spaced, serif; Times New Roman substitute per docs/FONTS.md
#let type-size = 14pt                      // FRBP 8015(a)(5)(A): 14-point or larger, everywhere.
#let body-leading = 1.955em                // FRBP 8015(a)(4): double-spaced. Pitch = 0.655em (Liberation Serif line box) + leading = 2.61em; single = 1.305em (calibration in ../README.md).
#let single-leading = 0.65em               // headings, block quotations, cover, TOC and TOA: single-spaced (typst default leading).
#let page-margin = 1in                     // FRBP 8015(a)(4): at least one inch on all four sides.
#let para-indent = 0.5in
#let passim-threshold = 7                  // an authority cited on this many pages or more prints "passim" (style)
#let word-limit = if doc-type == "reply" { 6500 } else { 13000 }   // FRBP 8015(a)(7)(B)(i)-(ii)
#let oral-argument-required = doc-type == "opening"                  // FRBP 8019(a); LBR 8014-1(b). The filed appellee brief (19-8005) has none, so it is optional there.
#let required-sections = if doc-type == "opening" {
  ("Statement of Jurisdiction", "Statement of the Issues", "Statement of the Case", "Summary of Argument", "Argument", "Conclusion")
} else if doc-type == "answering" {
  ("Summary of Argument", "Argument", "Conclusion")   // FRBP 8014(b): the other items need not appear
} else {
  ()                                                   // FRBP 8014(c): a reply complies with (a)(2)-(3) only
}
#let kind-order = ("case", "constitution", "statute", "regulation", "rule", "other")
#let kind-heading = (
  case: "Cases",
  constitution: "Constitutional Provisions",
  statute: "Statutes",
  regulation: "Regulations",
  rule: "Rules",
  other: "Other Authorities",
)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline or block markdown string as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Printed page label of a location, in the numbering of its own page (roman in the front matter).
#let printed-page(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("bap6-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// The body up to a line "# Addendum", and the addendum (or none).
#let split-addendum(body) = {
  let m = body.match(regex("(?m)^# Addendum\\s*$"))
  if m == none { (body, none) } else { (body.slice(0, m.start), body.slice(m.start)) }
}

/// 11622 -> "11,622"
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
/// Markup characters are removed first; links keep their text. Headings and footnotes count (FRBP 8015(g)).
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

/// Fail the build when a section the rules require is missing (FRBP 8014).
#let check-sections(main) = {
  for s in required-sections {
    if main.match(regex("(?m)^#\\s+" + s)) == none {
      panic("bap6-brief: the sample has no `# " + s + "` section, required for a " + doc-type + " brief (FRBP 8014)")
    }
  }
}

// ---------------------------------------------------------------------------
// Style: applied once to the whole document by `#show: brief-style`
// ---------------------------------------------------------------------------

#let brief-style(doc) = {
  set page(paper: "us-letter", margin: page-margin)
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)
  set heading(numbering: none)
  show heading.where(level: 1): it => block(sticky: true, above: 1.6em, below: 1.2em, width: 100%)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #align(center, text(weight: "bold", it.body))
  ]
  show heading.where(level: 2): it => block(sticky: true, above: 1.2em, below: 1em, width: 100%)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #text(weight: "bold", it.body)
  ]
  show heading.where(level: 3): it => block(sticky: true, above: 1.1em, below: 1em, width: 100%)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #pad(left: 0.5in, text(weight: "bold", it.body))
  ]
  show heading.where(level: 4): it => block(sticky: true, above: 1em, below: 1em, width: 100%)[
    #set par(leading: single-leading, first-line-indent: 0pt)
    #pad(left: 1in, text(style: "italic", it.body))
  ]
  show quote.where(block: true): it => block(above: 1em, below: 1.4em)[
    #pad(left: 0.5in, right: 0.5in)[
      #set par(leading: single-leading, first-line-indent: 0pt)
      #it.body
    ]
  ]
  doc
}

// ---------------------------------------------------------------------------
// Cover (FRBP 8015(a)(2)): case number, court, case title, nature of the proceeding,
// the brief's title naming the party, and counsel's name, address, phone and email.
// ---------------------------------------------------------------------------

#let cover(meta) = page(numbering: none)[
  #set par(leading: single-leading, first-line-indent: 0pt)
  #set align(center)
  #let lines = ()
  #let lines = lines + ([Case No. #meta.case_number],)
  #let lines = lines + ([*United States Bankruptcy Appellate Panel of the Sixth Circuit*],)
  #for side in meta.caption {
    let names = side.names.map(n => inl(n))
    lines = lines + ((stack(dir: ttb, spacing: single-leading, ..names, inl(side.designation))),)
    if side != meta.caption.last() { lines = lines + ([v.],) }
  }
  #stack(dir: ttb, spacing: 0.9em, ..lines)
  #v(1.4em)
  #inl(meta.proceeding)
  #v(1.4em)
  #text(size: 1.15em, weight: "bold", upper(meta.brief_title))
  #v(1fr)
  #for group in meta.counsel {
    let rows = group.names.map(n => inl(n)) + group.lines.map(l => inl(l))
    stack(dir: ttb, spacing: single-leading, ..rows)
    v(0.9em)
  }
  #stack(dir: ttb, spacing: single-leading, ..(meta.phone,).map(p => [#p]))
  #v(0.8em)
  #meta.at("date", default: "")
]

// ---------------------------------------------------------------------------
// Front matter
// ---------------------------------------------------------------------------

/// Table of contents: every outlined heading, with its printed page.
#let toc-section() = context {
  for head in query(heading.where(outlined: true)) {
    let indent = if head.level == 1 { 0pt } else { 1.5em * (head.level - 1) }
    block(above: 0.5em, below: 0.5em, width: 100%)[
      #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 1.5em)
      #grid(columns: (1fr, auto), column-gutter: 0.5em, [#h(indent)#head.body], [#printed-page(head.location())])
    ]
  }
}

/// Table of authorities. Each `[text](toa:KEY)` link in the body is recorded with its page (the
/// `show link` rule in `bap6-brief`); the registry in the frontmatter names each authority once.
#let toa-section(auths) = context {
  let hits = query(<toa-hit>)
  for kind in kind-order {
    let keys = auths.keys().filter(k => auths.at(k).kind == kind)
    if keys.len() == 0 { continue }
    block(sticky: true, above: 1.2em, below: 0.8em)[#text(weight: "bold", kind-heading.at(kind))]
    for k in keys.sorted(key: k => auths.at(k).at("sort", default: auths.at(k).at("name", default: auths.at(k).cite))) {
      let a = auths.at(k)
      let pgs = hits.filter(x => x.value == k).map(x => (p: x.location().page(), s: printed-page(x.location())))
      if pgs.len() == 0 { panic("bap6-brief: authority `" + k + "` is listed but never cited in the body") }
      let uniq = pgs.dedup(key: x => x.p).sorted(key: x => x.p)
      let shown = if uniq.len() >= passim-threshold { "passim" } else { uniq.map(x => x.s).join(", ") }
      let cited = if kind == "case" and "name" in a { "*" + a.name + "*, " + a.cite }
        else if "name" in a { a.name + ", " + a.cite }
        else { a.cite }
      block(width: 100%, above: 0.5em, below: 0.5em)[
        #set par(leading: single-leading, first-line-indent: 0pt, hanging-indent: 0.5in)
        #inl(cited) #box(width: 1fr, repeat[.]) #shown
      ]
    }
  }
}

/// Certificate blocks and the signature block take the same closing block.
#let signature-block(meta) = block(above: 1.6em, width: 100%, breakable: false)[
  #set par(leading: single-leading, first-line-indent: 0pt)
  #pad(left: 50%)[
    Respectfully submitted,
    #v(1.2em)
    #stack(dir: ttb, spacing: single-leading, [s/ #meta.signature.signer], ..meta.signature.lines.map(l => inl(l)))
    #v(0.8em)
    #meta.at("date", default: "")
  ]
]

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let brief(meta, md) = {
  let (main, addendum) = split-addendum(md)
  check-sections(main)
  let words = count-words(main)
  if words > word-limit {
    panic("bap6-brief: the brief has " + str(words) + " words; the limit for a " + doc-type + " brief is " + str(word-limit) + " (FRBP 8015(a)(7)(B))")
  }
  if oral-argument-required and "oral_argument" not in meta {
    panic("bap6-brief: the frontmatter needs `oral_argument` for a " + doc-type + " brief (FRBP 8019(a); LBR 8014-1(b))")
  }
  let auths = meta.at("authorities", default: (:))

  // Each citation link to toa:KEY is recorded for the table of authorities; no other links are altered.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      if key not in auths { panic("bap6-brief: link to toa:" + key + " has no entry in the authorities registry") }
      [#it.body#metadata(key)<toa-hit>]
    } else { it }
  }

  cover(meta)

  // Front matter: roman numerals, starting at i on the first page after the cover.
  set page(numbering: "i")
  counter(page).update(1)
  if "disclosure" in meta {
    heading(level: 1)[Corporate Disclosure Statement]
    inl(meta.disclosure)
    pagebreak()
  }
  heading(level: 1, outlined: false)[Table of Contents]
  toc-section()
  pagebreak()
  heading(level: 1)[Table of Authorities]
  toa-section(auths)
  pagebreak()
  if "oral_argument" in meta {
    heading(level: 1)[Statement Regarding Oral Argument]
    inl(meta.oral_argument)
    pagebreak()
  }

  // The brief: arabic numerals from 1.
  set page(numbering: "1")
  counter(page).update(1)
  inl(main)
  signature-block(meta)

  // Each certificate is one unbreakable block, so its heading, text and signature stay together.
  pagebreak()
  block(breakable: false)[
    #heading(level: 1, outlined: false)[Certificate of Compliance]
    This #doc-title complies with the type-volume limitation of Fed. R. Bankr. P. 8015(a)(7)(B) because it contains #group-digits(words) words, excluding the parts of the brief exempted by Fed. R. Bankr. P. 8015(g). It complies with the typeface requirement of Fed. R. Bankr. P. 8015(a)(5) and the type-style requirement of Fed. R. Bankr. P. 8015(a)(6) because it was prepared in a proportionally spaced typeface, #font-family at #str(type-size / 1pt)-point, with case names in italics.
    #signature-block(meta)
  ]

  if meta.at("service", default: false) {
    block(breakable: false)[
      #heading(level: 1, outlined: false)[Certificate of Service]
      I certify that on #meta.at("date", default: "[date]") I filed this #doc-title with the Clerk of the Bankruptcy Appellate Panel of the Sixth Circuit through the court's electronic filing system, which will send notice of the filing to all counsel of record.
      #signature-block(meta)
    ]
  }

  if addendum != none {
    pagebreak()
    inl(addendum)
  }
}
