// Memorandum in support of a motion for the U.S. District Court for the Northern District of Iowa (iand).
// Rules: N.D. Iowa LR 7(b)(3), (d) (a brief is filed with the motion; the brief states the grounds and cites the
// authorities), 7(h) (20 pages, not counting the table of contents, table of authorities and signature block);
// LR 10(a) (8.5 x 11 inch paper), 10(b) (double spaced, one side, top margin of at least 1 inch, pages numbered
// at the bottom; a brief of more than 10 pages has a subject matter table of contents on its first page),
// 10(d) (caption with district, division, case number, litigants and a designation of the content).
// Fed. R. Civ. P. 12(b)(6). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges, listing-row

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")  // no typeface is named in LR 10; Times New Roman, the house face (vendored in fonts/)
#let type-size = 12pt                   // no size is named in LR 10; 12 point is the usual federal filing size
#let page-w = 8.5in                     // LR 10(a): 8 1/2 by 11 inch
#let page-h = 11in
#let margin = 1in                       // LR 10(b)(3): top margin of at least 1 inch (all sides set to 1 inch)
#let para-indent = 0.5in                // first-line indent of body paragraphs; the paragraph number in a box of it
#let caption-left = 3.1in               // width of the party column of the caption
#let caption-marks = 0.3in              // the column of ")" marks
#let right-inset = 0.15in               // the case-number column stands off the marks
#let list-indent = 0.5in                // lists: the number half an inch in, the text a box after it
#let list-label = 0.4in
#let quote-indent = 0.5in               // block quotations, both sides
#let sig-left = 3.0in                   // the signature block stands 3 inches in
#let toc-step = 18pt                    // contents: a level-2 entry steps in 1.5 em
#let toc-page-col = 36pt                // contents: the page numbers keep the last 36 pt of the line to themselves
#let toc-gap = 6pt                      // contents: between rows

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch = 24pt                       // LR 10(b)(1): double spaced; the baseline pitch of body text
#let pitch-single = 13.8pt              // single spacing (caption, contents, quotations, signature): 1.15 x the size
#let half = pitch / 2                   // around lists, after quotations and service lists, between signature groups

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("iand-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italic case names, etc.).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  if type(body) == str { inl(body) } else { body }
})

// ---------------------------------------------------------------------------
// Caption (LR 10(d))
// ---------------------------------------------------------------------------

/// Court title: centered bold lines (district and division).
#let court-title(meta) = {
  let lines = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF IOWA")
  if "division" in meta { lines.push(upper(meta.division)) }
  for l in lines { line-block(align(center, text(weight: "bold", l))) }
}

/// Caption: the parties on the left, closed by a column of ")" marks (one per line); the case number, the judges and
/// the designation of the paper on the right, each on the single-spaced grid of the party lines.
#let caption(meta) = {
  let rows = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows.push("v.") }
    rows += p.names + (p.designation,)
  }
  block(above: pitch, below: pitch, grid(
    columns: (caption-left, caption-marks, 1fr),
    { for r in rows { line-block(r) } },
    { for _ in rows { line-block(")") } },
    pad(left: right-inset, {
      line-block(meta.at("case_label", default: "No.") + " " + meta.case_number)
      if "judge" in meta { line-block(above: pitch-single, "Judge: " + meta.judge) }
      if "magistrate_judge" in meta { line-block(above: pitch-single, "Magistrate Judge: " + meta.magistrate_judge) }
      line-block(above: 2 * pitch-single, text(weight: "bold", inl(meta.brief_title)))
    }),
  ))
}

// ---------------------------------------------------------------------------
// Table of contents (LR 10(b)(4))
// ---------------------------------------------------------------------------

/// One contents row: a step in for a level-2 heading; the page number in its own column.
#let toc-entry(it) = {
  let hd = it.element
  let ind = (hd.level - 1) * toc-step
  listing-row(hd.location(), { h(ind); hd.body }, it.page(), toc-page-col, ind, toc-gap)
}

