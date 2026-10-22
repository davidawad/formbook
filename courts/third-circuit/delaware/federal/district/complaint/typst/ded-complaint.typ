// Complaint for the United States District Court for the District of Delaware (ded).
// Rules: D. Del. LR 5.1.1(a) (8 1/2 x 11 white paper, double-spaced "typical word processing"
// spacing, at least 12 point type for all printed matter, margins at least 1 inch, consecutive page
// numbers, date and descriptive title, Delaware counsel block under the signature line); Fed. R.
// Civ. P. 10(a) (caption, title, file number, Rule 7(a) designation) and 10(b) (numbered paragraphs).
// See ../README.md for the rule text, the verification date and the open choices.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // vendored; not a rule requirement: the rule is about size
#let type-size = 12pt                   // LR 5.1.1(a): at least 12 point for all printed matter (footnotes, page number)
#let page-margin = 1in                  // LR 5.1.1(a): margins not less than 1 inch
#let para-indent = 0.5in                // first-line indent; an allegation's number starts here ...
#let num-box = 0.5in                    // ... in a box this wide: the text starts 1 in in (docx: a tab at 1440)
#let list-indent = 0.5in                // a prayer item's letter starts half an inch in ...
#let list-box = 0.5in                   // ... in a box this wide; the text hangs at 1 in (docx: List Letter)
#let cap-left = 3.3in                   // the caption's party column, ruled at its right ...
#let cap-rule = 0.75pt                  // ... with a rule this thick ...
#let cap-pad = 10pt                     // ... its text this far from the rule ...
#let cap-right = 0.3in                  // ... and the case column's text this far right of it
#let desig-indent = 2in                 // a party's designation ("Plaintiffs,") under its names
#let sig-col = 3.1in                    // the signature column; "Dated:" sits left of its first line

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/ded-complaint.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-body = 27.6pt                // LR 5.1.1(a): double spacing "according to typical word processing software":
                                        // 2 x 1.15 x 12 pt, the exemplar's pitch (docx 552)
#let pitch-single = 13.8pt              // court title, caption, title, signature, footnotes, footer (docx 276)
#let cover-gap = 27.6pt                 // a blank double line: court title to caption, caption to title
#let text-above = 13.8pt                // the title to the text
#let sig-above = 27.6pt                 // the last paragraph to the signature block
#let note-gap = 7pt                     // between two footnotes (docx: Footnote Text 140 twips after)
#let note-clearance = 6pt               // the text to the footnote rule (LibreOffice reserves no more above a note)
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = page-margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ded-complaint: the sample must start with a YAML frontmatter block") }
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

/// Footnote definitions "[^n]: text" keyed by label; each reference "[^n]" becomes a typst footnote.
#let footnote-defs(body) = {
  let d = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.+)$")) { d.insert(m.captures.at(0), m.captures.at(1)) }
  d
}

/// Inline markdown for one text segment; a space at either edge is kept (a footnote sits between two segments).
#let seg(s) = {
  let lead = if s.starts-with(" ") { [ ] } else { [] }
  let trail = if s.ends-with(" ") { [ ] } else { [] }
  lead + inl(s) + trail
}

/// Inline markdown with footnote references turned into typst footnotes.
#let rich(t, defs) = {
  let out = []
  let pos = 0
  for m in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
    out += seg(t.slice(pos, m.start))
    out += footnote(inl(defs.at(m.captures.at(0))))
    pos = m.end
  }
  out + seg(t.slice(pos))
}

#let is-def(t) = t.match(regex("^\\[\\^[^\\]]+\\]:")) != none
#let is-list(t) = t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none

/// A single-pitch line (one paragraph; it wraps on single lines). `above`: the space before it.
#let sline(content, above: 0pt, align-to: left, indent: 0pt) = block(width: 100%, above: above, below: 0pt,
  pad(left: indent, align(align-to, par(first-line-indent: 0pt, content))))

/// Single-pitch lines, one paragraph each; an empty item is a blank single line (leading blank lines as v(): the
/// space above the first block of a cell would be dropped, docx keeps an empty paragraph).
#let lines(items) = {
  let gap = 0pt
  let first = true
  for i in items {
    if i == "" { gap += pitch-single } else {
      if first and gap > 0pt { v(gap); gap = 0pt }
      sline(if type(i) == str { inl(i) } else { i }, above: gap)
      gap = 0pt
      first = false
    }
  }
}

/// A body paragraph on the double pitch, its first line indented; `label` (a number) in a box `num-box` wide.
#let body-par(label, content) = block(width: 100%, above: 0pt, below: 0pt, par({
  if label != none { box(width: num-box, label) }
  content
}))

/// Headings on the body pitch, bold, with no space of their own, kept with the block after them: level 1 centred
/// capitals, level 2 centred, level 3 bold italic at the margin.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set par(first-line-indent: 0pt)
  if level == 1 { align(center, par(text(weight: "bold", upper(inl(s))))) }
  else if level == 2 { align(center, par(text(weight: "bold", inl(s)))) }
  else { par(text(weight: "bold", style: "italic", inl(s))) }
})

