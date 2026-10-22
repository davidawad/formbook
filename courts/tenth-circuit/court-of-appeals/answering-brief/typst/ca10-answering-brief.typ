// U.S. Court of Appeals for the Tenth Circuit: answering brief (appellee's brief, no cross-appeal).
//
// Rule-driven and content-agnostic. Requirement IDs (CA10-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the
// same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // CA10-FORM-004: proportionally spaced, serif; Times New Roman substitute per docs/FONTS.md
#let type-size = 14pt                      // CA10-FORM-004 / 10th Cir. R. 32(A): 13 or 14 point, 14 preferred.
                                           // A proportional face must be 14-point or larger (FRAP 32(a)(5)).
#let h1-size = 19.5pt                      // body section headings (typst's level-1 heading size, 1.4em, in whole half points)
#let h2-size = 17pt                        // body point headings (typst's level-2 heading size, 1.2em, in whole half points)
// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing). The spaces below are the template's own gaps,
// measured baseline to baseline on its earlier render, less the line boxes now around them.
#let pitch-double = 28.1pt                 // CA10-FORM-003: double spacing (FRAP 32(a)(4)); calibrated on the exemplar (README.md)
#let pitch-single = 18.8pt                 // quotations, TOC/TOA, cover, certificates, footnotes: single-spaced
#let pitch-h1 = 24pt                       // a 19.5 pt heading line
#let pitch-h2 = 20pt                       // a 17 pt heading line
#let single-gap = 3.5pt                    // between two single-spaced paragraphs
#let h1-above = 12pt
#let h1-below = 2pt
#let h2-above = 10pt
#let title-above = 13pt                    // the titles the template prints (front matter, statements, certificates)
#let title-below = 4.8pt
#let cert-gap = 14.7pt                     // the larger steps inside a certificate
#let sig-gap = 20.3pt                      // above a signature, and between "Respectfully submitted," and it
#let toc-page-col = 36pt                   // TOC: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 56pt                   // TOA: page lists such as 1, 4, 6, 8 (a longer list widens its own row's column)
#let list-hang = 0.4in                     // TOC/TOA rows: wrapped lines hang 0.4 in
#let page-margin = 1in                     // CA10-FORM-002: at least one inch on all four sides (FRAP 32(a)(4)).
#let para-indent = 0.5in
#let sig-indent = 3.25in                   // the signature blocks start at the middle of the text
#let cert-indent = 0.4in                  // a certificate's numbered statements and their checked items
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

/// A single-spaced paragraph at the margin, `above` clear of the block before it.
#let spar(body, above: single-gap, align-to: left) = block(width: 100%, above: above, below: single-gap, {
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  align(align-to, body)
})

// ---------------------------------------------------------------------------
// Cover (FRAP 32(a)(2); 10th Cir. R. 28.2(C)(1)-(2))
// ---------------------------------------------------------------------------

#let caption-block(meta) = {
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    if i > 0 { spar(above: 10.5pt, align-to: center)[v.] }
    for (k, name) in side.names.enumerate() {
      spar(above: if i > 0 and k == 0 { 10.5pt } else { single-gap }, align-to: center, inl(name))
    }
    spar(align-to: center, inl(side.designation))
  }
}

/// The front cover, on one page (FRAP 32(a)(2): the front cover carries the case number, court,
/// title of the case, nature of the proceeding and court below, title of the brief, and counsel;
/// 10th Cir. R. 28.2(C)(1)-(2): district, judge, district court case number, oral argument).
/// The groups are spread with flexible space, so the page fills without fixed offsets.
#let cover-rule = align(center, line(length: 40%, stroke: 0.5pt))

#let cover(meta) = {
  set text(..edges(pitch-single))
  spar(align-to: center)[No. #need(meta, "case_number")]
  v(1fr)
  spar(align-to: center, strong[UNITED STATES COURT OF APPEALS\ FOR THE TENTH CIRCUIT])
  v(1fr)
  caption-block(meta)
  v(1fr)
  spar(align-to: center, inl(need(meta, "proceeding")))
  if "judge" in meta { spar(align-to: center, inl(meta.judge)) }
  if "district_court_case" in meta { spar(align-to: center, inl(meta.district_court_case)) }
  v(1fr)
  cover-rule
  spar(align-to: center, strong(upper(need(meta, "brief_title"))))
  cover-rule
  v(1fr)
  spar(align-to: center, need(meta, "oral_argument"))
  v(1fr)
  for (gi, group) in need(meta, "counsel").enumerate() {
    block(width: 100%, sticky: true, above: if gi > 0 { 8.4pt } else { single-gap }, below: 0pt, {
      for name in group.names { spar(align-to: center, inl(name)) }
      for line in group.lines { spar(align-to: center, emph(inl(line))) }
    })
  }
  spar(above: 8.4pt, align-to: center, inl(need(meta, "phone")))
  v(0.5fr)
}

