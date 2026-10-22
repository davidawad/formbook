// U.S. Bankruptcy Court, Eastern District of Washington: motion with memorandum of authorities.
//
// Rule-driven and content-agnostic. Requirement IDs (WAEB-MB-...) refer to ../README.md.
// No case-specific text, no coordinates measured off any filed memorandum, no forced
// line breaks. The markdown body is rendered by cmarker; the metadata comes from the
// YAML frontmatter of the same file (schema: ../README.md, "Markdown contract").

#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (the only numbers in this file; each traces to a rule or a style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")          // WAEB-MB-FORM-001: proportionally spaced serif. Vendored in /fonts.
#let type-size = 14pt                      // WAEB-MB-FORM-001: 14 points or more, everywhere (LBR 9004-1(a)(3)).
#let page-margin = 1in                     // WAEB-MB-FORM-004: letter paper; the rules give no margin, 1 inch is used.
#let text-width = 8.5in - 2 * page-margin
#let footer-distance = 0.5in               // the footer's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                   // WAEB-MB-BODY-002: first-line indent of a paragraph; the number starts here.
#let number-box = 0.5in                    // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let letter-box = 0.5in                    // a list item's label box after the indent; the text hangs after it
#let heading-box = 0.5in                   // a level 2 heading's letter box at the margin; the text hangs after it
#let counsel-gutter = 0.3in                // between two counsel groups set side by side
#let caption-left = 3.7in                  // the caption's party column, its rule included ...
#let caption-gutter = 0.3in                // ... the space after the rule ...
#let caption-right = text-width - caption-left - caption-gutter  // ... and the case column (2.5 in)
#let caption-pad = 0.15in                  // the party column's text to its rule
#let caption-foot = 9pt                    // the party column's last line to the rule under it
#let caption-case-pad = 0.1in              // the case column's text off its left edge
#let designation-indent = 1.5in            // "Debtors.", "Plaintiffs," ...
#let versus-indent = 0.8in                 // "v." between the parties
#let rule = 0.75pt                         // the caption's rules (docx: w:sz 6, eighths of a point)
#let sig-left = 3.0in                      // the signature column: firm, /s/ line and the names under it
#let table-slack = 1                       // an exhibit table: characters of room added to a column's longest cell ...
#let table-char = 7pt                      // ... at this much a character (the last column takes the rest)
#let table-inset = 5pt                     // ... cell padding (docx: 100 twips), 0.5 pt rules
// WAEB-MB-CAP-001: the court's own title, the same on every filing (FRCP 10(a) as applied by FRBP 7010).
#let court-title = ("UNITED STATES BANKRUPTCY COURT", "EASTERN DISTRICT OF WASHINGTON")

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/waeb.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 28pt                     // WAEB-MB-FORM-002: double spacing at 14 pt (LBR 9004-1(a)(3)): body, headings, footnotes
#let pitch-single = 16.1pt                 // single spacing: counsel, court title, caption, signature, exhibit tables, footer
#let block-gap = 16.1pt                    // a blank single line: counsel to court title, court title to caption, inside the caption
#let cover-below = 28pt                    // the caption to the text
#let sig-above = 28pt                      // the conclusion to the signature block
#let note-clearance = 12pt                 // the text to the footnote rule (at 8 pt typst 0.15 set the first part of a note
                                           // that runs over a page end before its reference line, which then moved on)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

/// Render an inline markdown string (italics etc.) as inline content.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Plain text of a piece of content, for comparisons and metadata only.
#let plain(c) = {
  if type(c) == str { c }
  else if c == [] { "" }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(plain).join() }
  else if c.has("body") { plain(c.body) }
  else if c.func() == [ ].func() { " " }
  else { "" }
}

#let need(meta, key) = {
  if key not in meta { panic("waeb-motion-brief: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("waeb-motion-brief: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// One single-pitch paragraph with an explicit space above it; `left` indents every line.
#let sline(above: 0pt, left: 0pt, centered: false, flush-right: false, c) = block(width: 100%, above: above, below: 0pt, {
  set text(..edges(pitch-single))
  set align(center) if centered
  set align(right) if flush-right
  pad(left: left, par(first-line-indent: 0pt, unloose(c)))
})

/// A body-pitch paragraph (no space of its own).
#let bpar(sticky: false, indent: 0pt, hang: 0pt, c) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky,
  par(first-line-indent: (amount: indent, all: true), hanging-indent: hang, unloose(c)))

// ---------------------------------------------------------------------------
// First page: counsel block, court title, caption (LBR 9004-1(a)(4)-(6), FRCP 10(a))
// ---------------------------------------------------------------------------

