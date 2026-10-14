// U.S. Bankruptcy Court, D. Utah: motion with supporting memorandum (one document, LBR 9013-1(c)(1)).
//
// Rule-driven and content-agnostic. Rule IDs (DUCivR 7-1, DUCivR 10-1, LBR 1001-1, LBR 9013-1, FRBP ...)
// refer to ../README.md, which records the primary source and the verification date of each.
// No case-specific text, no coordinates measured off any filed exemplar, no forced line breaks.
// The body is markdown rendered by cmarker; the metadata comes from the YAML frontmatter of the sample.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Doc-type parameters (the only part that differs between the three copies)
// ---------------------------------------------------------------------------

#let doc-kind = "motion-brief"
#let word-limit = 7750                     // DUCivR 7-1(a)(4)(A): motion under Rule 12(b) (see README: 25 pages also apply)
#let required-sections = (                 // one initial section stating the relief sought; conclusion last
  "^introduction",
  "^conclusion$",
)

// ---------------------------------------------------------------------------
// Parameters (each number traces to a rule or is a named style choice)
// ---------------------------------------------------------------------------

#let court-lines = ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE DISTRICT OF UTAH")   // caption: court name
#let font-family = "EB Garamond"          // a proportionally spaced serif (DUCivR 10-1). Vendored in /fonts.
#let type-size = 13pt                      // DUCivR 10-1: at least 12 pt, footnotes included. See README.
#let body-leading = 0.94em                 // with the metric-aligned line box, a baseline pitch of about
                                           // 2.2 x type size: double spacing (DUCivR 10-1).
#let single-leading = 0.12em               // headings, block quotes, footnotes, caption, TOC/TOA: single-spaced.
#let page-margin = (top: 1.5in, rest: 1in) // DUCivR 10-1: top margin at least 1.5 in, the others at least 1 in.
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let passim-threshold = 7                  // authority cited on this many pages or more: "passim"

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

#let need(meta, key) = {
  if key not in meta { panic("utb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("utb-motion-brief: the sample must start with a YAML frontmatter block") }
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
// Headings
// ---------------------------------------------------------------------------

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

#let style-heading(it) = {
  set text(size: type-size)
  if it.level == 1 {
    // Section headings: bold, capitals as written, centered.
    block(width: 100%, sticky: true, above: 1.4em, below: 1.1em,
      align(center, hang(0pt, strong(it.body))))
  } else if it.level == 2 {
    // Point headings: bold, the roman numeral in the text, hanging under the title.
    block(width: 100%, sticky: true, above: 1.1em, below: 0.9em, hang(heading-tab, strong(it.body)))
  } else {
    // Sub-headings: bold, indented one step, hanging under the title.
    block(width: 100%, sticky: true, above: 1em, below: 0.8em,
      pad(left: heading-tab, hang(heading-tab, strong(it.body))))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])

/// The authority groups, in the order of the table of authorities.
#let toa-groups = (
  (kind: "case", title: "Cases"),
  (kind: "statute", title: "Statutes"),
  (kind: "rule", title: "Rules"),
)

/// Page numbers where each authority is cited: the link in the body leaves a `toa-hit` tag
/// (see `show link` below). Body pages are numbered from the caption page on, so the
/// counter is the printed number.
#let toa-pages(key) = {
  let hits = query(<toa-hit>).filter(h => h.value == key)
  let pages = hits.map(h => counter(page).at(h.location()).first())
  pages.dedup().sorted()
}

#let toa-line(key, a) = {
  let pages = toa-pages(key)
  let name = if a.kind == "case" { emph(a.name) + [, ] + inl(a.cite) } else { inl(a.cite) }
  let where = if pages.len() == 0 { [—] }
    else if pages.len() >= passim-threshold { [passim] }
    else { pages.map(str).join(", ") }
  block(width: 100%, above: 0.4em, below: 0pt, hang(heading-tab, {
    name
    h(0.6em)
    dot-leader
    box(width: 6em, align(right, where))
  }))
}

#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  context {
    for g in toa-groups {
      // only authorities cited in the body are listed (a listed authority with no page is a gap)
      let keys = authorities.keys().filter(k => authorities.at(k).kind == g.kind and toa-pages(k).len() > 0)
      if keys.len() == 0 { continue }
      block(above: 1em, below: 0.4em, strong(g.title))
      let sorted = keys.sorted(key: k => lower(authorities.at(k).at("name", default: authorities.at(k).cite)))
      for k in sorted { toa-line(k, authorities.at(k)) }
    }
  }
}

// ---------------------------------------------------------------------------
// Caption page
// ---------------------------------------------------------------------------

/// Counsel block, single-spaced, top left (DUCivR 10-1; the signing attorney's bar number and contact).
#let counsel-block(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  for c in meta.counsel {
    for l in (..c.names, ..c.lines) { [#l \ ] }
  }
  v(1.2em)
}

