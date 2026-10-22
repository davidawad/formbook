// Complaint for the U.S. District Court for the Western District of Michigan (miwd).
// Rules: LCivR 10.1 (double spaced, 8 1/2 x 11, one side, type 12 point or larger, margins at least 1 inch);
// LCivR 10.3 (date, address and telephone of the signing attorney); Fed. R. Civ. P. 10(a) (caption),
// 10(b) (numbered paragraphs), 11(a) (signature with address, e-mail and telephone). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LCivR 10.1 names no face; Times New Roman (vendored, docs/FONTS.md), as the primary exemplar
#let type-size = 12pt                   // LCivR 10.1: type no smaller than 12 point
#let page-w = 8.5in                     // LCivR 10.1: 8 1/2 x 11 inch paper
#let margin = 1in                       // LCivR 10.1: all margins at least one inch
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                // first-line indent of every body paragraph
#let number-box = 0.5in                 // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let list-indent = 0.5in                // a request-for-relief letter starts half an inch in ...
#let letter-box = 0.4in                 // ... in a box of its own; the text hangs 0.9 in from the margin
#let caption-left = 3.25in              // the party column of the caption
#let caption-gutter = 0.25in            // between the party column's rule and the right column ...
#let caption-right-inset = 0.1in        // ... whose text starts this far further in
#let caption-pad-right = 10pt           // the party column's text to its right rule
#let caption-pad-bottom = 8pt           // the last party line to the rule under the party column
#let sig-col = 2.8in                    // the signature's right column starts here; "Dated:" sits left of it

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/miwd-complaint.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-body = 24pt                  // LCivR 10.1: double spaced
#let pitch-single = 13.8pt              // single spacing: court title, caption, counsel, signature, footer
#let caption-above = 24pt               // the court title to the caption
#let title-above = 24pt                 // the judge's line to the title in the caption's right column
#let counsel-above = 48pt               // the caption to the counsel block
#let group-gap = 13.8pt                 // between two counsel groups: one blank single line
#let lead-above = 24pt                  // page 2: the title to the lead-in
#let sig-above = 24pt                   // the last paragraph to the signature block
#let sig-gap = 12pt                     // "Respectfully submitted," to the firm, the firm to "By: /s/"
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("miwd-complaint: the sample must start with a YAML frontmatter block") }
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

/// Inline markdown (for names with *et al.*, section signs, etc.).
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// Single-spaced lines, one paragraph each. `above`: the space before the first line. An item is a string
/// (markdown) or content; `alignment`: of every line.
#let line-stack(items, above: 0pt, alignment: left) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let g = above
  for i in items {
    block(width: 100%, above: g, below: 0pt, align(alignment, par(if type(i) == str { inl(i) } else { i })))
    g = 0pt
  }
}

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content, above: 0pt) = block(width: 100%, above: above, below: 0pt, par(content))

// ---------------------------------------------------------------------------
// Cover: court title, caption, counsel block (LCivR 10.1; Fed. R. Civ. P. 10(a), 11(a))
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "WESTERN DISTRICT OF MICHIGAN")
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  line-stack(lines.map(l => text(weight: "bold", l)), alignment: center)
}

/// The caption (Fed. R. Civ. P. 10(a)): the parties single-spaced in a column closed by a rule on its right and under
/// it ("v." between the parties); at the right the case number and the judge (blanks for the clerk when the sample
/// has none) and the title in bold.
#let caption(meta) = {
  let blank = "__________________"
  let cn = if meta.case_number == "" { blank } else { meta.case_number }
  let hon = if meta.judge == "" { blank } else { meta.judge }
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  block(width: 100%, above: caption-above, below: 0pt, breakable: false, grid(
    columns: (caption-left, caption-gutter, 1fr),
    block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt),
      inset: (right: caption-pad-right, bottom: caption-pad-bottom), line-stack(rows)),
    [],
    pad(left: caption-right-inset, {
      line-stack(("Case No. " + cn, "Hon. " + hon))
      line-stack(above: title-above, (text(weight: "bold", inl(meta.title)),))
    }),
  ))
}

#let counsel-block(meta) = block(width: 100%, above: counsel-above, below: 0pt, breakable: false, {
  for (k, g) in meta.counsel.enumerate() {
    line-stack(above: if k > 0 { group-gap } else { 0pt }, g.names + g.lines)
  }
})

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Headings at the type size on the body pitch, with no space of their own, centered and bold, kept with the block
/// after them; level 1 in capitals.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true,
  align(center, par(first-line-indent: 0pt, text(weight: "bold", if level == 1 { upper(inl(s)) } else { inl(s) }))))

