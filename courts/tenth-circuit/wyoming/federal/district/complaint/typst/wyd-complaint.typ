// Complaint for the U.S. District Court for the District of Wyoming (wyd).
// Rules: D. Wyo. Local Civil Rule 10.1(a) (typed, double spaced, one side, 8 1/2 x 11, one-inch margins on
// all sides, not less than 12 point) and 10.1(b) (caption per Fed. R. Civ. P. 10(a) plus an attorney
// information block); Fed. R. Civ. P. 10(a) (caption) and 10(b) (numbered paragraphs). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // LR 10.1(a) names no face; Times New Roman, the house standard (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt                   // LR 10.1(a): not less than 12 point
#assert(type-size >= 12pt, message: "wyd-complaint: D. Wyo. LR 10.1(a) requires type not less than 12 point")
#let page-w = 8.5in                     // LR 10.1(a): 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LR 10.1(a): one inch margin on all sides
#let text-width = page-w - 2 * margin
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                // first-line indent of paragraphs; a paragraph number or item label starts here
#let number-box = 0.5in                 // a paragraph number or item label in a box after the indent: its text starts 1 in from the margin
#let attorney-gutter = 0.3in            // between the columns of the attorney information block
#let caption-left = 3.1in               // party column of the caption
#let caption-mid = 0.35in               // ")" column
#let designation-indent = 1in           // "Plaintiff," / "Defendants." under the party names, as in the filed exemplar
#let sig-left = 2.5in                   // the signature block starts 2.5 in from the margin, as in the filed exemplar
#let court-name = ("IN THE UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF WYOMING")

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/wyd.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 24pt                  // LR 10.1(a): double spaced, two 12 pt lines (body, headings, items)
#let pitch-single = 13.8pt              // attorney block, court name, caption, title and signature block: single spaced
#let court-above = 18pt                 // attorney block to the court name
#let caption-above = 18pt               // court name to the caption
#let title-above = 18pt                 // caption to the title
#let title-below = 12pt                 // title to the body
#let heading-above = 12pt               // above a heading (dropped at the top of a page)
#let sig-above = 24pt                   // the last chunk to the date line
#let sig-gap = 24pt                     // the date line to "Respectfully submitted,"
#let sig-blank = 2 * pitch-single       // two blank single lines before the "/s/" line and before the role

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wyd-complaint: the sample must start with a YAML frontmatter block") }
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

/// Markdown to inline typst content (italic case names, *pro hac vice*).
#let md(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

#let letter(i) = "abcdefghijklmnopqrstuvwxyz".at(i)

/// One single-pitch paragraph; "" (or none) is a blank line.
#let sline(above: 0pt, left: 0pt, centered: false, c) = if c == "" or c == none {
  block(width: 100%, height: pitch-single, above: above, below: 0pt)
} else {
  block(width: 100%, above: above, below: 0pt, {
    set text(..edges(pitch-single))
    set align(center) if centered
    pad(left: left, par(first-line-indent: 0pt, c))
  })
}

// ---------------------------------------------------------------------------
// First page: attorney information block (LR 10.1(b)), court name, caption, title
// ---------------------------------------------------------------------------

/// Attorney information block: one column per firm group, each line single spaced (a long line wraps in its column).
#let attorney-block(meta) = {
  let groups = meta.at("attorney", default: ())
  if groups.len() == 0 { return }
  let n = groups.len()
  let w = (text-width - attorney-gutter * (n - 1)) / n
  let cols = ()
  for (g, group) in groups.enumerate() {
    if g > 0 { cols.push(attorney-gutter) }
    cols.push(w)
  }
  let cells = ()
  for (g, group) in groups.enumerate() {
    if g > 0 { cells.push([]) }
    cells.push(for l in group { sline(md(l)) })
  }
  block(width: 100%, above: 0pt, below: 0pt, grid(columns: cols, ..cells))
}

/// Caption (Fed. R. Civ. P. 10(a)): party names with designations on the left, a ")" column, and the case number
/// and jury legend on the right. One grid row per caption line, so a long name that wraps pushes its own row down.
/// "vs." sits between the parties.
#let caption(meta) = {
  let rows = ()   // (text, is-designation)
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { rows += (("", false), ("vs.", false), ("", false)) }
    for n in p.names { rows.push((n, false)) }
    rows.push((p.designation, true))
  }
  let case-no = meta.at("case_number", default: none)
  if case-no == none or case-no == "" { case-no = "____________" }
  let right = ("",) * rows.len()
  right.at(0) = "Case No. " + case-no
  let jury = meta.at("jury_demand", default: false) == true and rows.len() > 2
  let cells = ()
  for (i, r) in rows.enumerate() {
    cells.push(sline(left: if r.at(1) { designation-indent } else { 0pt }, if r.at(0) == "" { "" } else { md(r.at(0)) }))
    cells.push(sline([)]))
    cells.push(if i == 2 and jury { sline(strong("JURY TRIAL DEMANDED")) } else if right.at(i) == "" { sline("") } else { sline(right.at(i)) })
  }
  block(width: 100%, above: caption-above, below: 0pt,
    grid(columns: (caption-left, caption-mid, text-width - caption-left - caption-mid), ..cells))
}

