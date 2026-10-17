// Complaint for the U.S. District Court for the District of Nevada (nvd).
// Rules: LR IA 10-1 (numbered lines, 28 per page, double-spaced text, 12 pt or larger, one-inch margins,
// numbered pages), LR IA 10-2 (first-page format), LR 38-1 (JURY DEMAND below the title); Fed. R. Civ. P.
// 10(a) (caption), 10(b) (numbered paragraphs). See ../README.md for the rule text and the choices made here.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // vendored in fonts/ (the only serif face vendored); LR IA 10-1(a)(3) names no face
#let type-size = 13pt                   // LR IA 10-1(a)(3): 12 pt or larger. 13 pt EB Garamond looks like 12 pt Times (README.md)
#let lines-per-page = 28                // LR IA 10-1(a)(1): no more than 28 numbered lines per page
#let page-w = 8.5in                     // LR IA 10-1(c): 8 1/2 by 11 inch paper
#let page-h = 11in
#let top-margin = 1in                   // LR IA 10-1(a)(6): margins at least one inch on all four sides
#let bottom-margin = 1in
#let pitch = (page-h - top-margin - bottom-margin) / lines-per-page   // 23.14 pt: 28 lines fit exactly between the margins
#let left-margin = 1.5in                // room for the line numbers and the pleading rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let body-leading = (pitch / type-size - 0.65) * 1em   // double spacing on the numbered-line grid; 0.65em is EB Garamond's line box (README.md)
#let single-leading = 0.5em             // single spacing for counsel, caption, quotations and signature
#let para-indent = 0.5in                // first-line indent of numbered allegations
#let caption-left = 3.2in               // width of the party column of the caption
#let counsel-lines = 7                  // the counsel block occupies at least lines 1 to 7

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("nvd-complaint: the sample must start with a YAML frontmatter block") }
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

