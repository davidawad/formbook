// Complaint for the U.S. District Court for the Northern District of Ohio (ohnd).
// Rules: Fed. R. Civ. P. 8(a) (short and plain statement), 10(a) (caption), 10(b) (numbered paragraphs),
// 38(b) (jury demand, when made); N.D. Ohio L.R. 10.1 (8 1/2 x 11 white paper, double spacing except
// quotations, a 1 1/2 inch top margin on the first page, consecutive page numbers, signature details);
// L.R. 3.13(a) (civil cover sheet, filed separately). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // L.R. 10.1 names no face; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                  // convention for federal filings; no N.D. Ohio font rule in L.R. 10.1
// Absolute lengths at 12 pt, so pitches can be divided (typst cannot divide two em lengths). Liberation Serif's
// line box is 0.655 em (7.86 pt); single spacing adds the rest of 1.15 em (13.8 pt pitch); double
// spacing is twice that (27.6 pt pitch), the same pitch Word gives 12 pt type.
#let natural-line = 7.86pt
#let single-pitch = 13.8pt
#let body-pitch = 2 * single-pitch
#let body-leading = body-pitch - natural-line
#let single-leading = single-pitch - natural-line
#let para-indent = 0.5in               // first-line indent of numbered paragraphs
#let page-w = 8.5in                    // L.R. 10.1: 8 1/2 x 11 inch paper
#let margin = 1in                      // convention: one inch on all sides
#let first-page-top = 1.5in            // L.R. 10.1: top margin of the first page, for the clerk's file stamp
#let text-width = page-w - 2 * margin
#let caption-left = 3.3in              // width of the party column of the caption
#let caption-paren = 0.3in             // the column of ")" marks

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ohnd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, the signature lines, and so on).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Lines set single-spaced, one per item; the stack keeps the single pitch between them.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// A double-spaced block that stays on the grid of body lines. Typst puts leading only between lines, so the
/// trailing leading is added as space: n lines then occupy n full body pitches. The block can still break
/// across pages (a fixed-height block could not, and a paragraph that crosses a page would overlap).
#let on-grid(c) = block(width: text-width, above: 0pt, below: 0pt, {
  c
  v(body-leading)
})

// ---------------------------------------------------------------------------
// Page furniture: 1 1/2 inch top margin on page 1 (L.R. 10.1), consecutive page numbers at the foot
// ---------------------------------------------------------------------------

/// Court title, centered, below the first page's extra 1/2 inch.
#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "NORTHERN DISTRICT OF OHIO")
  if "division" in meta { lines.push(upper(meta.division)) }
  align(center, line-stack(lines))
}

// ---------------------------------------------------------------------------
// Caption: party names, a column of ")" marks (one per line of each name), and the case number and judge
// ---------------------------------------------------------------------------

/// One caption row: the name in the first column, and as many ")" as the name has lines in the second.
#let caption-row(r) = {
  let name = if r == "" {
    box(height: single-pitch, width: 0pt)
  } else {
    // A trailing leading makes every line occupy one full single pitch (typst puts leading only between lines).
    block(width: caption-left, {
      set par(leading: single-leading, spacing: 0pt)
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
        set par(leading: single-leading, spacing: 0pt)
        "Case No. " + meta.case_number
        v(single-pitch)
        let judge = if "judge" in meta { meta.judge } else { "" }
        "Judge: " + judge
      }))
    }
  }
  grid(
    columns: (caption-left, caption-paren, 1fr),
    column-gutter: 0pt,
    ..cells,
  )
}

/// The title of the paper, bold and centered, one double-spaced line below the caption.
#let title-block(meta) = {
  v(body-pitch)
  align(center, block(width: text-width, {
    set par(leading: single-leading, spacing: 0pt)
    strong(inl(meta.title))
  }))
  v(body-pitch)
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Markdown marker for a paragraph the filing does not number: a chunk that starts with it is unnumbered.
#let unnumbered-marker = "<!--u-->"

