// U.S. District Court for the Northern Mariana Islands: motion with memorandum of points and authorities.
// Rules: D.N.M.I. LR 5.2 (form: paper, numbered lines, double spacing, 12-point serif type, margins,
// top-right corner blank on page one, court title, caption, hearing date and time on page one), LR 5.2.b
// (authorities not on Westlaw or Lexis are attached), LR 7.1.d (length: 25 pages for a memorandum; a table of
// contents and a table of authorities above 10 pages); Fed. R. Civ. P. 12(b). See ../README.md for the rule text.
// Content-agnostic: no case-specific text here; the metadata and the body come from the sample.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LR 5.2.a: a serif font. Vendored in fonts/.
#let type-size = 12pt                   // LR 5.2.a: 12-point type or larger, footnotes included.
#let pitch = 24pt                       // LR 5.2.a: double spacing; the numbered lines are this pitch.
#let page-w = 8.5in                     // LR 5.2.a: 8.5 x 11 inch paper.
#let page-h = 11in
#let top-margin = 1.5in                 // LR 5.2.a: not less than 1.5 inches on the top.
#let left-margin = 1in                  // LR 5.2.a: one inch on the left-hand side (the line numbers sit in it).
#let right-margin = 0.5in               // LR 5.2.a: one-half inch on the right-hand side.
#let text-width = page-w - left-margin - right-margin
// 1.5 in top + 1 in bottom leaves 8.5 in: 25 double-spaced lines (25 x 24 pt). The footer sits below them.
#let lines-per-page = 25
#let bottom-margin = page-h - top-margin - lines-per-page * pitch
#let body-leading = 1.35em              // a 24 pt baseline pitch at 12 pt in EB Garamond (measured; see README.md)
#let single-leading = 0.5em             // counsel, caption, signature, footnotes, tables: about 13.8 pt at 12 pt
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let caption-left = 3.4in               // width of the party column of the caption
#let counsel-lines = 7                  // counsel block takes at least lines 1 to 7
#let passim-threshold = 7               // an authority cited on this many pages or more prints "passim"

// LR 5.2.d.1: the court's title, two lines, single-spaced and centered, at least 1.5 inches from the top.
#let court-title-lines = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN MARIANA ISLANDS")

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nmid-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, names with *et al.*, etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("nmid-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// A single-spaced paragraph whose continuation lines are indented by `indent`.
#let hang(indent, body) = par(
  hanging-indent: indent, first-line-indent: 0pt, leading: single-leading, justify: false, body,
)

/// Fill whole numbered lines: the block is rounded up to a multiple of `pitch`, so whatever follows
/// it stays on the grid of numbered lines.
#let on-grid(c, sticky: false) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, sticky: sticky, c)
}

/// One single-spaced line per item, stacked; the block is then rounded to the grid by the caller.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  // A single line is 0.65 em high; the spacing between items makes the 13.8 pt single pitch.
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

// ---------------------------------------------------------------------------
// Headings: numbering and styles (the memorandum's own scheme: I., 1., a., (1))
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "I.", 3 "1.", 4 "a.", 5 "(1)". Level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("I.", k) }
  else if lv == 3 { numbering("1.", k) }
  else if lv == 4 { numbering("a.", k) }
  else if lv == 5 { numbering("(1)", k) }
  else { "" }
}

#let label-indent(level) = (level - 2) * heading-tab

// ---------------------------------------------------------------------------
// Tables of contents and authorities (LR 7.1.d.1)
// ---------------------------------------------------------------------------

#let dot-leader = box(width: 1fr, repeat[.#h(0.25em)])

