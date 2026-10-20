// Motion with memorandum for the U.S. District Court for the District of Arizona (azd).
// Rules: LRCiv 7.1(a) (first page), 7.1(b)(1) (double-spaced, 28 lines, proportional font of at least 13 point,
// numbered pages, margins); LRCiv 7.2(b) (memorandum filed with the motion), 7.2(e)(1) (a motion and its
// memorandum, 17 pages); LRCiv 12.1(c) (certification for a Rule 12(b)(6) motion: author content, see README.md).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LRCiv 7.1(b)(1): proportional font; vendored in fonts/ (see README.md, gap 2)
#let type-size = 13pt                   // LRCiv 7.1(b)(1): a proportional font of no less than 13 point, footnotes included
#let pitch = 24pt                       // LRCiv 7.1(b)(1): double-spaced body; the numbered lines are this pitch
#let lines-per-page = 27                // LRCiv 7.1(b)(1): no more than 28 lines per page
#let page-w = 8.5in                     // LRCiv 7.1(b)(1): letter size
#let page-h = 11in
#let top-margin = 72pt                  // line 1 sits on the top margin; the 28 lines end at 10 1/3 inches
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the page number
#let left-margin = 1.5in                // LRCiv 7.1(b)(1): not less than 1 1/2 inches (room for the line numbers)
#let right-margin = 1in              // LRCiv 7.1(b)(1): not less than 1/2 inch
#let text-width = page-w - left-margin - right-margin
// Line box of EB Garamond is 0.65em (measured, see README.md); the leading closes the rest of the pitch,
// so one line of body text is exactly `pitch` (13 pt type gives 15.55 pt of leading).
#let body-leading = pitch - 0.65 * type-size
#let single-leading = 0.5em             // counsel block, caption, headings, signature, certificate: about 15 pt at 13 pt
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let heading-tab = 0.5in                // hanging label width of numbered headings
#let caption-left = 3.2in               // width of the party column of the caption
#let counsel-lines = 5                  // LRCiv 7.1(a)(2): the court title begins on or below line 6

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("azd-motion: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Fill whole numbered lines: the block is rounded up to a multiple of `pitch`, so whatever follows
/// it stays on the grid of numbered lines.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, {
    set par(first-line-indent: 0pt)
    c
  })
}

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

/// Page number centered in the bottom margin (LRCiv 7.1(b)(1): pages must be numbered).
#let page-number-block() = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 8pt,
  block(width: text-width, align(center, text(size: type-size, context counter(page).display()))),
)

/// Running line from the second page on: case number, short title and judge, in the bottom margin below the
/// page number (the exemplar carries it at the top; no rule fixes its position, and a top-margin line would
/// interleave with the body text at page breaks in the content gate).
#let running-header(meta) = context {
  if counter(page).get().first() > 1 and "running_header" in meta {
    place(top + left, dx: left-margin, dy: top-margin + lines-per-page * pitch + 28pt,
      block(width: text-width, align(center, text(size: 9pt, meta.running_header.join(" | ")))))
  }
}

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-5 or more), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item: each item is a block, and the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false, first-line-indent: 0pt)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let counsel-block(meta) = context {
  // Lines 1 to 5 at least; a longer counsel block pushes the court title down, which the rule allows only
  // on or below line 6 (LRCiv 7.1(a)(2)).
  let h = measure(width: text-width, line-stack(meta.counsel)).height
  block(width: text-width, height: calc.max(counsel-lines, calc.ceil(h / pitch)) * pitch,
    line-stack(meta.counsel))
}

#let court-title() = {
  on-grid(align(center, text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT")))
  on-grid(align(center, text(weight: "bold", "FOR THE DISTRICT OF ARIZONA")))
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
    // LRCiv 7.1(a)(3), right of center: (A) the number of the action, (B) a brief description of the paper,
    // (C) mention of the memorandum filed with it.
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Case No. #meta.case_number]
    v(pitch * 0.5)
    [#text(weight: "bold", inl(meta.brief_title))]
    v(pitch * 0.5)
    [#meta.judge]
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title()
  v(pitch)
  caption(meta)
  v(pitch)
}

// ---------------------------------------------------------------------------
// Body, signature and certificate
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  on-grid([DATED: #meta.date])
  on-grid(align(right, box(width: 3.4in, line-stack(meta.signature.firm + ("",) + ("By: /s/ " + meta.signature.signer,) + meta.signature.lines))))
}

#let certificate(meta) = if "certificate" in meta {
  on-grid(align(center, text(weight: "bold", meta.certificate.heading)))
  on-grid({
    set par(leading: body-leading)
    h(para-indent)
    meta.certificate.text
  })
  on-grid(line-stack(meta.certificate.service))
  on-grid(align(right, box(width: 3.4in, [/s/ #meta.certificate.signer])))
}

/// The body, chunk by chunk (blank-line separated, as in the other doc types). A heading is one line-grid block; a
/// paragraph is a block with a gap of one body-leading below it, so every chunk is a whole number of numbered lines
/// and the next chunk starts on the grid. (A paragraph followed directly by a heading lost that gap in the first
/// version: the heading overlapped the last line.)
#let body-blocks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
    } else {
      block(width: text-width, below: body-leading, {
        // The indent is an explicit h(): typst does not indent the first paragraph inside a block.
        set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt)
        h(para-indent)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    }
  }
}

#let azd-motion(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: page-number-block(),
    header: running-header(meta),
    header-ascent: 0pt,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: body-leading, first-line-indent: para-indent, justify: false)
  set heading(numbering: heading-num)

  // Headings: level 1 is a centered, unnumbered section; levels 2 to 5 are numbered (I., A., 1., a.) and hang
  // from the margin. Each is kept with the paragraph after it.
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    if it.level == 1 {
      block(width: text-width, sticky: true, above: 0pt, below: 0pt,
        on-grid(align(center, text(weight: "bold", upper(it.body)))))
    } else {
      let ind = (it.level - 2) * heading-tab
      // A hanging paragraph, not a grid. Its lines use the body pitch: two single-spaced lines measure 23.4 pt,
      // which rounds to one grid line and let the second line overlap the text below.
      block(width: text-width, sticky: true, above: 0pt, below: 0pt, {
        set par(leading: body-leading, first-line-indent: 0pt, hanging-indent: ind + heading-tab)
        let body-text = if it.level == 5 { text(style: "italic", weight: "bold", it.body) } else { strong(it.body) }
        on-grid([#h(ind)#box(width: heading-tab, lab)#body-text])
      })
    }
  }

  cover(meta)

  if "lead_in" in meta {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  // Body: unnumbered paragraphs (a memorandum), headings numbered by the template.
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  body-blocks(body)

  // LRCiv 12.1(c): a Rule 12(b)(6) motion needs a certification of the conference before filing. Author content:
  // the template draws the heading and the text but does not check either.
  if "certification" in meta {
    on-grid(align(center, text(weight: "bold", meta.certification.heading)))
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      meta.certification.text
    })
  }

  signature-block(meta)
  certificate(meta)
}
