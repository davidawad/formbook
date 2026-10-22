// Complaint for the U.S. District Court for the District of Oregon (ord).
// Rules: LR 10-1 (double spacing, 12-point minimum for all typewritten material including footers, one-inch margins,
// no page numbers down the left margin, footer with a description and consecutive page numbers); LR 10-2 (counsel
// information upper left, court title centered, party names, case number at the center of the page, title);
// Fed. R. Civ. P. 8 and 10(a)-(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // no rule names a face; Times New Roman (vendored, docs/FONTS.md), as both filed exemplars
#let type-size = 12pt                   // LR 10-1(c): no smaller than 12 point, the footer included
#let page-w = 8.5in                     // 8 1/2 by 11 inch paper (LR 10-1(f)(1))
#let margin = 1in                       // LR 10-1(d): one inch on all four sides
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                // first-line indent of every body paragraph
#let number-box = 0.5in                 // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let list-indent = 0.5in                // a list item's letter starts half an inch in ...
#let letter-box = 0.4in                 // ... in a box of its own; the text hangs 0.9 in from the margin
#let quote-inset = 0.5in                // a block quotation is indented half an inch on both sides
#let caption-split = text-width / 2     // LR 10-2(f): the case number starts at the center of the page
#let caption-gap = 0.3in                // between the party column and the center line
#let sig-col = 3.1in                    // the signature's right column starts here; the date sits left of it
#let table-char = 6pt                   // a pipe table: a column is half an em per character of its longest cell ...
#let table-slack = 3                    // ... plus this many characters of room
#let table-inset = 5pt                  // cell padding (docx: 100 twips), 0.5 pt rules

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/complaint.lua and docx/reference.xml set the
// same twips: 20 x pt).
#let pitch-body = 24pt                  // LR 10-1(b): double-spaced; 27 lines fill the 9-inch text height
#let pitch-single = 13.8pt              // single spacing (LR 10-1(b) exceptions): counsel, caption, title, quotations, table, signature, footer
#let counsel-below = 1in                // LR 10-2(b): the court title at least one inch below the counsel information
#let caption-above = 12pt               // the court title to the caption
#let title-above = 24pt                 // LR 10-2(g): the title at least two lines below the case number
#let demand-above = 12pt                // the title to the jury demand
#let text-above = 24pt                  // the caption to the text
#let quote-gap = 12pt                   // above and below a block quotation
#let table-space = 12pt                 // above and below a table
#let sig-above = 24pt                   // the last paragraph to the signature block
#let sig-by-gap = 12pt                  // the firm to the "By: /s/" line
// LR 10-1(e)(1): the footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ord-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (for names with *et al.*, section symbols, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Single-spaced lines, one paragraph each; an empty item is a blank single line. `above`: the space before the
/// first line. An item is a string (markdown) or content.
#let line-stack(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let g = above
  for i in items {
    if i == "" { g += pitch-single } else {
      block(width: 100%, above: g, below: 0pt, par(unloose(if type(i) == str { inl(i) } else { i })))
      g = 0pt
    }
  }
}

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content, above: 0pt) = block(width: 100%, above: above, below: 0pt, par(unloose(content)))

// ---------------------------------------------------------------------------
// Cover: counsel (upper left, LR 10-2(a)), court title, caption, title of the paper
// ---------------------------------------------------------------------------

/// LR 10-2(b): the court title capitalized, centered and double-spaced, at least one inch below the counsel lines.
#let court-title(meta) = {
  let lines = meta.court.map(upper)
  if "division" in meta and meta.division != none { lines.push(upper(meta.division)) }
  for (i, l) in lines.enumerate() {
    block(width: 100%, above: if i == 0 { counsel-below } else { 0pt }, below: 0pt,
      align(center, par(first-line-indent: 0pt, text(weight: "bold", l))))
  }
}

/// The caption: the parties single-spaced at the left margin (LR 10-2(d)), "vs." between them; from the page center
/// the case number on the line of the first plaintiff (LR 10-2(f); a blank for the clerk when the sample has none),
/// the title of the paper in capitals, single-spaced (LR 10-2(g)), and the jury demand.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("vs.") }
    rows += p.names + (p.designation,)
  }
  let number = if "case_number" in meta and meta.case_number != none and meta.case_number != "" { meta.case_number } else { "________________" }
  block(width: 100%, above: caption-above, below: 0pt, breakable: false, grid(
    columns: (caption-split - caption-gap, caption-gap, 1fr),
    line-stack(rows),
    [],
    {
      line-stack(("Case No. " + number,))
      line-stack(above: title-above, (text(weight: "bold", inl(upper(meta.brief_title))),))
      if "jury_demand" in meta and meta.jury_demand {
        line-stack(above: demand-above, (text(weight: "bold", "DEMAND FOR JURY TRIAL"),))
      }
    },
  ))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// Headings at the type size on the body pitch, with no space of their own, kept with the block after them: level 1
/// centered bold capitals; level 2 centered bold; level 3 bold italic.
#let heading-block(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  set align(center) if level <= 2
  par(first-line-indent: 0pt, if level == 1 { text(weight: "bold", upper(unloose(inl(s)))) }
    else if level == 2 { text(weight: "bold", unloose(inl(s))) }
    else { text(weight: "bold", style: "italic", unloose(inl(s))) })
})