/// One table-of-contents row, on the grid; wrapped titles hang under the title and the page number has its own column.
#let toc-entry(hd) = {
  let nums = counter(heading).at(hd.location()).slice(0, hd.level)
  let lab = heading-num(..nums)
  let ind = if hd.level == 1 { 0pt } else { label-indent(hd.level) }
  let pg = numbering(hd.location().page-numbering(), ..counter(page).at(hd.location()))
  let title = if hd.level == 1 { upper(hd.body) } else { hd.body }
  // Measured at the width the title really gets: the label and the indent, and the page-number column, are not text.
  let hgt = measure(width: text-width - ind - heading-tab - 2.8em, title).height
  link(hd.location(), block(width: text-width, height: calc.ceil(hgt / pitch) * pitch, above: 0pt, below: 0pt, grid(
    columns: (1fr, auto), column-gutter: 0.4em,
    hang(ind + heading-tab, {
      h(ind)
      if lab != "" { box(width: heading-tab, lab) }
      title
      h(0.2em)
      dot-leader
    }),
    align(right + bottom, box(width: 2em, align(right, pg))),
  )))
}

#let toc-section() = {
  heading(level: 1, numbering: none, outlined: false)[Table of Contents]
  align(right, on-grid(strong[Page]))
  context {
    for hd in query(heading.where(outlined: true)) {
      if hd.level <= 4 { toc-entry(hd) }
    }
  }
}

#let toa-groups = (
  ("case", "Cases"),
  ("constitution", "Constitutional Provisions"),
  ("statute", "Statutes"),
  ("rule", "Rules"),
  ("regulation", "Regulations"),
  ("other", "Other Authorities"),
)

#let sort-key(a) = lower(a.at("name", default: a.at("cite", default: "")))

/// Table of authorities, built from the `toa:` links in the body. Every link must have a registry entry.
#let toa-section(authorities) = {
  heading(level: 1, numbering: none, outlined: false)[Table of Authorities]
  align(right, on-grid(strong[Page(s)]))
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("nmid-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: 0pt, below: 0pt, sticky: true, on-grid(strong(title)))
      for (key, a) in members {
        // Distinct printed page labels, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let loc = h.location()
          let label = numbering(loc.page-numbering(), ..counter(page).at(loc))
          if label not in pages { pages.push(label) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.join(", ") }
        block(breakable: false, width: 100%, on-grid(hang(0.35in, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [, ]
          }
          inl(a.cite)
          h(0.8em)
          dot-leader
          h(0.3em)
          page-text
        })))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// First page: counsel (lines 1-7), court title, caption with the hearing, the lead-in
// ---------------------------------------------------------------------------

#let counsel-block(meta) = context {
  // Lines 1-7 at least; a longer counsel block pushes the court title down (LR 5.2.c).
  let h = measure(width: 4.2in, line-stack(need(meta, "counsel"))).height
  block(width: 4.2in, height: calc.max(counsel-lines, calc.ceil(h / pitch)) * pitch,
    line-stack(need(meta, "counsel")))
}

#let court-title() = on-grid(align(center, text(weight: "bold", {
  court-title-lines.join(linebreak())
})))

/// Caption: the parties on the left (LR 5.2.d.2), the file number, the title of the paper and the hearing
/// date and time on the right (LR 5.2.d.3, 5.2.e).
#let caption-block(meta) = on-grid(grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    let versus = meta.at("versus", default: "v.")
    let rows = ()
    for (k, p) in need(meta, "caption").enumerate() {
      if k > 0 { rows.push(versus) }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(("CIVIL CASE NO. " + need(meta, "case_number"),))
    v(pitch * 0.5)
    text(weight: "bold", inl(need(meta, "brief_title")))
    v(pitch * 0.5)
    let hearing = need(meta, "hearing")
    line-stack((
      "Hearing Date: " + hearing.at("date", default: ""),
      "Hearing Time: " + hearing.at("time", default: ""),
      "Judge: " + hearing.at("judge", default: ""),
    ))
  }),
))

#let first-page(meta) = {
  counsel-block(meta)
  court-title()
  v(pitch)
  caption-block(meta)
  if "lead_in" in meta {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }
}

// ---------------------------------------------------------------------------
// Signature block (LR 5.2; the layout is a convention, the rules cite no form)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  on-grid(grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    [Date: #need(meta, "date")],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(pitch * 0.5)
      line-stack(sig.at("preamble", default: ()))
      v(pitch * 0.5)
      line-stack(("/s/ " + sig.signer, sig.signer) + sig.at("lines", default: ()))
    },
  ))
}

// ---------------------------------------------------------------------------
// Page furniture: numbered lines, pleading rules, footer
// ---------------------------------------------------------------------------