// ---------------------------------------------------------------------------
// Cover: court title, caption (Fed. R. Civ. P. 10(a)), title of the pleading
// ---------------------------------------------------------------------------

/// The caption: the parties at the left (each party's names, its designation 2 in in, "v." between), ruled at the
/// right; the file number and the jury demand at the right (docx: a one-row table, the left cell bordered).
#let caption(meta) = {
  let left-col = {
    for (k, p) in meta.caption.parties.enumerate() {
      if k > 0 { sline([v.]) }
      lines(p.names)
      sline(inl(p.designation), indent: desig-indent)
    }
  }
  let right = ("", [C.A. No. #meta.case_number])
  if "jury_demand" in meta and meta.jury_demand { right += ("", "", text(weight: "bold")[JURY TRIAL DEMANDED]) }
  block(width: 100%, above: cover-gap, below: 0pt, breakable: false, grid(
    columns: (cap-left, 1fr),
    stroke: (x, y) => if x == 0 { (right: cap-rule) },
    inset: (x, y) => if x == 0 { (right: cap-pad) } else { (left: cap-right) },
    left-col, lines(right),
  ))
}

#let cover(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  sline(align-to: center, text(weight: "bold")[IN THE UNITED STATES DISTRICT COURT])
  sline(align-to: center, text(weight: "bold")[FOR THE DISTRICT OF DELAWARE])
  caption(meta)
  sline(above: cover-gap, align-to: center, text(weight: "bold", upper(inl(meta.title))))
}

// ---------------------------------------------------------------------------
// Signature block: "Dated:" (LR 5.1.1(a)) left of the first line, the firm, a blank line, the signing counsel
// (Delaware counsel first; an empty line is a blank line), a blank line and "Attorneys for ..."; single lines in the
// signature column. It may run over a page, as the filed one does.
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = meta.signature
  let rows = sig.firm + ("",) + sig.lines
  if "attorneys_for" in meta { rows += ("",) + meta.attorneys_for }
  set text(..edges(pitch-single))
  let gap = sig-above
  let first = true
  for r in rows {
    if r == "" { gap += pitch-single } else {
      block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
        [#box(width: sig-col, if first [Dated: #inl(meta.date)])#inl(r)]))
      gap = 0pt
      first = false
    }
  }
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs (Fed. R. Civ. P. 10(b)), headings, the lettered prayer
// ---------------------------------------------------------------------------

/// A markdown list: one paragraph per item, lettered A., B., ... (a prayer for relief), the letter `list-indent` in,
/// in a `list-box`, the text hanging after it.
#let list-items(t, defs) = {
  let items = ()
  for l in t.split(regex("\\r?\\n")) {
    let m = l.match(regex("^(?:\\d+\\.|[-*+])[ \\t]+([\\s\\S]*)$"))
    if m != none { items.push(m.captures.at(0)) } else if items.len() > 0 { items.at(-1) += " " + l.trim() }
  }
  for (k, item) in items.enumerate() {
    block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent, par(first-line-indent: 0pt,
      hanging-indent: list-box, [#box(width: list-box, numbering("A.", k + 1))#rich(item, defs)])))
  }
}

/// One chunk: a heading, a list, an unnumbered paragraph ("<!-- unnumbered -->" first: the WHEREFORE clause and the
/// jury demand), or a numbered paragraph.
#let render-chunk(t, defs, para) = {
  let h = t.match(regex("^(#{1,3})[ \\t]+(.*)$"))
  if h != none {
    heading-block(h.captures.at(0).len(), h.captures.at(1))
  } else if is-list(t) {
    list-items(t, defs)
  } else if t.starts-with("<!-- unnumbered -->") {
    body-par(none, rich(t.slice(19).trim(), defs))
  } else {
    para.step()
    context body-par(str(para.get().first()) + ".", rich(t, defs))
  }
}

#let ded-complaint(meta, body) = {
  for k in ("case_number", "caption", "title", "date", "signature") {
    if k not in meta { panic("ded-complaint: missing required metadata field `" + k + "`") }
  }
  let defs = footnote-defs(body)
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "" and not is-def(c))
  let para = counter("allegation")

  set document(title: meta.title + ", C.A. No. " + meta.case_number, author: meta.signature.lines.at(0, default: ""))
  set page(paper: "us-letter", margin: page-margin, footer-descent: footer-descent,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 271"; xengine binds a single sign; docx: a no-break space).
  show regex("[§¶]{2,} \\S+"): it => box(it)
  // Footnotes at the type size (LR 5.1.1(a)), single-spaced (docx: Footnote Text in 13.8 pt boxes, 7 pt after).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-single))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  cover(meta)
  v(text-above)
  // An unnumbered lead-in paragraph (the complaint's opening sentence, before the first heading).
  if "lead_in" in meta { body-par(none, rich(meta.lead_in, defs)) }
  for t in chunks { render-chunk(t, defs, para) }
  signature-block(meta)
}
