// Adversary complaint for the United States Bankruptcy Court, Southern District of Iowa (iasb).
// Rules (primary sources, verified 2026-10-14; see ../README.md):
//   Fed. R. Bankr. P. 7010: Fed. R. Civ. P. 10 applies, and the caption must substantially conform to Official Form 416D.
//   Fed. R. Bankr. P. 7008: the jurisdiction allegation names the bankruptcy case (name, number, Code chapter), the district
//     and the division, and the complaint must state whether the pleader consents to final orders by the bankruptcy court.
//   Fed. R. Bankr. P. 9004(a), (b): legible; caption with the court's name, the title of the case, the case number and the
//     adversary-proceeding number, and a brief designation of the document.
//   Fed. R. Bankr. P. 9011(a): signed by an attorney of record, with the signer's address and telephone number.
//   Fed. R. Civ. P. 10(b): numbered paragraphs, each limited as far as practicable to a single set of circumstances.
// The court's local rules were abolished effective 2003-08-04 (court website), so no local typography rule applies.
// Font, size, spacing and margins are conventions (tier 2), chosen to match the filed exemplar; see ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each is a convention or a rule; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")     // no typeface is mandated; the exemplar's Times (vendored)
#let type-size = 12pt                // convention: 12 point, the size the exemplar uses
#let para-indent = 0.5in             // first-line indent of numbered and unnumbered body paragraphs
#let number-box = 0.5in              // a paragraph number's box: the text starts 1 in from the margin (docx: a tab)
#let letter-box = 0.4in              // a prayer item's letter box, hanging (docx: Prayer Item)
#let quote-indent = 0.75in           // a block quotation's indent on both sides
#let margin = 1in                    // convention: one inch on all sides; 8 1/2 x 11 is the court's paper
#let text-width = 8.5in - 2 * margin
#let caption-left = 3.4in            // width of the party column of the caption (Form 416D)
#let caption-gutter = 0.25in         // between the party column and the case numbers
#let caption-pad = 10pt              // the caption rules stand off the party block by this much
#let case-pad = 0.1in                // the case numbers stand off the gutter
#let sig-left = 2.8in                // signature block: the date column
#let sig-gutter = 0.2in              // signature block: between the date and the signature column
#let court-name = ("UNITED STATES BANKRUPTCY COURT", "SOUTHERN DISTRICT OF IOWA")  // FRBP 9004(b)(1), 7010

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/iasb-adversary-complaint.lua sets the same twips).
#let pitch-body = 24pt               // convention: double-spaced body text (exemplar)
#let pitch-single = 14pt             // caption, block quotations, the table, signature block, sub-headings
#let group-gap = 6pt                 // caption: between the party groups
#let court-below = 24pt              // court name to the caption
#let caption-below = 24pt            // the caption's rule to the title
#let title-below = 18pt              // the title to the text
#let heading-above = 12pt            // every heading: the space above it
#let subheading-below = 6pt          // levels 2 and 3: the space below them (level 1 sits on the body pitch)
#let quote-above = 6pt               // a block quotation's space above and below it
#let quote-below = 12pt
#let table-space = 6pt               // the table's space above and below it
#let table-inset = 5.4pt             // the table's cell padding, left and right (docx: 108 twips)
#let table-slack = 4               // the table: characters of room added to a column's longest cell
#let table-rule = 0.5pt            // the table's rules (docx: w:sz 4)
#let signature-above = 24pt          // the last paragraph to the signature block

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("iasb-adversary-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (names with *et al.*, case names in italics).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line (a paragraph of its own), with an explicit space above it.
#let line-block(above: 0pt, body) = block(width: 100%, above: above, below: 0pt, body)

/// Single-spaced lines, one paragraph each; an empty item is a blank line (the next line sits a line lower).
#let line-stack(items) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  let gap = 0pt
  for i in items {
    if i == "" { gap += pitch-single } else {
      line-block(above: gap, if type(i) == str { inl(i) } else { i })
      gap = 0pt
    }
  }
}

/// Inline content without the paragraph breaks cmarker may put around it (they may not occur inside a paragraph).
#let unloose(body) = {
  if body.func() != [].func() { return body }
  let cs = body.children
  while cs.len() > 0 and cs.last().func() in (parbreak, [ ].func()) { cs = cs.slice(0, -1) }
  while cs.len() > 0 and cs.first().func() in (parbreak, [ ].func()) { cs = cs.slice(1) }
  cs.join()
}

