// U.S. Judicial Panel on Multidistrict Litigation: motion for transfer under 28 U.S.C. 1407 with the
// memorandum of law in support. One PDF holds two case documents, as the filed exemplar does: the
// motion, then the memorandum (cover, tables, body, signature, certificate of service).
//
// Rule-driven and content-agnostic. Requirement IDs (JPML-...) refer to ../README.md, which quotes
// the Rules of Procedure of the Panel (effective Feb. 19, 2026). No case-specific text, no coordinates
// measured off the exemplar, no forced line breaks. The markdown body is rendered by cmarker; the
// metadata comes from the YAML frontmatter of the same file (schema: ../README.md).

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")   // JPML-FORM-002: 12-point font. EB Garamond is the only vendored family; see ../README.md.
#let type-size = 12pt              // JPML-FORM-002: 12-point for text and footnotes alike.
#let line-pitch = 24pt             // JPML-FORM-003: double spaced, text only. 27 lines fit on a body page.
#let body-leading = 0.694em        // gap between lines of body text; tuned so the line pitch is line-pitch (see ../README.md).
#let single-leading = 0.2em        // counsel blocks, caption, headings, footnotes, tables, signature blocks.
#let page-margin = 1in             // JPML-FORM-001: letter paper (8 1/2 x 11 in). 1 in margins are a style choice.
#let margins = (top: page-margin, bottom: page-margin, x: page-margin)
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let footer-size = 12pt            // page number only; the Panel's rules ask for numbered pages, not a footer title.
#let passim-threshold = 7          // authority cited on this many pages or more: "passim"
#let brief-page-limit = 20         // JPML-LIMIT-001 (Rule 3.2(a)(iii)): brief at most 20 pages, excluding tables and signature blocks.
#let memorandum-marker = "<!-- memorandum -->"  // separates the motion from the memorandum in the sample body

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("jpml-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("jpml-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

// ---------------------------------------------------------------------------
// Headings: numbering and styles
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

/// Left edge of a heading's label: level 2 at the margin, each deeper level half an inch in.
#let label-indent(level) = (level - 2) * heading-tab

// ---------------------------------------------------------------------------
// Tables of contents and authorities (not required by the Panel's rules; the filed exemplar has them)
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

/// Table of authorities, built from the `toa:` links found in the memorandum body.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  align(right, block(above: 0.3em, below: 0pt, strong[Page(s)]))
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("jpml-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
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
        // The page numbers sit in their own column so a wrapped entry can never push them onto a new line.
        block(breakable: false, above: 0.6em, below: 0pt, width: 100%, grid(
          columns: (1fr, auto), column-gutter: 0.4em,
          hang(0.35in, {
            if "name" in a {
              if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
              [, ]
            }
            inl(a.cite)
            h(0.8em)
            dot-leader
          }),
          align(right + bottom, box(width: 3em, align(right, page-text))),
        ))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Caption, counsel and signature (JPML-FIRST-*, JPML-SIG-*)
// ---------------------------------------------------------------------------

/// Heading of each case document (JPML-FIRST-001, Rule 3.2(a)(i)).
#let panel-heading(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(need(meta, "heading"))))
}

/// "IN RE:" block and MDL number, as the Panel's captions set them out (Rule 3.2(a)(i)).
#let caption(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  table(
    columns: (1fr, 2.2in),
    inset: 0pt,
    stroke: (x, y) => if x == 0 { (right: 0.7pt, bottom: 0.7pt) } else { none },
    pad(right: 1.2em, bottom: 1em, [IN RE:\ #strong(upper(need(meta, "in_re")))]),
    pad(left: 1.2em, align(center + horizon, need(meta, "mdl_no"))),
  )
}

/// Counsel blocks in two columns, alternating; each block is a list of lines (JPML-SIG-002).
#let counsel-grid(meta) = {
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  let blocks = need(meta, "counsel")
  let cols = ((), ())
  for (i, blk) in blocks.enumerate() { cols.at(calc.rem(i, 2)).push(blk) }
  grid(
    columns: (1fr, 1fr), column-gutter: 0.3in, row-gutter: 0pt,
    ..cols.map(col => {
      for blk in col {
        for l in blk { inl(l); linebreak() }
        v(single-leading * 3)
      }
    }),
  )
}

/// Signature block at the end of each case document. Rule 3.2(a)(ii) puts the designated
/// attorney's address, telephone and email and the party represented on the final page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(breakable: false, above: line-pitch, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    grid(columns: (1fr, 3.2in), [Dated: #need(meta, "date")], [
      Respectfully submitted,
      #v(line-pitch)
      /s/ #sig.signer
    ])
    v(line-pitch)
    counsel-grid(meta)
    v(single-leading * 3)
    inl(need(meta, "counsel_role"))
  })
}

