// U.S. Court of Appeals for the Tenth Circuit: answering brief (appellee's brief, no cross-appeal).
//
// Rule-driven and content-agnostic. Requirement IDs (CA10-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"     // CA10-FORM-004: proportionally spaced, serif; Times New Roman substitute per docs/FONTS.md
#let type-size = 14pt                      // CA10-FORM-004 / 10th Cir. R. 32(A): 13 or 14 point, 14 preferred.
                                           // A proportional face must be 14-point or larger (FRAP 32(a)(5)).
#let body-leading = 1.36em                 // CA10-FORM-003: double spacing (FRAP 32(a)(4)); calibrated in README.md.
#let single-leading = 0.65em               // quotations, headings, TOC/TOA, certificates: single-spaced (typst's normal line gap).
#let para-spacing = 0.9em
#let page-margin = 1in                     // CA10-FORM-002: at least one inch on all four sides (FRAP 32(a)(4)).
#let para-indent = 0.5in
#let passim-threshold = 7                  // an authority cited on this many pages or more: "passim".

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render a short inline markdown string (names, cites) as content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, set-document-title: false)

#let need(meta, key) = {
  if key not in meta { panic("ca10-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ca10-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
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

/// Word count of the markdown body, whitespace-delimited. Markup characters are not words.
/// Approximate by design: the sample is a portion of a brief, so the certificate states the
/// count of the sample's own text. See README.md, "Known gaps".
#let count-words(md) = {
  let s = md.replace(regex("\\[\\^[^\\]]+\\]:[^\n]*"), " ")     // footnote definitions
  s = s.replace(regex("\\[\\^[^\\]]+\\]"), "")                 // footnote references
  s = s.replace(regex("\\[([^\\]]*)\\]\\([^)]*\\)"), m => m.captures.at(0))
  s = s.replace(regex("[*_#>`]"), " ")
  s.split(regex("\\s+")).filter(w => w != "").len()
}

/// Front matter is numbered in lower roman; the cover (page i) carries no number.
#let front-page-number(..nums) = {
  let n = nums.pos().first()
  if n > 1 { numbering("i", n) }
}

// ---------------------------------------------------------------------------
// Cover (FRAP 32(a)(2); 10th Cir. R. 28.2(C)(1)-(2))
// ---------------------------------------------------------------------------

#let caption-block(meta) = {
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    if i > 0 {
      v(0.5em)
      align(center, par(first-line-indent: 0pt)[v.])
      v(0.5em)
    }
    for name in side.names {
      align(center, par(first-line-indent: 0pt, leading: single-leading, inl(name)))
    }
    align(center, par(first-line-indent: 0pt, leading: single-leading, inl(side.designation)))
  }
}

/// The front cover, on one page (FRAP 32(a)(2): the front cover carries the case number, court,
/// title of the case, nature of the proceeding and court below, title of the brief, and counsel;
/// 10th Cir. R. 28.2(C)(1)-(2): district, judge, district court case number, oral argument).
/// The groups are spread with flexible space, so the page fills without fixed offsets.
#let cover-rule = align(center, line(length: 40%, stroke: 0.5pt))

#let cover(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center)[No. #need(meta, "case_number")]
  v(1fr)
  align(center)[
    *UNITED STATES COURT OF APPEALS*\
    *FOR THE TENTH CIRCUIT*
  ]
  v(1fr)
  caption-block(meta)
  v(1fr)
  align(center, inl(need(meta, "proceeding")))
  if "judge" in meta { align(center, inl(meta.judge)) }
  if "district_court_case" in meta { align(center, inl(meta.district_court_case)) }
  v(1fr)
  cover-rule
  align(center, strong(upper(need(meta, "brief_title"))))
  cover-rule
  v(1fr)
  align(center, need(meta, "oral_argument"))
  v(1fr)
  for group in need(meta, "counsel") {
    align(center, block(width: 100%, sticky: true, {
      for name in group.names {
        par(first-line-indent: 0pt, leading: single-leading, align(center, inl(name)))
      }
      for line in group.lines {
        par(first-line-indent: 0pt, leading: single-leading, align(center, emph(inl(line))))
      }
    }))
    v(0.6em)
  }
  align(center, par(first-line-indent: 0pt, leading: single-leading, inl(need(meta, "phone"))))
  v(0.5fr)
}

// ---------------------------------------------------------------------------
// Headings in the body. The body's own numerals are kept as written (the sample is a transcription).
// ---------------------------------------------------------------------------

#let style-heading-1(it) = block(width: 100%, sticky: true, above: 1.2em, below: 1em,
  align(center, strong(it.body)))

#let style-heading-2(it) = block(width: 100%, sticky: true, above: 1em, below: 0.8em,
  par(first-line-indent: 0pt, hanging-indent: 0.5in, leading: single-leading, strong(it.body)))

