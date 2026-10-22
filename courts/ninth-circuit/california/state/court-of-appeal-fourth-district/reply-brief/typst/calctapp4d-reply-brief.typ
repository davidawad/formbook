// California Court of Appeal: reply brief (appellant's reply).
//
// Rule-driven and content-agnostic. Rule numbers in comments refer to README.md, which gives
// the citation, the URL and the date verified for each. No case-specific text, no coordinates
// measured off any filed brief, no forced line breaks. The markdown body is rendered by cmarker;
// the metadata comes from the YAML frontmatter of the same file (schema: README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"          // Rule 8.74(b)(1): proportionally spaced serif. Vendored in /fonts.
#let type-size = 13pt                      // Rule 8.204(b)(4), 8.74(b)(1): 13-point, footnotes included.
#let body-leading = 0.65em                 // Rule 8.74(b)(2): lines 1.5 spaced. Measured on the render (README.md).
#let single-leading = 0.12em               // headings, block quotations, footnotes, TOC and TOA: single spaced.
#let side-margin = 1.5in                   // Rule 8.204(b)(6): 1-1/2 inches left and right.
#let top-margin = 1in                      // Rule 8.204(b)(6): 1 inch top and bottom.
#let para-indent = 0.5in
#let toc-depth = 5
#let passim-threshold = 7                  // an authority cited on this many pages or more: "passim".
#let word-limit = 14000                    // Rule 8.204(c)(1): computer-generated brief.

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
  if key not in meta { panic("calctapp4d-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("calctapp4d-reply-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Put an invisible `tag` right after the first word of `c`, keeping any emphasis around it.
/// Returns (content, placed). Why not simply put the tag in front: when a citation begins at the
/// start of a line, typst files a tag that sits before the first word under the PREVIOUS line, which
/// may be on the previous page, so the table of authorities would cite the wrong page.
#let tag-after-first-word(c, tag) = {
  if type(c) == str or c.func() == text {
    let t = if type(c) == str { c } else { c.text }
    let m = t.match(regex("^\\s*\\S+"))
    if m == none { return (c, false) }
    return ([#m.text#tag#t.slice(m.end)], true)
  }
  if c.func() == emph { let r = tag-after-first-word(c.body, tag); return (emph(r.first()), r.last()) }
  if c.func() == strong { let r = tag-after-first-word(c.body, tag); return (strong(r.first()), r.last()) }
  if c.func() == [].func() {
    let out = ()
    let placed = false
    for ch in c.children {
      if placed { out.push(ch) }
      else { let r = tag-after-first-word(ch, tag); out.push(r.first()); placed = r.last() }
    }
    return (out.join(), placed)
  }
  (c, false)
}

/// 11942 -> "11,942"
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
/// Markup characters are removed first; links keep their text; footnote text is counted.
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
// Headings: numbering scheme and styles
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: I. / A. / 1. / a. (level 2 to 5).
/// Same scheme in the statements and the argument: the sections are "Sections" of one brief.
#let heading-label(h) = {
  let n = counter(heading).at(h.location()).at(h.level - 1, default: 1)
  if h.level == 2 { numbering("I.", n) }
  else if h.level == 3 { numbering("A.", n) }
  else if h.level == 4 { numbering("1.", n) }
  else if h.level == 5 { numbering("a.", n) }
  else { panic("calctapp4d-reply-brief: headings deeper than level 5 are not supported") }
}

#let heading-tab = 0.5in

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)   // every heading is body size or larger
  if it.level == 1 {
    // Section headings: bold, capitals, centered.
    block(width: 100%, sticky: true, above: 1.2em, below: 1em,
      align(center, strong(upper(it.body))))
  } else if it.numbering == none {
    // Unnumbered sub-headings: bold, left.
    block(width: 100%, sticky: true, above: 1em, below: 0.8em, strong(it.body))
  } else {
    // Numbered sub-headings: label in a fixed box, text hangs under the text, bold.
    let ind = (it.level - 2) * heading-tab
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 1em, below: 0.8em, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, strong(lab))
      if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])
#let toc-page-width = 2em               // page-number column of the table of contents

