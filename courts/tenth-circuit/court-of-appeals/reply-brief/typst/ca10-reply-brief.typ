// U.S. Court of Appeals for the Tenth Circuit: reply brief (FRAP 28(c)).
//
// Rule-driven and content-agnostic. Requirement IDs (CA10-RB-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from
// the YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")     // FRAP 32(a)(5)(A): proportional serif face; Times New Roman substitute per docs/FONTS.md
#let type-size = 14pt                      // FRAP 32(a)(5)(A) and 10th Cir. R. 32(A): 14-point, footnotes too.
#let body-leading = 1.336em                // FRAP 32(a)(4): double-spaced (about 2.2 x the type size per line).
#let single-leading = 0.516em              // headings, quotations, footnotes, TOC/TOA: single-spaced.
                                           // Liberation Serif line box (ascender to descender) is 0.909em: body pitch 0.909 + 1.336 = 2.245em, single 1.425em.
#let page-margin = 1in                     // FRAP 32(a)(4): at least one inch on all four sides.
#let para-indent = 0.5in
#let toc-depth = 4
#let passim-threshold = 7                  // authority cited on this many pages or more: "passim"
#let word-limit = 6500                     // FRAP 32(a)(7)(B)(ii): half of the principal-brief limit (13,000)

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
  if key not in meta { panic("ca10-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ca10-reply-brief: the sample must start with a YAML frontmatter block") }
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
// Headings: numbering scheme and styles
// ---------------------------------------------------------------------------

/// True when the level-1 section that contains `loc` is the Argument.
#let in-argument(loc) = {
  let tops = query(selector(heading.where(level: 1)).before(loc, inclusive: true))
  tops.len() > 0 and lower(plain(tops.last().body)).trim() == "argument"
}

/// Printed label of a numbered heading, e.g. "I.", "A.", "1.", "a.".
/// Argument: I. / A. / 1. / a.   Elsewhere: A. / 1. / a. / (1)
#let heading-label(h) = {
  let loc = h.location()
  let c = counter(heading).at(loc)
  let n = c.at(h.level - 1, default: 1)
  if in-argument(loc) {
    if h.level == 2 { numbering("I.", n) }
    else if h.level == 3 { numbering("A.", n) }
    else if h.level == 4 { numbering("1.", n) }
    else if h.level == 5 { numbering("a.", n) }
    else { panic("ca10-reply-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("ca10-reply-brief: headings deeper than level 5 are not supported") }
  }
}

#let heading-tab = 0.5in

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// Left edge of a heading's label. Labels sit half an inch in from the margin; each further
/// level steps in half an inch more. In the Argument the level-2 point heading is centered, so
/// its sub-headings start at the first step.
#let label-indent(h) = {
  let first = if in-argument(h.location()) { 3 } else { 2 }
  (h.level - first + 1) * heading-tab
}

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)   // every heading is body size or larger
  if it.level == 1 {
    // Section headings: bold, capitals, centered, a little larger than the body.
    block(width: 100%, sticky: true, above: 1.5em, below: 1.1em,
      align(center, text(size: 1.15em, strong(upper(it.body)))))
  } else if it.numbering == none {
    // Unnumbered sub-headings: bold, left.
    block(width: 100%, sticky: true, above: 1.2em, below: 0.9em, strong(it.body))
  } else if in-argument(it.location()) and it.level == 2 {
    // Point headings: bold, centered, with the roman numeral (smallcaps() has no effect: Liberation Serif has no small capitals).
    block(width: 100%, sticky: true, above: 1.2em, below: 1em,
      align(center, strong(smallcaps(heading-label(it) + [ ] + it.body))))
  } else {
    // Sub-headings: label in a fixed box, text hangs under the text, bold (italic below level 3).
    let ind = label-indent(it)
    let lab = heading-label(it)
    block(width: 100%, sticky: true, above: 1.1em, below: 0.9em, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, if it.level >= 4 { strong(emph(lab)) } else { strong(lab) })
      if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities (FRAP 28(c): both are required in a reply brief)
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])

