// Complaint for the U.S. District Court for the Northern District of West Virginia (wvnd).
// Rules: Fed. R. Civ. P. 8(a) (short and plain statement, jurisdiction, demand), 10(a) (caption: court,
// title, file number, Rule 7(a) designation), 10(b) (numbered paragraphs), 11(a) (signer's address,
// e-mail and telephone), 38(b) (jury demand, as body text); LR Gen P 5.03(c) (the "s/ name" signature).
// The local rules set no typography for complaints. The page is set to LR Civ P 7.02(a) (one-inch
// margins, 12 point, double spaced), the court's own filing standard for papers. See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // LR Civ P 7.02(a) names Times New Roman, Courier New or Arial; Liberation Serif is the vendored, metric-compatible Times New Roman
#let type-size = 12pt              // LR Civ P 7.02(a): 12 point proportionally spaced type
#let margin = 1in                  // LR Civ P 7.02(a): one inch on all four sides, 8 1/2 by 11 inch paper
#let para-indent = 0.5in           // first-line indent of paragraphs, and the box of a paragraph's number after it
#let item-indent = 0.5in           // prayer items: the label stands half an inch in ...
#let item-label = 0.5in            // ... in a box of this width; the text hangs after it
#let caption-left = 3.6in          // width of the party column of the caption
#let caption-gutter = 0.25in       // between the party column and the civil action number
#let designation-indent = 1in      // "Plaintiff," / "Defendants." under the party names
#let sig-left = 3.25in             // the signature block starts at the middle of the page

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-body = 24pt             // LR Civ P 7.02(a) double spacing: a 24 pt pitch at 12 pt (headings, title and court title too)
#let pitch-single = 13.8pt         // single spacing (caption, signature lines, page number): Word's single line, 1.15 x 12 pt
#let caption-gap = 6pt             // between the entries of the caption (party column, and the civil action number and judge lines)
#let cover-gap = 12pt              // the court title to the caption, the caption to the rule, the rule to the title
#let rule-height = 1.75pt          // the rule under the caption (docx: a 1 pt line and its 0.75 pt bottom border)
#let rule-stroke = 0.75pt

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wvnd-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (case names in italics, links). Smart punctuation keeps the author's characters.
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// Split the body into blank-line-separated chunks: headings, lettered lists, numbered paragraphs.
#let chunks-of(body) = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")

/// One single-spaced paragraph with explicit space above and below it.
#let line-block(above: 0pt, below: 0pt, left: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt, hanging-indent: 0pt)
  pad(left: left, body)
})

/// A paragraph at the body pitch.
#let body-par(sticky: false, content) = block(width: 100%, above: 0pt, below: 0pt, sticky: sticky,
  breakable: not sticky, par(first-line-indent: 0pt, content))

// ---------------------------------------------------------------------------
// Caption
// ---------------------------------------------------------------------------

/// Caption: court title, parties (left) and the civil action number (right), closed by a rule.
#let caption(meta) = {
  let title = ("UNITED STATES DISTRICT COURT", "FOR THE NORTHERN DISTRICT OF WEST VIRGINIA")
  if "division" in meta { title.push(meta.division) }
  for l in title { block(width: 100%, above: 0pt, below: 0pt, align(center, l)) }
  // the party column: each name and designation its own single-spaced paragraph, "v." between the sides
  let left = ()
  for (i, side) in meta.caption.enumerate() {
    for n in side.names { left.push((inl(n), 0pt)) }
    left.push((side.designation, designation-indent))
    if i < meta.caption.len() - 1 { left.push(([v.], 0pt)) }
  }
  let right = ("Civil Action No. " + meta.case_number,)
  if "judge" in meta { right.push("Judge: " + meta.judge) }
  block(width: 100%, above: cover-gap, below: 0pt, grid(
    columns: (caption-left, caption-gutter, 1fr),
    {
      for (k, (t, ind)) in left.enumerate() {
        line-block(left: ind, below: if k < left.len() - 1 { caption-gap } else { 0pt }, t)
      }
    },
    [],
    align(bottom, { for (k, l) in right.enumerate() { line-block(above: if k > 0 { caption-gap } else { 0pt }, l) } }),
  ))
  block(width: 100%, height: rule-height, above: cover-gap, below: cover-gap,
    place(bottom, line(length: 100%, stroke: rule-stroke)))
}

