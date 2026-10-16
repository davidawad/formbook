// U.S. Court of Appeals for the District of Columbia Circuit: appellant's principal brief.
//
// Rule-driven and content-agnostic. Requirement IDs (DC-...) refer to ../README.md. No case-specific
// text, no coordinates measured off a filed brief, no forced line breaks. The body is markdown rendered
// by cmarker; the metadata is the YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a stated choice)
// ---------------------------------------------------------------------------

#let font-family = "TeX Gyre Schola"  // FRAP 32(a)(5)(A): a serif, proportional face. Handbook IX.A.6 names Century; substitute per docs/FONTS.md (Century Schoolbook -> TeX Gyre Schola).
#let type-size = 14pt                  // FRAP 32(a)(5)(A): 14-point or larger, everywhere.
#let body-leading = 1.07em             // FRAP 32(a)(4): double-spaced body. Gives a baseline pitch of about 24 pt at 14 pt, the pitch the filed exemplar uses; a spacing choice, see README.
#let single-leading = 0.45em           // Single spacing for headings, block quotations, signature and certificate blocks, footnotes, tables. Measured on the render: 0.12em overlapped two-line headings.
#let page-margin = 1in                 // FRAP 32(a)(4): at least one inch on all four sides.
#let para-indent = 0.5in
#let counsel-columns = 2             // cover counsel groups per row (a layout choice; FRAP 32(a)(2)(F) sets only the contents)
#let word-limit = 13000                // FRAP 28.1(e)(2)(A)(i) and 32(a)(7)(B)(i), applied through Circuit Rule 32(e).
#let toa-page-col-max = 1.5in       // TOA: a page list wider than this wraps inside its column (Circuit Rule 28(a)(2): no "passim").

#let kind-order = ("case", "constitution", "statute", "regulation", "rule", "other")
#let kind-title = (
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

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// The markdown body: cmarker output (the paragraph settings are set by the caller).
#let inl-body(md) = cmarker.render(md, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("dc-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("dc-brief: the sample must start with a YAML frontmatter block") }
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

// ---------------------------------------------------------------------------
// Cover (FRAP 32(a)(2); Circuit Rule 28(a)(8))
// ---------------------------------------------------------------------------

#let cover-body(meta, cols, s, fill) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: single-leading)
  set align(center)
  // Circuit Rule 28(a)(8): capital letters at the top of the front cover.
  strong(inl(upper(need(meta, "oral_argument"))))
  v(1.6em * s)
  [No. #need(meta, "case_number")]
  v(1.6em * s)
  [UNITED STATES COURT OF APPEALS]
  v(0.2em)
  [FOR THE DISTRICT OF COLUMBIA CIRCUIT]
  v(1.8em * s)
  for (i, side) in need(meta, "caption").enumerate() {
    if i > 0 {
      v(0.9em * s)
      [v.]
      v(0.9em * s)
    }
    for n in side.names {
      block(width: 100%, inl(n))
    }
    v(0.3em)
    block(width: 100%, inl(side.designation))
  }
  v(1.8em * s)
  block(width: 100%, inl(need(meta, "proceeding")))
  if "district_court_case" in meta { v(0.4em); block(width: 100%, inl(meta.district_court_case)) }
  if "judge" in meta { v(0.4em); block(width: 100%, inl(meta.judge)) }
  v(2.2em * s)
  strong(upper(need(meta, "brief_title")))
  v(2.2em * s)
  let groups = need(meta, "counsel")
  grid(
    columns: (1fr,) * cols,
    column-gutter: 1.2em,
    row-gutter: 1.2em * s,
    align: left,
    ..groups.map(g => {
      let block-lines = g.names.map(n => [#n]) + g.lines.map(l => emph(inl(l)))
      block(width: 100%, align(left, stack(dir: ttb, spacing: single-leading, ..block-lines)))
    }),
  )
  if fill { v(1fr) } else { v(1.2em) }
  if "date" in meta { block(width: 100%, inl(meta.date)) }
}

/// The cover is one page; the type size never shrinks. Counsel groups are set in rows of
/// `counsel-columns` (at 14 pt a third column is too narrow for a name or a street line) with
/// the largest spacing that fits; only if no spacing fits are all groups set in one row.
#let cover(meta) = layout(size => {
  let n = need(meta, "counsel").len()
  let tries = ()
  for cols in (calc.min(n, counsel-columns), n).dedup() {
    for s in (1.0, 0.8, 0.6, 0.45, 0.3) { tries.push((cols, s)) }
  }
  let fits(t) = measure(block(width: size.width, cover-body(meta, t.at(0), t.at(1), false))).height <= size.height
  let pick = tries.find(fits)
  if pick == none { panic("dc-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  block(height: size.height, cover-body(meta, pick.at(0), pick.at(1), true))
})

// ---------------------------------------------------------------------------
// Certificates and signature (Circuit Rule 28(a)(1); FRAP 32(g); FRAP 25(d))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  set par(first-line-indent: 0pt, leading: single-leading, spacing: single-leading)
  v(1.2em)
  block(width: 100%, breakable: false, grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    align: left,
    [#if "date" in meta { inl(meta.date) }],
    block(breakable: false, [
      Respectfully submitted,
      #v(0.8em)
      #stack(dir: ttb, spacing: single-leading, [/s/ #sig.signer], [#sig.signer])
      #v(0.4em)
      #stack(dir: ttb, spacing: single-leading, ..sig.lines.map(l => emph(inl(l))))
    ]),
  ))
}

// ---------------------------------------------------------------------------
// Authorities (Circuit Rule 28(a)(2): every page is listed; "passim" may not be used)
// ---------------------------------------------------------------------------

/// Pages (counted from the first body page) of every `toa:KEY` link, keyed by KEY.
#let cited-pages() = {
  let start = query(<body-first>).first().location().page()
  let out = (:)
  for l in query(link) {
    if type(l.dest) != str or not l.dest.starts-with("toa:") { continue }
    let key = l.dest.slice(4)
    let p = l.location().page() - start + 1
    let cur = out.at(key, default: ())
    if p not in cur { cur.push(p) }
    out.insert(key, cur)
  }
  out
}