/// A body paragraph at the body pitch, its first line indented half an inch.
#let body-par(content) = block(width: 100%, above: 0pt, below: 0pt,
  par(first-line-indent: (amount: para-indent, all: true), unloose(content)))

/// A numbered paragraph (Fed. R. Civ. P. 10(b)): the number in its box after the first-line indent, then the text.
#let numbered(n, content) = body-par[#box(width: number-box)[#n.]#unloose(content)]

/// A pipe table (GitHub markdown), ruled and single-spaced, the width of the text it is indented to. A column's
/// width is in proportion to its longest cell (characters, emphasis marks not counted) plus `table-slack`, rounded
/// to the twip; the last column takes the rest (docx: the same arithmetic in docx/iasb-adversary-complaint.lua).
#let pipe-table(t, width) = {
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
  let need = range(ncol).map(j => calc.max(..rows.map(r => chars(r.at(j, default: "")))) + table-slack)
  let total = need.sum()
  let widths = need.slice(0, -1).map(n => calc.round(width.pt() * n / total * 20) / 20 * 1pt)
  widths.push(width - widths.sum(default: 0pt))
  // Word sets each rule in a height of its own above a row (and below the last): the cell pads above by the rule.
  table(columns: widths, inset: (x: table-inset, top: table-rule, bottom: 0pt), stroke: table-rule,
    ..rows.map(r => range(ncol).map(j => inl(r.at(j, default: "")))).flatten())
}

// ---------------------------------------------------------------------------
// Caption (Form 416D): court, debtor, plaintiff and defendant on the left; case number, chapter and adversary
// number on the right; the document's title below the caption.
// ---------------------------------------------------------------------------

#let party-groups(meta) = {
  let g = ()
  let debtor-label = if meta.debtors.len() > 1 { "Debtors." } else { "Debtor." }
  g.push(("In re:",) + meta.debtors + (debtor-label,))
  for p in meta.caption.plaintiffs { g.push(p.names + (p.designation,)) }
  g.push(("v.",))
  for d in meta.caption.defendants { g.push(d.names + (d.designation,)) }
  g
}

#let caption(meta) = {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  for (i, line) in court-name.enumerate() {
    line-block(align(center, text(weight: "bold", line)))
  }
  let groups = party-groups(meta)
  let adv = if meta.adv_number == "" { "______________" } else { meta.adv_number }
  // The rules beside and under the party column run the height of the caption (docx: the cell's borders).
  block(above: court-below, below: 0pt, grid(
    columns: (caption-left, caption-gutter, text-width - caption-left - caption-gutter),
    grid.cell(stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-pad, bottom: caption-pad),
      for (i, g) in groups.enumerate() {
        block(above: if i == 0 { 0pt } else { group-gap }, below: 0pt, line-stack(g))
      }),
    [],
    pad(left: case-pad, line-stack((
      "Case No. " + meta.case_number,
      "Chapter " + meta.chapter,
      "Adv. Proc. No. " + adv,
    ))),
  ))
  block(above: caption-below, below: title-below, width: 100%,
    align(center, text(weight: "bold", inl(meta.brief_title))))
}

// ---------------------------------------------------------------------------
// Body: headings, numbered paragraphs, lettered prayer items, tables, block quotations
// ---------------------------------------------------------------------------

/// A heading is kept with the block after it, so it never ends a page. Level 1 is a centered section in capitals on
/// the body pitch; level 2 a bold sub-heading, level 3 bold italic, both single-spaced.
#let heading-block(level, s) = {
  if level == 1 {
    block(width: 100%, sticky: true, above: heading-above, below: 0pt,
      align(center, text(weight: "bold", upper(s))))
  } else {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    block(width: 100%, sticky: true, above: heading-above, below: subheading-below,
      if level == 2 { text(weight: "bold", inl(s)) } else { text(weight: "bold", style: "italic", inl(s)) })
  }
}

