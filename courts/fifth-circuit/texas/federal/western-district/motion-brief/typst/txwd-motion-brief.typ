// Motion with brief in support, for the U.S. District Court for the Western District of Texas (txwd).
// Rules: W.D. Tex. Local Rule CV-10(a) (12-point or larger type including footnotes, double-spaced, 8½ × 11
// paper with one-inch margins on all sides, case style and descriptive name), CV-10(b) (attorney's address,
// e-mail, signature, state bar card number, telephone and fax); CV-7(a) (a motion must meet CV-10), CV-7(c)(1)
// (authority cited in the motion, not a separate brief), CV-7(c)(2) (20-page limit for other motions, exclusive
// of caption, signature block, certificate); Fed. R. Civ. P. 7(b)(1) (a motion states the grounds with
// particularity). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // CV-10 names no face; Times New Roman (vendored), the exemplar's face
#let type-size = 12pt                   // CV-10(a): 12-point or larger
#let margin = 1in                       // CV-10(a): one-inch margins on all sides
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let quote-indent = 0.5in               // block quotations: indented from both margins
#let list-indent = 0.5in                // lists: the label half an inch in (a nested list a further half inch)
#let list-label = 0.25in                // lists: the box of the label, the text hanging after it
#let caption-left = 3.7in               // party column of the caption
#let caption-mid = 0.3in                // the § column
#let caption-right-inset = 0.2in        // the case column stands off the § column
#let caption-lead = 0.075in             // a caption row's leading space: this much indent
#let signature-indent = 3.2in           // the signature column (the right 3.2 in of the text width)
#let toc-step = 18pt                    // contents: each level steps in 1.5 em
#let toc-page-col = 36pt                // contents: the page numbers keep the last 36 pt of the line to themselves
#let toc-gap = 10.8pt                   // contents: between rows (0.9 em)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-double = 24pt                // CV-10(a): double spaced, 2 x the type size
#let pitch-single = 14.4pt              // single spacing (caption, contents, quotations, signature): 1.2 x the size

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("txwd-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, smart punctuation).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Blank-line-separated chunks of the body.
#let chunks(body) = body.split("\n\n").map(c => c.trim()).filter(c => c != "")

/// One line of a block quote: a markdown quote marker (">") in front of it is dropped.
#let unquote(l) = { let t = l.trim(); if t.starts-with(">") { t.slice(1).trim() } else { t } }

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it. An empty line
/// keeps its height.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below,
  height: if body == "" or body == [] { pitch-single } else { auto }, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the document
// ---------------------------------------------------------------------------

#let court-title(meta) = for line in meta.court {
  line-block(align(center, text(weight: "bold", line)))
}

/// Caption rows: [left] or [left, right], one single-spaced line each, a § in the middle column on every row (the
/// W.D. Tex. convention in the exemplars); the right cell carries the case number. A row's leading spaces become an
/// indent. The caption stands two single lines below the court title and above the title of the document.
#let caption(rows) = block(above: 2 * pitch-single, below: 2 * pitch-single, grid(
  columns: (caption-left, caption-mid, 1fr),
  {
    for r in rows {
      let left = r.at(0)
      let stripped = left.trim(at: start)
      line-block(if stripped == "" { "" } else { [#h((left.len() - stripped.len()) * caption-lead)#inl(stripped)] })
    }
  },
  { for _ in rows { line-block(align(center, [§])) } },
  pad(left: caption-right-inset, { for r in rows { line-block(r.at(1, default: "")) } }),
))

// ---------------------------------------------------------------------------
// Table of contents
// ---------------------------------------------------------------------------

/// One contents row: a step in per level; the page number in its own column, a dot leader before it.
#let toc-entry(it) = {
  let hd = it.element
  let ind = (hd.level - 1) * toc-step
  listing-row(hd.location(), { h(ind); hd.body }, it.page(), toc-page-col, ind, toc-gap)
}

/// The contents, generated from the headings of the body (levels 1 to 3), on a page of their own.
#let contents(meta) = {
  line-block(below: pitch-single, align(center, text(weight: "bold", meta.toc_title)))
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  show outline.entry: toc-entry
  outline(title: none, depth: 3, indent: 0pt)
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs, block quotes, lists
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch with a first-line indent (a motion is not numbered like a complaint: FRCP
/// 10(b) does not apply). `keep`: kept whole on the page of the block after it (the last paragraph stays with the
/// signature block).
#let body-par(content, keep: false) = block(width: 100%, above: 0pt, below: 0pt, sticky: keep,
  breakable: not keep, par(first-line-indent: (amount: para-indent, all: true), content))