/// One table-of-contents row, built from a heading element. The label sits where the
/// heading's own label sits in the body, and wrapped lines hang under the title text.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none and hd.level >= 2
  let ind = if numbered { label-indent(hd) } else if hd.level >= 2 { (hd.level - 2) * heading-tab } else { 0pt }
  // The Argument's centered point heading has no body indent in the table; its label starts at the margin.
  if numbered and in-argument(hd.location()) and hd.level == 2 { ind = 0pt }
  let lab = if numbered { heading-label(hd) } else { none }
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  let hang-by = ind + heading-tab
  link(hd.location(), block(width: 100%, above: if hd.level == 1 { 0.6em } else { 0.35em }, below: 0pt,
    hang(hang-by, {
      h(ind)
      if numbered { box(width: heading-tab, lab) }
      title
      h(0.8em)
      dot-leader
      box(width: 2.6em, align(right, it.page()))
    })))
}

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 0.3em, below: 0pt, strong(underline[Page])))
  show outline.entry: toc-entry
  outline(title: none, target: selector(heading.where(outlined: true)), depth: toc-depth, indent: 0pt)
}

#let toa-groups = (
  ("case", "Cases:"),
  ("constitution", "Constitutional Provisions:"),
  ("statute", "Statutes:"),
  ("regulation", "Regulations:"),
  ("rule", "Rules:"),
  ("other", "Other Authorities:"),
)

/// Sort key: lowercased plain text without punctuation; digit runs zero-padded so "2 U.S.C." sorts
/// before "28 U.S.C.". (Parenthesised: a method chain on a new line after `#let` is not code.)
#let sort-key(a) = (
  lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite))))
    .replace(regex("[^a-z0-9 ]"), "")
    .replace(regex("\\d+"), m => "0" * calc.max(0, 8 - m.text.len()) + m.text)
)

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("ca10-reply-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
// Cover (FRAP 32(a)(2)(A)-(F); CA10-RB-COVER)
// ---------------------------------------------------------------------------

#let short-rule = align(center, line(length: 2in, stroke: 0.7pt))

#let cover-body(meta, gap) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.35em, justify: false)
  set align(center)
  v(gap * 0.6)
  // (A) the number of the case, centered at the top
  strong[No. #need(meta, "case_number")]
  v(gap)
  // (B) the name of the court
  strong[IN THE UNITED STATES COURT OF APPEALS\ FOR THE TENTH CIRCUIT]
  v(gap)
  // (C) the title of the case: each side's parties, the designation, and "v." between the sides
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    if i > 0 {
      if side.at("no-v", default: false) { v(gap * 0.6) }
      else { v(gap * 0.3); [v.]; v(gap * 0.3) }
    }
    for name in side.names { inl(name); parbreak() }
    align(left, pad(left: 50%, inl(side.designation)))
  }
  v(gap)
  short-rule
  v(gap)
  // (D) the nature of the proceeding and the court below
  inl(need(meta, "proceeding"))
  if "district_court_case" in meta or "judge" in meta {
    parbreak()
    [#if "district_court_case" in meta [D.C. No. #meta.district_court_case]#if "district_court_case" in meta and "judge" in meta [; ]#if "judge" in meta [#inl(meta.judge)]]
  }
  v(gap)
  short-rule
  v(gap)
  // (E) the title of the brief, identifying the party for whom it is filed
  strong(upper(inl(need(meta, "brief_title"))))
  v(gap)
  short-rule
  v(gap)
  // (F) counsel: name, office address, telephone number (the phone line goes with the last group)
  align(left, pad(left: 50%, {
    set par(hanging-indent: 0pt, spacing: 0.5em)
    let groups = need(meta, "counsel")
    for (gi, g) in groups.enumerate() {
      block(breakable: false, {
        for n in g.names { n; linebreak() }
        let lines = g.at("lines", default: ())
        if gi == groups.len() - 1 { lines = lines + (need(meta, "phone"),) }
        for l in lines { h(0.5em); emph(inl(l)); linebreak() }
      })
    }
  }))
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("ca10-reply-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Signature and certificates (Form 6; FRAP 25(a)(5), 10th Cir. R. 25.5; FRAP 25)
// ---------------------------------------------------------------------------

#let signature-line(meta) = [s/ #need(meta, "signature").signer]

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    align(left, pad(left: 50%, {
      [Respectfully submitted,]
      v(1.2em)
      signature-line(meta)
      linebreak()
      upper(sig.signer)
      for l in sig.at("lines", default: ()) { linebreak(); h(0.5em); emph(inl(l)) }
    }))
    if "date" in meta { v(0.8em); meta.date }
  })
}

