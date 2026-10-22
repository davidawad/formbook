// Complaint for the U.S. District Court for the Eastern District of Missouri (moed).
// Rules: E.D. Mo. L.R. 2.01(A) (12-point or larger type, double spacing, 8 1/2 by 11 inch paper, a blank
// 2 by 2 inch area in the upper left and upper right corners of page 1, contact details under each
// signature); Fed. R. Civ. P. 8(a), 10(a), 10(b), 38(b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")        // L.R. 2.01(A)(1) names no typeface; the vendored serif in fonts/
#let type-size = 12pt                   // L.R. 2.01(A)(1): 12-point or larger
#let page-w = 8.5in                     // L.R. 2.01(A)(1): 8 1/2 by 11 inch pages
#let page-h = 11in
#let margin = 1in                       // not stated in L.R. 2.01; a 1 inch margin is the convention used here
#let corner = 2in                       // L.R. 2.01(A)(2): blank 2 by 2 inch area, upper left and upper right, page 1
#let para-indent = 0.5in                // first-line indent; the allegation number's box after it
#let item-indent = 0.5in                // lettered items: the label half an inch in, the text a box after it
#let caption-left = 3.3in               // width of the party column of the caption
#let caption-gutter = 0.3in             // between the party column and the case-number column
#let caption-inset = 0.15in             // the party text stands off the column's right rule
#let caption-pad = 0.1in                // and off its bottom rule
#let designation-indent = 0.5in         // "Plaintiff," / "Defendants." in the party column
#let signature-indent = 3.25in          // signature blocks sit to the right of the text

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; the docx engine sets the same twips).
#let pitch-single = 13.8pt              // a single line: 1.15 x the type size (Word's single line in this face)
#let pitch-double = 2 * pitch-single    // L.R. 2.01(A)(1): double spaced (Word's double, as in the filed exemplar)

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("moed-complaint: the sample must start with a YAML frontmatter block") }
  (yaml(bytes(m.captures.at(0))), src.slice(m.end))
}

/// Inline markdown (italics, emphasis, typographic punctuation).
#let inl(s) = cmarker.render(s, raw-typst: false, smart-punctuation: true)

/// One single-spaced line block (a paragraph of its own), with explicit space above it.
#let line-block(above: 0pt, below: 0pt, indent: 0pt, body) = block(width: 100%, above: above, below: below, {
  set text(..edges(pitch-single))
  set par(first-line-indent: 0pt)
  pad(left: indent, body)
})

// ---------------------------------------------------------------------------
// First page: court title (inside the 2 inch corner band), caption, title of the paper
// ---------------------------------------------------------------------------

#let court-title(meta) = {
  let lines = ("UNITED STATES DISTRICT COURT", "EASTERN DISTRICT OF MISSOURI")
  if "division" in meta { lines.push(meta.division) }
  // The title block fills the band from the top margin down to the 2 inch corner line, so the
  // caption always starts below the blank corners (L.R. 2.01(A)(2)).
  block(width: 100%, height: corner - margin, above: 0pt, below: 0pt,
    for l in lines { line-block(align(center, text(weight: "bold", l))) })
}

#let caption(meta) = block(width: 100%, above: 0pt, below: 0pt, grid(
  columns: (caption-left, 1fr),
  column-gutter: caption-gutter,
  block(width: 100%, stroke: (right: 0.75pt, bottom: 0.75pt), inset: (right: caption-inset, bottom: caption-pad), {
    // Each party: its names, then its designation, indented; "v." between the parties.
    for (i, p) in meta.caption.parties.enumerate() {
      if i > 0 { line-block[v.] }
      line-block(inl(p.names))
      line-block(indent: designation-indent, inl(p.designation))
    }
  }),
  {
    // The case number, or a blank for the clerk; the legends a single line below it.
    let number = if "case_number" in meta and meta.case_number != none { meta.case_number } else { "______________" }
    line-block[Case No. #number]
    for (i, l) in meta.at("legends", default: ()).enumerate() {
      line-block(above: if i == 0 { pitch-single } else { 0pt }, text(weight: "bold", inl(l)))
    }
  },
))

