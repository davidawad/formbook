// Motion to dismiss with memorandum for the U.S. District Court for the Western District of Washington (wawd).
// Rules: W.D. Wash. LCR 10(d)-(e) (page size, first-page space, margins, font, title, bottom notation,
// numbered paper); LCR 7(b)(4) (ORAL ARGUMENT REQUESTED in the caption); LCR 7(d)(4) (28-day noting);
// LCR 7(e)(4), (6) (length and the word-count certificate); Fed. R. Civ. P. 7(b), 10(a), 12(b).
// See ../README.md. Content-agnostic: every case-specific word comes from the sample's frontmatter.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // LCR 10(e)(1): proportionally spaced font; vendored in fonts/
#let type-size = 12pt                   // LCR 10(e)(1): 12 point or larger
#let pitch = 24pt                       // LCR 10(e)(1): double spaced or exactly 24 points; the numbered lines are this pitch
#let lines-per-page = 27                // LCR 10(e)(5): numbered paper; 27 numbered lines fill the text block
#let page-w = 8.5in                     // LCR 10(d): 8 1/2 by 11 inch paper
#let page-h = 11in
#let top-margin = 72pt                  // LCR 10(e)(1): one-inch margins; line 1 sits on the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the bottom notation
#let left-margin = 1.5in                // room for the line numbers (LCR 10(e)(5): at least 1/2 inch to their left)
#let right-margin = 1in                 // LCR 10(e)(1): at least one inch
#let text-width = page-w - left-margin - right-margin
#let body-leading = 1.35em              // double spacing: EB Garamond's line box is 0.65em, so 1.35em leading gives a 24 pt pitch at 12 pt
#let single-leading = 0.5em             // single spacing for the caption, footer and signature: about 13.8 pt at 12 pt
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.1in               // width of the party column of the caption
#let first-page-blank = 6               // LCR 10(e)(1): no less than three inches above the court title (lines 1-6 blank)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wawd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names with *italics*, section symbols, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Fill whole numbered lines: the block is rounded up to a multiple of `pitch`, so whatever follows
/// it stays on the grid of numbered lines. A heading may run to several lines.
#let on-grid(c, sticky: false) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, sticky: sticky, c)
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, one per numbered line.
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

