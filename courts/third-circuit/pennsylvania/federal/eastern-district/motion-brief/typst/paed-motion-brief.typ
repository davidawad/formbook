// Motion with memorandum of law for the U.S. District Court for the Eastern District of Pennsylvania (paed).
// Rules: Fed. R. Civ. P. 7(b) (a motion states the grounds and relief with particularity) and 12(b); E.D. Pa.
// Local Civil Rule 7.1(a) (a proposed form of order accompanies every motion), 7.1(c) (a brief with a concise
// statement of the legal contentions and authorities), 7.1(d) (a written statement of the date and manner of
// service); Local Civil Rule 5.1.2(7)(b) (a certificate of service on every ECF document). The local rules set no
// typeface, margin, spacing, or table rule; the choices below follow the filed exemplar. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter and body, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // the exemplar's face; the local rules name none (vendored, docs/FONTS.md)
#let type-size = 12pt                   // convention; the local rules set no type size
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let margin = 1in                       // convention; the local rules set no margin
#let caption-left = 3.3in               // party column
#let caption-colon = 0.35in             // column of ":" marks between the parties and the action number
#let caption-right-inset = 0.15in       // the action number starts this far into the right column
#let item-indent = 0.5in                // a numbered item of the order starts half an inch in ...
#let item-box = 0.4in                   // ... its number in a box of its own; the text hangs 0.9 in from the margin
#let heading-box = 0.5in                // a level-2 or level-3 heading's label box; its title hangs after it
#let quote-inset = 0.5in                // a block quotation is indented half an inch on both sides
#let sig-col = 2.8in                    // the signature's column; the date sits left of it
#let order-sig-col = 3.7in              // the court's signature column of the proposed order (2.8 in wide)
#let toc-step = 0.5in                   // a contents row is indented this much per heading level below 1 ...
#let toc-hang = 0.5in                   // ... its label in a box this wide, the title's later lines hanging after it
#let toc-col = 0.5in                    // the page column of the contents

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/paed-motion-brief.lua and docx/reference.xml
// set the same twips: 20 x pt).
#let pitch-body = 24pt                  // double spacing, as the exemplar: body text and headings
#let pitch-single = 13.8pt              // single spacing: court title, caption, titles, quotations, contents, signatures, footer
#let caption-above = 13.8pt             // the court title to the caption: a blank single line
#let title-above = 13.8pt               // the caption to the title of the paper
#let text-above = 13.8pt                // the title to the text
#let quote-gap = 12pt                   // above and below a block quotation
#let sig-above = 24pt                   // the last paragraph to a signature block
#let sig-gap = 12pt                     // "Respectfully submitted," to the firm, the firm to "By: /s/", block to block
#let order-sig-gap = 41.4pt             // "BY THE COURT:" to the judge's line: three blank single lines
#let cert-above = 24pt                  // the motion's signature to the certificate of service
#let toc-above = 24pt                   // the contents' title to its first row
#let toc-gap = 12pt                     // above every other row of the contents
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("paed-motion-brief: the sample must start with a YAML frontmatter block") }
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

/// Split the body into its named sections: "<!-- name -->" starts a section that runs to the next marker.
#let sections(body) = {
  let out = (:)
  for piece in ("\n" + body).split("\n<!-- ") {
    let i = piece.position(" -->")
    if i != none {
      out.insert(piece.slice(0, i), piece.slice(i + 4))
    }
  }
  out
}

/// Blank-line-separated chunks of a section's markdown.
#let chunks(md) = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = line-stack(meta.court_lines.map(l => text(weight: "bold", inl(l))), align: center)

