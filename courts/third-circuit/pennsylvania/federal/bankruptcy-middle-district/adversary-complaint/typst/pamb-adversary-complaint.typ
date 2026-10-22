// U.S. Bankruptcy Court, M.D. Pennsylvania: adversary complaint (Fed. R. Bankr. P. 7001 et seq.).
//
// Rule-driven and content-agnostic. Requirement IDs (PAMB-ADV-...) refer to ../README.md, which quotes
// the rule text (FRBP 7008, 7010, 9004; L.B.R. 7003-1, 9004-1). No case-specific text, no coordinates
// measured off the exemplar, no forced line breaks. The metadata comes from the YAML frontmatter of the sample
// (schema: ../README.md); the body is read chunk by chunk (a blank line apart) and each chunk rendered by cmarker.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a named style choice)
// ---------------------------------------------------------------------------

#let font-family = ("Times New Roman", "Liberation Serif")  // No M.D. Pa. font rule found (../README.md, gaps): the house face, vendored
#let type-size = 12pt                    // FRBP 9004(a): clearly legible; no M.D. Pa. size rule. 12 pt, as the filed papers
#let footer-size = 11pt                  // the page number only
#let margin = 1in                        // style choice (no local margin rule found)
#let text-width = 8.5in - 2 * margin
#let para-indent = 0.5in                 // first-line indent; an allegation's number starts here ...
#let num-box = 0.5in                     // ... in a box this wide: its text starts 1 in in (docx: a tab at 1440)
#let cap-col = text-width / 2            // the caption's party column, ruled at its right and foot ...
#let cap-pad = 14pt                      // ... its text this far from the rule, the case column's as far right of it
#let cap-below = 12pt                    // the space above a rule under a caption row (and below it, in the next row)
#let cap-rule = 0.75pt
#let name-indent = 0.5in                 // the debtor's name lines, indented under "IN RE:"
#let desig-indent = 1.8in                // a party's designation ("Plaintiff")
#let adv-blank = 38                      // a blank adversary number: this many no-break spaces, underlined (1.6 in)
#let sig-col = 3.3in                     // the signature column; "Dated:" sits left of its first line
#let table-char = 6pt                    // a pipe table: a column is half an em per character of its longest cell ...
#let table-slack = 3                     // ... plus this many characters of room
#let table-indent = 1in                  // the table starts this far in

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/pamb.lua sets the same twips: 20 x pt).
#let pitch-body = 24pt                   // double spacing, as the filed complaint (docx 480)
#let pitch-single = 14pt                 // court title, caption, title, signature, footer (docx 280)
#let cover-gap = 24pt                    // court title to caption, caption to title: a blank double line
#let title-below = 12pt                  // the title to the Statement of Jurisdiction
#let sig-above = 24pt                    // the last paragraph to the signature block
#let sig-gap = 24pt                      // inside the signature block: closing to firm, firm to signature
// The footer's single-pitch line box ends half an inch above the bottom edge (docx: footer 720 twips).
#let footer-descent = margin - 0.5in - pitch-single

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

#let need(meta, key) = {
  if key not in meta { panic("pamb-adversary-complaint: missing required metadata field `" + key + "`") }
  meta.at(key)
}

/// Split "---\nyaml\n---\nbody" into (meta, body).
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("pamb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline content without the paragraph breaks cmarker may put around it.
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// Inline markdown.
#let inl(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// A single-pitch line (one paragraph; it wraps on single lines).
#let sline(content, above: 0pt, left: 0pt, align-to: left) = block(width: 100%, above: above, below: 0pt,
  pad(left: left, align(align-to, par(first-line-indent: 0pt, content))))

/// A body paragraph on the double pitch, its first line indented; `label` (a number) in a box `num-box` wide.
#let body-par(label, content, indent: para-indent) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: indent, {
    if label != none { box(width: num-box, label) }
    content
  }))

/// A heading on the body pitch, bold, with no space of its own, kept with the block after it: level 1 centered
/// capitals, other levels at the margin.
#let heading-block(level, body) = block(width: 100%, above: 0pt, below: 0pt, sticky: true,
  if level == 1 { align(center, par(first-line-indent: 0pt, strong(upper(body)))) }
  else { par(first-line-indent: 0pt, strong(body)) })