/// A request-for-relief item (A., B., ...): the letter half an inch in, the text hanging after its box (docx: List
/// Letter).
#let lettered(i, s) = block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent,
  par(first-line-indent: 0pt, hanging-indent: letter-box,
    [#box(width: letter-box, str.from-unicode(64 + i) + ".")#inl(s)])))

/// The signature block (Fed. R. Civ. P. 11(a); LCivR 10.3), single-spaced: "Dated:" and the date at the left of the
/// first line; "Respectfully submitted,", the firm, "By: /s/" with the signer and the signer's lines in a column from
/// `sig-col` (docx: a tab and a hanging indent there).
#let signature-block(meta) = {
  let sig = meta.signature
  let lines = (("Respectfully submitted,", 0pt),)
  lines += sig.firm.enumerate().map(((i, l)) => (l, if i == 0 { sig-gap } else { 0pt }))
  lines.push(("By: /s/ " + sig.signer, sig-gap))
  lines += sig.lines.map(l => (l, 0pt))
  block(width: 100%, above: sig-above, below: 0pt, {
    set text(..edges(pitch-single))
    for (i, (l, gap)) in lines.enumerate() {
      block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
        [#box(width: sig-col, if i == 0 [Dated: #meta.date])#inl(l)]))
    }
  })
}

/// The body. Each blank-line-separated chunk of markdown is a `#` heading (levels 1 to 3), a list (each item lettered
/// A., B., ...), or a paragraph, numbered 1, 2, ... (Fed. R. Civ. P. 10(b)) until the heading named by
/// `numbering_stops_at` (the request for relief and the jury demand are not numbered). `st`: (paragraphs numbered,
/// numbering on, items lettered): a list goes on across blank lines until another block.
#let item-re = regex("^(\\d+\\.|[-*+])[ \\t]+")
#let allegations(chunks, stop-at, st) = {
  let (n, on, li) = st
  let out = []
  for t in chunks {
    if t.starts-with("#") {
      li = 0
      let level = t.match(regex("^#+")).end
      let title = t.slice(level).trim()
      if stop-at != none and title == stop-at { on = false }
      out += heading-block(calc.min(level, 3), title)
    } else if t.starts-with(item-re) {
      // One item per line that starts with a label; a line without one continues the item before it.
      let items = ()
      for l in t.split("\n").map(l => l.trim()).filter(l => l != "") {
        if l.starts-with(item-re) or items.len() == 0 { items.push(l.replace(item-re, "")) } else { items.last() += " " + l }
      }
      for item in items {
        li += 1
        out += lettered(li, item)
      }
    } else {
      li = 0
      if on {
        n += 1
        out += body-par[#box(width: number-box)[#n.]#inl(t)]
      } else {
        out += body-par(inl(t))
      }
    }
  }
  (out, (n, on, li))
}

#let miwd-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    // Page numbers centered at the foot of every page after the cover (LCivR 10.1 sets no footer; convention).
    footer-descent: footer-descent,
    footer: context if counter(page).get().first() > 1 {
      align(center, par(first-line-indent: 0pt, text(..edges(pitch-single), counter(page).display())))
    },
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  court-title(meta)
  caption(meta)
  counsel-block(meta)
  pagebreak()

  // Page 2 opens with the title of the pleading, centered, then the lead-in paragraph.
  block(width: 100%, above: 0pt, below: 0pt,
    align(center, par(first-line-indent: 0pt, text(weight: "bold", inl(meta.title)))))
  if "lead_in" in meta { body-par(above: lead-above, inl(meta.lead_in)) }

  // The last paragraph (or, when the body ends in a list, its last item) stays on the page with the signature block:
  // a signature never starts a page alone.
  let stop-at = meta.at("numbering_stops_at", default: none)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let tail = chunks.last()
  if tail.starts-with(item-re) {
    let starts = tail.matches(regex("(?m)^(\\d+\\.|[-*+])[ \\t]+"))
    if starts.len() > 1 {
      chunks = chunks.slice(0, -1) + (tail.slice(0, starts.last().start).trim(), tail.slice(starts.last().start))
    }
  }
  let (main, st) = allegations(chunks.slice(0, -1), stop-at, (0, true, 0))
  main
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    allegations(chunks.slice(-1), stop-at, st).at(0)
    signature-block(meta)
  })
}