/// Subject matter table of contents: the headings of levels 1 and 2 with their pages. Not a heading itself, so it
/// is not listed in its own entries.
#let contents() = {
  line-block(below: pitch, align(center, text(weight: "bold", "TABLE OF CONTENTS")))
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  show outline.entry: toc-entry
  outline(title: none, depth: 2, indent: 0pt)
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// The signature block (a "SIGNATURE" chunk in the markdown places it): the date at the margin, then 3 inches in
/// the party, the firm, "/s/" and the signer with their lines; kept on one page.
#let signature-block(meta) = block(breakable: false, width: 100%, above: pitch, below: pitch, {
  if "date" in meta { line-block(below: pitch, "Dated: " + meta.date) }
  pad(left: sig-left, {
    let sig = meta.signature
    if "party" in sig { for l in sig.party { line-block(l) } }
    for (i, l) in sig.firm.enumerate() { line-block(above: if i == 0 and "party" in sig { half } else { 0pt }, l) }
    line-block(above: half, "/s/ " + sig.signer)
    for l in sig.at("lines", default: ()) { line-block(l) }
  })
})

/// A body paragraph at the double pitch: the first-line indent, then (when numbered, LR 10(b)) the number in a box of
/// the paragraph indent, the text after it.
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true),
    if num == none { content } else { [#box(width: para-indent, [#num.])#content] }))

/// Body chunks (blank-line separated markdown). A chunk is one of:
///   "# ...", "## ...", "### ..."   headings (level 1 centered caps; level 2 bold, flush left; level 3 italic)
///   "<!--SIGNATURE-->"            the signature block
///   "<!--SINGLE--> ..."           single-spaced lines (one per source line), e.g. a service list
///   "<!--NUMBERED--> ..."         a numbered paragraph (LR 10(b)); other paragraphs are not numbered
///   a list                        numbered 1., 2., ... (memorandum lists; not lettered)
///   "> ..."                       a block quotation, single-spaced and indented
///   anything else                 a paragraph with a first-line indent
/// Numbering is applied per chunk, not with a show rule: a show rule that re-wraps paragraph content recurses.
#let body(meta, src) = {
  let n = 0
  for c in src.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "") {
    let t = c.trim()
    if t == "<!--SIGNATURE-->" {
      signature-block(meta)
    } else if t.starts-with("<!--SINGLE-->") {
      let lines = t.slice("<!--SINGLE-->".len()).trim().split("\n").map(l => l.trim()).filter(l => l != "")
      block(width: 100%, above: 0pt, below: half, for l in lines { line-block(l) })
    } else if t.starts-with("#") {
      inl(t)
    } else if t.starts-with(regex("^(\\d+\\.|[-*+])[ \\t]")) {
      block(width: 100%, above: half, below: half, pad(left: list-indent, {
        set par(first-line-indent: 0pt)
        inl(t)
      }))
    } else if t.starts-with(">") {
      pad(left: quote-indent, right: quote-indent, line-block(below: half, inl(t.trim(">").trim())))
    } else if t.starts-with("<!--NUMBERED-->") {
      n += 1
      body-par(n, inl(t.slice("<!--NUMBERED-->".len()).trim()))
    } else {
      body-par(none, inl(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Entry
// ---------------------------------------------------------------------------

#let iand-motion-brief(meta, src) = {
  // Pages numbered at the bottom (LR 10(b)), arabic from the first; the number centered in a single-spaced line box,
  // so it sits at the same place on every page (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display("1"))),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (LR 10(b)(1): double spaced).
  show: xengine.with(pitch: pitch, list-indent: list-label)

  // Headings at the body size and pitch, no space of their own (the double pitch sets them off): level 1 centered
  // bold caps; level 2 bold, flush left; level 3 italic, flush left. Sticky: a heading never ends a page.
  show heading: it => {
    set text(size: type-size)
    set par(first-line-indent: 0pt)
    let b = if it.level == 1 { align(center, text(weight: "bold", upper(it.body))) } else if it.level == 2 {
      text(weight: "bold", it.body)
    } else { text(style: "italic", it.body) }
    block(sticky: true, width: 100%, above: 0pt, below: 0pt, b)
  }

  court-title(meta)
  caption(meta)

  if meta.at("toc", default: false) {
    contents()
    pagebreak()
  }

  body(meta, src)
}
