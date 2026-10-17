// San Diego County Superior Court (calsuperct-sandiego): motion (notice and memorandum of points and authorities) on pleading paper.
//
// Rule-driven and content-agnostic. The governing rules are Cal. Rules of Court 2.100-2.119 and
// the San Diego Superior Court Local Rules, Division II (see ../README.md for the rule numbers, URLs
// and the date each was verified). No case-specific text, no coordinates measured off the filed
// exemplar, no forced line breaks. The markdown body is rendered by cmarker; the metadata comes
// from the YAML frontmatter of the same file.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters: the only numbers in this file. Each one traces to a rule or is a named style choice.
// ---------------------------------------------------------------------------

// CRC 2.105: "essentially equivalent to Courier, Times New Roman, or Arial". No face is named, so
// the Times New Roman row of docs/FONTS.md applies: Liberation Serif (metric-compatible).
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 12pt              // CRC 2.104: a font size not smaller than 12 points.
#let box-h = 12pt                  // one text line occupies 1 em of box; the leading sets the pitch.
#let pitch = 24pt                  // double spacing (CRC 2.108(1)); the pleading grid is this pitch.
#let grid-rows = 28                // numbered lines per page (pleading convention, tier 2).
#let top-margin = 1in              // line 1 starts 1 inch from the top (CRC 2.111(1)).
#let bottom-margin = 46pt          // 28 lines (672 pt) fit; 29 lines (696 pt) do not.
#let left-margin = 1.5in           // text starts here; CRC 2.107 requires at least 1 inch.
#let right-margin = 0.5in          // CRC 2.107 requires at least 1/2 inch.
#let clerk-rows = 7                // lines 1-7 keep the right of center clear (CRC 2.111(2)).
#let footer-rise = 14pt            // footer sits above the page edge, clear of the body.
#let para-indent = 0.5in
#let text-width = 8.5in - left-margin - right-margin  // measured widths must be absolute: 100% mis-measures inside layout()

// Text box settings shared by the body, the line numbers and the footer. A box of exactly one em
// with these edges puts the baseline of every line on the same place, so line numbers align.
#let box-edges = (top-edge: 0.7em, bottom-edge: -0.3em)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("calsuperct-sandiego-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("calsuperct-sandiego-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Lines of text joined with line breaks; each list item is one line of inline markdown.
/// Leading spaces in an item are kept as an indent (0.25 em per space), so the caption's
/// "Plaintiff," and "v." can sit where the filer put them.
#let lines(items) = {
  let out = ()
  for (i, it) in items.enumerate() {
    if i > 0 { out.push(linebreak()) }
    let m = it.match(regex("^( *)(.*)$"))
    let n = m.captures.at(0).len()
    if n > 0 { out.push(h(n * 0.25em)) }
    out.push(inl(m.captures.at(1)))
  }
  out.join()
}

// ---------------------------------------------------------------------------
// Pleading paper: 28 numbered lines, two vertical rules, footer below the page number
// ---------------------------------------------------------------------------

#let pleading-background() = {
  for i in range(grid-rows) {
    place(top + left, dx: 0.7in, dy: top-margin + i * pitch, box(width: 0.35in,
      align(right, text(size: type-size, ..box-edges, str(i + 1)))))
  }
  // Vertical rules: a double rule between the numbers and the text, a single rule on the right.
  place(top + left, dx: 1.22in, line(start: (0pt, 0pt), end: (0pt, 792pt), stroke: 0.6pt))
  place(top + left, dx: 1.25in, line(start: (0pt, 0pt), end: (0pt, 792pt), stroke: 0.6pt))
  place(top + left, dx: 8.1in, line(start: (0pt, 0pt), end: (0pt, 792pt), stroke: 0.6pt))
}

/// Footer (CRC 2.109, 2.110): a printed line, the page number, then the title of the paper
/// in at least 10-point type.
#let pleading-footer(title) = context {
  set text(size: type-size, ..box-edges)
  stack(
    spacing: 2pt,
    line(length: 100%, stroke: 0.5pt),
    align(center, counter(page).display()),
    align(center, text(size: 10pt, title)),
  )
}

// ---------------------------------------------------------------------------
// First page (CRC 2.111): attorney block on line 1, court title on line 8, caption
// ---------------------------------------------------------------------------

