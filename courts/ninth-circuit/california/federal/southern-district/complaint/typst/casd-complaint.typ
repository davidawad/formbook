// Complaint for the U.S. District Court for the Southern District of California (casd).
// Rules: S.D. Cal. Civil L.R. 5.1 (14-point proportional type, 28 numbered lines, double spacing, letter size);
// Fed. R. Civ. P. 10(a) (caption) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/pleading-paper.typ": line-numbers as shared-line-numbers, pleading-rules as shared-pleading-rules
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // CivLR 5.1: proportional font "such as Times New Roman"
#let type-size = 14pt                   // CivLR 5.1: type no smaller than 14-point for proportional text
#let lines-per-page = 27                // CivLR 5.1: not more than 28 lines per page
#let page-w = 8.5in                     // CivLR 5.1: letter size
#let page-h = 11in
#let top-margin = 72pt                  // the numbered lines start at the top margin
#let left-margin = 1.5in                // room for the line numbers and the rules
#let right-margin = 1in
#let para-indent = 0.5in                // first-line indent of numbered allegations; the number in a box of it
#let list-indent = 0.5in                // prayer items: the label half an inch in
#let list-label = 0.4in                 // prayer items: the box of the label, the text hanging after it
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-inset = 10pt               // the party column's text stands off its right rule
#let caption-foot = 8pt                 // and its last line off its bottom rule
#let caption-right = 0.3in              // the case column stands off the party column's rule
#let signature-left = 2.6in             // the date column of the signature block
#let signature-gutter = 0.2in
#let counsel-lines = 7                  // Civil L.R. 3-4(a)(3): the court title starts on line 8
#let footer-size = 10pt

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is set here (Word's exact
// line spacing; docx/casd.lua sets the same twips).
#let pitch = 24pt                       // CivLR 5.1: the numbered lines (double spacing) are this pitch
#let pitch-single = 16pt                // single spacing (counsel, caption, signature): Word's single line at 14 pt
#let gap = pitch-single                  // a single line between the groups of the caption and signature
// A group of single lines starts this far below a numbered line's top, so every third single line stands level
// with a line number and the others 8 pt off it: the PDF text reads the same lines in every engine.
#let single-drop = 0.8 * (pitch - pitch-single)
#let bottom-margin = page-h - top-margin - lines-per-page * pitch   // 72 pt: holds the footer

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("casd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Block markdown (a chunk of the body).
#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Single-spaced lines, one paragraph per item, with `above` before the first.
#let line-stack(items, above: 0pt) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  for i in items { block(inl(i)) }
})

// ---------------------------------------------------------------------------
// Page furniture
// ---------------------------------------------------------------------------

/// Numbers 1 to 27 down the left margin, one per numbered line, on the body's line boxes.
#let line-numbers() = shared-line-numbers(left-margin, top-margin, pitch, lines-per-page, type-size, ..edges(pitch))

/// The pleading rules: a double rule at the text's left edge, a single rule at its right.
#let pleading-rules() = shared-pleading-rules(page-w, page-h, left-margin, right-margin)

#let footer-block(title, case-number) = place(
  top + left,
  dx: left-margin,
  dy: top-margin + lines-per-page * pitch + 6pt,
  block(width: page-w - left-margin - right-margin, {
    set text(size: footer-size, ..edges(12pt))   // 12 pt line boxes (docx: exact 240 twips)
    align(center, context counter(page).display("-1-"))
    v(4pt)
    grid(
      columns: (1fr, auto),
      upper(title),
      [CASE NO. #case-number],
    )
  }),
)

// ---------------------------------------------------------------------------
// Cover: counsel (lines 1-7), court title (line 8), caption, title of the paper
// ---------------------------------------------------------------------------

/// Lines 1-7 at least; more counsel lines push the court title down to the next numbered line (Civil L.R.
/// 3-4(a)(3): "except where additional space is required for counsel identification").
#let counsel-block(meta) = {
  let n = calc.max(counsel-lines, calc.ceil((single-drop + meta.counsel.len() * pitch-single) / pitch))
  block(width: 100%, height: n * pitch, above: 0pt, below: 0pt, inset: (top: single-drop), line-stack(meta.counsel))
}

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "SOUTHERN DISTRICT OF CALIFORNIA")
  if "division" in meta { lines.push(upper(meta.division)) }
  for l in lines { block(align(center, text(weight: "bold", l))) }
}