/// Sort key: case-insensitive, with runs of digits compared as numbers ("8 U.S.C." before "26 U.S.C.").
#let sort-key(s) = lower(s).replace(regex("\\d+"), m => "0" * calc.max(0, 8 - m.text.len()) + m.text)

#let authority-text(a) = {
  if a.kind == "case" { inl("*" + a.name + "*, " + a.cite) }
  else if "name" in a { inl(a.name + ", " + a.cite) }
  else { inl(a.cite) }
}

#let toa(meta) = context {
  set par(first-line-indent: 0pt)
  let pages = cited-pages()
  let reg = need(meta, "authorities")
  for key in pages.keys() {
    if key not in reg { panic("dc-brief: cited authority `" + key + "` is not in the authorities registry") }
  }
  for kind in kind-order {
    let items = reg.pairs().filter(p => p.at(1).kind == kind and p.at(0) in pages)
    if items.len() == 0 { continue }
    items = items.sorted(key: p => sort-key(p.at(1).at("sort", default: p.at(1).at("name", default: p.at(1).cite))))
    v(0.8em)
    strong(kind-title.at(kind))
    v(0.2em)
    for p in items {
      let ps = pages.at(p.at(0)).sorted().map(str).join(", ")
      // The page list has its own column, so it never runs into the entry or its leader;
      // a list wider than toa-page-col-max wraps inside the column.
      let col = calc.min(measure(ps).width, toa-page-col-max)
      block(above: 0.5em, width: 100%, breakable: false, grid(
        columns: (1fr, col), column-gutter: 0.3em, align: (left, right + bottom),
        par(leading: single-leading, first-line-indent: 0pt, hanging-indent: para-indent, justify: false,
          [#authority-text(p.at(1)) #h(0.3em) #box(width: 1fr, repeat[.])]),
        par(leading: single-leading, first-line-indent: 0pt, justify: false, ps),
      ))
    }
  }
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let dc-brief(meta, md) = {
  let parts = md.split(regex("(?m)^# Addendum[ \t]*$"))
  let main = parts.at(0)
  let addendum = if parts.len() > 1 { parts.at(1) } else { none }
  let words = count-words(main)
  if words > word-limit {
    panic("dc-brief: body is " + str(words) + " words; FRAP 28.1(e)(2)(A)(i) allows " + str(word-limit))
  }

  set document(title: "No. " + need(meta, "case_number") + " " + need(meta, "brief_title"))
  set page(paper: "us-letter", margin: page-margin, numbering: none)
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  set par(leading: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false, spacing: body-leading)
  show heading.where(level: 1): it => {
    set par(leading: single-leading, first-line-indent: 0pt)
    block(above: 1.4em, below: 1.2em, width: 100%, sticky: true, align(center, strong(it.body)))
  }
  show heading.where(level: 2): it => {
    set par(leading: single-leading, first-line-indent: 0pt)
    block(above: 1.2em, below: 1em, width: 100%, sticky: true, strong(it.body))
  }
  show heading.where(level: 3): it => {
    set par(leading: single-leading, first-line-indent: 0pt)
    block(above: 1em, below: 0.9em, width: 100%, sticky: true, pad(left: para-indent, strong(it.body)))
  }
  show quote.where(block: true): it => {
    set par(leading: single-leading, first-line-indent: 0pt)
    pad(left: 0.5in, right: 0.5in, bottom: 1.2em, it.body)
  }
  show footnote.entry: set par(leading: single-leading, first-line-indent: 0pt)
  // Never break between a section sign or pilcrow and its number, nor inside a run of adjacent
  // parentheses ("6103(i)(2)"). Boxes keep the extracted text exactly the author's characters.
  show regex("[§¶]+ \\S+"): it => box(it)
  show regex("\\S*\\)\\(\\S*"): it => box(it)

  // Cover: no page number.
  cover(meta)

  // Front matter: lower-case roman, starting at the certificate.
  pagebreak()
  set page(numbering: "i")
  counter(page).update(1)

  // Circuit Rule 28(a)(1): the certificate comes immediately inside the cover.
  heading(level: 1)[CERTIFICATE AS TO PARTIES, RULINGS, AND RELATED CASES, AND RULE 26.1 DISCLOSURE]
  let cert = need(meta, "certificate")
  // Paragraphs are marked by a first-line indent, as in the body; without it, consecutive
  // paragraphs of a certificate part read as one.
  set par(first-line-indent: (amount: para-indent, all: true), leading: body-leading, spacing: body-leading)
  [Pursuant to Circuit Rule 28(a)(1) and Federal Rule of Appellate Procedure 26.1, the undersigned counsel certifies as follows:]
  v(0.8em)
  block(width: 100%, strong[A. Parties and Amici])
  inl(cert.parties)
  v(0.8em)
  block(width: 100%, strong[B. Rulings Under Review])
  inl(cert.rulings)
  v(0.8em)
  block(width: 100%, strong[C. Related Cases])
  inl(cert.related)
  v(0.8em)
  block(width: 100%, strong[Rule 26.1 Disclosure])
  inl(cert.disclosure)

  pagebreak()
  heading(level: 1, outlined: false)[TABLE OF CONTENTS]
  outline(title: none, depth: 2, indent: 1.5em)

  pagebreak()
  heading(level: 1)[TABLE OF AUTHORITIES]
  toa(meta)

  if "glossary" in meta {
    pagebreak()
    heading(level: 1)[GLOSSARY]
    set par(first-line-indent: 0pt, leading: single-leading, spacing: single-leading)
    grid(
      columns: (auto, 1fr),
      column-gutter: 1.5em,
      row-gutter: 0.7em,
      ..meta.glossary.map(g => ([#g.abbr], [#inl(g.meaning)])).flatten(),
    )
  }

  // Body: arabic numbers, starting at 1 on the first page of the argument.
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  [#metadata(none)<body-first>]
  // The certificate and glossary above set their own paragraph styles at this level; reset the body.
  set par(leading: body-leading, first-line-indent: (amount: para-indent, all: true), justify: false, spacing: body-leading)
  // The signature block never stands alone on a page: the body's last paragraph is kept together
  // with it (unless that last block is a heading or a footnote definition).
  let text-md = main.trim(at: end)
  let breaks = text-md.matches(regex("\n[ \t]*\n"))
  let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
  let tail = text-md.slice(cut)
  if tail.len() > 0 and not tail.starts-with("#") and not tail.starts-with("[^") {
    inl-body(text-md.slice(0, cut))
    block(breakable: false, { inl-body(tail); signature-block(meta) })
  } else {
    inl-body(text-md)
    signature-block(meta)
  }

  // Certificates (FRAP 32(g)(1), Form 6 wording; FRAP 25(d)).
  pagebreak()
  heading(level: 1)[CERTIFICATE OF COMPLIANCE]
  set par(first-line-indent: 0pt, leading: body-leading, spacing: body-leading)
  [This document complies with the type-volume limitations of Fed. R. App. P. 32(a)(7)(B) because, excluding the parts of the document exempted by the Federal Rules of Appellate Procedure and this Court's rules, this document contains #group-digits(words) words, as calculated by my word processing software.]
  v(0.8em)
  [This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type-style requirements of Fed. R. App. P. 32(a)(6) because this document has been prepared in a proportionally spaced typeface, #int(type-size / 1pt)-point #font-family, using #need(meta, "word_processor").]
  v(1.2em)
  block(width: 100%, breakable: false, align(right, block(width: 55%, [
    #set par(first-line-indent: 0pt, leading: single-leading, spacing: single-leading)
    #stack(dir: ttb, spacing: single-leading, [/s/ #need(meta, "signature").signer], [#need(meta, "signature").signer])
  ])))

  pagebreak()
  heading(level: 1)[CERTIFICATE OF SERVICE]
  set par(first-line-indent: para-indent, leading: body-leading, spacing: body-leading)
  [I hereby certify that, on #need(meta, "date"), the foregoing document was served through the Court's ECF system on counsel for all parties.]
  v(1.2em)
  block(width: 100%, breakable: false, align(right, block(width: 55%, [
    #set par(first-line-indent: 0pt, leading: single-leading, spacing: single-leading)
    #stack(dir: ttb, spacing: single-leading, [/s/ #need(meta, "signature").signer], [#need(meta, "signature").signer])
  ])))

  if addendum != none {
    pagebreak()
    inl-body(addendum)
  }
}

