// Motion with brief in support (memorandum), United States Bankruptcy Court for the Western District of
// Wisconsin (wiwb). Built from the rules; the filed exemplar (../usage/SOURCE.md) settles only what they
// leave open. Rules (see ../README.md for quotes, URLs and the verification date):
//   Fed. R. Bankr. P. 9013 (a motion is written; it states its grounds with particularity and the relief sought),
//   9004(a)-(b) (legibility; caption elements), 9011 (signature block), 9014 (contested matter, for a motion
//   that is not an adversary-proceeding motion), 7012(b) (Fed. R. Civ. P. 12(b) defenses in adversary proceedings).
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a stated convention; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // Times New Roman, the house standard (docs/FONTS.md), vendored in fonts/; no system font is used (tools/render.sh)
#let type-size = 12pt                   // convention: 12 point body text (no W.D. Wis. rule found; README.md)
#let note-size = 10pt                   // footnote text
#let footer-size = 11pt                 // the page number
#let page-w = 8.5in                     // 8 1/2 by 11 inch paper (convention; README.md)
#let page-h = 11in
#let margin = 1in                       // convention: 1 inch margins
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                // first-line indent of body paragraphs; a bullet starts here
#let bullet-box = 0.4in                 // a bullet in a box after the indent: the item's lines hang at 0.9 in
#let heading-hang = 0.4in               // a level-2 heading's lines after the first hang this far in
#let title-inset = 0.5in                // the title of the paper is set this far in on both sides
#let quote-inset = 0.5in                // block quotations: indented on both sides
#let caption-left = 3.4in               // width of the party column of the caption
#let caption-gutter = 0.25in
#let caption-pad = 10pt                 // the party column's text stands this far from its rules (adversary caption)
#let caption-rule = 0.75pt
#let designation-right = 0.4in          // a party's designation is set flush right 0.4 in inside the party column
#let sig-col = 3.4in                    // signature: the date in a 3.4 in column, the firm and signer after it
#let adv-blank = "____________"         // the clerk's adversary number, when the sample has none
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "WESTERN DISTRICT OF WISCONSIN")   // Fed. R. Bankr. P. 9004(b)(1)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/wiwb.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 27.6pt                // double-spaced body (convention; no W.D. Wis. rule found): 2 x 1.15 x 12 pt, the word-processor "double" line (README.md)
#let pitch-single = 13.8pt              // single spacing: caption, title, headings, block quotations, signature
#let pitch-note = 11.5pt                // footnote lines: single spacing at 10 pt
#let note-gap = 6pt                     // between two footnotes
#let note-clearance = 13.8pt            // the body text to the footnote rule (Word's separator line)
#let court-gap = 18pt                   // court title to caption
#let caption-gap = 13.8pt               // a blank single line between the caption's elements (Official Form 416B)
#let title-gap = 24pt                   // caption to title, title to the body
#let heading-gap = 13.8pt               // above and below a heading (a blank single line)
#let quote-gap = 13.8pt                 // above and below a block quotation
#let sig-above = 39.6pt                 // the last paragraph to the signature block
#let sig-gap = 18pt                     // the closing to the firm, the firm to "By: /s/"
#let signer-above = 2.4pt               // "By: /s/" to the signer's lines
#let designation-gap = 6pt              // adversary caption: a party's names to its designation
#let versus-gap = 9.6pt                 // adversary caption: above and below "v."
#let adv-above = 2.4pt                  // adversary caption: "Adversary Case No." below the caption's top

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wiwb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

#let md(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true, h1-level: 1)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = unloose(md(s))

/// One single-pitch line (a paragraph of its own), with explicit spaces above and below it.
#let sline(above: 0pt, below: 0pt, left: 0pt, right: none, centered: false, c) = block(width: 100%, above: above,
  below: below, {
    set text(..edges(pitch-single))
    set align(center) if centered
    let body = par(first-line-indent: 0pt, if type(c) == str { inl(c) } else { c })
    if right != none { pad(right: right, align(std.right, body)) } else { pad(left: left, body) }
  })

// ---------------------------------------------------------------------------
// Caption (Fed. R. Bankr. P. 9004(b); Fed. R. Bankr. P. 7010 and Official Form 416 for adversary captions)
// ---------------------------------------------------------------------------