/// The title of the paper: bold, centered, single-spaced lines a double line below the caption.
#let title-block(s) = block(width: 100%, above: pitch-double, below: pitch-single, sticky: true,
  line-block(align(center, text(weight: "bold", inl(s)))))

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

/// A body paragraph at the double pitch: unnumbered (first-line indent), or numbered (Fed. R. Civ. P. 10(b): the
/// number in a box of the paragraph indent after the first-line indent, the text after it, wrapped to the margin).
#let body-par(num, content) = block(width: 100%, above: 0pt, below: 0pt, if num == none {
  par(first-line-indent: (amount: para-indent, all: true), content)
} else {
  par(first-line-indent: (amount: para-indent, all: true), [#box(width: para-indent, [#num.])#content])
})

/// A block note (a single-spaced, unnumbered paragraph, such as an omission marker), a single line off the text.
#let note(s) = line-block(above: pitch-single, below: pitch-single, inl(s))

/// A heading at the body pitch, bold: levels 1 and 2 centered, level 3 at the margin; sticky, so it never ends a page.
#let render-heading(level, s) = block(width: 100%, above: 0pt, below: 0pt, sticky: true,
  align(if level <= 2 { center } else { left }, text(weight: "bold", inl(s))))

/// A markdown list: items are lettered (a), (b), ...: the label half an inch in, the text hanging after it.
#let list-block(lines) = {
  let items = ()
  for l in lines {
    let m = l.match(regex("^[0-9]+\\. (.*)$"))
    if m != none { items.push(m.captures.at(0)) } else { items.at(-1) = items.at(-1) + " " + l }
  }
  for (i, t) in items.enumerate() {
    block(width: 100%, above: 0pt, below: 0pt, pad(left: item-indent, par(hanging-indent: item-indent,
      first-line-indent: 0pt, [#box(width: item-indent, numbering("(a)", i + 1))#inl(t)])))
  }
}

#let render-body(body) = {
  let n = 0
  for c in body.split(regex("\n\\s*\n")).map(c => c.trim()).filter(c => c != "") {
    if c.starts-with("### ") {
      render-heading(3, c.slice(4))
    } else if c.starts-with("## ") {
      render-heading(2, c.slice(3))
    } else if c.starts-with("# ") {
      render-heading(1, c.slice(2))
    } else if c.starts-with(">") {
      note(c.slice(1).trim())
    } else {
      let lines = c.split("\n").map(l => l.trim()).filter(l => l != "")
      if lines.at(0).match(regex("^[0-9]+\\. ")) != none {
        list-block(lines)
      } else {
        n += 1
        body-par(n, inl(lines.join(" ")))
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Signature: date, firm blocks (L.R. 2.01(A)(1): name, address, telephone, email, bar number under each
// signature), and the party represented; single-spaced, never split across a page
// ---------------------------------------------------------------------------

#let signature-block(meta) = block(width: 100%, breakable: false, above: pitch-double, below: 0pt, {
  if "date" in meta { line-block[DATED: #meta.date] }
  line-block(above: if "date" in meta { pitch-double } else { 0pt }, indent: signature-indent)[Respectfully submitted,]
  for f in meta.signature {
    line-block(above: pitch-single, indent: signature-indent, text(weight: "bold", inl(f.firm)))
    if "signer" in f { line-block(indent: signature-indent, inl(f.signer)) }
    for l in f.lines { line-block(indent: signature-indent, inl(l)) }
  }
  if "attorneys_for" in meta {
    line-block(above: pitch-single, indent: signature-indent, text(style: "italic", inl(meta.attorneys_for)))
  }
})

// ---------------------------------------------------------------------------
// Page and document
// ---------------------------------------------------------------------------

#let moed-complaint(meta, body) = {
  // Page numbers centered at the foot, arabic, on every page; the number in a single-spaced line box, so it sits at
  // the same place on every page (Word's footer).
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    footer-descent: 30%,
    footer: context align(center, text(..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch (L.R. 2.01(A)(1): double spaced).
  show: xengine.with(pitch: pitch-double, list-indent: item-indent)

  court-title(meta)
  caption(meta)
  title-block(meta.title)
  if "lead_in" in meta { body-par(none, inl(meta.lead_in)) }
  render-body(body)
  signature-block(meta)
}
