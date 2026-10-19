// U.S. District Court, Southern District of New York: memorandum of law in support of a motion (Fed. R.
// Civ. P. 12(b)). Cover, table of contents, table of authorities, body, signature block, certificate of
// compliance.
//
// Rule-driven and content-agnostic. Requirement IDs (NYSD-...) refer to ../README.md, which quotes the
// rules: S.D.N.Y. Joint Local Civil Rules (Jan. 2, 2026) 7.1(a)(2) (memorandum, headings), 7.1(b)
// (typeface, margins, spacing for all papers), 7.1(c) (length and word-count certificate). No case-specific
// text, no coordinates measured off the exemplar, no forced line breaks. The body is markdown rendered by
// cmarker; the metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice; see ../README.md)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")        // NYSD-FORM-002: the joint rules name no typeface; Times New Roman substitute per docs/FONTS.md. See README gaps.
#let type-size = 12pt                    // NYSD-FORM-002: 12-point type or larger, footnotes included (Local Civ. R. 7.1(b)(1) allows 10 pt footnotes; this uses 12).
#let body-leading = 1.091em              // NYSD-FORM-003: double-spaced (Local Civ. R. 7.1(b)(3)); text edges are ascender/descender (below), a 0.909em
                                         // line box in Liberation Serif, so 0.909em + 1.091em = 2.0em = a 24 pt pitch at 12 pt, also between paragraphs.
#let single-leading = 0.241em            // 0.909em + 0.241em = 1.15em (13.8 pt), single spacing: counsel block, caption, headings, footnotes, tables of contents and authorities, signature block.
#let line-pitch = 24pt
#let margins = (top: 1in, bottom: 1in, x: 1in)   // NYSD-FORM-004: at least one-inch margins on all sides (Local Civ. R. 7.1(b)(2)).
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let passim-threshold = 7                // an authority on this many pages or more is listed as "passim"

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Inline markdown (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nysd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nysd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

// ---------------------------------------------------------------------------
// Headings: numbering and styles (the memorandum's headings, NYSD-CONT-001)
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "I.", 3 "A.", 4 "1.", 5 "a.". Level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("I.", k) }
  else if lv == 3 { numbering("A.", k) }
  else if lv == 4 { numbering("1.", k) }
  else if lv == 5 { numbering("a.", k) }
  else { "" }
}

#let label-indent(level) = (level - 2) * heading-tab

// ---------------------------------------------------------------------------
// Tables of contents and authorities (Local Civ. R. 7.1: the tables are excluded from the word limit)
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.25em)])

/// One table-of-contents row from a heading element; wrapped lines hang under the title.
#let toc-entry(hd) = {
  let nums = counter(heading).at(hd.location()).slice(0, hd.level)
  let lab = heading-num(..nums)
  let ind = if hd.level == 1 { 0pt } else { label-indent(hd.level) }
  let pg = numbering(hd.location().page-numbering(), ..counter(page).at(hd.location()))
  // The page number sits in its own column so a wrapped title can never push it onto a new line.
  link(hd.location(), block(width: 100%, above: 0.45em, below: 0pt, grid(
    columns: (1fr, auto), column-gutter: 0.4em,
    hang(ind + heading-tab, {
      h(ind)
      if lab != "" { box(width: heading-tab, lab) }
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
  ("rule", "Rules"),
  ("regulation", "Regulations"),
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
        panic("nysd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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

// ---------------------------------------------------------------------------
// Cover: counsel block, court title, caption, title of the paper (Fed. R. Civ. P. 10(a))
// ---------------------------------------------------------------------------

#let counsel-block(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  for l in need(meta, "counsel") { inl(l); linebreak() }
}

#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, side) in sides.enumerate() {
      for n in side.names { inl(n); parbreak() }
      pad(left: 1.8in, inl(side.designation))
      if i < sides.len() - 1 { v(line-pitch * 0.5); align(center)[v.]; v(line-pitch * 0.5) }
    }
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for l in meta.at("legends", default: ()) { inl(l); linebreak() }
    v(line-pitch * 0.5)
    [#meta.at("file-label", default: "No.") #need(meta, "case_number")]
    if "judge" in meta { linebreak(); inl(meta.judge) }
    v(line-pitch * 0.5)
    strong(upper(inl(need(meta, "title"))))
  }
  table(
    columns: (1fr, 1fr),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 1em, left),
    pad(left: 1.2em, top: 0.3em, right),
  )
}

#let cover(meta) = page(numbering: none, footer: none, margin: margins, {
  counsel-block(meta)
  v(line-pitch)
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(need(meta, "court").map(l => [#l]).join(linebreak()))))
  v(line-pitch)
  caption-table(meta)
})

// ---------------------------------------------------------------------------
// Signature block and certificate of compliance (Local Civ. R. 7.1(c))
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [Dated: #meta.at("place", default: "New York, New York")#linebreak()#need(meta, "date")], {
      [Respectfully submitted,]
      v(line-pitch)
      for l in sig.at("firm", default: ()) { strong(inl(l)); linebreak() }
      v(line-pitch * 0.5)
      [s/ #inl(sig.signer)]
      linebreak()
      inl(sig.signer)
      linebreak()
      for l in sig.at("lines", default: ()) { inl(l); linebreak() }
    })
  })
}

