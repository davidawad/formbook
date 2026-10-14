// Motion with memorandum for the U.S. District Court for the Eastern District of Washington (waed).
// Rules: LCivR 10(a) (caption, footer, pagination), LCivR 10(d) (8 1/2 x 11, line numbers, serif type of 14 points
// or more, double spacing), LCivR 7(b)(1) (the motion serves as the memorandum), LCivR 7(i)(1) (hearing in the
// caption), LCivR 7(f)(1), (4) (length; caption, signatures and certificates are not counted). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "EB Garamond"        // LCivR 10(d): serif, traditional Roman; vendored in fonts/
#let type-size = 14pt                   // LCivR 10(d): proportionately spaced typeface of 14 points or more
#let pitch = 32pt                       // LCivR 10(d): text double spaced; 32 pt = 2 x 1.15 x 14 pt (the exemplar's pitch)
#let lines-per-page = 21                // the exemplar's numbered lines (21 per page); the rule does not fix a count
#let page-w = 8.5in                     // LCivR 10(d): 8 1/2 x 11 inch
#let page-h = 11in
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 48 pt: holds the footer
#let left-margin = 1.1in                // room for the line numbers and the pleading rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let body-leading = pitch - 0.65em      // EB Garamond's line box is 0.65em; this makes the baseline pitch 32 pt at 14 pt
#let single-leading = 0.5em             // single spacing for counsel, caption, headings and signature: about 16 pt
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let caption-left = 3.2in               // width of the party column of the caption
#let counsel-lines = 4                  // LCivR 10(a)(1)(A): counsel above line five; the court title starts on line five

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("waed-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for case names in italics, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Fill whole numbered lines: the block is rounded up to a multiple of `pitch`, so whatever follows
/// it stays on the grid of numbered lines.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// A heading: one numbered line, kept with the text after it (a heading never ends a page).
#let heading-line(c) = block(width: text-width, height: pitch, above: 0pt, below: 0pt, sticky: true, context {
  assert(measure(width: text-width, c).height <= pitch, message: "waed-motion-brief: a heading must fit on one numbered line")
  c
})

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 21 down the left margin, one per numbered line.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.45in, height: pitch,
        align(right, text(size: type-size, str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// LCivR 10(a)(1)(E) and 10(a)(2): in the footer of every page, the title (or an abbreviated title) followed by
/// the page number, sequentially numbered through the whole filing.
#let footer-block(title) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 6pt,
  block(width: text-width, {
    set text(size: type-size)
    upper(title) + " - " + context counter(page).display("1")
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-4), court title (line 5 on), caption with the hearing, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item: each item is a block, and the stack keeps the single spacing.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let counsel-block(meta) = context {
  // Lines 1 to 4 at least; more counsel lines push the court title down (LCivR 10(a)(1)(A)).
  let h = measure(width: text-width, line-stack(meta.counsel)).height
  block(width: text-width, height: calc.max(counsel-lines, calc.ceil(h / pitch)) * pitch,
    line-stack(meta.counsel))
}

#let court-title(meta) = {
  on-grid(align(center, "UNITED STATES DISTRICT COURT"))
  on-grid(align(center, "EASTERN DISTRICT OF WASHINGTON"))
  if "division" in meta {
    on-grid(align(center, upper(meta.division)))
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
  block(inset: (left: 0.15in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(("Case No. " + meta.case_number,))
    v(pitch * 0.5)
    [#text(weight: "bold", inl(meta.brief_title))]
    // LCivR 7(i)(1): a motion's caption carries the hearing date and time or place (or "without oral argument").
    if "hearing" in meta and meta.hearing != none {
      v(pitch * 0.5)
      line-stack(
        ("Hearing date: " + meta.hearing.date,)
          + if "type" in meta.hearing { (meta.hearing.type,) } else { () }
          + if "judge" in meta.hearing { (meta.hearing.judge,) } else { () },
      )
    }
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  v(pitch)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = on-grid(grid(
  columns: (2.6in, 1fr),
  column-gutter: 0.2in,
  [DATED #meta.date],
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(pitch * 0.5)
    line-stack(meta.signature.firm)
    v(pitch * 0.5)
    line-stack(("By s/" + meta.signature.signer,) + meta.signature.lines)
  },
))

/// Body chunks. A heading is one numbered line (left aligned, bold); a list is lettered by the template; any
/// other chunk is a paragraph with a first-line indent. Memoranda are not numbered (LCivR 7(b)(1)).
/// Numbering is not applied with a `show par` rule: a show rule that re-wraps paragraph content recurses without
/// end in typst 0.15.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; only a heading in front of it is kept with its first line.
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
      let piece = on-grid({
        set par(leading: body-leading)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
      if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
}

#let waed-motion-brief(meta, body) = {
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

  // Headings: level 1 is a bold caps section; level 2 a bold sub-section; level 3 bold italic. All left aligned,
  // as in the exemplar's memorandum body.
  show heading.where(level: 1): it => heading-line(text(weight: "bold", upper(it.body)))
  show heading.where(level: 2): it => heading-line(text(weight: "bold", it.body))
  show heading.where(level: 3): it => heading-line(text(weight: "bold", style: "italic", it.body))

  cover(meta)

  // Table of contents, generated from the body's headings, so its page numbers are the render's own (LCivR 10(a)(2)).
  if "toc" in meta and meta.toc {
    pagebreak()
    set par(leading: single-leading, spacing: 0pt)
    outline(
      title: on-grid(align(center, text(weight: "bold", "TABLE OF CONTENTS"))),
      depth: 2,
      indent: level => (0pt, 0.5in, 1in).at(calc.min(level, 2)),
    )
    pagebreak(weak: true)
  }

  // Body: the memorandum text (not numbered; LCivR 7(b)(1)).
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  // The certificate of service follows the signature block, on its own page, as in the exemplar.
  let parts = body.split(regex("(?m)^# CERTIFICATE OF SERVICE\\s*$"))
  body-chunks(parts.at(0))
  signature-block(meta)
  if parts.len() > 1 {
    pagebreak()
    body-chunks("# CERTIFICATE OF SERVICE\n\n" + parts.at(1))
  }
}
