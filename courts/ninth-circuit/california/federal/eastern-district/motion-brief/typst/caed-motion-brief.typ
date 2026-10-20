// Motion with notice and memorandum for the U.S. District Court for the Eastern District of California (caed).
// Rules: E.D. Cal. L.R. 130 (numbered lines in the left margin, double spacing, page number and a
// description of the document on the same line at the bottom), 131(a) (counsel in the upper left of the
// first page, with the party each attorney represents), 133(k) (a table of contents and a table of
// authorities for a brief over 15 pages), 230(b) (the hearing is set at least 35 days after filing).
// Fed. R. Civ. P. 7(b), 12(b)(6), 12(e). See ../README.md for each choice and what the exemplar shows instead.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no E.D. Cal. font rule; the only font vendored in fonts/ (README.md, open choices)
#let type-size = 12pt                   // no E.D. Cal. type-size rule; the exemplar is 12 pt
#let pitch = 24pt                       // L.R. 130(c): double-spaced; the numbered lines are this pitch
#let lines-per-page = 28                // L.R. 130(b) asks for numbered lines; 28 per page matches the exemplar
#let page-w = 8.5in                     // L.R. 130(b): 8 1/2 by 11 inch paper
#let page-h = 11in
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 48 pt: holds the footer
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 0.75in
#let text-width = page-w - left-margin - right-margin
#let body-leading = 1.35em              // double spacing: EB Garamond's line box is 0.65em, so 1.35em leading gives a 24 pt baseline pitch at 12 pt
#let single-leading = 0.5em             // single spacing for counsel, caption and signature (L.R. 130(c) allows it for these)
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.2in               // width of the party column of the caption
#let counsel-lines = 7                  // L.R. 131(a): counsel in the upper left; the court title starts on line 8 unless counsel needs more lines

// Page-number style: arabic for the notice and the memorandum, roman for the tables (L.R. 133(k) does not
// fix one; this follows the exemplar). Set by the markers [[TOC]], [[TOA]] and [[MEMO]] in the body.
#let pn-style = state("pn-style", "arabic")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("caed-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Fill whole numbered lines: the block is rounded up to a multiple of `pitch`, so whatever follows
/// it stays on the grid of numbered lines.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 28 down the left margin, one per numbered line.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.5in, height: pitch,
        align(right, text(size: type-size, str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// L.R. 130(d): the page number and a brief description of the document on the same line.
#let footer-block(title) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 6pt,
  block(width: text-width, {
    set text(size: 10pt)
    grid(
      columns: (1fr, auto),
      column-gutter: 0.2in,
      upper(title),
      context {
        let n = counter(page).get().first()
        if pn-style.at(here()) == "roman" { numbering("i", n) } else { str(n) }
      },
    )
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-7 or more), court title, caption, title of the paper, hearing
// ---------------------------------------------------------------------------

/// One single-spaced line per item: each item is a block, and the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let counsel-block(meta) = context {
  // Lines 1-7 at least; more counsel lines push the court title down (L.R. 131(a): the upper left corner).
  let h = measure(width: text-width, line-stack(meta.counsel)).height
  block(width: text-width, height: calc.max(counsel-lines, calc.ceil(h / pitch)) * pitch,
    line-stack(meta.counsel))
}

#let court-title(meta) = {
  on-grid(align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")))
  on-grid(align(center, text(weight: "bold", "EASTERN DISTRICT OF CALIFORNIA")))
  if "division" in meta {
    on-grid(align(center, text(weight: "bold", upper(meta.division))))
  }
}

#let caption(meta) = on-grid(grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    // Each party: its names, then its designation; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    let rows = ("Case No.: " + meta.case_number,)
    if "judge" in meta { rows.push(meta.judge) }
    if "magistrate" in meta { rows.push(meta.magistrate) }
    line-stack(rows)
    v(pitch * 0.5)
    [#text(weight: "bold", inl(meta.brief_title))]
    if "concurrent" in meta {
      v(pitch * 0.5)
      inl(meta.concurrent)
    }
    if "hearing" in meta {
      v(pitch * 0.5)
      line-stack((
        "Date: " + meta.hearing.date,
        "Time: " + meta.hearing.time,
        "Place: " + meta.hearing.place,
      ))
    }
    if "action_filed" in meta {
      v(pitch * 0.5)
      line-stack(("Action Filed: " + meta.action_filed,))
    }
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  v(pitch)
  caption(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Signature, tables and the memorandum
// ---------------------------------------------------------------------------

/// The signature block: the date, the firm, "By: /s/" with the signer, and the signer's name and role.
#let signature-block(meta) = on-grid(grid(
  columns: (2.6in, 1fr),
  column-gutter: 0.2in,
  [Dated: #meta.date],
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(meta.signature.firm)
    v(pitch * 0.5)
    line-stack(("By: /s/ " + meta.signature.signer, meta.signature.signer) + meta.signature.lines)
  },
))

/// Table of contents: the outline of the headings that follow it (the memorandum's headings, numbered as
/// the memorandum is). The page numbers are the memorandum's own.
#let toc-page() = {
  pagebreak()
  pn-style.update("roman")
  counter(page).update(1)
  on-grid(align(center, text(weight: "bold", "TABLE OF CONTENTS")))
  on-grid(align(right, text(weight: "bold", "Page")))
  outline(title: none, depth: 3, indent: 0.5in)
}

/// Table of authorities: the groups from the sample's frontmatter, each entry with its page references.
#let toa-page(meta) = {
  pagebreak()
  on-grid(align(center, text(weight: "bold", "TABLE OF AUTHORITIES")))
  on-grid(align(right, text(weight: "bold", "Page(s)")))
  for group in meta.authorities {
    on-grid(text(weight: "bold", group.category))
    for e in group.entries {
      block(width: text-width, above: 0pt, below: 0pt, {
        set par(leading: single-leading, spacing: 0pt, hanging-indent: 0.4in)
        inl(e.cite)
        box(width: 1fr, repeat[.\u{00a0}])
        [#e.pages]
      })
      v(single-leading * 2)
    }
  }
}

/// The memorandum starts on a new page with its own page numbering.
#let memo-start(meta) = {
  pagebreak()
  pn-style.update("arabic")
  counter(page).update(1)
  on-grid(align(center, text(weight: "bold", upper(meta.memo_title))))
}

