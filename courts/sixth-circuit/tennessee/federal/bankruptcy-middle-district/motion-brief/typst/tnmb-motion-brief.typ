// Memorandum of law in support of a motion, for the United States Bankruptcy Court, M.D. Tennessee (tnmb).
// Rules: LBR 5005-3(a), (b) (8 1/2 x 11, 12-point, one-inch margins, page numbers at the bottom with room for
// the CM/ECF footer); LBR 9004-2 (caption: case number, chapter, judge, adversary number, title); LBR 9013-2
// (briefs and memoranda; citations retrievable from Westlaw or Lexis); LBR 9013-3 (certificate of service:
// manner of service, names and addresses served). A motion travels with an LBR 9013-1 Notice and a proposed
// order; those are separate filings and are not produced here. See ../README.md.
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
#let single-leading = 0.495em          // single spacing: caption, quotations, headings, signature (about 13.8 pt)
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
  if m == none { panic("tnmb-motion-brief: the sample must start with a YAML frontmatter block") }
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

/// Inline markdown with each "[^n]" reference turned into a typst footnote (in text, headings and quotations).
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

#let title-block(meta) = stack(dir: ttb, spacing: single-leading,
  ..meta.title.map(l => align(center, text(weight: "bold", upper(l)))))

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, quotations, lists, signature, certificate of service
// ---------------------------------------------------------------------------

/// A heading. Level 1 is a centered section; level 2 is a bold sub-heading, left aligned with a hanging
/// indent (the letter of the argument point starts the line). Each heading is one sticky block, so it
/// never ends a page.
#let heading-block(level, c) = {
  if level == 1 {
    block(width: text-width, above: body-leading, below: body-leading, sticky: true,
      align(center, text(weight: "bold", upper(c))))
  } else {
    block(width: text-width, above: body-leading, below: body-leading, sticky: true,
      par(leading: single-leading, spacing: 0pt, hanging-indent: 0.5in, text(weight: "bold", c)))
  }
}

/// The body: each blank-line-separated chunk is a heading (#, ##, ###), a list, a block quotation (">"),
/// or a paragraph. Paragraphs are not numbered (LBR 9013-2 and the filed memorandum). The last paragraph
/// is kept with the signature block, so a signature never starts a page alone.
#let body-text(body, notes) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let live = chunks.filter(c => not c.trim().starts-with(regex("^\\[\\^\\d+\\]:")))
  for (i, c) in live.enumerate() {
    let t = c.trim()
    let hd = t.match(regex("^(#+)\\s+([\\s\\S]*)$"))
    if hd != none {
      heading-block(hd.captures.at(0).len(), inline-notes(hd.captures.at(1), notes))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      block(width: text-width, below: body-leading, {
        set par(leading: body-leading)
        cmarker.render(t, raw-typst: false, smart-punctuation: true, h1-level: 1)
      })
    } else if t.starts-with(">") {
      // The ">" markers are removed, and each quoted paragraph is its own block, so a footnote reference
      // inside the quotation splits only that paragraph and the paragraphs keep their spacing.
      let txt = t.split("\n").map(l => l.replace(regex("^>\\s?"), "")).join("\n")
      let paras = txt.split(regex("\\n[ \\t]*\\n")).filter(p => p.trim() != "")
      block(width: text-width, above: body-leading, below: body-leading, quote(block: true,
        stack(dir: ttb, spacing: 1em, ..paras.map(p => inline-notes(p.trim(), notes)))))
    } else {
      block(width: text-width, below: body-leading, sticky: i == live.len() - 1, {
        set par(leading: body-leading, spacing: 0pt)
        h(para-indent)
        inline-notes(t, notes)
      })
    }
  }
}

#let signature-block(meta) = block(width: text-width, breakable: false, above: body-leading, {
  pad(left: 2.5in, {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(body-leading)
    stack(dir: ttb, spacing: single-leading, ..meta.signature.map(l => inl(l)))
  })
})

/// Certificate of service (LBR 9013-3): the statement of service, then each addressee as a single-spaced block.
#let certificate-block(meta) = if "certificate" in meta {
  heading-block(1, [CERTIFICATE OF SERVICE])
  block(width: text-width, below: body-leading, {
    set par(leading: body-leading, spacing: 0pt)
    h(para-indent)
    inl(meta.certificate.text)
  })
  for addressee in meta.certificate.recipients {
    pad(left: 0.5in, block(width: text-width, below: body-leading,
      stack(dir: ttb, spacing: single-leading, ..addressee.map(l => inl(l)))))
  }
}

#let tnmb-motion-brief(meta, body) = {
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

  // LBR 5005-3(a) applies 12-point type to all filings, footnotes included (the exemplar's are smaller; README.md).
  show footnote.entry: set text(size: type-size)
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
  v(body-leading)
  title-block(meta)
  v(body-leading)

  body-text(body, notes)

  signature-block(meta)
  certificate-block(meta)
}
