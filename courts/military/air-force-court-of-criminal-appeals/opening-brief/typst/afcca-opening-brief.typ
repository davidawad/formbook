// U.S. Air Force Court of Criminal Appeals: brief (doc type set in the parameter block).
//
// Rule-driven and content-agnostic. Requirement IDs (AFCCA Rule 17.1, 17.3, 18.1, 18.3; Appendix A) refer to
// ../README.md. No case-specific text, no coordinates measured off any filed brief, no forced line breaks.
// The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of the same file
// (schema: ../README.md, "Markdown contract").
//
// This file is identical in the opening-brief and answering-brief folders except for `doc-kind`.

#import "@preview/cmarker:0.1.10"
#import "../../../../../lib/typst/tables.typ": leader-row

// ---------------------------------------------------------------------------
// Doc-type parameters (the only part that differs between the two copies)
// ---------------------------------------------------------------------------

#let doc-kind = "opening-brief"
#let required-sections = (                 // Appendix A (brief on behalf of appellant); Rule 18.3 (answer: same format).
  "^(assignments? of error|issues presented)$",
  "^(additional )?statement of (the )?case$",
  "^(additional )?argument(s)?$",
)
#let roman-sections = (                    // Sections whose level-2 headings are numbered I., II., ... (Appendix A; Rule 18.3).
  "assignments of error", "assignment of error", "issues presented",
  "argument", "additional arguments", "reply argument",
)
#let unnumbered-titles = (                 // Sub-headings the filings leave unnumbered.
  "standard of review", "law and analysis", "law & analysis", "additional facts",
)

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let court-line = "IN THE UNITED STATES AIR FORCE COURT OF CRIMINAL APPEALS"   // Appendix A
#let honorable = "TO THE HONORABLE, THE JUDGES OF THE UNITED STATES AIR FORCE COURT OF CRIMINAL APPEALS:"   // Appendix A
#let font-family = ("Times New Roman", "Liberation Serif")           // Rule 17.1(a): proportional type. Vendored in /fonts (see README, Known gaps).
#let type-size = 12pt                      // Rule 17.1(a): proportional 12-point type, everywhere, footnotes included.
#let body-leading = 0.94em                 // Rule 17.1(a): double-spaced. Calibrated on the render (README, Page review).
#let single-leading = 0.12em               // Block quotations, footnotes, headings, caption, TOC/TOA: single-spaced.
#let page-margin = 1in                     // Rule 17.1(a): at least one inch on all four sides.
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let toc-depth = 4
#let passim-threshold = 7                  // An authority cited on this many pages or more prints "passim".
#let index-threshold = 30                  // Rule 18.1: briefs over 30 pages need a subject index and a table of authorities.
#let page-limit = 50                       // Rule 17.3: filings shall not exceed 50 pages, excluding indices, attachments, appendices.

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
  if key not in meta { panic("afcca-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("afcca-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Put an invisible `tag` right after the first word of `c`, keeping any emphasis around it.
/// (A tag placed before a citation that starts a line can file under the previous line's page.)
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

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
/// (Must be an explicit `par`: a `set par(hanging-indent)` inside a block is ignored by typst 0.15.)
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

// ---------------------------------------------------------------------------
// Headings: numbering and styles (Appendix A; Rule 18.3)
// ---------------------------------------------------------------------------

/// True when the level-1 section that contains `loc` is one whose point headings are roman-numbered.
#let roman-section(loc) = {
  let tops = query(selector(heading.where(level: 1)).before(loc, inclusive: true))
  tops.len() > 0 and lower(plain(tops.last().body)).trim() in roman-sections
}


/// True in the sections whose point headings are a run of short items (AOE, issues): those are not kept
/// with the next heading, or the whole run would move to the next page as one block.
#let chained-section(loc) = {
  let tops = query(selector(heading.where(level: 1)).before(loc, inclusive: true))
  tops.len() > 0 and lower(plain(tops.last().body)).trim() in ("assignments of error", "assignment of error", "issues presented")
}

#let unnumbered(h) = lower(plain(h.body)).trim() in unnumbered-titles

/// Printed label of a sub-heading inside a roman section: I. / A. / 1. / a. (none for unnumbered titles).
/// The count restarts after the nearest higher-level heading, and skips unnumbered titles.
#let heading-label(h) = {
  if h.level == 1 or unnumbered(h) { return none }
  let loc = h.location()
  if not roman-section(loc) { return none }
  let before = query(selector(heading).before(loc, inclusive: false))
  let start = 0
  for (i, x) in before.enumerate() {
    if x.level < h.level { start = i + 1 }
  }
  let n = 1 + before.slice(start).filter(x => x.level == h.level and not unnumbered(x)).len()
  if h.level == 2 { numbering("I.", n) }
  else if h.level == 3 { numbering("A.", n) }
  else if h.level == 4 { numbering("1.", n) }
  else if h.level == 5 { numbering("a.", n) }
  else { panic("afcca-brief: headings deeper than level 5 are not supported") }
}

