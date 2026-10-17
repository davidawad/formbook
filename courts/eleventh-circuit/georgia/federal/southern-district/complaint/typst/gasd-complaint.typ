// Complaint for the U.S. District Court for the Southern District of Georgia (gasd).
// Rules: Fed. R. Civ. P. 10(a) (caption), 10(b) (numbered paragraphs); S.D. Ga. LR 10.1 (double-spaced,
// numbered pages), LR 5.4 (letter paper), LR 11.1 (counsel name, address, telephone, State Bar number).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see ../README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no S.D. Ga. typeface rule found (README.md); Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                   // the exemplar and the usual practice; not set by an S.D. Ga. rule
#let body-leading = 1.345em             // LR 10.1 double-spacing: Liberation Serif's line box is 0.655em, so this is a 24 pt pitch at 12 pt
#let single-leading = 0.495em            // single spacing for the caption, quotations, footnotes and signature
#let single-row = 13.8pt                // one single-spaced line: 0.655em line box + single-leading at 12 pt
#let page-w = 8.5in                     // LR 5.4: paper 8 1/2 by 11 inches
#let page-h = 11in
#let margin = 1in                       // not set by a rule (README.md); the usual 1-inch margin
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                // first-line indent of numbered paragraphs
#let caption-party-width = 3.1in        // width of the party column in the caption
#let caption-paren-width = 0.3in        // the ")" column of the caption

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("gasd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, italics, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  align(center, {
    text(weight: "bold", "IN THE UNITED STATES DISTRICT COURT")
    linebreak()
    text(weight: "bold", "SOUTHERN DISTRICT OF GEORGIA")
    if "division" in meta {
      linebreak()
      text(weight: "bold", upper(meta.division))
    }
  })
}

/// Caption: one row per line of the party column, a ")" in the middle, and the file number beside it.
/// Each row of frontmatter `caption.rows` is `{left: ..., right: ...}`; "right" may be empty.
#let caption(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  let rows = meta.caption.rows
  grid(
    columns: (caption-party-width, caption-paren-width, 1fr),
    rows: (single-row,) * rows.len(),
    row-gutter: 0pt,
    ..rows.map(r => (text(r.left), [)], text(r.right))).flatten(),
  )
}

#let title-block(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  v(body-leading)
  align(center, text(weight: "bold", upper(inl(meta.title))))
  v(body-leading)
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Page number centered in the bottom margin, on every page including the first (LR 10.1).
#let footer-number() = context {
  set text(size: type-size)
  align(center, counter(page).display("- 1 -"))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lettered list items, quotations
// ---------------------------------------------------------------------------

/// Numbered paragraphs (Fed. R. Civ. P. 10(b)). Each blank-line-separated chunk of markdown that is
/// neither a heading nor a list is one numbered paragraph. Headings and lists are not numbered.
/// A heading is kept in one unbreakable block with the chunk after it, so it never ends a page.
/// Numbering is applied per chunk, not with a `show par` rule: a show rule that re-wraps paragraph
/// content recurses without end in typst 0.15.
#let allegations(body, tail) = {
  // `tail` is the signature block. It follows the last chunk and is kept with it, so it never stands alone.
  let n = 0
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let last-list = chunks.len() > 0 and chunks.last().trim().match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none
  let has-pending = false
  for (k, c) in chunks.enumerate() {
    // The last list (the prayer) is kept whole, so the signature block never stands alone on a page.
    let last = k == chunks.len() - 1
    let t = c.trim()
    if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // Lettered items (a), (b) ... A list may break across pages.
      let items = {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if has-pending or last {
        block(breakable: false, width: text-width, { pending; items; if last { tail } })
      } else {
        items
      }
      pending = []
      has-pending = false
    } else if t.starts-with(">") {
      // A block quotation: indented and single-spaced, run in as one paragraph (its lines are joined).
      let quoted = t.split("\n").map(l => { let s = l.trim(); if s.starts-with(">") { s.slice(1).trim() } else { s } }).filter(s => s != "").join(" ")
      pad(left: 0.75in, right: 0.75in, block(width: 100%, {
        set par(leading: single-leading)
        text(quoted)
      }))
      v(body-leading)
    } else {
      let piece = {
        n += 1
        set par(leading: body-leading)
        h(para-indent)
        [#n.#h(0.3in)]
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      }
      if has-pending {
        pending
      }
      piece
      pending = []
      has-pending = false
    }
  }
  if pending != [] { block(breakable: false, width: text-width, pending) }
  if not last-list { block(breakable: false, width: text-width, tail) }
}

#let signature-block(meta) = {
  set par(leading: single-leading, spacing: 0pt)
  block(breakable: false, width: text-width, {
    v(body-leading)
    text(weight: "bold", upper(meta.signature.firm))
    v(single-leading)
    for s in meta.signature.signers {
      v(body-leading * 0.5)
      [/s/ #s.name]
      for l in s.lines { linebreak(); inl(l) }
      v(body-leading * 0.5)
    }
    v(body-leading * 0.5)
    for l in meta.signature.address { linebreak(); inl(l) }
    v(body-leading * 0.5)
    inl(meta.signature.counsel-for)
  })
}

#let gasd-complaint(meta, body) = {

  set page(
    paper: "us-letter",
    margin: margin,
    footer: footer-number(),
    footer-descent: 0.4in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 is a centered bold section; level 2 a centered bold sub-heading (a count);
  // level 3 is bold, flush left.
  show heading.where(level: 1): it => block(width: text-width, above: body-leading, below: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, above: body-leading, below: body-leading, sticky: true,
    align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: text-width, above: body-leading, below: body-leading, sticky: true,
    text(size: type-size, weight: "bold", it.body))

  // Quotations: indented and single-spaced (block quotes are not double-spaced in the exemplar's practice).
  show quote.where(block: true): it => pad(left: 0.75in, right: 0.75in, block(width: 100%, {
    set par(leading: single-leading)
    it.body
  }))

  // Lettered list items (prayer for relief).
  set enum(numbering: "(a)", indent: para-indent, body-indent: 0.4in, spacing: body-leading)

  // Caption page: court title, caption, title of the paper, then the lead-in and the numbered body.
  court-title(meta)
  v(body-leading)
  caption(meta)
  title-block(meta)

  if "lead_in" in meta {
    set par(leading: body-leading)
    h(para-indent)
    inl(meta.lead_in)
  }

  allegations(body, signature-block(meta))

}
