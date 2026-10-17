// Memorandum in support of a motion for the U.S. District Court for the Northern District of Ohio (ohnd).
// Rules: Fed. R. Civ. P. 10(a) (caption), 12(b) (the motion this memorandum supports); N.D. Ohio L.R. 7.1(c)
// (memorandum with the motion), 7.1(f) (length: 20 pages for dispositive motions, 15 for others; a memorandum
// over 15 pages needs a table of contents, a table of authorities, a statement of the issues and a summary of
// the argument; every dispositive memorandum carries a certification of track and page limit), 10.1 (8 1/2 x 11
// paper, double spacing except quotations, a 1 1/2 inch top margin on the first page, consecutive page numbers).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // L.R. 10.1 names no face; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                  // convention for federal filings; no N.D. Ohio font rule in L.R. 10.1
#let natural-line = 7.86pt             // Liberation Serif's line box, 0.655 em at 12 pt
#let single-pitch = 13.8pt             // single spacing: 1.15 em at 12 pt
#let body-pitch = 2 * single-pitch     // double spacing (L.R. 10.1): 27.6 pt, twice the single pitch
#let body-leading = body-pitch - natural-line
#let single-leading = single-pitch - natural-line
#let para-indent = 0.5in
#let page-w = 8.5in
#let margin = 1in
#let first-page-top = 1.5in            // L.R. 10.1: top margin of the first page, for the clerk's file stamp
#let text-width = page-w - 2 * margin
#let caption-left = 3.3in
#let caption-paren = 0.3in
#let passim-threshold = 7              // convention: an authority cited on 7 or more pages is listed "passim"
#let memo-limit-plain = 15             // L.R. 7.1(f): memoranda relating to all other motions
// L.R. 7.1(f): dispositive-motion memoranda, by track (expedited; administrative, standard and unassigned;
// complex; mass tort). Changed only by an order of the Judicial Officer, which the frontmatter records.
#let track-limits = (
  "expedited": 10,
  "administrative": 20,
  "standard": 20,
  "unassigned": 20,
  "complex": 30,
  "mass tort": 40,
)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohnd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (party names, the signature lines, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Lines set single-spaced, one per item; each item occupies one single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Plain text of content, for the checks on headings (the words of the heading, without markup).
#let text-of(c) = lower(repr(c))

// ---------------------------------------------------------------------------
// Caption (as the complaint: the court title, the party column with ")" marks, and the case number)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "NORTHERN DISTRICT OF OHIO")
  if "division" in meta { lines.push(upper(meta.division)) }
  align(center, line-stack(lines))
}

/// One caption row: the name, and as many ")" as the name has lines.
#let caption-row(r) = {
  let name = if r == "" {
    box(height: single-pitch, width: 0pt)
  } else {
    block(width: caption-left, {
      set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
      inl(r)
      v(single-leading)
    })
  }
  let parens = context {
    let h = if r == "" { 0pt } else { measure(width: caption-left, inl(r)).height }
    let k = calc.max(1, int(calc.round(h.pt() / single-pitch.pt())))
    stack(dir: ttb, spacing: 0pt, ..range(k).map(_ => block(height: single-pitch, [)])))
  }
  (name, parens)
}

#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows += ("", "v.", "") }
    rows += p.names + (p.designation,)
  }
  let cells = ()
  for (i, r) in rows.enumerate() {
    let (name, parens) = caption-row(r)
    cells += (name, parens)
    if i == 0 {
      cells.push(grid.cell(rowspan: rows.len(), inset: (left: 0.3in), align: top, {
        set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
        "Case No. " + meta.case_number
        v(single-pitch)
        let judge = if "judge" in meta { meta.judge } else { "" }
        "Judge: " + judge
      }))
    }
  }
  grid(columns: (caption-left, caption-paren, 1fr), column-gutter: 0pt, ..cells)
}

/// The title of the paper: bold, centered, set in a measure narrower than the page (the words wrap; no breaks).
#let title-block(meta) = {
  v(body-pitch)
  align(center, block(width: 5.6in, {
    set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
    strong(inl(meta.title))
  }))
  v(body-pitch)
}

// ---------------------------------------------------------------------------
// Table of contents and table of authorities (L.R. 7.1(f); built from the headings and the `toa:` links)
// ---------------------------------------------------------------------------

#let toc-section() = {
  align(center, strong("TABLE OF CONTENTS"))
  v(body-pitch)
  set par(leading: single-leading, spacing: 0pt)
  show outline.entry: it => block(above: 0.6em, below: 0pt, it)
  outline(title: none, depth: 3, indent: 0.5in)
}

#let toa-groups = (
  ("case", "Cases"),
  ("constitution", "Constitutional Provisions"),
  ("statute", "Statutes"),
  ("regulation", "Regulations"),
  ("rule", "Rules"),
  ("other", "Other Authorities"),
)

