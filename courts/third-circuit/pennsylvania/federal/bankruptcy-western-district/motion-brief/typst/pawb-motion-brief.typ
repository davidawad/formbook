// Brief in support of a motion (memorandum) in an adversary proceeding, U.S. Bankruptcy Court, W.D. Pennsylvania (pawb).
// Rules: Fed. R. Bankr. P. 9013 (a request for an order is made by written motion; grounds stated with particularity), 7010 (FRCP 10 applies; caption per
// Official Form 416D), W.PA LBR 7010-1(a)-(b) (caption with the judge's initials; short descriptive title), 7008-1(c)
// (proposed order attached to a motion: a separate filing), 7008-1(e) (briefs limited to 20 pages), 5005-13(b) (8.5 x 11,
// sequential page numbers, 12-point type or larger including footnotes, text-searchable PDF; paragraph numbering does
// not apply to briefs), 5005-6(d) (signature block). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no face is named (LBR 5005-13(b)(4)); the exemplar's face, vendored (docs/FONTS.md)
#let type-size = 12pt                   // LBR 5005-13(b)(4): "no smaller than 12 Courier or an equivalent font size", footnotes included
#let page-w = 8.5in                     // LBR 5005-13(b)(1): 8.5 by 11 inch paper
#let margin = 1in                       // convention (the exemplar); no W.PA rule sets margins
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let quote-indent = 0.5in               // block quotations: indented half an inch on each side
#let cap-left = 3.4in                   // the caption's boxed column (debtor, then the parties; Official Form 416D) ...
#let cap-gutter = 0.25in                // ... the gap to the case-number column
#let cap-pad = 10pt                     // the boxed column's text stops this far from its right rule
#let cap-rule = 0.75pt                  // the caption's rules
#let cap-designation = 0.5in            // a designation ("Debtor.", "Plaintiff,") starts half an inch in, as the exemplar

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/pawb-motion-brief.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-body = 24pt                  // double spacing, as the exemplar (docx 480)
#let pitch-single = 13.8pt              // court title, caption, title, quotations, footnotes, signature, footer (docx 276)
#let caption-above = 18pt               // the court title to the caption
#let cap-inset = 6pt                    // the caption boxes' text off their top and bottom rules
#let title-above = 18pt                 // the caption to the title of the paper
#let text-above = 12pt                  // the title to the text
#let quote-gap = 12pt                   // above and below a block quotation (docx: Block Text 240 twips)
#let sig-above = 24pt                   // the last paragraph to "Respectfully submitted,"
#let note-gap = 7pt                     // between two footnotes (docx: Footnote Text 140 twips after)
#let note-clearance = 6pt               // the text to the footnote rule (LibreOffice reserves no more above a note)
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pawb-motion-brief: the sample must start with a YAML frontmatter block") }
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

/// Inline markdown.
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// Footnote definitions "[^n]: text" keyed by label. Their chunks are removed from the body and each
/// reference "[^n]" becomes a typst footnote with the definition's text.
#let footnote-defs(body) = {
  let d = (:)
  for m in body.matches(regex("(?m)^\\[\\^(\\w+)\\]:[ \\t]*(.+)$")) {
    d.insert(m.captures.at(0), m.captures.at(1))
  }
  d
}

/// Inline markdown for one text segment. Markdown drops whitespace at a segment's edges, so a space at either edge
/// is kept as a typst space (a footnote reference sits between two segments).
#let seg(s) = {
  let lead = if s.starts-with(" ") { [ ] } else { [] }
  let trail = if s.ends-with(" ") { [ ] } else { [] }
  lead + inl(s) + trail
}

/// Inline markdown with footnote references turned into typst footnotes.
#let rich(t, defs) = {
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^(\\w+)\\]")) {
    out += seg(t.slice(pos, m.start))
    out += footnote(inl(defs.at(m.captures.at(0))))
    pos = m.end
  }
  out + seg(t.slice(pos))
}

#let is-def(t) = t.match(regex("^\\[\\^\\w+\\]:")) != none

/// Single-pitch lines, one paragraph each; an empty item is a blank single line. `above`: the space before the
/// first; `indent`: the left indent of each item, by position.
#let lines(items, above: 0pt, centered: false, indent: (:)) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  set align(center) if centered
  let gap = above
  for (k, i) in items.enumerate() {
    if i == "" { gap += pitch-single } else {
      block(width: 100%, above: gap, below: 0pt, pad(left: indent.at(str(k), default: 0pt),
        par(if type(i) == str { inl(i) } else { i })))
      gap = 0pt
    }
  }
}

/// A body paragraph on the double pitch, its first line indented.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt, par(content))

// ---------------------------------------------------------------------------
// Cover: court title, Form 416D caption, title of the paper
// ---------------------------------------------------------------------------

