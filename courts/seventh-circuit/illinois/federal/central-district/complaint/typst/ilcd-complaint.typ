// Complaint for the U.S. District Court for the Central District of Illinois (ilcd).
// Rules: Civil LR 5.1 (format: letter paper, one-inch margins, numbered pages, double spacing, 12- or 14-point body),
// 38.1 (title words for a jury demand), 40.1(E)(1) (division in the caption), 5.11(A) (s/name signatures),
// 11.1 (telephone number and typed name); Fed. R. Civ. P. 8(a), 10(a), 10(b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = "Liberation Serif"        // Times New Roman substitute per docs/FONTS.md, vendored in fonts/; LR 5.1(B)(2) asks for a plain roman style
#let type-size = 12pt                   // LR 5.1(B)(2): body text 12-point or 14-point
#let page-margin = 1in                  // LR 5.1(A): approximately one-inch margins on each side, top and bottom
#let body-leading = 1.345em             // LR 5.1(B)(1): double spacing. Liberation Serif's line box is 0.655em, so 0.655em + 1.345em = 2.0em = 24 pt at 12 pt
#let single-leading = 0.5em             // single spacing for the caption, block quotations and signature blocks
#let gap = 2em                          // one blank double-spaced line (24 pt at 12 pt), used around headings and blocks
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-left = 3.2in               // party column of the caption
#let paren-col = 0.3in                  // column of ")" marks between the party column and the case column
#let designation-indent = 1.25in        // "Plaintiff," and "v." sit under the party names

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ilcd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number, centered in the footer (LR 5.1(A): pages must be numbered).
#let page-footer() = context align(center, text(size: type-size, counter(page).display()))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = stack(dir: ttb, spacing: single-leading,
  align(center, text(weight: "bold", [UNITED STATES DISTRICT COURT])),
  align(center, text(weight: "bold", [CENTRAL DISTRICT OF ILLINOIS])),
  // LR 40.1(E)(1): the caption must identify the division in which the case is pending.
  align(center, text(weight: "bold", upper(meta.division))),
)

/// One ")" mark per line of a caption row: a long party name wraps onto more lines, and its row gets one mark per line.
#let paren-cell(content) = context {
  let h = measure(width: caption-left, content).height
  let n = int(calc.max(1, calc.round((h + single-leading).to-absolute().pt() / (0.655em + single-leading).to-absolute().pt())))
  align(right, stack(dir: ttb, spacing: single-leading, ..range(n).map(_ => [)])))
}

/// Caption: party names with ")" marks in their own column, and the case number and jury legend at the right.
/// Built as one grid so the marks always sit beside the names they belong to. The right-hand cell spans the rows.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push(pad(left: designation-indent, [v.])) }
    for n in p.names { rows.push(inl(n)) }
    rows.push(pad(left: designation-indent, inl(p.designation)))
  }
  let case-cell = grid.cell(
    rowspan: rows.len(),
    align: horizon,
    pad(left: 0.15in, {
      set par(leading: single-leading, spacing: 0pt)
      [Case No. #meta.case_number]
      if "jury_demand" in meta and meta.jury_demand {
        v(single-leading * 2)
        [Jury Trial Demanded]
      }
    }),
  )
  // Row 1 carries the spanning cell; the later rows fill the free columns 1 and 2 only.
  let cells = ()
  for (k, r) in rows.enumerate() {
    cells.push(r)
    cells.push(paren-cell(r))
    if k == 0 { cells.push(case-cell) }
  }
  set par(leading: single-leading, spacing: 0pt)
  grid(
    columns: (caption-left, paren-col, 1fr),
    row-gutter: single-leading,
    ..cells,
  )
}

#let cover(meta) = {
  court-title(meta)
  v(gap)
  caption(meta)
  v(gap)
  set par(leading: single-leading, spacing: 0pt)
  align(center, text(weight: "bold", upper(meta.brief_title)))
  if "equitable_relief" in meta and meta.equitable_relief {
    v(single-leading)
    align(center, text(weight: "bold", [EQUITABLE RELIEF IS SOUGHT]))
  }
}

// ---------------------------------------------------------------------------
// Signature blocks
// ---------------------------------------------------------------------------

#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => inl(i)))
}

/// Dated line, then "Respectfully submitted," and one "/s/ name" block per signer (LR 5.11(A)(2)).
/// Each signer's name, bar number, firm, address, telephone and email are typed below the signature (LR 11.1).
#let signature-block(meta) = block(breakable: false, width: 100%, above: gap, below: 0pt, {
  line-stack(("Dated: " + meta.date,))
  v(gap)
  line-stack(("Respectfully submitted,",))
  for s in meta.signature {
    v(gap)
    line-stack(("/s/ " + s.signer,) + s.lines)
  }
})

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lettered prayer items
// ---------------------------------------------------------------------------

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is neither a heading
/// nor a list is one numbered paragraph. Headings and lists are not numbered.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph content
/// recurses without end in typst 0.15.
#let paragraphs(body, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; only a heading in front of it is kept with its first line.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true)
        v(body-leading)
      }
      if has-pending {
        block(breakable: false, width: 100%, { pending; items })
      } else {
        items
      }
      pending = []
      has-pending = false
    } else {
      // A numbered paragraph breaks across pages like any text; only a heading in front of it is kept with its first line.
      // A chunk that starts with "[unnumbered]" is an indented paragraph outside the numbering (the WHEREFORE
      // clause and the jury demand sentence in the filing are not numbered).
      let unnumbered = t.starts-with("[unnumbered]")
      let piece = block(width: 100%, {
        if not unnumbered { para-counter.step() }
        set par(leading: body-leading, first-line-indent: 0pt)
        let text-md = if unnumbered { t.slice(12).trim() } else { t }
        context [#h(para-indent)#if not unnumbered [#(para-counter.display()).#h(0.3in)]#cmarker.render(text-md, raw-typst: false, smart-punctuation: true)]
        v(body-leading)
      })
      if has-pending {
        block(breakable: false, width: 100%, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: 100%, pending) }
}

#let ilcd-complaint(meta, body) = {
  assert("division" in meta, message: "ilcd-complaint: LR 40.1(E)(1) requires the division in the caption (frontmatter: division)")
  if meta.jury_demand {
    // LR 38.1: where a jury demand is endorsed, the title of the pleading must include "and demand for jury trial".
    assert(lower(meta.brief_title).contains("and demand for jury trial"), message: "ilcd-complaint: LR 38.1: a jury demand needs 'and demand for jury trial' in the title")
  }
  let para-counter = counter("allegation")

  set page(
    paper: "us-letter",
    margin: page-margin,
    numbering: none,
    footer: page-footer(),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 a centered section; level 2 a centered bold count heading; level 3 a centered bold subtitle.
  show heading.where(level: 1): it => block(width: 100%, above: 0pt, below: body-leading, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, above: 0pt, below: body-leading, sticky: true,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: 100%, above: 0pt, below: body-leading, sticky: true,
    align(center, text(weight: "bold", it.body)))

  cover(meta)
  v(gap)

  // The unnumbered lead-in paragraph (the opening sentence before paragraph 1).
  if "lead_in" in meta {
    block(width: 100%, {
      set par(leading: body-leading, first-line-indent: 0pt)
      h(para-indent)
      inl(meta.lead_in)
      v(body-leading)
    })
  }

  // Lettered items for the prayer for relief (markdown lists become (a), (b), ...).
  set enum(numbering: "(a)", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  paragraphs(body, para-counter)

  signature-block(meta)
}
