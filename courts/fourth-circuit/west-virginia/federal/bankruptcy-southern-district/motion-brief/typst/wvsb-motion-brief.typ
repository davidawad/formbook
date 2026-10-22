// U.S. Bankruptcy Court, S.D. West Virginia: motion with its supporting argument (FRBP 9013).
//
// Rule-driven and content-agnostic. Requirement IDs (WVSB-...) refer to ../README.md, which quotes the
// rule text and gives the date verified. No case-specific text, no coordinates measured off the
// exemplar, no forced line breaks. The body is rendered by cmarker from the markdown sample; the court
// title, caption, document title, signature block and optional certificate come from the YAML
// frontmatter of the same file.

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")         // WVSB-FORM-002: no rule names a typeface (see ../README.md); Times New Roman substitute per docs/FONTS.md. Vendored in /fonts.
#let type-size = 12pt                    // WVSB-FORM-002: no rule sets a size; the 12 pt convention (docs/FONTS.md).
#let note-size = 10pt                    // the debtors note under the caption
#let margins = (top: 1in, bottom: 1in, x: 1in)   // WVSB-FORM-004: a style choice (the exemplar uses 1 in).
#let para-indent = 0.5in
#let heading-tab = 0.5in                 // a heading's label box; each deeper level half an inch further in
#let quote-inset = 0.5in                 // block quotations, both sides
#let footer-size = 11pt
#let caption-left = 3.25in               // caption: the party column, half the text width
#let caption-inset = 0.2in               // the party text stands off the caption's right rule, the case information off the rule
#let sep-indent = 1.2in                  // "v." in the party column
#let designation-indent = 1.8in          // a side's designation ("Debtors.") under its names
#let sig-column = 3.2in                  // signature: the right-hand column (the preamble, the second counsel block)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt                   // WVSB-FORM-003: double spacing, as in the exemplar.
#let pitch-single = 13.8pt               // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-note = 11.5pt                 // a single line of the 10 pt note: 1.15 x its size
#let gap = pitch-body / 2                // between the caption's groups, around headings and quotations, in the signature

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

#let need(meta, key) = {
  if key not in meta { panic("wvsb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wvsb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: left, body)
})

/// A paragraph at the body pitch with the half-inch first-line indent.
#let body-par(body) = block(width: 100%, above: 0pt, below: 0pt, par(body))

// ---------------------------------------------------------------------------
// Headings: numbering (the exemplar's own sub-heading scheme; not a rule)
// ---------------------------------------------------------------------------

/// Printed label of a numbered heading: level 2 "A.", level 3 "1.", level 4 "a.". Level 1 is unnumbered.
#let heading-num(..n) = {
  let lv = n.pos().len()
  let k = n.pos().last()
  if lv == 2 { numbering("A.", k) }
  else if lv == 3 { numbering("1.", k) }
  else if lv == 4 { numbering("a.", k) }
  else { "" }
}

/// Left edge of a heading's label: level 2 at the margin, each deeper level half an inch in.
#let label-indent(level) = (level - 2) * heading-tab

// ---------------------------------------------------------------------------
// Caption (WVSB-CAP-001 to WVSB-CAP-003; FRBP 9004(b); FRCP 10(a))
// ---------------------------------------------------------------------------