#let heading-tab-w = heading-tab

#let style-heading(it) = {
  set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, justify: false)
  set text(size: type-size)
  if it.level == 1 {
    // Section headings: bold, centered, as typed.
    block(width: 100%, sticky: true, above: 1.4em, below: 1em, align(center, strong(it.body)))
  } else if it.outlined == false {
    // Caption, table-of-contents and table-of-authorities headings.
    block(width: 100%, sticky: true, above: 1.2em, below: 1em, align(center, strong(it.body)))
  } else {
    let lab = heading-label(it)
    if lab == none {
      // Unnumbered sub-heading: bold, centered in a roman section, flush left elsewhere.
      if roman-section(it.location()) {
        block(width: 100%, sticky: true, above: 1.1em, below: 0.9em, align(center, strong(it.body)))
      } else {
        block(width: 100%, sticky: true, above: 1.1em, below: 0.9em, strong(it.body))
      }
    } else if it.level == 2 {
      // Point heading (I., II.): the numeral on its own line, the text centered below it.
      block(width: 100%, sticky: not chained-section(it.location()), above: 1.2em, below: 1em,
        align(center, strong(lab) + linebreak() + strong(it.body)))
    } else {
      // Sub-heading: label in a fixed box, text hangs under the text.
      let ind = (it.level - 2) * heading-tab-w
      block(width: 100%, sticky: true, above: 1.1em, below: 0.9em, hang(ind + heading-tab-w, {
        h(ind)
        box(width: heading-tab-w, strong(lab))
        if it.level >= 4 { strong(emph(it.body)) } else { strong(it.body) }
      }))
    }
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities (Rule 18.1: subject index and table of authorities)
// ---------------------------------------------------------------------------

/// One table-of-contents row, built from a heading element.
#let toc-entry(it) = {
  let hd = it.element
  let lab = heading-label(hd)
  let ind = if hd.level >= 2 { (hd.level - 2) * heading-tab } else { 0pt }
  link(hd.location(), block(width: 100%, above: if hd.level == 1 { 0.6em } else { 0.35em }, below: 0pt,
    leader-row({
      h(ind)
      if lab != none { box(width: heading-tab, lab) }
      hd.body
    }, it.page(),
      hang: ind + heading-tab, leading: single-leading, dot-gap: 0.16em, lead-gap: 0.8em, gutter: 0pt, page-width: 2.6em, min-leader: 1em)))
}

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  // The rule sits below the descender of "g", so no part of the heading hangs under it into the first entry.
  align(right, block(above: 0.3em, below: 0.75em, strong(underline(offset: 0.3em)[Page])))
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

#let sort-key(a) = lower(plain(inl(a.at("sort", default: a.at("name", default: "") + " " + a.cite))))
    .replace(regex("[^a-z0-9 ]"), "")

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("afcca-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
        if first { h(1fr); strong(underline(offset: 0.3em)[Page(s)]) }
      })
      first = false
      for (key, a) in members {
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        block(breakable: false, above: 0.7em, below: 0pt, width: 100%, leader-row({
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [,]
            linebreak()
          }
          inl(a.cite)
        }, page-text,
          hang: 0.35in, leading: single-leading, dot-gap: 0.16em, lead-gap: 0.8em, gutter: 0.3em, min-leader: 1em))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Caption page (Appendix A): court, caption, title, panel, number, date
// ---------------------------------------------------------------------------

#let caption-block(meta) = {
  let lhs = ()
  let first = true
  for side in need(meta, "caption") {
    if not first { lhs.push(pad(left: 0.9in, [v.])) }
    first = false
    for n in side.names { lhs.push(inl(n)) }
    lhs.push(pad(left: 1.6in, inl(side.designation)))
  }
  let rhs = (
    strong(inl(need(meta, "brief_title"))),
    [],
    inl(need(meta, "panel")),
    [],
    inl(need(meta, "case_number")),
    [],
    inl(need(meta, "date")),
  )
  grid(
    columns: (3.4in, 0.35in, 2.4in),
    align: (left + top, center + top, left + top),
    stack(dir: ttb, spacing: 0.3em, ..lhs),
    stack(dir: ttb, spacing: 0.3em, ..lhs.map(x => [)])),
    stack(dir: ttb, spacing: 0.3em, ..rhs),
  )
}

#let caption-page(meta, index) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(court-line))
  v(1.6em)
  caption-block(meta)
  v(1.6em)
  if "counsel" in meta {
    // The filer's counsel block, when the filing carries one on its caption page (a cover-page variant of Appendix A).
    for group in meta.counsel {
      align(center, block(width: 80%, {
        for line in group { inl(line) + linebreak() }
      }))
      v(0.6em)
    }
  }
  if not index {
    align(center, strong(inl(honorable)))
  }
}

// ---------------------------------------------------------------------------
// Signature block and certificate (Appendix A)
// ---------------------------------------------------------------------------

