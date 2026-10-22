// United States Bankruptcy Appellate Panel of the Sixth Circuit: reply brief (appellant's reply).
//
// Rule-driven and content-agnostic. Governing rules: Fed. R. Bankr. P. 8012, 8014, 8015, 8019;
// 6th Cir. BAP LBR 8014-1. ../README.md records the rule text, the source and the date verified,
// and the one conflict (LBR 8014-1(d) says 12-point; FRBP 8015(a)(5)(A) says 14-point, and the
// federal rule governs). No case-specific text, no coordinates measured off any filed brief,
// no forced line breaks. The body is markdown rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or is a style choice)
// ---------------------------------------------------------------------------

#let doc-type = "reply"                  // "opening", "answering" or "reply": selects the rules below
#let doc-title = "reply brief of appellant"      // FRBP 8014(c)
#let font-family = ("Times New Roman", "Liberation Serif")      // FRBP 8015(a)(5): proportionally spaced, serif; Times New Roman substitute per docs/FONTS.md
#let type-size = 14pt                      // FRBP 8015(a)(5)(A): 14-point or larger, everywhere.
#let h1-size = 19.5pt                      // section headings and front-matter titles (style; Word sizes are half points)
#let h2-size = 17pt                        // level-2 headings (style)
#let title-size = 16pt                     // the brief's title on the cover (style)
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; LaTeX \pdfeachlineheight).
#let pitch-double = 36.4pt                 // FRBP 8015(a)(4): double-spaced, 2.6 x type size (calibration in ../README.md)
#let pitch-single = 18.2pt                 // block quotations, cover, TOC, TOA, signature, certificates: single-spaced
#let pitch-h1 = 24pt                       // a line of a 19.5 pt heading
#let pitch-h2 = 20pt                       // a line of a 17 pt heading
#let page-margin = 1in                     // FRBP 8015(a)(4): at least one inch on all four sides.
#let para-indent = 0.5in
#let toc-step = 21pt                       // TOC: each heading level indents one more step; wrapped lines hang by one step
#let toc-page-col = 36pt                   // TOC: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 56pt                   // TOA: page lists such as 1, 4, 6, 8
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

/// One single-spaced line block (cover, signature): its own paragraph, `above` the space before it.
#let line-block(body, above: 0pt) = block(above: above, below: 0pt, width: 100%, par(first-line-indent: 0pt, body))

// ---------------------------------------------------------------------------
// Style: applied once to the whole document by `#show: brief-style`
// ---------------------------------------------------------------------------

#let brief-style(doc) = {
  // The page number: centered in a single-spaced line box (Word's footer), at the same place on every page.
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context {
      let n = here().page-numbering()
      if n != none { align(center, text(..edges(pitch-single), counter(page).display(n))) }
    })
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  set par(first-line-indent: para-indent)
  // The cross-engine layout model: first fit, no kerning or ligatures, no hyphenation, line boxes of the body
  // pitch, a section sign kept with its number, no break inside "60(b)(5)".
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  set heading(numbering: none)
  show heading.where(level: 1): it => block(sticky: true, above: 22.4pt, below: 16.8pt, width: 100%, {
    set text(size: h1-size, ..edges(pitch-h1))
    set par(first-line-indent: 0pt)
    align(center, text(weight: "bold", it.body))
  })
  show heading.where(level: 2): it => block(sticky: true, above: 16.8pt, below: 14pt, width: 100%, {
    set text(size: h2-size, ..edges(pitch-h2))
    set par(first-line-indent: 0pt)
    text(weight: "bold", it.body)
  })
  show heading.where(level: 3): it => block(sticky: true, above: 15.4pt, below: 14pt, width: 100%, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(left: 0.5in, text(weight: "bold", it.body))
  })
  show heading.where(level: 4): it => block(sticky: true, above: 14pt, below: 14pt, width: 100%, {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt)
    pad(left: 1in, text(style: "italic", it.body))
  })
  show quote.where(block: true): it => block(above: 14pt, below: 19.6pt, pad(left: 0.5in, right: 0.5in, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    it.body
  }))
  set footnote.entry(gap: 7pt, clearance: 12.6pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))   // FRBP 8015(a)(5)(A): 14-point in footnotes too
    set par(first-line-indent: 0pt, hanging-indent: 0pt)
    it
  }
  doc
}

// ---------------------------------------------------------------------------
// Cover (FRBP 8015(a)(2)): case number, court, case title, nature of the proceeding,
// the brief's title naming the party, and counsel's name, address, phone and email.
// ---------------------------------------------------------------------------