/// Counsel block, upper left, single-spaced (WAEB-MB-CAP-002: attorney name, address and
/// telephone "on the left side above line five" in LBR 9004-1(a)(6)). `counsel` is one list of
/// lines, or a list of groups (one group per firm), which then sit in side-by-side columns so the
/// caption stays on page 1.
#let counsel-block(meta) = {
  let c = need(meta, "counsel")
  let groups = if type(c.first()) == array { c } else { (c,) }
  let n = groups.len()
  let col = (text-width - (n - 1) * counsel-gutter) / n
  block(width: 100%, above: 0pt, below: 0pt, grid(
    columns: range(n).map(_ => col), column-gutter: counsel-gutter,
    ..groups.map(g => g.map(l => sline(inl(l))).join())
  ))
}

/// The judge's name (optional), at the right margin, then the court title: on or below the fifth line
/// (WAEB-MB-CAP-003: LBR 9004-1(a)(4)).
#let court-heading(meta) = {
  if "judge" in meta { sline(above: block-gap, flush-right: true, inl(meta.judge)) }
  block(width: 100%, above: block-gap, below: 0pt, {
    for line in court-title { sline(centered: true, text(weight: "bold", line)) }
  })
}

/// Caption: debtors and parties on the left; case numbers, adversary number, title and jury
/// demand on the right (WAEB-MB-CAP-004: LBR 9004-1(a)(5)(A)-(D)). `parties` entries may set
/// `joiner` (default "v."), e.g. "and" before an intervenor. The party column carries a rule at
/// its right and at its foot (docx: the cell's borders).
#let caption(meta) = {
  let in-re = need(meta, "in_re")
  let parties = need(meta, "parties")
  let left = {
    sline[In re:]
    for (i, n) in in-re.enumerate() {
      // the last line is the debtors' designation ("Debtors."), set as the parties' designations are
      sline(left: if i == in-re.len() - 1 and i > 0 { designation-indent } else { 0pt }, inl(n))
    }
    for (i, p) in parties.enumerate() {
      if i > 0 { sline(above: block-gap, left: versus-indent, inl(p.at("joiner", default: "v."))) }
      for (j, n) in p.names.enumerate() { sline(above: if j == 0 { block-gap } else { 0pt }, inl(n)) }
      sline(left: designation-indent, inl(p.designation))
    }
  }
  let right = {
    let case-no = need(meta, "case_no")
    for line in (if type(case-no) == array { case-no } else { (case-no,) }) { sline(inl(line)) }
    sline(above: block-gap, text(weight: "bold", inl(need(meta, "title"))))
    if meta.at("jury_demand", default: false) { sline(above: block-gap)[DEMAND FOR JURY TRIAL] }
  }
  block(width: 100%, above: block-gap, below: 0pt, breakable: false, grid(
    columns: (caption-left, caption-gutter, caption-right),
    grid.cell(inset: (right: caption-pad, bottom: caption-foot), stroke: (right: rule, bottom: rule), left),
    [],
    grid.cell(inset: (left: caption-case-pad), right),
  ))
}

// ---------------------------------------------------------------------------
// Body: numbered paragraphs, headings, lettered lists, unnumbered centered lines, exhibit tables
// ---------------------------------------------------------------------------

/// Split the markdown body into blank-line-separated chunks.
#let chunks(md) = md.split(regex("\n\\s*\n")).map(s => s.trim()).filter(s => s != "")

/// A pipe table (an exhibit), single-spaced with 0.5 pt rules across the text width. A column is `table-char` per
/// character of its longest cell (emphasis marks not counted) plus `table-slack`; the last column takes the rest
/// (docx/waeb.lua does the same arithmetic). The header row is bold and is not repeated; rows do not split.
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
  let widths = range(ncol - 1).map(j => (calc.max(..rows.map(r => chars(r.at(j, default: "")))) + table-slack) * table-char)
  widths.push(text-width - widths.sum(default: 0pt))
  block(width: 100%, above: 0pt, below: 0pt, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    table(columns: widths, inset: table-inset, stroke: 0.5pt, align: left,
      ..rows.enumerate().map(((i, r)) => range(ncol).map(j => {
        let c = unloose(inl(r.at(j, default: "")))
        if i == 0 { text(weight: "bold", c) } else { c }
      })).flatten())
  })
}