/// The caption: party names on the left, a column of ":" marks (one per single line of the party column), and
/// "CIVIL ACTION" and the number on the right, around the middle line of the party column. A blank case number
/// prints as a line for the Clerk.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  let number = if meta.case_number == "" { "________________" } else { meta.case_number }
  let mid = calc.max(0, calc.floor((rows.len() - 2) / 2))
  block(width: 100%, above: caption-above, below: 0pt, breakable: false, grid(
    columns: (caption-left, caption-colon, 1fr),
    line-stack(rows),
    line-stack(rows.map(_ => ":")),
    pad(left: caption-right-inset, top: mid * pitch-single, line-stack(([CIVIL ACTION], [No. #number]))),
  ))
}

#let cover(meta, title) = {
  court-title(meta)
  caption(meta)
  line-stack(above: title-above, (text(weight: "bold", inl(title)),), align: center)
  v(text-above)
}

// ---------------------------------------------------------------------------
// Body blocks
// ---------------------------------------------------------------------------

/// The label of a heading: I. (level 1), A. (level 2), 1. (level 3).
#let heading-label(level, n) = numbering(("I.", "A.", "1.").at(level - 1), n)

/// Headings at the type size on the body pitch, with no space of their own, kept with the next block. Level 1:
/// the label and title centred, bold capitals; level 2: the label in a half-inch box, the title bold, hanging after
/// it; level 3: the same, bold italic. `toc`: the heading goes into the contents.
#let heading-block(level, label, s, toc: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  if toc { [#metadata((level: level, label: label, text: s))<paed-toc>] }
  if level == 1 {
    align(center, par(first-line-indent: 0pt, text(weight: "bold", upper(if label == "" { unloose(inl(s)) } else [#label #unloose(inl(s))]))))
  } else {
    let title = if level == 2 { text(weight: "bold", unloose(inl(s))) }
      else { text(weight: "bold", style: "italic", unloose(inl(s))) }
    par(first-line-indent: 0pt, hanging-indent: heading-box, [#box(width: heading-box, text(weight: "bold", label))#title])
  }
})

/// A numbered item of the order: its number half an inch in, in a box of its own, the text hanging after it (docx:
/// a tab and a hanging indent).
#let item(label, s) = block(width: 100%, above: 0pt, below: 0pt, pad(left: item-indent,
  par(first-line-indent: 0pt, hanging-indent: item-box, [#box(width: item-box, label)#unloose(inl(s))])))

/// A block quotation: single spaced, indented on both sides.
#let quotation(s) = block(width: 100%, above: quote-gap, below: quote-gap, pad(left: quote-inset, right: quote-inset, {
  set text(..edges(pitch-single))
  par(first-line-indent: 0pt, unloose(inl(s)))
}))

/// One markdown section, as a run of blocks: `#` headings (numbered I., A., 1. when `numbered`), `>` quotations,
/// `1.` lists (the order's items), and paragraphs. The last block is set with `closing` in one unbreakable block.
#let render-section(md, closing: none, numbered: false) = {
  let counts = (0, 0, 0)
  let pieces = ()
  for t in chunks(md) {
    if t.starts-with("#") {
      let level = calc.min(t.match(regex("^#+")).end, 3)
      counts.at(level - 1) += 1
      for k in range(level, 3) { counts.at(k) = 0 }
      let label = if numbered { heading-label(level, counts.at(level - 1)) } else { "" }
      pieces.push(heading-block(level, label, t.slice(level).trim(), toc: numbered))
    } else if t.starts-with(">") {
      pieces.push(quotation(t.replace(regex("(?m)^>[ \t]?"), "").replace(regex("\\s*\\n\\s*"), " ")))
    } else if t.match(regex("^\\d+\\.[ \\t]")) != none {
      // one item per "1." line; a line without a number continues the item before it
      let items = ()
      for l in t.split(regex("\\r?\\n")) {
        if l.match(regex("^\\d+\\.[ \\t]")) != none { items.push(l.replace(regex("^\\d+\\.[ \\t]+"), "")) }
        else { items.last() += " " + l.trim() }
      }
      for (k, s) in items.enumerate() { pieces.push(item(str(k + 1) + ".", s)) }
    } else {
      pieces.push(body-par(inl(t)))
    }
  }
  for (i, it) in pieces.enumerate() {
    if i == pieces.len() - 1 and closing != none {
      block(width: 100%, above: 0pt, below: 0pt, breakable: false, { it; closing })
    } else { it }
  }
}

/// A signature column: `first` on the first line, at the left; `lines` (text and space above) from `sig-col`
/// (docx: a tab and a hanging indent), single spaced and kept on one page.
#let sig-lines(first, lines, above) = block(width: 100%, above: above, below: 0pt, breakable: false, {
  set text(..edges(pitch-single))
  for (i, (l, gap)) in lines.enumerate() {
    block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
      [#box(width: sig-col, if i == 0 { first })#unloose(if type(l) == str { inl(l) } else { l })]))
  }
})

/// Counsel's signature: the date at the left; "Respectfully submitted," and each counsel block from `sig-col`.
#let signature-block(meta) = {
  let lines = (("Respectfully submitted,", 0pt),)
  for b in meta.signature.blocks {
    for (i, l) in b.firm.enumerate() { lines.push((l, if i == 0 { sig-gap } else { 0pt })) }
    lines.push(("By: /s/ " + b.signer, sig-gap))
    lines += b.lines.map(l => (l, 0pt))
  }
  sig-lines([Date: #inl(meta.date)], lines, sig-above)
}

/// The proposed order's signature: the court's block (the words are the court's form, not the case's).
#let order-signature() = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(width: 100%, above: 0pt, below: 0pt, pad(left: order-sig-col, par[BY THE COURT:]))
  block(width: 100%, above: order-sig-gap, below: 0pt, pad(left: order-sig-col, par[#("_" * 30) J.]))
})

/// The certificate of service (Local Civil Rules 5.1.2(7)(b), 7.1(d)): heading, text and signature kept together.
#let certificate(meta) = block(width: 100%, above: cert-above, below: 0pt, breakable: false, {
  heading-block(1, "", "Certificate of Service")
  body-par(inl(meta.service.text))
  sig-lines([Date: #inl(meta.service.date)], (("/s/ " + meta.service.signer, 0pt),) + meta.service.lines.map(l => (l, 0pt)),
    sig-above)
})

/// The table of contents: the memorandum's headings (levels 1 to 3), each row single spaced, indented by its level,
/// the label in a box, the page in its own column at the right after a dot leader (listing-row).
#let contents() = {
  block(width: 100%, above: 0pt, below: 0pt, sticky: true,
    align(center, par(first-line-indent: 0pt, text(weight: "bold", "TABLE OF CONTENTS"))))
  context {
    set text(..edges(pitch-single))
    for (i, m) in query(<paed-toc>).enumerate() {
      let lv = m.value.level
      let ind = (lv - 1) * toc-step
      let page = numbering("1", ..counter(page).at(m.location()))
      let title = unloose(inl(m.value.text))
      listing-row(m.location(), { h(ind); box(width: toc-hang, m.value.label); title }, page, toc-col,
        ind + toc-hang, if i == 0 { toc-above } else { toc-gap })
    }
  }
}

// ---------------------------------------------------------------------------
// The filing: order, motion with certificate, memorandum
// ---------------------------------------------------------------------------

// The page number, centred; none where the page numbering is none (the order, the memorandum's cover).
#let footer = context if page.numbering != none { align(center, par(first-line-indent: 0pt,
  text(..edges(pitch-single), counter(page).display()))) }

#let paed-motion-brief(meta, body) = {
  let parts = sections(body)
  for name in ("order", "motion", "memorandum") {
    if name not in parts { panic("paed-motion-brief: the sample needs a <!-- " + name + " --> section") }
  }

  set page(paper: "us-letter", margin: margin, numbering: none, footer-descent: footer-descent, footer: footer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays whole and with its number ("§§ 8340"): typst would break between the signs.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  // 1. Proposed order (Local Civil Rule 7.1(a)); no page number.
  cover(meta, meta.order_title)
  render-section(parts.at("order"), closing: order-signature())

  // 2. Motion and its certificate of service (Local Civil Rules 5.1.2(7)(b), 7.1(d)); arabic page numbers.
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  cover(meta, meta.motion_title)
  render-section(parts.at("motion"), closing: signature-block(meta))
  certificate(meta)

  // 3. Memorandum of law (Local Civil Rule 7.1(c)): its cover (no page number), the table of contents (roman
  //    numbers), then the body (arabic numbers from 1).
  pagebreak()
  set page(numbering: none)
  cover(meta, meta.memo_title)

  pagebreak()
  set page(numbering: "i")
  counter(page).update(1)
  contents()

  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  render-section(parts.at("memorandum"), closing: signature-block(meta), numbered: true)
}