#let caption-table(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  let left = stack(dir: ttb, spacing: 0.3em, ..meta.caption.map(c => block(width: 100%, {
    for n in c.names { [#n \ ] }
    if "designation" in c { [#h(2em)#c.designation] }
  })))
  let right = block(width: 100%, inset: (left: 0.2in), {
    [#meta.bankruptcy_case \ ]
    [#meta.chapter \ ]
    v(0.8em)
    [#meta.judge \ ]
    v(0.8em)
    [#meta.adversary]
  })
  grid(
    columns: (3fr, 2fr),
    gutter: 0pt,
    block(width: 100%, inset: (right: 0.2in, bottom: 0.6em), stroke: (right: 0.7pt, bottom: 0.7pt), left),
    right,
  )
}

#let caption-page(meta) = {
  counsel-block(meta)
  align(center, strong[#court-lines.at(0) \ #court-lines.at(1)])
  v(1.2em)
  caption-table(meta)
  v(0.8em)
  align(center, strong(inl(need(meta, "brief_title"))))
  v(0.6em)
}

// ---------------------------------------------------------------------------
// Signature, certificates
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [DATED this #need(meta, "date").]
    v(1.2em)
    pad(left: 3in, {
      for l in sig.lines { [#l \ ] }
      v(1.4em)
      [/s/ #sig.signer \ ]
      [#sig.signer \ ]
      [#sig.for]
    })
  })
}

#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none)[Certificate of Compliance]
  set par(first-line-indent: (amount: para-indent, all: true), leading: body-leading, spacing: body-leading, justify: false)
  [Pursuant to DUCivR 7-1(a)(4), as incorporated by LBR 1001-1(a), I certify that this Motion contains #group-digits(words) words, excluding the caption, table of contents, table of authorities, signature block, certificate of compliance, and certificate of service, as counted by the word-processing system used to prepare it, and therefore complies with the applicable word limit.]
  signature-block(meta)
}

#let certificate-of-service(meta) = {
  let svc = meta.service
  heading(level: 1, numbering: none)[Certificate of Service]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [I certify that on the #svc.at("date", default: need(meta, "date")), I caused a true and correct copy of the foregoing to be served on the following parties of record through the Court’s CM/ECF electronic filing system:]
  for r in svc.at("registered", default: ()) {
    block(above: 0.5em, breakable: false, pad(left: 0.5in, [#r]))
  }
  block(above: 1.2em, breakable: false, pad(left: 3in, [/s/ #need(meta, "signature").signer]))
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let utb-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "bankruptcy_case", "chapter", "judge", "adversary", "brief_title", "counsel", "signature", "date", "word_processor", "typeface") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- sections: one initial section stating the relief sought; conclusion last ----
  let titles = md.matches(regex("(?m)^#[ \t]+(.*?)[ \t]*$")).map(m => lower(m.captures.at(0)).trim())
  let pos = 0
  for pat in required-sections {
    let rest = titles.slice(pos)
    let k = rest.position(t => t.match(regex(pat)) != none)
    if k == none { panic("utb-motion-brief: a " + doc-kind + " needs a section matching `" + pat + "` (in this order; DUCivR 7-1)") }
    pos = pos + k + 1
  }
  if titles.first().match(regex("^introduction")) == none {
    panic("utb-motion-brief: the relief sought must be stated in the first section (DUCivR 7-1)")
  }

  // ---- length: DUCivR 7-1(a)(4)(A) ----
  let words = count-words(md)
  if words > word-limit {
    panic("utb-motion-brief: the motion has " + str(words) + " words; DUCivR 7-1(a)(4)(A) allows " + str(word-limit))
  }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set page(paper: "us-letter", margin: page-margin, numbering: "1", number-align: center, footer-descent: 30%)
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: none)
  set footnote.entry(
    gap: 0.5em, clearance: 0.9em, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size)   // typst's default is 0.85em; the footnotes keep the body size
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    it.body
  }))
  // Never break inside a token of adjacent parentheses ("60(b)(5)") or between a section sign
  // or pilcrow and its number. Unbreakable boxes keep the extracted text the author's characters.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§¶]+ \\S+"): it => box(it)
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      if key not in authorities { panic("utb-motion-brief: the citation `" + key + "` is not in the frontmatter `authorities`") }
      it.body + [#metadata(key)<toa-hit>]
    } else { it.body }
  }

  // ---- caption page ----
  caption-page(meta)
  pagebreak()

  // ---- table of contents ----
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  // typst's own entry layout: wrapped titles and the page number stay in order, leaders fill the gap
  show outline.entry: set block(above: 0.45em, below: 0pt)
  outline(title: none, depth: 3, indent: n => (n - 1) * heading-tab)
  pagebreak()

  // ---- table of authorities (its page numbers come from the body) ----
  toa-section(authorities)
  pagebreak()

  // ---- body ----
  {
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    render(md)
  }
  // The signature block follows the conclusion.
  signature-block(meta)

  // ---- certificates ----
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  if meta.at("service", default: (:)).at("certificate", default: false) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