/// Attorney block: single-spaced lines starting at line 1, left of center.
#let attorney-block(meta, width) = {
  let items = need(meta, "attorney")
  let body = par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt, lines(items))
  // Lines 1 to 7 are reserved for the attorney block and the clerk's space (CRC 2.111(1),(2)).
  layout(size => {
    let h = measure(block(width: width, body)).height
    if h > clerk-rows * pitch {
      panic("calsuperct-sandiego-motion-brief: the attorney block is taller than lines 1-" + str(clerk-rows))
    }
  })
  block(width: width, height: clerk-rows * pitch, body)
}

/// Top of the first page: the attorney block on lines 1-7. When the filer is exempt from fees
/// (Gov. Code, § 6103), the label goes in the upper right-hand corner above the caption, clear of
/// the clerk's file-stamp area (SD Local Rule 2.1.2(H)), so the block is narrowed to make room.
#let first-page-top(meta) = {
  if "fee_exempt" in meta {
    grid(columns: (4.2in, 2.3in), column-gutter: 0pt,
      attorney-block(meta, 4.2in),
      block(width: 2.3in, height: clerk-rows * pitch, par(leading: 0pt, spacing: 0pt,
        first-line-indent: 0pt, align(right, lines(meta.fee_exempt)))))
  } else {
    attorney-block(meta, text-width)
  }
}

/// Court title: centered, on line 8 (CRC 2.111(3)). Line 8 begins 7 lines below line 1.
#let court-title(meta) = {
  block(width: 100%, height: 2 * pitch, align(center, par(leading: pitch - box-h, spacing: 0pt,
    first-line-indent: 0pt, strong(lines(need(meta, "court"))))))
}

