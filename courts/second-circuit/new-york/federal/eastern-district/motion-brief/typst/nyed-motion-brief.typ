// U.S. District Court, Eastern District of New York: memorandum of law in support of a motion
// (Fed. R. Civ. P. 12(b) motion with memorandum, Local Civil Rule 7.1(a)(2), (b), (c)).
//
// Rule-driven and content-agnostic. Requirement IDs (NYED-...) refer to ../README.md, which quotes
// the rule text. No case-specific text, no coordinates measured off the exemplar, no forced line
// breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter
// of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"         // Vendored in /fonts. No EDNY rule names a face (NYED-FORM-002).
#let type-size = 12pt                    // NYED-FORM-002: LCR 7.1(b)(1), 12-point type or larger.
#let footnote-size = 10pt                // NYED-FORM-002: LCR 7.1(b)(1), 10-point type allowed in footnotes.
#let line-pitch = 24pt                   // NYED-FORM-003: LCR 7.1(b)(3), double-spaced body text.
#let body-leading = 0.695em              // Gap between body lines; with EB Garamond 12 pt the baseline pitch is 24 pt (measured).
#let single-leading = 0.2em              // Caption, counsel block, headings, footnotes, TOC and TOA, signature block (7.1(b)(3)).
#let margins = (top: 1in, bottom: 1in, x: 1in)  // NYED-FORM-004: LCR 7.1(b)(2), at least one inch on all sides.
#let para-indent = 0.5in                 // First-line indent of body paragraphs (convention).
#let heading-tab = 0.5in                 // Width of a heading label (I., A., 1., a.) and the hang that follows it.
#let footer-size = 12pt                  // Page numbers; same size as text.
#let passim-threshold = 7                // Authority cited on this many pages or more: "passim" (convention).

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Inline markdown (italics, links, footnote marks) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nyed-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nyed-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

#let dot-leader = box(width: 1fr, repeat[.#h(0.25em)])

// ---------------------------------------------------------------------------
// Caption (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, side) in sides.enumerate() {
      if i > 0 {
        v(line-pitch * 0.5)
        pad(left: 1.2in, [-against-])
        v(line-pitch * 0.5)
      }
      for n in side.names { inl(n); linebreak() }
      pad(left: 1.9in, inl(side.designation))
    }
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [Case No. #need(meta, "case_number")]
    if "legend" in meta {
      v(line-pitch * 0.5)
      strong(upper(inl(meta.legend)))
    }
  }
  table(
    columns: (3.4in, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (top: 0.7pt, bottom: 0.7pt) } else { none },
    pad(top: 0.7em, bottom: 0.9em, right: 1em, left),
    pad(left: 1.2em, right),
  )
}

// ---------------------------------------------------------------------------
// Headings: level 1 centered bold capitals; levels 2 to 4 with a label column (I., A., 1., a.)
// ---------------------------------------------------------------------------

/// A heading element. `label` is the printed label ("" for none) and is kept in the heading body so
/// the table of contents can show it.
#let heading-element(level, label, text) = {
  let body = if label == "" { inl(text) } else { [#box(width: heading-tab, inl(label)) #inl(text)] }
  heading(level: level, outlined: true, body)
}

/// Numbered-label parse: "## I.  TITLE" gives ("I.", "TITLE"); a heading with no two-space gap has no label.
#let parse-heading(t) = {
  let m = t.match(regex("^(#+)\\s+(\\S+\\.)\\s{2,}(.+)$"))
  if m != none { (m.captures.at(0).len(), m.captures.at(1), m.captures.at(2)) }
  else {
    let p = t.match(regex("^(#+)\\s+(.+)$"))
    if p == none { panic("nyed-motion-brief: malformed heading: " + t) }
    (p.captures.at(0).len(), "", p.captures.at(1))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities (LCR 7.1(c): excluded from the word count)
// ---------------------------------------------------------------------------

/// One table-of-contents row from a heading element; wrapped lines hang under the title.
#let toc-entry(hd) = {
  let pg = numbering(hd.location().page-numbering(), ..counter(page).at(hd.location()))
  let ind = if hd.level == 1 { 0pt } else { (hd.level - 2) * heading-tab }
  link(hd.location(), block(width: 100%, above: 0.45em, below: 0pt, grid(
    columns: (1fr, auto), column-gutter: 0.4em,
    hang(ind + heading-tab, {
      h(ind)
      if hd.level == 1 { upper(hd.body) } else { hd.body }
      h(0.2em)
      dot-leader
    }),
    align(right + bottom, box(width: 2em, align(right, pg))),
  )))
}

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, block(above: 0.3em, below: 0pt, strong[Page]))
  context {
    for hd in query(heading.where(outlined: true)) {
      if hd.level <= 4 { toc-entry(hd) }
    }
  }
}

#let toa-groups = (
  ("case", "Cases"),
  ("statute", "Statutes"),
  ("rule", "Federal Rules of Civil Procedure"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))