/// Body: the chunks of the markdown sample. Each blank-line-separated chunk is one of:
///   `[[TOC]]`, `[[TOA]]`, `[[MEMO]]` the tables and the memorandum markers (see above);
///   `---` the signature block goes here;
///   `#`, `##`, `###` headings (centered caps; centered bold; bold, left; bold, indented);
///   a list (`1.` items, numbered 1, 2, ... as in the exemplar);
///   a paragraph: unnumbered, with a first-line indent (briefs are not numbered).
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let brief-body(meta, body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // `prev` holds the chunk just before a `---`, so that the signature block is kept on the page with
  // the text it signs (a signature alone on a page is not a filing anyone would want).
  let prev = none
  for c in chunks {
    let t = c.trim()
    if t == "---" {
      if prev != none {
        block(breakable: false, width: text-width, { prev; signature-block(meta) })
      } else {
        signature-block(meta)
      }
      prev = none
      continue
    }
    if prev != none { prev }
    prev = none
    if t == "[[TOC]]" {
      toc-page()
    } else if t == "[[TOA]]" {
      toa-page(meta)
    } else if t == "[[MEMO]]" {
      memo-start(meta)
    } else if t.starts-with("#") {
      // A heading stays with the chunk after it, so it never ends a page.
      prev = block(breakable: false, width: text-width, sticky: true, on-grid(cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; items are spaced by body-leading so each fills whole lines.
      prev = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
    } else {
      prev = on-grid({
        set par(leading: body-leading)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    }
  }
  if prev != none { prev }
}

#let caed-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 centered caps; level 2 bold, left; level 3 bold, left, indented (the exemplar's A. / 1.).
  show heading.where(level: 1): it => align(center, text(weight: "bold", upper(it.body)))
  show heading.where(level: 2): it => text(weight: "bold", it.body)
  show heading.where(level: 3): it => pad(left: 0.5in, text(weight: "bold", it.body))
  cover(meta)

  // Body: the notice, the tables, and the memorandum; lists are numbered 1., 2., ... as in the exemplar.
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  brief-body(meta, body)
}
