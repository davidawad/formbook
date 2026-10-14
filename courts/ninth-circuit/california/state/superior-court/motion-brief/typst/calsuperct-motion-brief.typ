// California Superior Court (calsuperct): notice of motion and motion, with the memorandum of
// points and authorities, in one document on pleading paper.
//
// Rule-driven and content-agnostic. The governing rules are Cal. Rules of Court 2.100-2.119 and
// 3.1112-3.1113 (see ../README.md for the rule numbers, URLs and the date each was verified). No
// case-specific text, no coordinates measured off a filed brief, no forced line breaks inside body
// text. The markdown body is rendered by cmarker; the metadata comes from the YAML frontmatter.
//
// Body contract: the markdown body is the notice of motion first, then a line
// `# MEMORANDUM OF POINTS AND AUTHORITIES`, then the memorandum. The template prints the title itself.

#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters: the only numbers in this file. Each one traces to a rule or is a named style choice.
// ---------------------------------------------------------------------------

#let font-family = "EB Garamond"   // vendored in fonts/. CRC 2.105 font style: see README "Known gaps".
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
#let memo-page-limit = 15          // CRC 3.1113(d): an opening memorandum may not exceed 15 pages.
#let toa-passim = 7                // convention: an authority on this many pages or more prints "passim".

// Text box settings shared by the body, the line numbers and the footer. A box of exactly one em
// with these edges puts the baseline of every line on the same place, so line numbers align.
#let box-edges = (top-edge: 0.7em, bottom-edge: -0.3em)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("calsuperct-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("calsuperct-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Lines of text joined with line breaks; each item is one line of inline markdown.
/// Leading spaces in an item are kept as an indent (0.25 em per space).
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

/// Length of the 1-based page range [first, last], both inclusive.
#let page-span(first, last) = last - first + 1

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
#let attorney-block(meta) = {
  let items = need(meta, "attorney")
  let body = par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt, lines(items))
  // Lines 1 to 7 are reserved for the attorney block and the clerk's space (CRC 2.111(1),(2)).
  layout(size => {
    let h = measure(block(width: size.width, body)).height
    if h > clerk-rows * pitch {
      panic("calsuperct-motion-brief: the attorney block is taller than lines 1-" + str(clerk-rows))
    }
  })
  block(width: 100%, height: clerk-rows * pitch, body)
}

/// Court title: centered, on lines 8 and 9 (CRC 2.111(3)).
#let court-title(meta) = {
  block(width: 100%, height: 2 * pitch, align(center, par(leading: pitch - box-h, spacing: 0pt,
    first-line-indent: 0pt, strong(lines(need(meta, "court"))))))
}