#let signature-block(sig) = {
  set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.35em, justify: false)
  block(breakable: false, width: 100%, {
    v(1em)
    let closing = sig.at("closing", default: "Respectfully submitted,")
    if closing != "" { pad(left: 3in, [#closing]) ; v(2.2em) }
    pad(left: 3in, {
      strong(inl(sig.signer))
      linebreak()
      for line in sig.lines { inl(line) + linebreak() }
    })
  })
}

#let certificate(meta) = {
  let c = need(meta, "certificate")
  heading(level: 1, numbering: none, outlined: false)[Certificate of Filing and Service]
  set par(first-line-indent: para-indent)
  [I certify that the original and copies of the foregoing were #inl(c.method) to the Court and served on #inl(c.recipient) on #inl(c.date).]
  signature-block((signer: c.signer, lines: c.lines, closing: ""))
}

// ---------------------------------------------------------------------------
// The brief
// ---------------------------------------------------------------------------

/// The body: the TO THE HONORABLE line, the sections, the signature block, and the certificate.
#let brief-body(meta, md, index) = {
  [#metadata(none)<body-start>]
  if index { align(center, strong(inl(honorable))) }
  cmarker.render(md, raw-typst: false, smart-punctuation: true, h1-level: 1)
  if "signature" in meta and meta.signature != none {
    signature-block(meta.signature)
  }
  [#metadata(none)<end-of-brief>]
  if "certificate" in meta and meta.certificate != none {
    pagebreak(weak: true)
    certificate(meta)
  }
}

#let afcca-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "brief_title", "panel", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))
  let index = meta.at("index", default: false)
  let excerpt = meta.at("excerpt", default: false)

  if md.match(regex("(?m)^#+[ \t]+[^\n]*toa:")) != none {
    panic("afcca-brief: citation links (toa:) are not allowed in headings; the table of contents would list them as authorities")
  }

  // ---- sections (Appendix A, in order). An excerpt sample carries only part of a filing: not checked. ----
  if not excerpt {
    let titles = md.matches(regex("(?m)^#[ \t]+(.*?)[ \t]*$")).map(m => lower(m.captures.at(0)).trim())
    let pos = 0
    for pat in required-sections {
      let rest = titles.slice(pos)
      let k = rest.position(t => t.match(regex(pat)) != none)
      if k == none { panic("afcca-brief: " + doc-kind + " needs a section matching `" + pat + "` (Appendix A, in order)") }
      pos = pos + k + 1
    }
    // Appendix A: each argument states the standard of review and ends in a prayer for relief (opening brief).
    if not lower(md).contains("standard of review") {
      panic("afcca-brief: Appendix A requires a statement of the applicable standard of review in the argument")
    }
    if doc-kind == "opening-brief" and not lower(md).contains("wherefore") {
      panic("afcca-brief: Appendix A requires a prayer for the specified relief after the argument (WHEREFORE)")
    }
  }

  // ---- document-wide settings ----
  set document(
    title: plain(inl(need(meta, "brief_title"))) + ", " + need(meta, "case_number"),
    author: meta.at("signature", default: (signer: "")).signer,
  )
  set page(paper: "us-letter", margin: page-margin, number-align: center, footer-descent: 30%,
    numbering: if index { none } else { "1" })   // Rule 17.1(a)
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: "1")   // numbers are computed by heading-label; this only makes the elements countable
  set footnote.entry(
    gap: 0.5em, clearance: 0.9em, indent: 0pt,
    separator: line(length: 30%, stroke: 0.5pt),
  )
  show footnote.entry: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  show quote.where(block: true): it => block(above: 1em, below: 1em, pad(left: para-indent, right: para-indent, {
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.9em)
    it.body
  }))
  // Never break inside a token of adjacent parentheses ("60(b)(5)") or between a section sign and its number.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("§ \\S+"): it => box(it)
  show heading: style-heading
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it.body }
  }

  // ---- caption page ----
  caption-page(meta, index)

  // ---- front matter (index only, lower-case roman, Rule 18.1), then the body from page 1 ----
  // Page-numbering rules are scoped to the block that sets them, so the body is built in the same block.
  if index {
    pagebreak()
    set page(numbering: "i")
    toc-section()
    pagebreak()
    toa-section(authorities)
    pagebreak()
    set page(numbering: "1")
    counter(page).update(1)
    brief-body(meta, md, index)
  } else {
    brief-body(meta, md, index)
  }

  // ---- length: Rule 17.3 (50 pages, excluding indices, attachments and certificates); Rule 18.1 (index over 30 pages) ----
  context {
    let start = counter(page).at(query(<body-start>).first().location()).first()
    let end = counter(page).at(query(<end-of-brief>).first().location()).first()
    let pages = end - start + 1
    if pages > page-limit {
      panic("afcca-brief: the brief runs " + str(pages) + " pages; Rule 17.3 allows " + str(page-limit))
    }
    if pages > index-threshold and not index {
      panic("afcca-brief: the brief runs " + str(pages) + " pages; Rule 18.1 requires a subject index and table of authorities over " + str(index-threshold) + " pages (set `index: true`)")
    }
  }
}