/// Caption. A contested matter in the main case (no `caption:` in the frontmatter) follows Official Form 416B
/// (Caption, Short Title, 12/15): "In re" and the debtor's name with "Debtor" under it at the left; "Case No."
/// and "Chapter" at the right; no rules; a blank single line between the elements. An adversary proceeding keeps
/// the ruled party column with the adversary number at the right (Fed. R. Bankr. P. 7010). The adversary number
/// is printed only when the sample gives one; otherwise a blank for the clerk.
#let caption(meta) = if "caption" not in meta {
  block(width: 100%, above: court-gap, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    { sline("In re:"); sline(above: caption-gap, meta.debtor); sline(above: caption-gap, left: para-indent, "Debtor.") },
    [],
    {
      sline("Case No. " + meta.bankruptcy_case)
      if "chapter" in meta { sline(above: caption-gap, "Chapter " + meta.chapter) }
    },
  ))
} else {
  let left = {
    for l in ("In re:", meta.debtor, "Debtor.", "Case No. " + meta.bankruptcy_case) { sline(l) }
    if "chapter" in meta { sline("Chapter " + meta.chapter) }
    for (i, side) in meta.caption.enumerate() {
      for (j, n) in side.names.enumerate() { sline(above: if i == 0 and j == 0 { caption-gap } else { 0pt }, n) }
      sline(above: designation-gap, right: designation-right - caption-pad, side.designation)
      if i < meta.caption.len() - 1 { sline(above: versus-gap, below: versus-gap, "v.") }
    }
  }
  let n = if "adversary_case" in meta and meta.adversary_case != "" { meta.adversary_case } else { adv-blank }
  block(width: 100%, above: court-gap, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    stroke: (x, y) => if x == 0 { (right: caption-rule, bottom: caption-rule) },
    inset: (x, y) => if x == 0 { (right: caption-pad, bottom: caption-pad) } else { 0pt },
    left,
    [],
    // the space above the first line of a cell is not collapsed away (Word keeps it): a pad
    pad(top: adv-above, sline([#text(weight: "bold")[Adversary Case No.] #n])),
  ))
}

#let cover(meta) = {
  for l in court-name { sline(centered: true, text(weight: "bold", l)) }
  caption(meta)
  // Designation of the paper (Fed. R. Bankr. P. 9004(b)(4); Official Form 416B "[Designation of Character of
  // Paper]"): centred, bold capitals, single-spaced so a two-line title reads as one block.
  block(width: 100%, above: title-gap, below: title-gap, pad(x: title-inset,
    sline(centered: true, text(weight: "bold", upper(inl(meta.title))))))
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, lists, quotations
// ---------------------------------------------------------------------------

/// A body paragraph on the body pitch.
#let body-par(sticky: false, first: para-indent, hang: 0pt, c) = block(width: 100%, above: 0pt, below: 0pt,
  sticky: sticky, par(first-line-indent: (amount: first, all: true), hanging-indent: hang, unloose(c)))

/// Brief body: each blank-line-separated chunk is one paragraph (first-line indent, not numbered by the template:
/// a brief is argument, not allegations; numbers the drafter typed stay as typed). Headings are rendered by the
/// show rules below; a "- " chunk is a bulleted item, a "1. " chunk a numbered one; a "> " chunk a quotation.
#let brief-body(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  // Footnote text is kept apart from the chunks: each chunk is rendered alone, so a chunk gets the
  // definitions of the notes it refers to, and a definition chunk is not printed as a paragraph.
  let notes = (:)
  for m in body.matches(regex("(?m)^\\[\\^([^\\]]+)\\]:[ \\t]*(.*)$")) {
    notes.insert(m.captures.at(0), m.captures.at(1))
  }
  let chunks = chunks.filter(c => not c.trim().starts-with(regex("^\\[\\^[^\\]]+\\]:")))
  let item-re = regex("(?m)^(\\d+\\.|[-*+])[ \\t]+")
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let defs = ""
    for r in t.matches(regex("\\[\\^([^\\]]+)\\]")) {
      let id = r.captures.at(0)
      defs += "\n\n[^" + id + "]: " + notes.at(id, default: "")
    }
    // The last paragraph is kept on the page with the signature block that follows it.
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      md(t + defs)
    } else if t.starts-with(">") {
      // Block quotation: indented 0.5 inch on both sides, single-spaced, not first-line indented.
      let q = t.replace(regex("(?m)^>[ \\t]?"), "")
      block(width: 100%, above: quote-gap, below: quote-gap, sticky: last,
        pad(x: quote-inset, sline(md(q + defs))))
    } else if t.match(regex("^(\\d+\\.|[-*+])[ \\t]")) != none {
      let bullet = t.match(regex("^[-*+]")) != none
      let items = t.split(item-re).map(s => s.trim()).filter(s => s != "")
      for (k, item) in items.enumerate() {
        let label = if bullet [•] else [#(k + 1).]
        body-par(first: 0pt, hang: para-indent + bullet-box, sticky: last and k == items.len() - 1,
          [#h(para-indent)#box(width: bullet-box, label)#unloose(md(item + defs))])
      }
    } else {
      body-par(sticky: last, md(t + defs))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (Fed. R. Bankr. P. 9011): date, firm, /s/ signature, signer, bar number, address, phone
// ---------------------------------------------------------------------------

/// Single-spaced and kept on one page: the closing (when given) and the firm in a column from `sig-col`; then the
/// date at the left on the same line as "By: /s/" (docx: a tab and a hanging indent at `sig-col`); then the signer's
/// lines under the signature.
#let signature(meta) = {
  let sig = meta.signature
  let lines = ()
  // The closing line ("Respectfully submitted,") is the filer's choice; it is printed only when given.
  if "closing" in sig { lines.push((none, sig.closing, 0pt)) }
  if "firm" in sig { lines.push((none, text(weight: "bold", sig.firm), if lines.len() > 0 { sig-gap } else { 0pt })) }
  // Electronic signature: "/s/" before the signer's name, as CM/ECF filers type it (Fed. R. Bankr. P. 9011(a)
  // requires the signature; the "/s/" form is convention, see README.md).
  lines.push((if "date" in meta { inl(meta.date) }, "By: /s/ " + sig.signer, if lines.len() > 0 { sig-gap } else { 0pt }))
  for (k, l) in sig.lines.enumerate() { lines.push((none, l, if k == 0 { signer-above } else { 0pt })) }
  block(width: 100%, breakable: false, above: sig-above, below: 0pt, {
    set text(..edges(pitch-single))
    for (lead, l, gap) in lines {
      block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
        [#box(width: sig-col, lead)#if type(l) == str { inl(l) } else { l }]))
    }
  })
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let wiwb-motion-brief(meta, body) = {
  // Fed. R. Bankr. P. 9013(b) requires the grounds and the relief requested, in substance. It does not require
  // headings for them: the filed memorandum (../usage/SOURCE.md) states both in its own headings, so the
  // template asserts nothing about heading names.

  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    // The page number centered at the foot of every page (the ECF header is added by the court's system, not
    // here), in a single-pitch line box that ends footer-distance above the page edge.
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(size: footer-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  show regex("[§¶]+ \\S+"): it => box(it)

  // Footnotes at 10 pt in single lines, the mark, a space, the text (docx: Footnote Text).
  set footnote.entry(gap: note-gap, clearance: note-clearance, indent: 0pt, separator: line(length: 2in, stroke: 0.5pt))
  show footnote.entry: it => {
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    set text(size: note-size, ..edges(pitch-note))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt) // the entry does not inherit the body's leading 0
    [#super(num) #note.body]
  }

  // Headings are the body size (the filed memorandum's are 12 pt), single-spaced (a two-line heading reads as one
  // unit) with a blank single line above and below; sticky so a heading never ends a page.
  show heading: it => block(width: 100%, above: heading-gap, below: heading-gap, sticky: true, {
    set text(size: type-size, weight: "bold", ..edges(pitch-single))
    if it.level == 1 { set par(first-line-indent: 0pt); align(center, upper(it.body)) }
    else { par(first-line-indent: 0pt, hanging-indent: heading-hang, it.body) }
  })

  cover(meta)
  brief-body(body)
  signature(meta)
}