/// A block quotation, single-spaced and indented on both sides (LR 10-1(b) exempts quotations from double spacing).
#let quotation(s) = block(width: 100%, above: quote-gap, below: quote-gap, pad(left: quote-inset, right: quote-inset, {
  set text(..edges(pitch-single))
  par(first-line-indent: 0pt, unloose(inl(s)))
}))

/// A lettered item ((a), (b), ...; LR 10-1 has no list rule, the letters keep the classes and the prayer citable):
/// the letter half an inch in, the text hanging after its box (docx: Lettered).
#let lettered(i, s) = block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent,
  par(first-line-indent: 0pt, hanging-indent: letter-box,
    [#box(width: letter-box, "(" + str.from-unicode(96 + i) + ")")#unloose(inl(s))])))

/// A pipe table, unnumbered, single-spaced with 0.5 pt rules, half an inch in, kept on one page. A column is
/// `table-char` per character of its longest cell plus `table-slack` (docx/complaint.lua does the same arithmetic).
#let pipe-table(t) = {
  let row(l) = {
    let s = l.trim()
    if s.starts-with("|") { s = s.slice(1) }
    if s.ends-with("|") { s = s.slice(0, -1) }
    s.split("|").map(c => c.trim())
  }
  let lines = t.split("\n").map(l => l.trim()).filter(l => l != "")
  let rows = lines.enumerate().filter(((i, l)) => i != 1).map(((i, l)) => row(l))
  let ncol = rows.first().len()
  let chars(c) = c.replace("*", "").clusters().len()
  let widths = range(ncol).map(j => (calc.max(..rows.map(r => chars(r.at(j, default: "")))) + table-slack) * table-char)
  v(table-space)
  block(width: 100%, above: 0pt, below: 0pt, breakable: false, pad(left: para-indent, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    table(columns: widths, inset: table-inset, stroke: 0.5pt, align: left,
      ..rows.map(r => range(ncol).map(j => unloose(inl(r.at(j, default: ""))))).flatten())
  }))
  v(table-space)
}

/// The signature block (Fed. R. Civ. P. 11(a)), single-spaced: "DATED:" and the date at the left of the first line;
/// the firm, "By: /s/" with the signer and the signer's lines in a column from `sig-col` (docx: a tab and a hanging
/// indent there).
#let signature-block(meta) = {
  let sig = meta.signature
  let lines = sig.firm.map(l => (l, 0pt))
  lines.push(("By: /s/ " + sig.signer, sig-by-gap))
  lines += sig.lines.map(l => (l, 0pt))
  block(width: 100%, above: sig-above, below: 0pt, {
    set text(..edges(pitch-single))
    for (i, (l, gap)) in lines.enumerate() {
      block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
        [#box(width: sig-col, if i == 0 [DATED: #meta.date])#unloose(inl(l))]))
    }
  })
}

/// The body. Each blank-line-separated chunk of markdown is one of: a `#` heading (levels 1 to 3), a `>` block
/// quotation (unnumbered), a `-` list (each item lettered (a), (b), ...), a `|` table (unnumbered), or a paragraph,
/// numbered 1, 2, ... (Fed. R. Civ. P. 10(b)). `n`: the paragraphs numbered before. Returns (content, n).
#let item-re = regex("^[-*+][ \\t]+")
#let allegations(chunks, n) = {
  let out = []
  for t in chunks {
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      out += heading-block(calc.min(level, 3), t.slice(level).trim())
    } else if t.starts-with(">") {
      out += quotation(t.replace(regex("(?m)^>[ \t]?"), ""))
    } else if t.starts-with("|") {
      out += pipe-table(t)
    } else if t.starts-with(item-re) {
      // One item per line that starts with a label; a line without one continues the item before it.
      let items = ()
      for l in t.split("\n").map(l => l.trim()).filter(l => l != "") {
        if l.starts-with(item-re) or items.len() == 0 { items.push(l.replace(item-re, "")) } else { items.last() += " " + l }
      }
      for (i, item) in items.enumerate() { out += lettered(i + 1, item) }
    } else {
      n += 1
      out += body-par[#box(width: number-box)[#n.]#unloose(inl(t))]
    }
  }
  (out, n)
}

#let ord-complaint(meta, body) = {
  set page(
    paper: "us-letter",
    margin: margin,
    // LR 10-1(e)(1): a footer on every page with a brief description of the document and the page number, 12 pt.
    footer-descent: footer-descent,
    footer: context par(first-line-indent: 0pt, text(..edges(pitch-single),
      [#upper(meta.footer_title) - #counter(page).display()])),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  line-stack(meta.counsel)
  court-title(meta)
  caption(meta)
  v(text-above)
  if "lead_in" in meta { body-par(inl(meta.lead_in)) }

  // The last paragraph (or, when the body ends in a list, its last item) stays on the page with the signature block:
  // a signature never starts a page alone.
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let tail = chunks.last()
  let k = 0
  if tail.starts-with(item-re) {
    let starts = tail.matches(regex("(?m)^[-*+][ \\t]+"))
    k = starts.len() - 1
    if k > 0 { chunks = chunks.slice(0, -1) + (tail.slice(0, starts.last().start).trim(), tail.slice(starts.last().start)) }
  }
  let (main, n) = allegations(chunks.slice(0, -1), 0)
  main
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    if k > 0 { lettered(k + 1, chunks.last().replace(item-re, "")) } else { allegations(chunks.slice(-1), n).at(0) }
    signature-block(meta)
  })
}