#let cover(meta) = page(numbering: none, {
  set text(..edges(pitch-single))
  set align(center)
  line-block[Case No. #meta.case_number]
  line-block(above: 12.6pt)[*United States Bankruptcy Appellate Panel of the Sixth Circuit*]
  for (i, side) in meta.caption.enumerate() {
    for (j, n) in side.names.enumerate() { line-block(above: if j == 0 { 12.6pt } else { 0pt }, inl(n)) }
    line-block(inl(side.designation))
    if i < meta.caption.len() - 1 { line-block(above: 12.6pt)[v.] }
  }
  line-block(above: 19.6pt, inl(meta.proceeding))
  line-block(above: 19.6pt, text(size: title-size, weight: "bold", upper(meta.brief_title)))
  for (gi, group) in meta.counsel.enumerate() {
    for (ni, n) in group.names.enumerate() {
      line-block(above: if ni > 0 { 0pt } else if gi == 0 { 36.4pt } else { 12.6pt }, inl(n))
    }
    for l in group.lines { line-block(inl(l)) }
  }
  line-block(above: 12.6pt, meta.phone)
  if "date" in meta { line-block(above: 11.2pt, meta.date) }
})

// ---------------------------------------------------------------------------
// Front matter
// ---------------------------------------------------------------------------

/// Table of contents: every outlined heading, with its printed page.
#let toc-section() = context {
  set text(..edges(pitch-single))
  for head in query(heading.where(outlined: true)) {
    let indent = toc-step * (head.level - 1)
    listing-row(head.location(), { h(indent); head.body }, printed-page(head.location()), toc-page-col,
      indent + toc-step, 7pt)
  }
}

/// Table of authorities. Each `[text](toa:KEY)` link in the body is recorded with its page (the
/// `show link` rule in `bap6-brief`); the registry in the frontmatter names each authority once.
#let toa-section(auths) = context {
  set text(..edges(pitch-single))
  let hits = query(<toa-hit>)
  for kind in kind-order {
    let keys = auths.keys().filter(k => auths.at(k).kind == kind)
    if keys.len() == 0 { continue }
    block(sticky: true, above: 16.8pt, below: 11.2pt, par(first-line-indent: 0pt, text(weight: "bold", kind-heading.at(kind))))
    for k in keys.sorted(key: k => auths.at(k).at("sort", default: auths.at(k).at("name", default: auths.at(k).cite))) {
      let a = auths.at(k)
      let pgs = hits.filter(x => x.value == k).map(x => (p: x.location().page(), s: printed-page(x.location())))
      if pgs.len() == 0 { panic("bap6-brief: authority `" + k + "` is listed but never cited in the body") }
      let uniq = pgs.dedup(key: x => x.p).sorted(key: x => x.p)
      let shown = if uniq.len() >= passim-threshold { "passim" } else { uniq.map(x => x.s).join(", ") }
      let cited = if kind == "case" and "name" in a { "*" + a.name + "*, " + a.cite }
        else if "name" in a { a.name + ", " + a.cite }
        else { a.cite }
      listing-row(none, inl(cited), shown, toa-page-col, 0.5in, 7pt)
    }
  }
}

/// Certificate blocks and the signature block take the same closing block.
#let signature-block(meta) = block(above: 22.4pt, below: 0pt, width: 100%, breakable: false, {
  set text(..edges(pitch-single))
  pad(left: 50%, {
    line-block[Respectfully submitted,]
    line-block(above: 16.8pt)[s/ #meta.signature.signer]
    for l in meta.signature.lines { line-block(inl(l)) }
    if "date" in meta { line-block(above: 11.2pt, meta.date) }
  })
})

/// A front-matter or certificate page that opens with a heading: the heading (no space above it at the top of
/// the page) and its text, single-spaced.
#let cert-text(body) = block(above: 0pt, below: 0pt, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  body
})

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
  block(breakable: false, above: 0pt, below: 0pt, {
    heading(level: 1, outlined: false)[Certificate of Compliance]
    cert-text[This #doc-title complies with the type-volume limitation of Fed. R. Bankr. P. 8015(a)(7)(B) because it contains #group-digits(words) words, excluding the parts of the brief exempted by Fed. R. Bankr. P. 8015(g). It complies with the typeface requirement of Fed. R. Bankr. P. 8015(a)(5) and the type-style requirement of Fed. R. Bankr. P. 8015(a)(6) because it was prepared in a proportionally spaced typeface, #font-family.first() at #str(type-size / 1pt)-point, with case names in italics.]
    signature-block(meta)
  })

  if meta.at("service", default: false) {
    block(breakable: false, above: 22.4pt, below: 0pt, {
      heading(level: 1, outlined: false)[Certificate of Service]
      cert-text[I certify that on #meta.at("date", default: "[date]") I filed this #doc-title with the Clerk of the Bankruptcy Appellate Panel of the Sixth Circuit through the court's electronic filing system, which will send notice of the filing to all counsel of record.]
      signature-block(meta)
    })
  }

  if addendum != none {
    pagebreak()
    inl(addendum)
  }
}