/// Table of authorities, built from the `toa:` links found in the body.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  align(right, block(above: 0.3em, below: 0pt, strong[Page(s)]))
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("nyed-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 1em } else { 1.4em }, below: 0.2em, sticky: true, {
        set par(first-line-indent: 0pt, leading: single-leading)
        strong(title)
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
        block(breakable: false, above: 0.6em, below: 0pt, width: 100%, hang(0.35in, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [, ]
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

/// Inline content of a paragraph with its footnote references ("[^id]") turned into footnotes.
#let with-notes(t, defs) = {
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
    let id = m.captures.at(0)
    if id not in defs { panic("nyed-motion-brief: footnote [^" + id + "] has no definition") }
    out += inl(t.slice(pos, m.start))
    out += footnote(inl(defs.at(id)))
    pos = m.end
  }
  out + inl(t.slice(pos))
}

// ---------------------------------------------------------------------------
// Word count (LCR 7.1(c)): counts the body markdown, footnotes included, and nothing else
// ---------------------------------------------------------------------------

/// Words of the markdown body: link targets, footnote marks and markdown symbols are removed; a token
/// counts if it has a letter or digit. The word-processor count is the one that governs the filed
/// certificate; this is the template's own count, stated so the attorney can compare.
#let count-words(md) = {
  let t = md.replace(regex("\\]\\(toa:[^)]*\\)"), "]")
  t = t.replace(regex("\\[\\^[^\\]]+\\]:?"), " ")
  t = t.replace(regex("[#*_>]"), " ")
  t.split(regex("\\s+")).filter(w => w.find(regex("[A-Za-z0-9]")) != none).len()
}

// ---------------------------------------------------------------------------
// Cover, signature, certificates
// ---------------------------------------------------------------------------

#let cover(meta) = page(numbering: none, footer: none, margin: margins, {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(
    need(meta, "court").map(l => [#l]).join(linebreak())
  )))
  v(line-pitch)
  caption-table(meta)
  v(line-pitch * 2)
  align(center, strong(upper(inl(need(meta, "brief_title")))))
  v(1fr)
  if "counsel" in meta {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for l in meta.counsel { inl(l); linebreak() }
  }
})

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [Dated: #need(meta, "date")], {
      [Respectfully submitted,]
      v(line-pitch)
      [By: /s/ #sig.signer]
      linebreak()
      inl(sig.signer)
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

#let word-certificate(words) = block(breakable: false, above: line-pitch, {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Compliance]
  set par(first-line-indent: 0pt, leading: body-leading, justify: false)
  [I certify that this memorandum of law complies with the word-count limit of Local Civil Rule 7.1(c). Excluding the caption, table of contents, table of authorities, signature block, and certificates, it contains #words words, as counted by the template. The count must be confirmed against the word-processing program used to prepare the filed document.]
})

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let running-footer = context align(center, text(size: footer-size, counter(page).display()))

#let nyed-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "brief_title", "signature", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(paper: "us-letter")
  set document(
    title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      [#it.body#metadata(key)<toa-hit>]
    } else {
      it
    }
  }

  // Headings: level 1 centered bold capitals; deeper levels hang their label (LCR 7.1(a)(2): headings).
  show heading: it => {
    if it.level == 1 {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        align(center, strong(upper(it.body))))
    } else {
      let ind = (it.level - 2) * heading-tab
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        hang(ind + heading-tab, {
          h(ind)
          strong(it.body)
        }))
    }
  }

  cover(meta)
  page(numbering: "i", footer: running-footer, margin: margins, {
    counter(page).update(1)
    toc-section()
    pagebreak()
    toa-section(authorities)
  })
  page(numbering: "1", footer: running-footer, margin: margins, {
    counter(page).update(1)
    let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
    // Footnote definitions ("[^id]: text") are collected first and placed at their references.
    let defs = (:)
    let body-chunks = ()
    for c in chunks {
      let t = c.trim()
      let d = t.match(regex("^\\[\\^([^\\]]+)\\]:\\s*([\\s\\S]*)$"))
      if d != none { defs.insert(d.captures.at(0), d.captures.at(1)) } else { body-chunks.push(t) }
    }
    for t in body-chunks {
      if t.starts-with("#") {
        let (lvl, lab, txt) = parse-heading(t)
        heading-element(lvl, lab, txt)
      } else {
        par(first-line-indent: para-indent, leading: body-leading, spacing: 0pt, justify: false,
          with-notes(t, defs))
      }
    }
    signature-block(meta)
    // LCR 7.1(c): 8,750 words for a memorandum supporting a motion, unless the court permits more
    // (then `word_limit` in the frontmatter states the court's limit, converted at 350 words per page).
    let words = count-words(md)
    let limit = meta.at("word_limit", default: 8750)
    if words > limit {
      panic("nyed-motion-brief: " + str(words) + " words exceeds the LCR 7.1(c) limit of " + str(limit))
    }
    word-certificate(words)
  })
  if "service" in meta {
    page(numbering: "1", footer: running-footer, margin: margins, {
      heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
      set par(first-line-indent: para-indent, leading: body-leading, justify: false)
      inl(meta.service)
      signature-block(meta)
    })
  }
}
