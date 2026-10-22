// Motion with notice and memorandum for the U.S. District Court for the Eastern District of California (caed).
// Rules: E.D. Cal. L.R. 130 (numbered lines in the left margin, double spacing, page number and a
// description of the document on the same line at the bottom), 131(a) (counsel in the upper left of the
// first page, with the party each attorney represents), 133(k) (a table of contents and a table of
// authorities for a brief over 15 pages), 230(b) (the hearing is set at least 35 days after filing).
// Fed. R. Civ. P. 7(b), 12(b)(6), 12(e). See ../README.md for each choice and what the exemplar shows instead.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no E.D. Cal. font rule; the exemplar's face (vendored)
#let type-size = 12pt                   // no E.D. Cal. type-size rule; the exemplar is 12 pt
#let pitch = 24pt                       // L.R. 130(c): double-spaced; the numbered lines are this pitch
#let pitch-single = 12pt                // L.R. 130(c): counsel, caption, signature and the authorities single-spaced: half a numbered line
#let single-drop = 0.8 * pitch-single  // a single-spaced group starts this far down, so its baselines fall on the numbered
                                        // lines' baselines and halfway between them
#let footer-size = 10pt                 // the footer line (L.R. 130(d)), in a box of 12 pt
#let lines-per-page = 27                // L.R. 130(b) asks for numbered lines; 27 of 24 pt fill the text area
#let page-w = 8.5in                     // L.R. 130(b): 8 1/2 by 11 inch paper
#let page-h = 11in
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the footer
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let list-indent = 0.5in                // list items: the number half an inch in, in a box of list-label
#let list-label = 0.5in
#let heading-step = 0.5in               // a level-3 heading, and each contents level, steps in this much
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-inset = 10pt               // the party column's text stands off its rule
#let caption-gutter = 0.2in
#let caption-right-inset = 0.1in
#let caption-gap = 12pt                 // between the groups of the caption's right column
#let signature-left = 2.6in             // the date column of the signature block
#let toc-page-col = 36pt                // contents: the page numbers keep the last 36 pt of the line to themselves
#let toa-page-col = 1in                 // authorities: the page references ("1, 5, 17, 18", "passim") the last inch
#let toa-hang = 0.4in                   // authorities: an entry's later lines hang this far in
#let toa-gap = 12pt                     // authorities: between entries
#let counsel-lines = 7                  // L.R. 131(a): counsel in the upper left; the court title starts on line 8 unless counsel needs more lines

// Page-number style: arabic for the notice and the memorandum, roman for the tables (L.R. 133(k) does not
// fix one; this follows the exemplar). Set by the markers [[TOC]], [[TOA]] and [[MEMO]] in the body.
#let pn-style = state("pn-style", "arabic")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("caed-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own) with explicit space above and below it; an empty line keeps
/// its height.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below,
  height: if body == "" { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  if type(body) == str { inl(body) } else { body }
})

/// One line block at the body pitch.
#let row-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt,
  if type(body) == str { inl(body) } else { body })

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, one per numbered line, each in a line box of the body pitch (Word: a frame
/// of 27 exact 24 pt lines anchored to the page at the top margin), ending an inch from the page edge.
#let line-numbers() = place(top + left, dx: 0pt, dy: top-margin, block(width: left-margin - 0.5in, {
  set text(size: type-size, ..edges(pitch))
  set par(leading: 0pt, spacing: 0pt)
  for i in range(1, lines-per-page + 1) { block(width: 100%, above: 0pt, below: 0pt, align(right, str(i))) }
}))

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// L.R. 130(d): the page number and a brief description of the document on the same line, 6 pt below the last
/// numbered line.
#let footer-block(title) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 6pt,
  block(width: text-width, {
    set text(size: footer-size, ..edges(12pt))
    grid(
      columns: (1fr, auto),
      column-gutter: 0.2in,
      upper(title),
      context {
        let n = counter(page).get().first()
        if pn-style.at(here()) == "roman" { numbering("i", n) } else { str(n) }
      },
    )
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-7 or more), court title, caption, title of the paper, hearing
// ---------------------------------------------------------------------------

/// Counsel, one single-spaced line each, in a block of at least `counsel-lines` numbered lines (L.R. 131(a): the
/// upper left corner); more counsel lines push the court title down by whole numbered lines.
#let counsel-block(meta) = {
  let n = meta.counsel.len()
  block(width: text-width, above: 0pt, below: 0pt,
    height: calc.max(counsel-lines, calc.ceil((n * pitch-single + single-drop) / pitch)) * pitch, {
      block(width: 100%, height: single-drop, above: 0pt, below: 0pt)
      for l in meta.counsel { line-block(l) }
    })
}

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF CALIFORNIA")
  if "division" in meta { lines.push(upper(meta.division)) }
  for l in lines { row-block(align(center, text(weight: "bold", l))) }
}