#let first-page(meta) = {
  attorney-block(meta)
  sline(above: court-above, centered: true, strong(court-name.at(0)))
  sline(centered: true, strong(court-name.at(1)))
  caption(meta)
  sline(above: title-above, centered: true, strong(upper(meta.title)))
}

// ---------------------------------------------------------------------------
// Body: numbered allegations (Fed. R. Civ. P. 10(b))
// ---------------------------------------------------------------------------

/// A heading on the body pitch (LR 10.1(a): double spaced), centered, kept with the text after it: level 1 bold
/// capitals, level 2 bold, level 3 italic.
#let heading(level, title, above: 0pt) = block(width: 100%, above: calc.max(above, heading-above), below: 0pt,
  sticky: true, {
    set par(first-line-indent: 0pt)
    align(center, if level == 1 { strong(upper(md(title))) } else if level == 2 { strong(md(title)) } else { emph(md(title)) })
  })

/// A body paragraph on the body pitch: the first line indented, `label` (a number) in a box after the indent.
#let body-par(label: none, above: 0pt, sticky: false, c) = block(width: 100%, above: above, below: 0pt, sticky: sticky,
  par(first-line-indent: 0pt, [#h(para-indent)#if label != none { box(width: number-box, label) }#c]))

/// Walks the markdown body. Blank-line-separated chunks: a `#` heading, a list (lettered items (a), (b), ...), or a
/// paragraph (numbered, except a paragraph before the first heading, one starting with WHEREFORE, and any
/// paragraph in the prayer for relief). The last chunk is kept with the signature block.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let seen-heading = false
  let para-no = 0
  let in-prayer = false
  for (i, t) in chunks.enumerate() {
    let above = if i == 0 { title-below } else { 0pt }
    let sticky = i == chunks.len() - 1
    if t.starts-with("#") {
      seen-heading = true
      let level = t.match(regex("^#+")).end
      let title = t.slice(level).trim()
      in-prayer = lower(title).contains("prayer")
      heading(level, title, above: above)
    } else if t.match(regex("^\\d+\\.[ \\t]")) != none {
      // Lettered items: (a), (b), ...; a line that does not start with a number continues the item above it.
      let parts = ()
      for line in t.split(regex("\\r?\\n")).filter(l => l.trim() != "") {
        let m = line.match(regex("^\\d+\\.[ \\t]+([\\s\\S]*)$"))
        if m != none { parts.push(m.captures.at(0)) } else { parts.at(-1) = parts.at(-1) + " " + line.trim() }
      }
      for (k, it) in parts.enumerate() {
        block(width: 100%, above: if k == 0 { above } else { 0pt }, below: 0pt,
          sticky: sticky and k == parts.len() - 1,
          par(first-line-indent: 0pt, hanging-indent: para-indent + number-box,
            [#h(para-indent)#box(width: number-box, [(#letter(k))])#md(it)]))
      }
    } else if t.starts-with("WHEREFORE") or not seen-heading or in-prayer {
      body-par(above: above, sticky: sticky, md(t))
    } else {
      para-no += 1
      body-par(label: [#para-no.], above: above, sticky: sticky, md(t))
    }
  }
}

/// Signature block: the date line, then "Respectfully submitted," the "/s/" line, the signer's lines and the role
/// from 2.5 in, as in the filed exemplar; kept on one page.
#let signature-block(meta) = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  sline("Dated: " + meta.date)
  sline(above: sig-gap, left: sig-left, "Respectfully submitted,")
  block(width: 100%, above: sig-blank, below: 0pt,
    for l in ("/s/ " + meta.signature.signer,) + meta.signature.lines { sline(left: sig-left, md(l)) })
  block(width: 100%, above: sig-blank, below: 0pt, for l in meta.signature.role { sline(left: sig-left, md(l)) })
})

#let wyd-complaint(meta, body) = {
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    // Pages numbered at the foot, centered, in a single-pitch line box that ends footer-distance above the page edge.
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too (xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  first-page(meta)
  body-chunks(body)
  signature-block(meta)
}
