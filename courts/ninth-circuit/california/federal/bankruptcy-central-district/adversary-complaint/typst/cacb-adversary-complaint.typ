// Adversary complaint for the United States Bankruptcy Court, Central District of California (cacb).
// Rules: FRBP 7008(a) and LBR 7008-1 (core/non-core statement in the first numbered paragraph); FRBP 7010 (caption);
// LBR 7003-1 (Official Form 1040 cover sheet, paper filings only); LBR 9004-1 and The Central Guide Supplement to
// LBR 9004-1 (Aug. 2022): 8.5 x 11 pages, numbered margins of at most 28 lines, 12-point type or larger, double
// spacing, line 1 at least 1 inch below the top edge, page numbers at the bottom, counsel block on lines 1-7,
// court title on or below line 8, double caption, case / chapter / adversary numbers, hearing line on page 1.
// See ../README.md for the rule text, the open choices and the gaps.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // Central Guide 9004-1(b)(2)(C): Times New Roman is a listed typeface; Liberation Serif is its metric-compatible substitute (docs/FONTS.md)
#let type-size = 12pt                   // Central Guide 9004-1(b)(2)(C): not smaller than 12 point (the floor; the filed exemplar is 12 pt)
#let pitch = 24pt                       // Central Guide 9004-1(b)(2)(F): double-spaced; the numbered lines are this pitch
#let lines-per-page = 27                // Central Guide 9004-1(b)(2)(B)(i): not more than 28 numbered lines per page
#let page-w = 8.5in                     // Central Guide 9004-1(b)(2)(A): 8 1/2 by 11 inch pages
#let page-h = 11in
#let top-margin = 72pt                  // Central Guide 9004-1(b)(2)(C): line 1 at least 1 inch below the top edge
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the page number and footer
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let body-leading = 1.345em             // double spacing: Liberation Serif's line box is about 0.655em, so 1.345em leading makes a 24 pt baseline pitch at 12 pt (measured, README.md)
#let single-leading = 0.345em          // single spacing: 12 pt pitch at 12 pt type, so two single lines fit each numbered line (measured, README.md)
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let caption-left = 3.3in               // width of the party column of the double caption
#let counsel-lines = 7                  // Central Guide 9004-1(c)(1)(B): the space between lines 1 and 7 is left for the clerk; the court title starts on line 8

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("cacb-adversary-complaint: the sample must start with a YAML frontmatter block") }
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

/// A heading: whole numbered lines (one, or more when a statute line wraps), kept with the paragraph after it.
#let heading-line(c) = block(width: text-width, above: 0pt, below: 0pt, sticky: true, context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, c)
})

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

/// Page number at the bottom of every page (Central Guide 9004-1(b)(2)(G)), then the paper's title
/// and the adversary number on the footer line.
#let footer-block(title, adversary-number) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 6pt,
  block(width: text-width, {
    set text(size: type-size)
    align(center, context counter(page).display("1"))
    v(4pt)
    grid(
      columns: (1fr, auto),
      upper(title),
      [ADV. NO. #adversary-number],
    )
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-7), court title (line 8), double caption, title of the paper
// ---------------------------------------------------------------------------

/// One single-spaced line per item: each item is a block, and the stack keeps the single pitch.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

#let counsel-block(meta) = context {
  // Lines 1-7 at least; more counsel lines push the court title down (Central Guide 9004-1(c)(1)(B)-(C)).
  let h = measure(width: text-width, line-stack(meta.counsel)).height
  block(width: text-width, height: calc.max(counsel-lines, calc.ceil((h + 6pt) / pitch)) * pitch,
    line-stack(meta.counsel))
}

#let court-title(meta) = {
  on-grid(align(center, text(weight: "bold", "UNITED STATES BANKRUPTCY COURT")))
  on-grid(align(center, text(weight: "bold", "CENTRAL DISTRICT OF CALIFORNIA")))
  on-grid(align(center, text(weight: "bold", upper(meta.division))))
}

/// The double caption (Central Guide 9004-1(c)(2)): debtor on top, then the adversary parties, separated
/// from the right-hand column by a rule. Right column: case number, chapter, adversary number, title, hearing.
#let caption(meta) = on-grid(grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    let rows = ("In re:", ..meta.caption.debtor.names, meta.caption.debtor.designation, "\u{00A0}")
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 {
        rows.push("\u{00A0}")
        rows.push("v.")
        rows.push("\u{00A0}")
      }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack((
      "Case No. " + meta.bankruptcy_case,
      "Chapter " + meta.chapter,
      "\u{00A0}",
      "Adv. No. " + meta.adversary_number,
    ))
    v(pitch * 0.5)
    text(weight: "bold", inl(meta.brief_title))
    if "legend" in meta and meta.legend != none {
      v(pitch * 0.5)
      text(weight: "bold", upper(meta.legend))
    }
    v(pitch * 0.5)
    line-stack(meta.hearing)
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
// Body and signature
// ---------------------------------------------------------------------------

// The signature block never splits across pages (a split leaves the last line on a page of its own).
#let signature-block(meta) = block(breakable: false, width: text-width, on-grid(grid(
  columns: (2.6in, 1fr),
  column-gutter: 0.2in,
  [Dated: #meta.date],
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(pitch * 0.5)
    line-stack(meta.signature.firm)
    v(pitch * 0.5)
    line-stack(("By: /s/ " + meta.signature.signer, upper(meta.signature.signer)) + meta.signature.lines)
  },
)))

/// Joins a heading (`lead`, or none) and the last piece (`tail`, or none) into one unbreakable block: a heading
/// never ends a page, and the signature block never stands alone on a page.
#let kept(lead, piece, tail) = if lead == none and tail == none { piece } else {
  block(breakable: false, width: text-width, { if lead != none { lead }; piece; if tail != none { tail } })
}

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a
/// list is one numbered paragraph (FRBP 7010 applies Fed. R. Civ. P. 10(b)). Headings and lists are unnumbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15. `signature` follows the last chunk and is kept with it.
#let allegations(body, para-counter, signature) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let tail-of(i) = if i == chunks.len() - 1 { signature } else { none }
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; only a heading in front of it is kept with its first line.
      // Items are spaced by body-leading, so each item fills whole lines; the trailing v() closes the last one.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      kept(if has-pending { pending } else { none }, items, tail-of(i))
      pending = []
      has-pending = false
    } else if t.starts-with("WHEREFORE") {
      // The prayer's lead-in is not a numbered allegation (it is unnumbered in the filed complaint).
      let piece = on-grid({ set par(leading: body-leading); h(para-indent); cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1) })
      kept(if has-pending { pending } else { none }, piece, tail-of(i))
      pending = []
      has-pending = false
    } else {
      // A paragraph breaks across pages like any text; only a heading in front of it is kept with its first line.
      let piece = {
        para-counter.step()
        on-grid({ set par(leading: body-leading); context [#h(para-indent)#(para-counter.display()).#h(0.3in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)] })
      }
      kept(if has-pending { pending } else { none }, piece, tail-of(i))
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, { pending; signature }) }
}

#let cacb-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title, meta.adversary_number),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered section; level 2 a bold centered sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => heading-line(align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => heading-line(align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => heading-line(text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)

  if "lead_in" in meta {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  // Body: numbered allegations; markdown lists become (a), (b), ...
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter, signature-block(meta))
}