/// The caption: the parties in a column closed by a rule at its right and foot; at the right the case number and the
/// judges, the title, the papers filed with it, the hearing and the filing date, 12 pt apart.
#let caption(meta) = block(above: pitch, below: 0pt, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt),
    inset: (top: single-drop, right: caption-inset, bottom: 8pt), {
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { line-block("v.") }
      for n in p.names { line-block(n) }
      line-block(p.designation)
    }
  }),
  pad(left: caption-right-inset, top: single-drop, {
    line-block("Case No.: " + meta.case_number)
    if "judge" in meta { line-block(meta.judge) }
    if "magistrate" in meta { line-block(meta.magistrate) }
    line-block(above: caption-gap, text(weight: "bold", inl(meta.brief_title)))
    if "concurrent" in meta { line-block(above: caption-gap, meta.concurrent) }
    if "hearing" in meta {
      line-block(above: caption-gap, "Date: " + meta.hearing.date)
      line-block("Time: " + meta.hearing.time)
      line-block("Place: " + meta.hearing.place)
    }
    if "action_filed" in meta { line-block(above: caption-gap, "Action Filed: " + meta.action_filed) }
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Signature, tables and the memorandum
// ---------------------------------------------------------------------------

/// The signature block: the date, the firm, "By: /s/" with the signer, and the signer's name and role; one
/// numbered line below the text, never broken across a page. Its height is a whole number of numbered lines (each
/// of its lines is one line of text), so what follows it stays on the numbered lines.
#let signature-block(meta) = {
  let sig = meta.signature
  let h = single-drop + (sig.firm.len() + 2 + sig.lines.len()) * pitch-single + 12pt
  block(width: 100%, height: calc.ceil(h / pitch) * pitch, breakable: false, above: pitch, below: 0pt, grid(
    columns: (signature-left, 1fr),
    column-gutter: 0.2in,
    pad(top: single-drop, line-block("Dated: " + meta.date)),
    pad(top: single-drop, {
      for l in sig.firm { line-block(l) }
      line-block(above: 12pt, "By: /s/ " + sig.signer)
      line-block(sig.signer)
      for l in sig.lines { line-block(l) }
    }),
  ))
}

/// A memorandum heading at the body pitch, bold, sticky (it never ends a page): level 1 centered (as written), level 2
/// at the margin, level 3 a step in. Listed in the table of contents.
#let heading-block(level, c) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  let body = if level == 1 { align(center, text(weight: "bold", inl(c))) } else {
    pad(left: if level >= 3 { heading-step } else { 0pt }, text(weight: "bold", inl(c)))
  }
  [#body#metadata((level: level, text: c))<memo-heading>]
})

/// A body paragraph at the double pitch with a first-line indent (a brief is not numbered). `keep`: kept whole on the
/// page of the block after it (the last paragraph stays with the signature block).
#let body-par(content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, par(first-line-indent: (amount: para-indent, all: true), content))