#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.3in, height: pitch,
        align(right, text(size: type-size, str(i)))))
  }
}

#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.12in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.08in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.08in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

#let footer-block(title, case-number) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 48pt,
  block(width: text-width, {
    set text(size: 10pt)
    align(center, context counter(page).display())
    v(4pt)
    grid(
      columns: (1fr, auto),
      upper(title),
      [CASE NO. #case-number],
    )
  }),
)

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let nmid-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("case_number", "caption", "counsel", "brief_title", "footer_title", "hearing", "signature", "date") {
    let _ = need(meta, k)
  }
  let authorities = meta.at("authorities", default: (:))

  // ---- document-wide settings ----
  set page(
    paper: "us-letter",
    numbering: "1",
    footer: none,   // the footer-block below carries the page number; typst's default footer would repeat it
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(need(meta, "footer_title"), need(meta, "case_number")),
  )
  set document(
    title: need(meta, "brief_title") + ", No. " + need(meta, "case_number"),
    author: need(meta, "signature").signer,
  )
  set text(
    font: font-family, size: type-size, lang: "en", region: "us",
    hyphenate: false, fallback: false,
  )
  set par(
    leading: body-leading, spacing: 0pt,
    first-line-indent: (amount: para-indent, all: true), justify: false,
  )
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

  // Headings: level 1 is a centered section; levels 2 and up are numbered and hang their labels.
  // Each heading occupies whole numbered lines (on-grid), so the body below stays on the grid.
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    // The height is measured at the width the text really gets (a hanging heading is narrower by its indent),
    // so a heading that wraps takes two numbered lines and never runs into the paragraph below it.
    if it.level == 1 {
      let hgt = measure(width: text-width, strong(upper(it.body))).height
      block(width: text-width, height: calc.ceil(hgt / pitch) * pitch, above: 0pt, below: 0pt, sticky: true,
        align(center, strong(upper(it.body))))
    } else {
      let ind = label-indent(it.level)
      let hgt = measure(width: text-width - ind - heading-tab, strong(it.body)).height
      block(width: text-width, height: calc.ceil(hgt / pitch) * pitch, above: 0pt, below: 0pt, sticky: true,
        hang(ind + heading-tab, {
          h(ind)
          box(width: heading-tab, lab)
          strong(it.body)
        }))
    }
  }

  first-page(meta)
  pagebreak()
  toc-section()
  pagebreak()
  toa-section(authorities)
  pagebreak()

  // The body, one markdown chunk at a time, each rounded up to whole numbered lines (on-grid): a paragraph's
  // height is its lines plus the leading between them, so an unrounded paragraph would overlap the next one.
  // Footnote definitions are not chunks of their own: each chunk is rendered with all of them, so a reference
  // resolves wherever its definition sits in the file.
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let defs = chunks.filter(c => c.trim().starts-with("[^")).join("\n\n")
  let texts = chunks.filter(c => not c.trim().starts-with("[^"))
  let is-list(c) = c.trim().starts-with(regex("^(\\d+\\.|[-*+])[ \\t]"))
  // Lettered list items, as in the complaint: (a), (b), ...
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in)
  set list(indent: 0.5in, body-indent: 0.4in)
  // The last paragraph is kept with the signature block, so the signature never stands alone.
  // A paragraph's first line is indented by a leading space (as in the complaint: cmarker's output for one
  // chunk is not a paragraph that `first-line-indent` reaches); a heading and a list are not indented.
  let chunk-body(c) = on-grid(sticky: c.trim().starts-with("#"), context {
    if is-list(c) or c.trim().starts-with("#") {
      cmarker.render(c + "\n\n" + defs, raw-typst: false, smart-punctuation: true)
    } else {
      [#h(para-indent)#cmarker.render(c + "\n\n" + defs, raw-typst: false, smart-punctuation: true)]
    }
  })
  for c in texts.slice(0, texts.len() - 1) {
    chunk-body(c)
  }
  let last = texts.last()
  block(breakable: false, width: text-width, {
    chunk-body(last)
    signature-block(meta)
  })
}