/// One table-of-contents row, built from a heading element. The label sits where the heading's
/// own label sits in the body, and wrapped lines hang under the title text.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none and hd.level >= 2
  let ind = if hd.level >= 2 { (hd.level - 2) * heading-tab } else { 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  // Two columns: the title and its leader wrap inside the first, the page number sits in the second,
  // level with the last line. A long title therefore never pushes its page number onto a line of its own.
  link(hd.location(), block(width: 100%, above: if hd.level == 1 { 0.6em } else { 0.35em }, below: 0pt,
    grid(columns: (1fr, toc-page-width), column-gutter: 0.3em,
      hang(ind + heading-tab, {
        h(ind)
        if numbered { box(width: heading-tab, lab) }
        title
        h(0.6em)
        dot-leader
      }),
      align(right + bottom, it.page()),
    )))
}

/// The table of contents lists the body's headings: the ones after `<body-start>` and before
/// `<body-end>`. The certificates have headings too, but they are not listed (the exemplar stops at the Conclusion).
#let toc-section() = {
  heading(level: 1, numbering: none)[Table of Contents]
  align(right, block(above: 0.3em, below: 0pt, strong(underline[Page])))
  show outline.entry: toc-entry
  outline(
    title: none,
    target: selector(heading.where(outlined: true)).after(<body-start>).before(<body-end>),
    depth: toc-depth, indent: 0pt,
  )
}

#let toa-groups = (
  ("case", "Cases:"),
  ("constitution", "Constitutional Provisions:"),
  ("statute", "Statutes:"),
  ("regulation", "Regulations:"),
  ("rule", "Rules:"),
  ("other", "Other Authorities:"),
)

#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite))))
    .replace(regex("[^a-z0-9 ]"), "")

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("calctapp4d-reply-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 1em } else { 1.4em }, below: 0.2em, sticky: true, {
        set par(first-line-indent: 0pt)
        strong(title)
        if first { h(1fr); strong(underline[Page(s)]) }
      })
      first = false
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        block(breakable: false, above: 0.7em, below: 0pt, width: 100%, hang(0.35in, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [,]
            linebreak()
          }
          inl(a.cite)
          h(0.8em)
          dot-leader
          h(0.3em)
          page-text
        }))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Cover (Rule 8.204(b), 8.40 cover information; the cover is page 1 and is not printed with a number)
// ---------------------------------------------------------------------------

