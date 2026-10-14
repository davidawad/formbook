// Motion with memorandum of points and authorities, United States Bankruptcy Court, District of Arizona (arb).
// Rules: FRBP 9013(a), (b) (a request for an order is made by written motion, which states its grounds
// with particularity and the relief requested); LRBP 9013-1(a) (a motion includes a memorandum setting out
// the supporting authorities), (b) (15 pages, exclusive of attachments, unless the court orders otherwise);
// LRBP 1005-1(a) (court title); LRBP 9004-1 (a) first-page filer block, (c) dual caption where there is an
// adversary proceeding, (e) hearing if known, (g) form of papers, (h) length. See ../README.md.
// Content-agnostic: every case word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let court-title = ("UNITED STATES BANKRUPTCY COURT", "DISTRICT OF ARIZONA")  // LRBP 1005-1(a)
#let font-family = "EB Garamond"        // proportional, standard; vendored in fonts/ (LRBP 9004-1(g))
#let type-size = 13pt                   // LRBP 9004-1(g): "a proportional font size no smaller than 13 point"
#let footnote-size = 12pt               // LRBP 9004-1(g): footnotes may be 12 point
#let pitch = 24pt                       // LRBP 9004-1(g): double spacing; the numbered lines are this pitch
#let lines-per-page = 28                // LRBP 9004-1(g): no more than 28 lines per page
#let page-limit = 15                    // LRBP 9013-1(b): 15 pages, exclusive of attachments (see README.md)
#let page-w = 8.5in                     // LRBP 9004-1(g): paper 8 1/2 by 11 inches
#let page-h = 11in
#let top-margin = 72pt                  // numbered line 1 sits on the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 48 pt: holds the footer
#let left-margin = 1.5in                // LRBP 9004-1(g): left margin at least 1 1/2 inches
#let right-margin = 0.75in              // LRBP 9004-1(g): right margin at least 1/2 inch
#let text-width = page-w - left-margin - right-margin
// 8.45 pt is EB Garamond's natural line pitch at 13 pt (0.65 em, measured); 15.55 pt of leading makes
// the baseline pitch exactly 24 pt. Measured with pdftotext -bbox on the render (README.md).
#let body-leading = 15.55pt
#let single-leading = 0.5em             // counsel, caption, signature, footnotes: single-spaced
#let para-indent = 0.5in
#let heading-tab = 0.5in
#let caption-left = 3.1in               // width of the party column of the caption
#let filer-lines = 7                    // the court title starts on line 8 (convention; LRBP 9004-1(a) only fixes line 1)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("arb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics for case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("arb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Fill whole numbered lines: the block is rounded up to a multiple of `pitch`, so whatever follows
/// it stays on the grid of numbered lines.
#let on-grid(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, c)
}

/// A heading: whole numbered lines (one line unless the title wraps), kept with the paragraph after it
/// (a heading never ends a page).
#let heading-line(c) = context {
  let h = measure(width: text-width, c).height
  block(width: text-width, height: calc.ceil(h / pitch) * pitch, above: 0pt, below: 0pt, sticky: true, c)
}

// ---------------------------------------------------------------------------
// Page furniture: pleading paper (LRBP 9004-1(g))
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

/// Footer in the bottom margin: page number, the paper's title, and the case number (and the adversary
/// number, when there is one).
#let footer-block(meta) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 6pt,
  block(width: text-width, {
    set text(size: 11pt)
    align(center, context counter(page).display("1"))
    v(4pt)
    grid(
      columns: (1fr, auto),
      upper(need(meta, "footer_title")),
      if "adversary_number" in meta [ADV. NO. #meta.adversary_number] else [CASE NO. #need(meta, "debtor").case_number],
    )
  }),
)

// ---------------------------------------------------------------------------
// First page: filer block (line 1), court title, caption (LRBP 9004-1(a), (c), (e))
// ---------------------------------------------------------------------------

/// One single-spaced line per item, kept on the single-spacing grid. Items are strings (cmarker) or content.
#let line-stack(items) = {
  set par(leading: single-leading, spacing: 0pt, justify: false)
  stack(dir: ttb, spacing: single-leading, ..items.map(i => if type(i) == str { inl(i) } else { i }))
}