/// The body in document order. Numbered paragraphs continue from the consent paragraph (Fed. R. Civ. P. 10(b)).
#let body-content(body, meta) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).filter(c => c.trim() != "")
  let n = 0
  let out = []

  // The first two numbered paragraphs are required by Fed. R. Bankr. P. 7008 and come from the frontmatter, so a sample
  // cannot omit them: (1) the allegation of jurisdiction names the case (name, number, Code chapter), the district and the
  // division; (2) the statement whether the pleader consents to final orders by the bankruptcy court.
  assert("division" in meta, message: "iasb-adversary-complaint: frontmatter needs division (FRBP 7008)")
  assert("final_orders_consent" in meta, message: "iasb-adversary-complaint: frontmatter needs final_orders_consent (FRBP 7008)")
  let case-reference = "This adversary proceeding arises in and relates to the Chapter " + meta.chapter + " case of " + meta.debtors.join(", ") + ", Case No. " + meta.case_number + ", pending in the United States Bankruptcy Court for the Southern District of Iowa, " + meta.division + " Division."
  for sentence in (case-reference, meta.final_orders_consent) {
    n += 1
    out += numbered(n, inl(sentence))
  }

  for c in chunks {
    let t = c.trim()
    if t.starts-with("#") {
      let level = t.match(regex("^(#+)")).captures.at(0).len()
      out += heading-block(level, t.replace(regex("^#+[ \t]*"), ""))
    } else if t.starts-with("|") {
      // A table is single-spaced, ruled, indented to the paragraph text, kept on one page, and not numbered.
      // The space around it is spacing of its own, kept at a page end (docx: an empty paragraph of that height).
      out += v(table-space)
      out += block(width: 100%, breakable: false, above: 0pt, below: 0pt,
        pad(left: para-indent, {
          set text(..edges(pitch-single))
          set par(first-line-indent: 0pt)
          pipe-table(t, text-width - para-indent)
        }))
      out += v(table-space + table-rule)
    } else if t.starts-with("- ") {
      // A list is lettered A., B., C. (the prayer for relief). Each item starts with "- "; the list may break across
      // pages. The letter hangs in its box half an inch in; the text wraps under the text.
      let items = t.split("\n").map(l => l.trim()).filter(l => l.starts-with("- ")).map(l => l.slice(2))
      for (i, item) in items.enumerate() {
        out += block(width: 100%, above: 0pt, below: 0pt, pad(left: para-indent,
          par(first-line-indent: 0pt, hanging-indent: letter-box,
            [#box(width: letter-box)[#numbering("A.", i + 1)]#unloose(inl(item))])))
      }
    } else if t.starts-with(">") {
      // A block quotation is single-spaced and indented on both sides.
      out += block(width: 100%, above: quote-above, below: quote-below, pad(x: quote-indent, {
        set text(..edges(pitch-single))
        set par(first-line-indent: 0pt)
        inl(t.replace(regex("(?m)^>[ \t]?"), ""))
      }))
    } else if t.starts-with("WHEREFORE") {
      // The prayer's lead-in is an unnumbered paragraph (Fed. R. Civ. P. 10(b) numbers the allegations only).
      out += body-par(inl(t))
    } else {
      n += 1
      out += numbered(n, inl(t))
    }
  }
  out
}

/// Signature block: the date, the firm, the signer's electronic signature (FRBP 9011(a)), and the counsel lines.
/// The space above it is spacing of its own (docx: an empty paragraph of that height), so it stays behind when the
/// block moves to the next page.
#let signature-block(meta) = v(signature-above) + block(width: 100%, breakable: false, above: 0pt, below: 0pt, grid(
  columns: (sig-left, sig-gutter, text-width - sig-left - sig-gutter),
  line-stack(("Dated: " + meta.date,)),
  [],
  line-stack((
    "Respectfully submitted,",
    "",
    ..meta.signature.firm,
    "",
    "By: /s/ " + meta.signature.signer,
    meta.signature.signer,
    ..meta.signature.lines,
  )),
))

/// Counsel's signature block at the end of the pleading; the caption carries no counsel block (Form 416D).
#let iasb-adversary-complaint(meta, body) = {
  // Every page numbered, bottom centre; the number in a single-spaced line box (Word's footer).
  set page(
    paper: "us-letter",
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  set par(first-line-indent: (amount: para-indent, all: true))
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number. No markdown lists reach typst's list layout (list-indent: none).
  show: xengine.with(pitch: pitch-body, list-indent: none)

  caption(meta)

  if "lead_in" in meta { body-par(inl(meta.lead_in)) }

  body-content(body, meta)
  signature-block(meta)
}
