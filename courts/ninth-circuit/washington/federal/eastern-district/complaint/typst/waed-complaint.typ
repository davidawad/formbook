// Complaint for the U.S. District Court for the Eastern District of Washington (waed).
// Rules: LCivR 10(a) (caption, footer, pagination), LCivR 10(d) (8 1/2 x 11, line numbers, serif type of 14 points
// or more, double spacing); Fed. R. Civ. P. 10(a) and (b) (caption, numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // LCivR 10(d): serif, traditional Roman; vendored (docs/FONTS.md)
#let type-size = 14pt                   // LCivR 10(d): proportionately spaced typeface of 14 points or more
#let lines-per-page = 20                // the exemplar has 21; 20 keeps every line inside the 1 in bottom margin (the rule fixes no count)
#let page-w = 8.5in                     // LCivR 10(d): 8 1/2 x 11 inch
#let page-h = 11in
#let left-margin = 1.1in                // room for the line numbers and the pleading rules
#let right-margin = 1in
#let text-width = page-w - left-margin - right-margin   // 460.8 pt
#let para-indent = 0.5in                // first-line indent of a numbered paragraph ...
#let number-box = 0.5in                 // ... then the number in a box: the text starts 1 in from the margin (docx: a tab)
#let list-indent = 0.5in                // a relief item's letter starts half an inch in ...
#let letter-box = 0.4in                 // ... in a box of its own; the text hangs 0.9 in from the margin
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column and the right column
#let caption-rule-pad = 10pt            // the party column's text stands this far off its right rule ...
#let caption-rule-below = 8pt           // ... and its last line this far above its bottom rule
#let caption-right-pad = 0.15in         // the right column's text stands off the gutter by this much
#let sig-left = 2.6in                   // the date column of the signature block
#let sig-gutter = 0.2in
#let counsel-lines = 4                  // LCivR 10(a)(1)(A): counsel above line five; the court title starts on line five

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is explicit (Word's exact
// line spacing; docx/waed-complaint.lua and docx/reference.xml set the same twips).
#let pitch = 32pt                       // LCivR 10(d): double spaced; one numbered line (2 x 16 pt)
#let pitch-single = 16pt                // single spacing (LCivR 10(d) allows it for counsel, caption, signature): half a numbered line
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 80 pt: holds the footer
#let footer-gap = 12pt                  // the footer line's box starts this far below the last numbered line

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("waed-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown (case names in italics, quotations, and so on).
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// Single-spaced lines, one paragraph each, at the single pitch; an item is a string (markdown) or content.
/// `gaps`: the indices of items that a blank single line precedes.
#let line-stack(items, gaps: ()) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  for (k, i) in items.enumerate() {
    block(width: 100%, above: if k in gaps { pitch-single } else { 0pt }, below: 0pt,
      par(if type(i) == str { inl(i) } else { i }))
  }
}

/// Whole numbered lines for a height: at least `min`.
#let grid-lines(h, min: 1) = calc.max(min, calc.ceil(h / pitch - 0.001))

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 20 down the left margin, each in a numbered line's box, ending 0.65 in from the page edge.
#let line-numbers() = {
  set text(..edges(pitch))
  for i in range(1, lines-per-page + 1) {
    place(top + left, dy: top-margin + (i - 1) * pitch,
      block(width: left-margin - 0.45in, height: pitch, align(right, str(i))))
  }
}

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = {
  place(top + left, dx: left-margin - 0.2in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: left-margin - 0.16in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
  place(top + left, dx: page-w - right-margin + 0.1in, line(start: (0pt, 0pt), end: (0pt, page-h), stroke: 0.75pt))
}

/// LCivR 10(a)(1)(E): in the footer of every page, the title (or an abbreviated title) followed by the page number;
/// one single-spaced line 12 pt below the last numbered line (docx: the footer, docx/waed-complaint.lua).
#let footer-block(title) = place(top + left, dx: left-margin, dy: top-margin + lines-per-page * pitch + footer-gap,
  block(width: text-width, {
    set text(..edges(pitch-single))
    par(first-line-indent: 0pt, upper(title) + " - " + context counter(page).display("1"))
  }))

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-4), court title (line 5 on), caption, title of the paper
// ---------------------------------------------------------------------------

/// Counsel, single spaced from line 1, in whole numbered lines, at least four (LCivR 10(a)(1)(A)).
#let counsel-block(meta) = context {
  let body = line-stack(meta.counsel)
  let h = measure(width: text-width, body).height
  block(width: 100%, height: grid-lines(h, min: counsel-lines) * pitch, above: 0pt, below: 0pt, body)
}

