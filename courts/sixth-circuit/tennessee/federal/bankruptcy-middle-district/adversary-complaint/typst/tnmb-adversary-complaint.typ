// Adversary complaint for the United States Bankruptcy Court, M.D. Tennessee (tnmb).
// Rules: LBR 5005-3(a) (8 1/2 x 11, 12-point, one-inch margins), 5005-3(b) (page numbers at the bottom with
// room for the CM/ECF footer), 9004-2(a)-(b) (caption: case number, chapter, judge, adversary number, title),
// 7003-1 (adversary cover sheet, filed separately and not produced here); FRBP 7010 (Civil Rule 10 applies,
// so allegations are numbered, Civil Rule 10(b)). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to the filed exemplar; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // no family is named by the rules; Times New Roman substitute, the default per docs/FONTS.md
#let type-size = 12pt                 // LBR 5005-3(a): clearly legible in 12-point font
#let page-w = 8.5in                   // LBR 5005-3(a): 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin = 1in                     // LBR 5005-3(a): one-inch margins throughout
#let text-width = page-w - 2 * margin
#let body-leading = 1.345em           // double spacing (exemplar): 24 pt baseline pitch at 12 pt (line box 0.655em)
#let single-leading = 0.495em          // single spacing: caption, quotations, signature (about 13.8 pt)
#let para-indent = 0.5in              // first-line indent of paragraphs (exemplar)
#let caption-left = 3.7in             // party column of the caption: a party name must fit one row (README.md)
#let caption-mid = 0.3in              // the ")" column
#let blank = "\u{00A0}"               // a caption row with no text still takes a line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("tnmb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in *italics*, section symbols, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Footnote definitions ("[^n]: text") are blank-line-separated chunks; they are collected first.
#let note-defs(chunks) = {
  let notes = (:)
  for c in chunks {
    let m = c.trim().match(regex("^\\[\\^(\\d+)\\]:\\s*([\\s\\S]*)$"))
    if m != none { notes.insert(m.captures.at(0), m.captures.at(1)) }
  }
  notes
}

/// Inline markdown with each "[^n]" reference turned into a typst footnote.
#let inline-notes(t, notes) = {
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^(\\d+)\\]")) {
    if m.start > pos { out += inl(t.slice(pos, m.start)) }
    out += footnote(inl(notes.at(m.captures.at(0))))
    pos = m.end
  }
  if pos < t.len() { out += inl(t.slice(pos)) }
  out
}

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (LBR 9004-2)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ([IN THE UNITED STATES BANKRUPTCY COURT], [FOR THE MIDDLE DISTRICT OF TENNESSEE])
  if "division" in meta { lines.push(upper(meta.division)) }
  stack(dir: ttb, spacing: single-leading, ..lines.map(l => align(center, text(weight: "bold", l))))
}

/// The caption: the debtor and the parties in the left column, a ")" column, and on the right the
/// case number, chapter, judge and adversary number (LBR 9004-2(a)(1), (b)). One row per line.
#let caption(meta) = {
  let c = meta.caption
  let left = ("IN RE:", blank) + c.debtor + ("Debtor.", blank)
  for (k, p) in c.parties.enumerate() {
    if k > 0 { left += ("v.", blank) }
    left += p.names + (p.designation, blank)
  }
  let adv = if "adv_proc_no" in meta and meta.adv_proc_no != "" { meta.adv_proc_no } else { "________" }
  let right = (
    "Case No. " + str(meta.case_number),
    "Chapter " + str(meta.chapter),
    "Judge " + str(meta.judge),
    blank,
    "Adv. Proc. No. " + str(adv),
  )
  let n = calc.max(left.len(), right.len())
  let cells = ()
  for i in range(n) {
    cells.push(if i < left.len() { left.at(i) } else { blank })
    cells.push(")")
    cells.push(if i < right.len() { right.at(i) } else { blank })
  }
  set par(leading: single-leading, spacing: 0pt, justify: false)
  grid(
    columns: (caption-left, caption-mid, 1fr),
    row-gutter: single-leading,
    ..cells,
  )
}

#let title-block(meta) = {
  v(body-leading)
  set par(leading: single-leading, spacing: 0pt)
  for line in meta.title {
    align(center, text(weight: "bold", upper(line)))
  }
}

// ---------------------------------------------------------------------------
// Body: numbered allegations, headings, lists, quotations, signature
// ---------------------------------------------------------------------------

/// Numbered allegations. Each blank-line-separated chunk of markdown is one of: a heading (kept with the
/// chunk after it), a list (lettered A., B., ... ), a block quotation, an unnumbered paragraph (a chunk
/// that starts with "§ "; the marker is dropped), or a numbered paragraph (Civil Rule 10(b)).
/// Numbering is applied per chunk, not with a `show par` rule (that recurses without end in typst 0.15).
#let allegations(body, notes, para-counter) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let pending = []
  let has-pending = false
  for c in chunks {
    let t = c.trim()
    if t.starts-with(regex("^\\[\\^\\d+\\]:")) {
      continue
    } else if t.starts-with("#") {
      pending += cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
      continue
    }
    let piece = if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      // A list may break across pages; items are spaced by body-leading.
      block(width: text-width, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
        v(body-leading)
      })
    } else if t.starts-with(">") {
      block(width: text-width, above: body-leading, below: body-leading, inl(t))
    } else if t.starts-with("~ ") {
      block(width: text-width, below: body-leading, {
        set par(leading: body-leading, spacing: 0pt)
        h(para-indent)
        inline-notes(t.slice("~ ".len()), notes)
      })
    } else {
      para-counter.step()
      block(width: text-width, below: body-leading, context {
        set par(leading: body-leading, spacing: 0pt)
        h(para-indent)
        [#(para-counter.display()).#h(0.3in)]
        inline-notes(t, notes)
      })
    }
    // A sticky heading stays with the piece after it; it is not wrapped with it, because block spacing
    // is dropped at the top of a container and the heading would then sit on the previous line.
    if has-pending { pending }
    piece
    pending = []
    has-pending = false
  }
  if pending != [] { pending }
}

#let signature-block(meta) = block(width: text-width, breakable: false, above: body-leading, {
  pad(left: 3.25in, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(body-leading)
    stack(dir: ttb, spacing: single-leading, ..meta.signature.map(l => inl(l)))
  })
})

#let tnmb-adversary-complaint(meta, body) = {
  let para-counter = counter("allegation")
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let notes = note-defs(chunks)

  set page(
    paper: "us-letter",
    margin: margin,
    numbering: "1",
    number-align: center,
    footer-descent: 0.6in,
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Headings: level 1 a centered section; level 2 a centered bold sub-heading; level 3 bold italic.
  show heading.where(level: 1): it => block(width: text-width, above: body-leading, below: body-leading, sticky: true,
    align(center, text(weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: text-width, above: 0pt, below: body-leading, sticky: true,
    align(center, text(weight: "bold", it.body)))
  show heading.where(level: 3): it => block(width: text-width, above: 0pt, below: body-leading, sticky: true,
    text(weight: "bold", style: "italic", it.body))
  // Block quotations are single-spaced and indented from both margins.
  show quote.where(block: true): it => pad(x: 0.5in, {
    set par(leading: single-leading, spacing: 0pt)
    it.body
  })

  set enum(numbering: "A.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  court-title(meta)
  v(body-leading)
  caption(meta)
  title-block(meta)
  v(body-leading)

  allegations(body, notes, para-counter)

  signature-block(meta)
}