#let form-sig-line(meta) = block(above: 1.6em, breakable: false, {
  set par(first-line-indent: 0pt, leading: single-leading)
  grid(columns: (1fr, 1fr), column-gutter: 1em,
    [#signature-line(meta)\ #text(size: type-size)[Signature]],
    [#meta.at("date", default: "")\ Date])
})

/// Certificate of Compliance, Form 6 wording (FRAP 32(g); 10th Cir. R. 32; CA10-RB-CERT-001).
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none)[Certificate of Compliance With Type-Volume Limit, Typeface Requirements, and Type Style Requirements]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [1. This document complies with the word limit of Fed. R. App. P. 32(a)(7)(B)(ii) because, excluding the parts of the document exempted by Fed. R. App. P. 32(f), this document contains #group-digits(words) words.]
  parbreak()
  [2. This document complies with the typeface requirements of Fed. R. App. P. 32(a)(5) and the type style requirements of Fed. R. App. P. 32(a)(6) because this document has been prepared in a proportionally spaced typeface using #meta.at("typeset_with", default: "Typst 0.15.0") in #int(type-size.pt())-point #font-family.]
  form-sig-line(meta)
}

/// Certificate of Digital Submission (10th Cir. R. 25.5; FRAP 25(a)(5)). Only when `digital_submission: true`.
#let certificate-of-digital-submission(meta) = {
  heading(level: 1, numbering: none)[Certificate of Digital Submission]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [I hereby certify that with respect to the foregoing:]
  parbreak()
  [(1) all required privacy redactions have been made per Fed. R. App. P. 25(a)(5) and 10th Cir. R. 25.5;]
  parbreak()
  [(2) this document is a native PDF document;]
  parbreak()
  [(3) the ECF submission is an exact copy of that document;]
  parbreak()
  [(4) the digital submission has been scanned for viruses with #need(meta, "virus_scanner"), and]
  parbreak()
  [(5) according to the program, this document is free of viruses.]
  form-sig-line(meta)
}

/// Certificate of Service. The ECF statement is always given; paper service to unregistered
/// participants is listed only when `service.unregistered` is given.
#let certificate-of-service(meta) = {
  let svc = meta.at("service", default: (:))
  heading(level: 1, numbering: none)[Certificate of Service]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [I hereby certify that on #need(meta, "date"), pursuant to Fed. R. App. P. 25, I electronically filed the foregoing using the Court’s CM/ECF system, which in turn caused electronic notifications of such filing to be sent to all counsel of record.]
  let unreg = svc.at("unregistered", default: ())
  if unreg.len() > 0 {
    parbreak()
    [I certify that I served the foregoing on this date by hand delivery, mail, third-party commercial carrier for delivery within 3 calendar days, or email to the following unregistered case participants:]
    for u in unreg { block(above: 0.7em, breakable: false, pad(left: 0.5in, [#u.name, #u.address])) }
  }
  form-sig-line(meta)
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca10-reply-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "phone", "signature", "date") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  // ---- word count (FRAP 32(a)(7)(B)(ii)); the certificate states it ----
  let words = count-words(md)
  if words > word-limit {
    panic("ca10-reply-brief: the reply brief has " + str(words) + " words; FRAP 32(a)(7)(B)(ii) allows " + str(word-limit))
  }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set page(paper: "us-letter", margin: page-margin, number-align: center, footer-descent: 30%)
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
    set text(size: type-size)   // typst's default is 0.85em; 10th Cir. R. 32(A): footnotes match the body
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    // marker, a thin space, then the note (typst's default runs them together)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    it.body
  }))
  // Typography that holds for any text: never break inside a token of adjacent parentheses
  // ("60(b)(5)"), and never between a section sign / pilcrow and its number. Done with
  // unbreakable boxes so the extracted text stays exactly the author's characters.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§¶] \\S+"): it => box(it)
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- cover ----
  cover(meta)

  // ---- front matter (lowercase roman) ----
  set page(numbering: "i")
  counter(page).update(1)
  toc-section()
  pagebreak()
  toa-section(authorities)

  // ---- body (arabic from 1) ----
  set page(numbering: "1")
  counter(page).update(1)
  {
    set heading(numbering: "1")
    // The signature block never stands alone on a page: the brief's last paragraph is
    // kept together with it (unless that last block is a heading or a footnote definition).
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

  // ---- certificates ----
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  if meta.at("digital_submission", default: false) {
    pagebreak(weak: true)
    certificate-of-digital-submission(meta)
  }
  pagebreak(weak: true)
  certificate-of-service(meta)
}