/// Blank-line-separated markdown chunks of the body. A paragraph is numbered (Fed. R. Civ. P. 10(b)).
/// A heading is set in front of the chunk after it, so a heading never ends a page. A chunk made only of
/// **bold** text is an unnumbered run-in label (the group labels of a list of conditions). A list is
/// lettered A., B., ... and its numbers follow the markdown numbers, so a group can continue a letter run.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let out = ()
  let pending = []
  for c in chunks {
    let t = c.trim()
    // Each chunk is either a run-in part (heading or label, held until the next piece) or a piece.
    let run-in = false
    let piece = none
    if t.starts-with("#") {
      run-in = true
      pending += block(sticky: true, width: text-width, on-grid(cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)))
    } else if t.starts-with("**") and t.ends-with("**") and not t.slice(2, -2).contains("**") {
      run-in = true
      pending += block(sticky: true, width: text-width, on-grid({
        set par(leading: body-leading, spacing: 0pt)
        strong(inl(t.slice(2, -2)))
      }))
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      // Lettered sub-paragraphs: the markdown number is the letter's position, the template letters them.
      // Items are spaced by the body leading, so the trailing v() closes the last item's gap.
      piece = {
        set par(leading: body-leading, spacing: 0pt)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
    } else if t.starts-with(unnumbered-marker) {
      // A paragraph the filing leaves unnumbered (the WHEREFORE clause): indented, not counted.
      piece = on-grid({
        set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt)
        h(para-indent)
        cmarker.render(t.slice(unnumbered-marker.len()).trim(), raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else {
      // The counter step is part of the piece's content, so it lands in the document at this paragraph.
      piece = {
        para-counter.step()
        on-grid({
          set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt)
          context [#h(para-indent)#(para-counter.display()).#h(0.5in)#cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)]
        })
      }
    }
    if run-in {
      continue
    }
    // A pending heading or label is sticky: it stays on the page of the piece after it.
    if pending != [] {
      out.push({ pending; piece })
    } else {
      out.push(piece)
    }
    pending = []
  }
  if pending != [] { out.push(pending) }
  out
}

/// Jury demand (Fed. R. Civ. P. 38(b)); printed only when the frontmatter asks for it.
#let jury-demand(meta) = if "jury_demand" in meta and meta.jury_demand {
  on-grid(align(center, strong("JURY DEMAND")))
  on-grid({
    set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt)
    h(para-indent)
    "Plaintiff demands a trial by jury on all issues so triable."
  })
}

/// Signature block: single-spaced at the right; the date at the left (L.R. 10.1: the typed name, address,
/// telephone, facsimile, e-mail and Ohio Bar Registration Number go in the lines).
#let signature-block(meta) = block(width: text-width, breakable: false, {
  v(body-pitch)
  grid(
    columns: (2.6in, 1fr),
    column-gutter: 0.2in,
    if "date" in meta { [Dated: #meta.date] } else { [] },
    {
      set par(leading: single-leading, spacing: 0pt)
      [Respectfully submitted,]
      v(single-pitch)
      line-stack(meta.signature.lines)
    },
  )
})

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let ohnd-complaint(meta, body) = {
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: (top: margin, bottom: margin, left: margin, right: margin),
    footer: context align(center, text(size: type-size, counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)
  // Lettered sub-paragraphs (markdown ordered lists): A., B., ... ; a list may break across pages.
  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.5in, spacing: body-leading)

  // Headings: level 1 is a centered bold section; level 2 a centered bold sub-heading; level 3 bold, left.
  show heading.where(level: 1): it => align(center, text(size: type-size, weight: "bold", upper(it.body)))
  show heading.where(level: 2): it => align(center, text(size: type-size, weight: "bold", it.body))
  show heading.where(level: 3): it => text(size: type-size, weight: "bold", style: "italic", it.body)

  // First page: the top margin is 1 1/2 inches (L.R. 10.1), so the first page starts with the extra 1/2 inch.
  v(first-page-top - margin)
  court-title(meta)
  v(body-pitch)
  caption(meta)
  title-block(meta)

  if "lead_in" in meta {
    on-grid({
      set par(leading: body-leading, spacing: 0pt)
      h(para-indent)
      inl(meta.lead_in)
    })
  }

  // The last paragraph, the jury demand and the signature block share one unbreakable block, so the
  // signature never stands alone on a page (the WHEREFORE clause stays with it).
  let pieces = allegations(body, para-counter)
  let n = pieces.len()
  pieces.slice(0, calc.max(0, n - 1)).join()
  block(breakable: false, width: text-width, (
    pieces.at(n - 1, default: []),
    jury-demand(meta),
    signature-block(meta),
  ).join())
}
