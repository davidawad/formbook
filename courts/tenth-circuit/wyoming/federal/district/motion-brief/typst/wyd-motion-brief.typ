// Memorandum in support of a dispositive motion, U.S. District Court for the District of Wyoming (wyd).
// Rules: D. Wyo. LR 7.1(b)(2)(A)-(B) (brief for a dispositive motion; 25-page limit); LR 10.1(a) (typed, double
// spaced, one side, 8 1/2 x 11, one-inch margins on all sides, not less than 12 point) and 10.1(b) (caption per
// Fed. R. Civ. P. 10(a) plus an attorney information block); Fed. R. Civ. P. 10(a). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif") // LR 10.1(a) names no face; Times New Roman, the house standard (docs/FONTS.md), vendored in fonts/
#let type-size = 12pt                   // LR 10.1(a): not less than 12 point
#assert(type-size >= 12pt, message: "wyd-motion-brief: D. Wyo. LR 10.1(a) requires type not less than 12 point")
#let page-w = 8.5in                     // LR 10.1(a): 8 1/2 x 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LR 10.1(a): one inch margin on all sides
#let text-width = page-w - 2 * margin
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                // first-line indent of paragraphs; a list number starts here
#let item-box = 0.35in                  // a list number in a box after the indent: its text hangs at 0.85 in
#let h1-box = 0.5in                     // "I." of a level-1 heading at the margin, its text from 0.5 in
#let h2-box = 0.4in                     // "A." of a level-2 heading at the 0.5 in indent, its text from 0.9 in
#let attorney-gutter = 0.3in            // between the columns of the attorney information block
#let caption-left = 3.1in               // party column of the caption
#let caption-mid = 0.35in               // ")" column
#let designation-indent = 1in           // "Plaintiff," / "Defendant." under the party names, as in the filed exemplar
#let sig-left = 2.5in                   // the signature block starts 2.5 in from the margin, as in the filed exemplar
#let page-limit = 25                    // LR 7.1(b)(2)(B): briefs in support of dispositive motions
#let court-name = ("UNITED STATES DISTRICT COURT", "FOR THE DISTRICT OF WYOMING")

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/wyd.lua and docx/reference.xml set the same
// twips: 20 x pt).
#let pitch-body = 24pt                  // LR 10.1(a): double spaced, two 12 pt lines (body, title, headings, items, certificate text)
#let pitch-single = 13.8pt              // attorney block, court name, caption, signature block and service list: single spaced
#let court-above = 18pt                 // attorney block to the court name
#let caption-above = 18pt               // court name to the caption
#let title-above = 18pt                 // caption to the title
#let title-below = 12pt                 // title to the body
#let heading-above = 12pt               // above a heading (dropped at the top of a page)
#let sig-above = 24pt                   // the last chunk to the date line
#let sig-gap = 24pt                     // the date line to "Respectfully submitted,"
#let sig-blank = 2 * pitch-single       // two blank single lines before the "/s/" line and before the role
#let cert-above = 24pt                  // the signature block to the certificate of service
#let cert-gap = 12pt                    // between the parts of the certificate

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("wyd-motion-brief: the sample must start with a YAML frontmatter block") }
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

/// Caption (Fed. R. Civ. P. 10(a)): party names with designations on the left, a ")" column, and the case number on
/// the right, level with the separator ("v.") between the parties, as in the filed exemplar. One grid row per caption
/// line, so a long name that wraps pushes its own row down.
#let caption(meta) = {
  let sep = meta.caption.at("separator", default: "v.")
  let rows = ()   // (text, is-designation)
  let sep-row = none
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 {
      if sep-row == none { sep-row = rows.len() + 1 }
      rows += (("", false), (sep, false), ("", false))
    }
    for n in p.names { rows.push((n, false)) }
    rows.push((p.designation, true))
  }
  let case-row = if sep-row == none { 0 } else { sep-row }
  let cells = ()
  for (i, r) in rows.enumerate() {
    cells.push(sline(left: if r.at(1) { designation-indent } else { 0pt }, if r.at(0) == "" { "" } else { md(r.at(0)) }))
    cells.push(sline([)]))
    cells.push(if i == case-row { sline("Case No. " + meta.case_number) } else { sline("") })
  }
  block(width: 100%, above: caption-above, below: 0pt,
    grid(columns: (caption-left, caption-mid, text-width - caption-left - caption-mid), ..cells))
}

#let first-page(meta) = {
  attorney-block(meta)
  sline(above: court-above, centered: true, strong(court-name.at(0)))
  sline(centered: true, strong(court-name.at(1)))
  caption(meta)
  // the title on the body pitch (LR 10.1(a): double spaced), centered, bold capitals
  block(width: 100%, above: title-above, below: 0pt, sticky: true,
    align(center, par(first-line-indent: 0pt, strong(upper(md(meta.title))))))
}

