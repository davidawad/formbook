// Motion to dismiss with brief in support, for the U.S. District Court for the Eastern District of
// Michigan (mied). One document: the motion (numbered 1, 2, ...), the brief's cover (unnumbered), the
// front matter (statement of issues, controlling authorities, contents; roman numerals) and the brief
// (numbered from 1), then the certificate of service.
// Rules: LR 5.1(a) (double spacing, 1-inch margins, 14-point proportional type, page numbers);
// LR 7.1(a) (conferral statement in the motion); LR 7.1(d) (brief contents and the 25-page limit);
// Fed. R. Civ. P. 12(b)(6). See ../README.md for the rule text, its source and the open questions.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or to a named style choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR 5.1(a)(3) names no face (any proportional type, 14 pt); Times New Roman (vendored, docs/FONTS.md), as the filed exemplar
#let type-size = 14pt                   // LR 5.1(a)(3): 14 point for proportional type, footnotes included
#let margin = 1in                       // LR 5.1(a)(2): at least 1 inch, top, bottom and sides
#let page-number-size = 12pt            // page numbers are not text under LR 5.1(a)(3); style choice
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let number-box = 0.5in                 // a numbered issue's number at the indent, the text 1 in from the margin (docx: a tab)
#let bullet-box = 0.25in                // an authority's bullet at the margin, the text hanging after it
#let heading-hang = 0.5in               // a level-2 or level-3 heading's lines after the first hang this far
#let heading3-indent = 0.5in            // a level-3 heading starts half an inch in
#let quote-inset = 0.5in                // a block quotation is indented half an inch on both sides
#let caption-left = 3.3in               // width of the party column of the caption
#let caption-gap = 0.25in               // between the party column's rule and the case number column
#let caption-inset = 10pt               // the party column's text to its right and bottom rules
#let caption-right-inset = 0.1in        // the case number column's left inset
#let designation-indent = 1in           // a party's designation ("Plaintiff,") is set in from the names
#let sig-left = 3.2in                   // the signature block's column starts here; the date sits left of it
#let toc-step = 0.5in                   // a contents row is indented this much per heading level below 1 ...
#let toc-hang = 0.5in                   // ... its lines after the first hang this much further
#let toc-col = 0.5in                    // the page column of the contents

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/mied-motion-brief.lua and docx/reference.xml
// set the same twips: 20 x pt). Double spacing (LR 5.1(a)(2)) is read against Times New Roman's single line box,
// 1.15 em: 16.1 pt single and 32.2 pt double at 14 pt.
#let pitch-body = 32.2pt                // LR 5.1(a)(2): double spaced, headings included
#let pitch-single = 16.1pt              // single spacing: court title, caption, title, quotations, authorities, contents, signature
#let pitch-footer = 13.8pt              // the 12 pt page number's single line
#let caption-above = 32.2pt             // the court title to the caption: one double line
#let title-above = 32.2pt               // the caption to the title of the paper
#let text-above = 16.1pt                // the title to the text: one single line
#let quote-gap = 16.1pt                 // above and below a block quotation
#let toc-above = 32.2pt                 // the contents' title to its first row
#let toc-gap-1 = 16.1pt                 // above a level-1 row of the contents
#let toc-gap = 8.05pt                   // above any other row
#let sig-above = 32.2pt                 // the last paragraph to the signature block
#let sig-gap = 16.1pt                   // "Respectfully submitted," to the firm, the firm to "By: /s/"
// The page number's line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-footer

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("mied-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, emphasis) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Single-spaced lines, one paragraph each; an empty item is a blank single line. An item is a string (markdown),
/// content, or a pair (item, left indent).
#let line-stack(items, above: 0pt) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let g = above
  for i in items {
    let (s, left) = if type(i) == array { i } else { (i, 0pt) }
    if s == "" { g += pitch-single } else {
      block(width: 100%, above: g, below: 0pt,
        pad(left: left, par(unloose(if type(s) == str { inl(s) } else { s }))))
      g = 0pt
    }
  }
}

/// A body paragraph at the body pitch; its first line indented half an inch unless `indent` is false.
#let body-par(content, indent: true) = block(width: 100%, above: 0pt, below: 0pt,
  if indent { par(unloose(content)) } else { par(first-line-indent: 0pt, unloose(content)) })

// ---------------------------------------------------------------------------
// Caption and cover
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "FOR THE EASTERN DISTRICT OF MICHIGAN")
  if "division" in meta { lines.push(upper(meta.division)) }
  align(center, line-stack(lines.map(l => text(weight: "bold", l))))
}