/// Caption: parties on the left (closed by a right rule and a bottom rule), and on the right the
/// case number, the title of each paper listed separately (CRC 3.1112(c)), the hearing details
/// (CRC 2.111(7)) and the action-filed date (CRC 2.111(4)-(6)).
#let caption(meta) = {
  let cap = need(meta, "caption")
  let left-cell = block(width: 100%, stroke: (right: 0.6pt + black, bottom: 0.6pt + black),
    inset: (right: 0.12in, bottom: 0.12in, top: 0pt),
    par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt, lines(cap.left)))
  let right-cell = block(width: 100%, inset: (left: 0.2in, top: 0pt), {
    // Each group is a block, so the hearing table never sits inside a paragraph.
    set par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt)
    let groups = ()
    if "case_number" in cap { groups.push(par(cap.case_number)) }
    groups.push(par(strong(lines(need(cap, "title")))))
    if "details" in cap { groups.push(par(lines(cap.details))) }
    if "hearing" in meta {
      let hg = meta.hearing
      let cells = ()
      for (k, lbl) in (("date", "Date:"), ("time", "Time:"), ("dept", "Dept.:"), ("judge", "Judge:")) {
        if k in hg {
          cells.push(lbl)
          cells.push(inl(hg.at(k)))
        }
      }
      groups.push(grid(columns: (0.75in, 1fr), ..cells))
    }
    if "action_filed" in cap { groups.push(par([Action Filed: #cap.action_filed])) }
    if "concurrent" in cap { groups.push(par([[#cap.concurrent]])) }
    stack(dir: ttb, spacing: pitch, ..groups)
  })
  grid(columns: (3.6in, 2.9in), column-gutter: 0pt, left-cell, right-cell)
}

// ---------------------------------------------------------------------------
// Headings and body text
// ---------------------------------------------------------------------------

#let style-heading(it) = {
  set par(first-line-indent: 0pt, leading: box-h, spacing: box-h)
  if it.level == 1 {
    // Section headings: bold, capitals, centered (memorandum sections and the Conclusion).
    block(width: 100%, sticky: true, above: 12pt, below: 12pt,
      align(center, strong(upper(it.body))))
  } else if it.level == 2 {
    // Argument points: bold, the label typed by the author, hanging under the text.
    block(width: 100%, sticky: true, above: 12pt, below: 12pt,
      pad(left: 0.5in, par(hanging-indent: 0.5in, first-line-indent: -0.5in, strong(it.body))))
  } else if it.level == 3 {
    block(width: 100%, sticky: true, above: 12pt, below: 12pt,
      pad(left: 1in, par(hanging-indent: 0.5in, first-line-indent: -0.5in, strong(it.body))))
  } else {
    block(width: 100%, sticky: true, above: 12pt, below: 12pt,
      pad(left: 1.5in, par(hanging-indent: 0.5in, first-line-indent: -0.5in, strong(emph(it.body)))))
  }
}

/// Table-of-contents and table-of-authorities entries: text, dot leader, page number.
#let dot-leader = box(width: 1fr, repeat[.#h(0.25em)])

// ---------------------------------------------------------------------------
// Tables of contents and authorities
// ---------------------------------------------------------------------------

/// Authorities: a link [text](toa:KEY) is a citation of KEY. The link keeps its default
/// rendering; the table of authorities reads the links from the document (query(link)) and
/// takes the page each one starts on. (A marker element inside the text would split "(" from
/// the citation, so none is used.)
#let toa-citations() = {
  query(link)
    .filter(l => type(l.dest) == str and l.dest.starts-with("toa:"))
    .map(l => (key: l.dest.slice(4), page: l.location().page()))
}

/// Contents: every heading of the memorandum, with a dot leader and the page it is on. Wrapped
/// titles hang under the title; each entry is single-spaced with one line of space above it.
#let table-of-contents(memo-title-page, toa-page) = {
  align(center, strong[TABLE OF CONTENTS])
  v(pitch)
  set block(above: box-h, below: 0pt)
  block(width: 100%, par(first-line-indent: 0pt, leading: box-h, spacing: 0pt,
    [MEMORANDUM OF POINTS AND AUTHORITIES #dot-leader #h(0.1em) #memo-title-page]))
  block(width: 100%, par(first-line-indent: 0pt, leading: box-h, spacing: 0pt,
    [TABLE OF AUTHORITIES #dot-leader #h(0.1em) #toa-page]))
  // Each entry: indented by level (a half inch per level below the first), title, dot leader, page.
  show outline.entry: it => block(above: box-h, below: 0pt, pad(left: (it.level - 1) * 0.5in,
    par(first-line-indent: 0pt, hanging-indent: 0pt, leading: box-h, spacing: 0pt,
      [#it.element.body #dot-leader #h(0.1em) #it.element.location().page()])))
  outline(title: none, target: heading)
}

#let kind-order = ("case", "constitution", "statute", "regulation", "rule", "other")
#let kind-title = (
  case: "Cases", constitution: "Constitutional Provisions", statute: "Statutes",
  regulation: "Regulations", rule: "Rules", other: "Other Authorities",
)

/// The table of authorities: one group per kind, alphabetized by the sort key (or name),
/// each with the pages of the memorandum where it is cited.
#let table-of-authorities(authorities) = {
  align(center, strong[TABLE OF AUTHORITIES])
  v(pitch)
  context {
    let cites = toa-citations()
    for kind in kind-order {
      let keys = authorities.keys().filter(k => authorities.at(k).kind == kind)
      if keys.len() == 0 { continue }
      keys = keys.sorted(key: k => {
        let a = authorities.at(k)
        lower(if "sort" in a { a.sort } else if "name" in a { a.name } else { a.cite })
      })
      par(first-line-indent: 0pt, spacing: 6pt, leading: box-h, strong(kind-title.at(kind)))
      for k in keys {
        let a = authorities.at(k)
        let pages = cites.filter(c => c.key == k).map(c => c.page)
        let uniq = pages.dedup().sorted()
        let pg = if uniq.len() == 0 { "—" } else if uniq.len() >= toa-passim { "passim" } else {
          uniq.map(str).join(", ")
        }
        let label = if "name" in a { if kind == "case" { emph(a.name) } else { a.name } } else { a.cite }
        let cite-text = if "name" in a { [, #a.cite] } else { [] }
        block(width: 100%, pad(left: 0.5in, par(hanging-indent: 0.5in, first-line-indent: 0pt,
          leading: box-h, spacing: 6pt, {
            [#label#cite-text #dot-leader #h(0.1em) #pg]
          })))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (CRC 2.111(1); the signer's own signature)
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

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

/// Split the body into the notice (before the memorandum heading) and the memorandum.
#let split-body(body) = {
  let parts = body.split(regex("(?m)^# MEMORANDUM OF POINTS AND AUTHORITIES[ \t]*\r?\n"))
  if parts.len() != 2 {
    panic("calsuperct-motion-brief: the body needs exactly one line `# MEMORANDUM OF POINTS AND AUTHORITIES`")
  }
  (parts.at(0), parts.at(1))
}

#let calsuperct-motion-brief(meta, body) = {
  let (notice, memo) = split-body(body)
  let authorities = if "authorities" in meta { meta.authorities } else { (:) }

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: pleading-background(),
    footer: pleading-footer(need(meta, "footer_title")),
    footer-descent: footer-rise,
  )
  set text(font: font-family, size: type-size, ..box-edges, lang: "en")
  // Blocks take no automatic spacing: every vertical gap is set explicitly so the grid holds.
  set block(spacing: 0pt)
  set par(leading: box-h, spacing: box-h, first-line-indent: (amount: para-indent, all: true), justify: false)
  show heading: style-heading
  show quote: it => pad(left: 0.5in, right: 0.5in, block(width: 100%,
    par(leading: box-h, spacing: 12pt, first-line-indent: 0pt, it.body)))
  show footnote.entry: set text(size: type-size)
  set footnote.entry(indent: 0pt)

  // Page 1: attorney block (lines 1-7), court title (lines 8-9), caption (from line 11).
  attorney-block(meta)
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)

  // The notice of motion.
  cmarker.render(notice, raw-typst: false, smart-punctuation: true)
  signature-block(meta)

  // Table of contents and table of authorities, each on its own page (CRC 3.1113(f)).
  pagebreak()
  context {
    let memo-page = query(<memo-first>).first().location().page()
    let toa-page = query(<toa-first>).first().location().page()
    table-of-contents(memo-page, toa-page)
  }
  pagebreak()
  [#metadata(none) <toa-first>]
  table-of-authorities(authorities)

  // The memorandum (CRC 3.1113). Its first page carries the title and the memo label.
  pagebreak()
  [#metadata(none) <memo-first>]
  block(width: 100%, align(center, strong[MEMORANDUM OF POINTS AND AUTHORITIES]))
  v(pitch)
  cmarker.render(memo, raw-typst: false, smart-punctuation: true)
  signature-block(meta)
  [#metadata(none) <memo-last>]

  // CRC 3.1113(d): the memorandum may not exceed the page limit. The count runs from the memo's
  // title page to the page of the signature block, and excludes the caption page, the notice,
  // the tables and the proof of service (not generated here).
  context {
    let first = query(<memo-first>).first().location().page()
    let last = query(<memo-last>).first().location().page()
    if page-span(first, last) > memo-page-limit {
      panic("calsuperct-motion-brief: the memorandum is " + str(page-span(first, last)) +
        " pages; CRC 3.1113(d) allows " + str(memo-page-limit))
    }
  }
}