// ---------------------------------------------------------------------------
// Cover: court title, caption (FRBP 7010; FRCP 10(a); L.B.R. 9004-1 and Official Form 416D), title
// ---------------------------------------------------------------------------

#let court-title(meta) = for l in need(meta, "court") { sline(align-to: center, strong(upper(inl(l)))) }

/// The caption: two rows, each a party column ruled at its right and foot and a case column; the debtor and the
/// bankruptcy case first, then the parties to the adversary proceeding and the adversary number. The rule runs the
/// height of the row; the space above and below a rule is under both columns (LibreOffice takes a cell's margin for
/// the whole row; docx: a two-row table, the left cells bordered).
#let caption-table(meta) = {
  let debtor = need(meta, "debtor")
  let sides = need(meta, "caption")
  let row1-left = {
    sline[IN RE:]
    for (i, n) in debtor.name.enumerate() { sline(inl(n), left: name-indent, above: if i == 0 { pitch-single } else { 0pt }) }
  }
  let row1-right = {
    sline(inl(debtor.chapter))
    sline(above: pitch-single)[Case No. #debtor.case_number]
  }
  let row2-left = {
    for (i, side) in sides.enumerate() {
      for (k, n) in side.names.enumerate() { sline(inl(n), above: if i > 0 and k == 0 { pitch-single } else { 0pt }) }
      sline(inl(side.designation), left: desig-indent)
      if i < sides.len() - 1 { sline(align-to: center, above: pitch-single)[v.] }
    }
  }
  // FRBP 7010 / Form 416D: the adversary number is supplied by the clerk; the blank is printed when none is given.
  let adv = meta.at("adversary_number", default: "")
  let row2-right = sline[Adversary No. #if adv == "" { underline("\u{00A0}" * adv-blank) } else { adv }]
  block(width: 100%, above: cover-gap, below: 0pt, breakable: false, grid(
    columns: (cap-col, 1fr),
    stroke: (x, y) => if x == 0 { (right: cap-rule, bottom: cap-rule) },
    inset: (x, y) => (
      top: if y == 0 { 0pt } else { cap-below },
      bottom: cap-below,
      left: if x == 0 { 0pt } else { cap-pad },
      right: if x == 0 { cap-pad } else { 0pt },
    ),
    row1-left, row1-right, row2-left, row2-right,
  ))
}

#let cover(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  court-title(meta)
  caption-table(meta)
  sline(above: cover-gap, align-to: center, strong(upper(inl(need(meta, "title")))))
  v(title-below)
}

// ---------------------------------------------------------------------------
// Statement of jurisdiction (FRBP 7008(a))
// ---------------------------------------------------------------------------