/// Filer block from line 1: counsel, firm, address, email, State Bar number, telephone and the party
/// represented (LRBP 9004-1(a)). Occupies at least `filer-lines` numbered lines.
#let filer-block(meta) = context {
  let items = need(meta, "filer")
  let h = measure(width: text-width, line-stack(items)).height
  block(width: text-width, height: calc.max(filer-lines, calc.ceil(h / pitch)) * pitch, line-stack(items))
}

#let court-title-block() = {
  for l in court-title {
    on-grid(align(center, text(weight: "bold", l)))
  }
}

/// Caption (LRBP 9004-1(a), (b), (e)). The debtor's caption is always given. When the motion is filed in an
/// adversary proceeding, the second caption names the adversary parties and the adversary number (9004-1(c)).
/// The right column carries the chapter and case number, the title, the relief sought and the hearing.
#let caption(meta) = {
  let debtor = need(meta, "debtor")
  let has-adv = "adversary_number" in meta
  let left-cell(rows, top: 0pt) = block(
    width: caption-left,
    stroke: (right: 0.75pt, bottom: 0.75pt),
    inset: (right: 10pt, bottom: 8pt, top: top),
    line-stack(rows),
  )
  let right-cell(rows, top: 0pt) = block(inset: (left: 0.1in, bottom: 8pt, top: top), line-stack(rows))

  let debtor-rows = ("In re:", "") + debtor.names + ("", "*Debtor.*")
  let case-rows = ("Chapter " + str(debtor.chapter), "", "Case No. " + debtor.case_number)
  if has-adv {
    // Row 1 holds the debtor; row 2 holds the adversary parties and the title.
    let party-rows = ()
    for (k, p) in need(meta, "parties").enumerate() {
      if k > 0 { party-rows += ("", "v.", "") }
      party-rows += p.names
      party-rows += ("", "*" + p.designation + "*")
    }
    let adv-rows = ("Adv. No. " + meta.adversary_number, "")
    adv-rows += (text(weight: "bold", upper(inl(need(meta, "title")))),)
    adv-rows += ("", inl(need(meta, "relief")))
    if "hearing" in meta and meta.hearing != none {
      let hr = meta.hearing
      adv-rows += ("", "Hearing date: " + hr.at("date", default: ""), "Time: " + hr.at("time", default: ""), "Place: " + hr.at("place", default: ""))
    }
    on-grid(grid(
      columns: (caption-left, 1fr),
      column-gutter: 0.2in,
      left-cell(debtor-rows),
      right-cell(case-rows),
      left-cell(party-rows, top: 8pt),
      right-cell(adv-rows, top: 8pt),
    ))
  } else {
    // A contested matter in the main case: one caption, the title on the right.
    let rows = (text(weight: "bold", upper(inl(need(meta, "title")))),)
    rows += ("", inl(need(meta, "relief")))
    if "hearing" in meta and meta.hearing != none {
      let hr = meta.hearing
      rows += ("", "Hearing date: " + hr.at("date", default: ""), "Time: " + hr.at("time", default: ""), "Place: " + hr.at("place", default: ""))
    }
    on-grid(grid(
      columns: (caption-left, 1fr),
      column-gutter: 0.2in,
      left-cell(debtor-rows),
      right-cell(case-rows + ("",) + rows),
    ))
  }
}

#let cover(meta) = {
  filer-block(meta)
  court-title-block()
  v(pitch)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Signature block
// ---------------------------------------------------------------------------

#let signature-block(meta) = on-grid(grid(
  columns: (2.6in, 1fr),
  column-gutter: 0.2in,
  [Dated: #need(meta, "date")],
  {
    set par(leading: single-leading, spacing: 0pt, justify: false)
    [Respectfully submitted,]
    v(pitch * 0.5)
    let sig = need(meta, "signature")
    line-stack(("/s/ " + sig.signer,) + sig.lines)
  },
))

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, lists. Unlike the complaint, paragraphs are not numbered.
// ---------------------------------------------------------------------------

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

/// Left edge of a heading's label: level 2 at the margin, each deeper level half an inch in.
#let label-indent(level) = (level - 2) * heading-tab

