// Complaint for the U.S. District Court for the Eastern District of California (caed).
// Rules: E.D. Cal. L.R. 130 (numbered lines in the left margin, double spacing, page number and a
// description of the document on the same line at the bottom), 131(a) (counsel in the upper left of
// the first page, with the party each attorney represents); Fed. R. Civ. P. 8, 10(a), 10(b) (numbered
// paragraphs), 38 (jury demand). See ../README.md for each choice and what the exemplar shows instead.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no E.D. Cal. font rule; the exemplar's face (vendored)
#let type-size = 12pt                   // no E.D. Cal. type-size rule; the exemplar is 12 pt
#let pitch = 24pt                       // L.R. 130(c): double-spaced; the numbered lines are this pitch
#let pitch-single = 12pt                // L.R. 130(c): counsel, caption and signature single-spaced: half a numbered line, as filed
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
#let para-indent = 0.5in                // first-line indent; the paragraph number in a box of the same width after it
#let list-indent = 0.5in                // prayer items: the number half an inch in, in a box of list-label
#let list-label = 0.5in
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-inset = 10pt               // the party column's text stands off its rule
#let caption-gutter = 0.2in
#let caption-right-inset = 0.1in
#let signature-left = 2.6in             // the date column of the signature block
#let counsel-lines = 7                  // L.R. 131(a): counsel in the upper left; the court title starts on line 8

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("caed-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own) with explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, {
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
      context counter(page).display("1"),
    )
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-7), court title (line 8), caption, title of the paper
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

/// The caption: the parties (names, designation, "v." between them) in a column closed by a rule at its right and
/// foot; the case number, the title and the jury demand at the right, 12 pt apart.
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
    line-block(above: 12pt, text(weight: "bold", inl(meta.brief_title)))
    if "jury_demand" in meta and meta.jury_demand {
      line-block(above: 12pt, text(weight: "bold", "DEMAND FOR JURY TRIAL"))
    }
  }),
))

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  caption(meta)
  pagebreak()
}

// ---------------------------------------------------------------------------
// Body and signature
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
    for l in meta.signature.firm { line-block(l) }
    line-block(above: 12pt, "By: /s/ " + meta.signature.signer)
    line-block(meta.signature.signer)
    for l in meta.signature.lines { line-block(l) }
  }),
))
}

/// A body paragraph at the double pitch: the first-line indent, then (when numbered, Fed. R. Civ. P. 10(b)) the
/// number in a box of the paragraph indent and the text after it. `keep`: kept whole on the page of the block after
/// it (the last paragraph stays with the signature block).
#let body-par(num, content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: para-indent, [#num.])#content] }))

/// A heading at the body pitch, bold, sticky (it never ends a page): level 1 centered capitals, level 2 centered,
/// level 3 at the margin.
#let heading-block(level, c) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  let t = inl(c)
  align(if level < 3 { center } else { left }, text(weight: "bold", if level == 1 { upper(t) } else { t }))
})

/// A list chunk (the prayer): an item per line that starts with "1." (a continuation line joins the item before it),
/// numbers as written, the number half an inch in, in a box of list-label, the text hanging after it.
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

/// Numbered allegations. Each blank-line-separated chunk of markdown is one of:
///   `#` heading (level 1 centered caps; level 2 centered bold; level 3 bold, left);
///   `---` the signature block goes here;
///   a list (`1.` items: the prayer, numbered as written, as in the exemplar);
///   a paragraph: numbered (Fed. R. Civ. P. 10(b)), unless it starts with `[unnumbered]`.
/// The block before a signature block is kept whole with it.
#let allegations(meta, body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let n = 0
  for (i, t) in chunks.enumerate() {
    let keep = i + 1 < chunks.len() and chunks.at(i + 1) == "---"
    if t == "---" {
      signature-block(meta)
    } else if t.starts-with("#") {
      let m = t.match(regex("^(#+)\\s+(.*)$"))
      heading-block(m.captures.at(0).len(), m.captures.at(1))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      list-chunk(t, keep-last: keep)
    } else if t.starts-with("[unnumbered]") {
      // An unnumbered paragraph (the WHEREFORE clause, the jury demand): a text that is not an allegation.
      body-par(none, inl(t.slice("[unnumbered]".len()).trim()), keep: keep)
    } else {
      n += 1
      body-par(n, inl(t), keep: keep)
    }
  }
}

#let caed-complaint(meta, body) = {
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
  // A doubled section sign stays with its number ("§§ 1114"; xengine binds a single sign), as the docx filter binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  cover(meta)
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
  allegations(meta, body)
}