#let cover-body(meta, gap) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.35em, justify: false)
  set align(center)
  for l in need(meta, "court_lines") { strong(l); linebreak() }
  v(gap)
  // Caption on the left, Court of Appeal case number on the right.
  grid(columns: (4fr, 2fr), column-gutter: 0.25in,
    align(left, {
      set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.6em)
      let sides = need(meta, "caption")
      for (i, side) in sides.enumerate() {
        for name in side.names { inl(name); parbreak() }
        pad(left: 45%, inl(side.designation))
        if i < sides.len() - 1 { v(gap * 0.4); pad(left: 45%, [v.]); v(gap * 0.4) }
      }
    }),
    align(left + horizon, [Court of Appeal Case No. #need(meta, "case_number")]),
  )
  v(gap)
  // Superior court, judge, then the title of the brief.
  need(meta, "trial_court")
  linebreak()
  [Case No. #need(meta, "superior_case_number")]
  linebreak()
  inl(need(meta, "judge"))
  v(gap * 1.6)
  strong(upper(inl(need(meta, "brief_title"))))
  v(gap * 1.6)
  // Counsel (Rule 8.204(b): the party each attorney represents, with the attorney's State Bar number).
  align(left, pad(left: 50%, {
    set par(hanging-indent: 0pt, spacing: 0.5em)
    let groups = need(meta, "counsel")
    for g in groups {
      block(breakable: false, {
        for n in g.names { n; linebreak() }
        for l in g.at("lines", default: ()) { l; linebreak() }
      })
      v(0.5em)
    }
    emph(inl(need(meta, "counsel_for")))
  }))
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.2, 1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("calctapp4d-reply-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Signature, certificates (Rule 8.204(c)(1)), proof of service
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3in),
      [Dated: #need(meta, "date")],
      [#sig.firm \ s/#sig.signer \ #sig.signer \ #emph(inl(sig.role))])
  })
}

/// Certificate of word count: Rule 8.204(c)(1). The number is the count of the brief's text
/// (body, headings, footnotes) in `count-words`, not a figure typed in by hand.
#let certificate-of-word-count(meta, words) = {
  heading(level: 1, numbering: none)[Certificate of Word Count]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [Under Rule 8.204, subdivision (c)(1), of the California Rules of Court, I certify that the attached #emph(inl(need(meta, "brief_title"))) is 1½-spaced, typed in a proportionally spaced, 13-point font, and the brief contains #group-digits(words) words of text, including footnotes, as counted by the word-count feature of the word-processing program used to prepare the brief.]
  signature-block(meta)
}

/// Proof of service. Its wording follows the exemplar; the parties and the method come from the frontmatter.
#let proof-of-service(meta) = {
  let svc = need(meta, "service")
  heading(level: 1, numbering: none)[Proof of Service]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.8em, justify: false)
  [Case Name: #inl(need(meta, "case_name")) \
   Court of Appeal Case No.: #need(meta, "case_number") \
   Superior Court Case No.: #need(meta, "superior_case_number")]
  parbreak()
  [I, #svc.declarant, am employed in #svc.employed_in. I am over the age of eighteen (18) years and am not a party to the within action. My business address is #svc.business_address.]
  parbreak()
  [On #need(meta, "date"), I served a copy of the foregoing document described as: #need(meta, "brief_title"), on the following parties, as follows:]
  for s in svc.served {
    block(above: 0.6em, breakable: false, pad(left: 0.5in, [#s.name \ Served #s.method.]))
  }
  parbreak()
  [I declare under penalty of perjury under the laws of the State of California that the foregoing is true and correct.]
  parbreak()
  [Executed on #svc.executed.]
  block(above: 1.4em, breakable: false, pad(left: 50%, [#svc.declarant \ Declarant]))
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let calctapp4d-reply-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court_lines", "case_number", "case_name", "caption", "trial_court", "superior_case_number", "judge",
            "brief_title", "counsel", "counsel_for", "signature", "date", "service") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  // ---- count, then fail loudly on the word limit ----
  let words = count-words(md)
  if words > word-limit {
    panic("calctapp4d-reply-brief: the brief has " + str(words) + " words; Rule 8.204(c)(1) allows " + str(word-limit))
  }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set page(paper: "us-letter", margin: (x: side-margin, y: top-margin), number-align: center, footer-descent: 30%)
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
    set text(size: type-size)   // typst's default is 0.85em; Rule 8.204(b)(4) allows nothing under 13 pt
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    it.body
  }))
  // Typography that holds for any text: never break inside a token of adjacent parentheses
  // ("60(b)(5)"), and never between a section sign and its number. Unbreakable boxes keep the
  // extracted text the author's characters.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§¶]+ \\S+"): it => box(it)
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover (page 1) ----
  cover(meta)

  // ---- tables (pages 2 onward; arabic, counting the cover as page 1: Rule 8.74(a)(2)) ----
  set page(numbering: "1")
  toc-section()
  pagebreak()
  toa-section(authorities)
  pagebreak()

  // ---- body ----
  [#metadata(none)<body-start>]
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph is kept with it
    // (unless that last block is a heading or a footnote definition).
    let text-md = md.trim(at: end)
    let breaks = text-md.matches(regex("\n[ \t]*\n"))
    let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
    let tail = text-md.slice(cut)
    let keep = tail.len() > 0 and not tail.starts-with("#") and not tail.starts-with("[^")
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    if keep {
      render(text-md.slice(0, cut))
      block(breakable: false, { render(tail); signature-block(meta) })
    } else {
      render(text-md)
      signature-block(meta)
    }
  }
  [#metadata(none)<body-end>]

  // ---- certificates and proof of service ----
  pagebreak(weak: true)
  certificate-of-word-count(meta, words)
  pagebreak(weak: true)
  proof-of-service(meta)
}