/// A heading label hung in the left margin of its own line: `ind` in, the label in a `heading-tab` box.
#let hang-label(ind, lab, c) = {
  h(ind)
  if lab != "" { box(width: heading-tab, lab) }
  c
}

/// Body chunks as set text. A heading is kept in one unbreakable block with the chunk after it. The last
/// chunk is set together with `tail` (the signature block, and the certificate if any), so a signature never
/// stands alone on a page.
#let body-chunks(body, tail) = {
  let all = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // cmarker resolves a footnote reference only against definitions in the same string, and each chunk is
  // rendered on its own, so each chunk carries the definitions of the footnotes it refers to.
  let defs = all.filter(c => c.trim().starts-with("[^"))
  let chunks = all.filter(c => not c.trim().starts-with("[^"))
  let with-notes(t) = {
    let s = t
    for d in defs {
      let key = d.trim().slice(2, d.trim().position("]"))
      if t.contains("[^" + key + "]") { s += "\n\n" + d.trim() }
    }
    s
  }
  let pending = []
  let has-pending = false
  for (idx, c) in chunks.enumerate() {
    let t = c.trim()
    let last = idx == chunks.len() - 1
    if t.starts-with("#") {
      pending += cmarker.render(with-notes(t), raw-typst: false, smart-punctuation: true, h1-level: 1)
      has-pending = true
    } else {
      let piece = if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
        // A list may break across pages; each item fills whole lines.
        {
          set par(leading: body-leading)
          cmarker.render(with-notes(t), raw-typst: false, smart-punctuation: true, h1-level: 1)
          v(body-leading)
        }
      } else {
        on-grid({
          set par(leading: body-leading)
          h(para-indent)
          cmarker.render(with-notes(t), raw-typst: false, smart-punctuation: true, h1-level: 1)
        })
      }
      if last {
        block(breakable: false, width: text-width, { pending; piece; tail })
      } else if has-pending {
        block(breakable: false, width: text-width, { pending; piece })
      } else {
        piece
      }
      pending = []
      has-pending = false
    }
  }
  if chunks.len() == 0 or has-pending {
    block(breakable: false, width: text-width, { pending; tail })
  }
}

#let arb-motion-brief(meta, body) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("filer", "debtor", "title", "relief", "footer_title", "date", "signature") {
    let _ = need(meta, k)
  }
  if "adversary_number" in meta {
    let _ = need(meta, "parties")
  }

  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta),
  )
  set document(title: upper(need(meta, "title")) + ", Case No. " + need(meta, "debtor").case_number, author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", hyphenate: false, fallback: false)
  set par(leading: body-leading, spacing: 0pt, first-line-indent: 0pt, justify: false)

  // Heading numbers come from the level (I., A., 1., a.) under level 2; level 1 is a centred section.
  set heading(numbering: heading-num)
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    if it.level == 1 {
      heading-line(align(center, text(weight: "bold", upper(it.body))))
    } else {
      let ind = label-indent(it.level)
      heading-line(hang-label(ind, lab, text(weight: "bold", it.body)))
    }
  }

  // Footnotes: 12 point, single-spaced (LRBP 9004-1(g)).
  set footnote.entry(gap: 0.5em, clearance: 0.9em, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: set text(size: footnote-size)
  show footnote.entry: set par(first-line-indent: 0pt, leading: single-leading, spacing: 0.4em)

  cover(meta)

  // Lists are lettered or numbered by the template when the markdown uses them.
  set enum(numbering: "1.", indent: 0.5in, body-indent: 0.4in, spacing: body-leading)
  set list(indent: 0.5in, body-indent: 0.4in, spacing: body-leading)

  body-chunks(body, {
    signature-block(meta)
  })

  // LRBP 9013-1(b) and 9004-1(h): 15 pages, exclusive of attachments, unless the court orders otherwise.
  context {
    let n = counter(page).final().first()
    assert(n <= page-limit, message: "arb-motion-brief: " + str(n) + " pages; LRBP 9013-1(b) allows " + str(page-limit) + " (exclusive of attachments) unless the court orders otherwise")
  }
}