/// The court's name, one numbered line each, centred (LCivR 10(a)(1)(B)), then a blank numbered line.
#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF WASHINGTON")
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  for l in lines { block(width: 100%, above: 0pt, below: 0pt, align(center, par(first-line-indent: 0pt, l))) }
  block(width: 100%, height: pitch, above: 0pt, below: 0pt)
}

/// The parties at left (each party's names, then its designation; "v." between them) in a box ruled at its right
/// and foot; the case number, the title of the paper (bold) and the jury demand at right (LCivR 10(a)(1)(C), (D)).
/// The row is whole numbered lines tall, so the text after it is on the numbered lines.
#let caption(meta) = context {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  let items = ("Case No. " + meta.case_number, text(weight: "bold", inl(meta.brief_title)))
  let gaps = (1,)
  if "jury_demand" in meta and meta.jury_demand {
    items.push(text(weight: "bold", "DEMAND FOR JURY TRIAL"))
    gaps.push(2)
  }
  let left = line-stack(rows)
  let right = line-stack(items, gaps: gaps)
  let right-w = text-width - caption-left - caption-gutter
  let hl = measure(width: caption-left - caption-rule-pad, left).height + caption-rule-below
  let hr = measure(width: right-w - caption-right-pad, right).height
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, grid(
    columns: (caption-left, caption-gutter, right-w),
    rows: (grid-lines(calc.max(hl, hr)) * pitch,),
    grid.cell(stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-rule-pad), left),
    [],
    grid.cell(inset: (left: caption-right-pad), right),
  ))
}

#let cover(meta) = {
  counsel-block(meta)
  court-title(meta)
  caption(meta)
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Headings: one numbered line each, kept with the block after them; level 1 a centred bold section in capitals,
/// level 2 a centred bold heading, level 3 bold italic at the margin.
#let heading-block(level, s) = {
  let body = if level == 1 { upper(inl(s)) } else { inl(s) }
  let body = if level >= 3 { text(weight: "bold", style: "italic", body) } else { text(weight: "bold", body) }
  block(width: 100%, sticky: true, above: 0pt, below: 0pt,
    align(if level >= 3 { left } else { center }, par(first-line-indent: 0pt, body)))
}

/// A numbered paragraph (Fed. R. Civ. P. 10(b)): the first-line indent, the number in its box, then the text.
#let numbered(n, s) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: number-box)[#n.]#inl(s)]))

/// A relief item: the letter in its box half an inch in, the text hanging after it.
#let lettered(k, s) = block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent,
  par(first-line-indent: 0pt, hanging-indent: letter-box, [#box(width: letter-box)[#numbering("A.", k)]#inl(s)])))

/// The date at the margin and the signature column (Fed. R. Civ. P. 11(a)), single spaced, on one page, a blank
/// single line below the text.
#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-single, below: 0pt, grid(
  columns: (sig-left, sig-gutter, text-width - sig-left - sig-gutter),
  line-stack(("DATED " + meta.date,)),
  [],
  {
    let firm = meta.signature.firm
    line-stack(("Respectfully submitted,",) + firm
      + ("/s/ " + meta.signature.signer, meta.signature.signer) + meta.signature.lines,
      gaps: (1, 1 + firm.len()))
  },
))

/// The body. Each blank-line-separated chunk of markdown is one of: a `#` heading (levels 1 to 3), a `1.` or `-`
/// list (lettered A., B., ... afresh in each list), or a paragraph, numbered (Fed. R. Civ. P. 10(b)).
#let item-re = regex("^(\\d+\\.|[-*+])[ \\t]+")
#let allegations(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let n = 0
  for t in chunks {
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      heading-block(calc.min(level, 3), t.slice(level).trim())
    } else if t.starts-with(item-re) {
      // One item per line that starts with a label; a line without one continues the item before it.
      let items = ()
      for l in t.split("\n").map(l => l.trim()).filter(l => l != "") {
        if l.starts-with(item-re) or items.len() == 0 { items.push(l.replace(item-re, "")) } else { items.last() += " " + l }
      }
      for (k, item) in items.enumerate() { lettered(k + 1, item) }
    } else {
      n += 1
      numbered(n, t)
    }
  }
}

#let waed-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch. Lists are written by allegations() (list-indent: none).
  show: xengine.with(pitch: pitch, list-indent: none)
  // A doubled sign stays whole and with its number ("¶¶ 8–9", "§§ 206(a)"): typst would break between the signs.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  cover(meta)
  allegations(body)
  signature-block(meta)
}