/// The caption (Official Form 416D; LBR 7010-1(a)): a boxed column ruled above and to the right holding "In re:",
/// the debtor and its designation, then one ruled to the right and below holding the parties (a blank single line
/// between the names and the designation and between the parties); the case number and chapter, and the adversary
/// proceeding number, at the top of each box on the right.
#let caption(meta) = {
  let debtor = ("In re:", "", meta.debtor.name, "", meta.debtor.designation)
  let parties = ()
  let ind = (:)
  ind.insert(str(debtor.len() - 1), cap-designation)
  let pind = (:)
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { parties.push("") }
    parties += p.names + ("",)
    pind.insert(str(parties.len()), cap-designation)
    parties.push(p.designation)
  }
  let adv = if "adversary_number" in meta and meta.adversary_number != "" { meta.adversary_number }
    else { "______________" }
  let r = cap-rule
  block(width: 100%, above: caption-above, below: 0pt, breakable: false, grid(
    columns: (cap-left, cap-gutter, 1fr),
    grid.cell(stroke: (top: r, right: r), inset: (right: cap-pad, top: cap-inset), lines(debtor, indent: ind)),
    [],
    grid.cell(inset: (top: cap-inset), lines(("Case No. " + meta.bankruptcy_case, meta.chapter))),
    grid.cell(stroke: (right: r, bottom: r), inset: (right: cap-pad, top: pitch-single, bottom: cap-inset),
      lines(parties, indent: pind)),
    [],
    grid.cell(inset: (top: pitch-single), lines(("Adv. Proc. No. " + adv,))),
  ))
}

#let cover(meta) = {
  lines(centered: true, ("IN THE UNITED STATES BANKRUPTCY COURT", "FOR THE WESTERN DISTRICT OF PENNSYLVANIA")
    .map(l => text(weight: "bold", l)))
  caption(meta)
  // LBR 7010-1(b): a short, concise descriptive title in addition to the adversary caption.
  lines(above: title-above, centered: true, (text(weight: "bold", inl(meta.title)),))
}

// ---------------------------------------------------------------------------
// Signature block (LBR 5005-6(d)): the filing user's name is preceded by "/s/"; the firm, then each attorney's
// Bar ID, address, phone and e-mail. Only the filing user's name carries "/s/".
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let items = ("Respectfully submitted,", "")
  if "firm" in meta.signature { items += meta.signature.firm + ("",) }
  for (k, b) in meta.signature.blocks.enumerate() {
    if k > 0 { items.push("") }
    items += ((if b.sign { "/s/" + b.signer } else { b.signer }), b.pa_id) + b.lines
  }
  block(width: 100%, above: sig-above, below: 0pt, breakable: false, lines(items))
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// Headings at the type size on the body pitch, with no space of their own, kept whole and with the block after
/// them: level 2 ("I. OVERVIEW") centred bold capitals; level 3 ("A. ...") bold at the margin; level 4 ("1. ...")
/// bold italic at the margin. A heading's own number ("1. ...") is text, not a markdown list: its full stop is
/// escaped for cmarker.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false, {
  let s = s.replace(regex("^(\\d+)\\. "), m => m.captures.at(0) + "\\. ")
  set align(center) if level <= 2
  par(first-line-indent: 0pt, if level <= 2 { text(weight: "bold", upper(inl(s))) }
    else if level == 3 { text(weight: "bold", inl(s)) }
    else { text(weight: "bold", style: "italic", inl(s)) })
})

/// One chunk: a heading, a block quotation ("> ": single spaced, half an inch in on each side, a space above and
/// below), or a paragraph (first line indented; briefs are not paragraph numbered, LBR 5005-13(b)(3)).
#let render-chunk(t, defs) = {
  if t.starts-with("#") {
    let level = t.match(regex("^#+")).end
    heading-block(level, t.slice(level).trim())
  } else if t.starts-with(">") {
    let q = t.split(regex("\\r?\\n")).map(l => l.replace(regex("^>[ \\t]?"), "")).join(" ")
    block(width: 100%, above: quote-gap, below: quote-gap, pad(x: quote-indent, {
      set text(..edges(pitch-single))
      par(first-line-indent: 0pt, rich(q, defs))
    }))
  } else {
    body-par(rich(t, defs))
  }
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let pawb-motion-brief(meta, body) = {
  let defs = footnote-defs(body)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "" and not is-def(c))
  assert(not chunks.last().starts-with("#"), message: "pawb-motion-brief: the body must end with a paragraph (the signature is set with it)")

  set page(
    paper: "us-letter",
    margin: margin,
    // LBR 5005-13(b)(2): sequential page numbers, centred at the foot; page 1 is numbered too.
    footer-descent: footer-descent,
    footer: context align(center, par(first-line-indent: 0pt, text(..edges(pitch-single), counter(page).display()))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 108"; xengine binds a single sign; docx: a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at the type size (LBR 5005-13(b)(4)), single-spaced, kept whole (docx: Footnote Text keeps its
  // lines, 7 pt after), a short rule above.
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    block(breakable: false, [#super(num)#h(0.25em)#note.body])
  }

  cover(meta)
  v(text-above)
  for (i, t) in chunks.enumerate() {
    if i == chunks.len() - 1 {
      block(width: 100%, above: 0pt, below: 0pt, breakable: false, { render-chunk(t, defs); signature-block(meta) })
    } else { render-chunk(t, defs) }
  }
}
