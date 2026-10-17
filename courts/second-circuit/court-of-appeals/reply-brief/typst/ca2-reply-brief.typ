// U.S. Court of Appeals for the Second Circuit: reply brief.
//
// Rule-driven and content-agnostic. Rule IDs (CA2-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed brief, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from
// the YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"          // CA2-FORM-004: serif, proportional; Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let type-size = 14pt                      // CA2-FORM-004: FRAP 32(a)(5)(A), 14-point or larger, everywhere.
#let docket-size = 72pt                    // CA2-COVER-001: Local Rule 32.1(a)(1), docket number at least one inch high.
#let body-leading = 1.336em                // double spacing: Liberation Serif's ascender-to-descender box (0.909em, set below)
                                           // plus this leading gives a 2.245em baseline pitch (31.4 pt at 14 pt), about 2.2 x type size.
#let single-leading = 0.516em              // headings, quotations, footnotes, TOC/TOA: single-spaced.
#let page-margin = 1in                     // CA2-FORM-002: FRAP 32(a)(4), at least one inch on all four sides.
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let toc-depth = 4
#let passim-threshold = 7                  // authority cited on this many pages or more: "passim"
#let word-limit = 7000                     // CA2-LEN-001: Local Rule 32.1(a)(4)(B), reply brief.

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
  if key not in meta { panic("ca2-reply-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ca2-reply-brief: the sample must start with a YAML frontmatter block") }
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

/// 6994 -> "6,994"
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
    else { panic("ca2-reply-brief: headings deeper than level 5 are not supported") }
  } else {
    if h.level == 2 { numbering("A.", n) }
    else if h.level == 3 { numbering("1.", n) }
    else if h.level == 4 { numbering("a.", n) }
    else if h.level == 5 { numbering("(1)", n) }
    else { panic("ca2-reply-brief: headings deeper than level 5 are not supported") }
  }
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// Left edge of a heading's label. The point headings of the Argument (level 2) start at the
/// margin; each further level steps in half an inch, as in the filed exemplar.
#let label-indent(h) = (h.level - 2) * heading-tab

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)   // typst's built-in heading sizes are not used; every heading is body size or larger
  if it.level == 1 {
    // Section headings: bold, capitals, centered.
    block(width: 100%, sticky: true, above: 1.5em, below: 1.1em, align(center, strong(upper(it.body))))
  } else if it.numbering == none {
    // Unnumbered sub-headings: bold, left.
    block(width: 100%, sticky: true, above: 1.2em, below: 0.9em, strong(it.body))
  } else {
    // Numbered headings: the label sits in a fixed box and the text hangs under it.
    // Point headings of the Argument are bold capitals; deeper levels are bold italic from level 4.
    let ind = label-indent(it)
    let lab = heading-label(it)
    let lab-styled = if it.level >= 4 { strong(emph(lab)) } else { strong(lab) }
    let txt = if in-argument(it.location()) and it.level == 2 { strong(upper(it.body)) }
      else if it.level >= 4 { strong(emph(it.body)) }
      else { strong(it.body) }
    block(width: 100%, sticky: true, above: 1.1em, below: 0.9em, hang(ind + heading-tab, {
      h(ind)
      box(width: heading-tab, lab-styled)
      txt
    }))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])

/// One table-of-contents row, built from a heading element. The label sits where the
/// heading's own label sits in the body, and wrapped lines hang under the title text.
#let toc-entry(it) = {
  let hd = it.element
  let numbered = hd.numbering != none and hd.level >= 2
  let ind = if hd.level >= 2 { label-indent(hd) } else { 0pt }
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
  align(right, block(above: 0.3em, below: 0pt, strong[Page]))
  show outline.entry: toc-entry
  outline(title: none, target: selector(heading.where(outlined: true)), depth: toc-depth, indent: 0pt)
}

// Table of authorities groups. Each entry: (kinds, printed title). Regulations and rules share a group.
#let toa-groups = (
  ((("case",), "Cases:")),
  ((("constitution",), "Constitutional Provisions:")),
  ((("statute",), "Statutes:")),
  ((("regulation", "rule"), "Rules & Regulations:")),
  ((("other",), "Other Authorities:")),
)