/// Plain text of an inline-markdown string (case names in italics lose their markup).
#let plain-text(c) = {
  if type(c) == str { c.replace(regex("[*_]"), "") } else { repr(c) }
}

#let sort-key(a) = lower(plain-text(a.at("sort", default: a.at("name", default: "") + " " + a.cite)))
  .replace(regex("[^a-z0-9 ]"), "")

#let toa-section(authorities) = {
  align(center, strong("TABLE OF AUTHORITIES"))
  v(body-pitch)
  context {
    let hits = query(<toa-hit>)
    for h in hits {
      if h.value not in authorities {
        panic("ohnd-motion-brief: link `toa:" + h.value + "` has no entry under `authorities:` in the frontmatter")
      }
    }
    set par(leading: single-leading, spacing: 0pt)
    let first = true
    for (kind, title) in toa-groups {
      let members = authorities.pairs()
        .filter(p => p.last().kind == kind and hits.any(h => h.value == p.first()))
        .sorted(key: p => sort-key(p.last()))
      if members.len() == 0 { continue }
      block(above: if first { 0pt } else { 1.2em }, below: 0.4em, sticky: true, {
        strong(title)
        if first { h(1fr); strong("Page(s)") }
      })
      first = false
      for (key, a) in members {
        // Distinct page numbers, in document order.
        let pages = ()
        for h in hits.filter(h => h.value == key) {
          let p = counter(page).at(h.location()).first()
          if p not in pages { pages.push(p) }
        }
        let page-text = if pages.len() >= passim-threshold { emph[passim] } else { pages.map(str).join(", ") }
        block(breakable: false, above: 0.6em, below: 0pt, width: 100%, {
          set par(hanging-indent: 0.35in, first-line-indent: 0pt, leading: single-leading, spacing: 0pt)
          if "name" in a {
            if kind == "case" { emph(inl(a.name)) } else { inl(a.name) }
            [, ]
          }
          inl(a.cite)
          h(0.8em)
          box(width: 1fr, repeat[.])
          h(0.3em)
          page-text
        })
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Checks the template makes on the layout itself (a failed check stops the build)
// ---------------------------------------------------------------------------

/// The memorandum (caption page through the signature block) is within the page limit for its track, and a
/// memorandum over 15 pages has the contents and summary the rule requires.
#let length-checks(meta, limit, has-contents) = context {
  let end = query(<memo-end>).first().location()
  let pages = counter(page).at(end).first()
  assert(pages <= limit, message: "ohnd-motion-brief: the memorandum runs " + str(pages) + " pages; L.R. 7.1(f) allows " + str(limit) + " for this track (a Judicial Officer's order is needed to exceed it)")
  if pages > memo-limit-plain {
    assert(has-contents, message: "ohnd-motion-brief: the memorandum runs " + str(pages) + " pages; L.R. 7.1(f) requires a table of contents and a table of authorities above 15 pages (set `contents: true`)")
    let heads = query(heading).map(h => text-of(h.body))
    assert(heads.any(h => h.contains("issue")), message: "ohnd-motion-brief: L.R. 7.1(f) requires a statement of the issue(s) to be decided above 15 pages (a heading with \"Issue\")")
    assert(heads.any(h => h.contains("summary")), message: "ohnd-motion-brief: L.R. 7.1(f) requires a summary of the argument above 15 pages (a heading with \"Summary\")")
  }
}

// ---------------------------------------------------------------------------
// Certification of track and page limit (L.R. 7.1(f)); printed after the signature block
// ---------------------------------------------------------------------------

#let certification(meta, limit) = {
  let dispositive = if "dispositive" in meta { meta.dispositive } else { true }
  let track = meta.track
  block(width: text-width, breakable: false, {
    v(body-pitch)
    align(center, strong("CERTIFICATION OF TRACK AND PAGE LIMIT"))
    v(body-pitch)
    set par(leading: body-leading, spacing: 0pt, first-line-indent: (amount: para-indent, all: true))
    if dispositive {
      "Pursuant to Local Rule 7.1(f), the undersigned certifies that this memorandum relates to a dispositive motion, that this case is assigned to the " + track + " track, and that this memorandum adheres to the " + str(limit) + "-page limitation set by Local Rule 7.1(f) for that track."
    } else {
      "Pursuant to Local Rule 7.1(f), the undersigned certifies that this memorandum relates to a motion other than a dispositive motion, that this case is assigned to the " + track + " track, and that this memorandum adheres to the " + str(limit) + "-page limitation set by Local Rule 7.1(f) for such motions."
    }
    if "page_limit_order" in meta {
      " The page limitation was modified by order (" + meta.page_limit_order + "), and this memorandum complies with that modification."
    }
  })
}

// ---------------------------------------------------------------------------
// Signature block (single-spaced, at the right; L.R. 10.1: name, address, telephone, fax, e-mail, Ohio Bar No.)
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: text-width, breakable: false, {
  v(body-pitch)
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    if "date" in meta { [Dated: #meta.date] } else { [] },
    {
      set par(leading: single-leading, spacing: 0pt, first-line-indent: 0pt)
      [Respectfully submitted,]
      v(single-pitch)
      if "firm" in meta.signature { line-stack(meta.signature.firm) }
      if "firm" in meta.signature { v(single-pitch) }
      line-stack(meta.signature.lines)
    },
  )
  [#metadata(none)<memo-end>]
})

// ---------------------------------------------------------------------------
// The memorandum
// ---------------------------------------------------------------------------

#let ohnd-motion-brief(meta, body) = {
  let has-contents = if "contents" in meta { meta.contents } else { false }
  let authorities = if "authorities" in meta { meta.authorities } else { (:) }
  let dispositive = if "dispositive" in meta { meta.dispositive } else { true }
  assert(meta.track in track-limits, message: "ohnd-motion-brief: frontmatter `track` must be one of " + track-limits.keys().join(", "))
  let limit = if dispositive { track-limits.at(meta.track) } else { memo-limit-plain }

  set page(
    paper: "us-letter",
    margin: (top: margin, bottom: margin, left: margin, right: margin),
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", hyphenate: false)
  // Paragraphs: double-spaced; the paragraph spacing equals the leading, so every line falls on the grid of
  // body pitches. Only the body's paragraphs are indented (set again where the body is rendered below); the
  // caption, headings, quotations and signature are not.
  set par(leading: body-leading, spacing: body-leading, first-line-indent: 0pt, justify: false)
  set heading(numbering: none)
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.5em)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }
  // Headings: single-spaced, bold, kept with the paragraph after them. Level 1 is a section of the memorandum,
  // level 2 a point, level 3 a sub-point. The numerals are typed in the sample, as filed.
  show heading.where(level: 1): it => block(sticky: true, above: body-pitch, below: body-leading, width: text-width,
    par(first-line-indent: 0pt, hanging-indent: 0.5in, leading: single-leading, spacing: 0pt,
      text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 2): it => block(sticky: true, above: body-leading, below: body-leading, width: text-width,
    pad(left: 0.5in, par(first-line-indent: 0pt, hanging-indent: 0.5in, leading: single-leading, spacing: 0pt,
      text(size: type-size, weight: "bold", it.body))))
  show heading.where(level: 3): it => block(sticky: true, above: body-leading, below: body-leading, width: text-width,
    pad(left: 1in, par(first-line-indent: 0pt, hanging-indent: 0.5in, leading: single-leading, spacing: 0pt,
      text(size: type-size, weight: "bold", it.body))))
  // Block quotations: single-spaced, indented on both sides.
  show quote.where(block: true): it => block(above: body-leading, below: body-leading, width: text-width,
    pad(left: para-indent, right: para-indent, {
      set par(first-line-indent: 0pt, leading: single-leading, spacing: single-leading)
      it.body
    }))
  // Typography that holds for any text: no break inside "60(b)(5)", none between a section sign and its number.
  show regex("\\S*\\)\\(\\S*"): it => box(it)
  show regex("[§¶] \\S+"): it => box(it)
  // Each `toa:` link marks the page where its authority is cited (the table of authorities reads the marks).
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("toa:") {
      [#metadata(it.dest.slice(4))<toa-hit>#it.body]
    } else {
      it.body
    }
  }

  // ---- the caption page ----
  // First page: the top margin is 1 1/2 inches (L.R. 10.1), so the first page starts with the extra 1/2 inch.
  v(first-page-top - margin)
  court-title(meta)
  v(body-pitch)
  caption(meta)
  title-block(meta)

  // ---- contents (L.R. 7.1(f): above 15 pages; the template always prints them when asked for) ----
  if has-contents {
    pagebreak()
    toc-section()
    pagebreak()
    toa-section(authorities)
    pagebreak()
  }

  // ---- the body: everything but the last paragraph, then the last paragraph with the signature ----
  let chunks = body.trim().split(regex("\\r?\\n[ \\t]*\\r?\\n"))
  let tail = chunks.last()
  // The tail is rendered apart from the rest, so it can carry neither a footnote definition nor a footnote mark.
  assert(not tail.trim().starts-with("[^") and not tail.contains("[^"), message: "ohnd-motion-brief: the last paragraph of the body must not hold a footnote (move the note to an earlier paragraph)")
  set par(first-line-indent: (amount: para-indent, all: true))
  cmarker.render(chunks.slice(0, chunks.len() - 1).join("\n\n"), raw-typst: false, smart-punctuation: true, h1-level: 1)
  // The last paragraph is kept with the signature block, so the signature never stands alone.
  block(breakable: false, width: text-width, {
    cmarker.render(tail, raw-typst: false, smart-punctuation: true, h1-level: 1)
    signature-block(meta)
  })
  certification(meta, limit)
  length-checks(meta, limit, has-contents)
}