/// Body of the memorandum. Every chunk is one of:
///   `# Heading`        centered bold caps (no number); `# EXHIBIT ...` starts a new page.
///   `## Heading`       lettered A., B., ... (counter restarts under each `#` heading).
///   `**Line**`         unnumbered, centered bold line.
///   `- item` lines     lettered (a), (b), ...
///   `| table |`        a markdown table.
///   `~ text`           an unnumbered paragraph, first line indented (the opening paragraph, the CONCLUSION lead-in).
///   anything else      a numbered paragraph (WAEB-MB-BODY-001): numbered 1, 2, ... by the template.
/// Every block is on the body pitch with no space of its own; headings and `~` paragraphs keep with what follows
/// (docx: keepNext).
#let memorandum-body(md) = {
  let para-n = 0
  let sub-n = 0
  for c in chunks(md) {
    let hd = c.match(regex("^(#{1,2})\\s+([\\s\\S]*)$"))
    let bold = c.match(regex("^\\*\\*([^*]+)\\*\\*$"))
    let lines = c.split("\n")
    if hd != none {
      let lvl = hd.captures.at(0).len()
      let t = hd.captures.at(1).trim()
      if lvl == 1 {
        sub-n = 0
        if t.starts-with("EXHIBIT") { pagebreak(weak: true) }
        block(width: 100%, above: 0pt, below: 0pt, sticky: true,
          align(center, par(first-line-indent: 0pt, text(weight: "bold", unloose(inl(t))))))
      } else {
        sub-n += 1
        bpar(sticky: true, hang: heading-box,
          text(weight: "bold", [#box(width: heading-box, numbering("A.", sub-n))#unloose(inl(t))]))
      }
    } else if bold != none {
      block(width: 100%, above: 0pt, below: 0pt, sticky: true,
        align(center, par(first-line-indent: 0pt, text(weight: "bold", unloose(inl(bold.captures.at(0)))))))
    } else if lines.all(l => l.starts-with("- ")) {
      for (i, item) in lines.enumerate() {
        bpar(hang: para-indent + letter-box,
          [#h(para-indent)#box(width: letter-box, numbering("(a)", i + 1))#unloose(inl(item.slice(2)))])
      }
    } else if c.starts-with("|") {
      pipe-table(c)
    } else if c.starts-with("~ ") {
      bpar(sticky: true, indent: para-indent, inl(c.slice(2)))
    } else {
      para-n += 1
      bpar(indent: para-indent, [#box(width: number-box, numbering("1.", para-n))#unloose(inl(c))])
    }
  }
}


// ---------------------------------------------------------------------------
// Signature block (WAEB-MB-SIG-001: FRBP 9011(a), name typed under each signature line;
// address and telephone of each signer; LBR 9004-1(a)(4))
// ---------------------------------------------------------------------------

/// The date at the margin on the body pitch, then one block per firm in the signature column from `sig-left`,
/// single-spaced: the firm, a blank line, "By /s/" and the signer's lines (a block without `signer` is typed names
/// only); blocks a blank line apart. The date and every block stay together on one page: a date alone at the foot of
/// a page is not a signature (docx: keepNext on every line but the last).
#let signature-block(meta) = {
  let s = need(meta, "signature")
  block(breakable: false, above: sig-above, below: 0pt, width: 100%, {
    block(width: 100%, above: 0pt, below: 0pt, par(first-line-indent: 0pt, inl(s.date)))
    set text(..edges(pitch-single))
    for b in s.blocks {
      sline(above: block-gap, left: sig-left, inl(b.firm))
      if "signer" in b { sline(above: block-gap, left: sig-left)[By /s/ #unloose(inl(b.signer))] }
      for line in b.lines { sline(left: sig-left, inl(line)) }
    }
  })
}

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

#let motion-brief(meta, md) = {
  for k in ("in_re", "parties", "case_no", "title", "counsel", "signature") { let _ = need(meta, k) }

  set document(
    title: plain(inl(need(meta, "title"))),
    author: need(meta, "signature").blocks.first().at("signer", default: ""),
  )
  // WAEB-MB-FOOT-001 (LBR 9004-1(a)(7)): bottom left, the abbreviated name of the document, a 1 em space and the page
  // number, in a single-pitch line box that ends `footer-distance` above the page edge.
  set page(
    paper: "us-letter", margin: page-margin,
    footer-descent: page-margin - footer-distance - pitch-single,
    footer: context align(left, text(..edges(pitch-single),
      [#upper(meta.at("footer_title", default: "MEMORANDUM"))#h(1em)#counter(page).display()])),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: 0pt)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, footnote marks at 58 %, a section sign kept with its number. Lists are laid out here (list-indent:
  // none).
  show: xengine.with(pitch: pitch-body, list-indent: none)
  set heading(numbering: none)
  // Footnotes at the type size and double-spaced (LBR 9004-1(a)(3): "footnotes shall be double-spaced"), a short
  // rule above them (docx: Footnote Text in 28 pt line boxes).
  set footnote.entry(gap: 0pt, clearance: note-clearance, indent: 0pt, separator: line(length: 30%, stroke: 0.5pt))
  show footnote.entry: it => {
    set text(size: type-size, ..edges(pitch-body))
    set par(first-line-indent: 0pt, hanging-indent: 0pt, leading: 0pt)
    let note = it.note
    let num = numbering(note.numbering, ..counter(footnote).at(note.location()))
    [#super(num)#h(0.25em)#note.body]
  }

  // ---- first page ----
  counsel-block(meta)
  court-heading(meta)
  caption(meta)
  v(cover-below)

  // ---- body, then the signature block ----
  memorandum-body(md)
  signature-block(meta)
}