/// A block quotation: single-spaced, indented both sides, a single line above and below it (CV-10(a) allows single
/// spacing for quotations more than two lines long).
#let block-quote(c) = block(width: 100%, above: pitch-single, below: pitch-single, pad(x: quote-indent,
  line-block(inl(c.split("\n").map(unquote).join(" ")))))

/// A list chunk: an item per line that starts with "1." or "-" (a continuation line joins the item before it); a
/// nested item (indented in the markdown) steps in a further list indent. Numbers as written, a bullet for "-".
/// Each item at the double pitch, the label in a box of list-label, the text hanging after it.
#let list-chunk(c) = {
  let items = ()
  for l in c.split("\n") {
    let m = l.match(regex("^(\\s*)(\\d+\\.|[-*+])\\s+(.*)$"))
    if m != none {
      let lab = m.captures.at(1)
      items.push((level: if m.captures.at(0).len() > 0 { 1 } else { 0 },
        label: if lab.ends-with(".") { lab } else { "•" }, text: m.captures.at(2)))
    } else if items.len() > 0 {
      items.last().text += " " + l.trim()
    }
  }
  for it in items {
    block(width: 100%, above: 0pt, below: 0pt, pad(left: list-indent * (it.level + 1),
      par(first-line-indent: 0pt, hanging-indent: list-label, [#box(width: list-label, it.label)#inl(it.text)])))
  }
}

#let body-block(body) = {
  let cs = chunks(body)
  for (i, c) in cs.enumerate() {
    let last = i == cs.len() - 1
    if c.starts-with("### ") {
      heading(level: 3, outlined: true, c.slice(4))
    } else if c.starts-with("## ") {
      heading(level: 2, outlined: true, c.slice(3))
    } else if c.starts-with("# ") {
      heading(level: 1, outlined: true, upper(c.slice(2)))
    } else if c.starts-with(">") {
      block-quote(c)
    } else if c.match(regex("^(\\d+\\.|[-*+]) ")) != none {
      list-chunk(c)
    } else {
      body-par(inl(c), keep: last)
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block and certificate: CV-10(b)
// ---------------------------------------------------------------------------

/// In the right 3.2 inches: "Respectfully submitted", the firm lines, "/s/" and the signer, the signer's lines (an
/// empty line keeps its height), a single line between the groups; never broken across a page.
#let signature-block(meta) = {
  let sig = meta.signature
  block(width: 100%, breakable: false, above: pitch-single, below: 0pt, grid(columns: (1fr, signature-indent), [], {
    line-block[Respectfully submitted,]
    for (i, l) in sig.firm.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, l) }
    line-block(above: pitch-single, "/s/ " + sig.signer)
    for l in sig.lines { line-block(l) }
  }))
}

/// Certificate of service: a centered bold heading two single lines below the signature, the paragraph a single line
/// below it at the double pitch, the signer's lines at the right a single line below; kept on one page.
#let certificate-block(cert) = block(width: 100%, breakable: false, above: 2 * pitch-single, below: 0pt, {
  block(width: 100%, above: 0pt, below: pitch-single, {
    set par(first-line-indent: 0pt)
    align(center, text(weight: "bold", inl(cert.heading)))
  })
  block(width: 100%, above: 0pt, below: pitch-single,
    par(first-line-indent: (amount: para-indent, all: true), inl(cert.text)))
  line-block(align(right, inl("/s/ " + cert.signer)))
  for l in cert.lines { line-block(align(right, inl(l))) }
})

// ---------------------------------------------------------------------------
// The document
// ---------------------------------------------------------------------------

#let txwd-motion-brief(meta, body) = {
  // Pages numbered at the foot, centered, arabic from the first; the number in a single-spaced line box, so it sits
  // at the same place on every page (Word's footer).
  set page(paper: "us-letter", margin: margin, header: none, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))))
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (CV-10(a): double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: list-label)
  // A doubled section sign stays with its number ("§§ 16.033"; xengine binds a single sign), as the docx filter
  // binds it.
  show regex("[§¶]{2,} \\S+"): it => box(it)

  // A heading is plain text, as written (its leading "1." is the author's number, not a list).
  // Headings at the body size and pitch, no space of their own (the double pitch sets them off): level 1 centered
  // bold capitals, levels 2 and 3 bold at the margin. Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    block(sticky: true, width: 100%, above: 0pt, below: 0pt,
      align(if it.level == 1 { center } else { left }, text(weight: "bold", it.body)))
  }

  // cover
  court-title(meta)
  caption(meta.caption)
  block(width: 100%, above: 0pt, below: 0pt, {
    set par(first-line-indent: 0pt)
    align(center, text(weight: "bold", inl(meta.title)))
  })

  // table of contents, on its own page
  pagebreak()
  contents(meta)

  // body, from a new page
  pagebreak()
  body-block(body)
  signature-block(meta)
  if "certificate" in meta { certificate-block(meta.certificate) }
}