/// The signature block, after the last paragraph (Fed. R. Civ. P. 11(a); LR Gen P 5.03(c)).
#let signature-block(sig) = {
  assert(sig.lines.any(l => l.contains("@")), message: "wvnd-complaint: the signature lines need an e-mail address (Fed. R. Civ. P. 11(a))")
  assert(sig.lines.any(l => l.match(regex("\\(?\\d{3}\\)?[ .-]?\\d{3}[ .-]?\\d{4}")) != none), message: "wvnd-complaint: the signature lines need a telephone number (Fed. R. Civ. P. 11(a))")
  block(width: 100%, breakable: false, above: pitch-body, below: 0pt, {
    block(width: 100%, above: 0pt, below: 0pt, [Dated: #sig.date])
    pad(left: sig-left, {
      block(width: 100%, above: 0pt, below: 0pt, sig.party)
      block(width: 100%, above: 0pt, below: 0pt, [By Counsel,])
    })
    line-block(above: pitch-body, left: sig-left, "s/ " + sig.signer)
    for (i, l) in sig.lines.enumerate() { line-block(above: if i == 0 { pitch-single } else { 0pt }, left: sig-left, inl(l)) }
  })
}

// ---------------------------------------------------------------------------
// The complaint
// ---------------------------------------------------------------------------

#let wvnd-complaint(meta, body) = {
  assert("case_number" in meta, message: "wvnd-complaint: frontmatter needs case_number")
  assert("caption" in meta, message: "wvnd-complaint: frontmatter needs caption (a list of sides)")
  assert("title" in meta, message: "wvnd-complaint: frontmatter needs title (Fed. R. Civ. P. 10(a))")
  assert("signature" in meta, message: "wvnd-complaint: frontmatter needs signature")

  // LR Civ P 7.02(a): letter paper, one-inch margins; the page number centered in the bottom margin, in a single-
  // spaced line box (Word's footer).
  set page(paper: "us-letter", margin: margin, footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())))
  set text(font: font-family, size: type-size, lang: "en", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of
  // the body pitch.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number ("§§ 1331"), as a single one does in xengine.
  show regex("[§¶]{2} \\S+"): it => box(it)

  caption(meta)

  // Fed. R. Civ. P. 10(a): the title of the complaint names the paper.
  block(width: 100%, above: 0pt, below: 0pt, sticky: true, align(center, text(weight: "bold", inl(meta.title))))

  if "lead_in" in meta { body-par[#h(para-indent)#inl(meta.lead_in)] }

  let n = 0
  let chunks = chunks-of(body)
  for (k, c) in chunks.enumerate() {
    // the last paragraph stays with the signature block, so the signature never stands alone on a page
    let last = k == chunks.len() - 1
    if c.starts-with("#") {
      let level = c.match(regex("^#+")).text.len()
      let t = c.replace(regex("^#+\\s*"), "")
      block(width: 100%, sticky: true, above: 0pt, below: 0pt, {
        if level <= 2 { align(center, text(weight: "bold", inl(t))) }
        else { text(weight: "bold", style: "italic", inl(t)) }
      })
    } else if c.split("\n").all(l => l.match(regex("^[0-9]+\\. ")) != none) {
      // prayer and other lettered lists: (a), (b), ...
      let items = c.split("\n")
      for (i, l) in items.enumerate() {
        block(width: 100%, above: 0pt, below: 0pt, sticky: last, breakable: not last,
          par(hanging-indent: item-indent + item-label, first-line-indent: 0pt,
            [#h(item-indent)#box(width: item-label, numbering("(a)", i + 1))#inl(l.replace(regex("^[0-9]+\\. "), ""))]))
      }
    } else if c.starts-with("~ ") {
      // an unnumbered paragraph (the introduction, notes outside the allegations)
      body-par(sticky: last)[#h(para-indent)#inl(c.slice(2))]
    } else {
      // a numbered paragraph (Fed. R. Civ. P. 10(b)); the number runs through the whole complaint
      n += 1
      body-par(sticky: last)[#h(para-indent)#box(width: para-indent)[#n.]#inl(c)]
    }
  }

  signature-block(meta.signature)
}