/// LCR 10(e)(3): bottom notation. Left: abbreviated title, case number and page number.
/// Right (when the sample gives one): the firm, mailing address and telephone of the preparing attorney.
#let footer-block(title, case-number, firm) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 8pt,
  block(width: text-width, grid(
    columns: (1fr, auto),
    column-gutter: 0.3in,
    {
      set text(size: 10pt)
      set par(leading: 0.6em, spacing: 0pt)
      stack(dir: ttb, spacing: 3pt,
        upper(title),
        [(Case No. #case-number) -- #context counter(page).display()],
      )
    },
    {
      set text(size: 9pt)
      set par(leading: 0.75em, spacing: 0pt, justify: false)
      if firm.len() > 0 {
        align(right, stack(dir: ttb, spacing: 2.5pt, ..firm.map(l => [#l])))
      }
    },
  )),
)

// ---------------------------------------------------------------------------
// Cover: judge (line 1), court title (line 7), caption with noting data, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item: each item is a block, and the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let court-title(meta) = {
  on-grid(align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")))
  on-grid(align(center, text(weight: "bold", "WESTERN DISTRICT OF WASHINGTON")))
  on-grid(align(center, text(weight: "bold", upper(meta.location))))
}

#let caption(meta) = on-grid(grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.25in,
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
    line-stack(("Case No. " + meta.case_number,))
    v(pitch * 0.5)
    [#text(weight: "bold", inl(meta.brief_title))]
    // The noting date, oral-argument request and dates of the action, in the order given (LCR 7(b)(4), 7(d)).
    for note in meta.at("caption_notes", default: ()) {
      v(pitch * 0.5)
      text(weight: "bold", inl(note))
    }
  }),
))

#let cover(meta) = {
  // Lines 1-6: the judge's name on line 1 (LCR 10(e)(1) lets the judge's name sit in the margin), then blank.
  block(width: text-width, height: first-page-blank * pitch, align(top + right, text(weight: "bold",
    if "judge" in meta { meta.judge } else { "" })))
  court-title(meta)
  v(pitch)
  caption(meta)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// LCR 7(e)(6): when word limits apply, the signer certifies the word count of the memorandum.
#let word-certificate(meta) = on-grid({
  set par(leading: body-leading)
  h(para-indent)
  [The undersigned certifies that this memorandum contains #meta.word_count words, excluding captions, tables of contents, tables of authorities, signature blocks, required marginal text (e.g., title information and page numbers), or certificates of service, in compliance with the applicable Local Civil Rules, specifically LCR 7(d)(4) and LCR 7(e)(6).]
})

/// The signature block: the date, the firm (if one is listed), the signers, then the rest of the counsel list.
#let signature-block(meta) = {
  let sig = meta.signature
  on-grid(grid(
    columns: (3.0in, 1fr),
    column-gutter: 0.2in,
    [#sig.date],
    {
      set par(leading: single-leading, spacing: 0pt, justify: false)
      [Respectfully submitted,]
      v(pitch * 0.5)
      if "firm" in sig and sig.firm != "" {
        [#sig.firm]
        v(pitch * 0.5)
      }
      line-stack(sig.signers.enumerate().map(((k, s)) => if k == 0 { "By: " + s } else { s }))
    },
  ))
  if "additional" in sig {
    v(pitch)
    let rows = sig.additional
    if "role" in sig { rows.push(sig.role) }
    on-grid(line-stack(rows))
  }
}

/// A table of contents or authorities, written as markdown rows: `| entry | page |`. Each row is one
/// double-spaced grid line (a long entry runs to several lines); the entry is indented by its level:
/// "I. " sections at 0.5 in, "A. " sub-sections at 1 in. The header row `| | Page |` prints "Page" at the right.
#let toc-table(t) = {
  let rows = ()
  for row in t.split("\n") {
    let r = row.trim()
    if r.starts-with("|") and not r.contains("---") {
      let cells = r.split("|").map(s => s.trim()).filter(s => s != "")
      if cells.len() == 1 and cells.at(0) == "Page" {
        rows.push(align(right, text(weight: "bold", "Page")))
      } else if cells.len() == 2 {
        let e = cells.at(0)
        let ind = if e.match(regex("^(I|II|III|IV|V)\\. ")) != none {
          0.5in
        } else if e.match(regex("^[A-Z]\\. ")) != none {
          1in
        } else {
          0pt
        }
        rows.push(grid(
          columns: (1fr, 0.6in),
          column-gutter: 0.1in,
          block(inset: (left: ind), inl(e)),
          align(right, cells.at(1)),
        ))
      }
    }
  }
  // Single-spaced entries with a gap between them; the whole table is rounded to whole numbered lines.
  on-grid({
    set par(leading: single-leading)
    stack(dir: ttb, spacing: 12pt, ..rows)
  })
}

/// Body text: each blank-line-separated chunk of markdown is one paragraph with a first-line indent.
/// Headings are kept with the chunk after them; lists are rendered as markdown lists.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let brief-body(body, page-breaks) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      // The sections named in the frontmatter start a new page (the TOC, the TOA, the introduction).
      if page-breaks.any(h => t.contains(h)) { pagebreak(weak: true) }
      pending += on-grid(sticky: true, cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
      has-pending = true
    } else if t.starts-with("|") {
      // A table of contents or authorities: one row per double-spaced grid line (see toc-table).
      let tbl = toc-table(t)
      if has-pending {
        block(breakable: false, width: text-width, { pending; tbl })
      } else {
        tbl
      }
      pending = []
      has-pending = false
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages. Items are spaced by body-leading, so each item fills whole lines;
      // the trailing v() closes the last one. Not wrapped in on-grid: a fixed-height block cannot break.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; items })
      } else {
        items
      }
      pending = []
      has-pending = false
    } else {
      // A paragraph breaks across pages like any text; only a heading in front of it is kept with its first line.
      let piece = on-grid({ set par(leading: body-leading); h(para-indent); cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1) })
      if has-pending {
        { pending; piece }
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let wawd-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title, meta.case_number, meta.at("footer_firm", default: ())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered bold caps section; level 2 a bold argument heading, left, with a
  // hanging indent for its numeral; level 3 a bold italic sub-heading, left.
  show heading.where(level: 1): it => align(center, text(weight: "bold", upper(it.body)))
  show heading.where(level: 2): it => block(width: text-width, par(hanging-indent: 0.5in, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => text(weight: "bold", style: "italic", it.body)

  cover(meta)

  // Tables (the tables of contents and authorities) are set without rules; rows are one line each.
  show table: set table(stroke: none, inset: (x: 0pt, y: 0pt))

  brief-body(body, meta.at("page_breaks", default: ()))

  word-certificate(meta)
  signature-block(meta)

  // Certificate of service: its own page, after the signature (LCR 10(e)(4); Fed. R. Civ. P. 5).
  if "certificate_of_service" in meta {
    let c = meta.certificate_of_service
    pagebreak(weak: true)
    on-grid(align(center, text(weight: "bold", "CERTIFICATE OF SERVICE")))
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      [I certify that on #c.date, a true and correct copy of the foregoing document was electronically filed with the Court's ECF system to be sent via the electronic notification system to all counsel of record in the above-captioned matter.]
    })
    on-grid(grid(columns: (3.0in, 1fr), column-gutter: 0.2in, [], line-stack(("By: " + c.signer,))))
  }
}