/// Caption: parties on the left (closed by a right rule and a bottom rule), the case number,
/// the nature of the paper and the judge and department on the right (CRC 2.111(4)-(7)).
#let caption(meta) = {
  let cap = need(meta, "caption")
  let left-cell = block(width: 100%, stroke: (right: 0.6pt + black, bottom: 0.6pt + black),
    inset: (right: 0.12in, bottom: 0.12in, top: 0pt),
    par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt, lines(need(cap, "left"))))
  let right-cell = block(width: 100%, inset: (left: 0.2in, top: 0pt),
    par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt, {
      if "case_number" in cap {
        [#cap.case_number]
        linebreak()
        linebreak()
      }
      // Limited civil cases carry the words "Limited Civil Case" in the caption (CRC 2.111(10)).
      if "limited_civil" in cap and cap.limited_civil {
        [LIMITED CIVIL CASE]
        linebreak()
        linebreak()
      }
      strong(lines(need(cap, "title")))
      if "details" in cap {
        linebreak()
        linebreak()
        lines(cap.details)
      }
      // CRC 3.1110(b): the hearing date, time and place, the hearing judge, the date the action was
      // filed and the trial date (if set) appear on the first page. CRC 2.111(7): judge and
      // department below the nature of the paper, when assigned.
      if "hearing" in cap {
        let hr = cap.hearing
        linebreak()
        linebreak()
        for key in ("date", "time", "dept", "judge") {
          if key in hr {
            let label = if key == "date" { "Date:" } else if key == "time" { "Time:" } else if key == "dept" { "Dept.:" } else { "Judge:" }
            [#label #hr.at(key)]
            linebreak()
          }
        }
        if "action_filed" in cap { [Action filed: #cap.action_filed] ; linebreak() }
        if "trial_date" in cap { [Trial date: #cap.trial_date] ; linebreak() }
      } else if "judge" in cap or "dept" in cap {
        linebreak()
        linebreak()
        if "dept" in cap { [Dept.: #cap.dept] }
        if "dept" in cap and "judge" in cap { linebreak() }
        if "judge" in cap { [Judge: #cap.judge] }
      }
      // CRC 2.111(9): on a complaint, the amount-demanded statement (wording from the frontmatter).
      if "amount_demanded" in cap {
        linebreak()
        linebreak()
        inl(cap.amount_demanded)
      }
    }))
  grid(columns: (3.6in, 2.9in), column-gutter: 0pt, left-cell, right-cell)
}

// ---------------------------------------------------------------------------
// Headings and body text
// ---------------------------------------------------------------------------

#let style-heading(it) = {
  set par(first-line-indent: 0pt, leading: 12pt, spacing: 12pt)
  if it.level == 1 {
    block(width: 100%, sticky: true, above: 12pt, below: 12pt,
      align(center, strong(upper(it.body))))
  } else if it.level == 2 {
    block(width: 100%, sticky: true, above: 12pt, below: 12pt,
      align(center, strong(upper(it.body))))
  } else if it.level == 3 {
    block(width: 100%, sticky: true, above: 12pt, below: 12pt, strong(it.body))
  } else {
    block(width: 100%, sticky: true, above: 12pt, below: 12pt, strong(emph(it.body)))
  }
}

// ---------------------------------------------------------------------------
// Tables of contents and authorities (CRC 3.1113(f)): a memorandum that exceeds 10 pages must
// include both. Built when the frontmatter has `authorities:`; citations in the body are links
// `[text](toa:key)` whose key names an entry there. Every row sits on the 24 pt pleading grid.
// ---------------------------------------------------------------------------

#let memo-page-limit = 10           // CRC 3.1113(f): over 10 pages, a TOC and a TOA are required.
#let toc-indent = 0.5in             // each heading level below the top one, in the table of contents.
#let toa-hang = 0.25in              // a citation's second line hangs under its case name.

#let dot-leader = box(width: 1fr, repeat[.#h(0.16em)])

/// Put an invisible `tag` right after the first word of `c`, keeping any emphasis around it.
/// A tag placed before the first word of a line is filed under the previous line, which can be
/// on the previous page, so the table of authorities would cite the wrong page.
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

/// Printed page label of a location ("3", "ii").
#let page-label(loc) = numbering(loc.page-numbering(), ..counter(page).at(loc))

#let table-title(t) = block(width: 100%, sticky: true, below: box-h,
  align(center, par(first-line-indent: 0pt, strong(t))))

/// One row of the table of contents: the heading text, a dot leader, the page number.
#let toc-entry(top-level, it) = {
  let hd = it.element
  let ind = (hd.level - top-level) * toc-indent
  link(hd.location(), block(width: 100%,
    par(first-line-indent: 0pt, hanging-indent: ind + toc-indent, {
      h(ind)
      hd.body
      h(0.6em)
      dot-leader
      box(width: 2.4em, align(right, page-label(hd.location())))
    })))
}

#let toc-section() = {
  table-title[TABLE OF CONTENTS]
  context {
    let target = selector(heading).after(<memo-start>)
    let levels = query(target).map(h => h.level)
    if levels.len() == 0 { panic("calsuperct-sandiego-motion-brief: the memorandum has no headings for its table of contents") }
    let top = calc.min(..levels)
    show outline.entry: it => toc-entry(top, it)
    outline(title: none, target: target, depth: 9, indent: 0pt)
  }
}

#let toa-groups = (
  ("case", "CASES"),
  ("constitution", "CONSTITUTIONAL PROVISIONS"),
  ("statute", "STATUTES"),
  ("regulation", "REGULATIONS"),
  ("rule", "RULES"),
  ("other", "OTHER AUTHORITIES"),
)

#let toa-section(authorities) = {
  table-title[TABLE OF AUTHORITIES]
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("calsuperct-sandiego-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => lower(p.last().at("sort", default: p.last().at("name", default: p.last().cite))))
      if members.len() == 0 { continue }
      block(width: 100%, sticky: true, above: box-h, par(first-line-indent: 0pt, strong(title)))
      for (key, a) in members {
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let label = page-label(h.location())
          if label not in pages { pages.push(label) }
        }
        block(width: 100%, breakable: false, above: box-h, par(first-line-indent: 0pt, hanging-indent: toa-hang, {
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [,]
            linebreak()
          }
          inl(a.cite)
          h(0.6em)
          dot-leader
          h(0.3em)
          pages.join(", ")
        }))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (CRC 2.111(1); signature under CCP 128.7 is the signer's own)
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = need(meta, "signature")
  block(width: 100%, sticky: true, above: pitch, {
    par(leading: box-h, spacing: 0pt, first-line-indent: 0pt, {
      if "dated" in sig { [Dated: #sig.dated] }
    })
    pad(left: 3.1in, par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt, lines(sig.lines)))
    v(pitch)
    pad(left: 3.1in, par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt, {
      [By: #box(width: 2.7in, line(length: 100%, stroke: 0.5pt))]
      linebreak()
      h(0.3in)
      strong(upper(sig.signer))
      if "role" in sig {
        linebreak()
        h(0.3in)
        sig.role
      }
    }))
  })
}

/// The body, then `closing` (jury demand, signature block). The signature block never stands alone
/// on a page: the body's last paragraph is kept on the page with it. Trailing footnote definitions
/// stay with the rest of the body; a last paragraph that is a heading, a quotation or carries a
/// footnote reference is not split off, so its note still resolves.
#let body-with-closing(md, closing) = {
  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)
  let paras = md.trim(at: end).split(regex("\n[ \t]*\n"))
  let k = paras.len() - 1
  while k > 0 and paras.at(k).trim().starts-with("[^") { k -= 1 }
  let tail = paras.at(k).trim()
  if k == 0 or tail.starts-with("#") or tail.starts-with(">") or tail.contains("[^") {
    render(md)
    closing
  } else {
    render((paras.slice(0, k) + paras.slice(k + 1)).join("\n\n"))
    block(width: 100%, breakable: false, above: box-h, { render(tail); closing })
  }
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let calsuperct-sandiego-motion-brief(meta, body) = {
  let authorities = meta.at("authorities", default: none)
  if body.match(regex("(?m)^#+[ \t]+[^\n]*\\]\\(toa:")) != none {
    panic("calsuperct-sandiego-motion-brief: citation links (toa:) are not allowed in headings; the table of contents would list them as authorities")
  }
  // A combined paper (notice of motion, then the memorandum) is split at the memorandum's heading;
  // the tables go between the two. Without that heading the whole body is the memorandum.
  let memo = body.match(regex("(?mi)^#+[ \t]+memorandum of points and authorities[^\n]*$"))
  let notice-md = if memo == none { "" } else { body.slice(0, memo.start) }
  let memo-head = if memo == none { "" } else { body.slice(memo.start, memo.end) }
  let memo-md = if memo == none { body } else { body.slice(memo.end) }
  let render(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: pleading-background(),
    footer: pleading-footer(need(meta, "footer_title")),
    footer-descent: footer-rise,
    // CRC 2.109: pages numbered consecutively at the bottom. With tables, the caption page, any
    // notice and the tables take lowercase roman numerals and the memorandum starts again at 1.
    numbering: if authorities == none { "1" } else { "i" },
  )
  set text(font: font-family, size: type-size, ..box-edges, lang: "en")
  // Blocks take no automatic spacing: every vertical gap is set explicitly so the grid holds.
  set block(spacing: 0pt)
  set par(leading: box-h, spacing: box-h, first-line-indent: (amount: para-indent, all: true), justify: false)
  show heading: style-heading
  show footnote.entry: set text(size: type-size)
  set footnote.entry(indent: 0pt)
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      tag-after-first-word(it.body, [#metadata(it.dest.slice(4))<toa-hit>]).first()
    } else { it }
  }

  // Lines 1-7: attorney block (fixed height). Lines 8-9: court title. Line 10 is blank.
  first-page-top(meta)
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)

  let memorandum = {
    render(memo-head)
    [#metadata(none)<memo-start>]
    body-with-closing(memo-md, {
      if "jury_demand" in meta {
        block(width: 100%, sticky: true, above: 24pt, below: 12pt,
          align(center, strong(upper(meta.jury_demand))))
      }
      signature-block(meta)
    })
    [#metadata(none)<memo-end>]
  }

  if authorities == none {
    render(notice-md)
    memorandum
    // CRC 3.1113(f): a memorandum over 10 pages needs a table of contents and a table of authorities.
    context {
      let n = locate(<memo-end>).page() - locate(<memo-start>).page() + 1
      if n > memo-page-limit {
        panic("calsuperct-sandiego-motion-brief: the memorandum runs " + str(n) + " pages; CRC 3.1113(f) requires a table of contents and a table of authorities over " + str(memo-page-limit) + " (add `authorities:` to the frontmatter)")
      }
    }
  } else {
    render(notice-md)
    pagebreak()
    toc-section()
    pagebreak()
    toa-section(authorities)
    {
      set page(numbering: "1")
      counter(page).update(1)
      memorandum
    }
  }
}