// ---------------------------------------------------------------------------
// Headings in the body. The body's own numerals are kept as written (the sample is a transcription).
// ---------------------------------------------------------------------------

#let style-heading-1(it) = block(width: 100%, sticky: true, above: h1-above, below: h1-below, {
  set text(size: h1-size, ..edges(pitch-h1))
  align(center, par(first-line-indent: 0pt, strong(it.body)))
})

#let style-heading-2(it) = block(width: 100%, sticky: true, above: h2-above, below: 0pt, {
  set text(size: h2-size, ..edges(pitch-h2))
  par(first-line-indent: 0pt, hanging-indent: 0.5in, strong(it.body))
})

/// Unnumbered titles the template prints itself (front matter, oral argument, certificates).
#let section-title(body, above: title-above) = block(width: 100%, sticky: true, above: above, below: title-below, {
  set text(..edges(pitch-single))
  align(center, par(first-line-indent: 0pt, strong(body)))
})

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

/// One row of the contents (listing-row): title, dot leader, page (the page counter at `loc`).
#let toc-row(title, loc, indent: 0pt) = {
  let pg = counter(page).at(loc).first()
  // Front-matter pages (before the body) are listed in roman numerals, as they are printed.
  let body-page = query(<ca10-body>).first().location().page()
  let shown = if loc.page() < body-page { numbering("i", pg) } else { [#pg] }
  listing-row(none, { h(indent); title }, shown, toc-page-col, list-hang, 0pt)
}

#let toc-section() = {
  section-title(above: 0pt)[TABLE OF CONTENTS]
  block(width: 100%, above: title-below, below: single-gap, align(right, strong(underline[Page])))
  context {
    // Front-matter entries, found by their labels.
    for (lab, t) in ((<ca10-toa>, [TABLE OF AUTHORITIES]), (<ca10-prior>, [STATEMENT OF PRIOR OR RELATED APPEALS])) {
      let found = query(lab)
      if found.len() > 0 { toc-row(t, found.first().location()) }
    }
    // Body headings, levels 1 and 2 (the sample's own structure).
    for h in query(heading.where(level: 1).or(heading.where(level: 2))) {
      toc-row(h.body, h.location(), indent: if h.level == 2 { list-hang } else { 0pt })
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
  [#section-title(above: 0pt)[TABLE OF AUTHORITIES] <ca10-toa>]
  block(width: 100%, above: title-below, below: 0pt, align(right, strong(underline[Page(s)])))
  context for k in toa-kinds {
    let items = authorities.pairs().filter(p => p.last().at("kind", default: "other") == k.kind)
    if items.len() > 0 {
      block(width: 100%, above: 2pt, below: 0pt, sticky: true, par(first-line-indent: 0pt, strong(k.title)))
      for (key, a) in items.sorted(key: p => lower(p.last().name)) {
        let pages = pages-cited(key)
        let shown = if a.kind == "case" { emph(a.name) } else { [#a.name] }
        let cite = if a.at("cite", default: "") != "" { [, #a.cite] } else { [] }
        let mark = if pages.len() == 0 { [--] } else if pages.len() >= passim-threshold { [passim] } else { pages.map(str).join(", ") }
        listing-row(none, [#shown#cite], mark, calc.max(toa-page-col, measure(mark).width), list-hang, 0pt)
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Back matter: signature, oral argument, certificates, service
// ---------------------------------------------------------------------------

/// The signer's lines, one per line, in the right half.
#let signature-lines(meta) = need(meta, "signature").lines.map(inl).join(linebreak())

/// A signature in the right half of the page: `first` (the "s/" line) and the signer's lines.
#let sig-block(meta, first, above: sig-gap) = block(width: 100%, breakable: false, above: above, below: 0pt,
  { set par(first-line-indent: 0pt); pad(left: sig-indent, [#first#linebreak()#signature-lines(meta)]) })

#let signature-block(meta) = block(width: 100%, breakable: false, above: 11pt, below: 0pt, {
  set text(..edges(pitch-single))
  { set par(first-line-indent: 0pt); pad(left: sig-indent)[Respectfully submitted,] }
  sig-block(meta, [s/ #need(meta, "signature").signer])
})

/// A numbered statement of a certificate: the number in a half-inch box, the text hanging after it.
#let cert-item(num, body, above: single-gap) = block(width: 100%, above: above, below: single-gap,
  par(first-line-indent: 0pt, hanging-indent: cert-indent, { box(width: cert-indent, num); body }))

#let certificate-of-compliance(meta, words) = {
  set text(..edges(pitch-single))
  [#section-title(above: 0pt)[CERTIFICATE OF COMPLIANCE WITH TYPE-VOLUME LIMIT] <ca10-cert-compliance>]
  cert-item[1.][This brief complies with the type-volume limitation of Fed. R. App. P. 32(a)(7)(B) because:]
  block(width: 100%, above: single-gap, below: single-gap, pad(left: cert-indent, par(first-line-indent: 0pt)[[x] this brief contains #group-digits(words) words, excluding the parts of the brief exempted by Fed. R. App. P. 32(f) and 10th Cir. R. 32(B).]))
  cert-item(above: cert-gap)[2.][This brief complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type style requirements of Fed. R. App. P. 32(a)(6) because:]
  block(width: 100%, above: single-gap, below: single-gap, pad(left: cert-indent, par(first-line-indent: 0pt)[[x] this brief has been prepared in a proportionally spaced typeface, #font-family.first(), in #int(type-size / 1pt)-point type.]))
  spar(above: sig-gap)[Date: #need(meta, "date").]
  sig-block(meta, [s/ #need(meta, "signature").signer])
}

#let certificate-of-digital-submission(meta) = {
  set text(..edges(pitch-single))
  [#section-title(above: 0pt)[CERTIFICATE OF DIGITAL SUBMISSION] <ca10-cert-digital>]
  spar[I hereby certify that with respect to the foregoing:]
  spar[(1) all required privacy redactions have been made per 10th Cir. R. 25.5;]
  spar[(2) if required to file additional hard copies, that the ECF submission is an exact copy of those documents;]
  spar[(3) the digital submissions have been scanned for viruses with the most recent version of a commercial virus scanning program, #need(meta, "virus_scanner"), and according to the program are free of viruses.]
  sig-block(meta, [s/ #need(meta, "signature").signer])
}

#let certificate-of-service(meta) = {
  set text(..edges(pitch-single))
  [#section-title(above: 0pt)[CERTIFICATE OF SERVICE] <ca10-cert-service>]
  spar[I hereby certify that on #need(meta, "date") a true and correct copy of the foregoing was filed with the Clerk of the Court using CM/ECF system and also served on the following:]
  for group in need(meta, "service").at("unregistered", default: ()) {
    spar(above: cert-gap, group.map(inl).join(linebreak()))
  }
  sig-block(meta, [By: s/ #need(meta, "signature").signer], above: 26pt)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca10-brief(meta, md) = {
  set document(title: "Answer brief " + need(meta, "case_number"))
  // The page number: centered in a single-spaced line box (Word's footer), at the same place on every page.
  set page(paper: "us-letter", margin: page-margin, footer-descent: 30%,
    footer: context {
      let n = counter(page).get().first()
      let label = if page.numbering == "1" { str(n) } else if n > 1 { numbering("i", n) } else { none }
      if label != none { align(center, text(..edges(pitch-single), label)) }
    })
  set page(numbering: "i")
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model (lib/typst/xengine.typ): first fit, no kerning or ligatures, no hyphenation, line
  // boxes of the body pitch, footnote marks at 58 %, lists with the number in a half-inch box, a section sign kept
  // with its number, no break inside "60(b)(5)".
  show: xengine.with(pitch: pitch-double, list-indent: para-indent)
  show heading.where(level: 1): it => style-heading-1(it)
  show heading.where(level: 2): it => style-heading-2(it)
  set footnote.entry(gap: 7pt, clearance: 12.6pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))   // 10th Cir. R. 32(A): footnotes at the body size
    set par(first-line-indent: 0pt, hanging-indent: 0pt, spacing: 7pt)
    // marker, a quarter em, then the note
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 14pt, below: 14pt, pad(left: para-indent, right: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: 12.6pt)
    it.body
  }))
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
  {
    set text(..edges(pitch-single))
    toc-section()
    pagebreak()
    toa-section(need(meta, "authorities"))
    [#section-title(above: 16pt)[STATEMENT OF PRIOR OR RELATED APPEALS] <ca10-prior>]
    spar(above: title-below, inl(need(meta, "prior_related")))
  }

  // Body (arabic numerals from 1).
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  [#metadata("body") <ca10-body>]
  cmarker.render(md, smart-punctuation: true, raw-typst: false, h1-level: 1, set-document-title: false)

  signature-block(meta)

  // Statement of oral argument (10th Cir. R. 28.2(C)(2); FRAP 34): text of the brief, double-spaced.
  [#section-title[STATEMENT OF COUNSEL AS TO ORAL ARGUMENT] <ca10-oral>]
  inl(need(meta, "oral_argument_statement"))

  // Certificates (10th Cir. R. 25.5; FRAP 32(g); FRAP 25(d); 10th Cir. R. 25.4).
  pagebreak()
  certificate-of-compliance(meta, count-words(md))
  pagebreak()
  certificate-of-digital-submission(meta)
  pagebreak()
  certificate-of-service(meta)
}
