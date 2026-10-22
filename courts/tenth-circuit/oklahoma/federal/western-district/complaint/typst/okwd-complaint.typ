// Complaint for the U.S. District Court for the Western District of Oklahoma (okwd).
// Rules: LCvR7.1(d) (13-point print style including footnotes; margins at least one inch), LCvR5.2(a) (double-spaced,
// 8 1/2 by 11), LCvR5.4 (counsel's mailing address, telephone, fax and e-mail on every paper), LCvR3.1 (each party
// numbered separately in the caption), Fed. R. Civ. P. 8, 10(a), 10(b). See ../README.md.
// Content-agnostic: every case-specific word comes from the sample's frontmatter, never from this file.
#import "@preview/cmarker:0.1.10"
#import "/lib/typst/xengine.typ": xengine, edges

// ---------------------------------------------------------------------------
// Parameters (each traces to a rule or a layout choice; see README.md)
// ---------------------------------------------------------------------------
#let font-family = ("Times New Roman", "Liberation Serif")   // no W.D. Okla. rule names a face (LCvR7.1(d), rules.md OKWD-FONT-002); Times New Roman, the house standard (docs/FONTS.md); the exemplar's Century Schoolbook is one filer's style (tier 3)
#let type-size = 13pt                   // LCvR7.1(d): print style not less than 13-point, footnotes included
#let page-w = 8.5in                     // LCvR5.2(a): 8 1/2 by 11 inch paper
#let page-h = 11in
#let margin = 1in                       // LCvR7.1(d): minimum one inch on the top, bottom and sides
#let footer-distance = 0.5in            // the page number's line box ends half an inch above the page edge (docx: footer 720)
#let para-indent = 0.5in                // first-line indent; a paragraph number or prayer letter starts here
#let number-box = 0.5in                 // a paragraph number (prayer letter) in a box after the indent: its text starts 1 in in
#let caption-left = 3.4in               // width of the party column of the caption
#let paren-w = 0.3in                    // the ")" column between the parties and the case number
#let caption-right-pad = 0.3in          // the case number stands this far right of the ")" column
#let designation-indent = 0.5in         // a party's designation ("Plaintiff,") is indented in the party column
#let sig-left = 3.4in                   // the signature block starts 3.4 in from the margin (right half of the page)

// Cross-engine layout model (lib/typst/xengine.typ; docs/EVAL-LOOP.md, "Cross-engine gate"): every line is a box of
// its pitch with the baseline at 0.8 of it, the boxes touch, and the space between blocks is the larger of the space
// below the one and above the other (Word's exact line spacing; docx/okwd-complaint.lua and docx/reference.xml set
// the same twips: 20 x pt).
#let pitch-single = 14.95pt             // one line of Times New Roman at 13 pt (1.15 em): caption, headings, signature
#let pitch-body = 29.9pt                // LCvR5.2(a) double spacing: two single lines of the face at 13 pt
#let cover-gap = 14.95pt                // court title to caption, caption to title, title to body (a blank single line)
#let heading-above = 14.95pt            // a blank single line above a heading
#let sig-above = 14.95pt                // the last paragraph to the signature block
#let jury-gap = 14.95pt                 // the case number to "JURY TRIAL DEMANDED"

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Split the sample's YAML frontmatter from its markdown body.
#let split-frontmatter(src) = {
  let m = src.match(regex("^---\r?\n([\\s\\S]*?)\r?\n---[ \t]*\r?\n"))
  if m == none { panic("okwd-complaint: the sample must start with a YAML frontmatter block") }
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

/// Markdown to inline typst content.
#let md(s) = unloose(cmarker.render(s, raw-typst: false, smart-punctuation: true))

/// One single-pitch line (a paragraph of its own); "" is a blank line.
#let sline(above: 0pt, left: 0pt, centered: false, sticky: false, c) = if c == "" {
  block(width: 100%, height: pitch-single, above: above, below: 0pt, sticky: sticky)
} else {
  block(width: 100%, above: above, below: 0pt, sticky: sticky, {
    set text(..edges(pitch-single))
    set align(center) if centered
    pad(left: left, par(first-line-indent: 0pt, c))
  })
}

// ---------------------------------------------------------------------------
// Cover: court title, caption (LCvR3.1: parties numbered as written), title
// ---------------------------------------------------------------------------

/// The caption: the party column (each party's names, its designation indented, "v." between parties), one ")" per
/// line of it, and the case number (and the jury demand) at the right. One line each: the caption lines are short.
#let caption(meta) = {
  let left = ()
  for (k, p) in meta.caption.parties.enumerate() {
    if k > 0 { left.push(sline("v.")) }
    for name in p.names { left.push(sline(name)) }
    left.push(sline(left: designation-indent, p.designation))
  }
  let right = (sline(if meta.case_number == "" { "Case No. ____________" } else { meta.case_number }),)
  if meta.at("jury_demand", default: false) {
    right.push(sline(above: jury-gap, strong("JURY TRIAL DEMANDED")))
  }
  block(width: 100%, above: cover-gap, below: 0pt, breakable: false, grid(
    columns: (caption-left, paren-w, 1fr),
    left.join(),
    for _ in left { sline(centered: true, [)]) },
    pad(left: caption-right-pad, right.join()),
  ))
}