/// Sort key: case-insensitive, with digit runs compared by value ("9 U.S.C." before "10 U.S.C.").
#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite)))).replace(regex("\\d+"), m => "0" * calc.max(0, 10 - m.text.len()) + m.text)
    .replace(regex("[^a-z0-9 ]"), "")

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("ca2-reply-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kinds, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind in kinds and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 1em } else { 1.4em }, below: 0.2em, sticky: true, {
        set par(first-line-indent: 0pt)
        strong(title)
        if first { h(1fr); strong[Page(s)] }
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
            if a.kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
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
// Cover (FRAP 32(a)(2); CA2-COVER-001, -002)
// ---------------------------------------------------------------------------

/// One counsel group: names, then italic lines (role, firm, address), then its telephone number.
#let counsel-group(g) = block(breakable: false, {
  set align(left)
  for n in g.names { inl(n); linebreak() }
  for l in g.at("lines", default: ()) { h(0.5em); emph(inl(l)); linebreak() }
  h(0.5em); g.phone
})

#let cover-body(meta, gap) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.35em, justify: false)
  // Cover lines are set on the baseline: the descender room of the body text would push the
  // counsel block off the one-page cover.
  set text(bottom-edge: "baseline")
  set align(center)
  // The docket number, centered at the top (FRAP 32(a)(2)(A); Local Rule 32.1(a)(1)).
  text(size: docket-size, need(meta, "case_number"))
  v(gap)
  // The name of the court (FRAP 32(a)(2)(B)).
  [In the United States Court of Appeals for the Second Circuit]
  v(gap)
  // The title of the case (FRAP 32(a)(2)(C)): each side's names, then its designation at the right.
  let sides = need(meta, "caption")
  for (i, side) in sides.enumerate() {
    for name in side.names { inl(name); parbreak() }
    align(right, inl(side.designation))
    if i < sides.len() - 1 { v(gap * 0.3); [v.]; v(gap * 0.3) }
  }
  v(gap)
  // The nature of the proceeding and the court below (FRAP 32(a)(2)(D)).
  let proc = upper(inl(need(meta, "proceeding")))
  proc
  if "district_court_case" in meta or "judge" in meta {
    let parts = ()
    if "district_court_case" in meta { parts.push("No. " + meta.district_court_case) }
    if "judge" in meta { parts.push(meta.judge) }
    linebreak()
    upper(parts.join(", "))
  }
  v(gap)
  // The title of the brief (FRAP 32(a)(2)(E)).
  strong(upper(inl(need(meta, "brief_title"))))
  v(gap)
  // Counsel (FRAP 32(a)(2)(F): name, office address, telephone number), in two columns.
  let groups = need(meta, "counsel")
  let half = calc.ceil(groups.len() / 2)
  grid(columns: (1fr, 1fr), column-gutter: 0.5in,
    stack(dir: ttb, spacing: 1.1em, ..groups.slice(0, half).map(counsel-group)),
    stack(dir: ttb, spacing: 1.1em, ..groups.slice(half).map(counsel-group)))
  if "counsel_for" in meta {
    v(gap)
    emph(inl(meta.counsel_for))
  }
}

/// The cover is one page. The spacing between its parts is the only thing that gives:
/// the largest spacing at which the whole cover fits the page is used (the type size never shrinks).
#let cover(meta) = page(numbering: none, footer: none, layout(size => {
  let fits(g) = measure(block(width: size.width, cover-body(meta, g * 1em))).height <= size.height
  let g = (1.0, 0.8, 0.6, 0.45, 0.3, 0.2, 0.1, 0.0).find(fits)
  if g == none { panic("ca2-reply-brief: the cover does not fit on one page; shorten the counsel or party lines") }
  cover-body(meta, g * 1em)
}))

// ---------------------------------------------------------------------------
// Signature and certificates (FRAP 32(g); FRAP 25(d); Local Rule 32.1(a)(4)(B))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: 1.4em, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [Dated: #need(meta, "date")]
    v(1.2em)
    align(left, pad(left: 50%, {
      [Respectfully submitted,]
      v(1.2em)
      [/s/ #sig.signer]
      linebreak()
      upper(sig.signer)
      for l in sig.at("lines", default: ()) { linebreak(); emph(inl(l)) }
      if "counsel_for" in meta { v(0.6em); emph(inl(meta.counsel_for)) }
    }))
  })
}