/// The parties single-spaced in a column closed by a rule at its right and foot: each party's names, a blank line,
/// its designation set in; "v." between the parties with a blank line above and below; at the right the case number
/// and the judges.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows += ("", "v.", "") }
    rows += p.names
    rows.push("")
    rows.push((p.designation, designation-indent))
  }
  let right = ("Case No. " + meta.case_number,)
  if "judge" in meta { right.push(meta.judge) }
  if "judges" in meta { right += meta.judges }
  block(width: 100%, above: caption-above, below: 0pt, breakable: false, grid(
    columns: (caption-left, caption-gap, 1fr),
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt),
      inset: (right: caption-inset, bottom: caption-inset), line-stack(rows)),
    [],
    pad(left: caption-right-inset, line-stack(right)),
  ))
}

/// Cover of a paper: court title, caption, title of the paper (bold, centered, single spaced).
#let cover(meta, title) = {
  court-title(meta)
  caption(meta)
  block(width: 100%, above: title-above, below: text-above,
    align(center, line-stack((text(weight: "bold", inl(title)),))))
}

// ---------------------------------------------------------------------------
// Blocks: headings, lists, quotations
// ---------------------------------------------------------------------------

/// Headings at the type size on the body pitch, with no space of their own, kept with the next line. Level 1:
/// centered bold capitals; level 2: bold at the margin; level 3: bold, half an inch in; the lines of a level-2 or
/// level-3 heading after the first hang half an inch. `toc`: the heading goes into the contents.
#let heading-block(level, s, toc: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: true, {
  if toc { [#metadata((level: level, text: s))<mied-toc>] }
  if level == 1 {
    align(center, par(first-line-indent: 0pt, text(weight: "bold", upper(unloose(inl(s))))))
  } else {
    pad(left: if level >= 3 { heading3-indent } else { 0pt },
      par(first-line-indent: 0pt, hanging-indent: heading-hang, text(weight: "bold", unloose(inl(s)))))
  }
})

#let item-re = regex("^(\\d+[.)]|[-*+])[ \\t]+")

/// A list chunk as its items: one per line that starts with a label; a line without one continues the item before.
#let list-items(t) = {
  let items = ()
  for l in t.split("\n").map(l => l.trim()).filter(l => l != "") {
    if l.starts-with(item-re) or items.len() == 0 { items.push(l.replace(item-re, "")) } else { items.last() += " " + l }
  }
  items
}

/// A numbered list (the issues): each item on the body pitch, its number at the indent in a box, the text after it,
/// later lines at the margin (docx: a tab at 1 in). A bulleted list (the authorities): single spaced, the bullet at
/// the margin, the text hanging after it.
#let list-block(t) = {
  let numbered = t.starts-with(regex("^\\d"))
  for (i, item) in list-items(t).enumerate() {
    if numbered {
      body-par[#box(width: number-box)[#(i + 1).]#unloose(inl(item))]
    } else {
      block(width: 100%, above: 0pt, below: 0pt, {
        set text(..edges(pitch-single))
        par(first-line-indent: 0pt, hanging-indent: bullet-box, [#box(width: bullet-box, "\u{2022}")#unloose(inl(item))])
      })
    }
  }
}

/// A block quotation: single spaced, indented on both sides (LR 5.1(a)(2) exempts quotations from double spacing).
#let quotation(s) = block(width: 100%, above: quote-gap, below: quote-gap, pad(left: quote-inset, right: quote-inset, {
  set text(..edges(pitch-single))
  par(first-line-indent: 0pt, unloose(inl(s)))
}))

/// The chunks of a markdown part: a `#` heading, a `>` quotation, a list, or a paragraph (indented, except the one
/// right after a quotation, which goes on with the sentence the quotation interrupted). `front`: a level-1 heading
/// opens a page; `toc`: the headings go into the contents.
#let chunks-of(s) = s.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "" and not c.starts-with("<!--"))
#let blocks(chunks, front: false, toc: false) = {
  let after-quote = false
  for t in chunks {
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      if front and level == 1 { pagebreak(weak: true) }
      heading-block(calc.min(level, 3), t.slice(level).trim(), toc: toc)
      after-quote = false
    } else if t.starts-with(">") {
      quotation(t.replace(regex("(?m)^>[ \t]?"), "").replace("\n", " "))
      after-quote = true
    } else if t.starts-with(item-re) {
      list-block(t)
      after-quote = false
    } else {
      body-par(inl(t), indent: not after-quote)
      after-quote = false
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block, certificate, contents
// ---------------------------------------------------------------------------

/// Signature block, single spaced and kept on one page: the date (when given) at the left of the first line; from `sig-left`
/// "Respectfully submitted,", the firm, "By: /s/" and the signer, then the signer's lines (docx: a tab and a
/// hanging indent there).
#let signature-block(meta) = {
  let sig = meta.signature
  let lines = (("Respectfully submitted,", 0pt),)
  let firm = sig.at("firm", default: ())
  for (i, l) in firm.enumerate() { lines.push((l, if i == 0 { sig-gap } else { 0pt })) }
  lines.push(("By: /s/ " + sig.signer, sig-gap))
  lines.push((sig.signer, 0pt))
  lines += sig.lines.map(l => (l, 0pt))
  block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
    set text(..edges(pitch-single))
    for (i, (l, gap)) in lines.enumerate() {
      block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-left,
        [#box(width: sig-left, if i == 0 and "date" in meta [Dated: #inl(meta.date)])#unloose(inl(l))]))
    }
  })
}