/// Two-column caption. Left: each side of the case, with `v.` printed before a side that has `sep`.
/// Right: the case information (case number, chapter, judge). A side's `footnote` is marked on its
/// designation and set under the caption.
#let caption(meta) = {
  let sides = need(meta, "caption")
  let info = need(meta, "case_info")
  let left = for (i, side) in sides.enumerate() {
    if "sep" in side { line-block(above: gap, below: gap, left: sep-indent, inl(side.sep)) }
    let first = i > 0 and "sep" not in side
    for (j, n) in side.names.enumerate() { line-block(above: if first and j == 0 { gap } else { 0pt }, inl(n)) }
    line-block(left: designation-indent, {
      inl(side.designation)
      if "footnote" in side { super[\*] }
    })
  }
  block(above: pitch-body, below: 0pt, grid(
    columns: (caption-left, 1fr),
    block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: gap), left),
    pad(left: caption-inset, for l in info { line-block(inl(l)) }),
  ))
  // The debtors note sits under the caption, in the flow (not a page-foot footnote).
  for side in sides {
    if "footnote" in side {
      block(width: 100%, above: gap / 2, below: 0pt, {
        set text(size: note-size, ..edges(pitch-note))
        set par(first-line-indent: 0pt)
        [\* #inl(side.footnote)]
      })
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (FRBP 9011(a); LR 9011-4 for the /s/ form)
// ---------------------------------------------------------------------------

/// The prayer (`closing`, the WHEREFORE clause) when the sample gives one, the date at the margin and
/// the preamble in the right-hand column, then the counsel blocks two to a row (the first at the
/// margin, the second in the right-hand column); never split across pages, so the signature never
/// stands alone on a page.
#let signature-block(sig, closing: none) = {
  let at = 8.5in - 2 * margins.x - sig-column   // letter width less the margins
  block(width: 100%, breakable: false, above: pitch-body, below: 0pt, {
    if closing != none { block(width: 100%, above: 0pt, below: gap, par(inl(closing))) }
    if "dated" in sig { line-block[Dated: #inl(sig.dated)] }
    for (i, l) in sig.at("preamble", default: ()).enumerate() {
      line-block(above: if i == 0 and "dated" in sig { gap } else { 0pt }, left: at, inl(l))
    }
    let cells = sig.blocks.map(blk => for l in blk { line-block(inl(l)) })
    block(width: 100%, above: gap, below: 0pt, grid(columns: (1fr, sig-column), row-gutter: gap, ..cells))
  })
}

// ---------------------------------------------------------------------------
// The motion
// ---------------------------------------------------------------------------

#let wvsb-motion-brief(meta, md) = {
  // ---- metadata checks (loud failure beats silent omission) ----
  for k in ("court", "caption", "case_info", "title", "signature") {
    let _ = need(meta, k)
  }

  // ---- document-wide settings (WVSB-FORM-001: letter paper; WVSB-FORM-002 to 004 style) ----
  // A centered page number on every page, in a single-spaced line box (Word's footer).
  set page(paper: "us-letter", margin: margins, numbering: "1", footer-descent: 30%, footer: context align(center,
    text(size: footer-size, ..edges(pitch-single), counter(page).display("1"))))
  set document(title: need(meta, "title"))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1334"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  // Footnotes: 12 pt, single-spaced (the entry sets its own leading: it does not inherit the body's); the mark, a
  // space, the note (Word's footnote layout).
  set footnote.entry(gap: 7pt, clearance: 12.6pt, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    // LibreOffice splits a note anywhere (it keeps no widow or orphan line in a footnote): so does typst here.
    set text(size: type-size, ..edges(pitch-single), costs: (widow: 0%, orphan: 0%))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    [#super(num) #note.body]
  }

  // Block quotations: single-spaced, inset on both sides, half a body line around them and between their
  // paragraphs.
  set quote(block: true)
  show quote: it => block(width: 100%, above: gap, below: gap, pad(x: quote-inset, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt, spacing: gap)
    it.body
  }))

  // Headings, single-spaced, half a body line above and below, kept with the text after them: level 1 centred
  // bold capitals (unnumbered); level 2+ the label in a half-inch box ((level - 2) half inches in), the bold
  // title hanging after it.
  set heading(numbering: heading-num)
  show heading: it => context {
    let nums = counter(heading).at(it.location()).slice(0, it.level)
    let lab = if it.numbering == none { "" } else { numbering(it.numbering, ..nums) }
    block(width: 100%, above: gap, below: gap, sticky: true, {
      set text(size: type-size, ..edges(pitch-single))
      set par(first-line-indent: 0pt)
      if it.level == 1 { align(center, strong(upper(it.body))) }
      else {
        let ind = label-indent(it.level)
        par(hanging-indent: ind + heading-tab, strong[#h(ind)#box(width: heading-tab, lab)#it.body])
      }
    })
  }

  // ---- first page: court title, caption, document title ----
  for l in need(meta, "court") { line-block(align(center, inl(l))) }
  caption(meta)
  line-block(above: pitch-body, below: gap, align(center, strong(upper(inl(need(meta, "title"))))))

  // ---- body (numbered paragraphs are typed in the sample, escaped as `1\.`) ----
  cmarker.render(md, raw-typst: false, smart-punctuation: true)

  signature-block(need(meta, "signature"), closing: meta.at("closing", default: none))

  // ---- certificate of service, when the sample gives one (WVSB-MOT-004; LR 9013-1(a)(3)) ----
  if "certificate" in meta {
    let c = meta.certificate
    pagebreak()
    line-block(below: gap, align(center, strong(upper("Certificate of Service"))))
    body-par(inl(c.text))
    signature-block(c)
  }
}
