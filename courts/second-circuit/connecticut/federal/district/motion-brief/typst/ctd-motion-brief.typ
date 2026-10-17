// U.S. District Court, District of Connecticut (ctd): memorandum of law in support of a motion
// (Rule 12(b) motion to dismiss, or any other motion with a memorandum).
//
// Rule-driven and content-agnostic. Requirement IDs (CTD-...) refer to ../README.md, which quotes the
// rule text (D. Conn. Local Rules 7(a), 7(d), 10; Fed. R. Civ. P. 7(b), 10, 12(b); the Electronic Filing
// Policies and Procedures). No case-specific text, no coordinates measured off the exemplar, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter of
// the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = "Liberation Serif"     // CTD-FORM-003: the rules name no font (see README); Times New Roman substitute per docs/FONTS.md, vendored in fonts/
#let type-size = 12pt                // CTD-FORM-002: text at least 12 point (L.R. 7(a)(5))
#let footnote-size = 10pt            // CTD-FORM-002: footnotes at least 10 point (L.R. 7(a)(5))
#let line-pitch = 27.6pt             // CTD-FORM-001: double spacing = 2 x 13.8 pt, the single line of 12 pt Times in Word
#let body-leading = 1.645em          // gap between lines of body text; with Liberation Serif's line box (0.655 em) it gives line-pitch
#let single-leading = 0.5em          // headings, captions, footnotes, block quotes, tables, signature blocks: single spaced
#let margin = 1in                    // CTD-FORM-004: at least one inch on every side (L.R. 10)
#let margins = (top: margin, bottom: margin, x: margin)
#let para-indent = 0.5in             // first-line indent of body paragraphs
#let heading-tab = 0.5in
#let passim-threshold = 7            // authority cited on this many pages or more: "passim"
#let caption-left = 3.3in            // width of the party column of the caption

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("ctd-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ctd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// A block of single-spaced lines (counsel, caption, signature).
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if type(i) == str { inl(i) } else { i }))
}

// ---------------------------------------------------------------------------
// Headings: numbering and styles (CTD-CONT-001)
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "A.", 3 "1.", 4 "a.". Level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("A.", k) }
  else if lv == 3 { numbering("1.", k) }
  else if lv == 4 { numbering("a.", k) }
  else { "" }
}

/// Left edge of a heading's label: level 2 at the margin, each deeper level half an inch in.
#let label-indent(level) = (level - 2) * heading-tab

// ---------------------------------------------------------------------------
// Tables of contents and authorities (CTD-CONT-003)
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
  ("rule", "Federal Rules"),
  ("regulation", "Regulations"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))

/// Table of authorities, built from the `toa:` links found in the body (CTD-CONT-003).
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  align(right, block(above: 0.3em, below: 0pt, strong[Page(s)]))
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("ctd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
// Cover: court title, caption, title of the paper (CTD-FIRST-001..003)
// ---------------------------------------------------------------------------

#let caption-table(meta) = {
  let sides = need(meta, "caption")
  let left = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    for (i, side) in sides.enumerate() {
      for n in side.names { inl(n); parbreak() }
      pad(left: 1.5in, inl(side.designation))
      if i < sides.len() - 1 { v(line-pitch * 0.5); [v.]; v(line-pitch * 0.5) }
    }
  }
  let right = {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    [Case No. #need(meta, "case_number")]
    v(line-pitch * 0.5)
    [Date: #need(meta, "date")]
    v(line-pitch * 0.5)
    strong(upper(inl(need(meta, "brief_title"))))
  }
  table(
    columns: (caption-left, 1fr),
    inset: 0pt,
    column-gutter: 0.2in,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 0.1in, bottom: 0.8em, left),
    pad(left: 0.1in, top: 0.3em, right),
  )
}

/// Optional legend in the lower margin of the cover (L.R. 7(a)(1): whether oral argument is requested).
#let oral-argument-legend(meta) = {
  if "oral_argument" in meta and meta.oral_argument != none {
    place(bottom + left, dy: -0.3in, text(weight: "bold", upper("Oral argument " + meta.oral_argument)))
  }
}

#let cover(meta) = page(numbering: none, footer: none, margin: margins, {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(
    need(meta, "court").map(l => [#l]).join(linebreak())
  )))
  v(line-pitch)
  caption-table(meta)
  oral-argument-legend(meta)
})

// ---------------------------------------------------------------------------
// Signature block and certification (CTD-SIG-001: L.R. 10; EFPP XI.B)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let signers = (sig,) + sig.at("others", default: ())
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (2.6in, 1fr), column-gutter: 0.2in, [Dated: #need(meta, "date")], {
      [Respectfully submitted,]
      for s in signers {
        v(line-pitch)
        line-stack(("BY: /s/ " + s.signer,))
        linebreak()
        let name-line = if "bar" in s { s.signer + ", Fed. Bar No. " + s.bar } else { s.signer }
        line-stack((name-line,) + s.at("lines", default: ()))
      }
    })
  })
}

#let certification-block(meta) = {
  let c = meta.at("certification", default: none)
  if c != none {
    block(breakable: false, above: line-pitch, {
      heading(level: 1, numbering: none, outlined: false)[Certification of Service]
      par(first-line-indent: 0pt, leading: body-leading, spacing: 0pt, inl(c.text))
      v(line-pitch)
      grid(columns: (1fr, 3.2in), [], {
        line-stack(("/s/ " + c.signer,))
        linebreak()
        line-stack((c.signer,) + c.at("lines", default: ()))
      })
    })
  }
}

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let running-footer(meta) = context {
  let loc = here()
  align(center, text(size: type-size, numbering(loc.page-numbering(), ..counter(page).get())))
}

#let ctd-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "court", "caption", "brief_title", "date", "signature") {
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
  )
  set par(
    leading: body-leading, spacing: body-leading,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  // The numbering function is what steps the heading counter; the labels are drawn by the show rule below.
  set heading(numbering: heading-num)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)
  // Block quotations are single spaced and indented (L.R. 7(a)(5) exempts block quotes from double spacing).
  show quote.where(block: true): it => pad(left: 0.5in, right: 0.5in, par(
    first-line-indent: 0pt, leading: single-leading, spacing: line-pitch * 0.5, justify: false, it.body,
  ))
  // Each paragraph after the first in a list is double spaced like body text.
  set enum(numbering: "1)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  show enum: set par(first-line-indent: 0pt)
  show list: set par(first-line-indent: 0pt)

  // Authority links: a link whose target is `toa:KEY` is recorded with the page it starts on.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      let key = it.dest.slice(4)
      [#it.body#metadata(key)<toa-hit>]
    } else {
      it
    }
  }

  // Headings are single spaced (L.R. 7(a)(5) exempts headings); level 1 centered, level 2+ hanging labels.
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    if it.level == 1 {
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true, {
        set text(size: type-size)
        align(center, strong(upper(it.body)))
      })
    } else {
      let ind = label-indent(it.level)
      block(width: 100%, above: line-pitch * 0.5, below: line-pitch * 0.5, sticky: true, {
        set text(size: type-size)
        hang(ind + heading-tab, {
          h(ind)
          box(width: heading-tab, lab)
          strong(it.body)
        })
      })
    }
  }

  cover(meta)
  page(numbering: "i", footer: running-footer(meta), margin: margins, {
    counter(page).update(1)
    toc-section()
    pagebreak()
    toa-section(authorities)
  })
  page(numbering: "1", footer: running-footer(meta), margin: margins, {
    counter(page).update(1)
    cmarker.render(md, raw-typst: false, smart-punctuation: true)
    signature-block(meta)
    certification-block(meta)
  })
}