/// Certificate of service (JPML-SERV-001): the form is generated; the service list itself is an attachment.
#let certificate(meta) = block(breakable: false, above: line-pitch, {
  heading(level: 1, numbering: none, outlined: false)[Certificate of Service]
  set par(first-line-indent: para-indent, leading: body-leading, justify: false)
  [The undersigned hereby certifies that on #need(meta, "date"), a true and correct copy of the above and foregoing was filed with the Clerk of the Panel through CM/ECF, which will serve it electronically on all counsel of record.]
  set par(first-line-indent: 0pt, leading: single-leading)
  v(line-pitch)
  [By: /s/ #need(meta, "signature").signer]
})

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

#let page-footer = context {
  let loc = here()
  set text(size: footer-size)
  align(center, numbering(loc.page-numbering(), ..counter(page).get()))
}

// ---------------------------------------------------------------------------
// Case documents
// ---------------------------------------------------------------------------

/// The motion: heading, caption, title, the motion text (markdown), signature block.
#let motion-document(meta, md) = page(numbering: "1", footer: page-footer, margin: margins, {
  counter(page).update(1)
  panel-heading(meta)
  v(line-pitch)
  caption(meta)
  v(line-pitch)
  block(width: 100%, {
    set par(first-line-indent: 0pt, leading: single-leading, justify: false)
    align(center, strong(upper(need(meta, "motion_title"))))
  })
  v(line-pitch)
  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
})

/// The memorandum cover: heading, caption, title, counsel, date. No page number.
#let memorandum-cover(meta) = page(numbering: none, footer: none, margin: margins, {
  panel-heading(meta)
  v(line-pitch)
  caption(meta)
  v(line-pitch)
  set par(first-line-indent: 0pt, leading: single-leading, justify: false)
  align(center, strong(upper(need(meta, "brief_title"))))
  v(line-pitch * 2)
  counsel-grid(meta)
  v(single-leading * 3)
  inl(need(meta, "counsel_role"))
  v(line-pitch)
  [Dated: #need(meta, "date")]
})

/// The memorandum body: markdown, then the signature block and certificate.
#let memorandum-body(meta, md, authorities) = {
  // The body of the memorandum starts at page 1; the page limit counts from here (JPML-LIMIT-001).
  [#metadata("start")<brief-body-start>]
  cmarker.render(md, raw-typst: false, smart-punctuation: true)
  // place() takes no line of the flow, so the marker cannot spill a page of its own (JPML-LIMIT-001).
  place(dx: 0pt, dy: 0pt, [#metadata("end")<brief-body-end>])
  signature-block(meta)
  certificate(meta)
}

#let jpml-motion-brief(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("heading", "mdl_no", "in_re", "motion_title", "brief_title", "counsel", "counsel_role", "signature", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))
  let parts = body.split(memorandum-marker)
  if parts.len() != 2 {
    panic("jpml-motion-brief: the sample body must hold the motion, then a line `" + memorandum-marker + "`, then the memorandum")
  }
  let (motion-md, brief-md) = parts

  // ---- document-wide settings ----
  set page(paper: "us-letter")   // JPML-FORM-001: 8 1/2 x 11 inch
  set document(
    title: need(meta, "brief_title"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
    top-edge: "ascender", bottom-edge: "descender",
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
  // The numbering function is what steps the heading counter; the labels are drawn by the show rule below.
  set heading(numbering: heading-num)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: type-size)
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

  motion-document(meta, motion-md)
  memorandum-cover(meta)
  page(numbering: "i", footer: page-footer, margin: margins, {
    counter(page).update(1)
    toc-section()
    pagebreak()
    toa-section(authorities)
  })
  page(numbering: "1", footer: page-footer, margin: margins, {
    counter(page).update(1)
    memorandum-body(meta, brief-md, authorities)
  })

  // ---- page limit: the memorandum body, from its first page to the end of the text (JPML-LIMIT-001) ----
  context {
    let s = query(<brief-body-start>).first().location()
    let e = query(<brief-body-end>).first().location()
    let n = counter(page).at(e).first() - counter(page).at(s).first() + 1
    if n > brief-page-limit {
      panic("jpml-motion-brief: the memorandum body runs " + str(n) + " pages; the limit is " + str(brief-page-limit) + " (Rule 3.2(a)(iii))")
    }
  }
}
