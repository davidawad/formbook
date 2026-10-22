// Brief in support of a motion to dismiss for the U.S. District Court for the Eastern District of Arkansas (ared).
// Rules: E.D. Ark. Local Rule 7.2(a), (e) (a motion to dismiss is a separate pleading with a separate brief);
// Local Rule 5.5(a) (type not less than elite, double space, letter size, one side) and 5.5(c)(1) (signature
// block); Fed. R. Civ. P. 7(b), 11(a), 12(b)(6). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
// No rule names a font (LR 5.5(a) sets only a minimum); vendored in fonts/, the face of the exemplars.
#let font-family = ("Times New Roman", "Liberation Serif")
#let type-size = 12pt                   // LR 5.5(a): type not less than elite (12 cpi); 12 pt is the working equivalent
#let table-size = 11pt                  // tables only; the exemplar's chart is set smaller than body text (convention)
#let page-w = 8.5in                     // LR 5.5(a): letter size
#let margin = 1in                       // no margin rule in LR 5.5; 1 inch on every side, as in the exemplar
#let text-width = page-w - 2 * margin
#let para-indent = 0.5in                // first-line indent of body paragraphs
#let label-box = 0.5in                  // a level 2 or 3 heading number, or a list number, and the space after it
#let quote-indent = 1in                 // block quotation: indented both sides, single-spaced (convention)
#let caption-left = 3.2in               // width of the party column of the caption
#let caption-gutter = 0.2in             // between the party column and the case number
#let caption-inset = (right: 10pt, bottom: 8pt) // the party column's text stands off its rules
#let case-pad = 0.1in                   // the case number stands off the gutter
#let sig-left = 2.6in                   // the signature block: "Dated:" column, then the signature at right
#let sig-gap = 12pt                     // signature block: between "Respectfully submitted,", the firm and the signer
#let block-gap = 12pt                   // the space above and below a table or a block quotation
#let cell-inset = (x: 3.6pt, y: 1.8pt)  // table cells: the text stands off the rules
#let rule = 0.5pt                       // table rules

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/brief.lua sets the same twips).
#let pitch = 24pt                       // LR 5.5(a): double space (body, headings, court title, title)
#let pitch-single = 13.8pt              // single spacing: caption, block quotations, signature block
#let pitch-table = 12.65pt              // single spacing at the table size

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("ared-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics for case names and signals, for example).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One line block (a paragraph of its own), with an explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, body) = block(width: 100%, above: above, below: below, body)

/// Several single-spaced lines, one paragraph each; an empty item leaves one blank line before the next.
#let lines(items, above: 0pt) = {
  let gap = above
  for s in items {
    if s == "" { gap = pitch-single } else {
      line-block(above: gap, inl(s))
      gap = 0pt
    }
  }
}

/// A list item's body without the paragraph breaks a loose list puts around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

// ---------------------------------------------------------------------------
// Cover: court title, caption, title of the paper (no separate cover page)
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let rows = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE EASTERN DISTRICT OF ARKANSAS")
  if "division" in meta and meta.division != none { rows.push(upper(meta.division)) }
  for r in rows { line-block(align(center, r)) }
}

#let caption(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(above: pitch, below: 0pt, breakable: false, grid(
    columns: (caption-left, caption-gutter, 1fr),
    block(width: caption-left, stroke: (right: 0.75pt, bottom: 0.75pt), inset: caption-inset, {
      // Each party: its names, then its designation; "v." between the parties, a line above and below it.
      for (k, p) in meta.caption.parties.enumerate() {
        if k > 0 { line-block(above: pitch-single, below: pitch-single)[v.] }
        lines(p.names + (p.designation,))
      }
    }),
    [],
    pad(left: case-pad, line-block[Case No. #meta.case_number]),
  ))
  // The title of the paper, centered bold, a blank double-spaced line above and below it.
  set text(..edges(pitch))
  line-block(above: pitch, below: pitch, align(center, text(weight: "bold", inl(meta.brief_title))))
}

// ---------------------------------------------------------------------------
// Body and signature
// ---------------------------------------------------------------------------

/// "Dated:" (when the sample gives a date) at left; at right "Respectfully submitted,", the firm, the "/s/" line
/// and the signer, then the lines. One unbreakable block, a blank double-spaced line above it.
#let signature-block(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  block(above: pitch, below: 0pt, breakable: false, grid(
    columns: (sig-left, 1fr),
    if "date" in meta and meta.date != none { line-block[Dated: #meta.date] },
    {
      line-block[Respectfully submitted,]
      lines(meta.signature.firm, above: sig-gap)
      lines(("/s/ " + meta.signature.signer,) + meta.signature.lines, above: sig-gap)
    },
  ))
}