/// A list chunk: an item per line that starts with "1." (a continuation line joins the item before it), numbers as
/// written, the number half an inch in, in a box of list-label, the text hanging after it.
#let list-chunk(c, keep-last: false) = {
  let items = ()
  for l in c.split("\n") {
    let m = l.match(regex("^\\s*(\\d+\\.|[-*+])\\s+(.*)$"))
    if m != none {
      let lab = m.captures.at(0)
      items.push((label: if lab.ends-with(".") { lab } else { "•" }, text: m.captures.at(1)))
    } else if items.len() > 0 {
      items.last().text += " " + l.trim()
    }
  }
  for (i, it) in items.enumerate() {
    let keep = keep-last and i == items.len() - 1
    block(width: 100%, above: 0pt, below: 0pt, sticky: keep, breakable: not keep, pad(left: list-indent,
      par(first-line-indent: 0pt, hanging-indent: list-label, [#box(width: list-label, it.label)#inl(it.text)])))
  }
}

/// Table of contents: the memorandum's headings, a step in per level, each with its page in the memorandum's own
/// numbering in a column of its own and a dot leader before it; on a page of its own, numbered i.
#let toc-page() = {
  pagebreak()
  pn-style.update("roman")
  counter(page).update(1)
  row-block(align(center, text(weight: "bold", "TABLE OF CONTENTS")))
  row-block(align(right, text(weight: "bold", "Page")))
  context for hd in query(<memo-heading>) {
    let ind = (hd.value.level - 1) * heading-step
    let n = counter(page).at(hd.location()).first()
    listing-row(hd.location(), { h(ind); inl(hd.value.text) }, str(n), toc-page-col, ind, 0pt)
  }
}

/// Table of authorities: the groups from the sample's frontmatter, each entry single-spaced with its page references
/// as given, 12 pt apart.
#let toa-page(meta) = {
  pagebreak()
  row-block(align(center, text(weight: "bold", "TABLE OF AUTHORITIES")))
  row-block(align(right, text(weight: "bold", "Page(s)")))
  for group in meta.authorities {
    row-block(text(weight: "bold", group.category))
    for e in group.entries {
      block(width: 100%, above: 0pt, below: toa-gap, {
        set text(..edges(pitch-single))
        listing-row(none, inl(e.cite), e.pages, toa-page-col, toa-hang, 0pt)
      })
    }
  }
}

/// The memorandum starts on a new page with its own page numbering.
#let memo-start(meta) = {
  pagebreak()
  pn-style.update("arabic")
  counter(page).update(1)
  row-block(align(center, text(weight: "bold", upper(meta.memo_title))))
}

/// Body: the chunks of the markdown sample. Each blank-line-separated chunk is one of:
///   `[[TOC]]`, `[[TOA]]`, `[[MEMO]]` the tables and the memorandum markers (see above);
///   `---` the signature block goes here (the block before it is kept whole with it);
///   `#`, `##`, `###` headings (centered; bold, left; bold, a step in);
///   a list (`1.` items, numbered as written, as in the exemplar);
///   a paragraph: unnumbered, with a first-line indent (briefs are not numbered).
#let brief-body(meta, body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  for (i, t) in chunks.enumerate() {
    let keep = i + 1 < chunks.len() and chunks.at(i + 1) == "---"
    if t == "---" {
      signature-block(meta)
    } else if t == "[[TOC]]" {
      toc-page()
    } else if t == "[[TOA]]" {
      toa-page(meta)
    } else if t == "[[MEMO]]" {
      memo-start(meta)
    } else if t.starts-with("#") {
      let m = t.match(regex("^(#+)\\s+(.*)$"))
      heading-block(m.captures.at(0).len(), m.captures.at(1))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      list-chunk(t, keep-last: keep)
    } else {
      body-par(inl(t), keep: keep)
    }
  }
}

#let caed-motion-brief(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): first fit, ragged
  // right, no kerning, ligatures or hyphenation, every line a box of its pitch; the docx engine sets the same twips.
  show: xengine.with(pitch: pitch, list-indent: list-label)
  // A doubled section sign stays with its number ("§§ 1788.301(a)"; xengine binds a single sign), as the docx filter
  // binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  cover(meta)
  // the notice starts on a new page
  pagebreak()
  brief-body(meta, body)
}