#let cover(meta) = {
  sline(centered: true, strong("IN THE UNITED STATES DISTRICT COURT"))
  sline(centered: true, strong("FOR THE WESTERN DISTRICT OF OKLAHOMA"))
  caption(meta)
  sline(above: cover-gap, centered: true, strong(upper(meta.brief_title)))
}

// ---------------------------------------------------------------------------
// Body: numbered allegations (Fed. R. Civ. P. 10(b)), headings, prayer items
// ---------------------------------------------------------------------------

/// A heading: bold, single-spaced, centered, kept with the text after it; level 1 in capitals.
#let heading(level, s, above: 0pt) = block(width: 100%, above: calc.max(above, heading-above), below: 0pt,
  sticky: true, {
    set text(..edges(pitch-single))
    set par(first-line-indent: 0pt)
    align(center, strong(if level == 1 { upper(md(s)) } else { md(s) }))
  })

/// A body paragraph on the double pitch, its first line indented; `label` (a number or letter) in a box after the
/// indent, the lines after the first at the margin (a paragraph) or hanging under the text (a prayer item).
#let body-par(label: none, hang: false, above: 0pt, sticky: false, c) = block(width: 100%, above: above, below: 0pt,
  sticky: sticky, par(first-line-indent: 0pt, hanging-indent: if hang { para-indent + number-box } else { 0pt },
    [#h(para-indent)#if label != none { box(width: number-box, label) }#c]))

/// The body, chunk by chunk (a chunk is the text between blank lines; its first characters say what it is). A `#`
/// chunk is a heading; a `1.` chunk a prayer item, lettered A., B., ... by its number; any other chunk a paragraph,
/// numbered unless it stands under a level-1 heading named in the frontmatter `unnumbered` list (the prayer and the
/// jury demand). The last chunk is kept with the signature block, so a signature never stands alone on a page.
#let allegations(body, unnumbered, above) = {
  let chunks = body.split(regex("\\r?\\n[ \\t]*\\r?\\n")).map(c => c.trim()).filter(c => c != "")
  let numbering-on = true
  let n = 0
  for (i, t) in chunks.enumerate() {
    let a = if i == 0 { above } else { 0pt }
    let last = i == chunks.len() - 1
    let h = t.match(regex("^(#+)[ \\t]+(.*)$"))
    if h != none {
      let level = h.captures.at(0).len()
      let title = h.captures.at(1).trim()
      if level == 1 { numbering-on = not unnumbered.any(u => title.contains(u)) }
      heading(level, title, above: a)
    } else if t.match(regex("^\\d+\\.[ \\t]")) != none {
      let m = t.match(regex("^(\\d+)\\.[ \\t]+([\\s\\S]*)$"))
      body-par(label: numbering("A.", int(m.captures.at(0))) , hang: true, above: a, sticky: last,
        md(m.captures.at(1)))
    } else if numbering-on {
      n += 1
      body-par(label: [#n.], above: a, sticky: last, md(t))
    } else {
      body-par(above: a, sticky: last, md(t))
    }
  }
}

// ---------------------------------------------------------------------------
// Signature block (LCvR5.4; Fed. R. Civ. P. 11(a)), single-spaced in the right half, kept on one page
// ---------------------------------------------------------------------------

#let signature-block(meta) = {
  let sig = meta.signature
  let firm = sig.at("firm", default: ())
  block(width: 100%, above: sig-above, below: 0pt, breakable: false, {
    // the date (when given) at the margin, beside "Respectfully submitted,"
    block(width: 100%, above: 0pt, below: 0pt, {
      set text(..edges(pitch-single))
      par(first-line-indent: 0pt, hanging-indent: sig-left,
        [#box(width: sig-left, if "date" in meta [Dated: #meta.date])Respectfully submitted,])
    })
    sline("")
    for l in firm { sline(left: sig-left, l) }
    if firm.len() > 0 { sline("") }
    sline(left: sig-left, sig.sign)
    for l in sig.lines { sline(left: sig-left, l) }
  })
}

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------

#let okwd-complaint(meta, body) = {
  set page(
    width: page-w,
    height: page-h,
    margin: margin,
    // The page number centered at the foot of every page, at the type size (LCvR7.1(d)), in a single-pitch line box
    // that ends footer-distance above the page edge.
    footer-descent: margin - footer-distance - pitch-single,
    footer: context align(center, text(size: type-size, ..edges(pitch-single), counter(page).display())),
  )
  set text(font: font-family, size: type-size, lang: "en", region: "us", fill: black, fallback: false)
  // The cross-engine layout model: first fit, ragged right, no kerning, ligatures or hyphenation, line boxes of the
  // body pitch, a section sign kept with its number.
  show: xengine.with(pitch: pitch-body, list-indent: none)
  // A doubled sign stays with its number too (xengine binds a single one).
  show regex("[§¶]+ \\S+"): it => box(it)

  cover(meta)

  if "lead_in" in meta {
    body-par(above: cover-gap, md(meta.lead_in))
  }
  allegations(body, meta.at("unnumbered", default: ()), if "lead_in" in meta { 0pt } else { cover-gap })
  signature-block(meta)
}