/// Certificate of compliance: the word count is the one in the frontmatter, the typeface and margins
/// come from this template's own parameters (not typed in by hand).
#let certificate(meta) = {
  let count = need(meta, "word_count")
  heading(level: 1, numbering: none, outlined: false)[Certificate of Compliance]
  set par(first-line-indent: 0pt, leading: body-leading, justify: false)
  [1. This memorandum complies with the word-count limit of Local Civil Rule 7.1(c) because it contains #count words, excluding the caption, table of contents, table of authorities, signature block and this certificate, as counted by the word-processing program used to prepare it.]
  v(line-pitch * 0.5)
  [2. This memorandum complies with the formatting requirements of Local Civil Rule 7.1(b) because it is printed in #font-family.first(), #(type-size / 1pt)-point type, with one-inch margins on all sides, and is double-spaced except for headings, footnotes and block quotations.]
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [Dated: #meta.at("place", default: "New York, New York")#linebreak()#need(meta, "date")], {
      [Respectfully submitted,]
      v(line-pitch)
      [s/ #inl(need(meta, "signature").signer)]
    })
  })
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let nysd-motion-brief(meta, md) = {
  for k in ("court", "case_number", "caption", "title", "counsel", "signature", "date", "word_count") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  set page(paper: "us-letter")
  set document(
    title: need(meta, "title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  set heading(numbering: heading-num)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, separator: line(length: 30%, stroke: 0.5pt))
  // The note number is set in its own column so it is never run into the note text.
  show footnote.entry: it => {
    let n = counter(footnote).at(it.note.location()).first()
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em, justify: false)
    grid(columns: (auto, 1fr), column-gutter: 0.3em, super[#n], it.note.body)
  }

  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      [#it.body#metadata(key)<toa-hit>]
    } else {
      it
    }
  }

  // Headings: level 1 centered caps (PRELIMINARY STATEMENT, CONCLUSION); level 2 and deeper hang with their label.
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    if it.level == 1 {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        align(center, strong(upper(it.body))))
    } else {
      let ind = label-indent(it.level)
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true,
        hang(ind + heading-tab, {
          h(ind)
          box(width: heading-tab, lab)
          strong(it.body)
        }))
    }
  }

  cover(meta)
  page(numbering: "i", footer: align(center, context counter(page).display()), margin: margins, {
    counter(page).update(1)
    toc-section()
    pagebreak()
    toa-section(authorities)
  })
  page(numbering: "1", footer: align(center, context counter(page).display()), margin: margins, {
    counter(page).update(1)
    cmarker.render(md, raw-typst: false, smart-punctuation: true, h1-level: 1)
    signature-block(meta)
  })
  page(numbering: none, footer: none, margin: margins, certificate(meta))
}