// ---------------------------------------------------------------------------
// Body: headings, paragraphs (unnumbered, first-line indent), numbered list
// ---------------------------------------------------------------------------

/// A heading on the body pitch (LR 10.1(a): double spaced), bold, kept with the text after it. A heading that
/// starts with a roman numeral (level 1) or a letter (level 2) is set flush with its number in a box and its lines
/// hanging after it, as in the filed exemplar; any other heading (CONCLUSION) is centered.
#let heading(level, title, above: 0pt) = {
  let num = title.match(regex("^([IVXL]+\\.|[A-Z]\\.)[ \\t]+([\\s\\S]*)$"))
  block(width: 100%, above: calc.max(above, heading-above), below: 0pt, sticky: true, {
    if num != none {
      let (inset, gap) = if level == 1 { (0pt, h1-box) } else { (para-indent, h2-box) }
      par(first-line-indent: 0pt, hanging-indent: inset + gap,
        strong[#h(inset)#box(width: gap, num.captures.at(0))#md(num.captures.at(1))])
    } else {
      align(center, par(first-line-indent: 0pt, strong(md(title))))
    }
  })
}

/// Walks the markdown body. Blank-line-separated chunks: a `#` heading, a numbered list (kept as written, the number
/// in a box after the indent, the lines hanging after it; used for the relief requested), or a paragraph (first-line
/// indent, not numbered). The last chunk is kept with the signature block.
#let body-chunks(body) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  for (i, t) in chunks.enumerate() {
    let sticky = i == chunks.len() - 1
    let above = if i == 0 { title-below } else { 0pt }
    if t.starts-with("#") {
      let level = t.match(regex("^#+")).end
      heading(level, t.slice(level).trim(), above: above)
    } else if t.match(regex("^\\d+\\.[ \\t]")) != none {
      // A list item may run over several lines; a line that does not start with a number continues it.
      let parts = ()
      for line in t.split(regex("\\r?\\n")).filter(l => l.trim() != "") {
        let m = line.match(regex("^(\\d+)\\.[ \\t]+([\\s\\S]*)$"))
        if m != none { parts.push((m.captures.at(0), m.captures.at(1))) } else {
          parts.at(-1) = (parts.at(-1).at(0), parts.at(-1).at(1) + " " + line.trim())
        }
      }
      for (k, it) in parts.enumerate() {
        block(width: 100%, above: if k == 0 { above } else { 0pt }, below: 0pt, sticky: sticky and k == parts.len() - 1,
          par(first-line-indent: 0pt, hanging-indent: para-indent + item-box,
            [#h(para-indent)#box(width: item-box, [#it.at(0).])#md(it.at(1))]))
      }
    } else {
      block(width: 100%, above: above, below: 0pt, sticky: sticky, par(first-line-indent: 0pt, [#h(para-indent)#md(t)]))
    }
  }
}

/// Date line, "Respectfully submitted," and the signature block (from 2.5 in, as in the exemplar); kept on one page.
#let signature-block(meta) = block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
  sline(md(meta.dated))
  sline(above: sig-gap, left: sig-left, "Respectfully submitted,")
  block(width: 100%, above: sig-blank, below: 0pt,
    for l in ("/s/ " + meta.signature.signer,) + meta.signature.lines { sline(left: sig-left, md(l)) })
  block(width: 100%, above: sig-blank, below: 0pt, for l in meta.signature.role { sline(left: sig-left, md(l)) })
})

/// Certificate of service (Fed. R. Civ. P. 5(b)): the heading, the statement (double spaced), the persons served
/// (single spaced, 0.5 in in) and the signer (from 2.5 in), kept on one page.
#let certificate(meta) = {
  let c = meta.at("certificate", default: none)
  if c == none { return }
  block(width: 100%, above: cert-above, below: 0pt, breakable: false, {
    block(width: 100%, above: 0pt, below: 0pt, align(center, par(first-line-indent: 0pt, strong("CERTIFICATE OF SERVICE"))))
    block(width: 100%, above: cert-gap, below: 0pt, par(first-line-indent: 0pt, [#h(para-indent)#md(c.text)]))
    block(width: 100%, above: cert-gap, below: 0pt, for l in c.at("served", default: ()) { sline(left: para-indent, md(l)) })
    sline(above: pitch-body, left: sig-left, md("/s/ " + c.signer))
  })
}

#let wyd-motion-brief(meta, body) = {
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
  certificate(meta)

  // LR 7.1(b)(2)(B): the brief, counted from the caption page, may not exceed the page limit.
  context {
    let n = counter(page).final().first()
    assert(n <= page-limit, message: "wyd-motion-brief: D. Wyo. LR 7.1(b)(2)(B) limits this brief to " + str(page-limit) + " pages; the render is " + str(n))
  }
}