/// FRBP 7008(a): the jurisdiction allegation names the case (name, number, chapter) and the district, and
/// states whether the proceeding is core or non-core and whether the pleader consents to final orders.
/// The sentence that names the case is generated from the metadata; the core and consent statements are
/// written by the pleader and must be present (the template refuses to build without them).
#let jurisdiction-block(meta) = {
  let j = need(meta, "jurisdiction")
  let debtor = need(meta, "debtor")
  heading-block(1, [Statement of Jurisdiction])
  body-par(none, [This adversary proceeding arises in and relates to the #inl(debtor.chapter) case of #inl(debtor.name.first()), Case No. #debtor.case_number, pending in the United States Bankruptcy Court for the #inl(j.district).])
  body-par(none, inl(need(j, "core")))
  body-par(none, inl(need(j, "consent")))
}

// ---------------------------------------------------------------------------
// Signature block (FRBP 9011; convention: no rule prescribes the layout)
// ---------------------------------------------------------------------------

/// Single lines from `sig-col`: the closing, the firm, "/s/" and the signer, the signer's lines; "Dated:" left of the
/// first line when the frontmatter has a date (docx: a tab and a hanging indent there). Kept on one page.
#let signature-block(meta) = {
  let sig = need(meta, "signature")
  let rows = (([Respectfully submitted,], 0pt), (inl(sig.firm), sig-gap), ([/s/ #inl(sig.signer)], sig-gap),
    (inl(sig.signer), 0pt))
  if "id" in sig { rows.push((inl(sig.id), 0pt)) }
  for l in sig.at("lines", default: ()) { rows.push((inl(l), 0pt)) }
  let date = if "date" in meta and meta.date != none { [Dated: #meta.date] } else { [] }
  block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
    set text(..edges(pitch-single))
    for (i, (r, gap)) in rows.enumerate() {
      block(width: 100%, above: gap, below: 0pt, par(first-line-indent: 0pt, hanging-indent: sig-col,
        [#box(width: sig-col, if i == 0 { date })#r]))
    }
  })
}

// ---------------------------------------------------------------------------
// Body: lead-in, numbered allegations (FRCP 10(b)), the fee table, the prayer
// ---------------------------------------------------------------------------

/// A pipe table, borderless, on the body pitch, `table-indent` in, kept on one page; a column is `table-char` per
/// character of its longest cell plus `table-slack`, aligned as the delimiter row says (docx: the same arithmetic).
#let pipe-table(t) = {
  let row(l) = {
    let s = l.trim()
    if s.starts-with("|") { s = s.slice(1) }
    if s.ends-with("|") { s = s.slice(0, -1) }
    s.split("|").map(c => c.trim())
  }
  let ls = t.split("\n").map(l => l.trim()).filter(l => l != "")
  let aligns = row(ls.at(1)).map(c => if c.ends-with(":") { right } else if c.starts-with(":") { left } else { left })
  let rows = ls.enumerate().filter(((i, l)) => i != 1).map(((i, l)) => row(l))
  let ncol = rows.first().len()
  let chars(c) = c.replace("*", "").clusters().len()
  let widths = range(ncol).map(j => (calc.max(..rows.map(r => chars(r.at(j, default: "")))) + table-slack) * table-char)
  block(width: 100%, above: 0pt, below: 0pt, breakable: false, pad(left: table-indent,
    grid(columns: widths, align: (x, y) => aligns.at(x, default: left),
      ..rows.map(r => range(ncol).map(j => par(first-line-indent: 0pt, inl(r.at(j, default: ""))))).flatten())))
}

/// The number of an allegation chunk ("N. text"), as CommonMark numbers a list: the number written on the first item,
/// one more than the item before on the next; none for any other chunk.
#let item-number(t, last-num) = {
  let li = t.match(regex("^(\\d+)\\.[ \\t]"))
  if li == none { none } else if last-num != none { last-num + 1 } else { int(li.captures.at(0)) }
}

/// One chunk: a heading, a table, an allegation (`num`: the number in a box at the indent, the text after it, the
/// lines below it at the margin), or a paragraph.
#let render-chunk(t, num) = {
  let h = t.match(regex("^(#{1,6})[ \\t]+(.*)$"))
  if h != none {
    heading-block(h.captures.at(0).len(), inl(h.captures.at(1)))
  } else if t.starts-with("|") {
    pipe-table(t)
  } else if num != none {
    body-par(str(num) + ".", inl(t.replace(regex("^\\d+\\.[ \\t]+"), "")))
  } else {
    body-par(none, inl(t))
  }
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let pamb-adversary-complaint(meta, md) = {
  for k in ("court", "debtor", "caption", "title", "jurisdiction", "signature") { let _ = need(meta, k) }

  set page(paper: "us-letter", margin: margin, footer-descent: footer-descent,
    footer: context align(center, text(size: footer-size, ..edges(pitch-single), counter(page).display())))
  set document(title: need(meta, "title"), author: need(meta, "signature").signer)
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§541"; xengine binds a single sign; docx: the same rule).
  show regex("[§¶]{2,} ?\\S+"): it => box(it)

  cover(meta)
  jurisdiction-block(meta)

  // Each chunk in turn, the numbering carried within a list; the last chunk (the prayer) is kept on one page with
  // the signature block, so the signature never stands alone.
  let chunks = md.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let num = none
  for (i, t) in chunks.enumerate() {
    num = item-number(t, num)
    if i + 1 == chunks.len() {
      block(width: 100%, breakable: false, above: 0pt, below: 0pt, {
        render-chunk(t, num)
        signature-block(meta)
      })
    } else {
      render-chunk(t, num)
    }
  }
}