/// The certificate of service: its heading opens a page; its first paragraph is the certification, the paragraphs
/// after it its signature lines, single spaced from `sig-left`.
#let certificate(chunks) = {
  pagebreak(weak: true)
  heading-block(1, "CERTIFICATE OF SERVICE")
  let paras = chunks
  if paras.len() > 0 { blocks(paras.slice(0, 1)) }
  if paras.len() > 1 {
    block(width: 100%, above: sig-above, below: 0pt, breakable: false,
      line-stack(paras.slice(1).map(p => (p, sig-left))))
  }
}

/// The table of contents: the body headings (levels 1 to 3), each row single spaced, indented by its level, the
/// page in its own column at the right with a dot leader to it (listing-row).
#let contents() = {
  pagebreak(weak: true)
  heading-block(1, "Table of Contents")
  context {
    set text(..edges(pitch-single))
    for (i, m) in query(<mied-toc>).enumerate() {
      let lv = m.value.level
      let ind = (lv - 1) * toc-step
      let page = numbering("1", ..counter(page).at(m.location()))
      let title = if lv == 1 { upper(unloose(inl(m.value.text))) } else { unloose(inl(m.value.text)) }
      listing-row(m.location(), { h(ind); title }, page, toc-col, ind + toc-hang,
        if i == 0 { toc-above } else if lv == 1 { toc-gap-1 } else { toc-gap })
    }
  }
}

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

// The page number, 12 pt, centred; none on the brief's cover (numbering none).
#let footer = context if page.numbering != none { align(center, par(first-line-indent: 0pt,
  text(size: page-number-size, ..edges(pitch-footer), counter(page).display()))) }

#let mied-motion-brief(meta, body) = {
  set page(paper: "us-letter", margin: margin, numbering: "1", footer-descent: footer-descent, footer: footer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. Lists are laid out here (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  // Split the markdown at its markers: <!-- brief --> starts the brief, <!-- body --> starts the numbered text,
  // <!-- toc --> places the contents, and the CERTIFICATE OF SERVICE heading closes the body (it is not in the
  // contents).
  let parts = body.split("<!-- brief -->")
  let motion = chunks-of(parts.at(0))
  let brief = parts.slice(1).join("<!-- brief -->")
  let front-body = brief.split("<!-- body -->")
  let front-toc = front-body.at(0).split("<!-- toc -->")
  let main = chunks-of(front-body.slice(1).join("<!-- body -->"))
  let ci = main.position(c => c.match(regex("^#[ \t]+CERTIFICATE OF SERVICE[ \t]*$")) != none)
  let argument = if ci == none { main } else { main.slice(0, ci) }
  let cert = if ci == none { () } else { main.slice(ci + 1) }

  // The motion: its own cover, the motion and the conferral statement, then the signature block (one unbreakable
  // block; the conferral paragraph may break across the page before it, as filed).
  cover(meta, meta.motion_title)
  blocks(motion)
  signature-block(meta)

  // The brief's cover: unnumbered; the page count restarts from here (the cover is i).
  pagebreak()
  set page(numbering: none)
  counter(page).update(1)
  cover(meta, meta.brief_title)

  // Front matter: roman numerals from ii; each level-1 section opens a page.
  pagebreak()
  set page(numbering: "i")
  blocks(chunks-of(front-toc.at(0)), front: true)
  if front-toc.len() > 1 {
    contents()
    blocks(chunks-of(front-toc.slice(1).join("<!-- toc -->")), front: true)
  }

  // The brief: arabic numerals from 1; the last paragraph kept with the signature.
  pagebreak()
  set page(numbering: "1")
  counter(page).update(1)
  blocks(argument.slice(0, -1), toc: true)
  block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
    blocks(argument.slice(-1), toc: true)
    signature-block(meta)
  })

  if ci != none { certificate(cert) }
}
