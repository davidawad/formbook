// Complaint for the U.S. District Court for the Eastern District of Pennsylvania (paed).
// Rules: Fed. R. Civ. P. 8(a) and 10(a)-(b) (caption, numbered paragraphs); E.D. Pa. Local Civil Rule 5.1.1 (no
// dollar amount for unliquidated damages); Local Civil Rule 40.1(b) (civil cover sheet and designation form,
// filed with the complaint, not generated here). The local rules set no typeface, margin or spacing rule; the
// choices below are the convention in the filed exemplar. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // the exemplar's face; the local rules name none (vendored, docs/FONTS.md)
#let type-size = 12pt                   // convention; the local rules set no type size
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let number-box = 0.5in                 // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let letter-indent = 0.5in              // a lettered item "(a)" starts half an inch in ...
#let letter-box = 0.4in                 // ... its letter in a box of its own; the text hangs 0.9 in from the margin
#let margin = 1in                       // convention; the local rules set no margin
#let text-width = 8.5in - 2 * margin
#let caption-left = 3.0in               // party column
#let caption-colon = 0.35in             // column of ":" marks between the parties and the case number
#let caption-right-inset = 0.15in       // the case number starts this far into the right column

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/paed-complaint.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-body = 24pt                  // double spacing, as the exemplar: 27 lines fill the 9-inch text height
#let pitch-single = 13.8pt              // single spacing: court title, caption, signature, footer
#let caption-above = 13.8pt             // the court title to the caption: a blank single line
#let title-above = 13.8pt               // the caption to the title of the pleading
#let text-above = 13.8pt                // the title to the text
#let sig-above = 24pt                   // the last paragraph to the signature block
#let sig-gap = 12pt                     // between the firm, the signer's lines and the date
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("paed-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Single-spaced lines, one paragraph each. `above`: the space before the first line. An item is a string
/// (markdown) or content; `align`: the lines' alignment.
#let line-stack(items, above: 0pt, align: left) = {
  set text(..edges(pitch-single))
  set std.align(align)
  set par(first-line-indent: 0pt)
  for (k, i) in items.enumerate() {
    block(width: 100%, above: if k == 0 { above } else { 0pt }, below: 0pt,
      par(unloose(if type(i) == str { inl(i) } else { i })))
  }
}

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt, par(unloose(content)))

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = line-stack(meta.court_lines.map(l => text(weight: "bold", inl(l))), align: center)

/// The caption: party names on the left, a column of ":" marks (one per single line of the party column), and the
/// civil action number on the right, on the middle line of the party column (the upper middle when the count is
/// even). A blank case number prints as a line for the Clerk.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  let number = if meta.case_number == "" { "________________" } else { meta.case_number }
  let mid = calc.floor((rows.len() - 1) / 2)
  block(width: 100%, above: caption-above, below: 0pt, breakable: false, grid(
    columns: (caption-left, caption-colon, 1fr),
    line-stack(rows),
    line-stack(rows.map(_ => ":")),
    pad(left: caption-right-inset, top: mid * pitch-single, line-stack(([Civil Action No. #number],))),
  ))
}

#let title(meta) = line-stack(above: title-above, (text(weight: "bold", inl(meta.brief_title)),), align: center)

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Headings at the type size on the body pitch, with no space of their own, kept whole and with the block after
/// them: level 1 centred bold capitals; level 2 centred bold; level 3 bold italic at the margin.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, breakable: false, {
  set align(center) if level <= 2
  par(first-line-indent: 0pt, if level == 1 { text(weight: "bold", upper(unloose(inl(s)))) }
    else if level == 2 { text(weight: "bold", unloose(inl(s))) }
    else { text(weight: "bold", style: "italic", unloose(inl(s))) })
})

/// A lettered item "(a)": the letter half an inch in, in a box of its own, the text hanging after it (docx: a tab
/// and a hanging indent).
#let lettered(label, s) = block(width: 100%, above: 0pt, below: 0pt, pad(left: letter-indent,
  par(first-line-indent: 0pt, hanging-indent: letter-box, [#box(width: letter-box, label)#unloose(inl(s))])))

/// The signature block, single-spaced at the margin: the firm, "BY: /s/" and the signer's lines, the date.
#let signature-block(meta) = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  line-stack(meta.signature.firm)
  line-stack(above: sig-gap, ("BY: /s/ " + meta.signature.signer,) + meta.signature.lines)
  line-stack(above: sig-gap, ([Date: #meta.date],))
})

/// The body, chunk by chunk (blank-line separated). A `#` chunk is a heading (levels 1 to 3); a chunk of `1.` items
/// is a lettered list, "(a)", "(b)", ...; every other chunk is a paragraph, numbered (Fed. R. Civ. P. 10(b)) unless
/// it opens with "WHEREFORE" (the request for relief). The last piece is set with `closing` (the signature block) in
/// one unbreakable block, so the signature never stands alone on a page.
#let body-chunks(body, closing) = {
  let n = 0
  let pieces = ()
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  for t in chunks {
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      pieces.push(heading-block(calc.min(level, 3), t.slice(level).trim()))
    } else if t.match(regex("^\\d+\\.[ \\t]")) != none {
      // one item per "1." line; a line without a number continues the item before it
      let items = ()
      for l in t.split(regex("\\r?\\n")) {
        if l.match(regex("^\\d+\\.[ \\t]")) != none { items.push(l.replace(regex("^\\d+\\.[ \\t]+"), "")) }
        else { items.last() += " " + l.trim() }
      }
      for (k, s) in items.enumerate() { pieces.push(lettered("(" + numbering("a", k + 1) + ")", s)) }
    } else if t.starts-with("WHEREFORE") {
      pieces.push(body-par(inl(t)))
    } else {
      n += 1
      pieces.push(body-par[#box(width: number-box)[#n.]#unloose(inl(t))])
    }
  }
  for (i, it) in pieces.enumerate() {
    if i == pieces.len() - 1 {
      block(width: 100%, above: 0pt, below: 0pt, breakable: false, { it; closing })
    } else { it }
  }
}

#let paed-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: footer-descent,
    footer: context align(center, par(first-line-indent: 0pt, text(..edges(pitch-single), counter(page).display()))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays whole and with its number ("§§ 1681"): typst would break between the signs.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  court-title(meta)
  caption(meta)
  title(meta)
  v(text-above)
  if "lead_in" in meta { body-par(inl(meta.lead_in)) }
  let last-chunk = body.trim().split(regex("\\r?\\n[ \\t]*\\r?\\n")).last()
  assert(not last-chunk.starts-with("#"), message: "paed-complaint: the body must end with a paragraph or a list (the signature is set with it)")
  body-chunks(body, signature-block(meta))
}