/// Unnumbered titles the template prints itself (front matter, oral argument, certificates).
#let section-title(body) = block(width: 100%, sticky: true, above: 0.4em, below: 1em,
  align(center, strong(body)))

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

/// One row of a table: title, dot leader, page (the page counter at `loc`).
#let toc-row(title, loc, indent: 0pt) = {
  let pg = counter(page).at(loc).first()
  // Front-matter pages (before the body) are listed in roman numerals, as they are printed.
  let body-page = query(<ca10-body>).first().location().page()
  let shown = if loc.page() < body-page { numbering("i", pg) } else { [#pg] }
  block(width: 100%, below: 0.6em, par(first-line-indent: 0pt, hanging-indent: 0.4in, leading: single-leading, justify: false, {
    h(indent)
    title
    h(0.3em)
    box(width: 1fr, repeat[.#h(0.16em)])
    shown
  }))
}

#let toc-section() = {
  section-title[TABLE OF CONTENTS]
  align(right, strong(underline[Page]))
  context {
    // Front-matter entries, found by their labels.
    for (lab, t) in ((<ca10-toa>, [TABLE OF AUTHORITIES]), (<ca10-prior>, [STATEMENT OF PRIOR OR RELATED APPEALS])) {
      let found = query(lab)
      if found.len() > 0 { toc-row(t, found.first().location()) }
    }
    // Body headings, levels 1 and 2 (the sample's own structure).
    for h in query(heading.where(level: 1).or(heading.where(level: 2))) {
      toc-row(h.body, h.location(), indent: if h.level == 2 { 0.4in } else { 0pt })
    }
    // Back matter, found by the labels on each title.
    for (lab, t) in (
      (<ca10-oral>, [STATEMENT OF COUNSEL AS TO ORAL ARGUMENT]),
      (<ca10-cert-compliance>, [CERTIFICATE OF COMPLIANCE WITH TYPE-VOLUME LIMIT]),
      (<ca10-cert-digital>, [CERTIFICATE OF DIGITAL SUBMISSION]),
      (<ca10-cert-service>, [CERTIFICATE OF SERVICE]),
    ) {
      let found = query(lab)
      if found.len() > 0 { toc-row(t, found.first().location()) }
    }
  }
}

/// Pages on which the authority `key` is cited in the body or the back matter (not the front matter).
/// Each citation is tagged by the show rule in `ca10-brief` with <ca10-cite>, whose value lists keys.
/// Must be called inside `context`.
#let pages-cited(key) = {
  let start = query(<ca10-body>).first().location().page()
  let hits = query(<ca10-cite>).filter(e => e.location().page() >= start and key in e.value)
  hits.map(e => counter(page).at(e.location()).first()).dedup()
}

#let toa-kinds = (
  (kind: "case", title: [Cases]),
  (kind: "statute", title: [Statutes]),
  (kind: "rule", title: [Rules]),
  (kind: "other", title: [Other Authorities]),
)