/// A pipe table: every column the same width, single-spaced at the table size, ruled; the first row is the header
/// (bold); the table is kept on one page. Parsed here so that the columns are the same in every engine
/// (docx/brief.lua writes the same table).
#let pipe-table(t) = {
  let rows = t.split("\n").map(l => l.trim()).filter(l => l != "")
  let cells(l) = l.trim("|").split("|").map(c => c.trim())
  let head = cells(rows.first())
  let body = rows.slice(2).map(cells)
  let n = head.len()
  set text(size: table-size, ..edges(pitch-table))
  set par(first-line-indent: 0pt)
  block(above: block-gap, below: block-gap, breakable: false, table(
    columns: (1fr,) * n,
    inset: cell-inset,
    stroke: rule,
    ..head.map(c => text(weight: "bold", inl(c))),
    ..body.flatten().map(c => inl(c)),
  ))
}

/// Brief body. Unlike a complaint, the paragraphs of a brief are not numbered. Each blank-line-separated
/// chunk of markdown is one of:
///   `# TEXT` ... heading level 1: numbered I., II., ... (a leading <!--unnumbered--> makes it unnumbered, e.g. CONCLUSION)
///   `## TEXT` ... heading level 2: lettered A., B., ...
///   `### TEXT` ... heading level 3: numbered 1., 2., ...
///   `| ... |` ... a pipe table: single-spaced, not indented
///   `> TEXT` ... a block quotation: single-spaced, indented both sides
///   `1. ...` ... a list (numbered (1), (2), ...)
///   anything else ... a body paragraph, double-spaced, first-line indent.
/// Every block is double-spaced with no space of its own except tables and quotations. A heading is a sticky
/// block: it stays on the page with the first lines of the chunk after it. The last paragraph stays with the
/// signature block, so a signature never stands alone on a page. The heading counters are plain variables in
/// this loop; numbers are not typed by the author.
#let brief-body(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let h1 = 0
  let h2 = 0
  let h3 = 0
  for (i, c) in chunks.enumerate() {
    let t = c.trim()
    let last = i == chunks.len() - 1
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      let title = t.slice(level).trim()
      let unnumbered = title.starts-with("<!--unnumbered-->")
      if unnumbered { title = title.slice("<!--unnumbered-->".len()).trim() }
      set par(first-line-indent: 0pt, hanging-indent: if level == 1 { 0pt } else { label-box })
      let heading = if level == 1 {
        if not unnumbered { h1 += 1; h2 = 0; h3 = 0 }
        align(center, par(text(weight: "bold", if unnumbered { upper(inl(title)) } else {
          [#numbering("I.", h1) #upper(inl(title))]
        })))
      } else if level == 2 {
        h2 += 1
        h3 = 0
        par(text(weight: "bold", [#box(width: label-box, numbering("A.", h2))#inl(title)]))
      } else {
        h3 += 1
        par[#box(width: label-box, numbering("1.", h3))#text(weight: "bold", style: "italic", inl(title))]
      }
      block(sticky: true, width: 100%, above: 0pt, below: 0pt, heading)
    } else if t.starts-with("|") {
      pipe-table(t)
    } else if t.starts-with(">") {
      let quoted = t.split("\n").map(l => l.trim().replace(regex("^>\\s?"), "")).join(" ")
      set text(..edges(pitch-single))
      block(above: block-gap, below: block-gap, pad(x: quote-indent, par(first-line-indent: 0pt, inl(quoted))))
    } else if t.starts-with(regex("^\\d+\\.[ \\t]")) {
      show enum: it => {
        let n = if it.start == auto { 1 } else { it.start }
        for (j, item) in it.children.enumerate() {
          if item.has("number") and item.number != none { n = item.number }
          block(sticky: last and j == it.children.len() - 1, above: 0pt, below: 0pt, pad(left: para-indent,
            par(first-line-indent: 0pt, hanging-indent: label-box,
              [#box(width: label-box, numbering("(1)", n))#unloose(item.body)])))
          n += 1
        }
      }
      cmarker.render(t, raw-typst: false, smart-punctuation: true)
    } else {
      block(sticky: last, above: 0pt, below: 0pt, par(inl(t)))
    }
  }
}

#let ared-motion-brief(meta, body) = {
  // Page number centered in the bottom margin, in a single-spaced line box on the baseline of Word's footer (0.3 in
  // footer distance; footer-descent 51 % of the margin).
  set page(
    paper: "us-letter",
    margin: margin,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
    footer-descent: 51%,
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch. Lists are written by brief-body (list-indent: none).
  show: xengine.with(pitch: pitch, list-indent: none)

  court-title(meta)
  caption(meta)

  brief-body(body)

  signature-block(meta)
}