/// The caption: the party column ruled at its right and foot (the rules run to the foot of the row), the case
/// column beside it; one pitch below the court title.
#let caption(meta) = block(above: pitch, grid(
  columns: (caption-left, 1fr),
  grid.cell(stroke: (right: 0.75pt, bottom: 0.75pt), inset: (top: single-drop, right: caption-inset, bottom: caption-foot), {
    // Each party: its names, then its designation; "v." between the parties.
    let rows = ()
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { rows.push("v.") }
      rows += p.names + (p.designation,)
    }
    line-stack(rows)
  }),
  grid.cell(inset: (top: single-drop, left: caption-right), {
    line-stack(("Case No. " + meta.case_number,))
    block(above: gap, below: 0pt, { set text(..edges(pitch-single), weight: "bold"); inl(meta.brief_title) })
    if "legend" in meta and meta.legend != none {
      block(above: gap, below: 0pt, { set text(..edges(pitch-single), weight: "bold"); upper(meta.legend) })
    }
    if "jury_demand" in meta and meta.jury_demand {
      block(above: gap, below: 0pt, { set text(..edges(pitch-single), weight: "bold"); [DEMAND FOR JURY TRIAL] })
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

/// A numbered line below the text: dated at the left; the firm and signer in the right column, single spaced;
/// never split across pages.
#let signature-block(meta) = block(breakable: false, above: pitch, inset: (top: single-drop), grid(
  columns: (signature-left, 1fr),
  column-gutter: signature-gutter,
  line-stack(("Dated: " + meta.date,)),
  {
    line-stack(("Respectfully submitted,",))
    line-stack(meta.signature.firm, above: gap)
    line-stack(("By: /s/ " + meta.signature.signer, meta.signature.signer) + meta.signature.lines, above: gap)
  },
))

/// A body paragraph: the first line indented half an inch, the paragraph number (if any) in a box of half an inch.
#let body-par(label, content) = block(par(first-line-indent: (amount: para-indent, all: true),
  if label == none { content } else { box(width: para-indent, label) + content }))

/// A list: each item's label half an inch in, in a box of `list-label`, the text hanging after it; prayer items are
/// lettered (a), (b), ...
#let list-items(t, letters) = {
  let m = t.match(regex("^(\\d+)\\."))
  let n = if m == none { 1 } else { int(m.captures.at(0)) }
  let items = t.split(regex("\\r?\\n(?:\\d+\\.|[-*+])[ \\t]+"))
  items.at(0) = items.at(0).replace(regex("^(?:\\d+\\.|[-*+])[ \\t]+"), "")
  let ordered = m != none
  for (k, it) in items.enumerate() {
    let lab = if not ordered { [•] } else if letters { numbering("(a)", n + k) } else { str(n + k) + "." }
    block(pad(left: list-indent, par(hanging-indent: list-label, first-line-indent: 0pt,
      box(width: list-label, lab) + inl(it.replace(regex("\\s*\\r?\\n\\s*"), " ")))))
  }
}

/// Numbered allegations. Each blank-line-separated chunk of markdown that is neither a heading nor a list is one
/// numbered paragraph (Fed. R. Civ. P. 10(b)); headings and lists are not numbered, nor the paragraphs under a
/// PRAYER or DEMAND heading (the filed complaint leaves them unnumbered; CivLR 5.1 is silent). A heading stays with
/// the block after it; the last block stays with the signature.
#let allegations(body, sig) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let unnumbered = false
  let n = 0
  for (i, t) in chunks.enumerate() {
    let last = i == chunks.len() - 1
    let piece = if t.starts-with("#") {
      let htext = upper(t.trim("#", at: start).trim())
      unnumbered = htext.starts-with("PRAYER") or htext.starts-with("DEMAND")
      block(sticky: true, md(t))
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      list-items(t, unnumbered)
    } else if unnumbered {
      body-par(none, md(t))
    } else {
      n += 1
      body-par([#n.], md(t))
    }
    if last { block(breakable: false, { piece; sig }) } else { piece }
  }
}

#let casd-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: (top: top-margin, bottom: bottom-margin, left: left-margin, right: right-margin),
    background: {
      line-numbers()
      pleading-rules()
    },
    foreground: footer-block(meta.footer_title, meta.case_number),
  )
  set text(font: font-family, size: type-size, lang: "en")
  set par(first-line-indent: 0pt)
  show: xengine.with(pitch: pitch, list-indent: none)
  set block(above: 0pt, below: 0pt, width: 100%)

  // Headings, one numbered line each: level 1 centered bold capitals; level 2 centered bold; level 3 bold italic.
  show heading.where(level: 1): it => block(width: 100%, align(center, text(size: type-size, weight: "bold", upper(it.body))))
  show heading.where(level: 2): it => block(width: 100%, align(center, text(size: type-size, weight: "bold", it.body)))
  show heading.where(level: 3): it => block(text(size: type-size, weight: "bold", style: "italic", it.body))

  cover(meta)

  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }

  allegations(body, signature-block(meta))
}