/// The same for an indented block (a quotation): measured at the indented width, then placed on the grid.
#let on-grid-indented(c) = context {
  let h = measure(width: text-width - 1in, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, pad(left: 0.5in, right: 0.5in, c))
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 28 down the left margin, one per numbered line.
#let line-numbers() = {
  for i in range(1, lines-per-page + 1) {
    place(top + left, dx: 0pt, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.42in, height: pitch,
        align(right, text(size: type-size, str(i)))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// Page number ("-1-") and, when the sample gives one, the paper's title, both in the bottom margin.
/// Text is 12 pt or larger (LR IA 10-1(a)(3)).
#let footer-block(title) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 4pt,
  block(width: text-width, {
    set text(size: 12pt)
    set par(leading: single-leading, spacing: 0pt)
    align(center, context counter(page).display("-1-"))
    if title != none {
      v(4pt)
      align(center, upper(title))
    }
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (single spaced, LR IA 10-2), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// Single-spaced items, one per line; the stack keeps the single leading.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items)
}

#let counsel-block(meta) = context {
  // Counsel is set on at least lines 1 to 7; a longer block pushes the court title down.
  let h = measure(width: text-width, line-stack(meta.counsel.map(inl))).height
  block(width: text-width, height: calc.max(counsel-lines, calc.ceil(h / pitch)) * pitch,
    line-stack(meta.counsel.map(inl)))
}

#let court-title() = {
  on-grid(align(center, text(weight: "bold", "UNITED STATES DISTRICT COURT")))
  on-grid(align(center, text(weight: "bold", "DISTRICT OF NEVADA")))
}

#let caption(meta) = on-grid(grid(
  columns: (caption-left, 1fr),
  column-gutter: 0.2in,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: 10pt, bottom: 8pt), {
    // Each party: its names, then its designation (indented); "v." between the parties.
    let rows = ()
    let sep = meta.caption.at("separator", default: "v.")
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push(inl(sep)) }
      for n in p.names { rows.push(inl(n)) }
      rows.push(pad(left: 1.2in, inl(p.designation)))
    }
    line-stack(rows)
  }),
  block(inset: (left: 0.1in), {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    line-stack(("Case No.: " + meta.case_number,).map(inl))
    v(pitch * 0.5)
    text(weight: "bold", inl(meta.brief_title))
    // LR 38-1: "JURY DEMAND" in capitals on the first page, immediately below the title of the pleading.
    if "jury_demand" in meta and meta.jury_demand {
      v(pitch * 0.5)
      text(weight: "bold", "JURY DEMAND")
    }
    // Claims summary (the complaint's first-page list of causes of action), one hanging item each.
    if "summary" in meta and meta.summary != none {
      v(pitch * 0.5)
      for (k, s) in meta.summary.enumerate() {
        block(width: 100%, inset: (bottom: 4pt), par(hanging-indent: 0.35in, [(#(k + 1)) #text(weight: "bold", inl(s))]))
      }
    }
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  v(pitch)
  court-title()
  v(pitch)
  caption(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  on-grid(meta.date)
  v(pitch)
  pad(left: 2.6in, {
    on-grid(line-stack(meta.signature.firm.map(inl)))
    v(pitch * 0.5)
    on-grid(line-stack((inl("By: /s/ " + meta.signature.signer),) + meta.signature.lines.map(inl)))
  })
}

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading, a
/// list nor a quotation is one numbered paragraph (Fed. R. Civ. P. 10(b)). Headings, lists and
/// quotations are not numbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter, unnumbered) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  // The section the chunk is in (its level 1 heading, upper case). Sections listed in the sample's
  // `unnumbered_sections` (for example the prayer and the jury demand) take unnumbered paragraphs.
  let section = ""
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      if t.starts-with("# ") { section = upper(t.replace(regex("^#\\s*"), "").trim()) }
      pending += on-grid(cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1))
      has-pending = true
    } else {
      let piece = if t.starts-with("(") and t.ends-with(")") {
        // A parenthetical line under a claim heading ("(Plaintiff ... against Defendant ...)"): centered, unnumbered.
        on-grid(align(center, cmarker.render(t, raw-typst: false, smart-punctuation: true)))
      } else if t.starts-with(">") {
        // A quotation: single spaced, indented, unnumbered (LR IA 10-1(a)(4) for quotes over 50 words).
        on-grid-indented({
          set par(leading: single-leading)
          cmarker.render(t, raw-typst: false, smart-punctuation: true)
        })
      } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
        // A list may break across pages; only a heading in front of it is kept with its first line.
        // Items are spaced by body-leading, so each item fills whole lines; the trailing v() closes the last one.
        // Not wrapped in on-grid: a fixed-height block cannot break between pages, and a list must.
        {
          set par(leading: body-leading)
          cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
          v(body-leading)
        }
      } else {
        // A numbered paragraph (unless its section is unnumbered). It breaks across pages like any text.
        let numbered = not unnumbered.contains(section)
        if numbered { para-counter.step() }
        on-grid({
          set par(leading: body-leading)
          context {
            let lead = if numbered { [#h(para-indent)#(para-counter.display()).#h(0.3in)] } else { h(para-indent) }
            lead + cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
          }
        })
      }
      if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if has-pending { block(breakable: false, width: text-width, pending) }
}

#let nvd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.at("footer_title", default: none)),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered caps section; level 2 a centered bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => align(center, text(weight: "bold", upper(it.body)))
  show heading.where(level: 2): it => align(center, text(weight: "bold", it.body))
  show heading.where(level: 3): it => text(weight: "bold", style: "italic", it.body)

  cover(meta)

  if "lead_in" in meta and meta.lead_in != none {
    on-grid({
      set par(leading: body-leading)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  // Body: numbered allegations (Fed. R. Civ. P. 10(b)); markdown lists are numbered 1., 2., ... as typed.
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  allegations(body, para-counter, meta.at("unnumbered_sections", default: ()))

  signature-block(meta)
}