#let signer-block(meta) = block(above: 1.2em, breakable: false, {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  [/s/ #need(meta, "signature").signer]
  linebreak()
  need(meta, "signature").signer
})

/// Certificate of Compliance: FRAP 32(g)(1) and Form 6 content, in the words of the Second Circuit
/// exemplar (CA2-CERT-001, -002). The word count is computed from the markdown body.
#let certificate-of-compliance(meta, words) = {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Compliance]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [This brief complies with the type-volume limitation set forth in Local Rule 32.1(a)(4)(B) because it contains #group-digits(words) words, excluding the parts of the brief exempted by Federal Rule of Appellate Procedure 32(f).]
  parbreak()
  [This brief complies with the typeface requirements of Federal Rule of Appellate Procedure 32(a)(5) and the type-style requirements of Federal Rule of Appellate Procedure 32(a)(6) because it was prepared in a proportionally spaced typeface using #need(meta, "typeface_software") in #need(meta, "typeface") #str(int(type-size / 1pt))-point font.]
  block(above: 1.6em, breakable: false, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [Dated: #need(meta, "date")]
    v(1.2em)
    signer-block(meta)
  })
}

/// Certificate of Service (FRAP 25(d)): the wording of the Second Circuit exemplar. Electronic
/// filing needs no proof of service under FRAP 25(d)(1); the certificate is the exemplar's convention.
#let certificate-of-service(meta) = {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 1em, justify: false)
  [I hereby certify that, on #need(meta, "date"), I electronically filed the foregoing #inl(need(meta, "brief_title")) with the United States Court of Appeals for the Second Circuit using the Court’s electronic filing system, which will serve copies on all registered counsel.]
  block(above: 1.6em, breakable: false, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [Dated: #need(meta, "date")]
    v(1.2em)
    signer-block(meta)
  })
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

#let ca2-reply-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "proceeding", "brief_title", "counsel", "signature", "date", "typeface", "typeface_software") { let _ = need(meta, k) }
  let authorities = meta.at("authorities", default: (:))

  // ---- length (Local Rule 32.1(a)(4)(B)) ----
  let words = count-words(md)
  if words > word-limit {
    panic("ca2-reply-brief: the brief has " + str(words) + " words; Local Rule 32.1(a)(4)(B) allows " + str(word-limit))
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
    set text(size: type-size)   // typst's default is 0.85em; FRAP 32(a)(5)(A) allows nothing under 14 pt
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
  show regex("§§? \\S+|¶¶? \\S+"): it => box(it)
  // A volume, the reporter and the page stay on one line ("32 C.F.R.", "9 U.S.C.", "684 F.3d").
  show regex("\\d+ (U\\.S\\.C\\.|C\\.F\\.R\\.|U\\.S\\.|F\\.[0-9a-z]+|Fed\\. Reg\\.)"): it => box(it)
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
    // Footnote definitions come after the text (they render at their reference), so the
    // last paragraph of the text is the one before the first definition.
    let text-md = md.trim(at: end)
    let defs = text-md.match(regex("\n\n\\[\\^[^\\]]+\\]:"))
    let body-end = if defs == none { text-md.len() } else { defs.start }
    let main-md = text-md.slice(0, body-end)
    let defs-md = text-md.slice(body-end)
    let breaks = main-md.matches(regex("\n[ \t]*\n"))
    let cut = if breaks.len() > 0 { breaks.last().end } else { 0 }
    let tail = main-md.slice(cut)
    let keep = tail.len() > 0 and not tail.starts-with("#") and not tail.contains("[^")
    let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)
    if keep {
      // The definitions go with the text that references them, in the same render.
      render(main-md.slice(0, cut) + defs-md)
      block(breakable: false, { render(tail); signature-block(meta) })
    } else {
      render(text-md)
      signature-block(meta)
    }
  }

  // ---- certificates (each on its own page; numbering continues) ----
  pagebreak(weak: true)
  certificate-of-compliance(meta, words)
  if meta.at("service", default: (:)).at("certificate", default: false) {
    pagebreak(weak: true)
    certificate-of-service(meta)
  }
}