#let toa-section(authorities) = {
  [#section-title[TABLE OF AUTHORITIES] <ca10-toa>]
  align(right, strong(underline[Page(s)]))
  context for k in toa-kinds {
    let items = authorities.pairs().filter(p => p.last().at("kind", default: "other") == k.kind)
    if items.len() > 0 {
      block(width: 100%, above: 0.8em, below: 0.6em, sticky: true, strong(k.title))
      for (key, a) in items.sorted(key: p => lower(p.last().name)) {
        let pages = pages-cited(key)
        let shown = if a.kind == "case" { emph(a.name) } else { [#a.name] }
        let cite = if a.at("cite", default: "") != "" { [, #a.cite] } else { [] }
        let mark = if pages.len() == 0 { [--] } else if pages.len() >= passim-threshold { [passim] } else { pages.map(str).join(", ") }
        block(width: 100%, below: 0.6em, par(first-line-indent: 0pt, hanging-indent: 0.4in, leading: single-leading, justify: false, [#shown#cite#h(0.3em)#box(width: 1fr, repeat[.#h(0.16em)])#mark]))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Back matter: signature, oral argument, certificates, service
// ---------------------------------------------------------------------------

/// The signature lines, printed under the signer's name. Plain content (no par), so it can sit in a block.
#let signature-lines(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading)
  for line in need(meta, "signature").lines {
    [#inl(line)]
    linebreak()
  }
}

#let signature-block(meta) = block(width: 100%, breakable: false, above: 1.6em, pad(left: 3.25in)[
  #set par(first-line-indent: 0pt, leading: single-leading)
  Respectfully submitted,
  #v(1.2em)
  s/ #need(meta, "signature").signer
  #linebreak()
  #signature-lines(meta)
])

#let certificate-of-compliance(meta, words) = [
  #section-title[CERTIFICATE OF COMPLIANCE WITH TYPE-VOLUME LIMIT] <ca10-cert-compliance>
  #set par(first-line-indent: 0pt, leading: single-leading)
  1. This brief complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B) because:

  #pad(left: 0.4in)[[x] this brief contains #group-digits(words) words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f) and 10th Cir. R. 32(B).]
  #v(0.8em)
  2. This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type style requirements of Fed. R. App. P. 32(a)(6) because:

  #pad(left: 0.4in)[[x] this brief has been prepared in a proportionally spaced typeface using Typst in #int(type-size / 1pt)-point #font-family.]
  #v(1.2em)
  Date: #need(meta, "date").
  #v(1.2em)
  #pad(left: 3.25in)[s/ #need(meta, "signature").signer #linebreak() #signature-lines(meta)]
]

#let certificate-of-digital-submission(meta) = [
  #section-title[CERTIFICATE OF DIGITAL SUBMISSION] <ca10-cert-digital>
  #set par(first-line-indent: 0pt, leading: single-leading)
  I hereby certify that with respect to the foregoing:

  (1) all required privacy redactions have been made per 10th Cir. R. 25.5;

  (2) if required to file additional hard copies, that the ECF submission is an exact copy of those documents;

  (3) the digital submissions have been scanned for viruses with the most recent version of a commercial virus scanning program, #need(meta, "virus_scanner"), and according to the program are free of viruses.
  #v(1.2em)
  #pad(left: 3.25in)[s/ #need(meta, "signature").signer #linebreak() #signature-lines(meta)]
]

#let certificate-of-service(meta) = [
  #section-title[CERTIFICATE OF SERVICE] <ca10-cert-service>
  #set par(first-line-indent: 0pt, leading: single-leading)
  I hereby certify that on #need(meta, "date") a true and correct copy of the foregoing was filed with the Clerk of the Court using CM/ECF system and also served on the following:
  #v(0.8em)
  #for group in need(meta, "service").at("unregistered", default: ()) [
    #block(width: 100%)[
      #for (i, line) in group.enumerate() {
        if i > 0 { linebreak() }
        inl(line)
      }
    ]
    #v(0.8em)
  ]
  #v(0.8em)
  #pad(left: 3.25in)[By: s/ #need(meta, "signature").signer #linebreak() #signature-lines(meta)]
]

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca10-brief(meta, md) = {
  set document(title: "Answer brief " + need(meta, "case_number"))
  set text(font: font-family, size: type-size, lang: "en", region: "us")
  set page(paper: "us-letter", margin: page-margin, numbering: front-page-number)
  set par(leading: body-leading, spacing: para-spacing, first-line-indent: (amount: para-indent, all: true), justify: false)
  show heading.where(level: 1): it => style-heading-1(it)
  show heading.where(level: 2): it => style-heading-2(it)
  show footnote.entry: it => {
    set text(size: type-size)
    set par(leading: single-leading, first-line-indent: 0pt)
    it
  }
  // Tag every occurrence of an authority's `search` pattern with its key(s); toa-section reads them back.
  let auth = need(meta, "authorities")
  let pattern = auth.pairs().map(p => "(" + p.last().search + ")").join("|")
  show regex(pattern): it => {
    let keys = auth.pairs().filter(p => it.text.find(regex(p.last().search)) != none).map(p => p.first())
    it + [#metadata(keys)<ca10-cite>]   // no space before the label: a space would print
  }

  // Cover (page i, unnumbered).
  cover(meta)
  pagebreak()

  // Front matter (roman numerals).
  toc-section()
  pagebreak()
  toa-section(need(meta, "authorities"))
  v(1.2em)
  [#section-title[STATEMENT OF PRIOR OR RELATED APPEALS] <ca10-prior>]
  par(first-line-indent: 0pt, leading: single-leading, inl(need(meta, "prior_related")))

  // Body (arabic numerals from 1).
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  [#metadata("body") <ca10-body>]
  cmarker.render(md, smart-punctuation: true, raw-typst: false, h1-level: 1, set-document-title: false)

  signature-block(meta)

  // Statement of oral argument (10th Cir. R. 28.2(C)(2); FRAP 34).
  v(1.2em)
  [#section-title[STATEMENT OF COUNSEL AS TO ORAL ARGUMENT] <ca10-oral>]
  par(first-line-indent: para-indent, inl(need(meta, "oral_argument_statement")))

  // Certificates (10th Cir. R. 25.5; FRAP 32(g); FRAP 25(d); 10th Cir. R. 25.4).
  pagebreak()
  certificate-of-compliance(meta, count-words(md))
  pagebreak()
  certificate-of-digital-submission(meta)
  pagebreak()
  certificate-of-service(meta)
}
